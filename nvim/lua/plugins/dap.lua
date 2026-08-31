return {
  "rcarriga/nvim-dap-ui",
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")
    dapui.setup({
      layouts = {
        {
          position = "left",
          size = 44,
          elements = {
            { id = "scopes", size = 0.45 },
            { id = "watches", size = 0.20 },
            { id = "stacks", size = 0.20 },
            { id = "breakpoints", size = 0.15 },
          },
        },
        {
          position = "bottom",
          size = 10,
          elements = {
            { id = "repl", size = 1.0 },
          },
        },
      },
      floating = { border = "rounded", mappings = { close = { "q", "<Esc>" } } },
    })

    -- Cleaner breakpoint / stopped signs
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
    vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint" })
    vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "CursorLine" })

    -- Run a long-lived service in a detached herdr tab (keeps its logs out of
    -- nvim). env = {KEY=VALUE}, cmd = {arg, ...}. Returns false when herdr isn't
    -- available so callers can fall back to an nvim split.
    local function herdr_run(label, cwd, cmd, env)
      if vim.fn.executable("herdr") ~= 1 then return false end
      local create = { "herdr", "tab", "create", "--label", label, "--no-focus", "--cwd", cwd }
      for k, v in pairs(env or {}) do
        table.insert(create, "--env")
        table.insert(create, k .. "=" .. tostring(v))
      end
      local ok, data = pcall(vim.fn.json_decode, vim.fn.system(create))
      local pane = ok and (((data or {}).result or {}).root_pane or {}).pane_id
      if not pane then return false end
      -- herdr types the joined args into the pane's shell, so pass the command as
      -- plain args (no `sh -c` wrapper, which would get mangled by word-splitting).
      local run = { "herdr", "pane", "run", pane }
      for _, a in ipairs(cmd) do table.insert(run, a) end
      vim.fn.system(run)
      vim.notify("Started '" .. label .. "' in a herdr tab", vim.log.levels.INFO)
      return true
    end

    -- Only use easy-dotnet's debug config; ignore the project's .vscode/launch.json
    -- (its dotnet/coreclr/blazorwasm adapters aren't registered here)
    dap.providers.configs["dap.launch.json"] = nil

    dap.listeners.before.attach.dapui_config = function() dapui.open() end
    dap.listeners.before.launch.dapui_config = function() dapui.open() end
    dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
    dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

    -- nvim 0.12's jobstart({term=true}) rejects a non-empty buffer, but nvim-dap
    -- pools and reuses terminal buffers. Before each new session, wipe only the
    -- terminal buffers whose job has already exited: frees the pool so the next
    -- launch gets a fresh buffer, keeps running services' terminals, and leaves a
    -- crashed run's output on screen until you launch again.
    local function wipe_dead_dap_terms()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.b[buf]["dap-type"] then
          local job = vim.b[buf].terminal_job_id
          local running = job and vim.fn.jobwait({ job }, 0)[1] == -1
          if not running then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
          end
        end
      end
    end
    dap.listeners.before.launch["wipe_dead_dap_terms"] = wipe_dead_dap_terms
    dap.listeners.before.attach["wipe_dead_dap_terms"] = wipe_dead_dap_terms

    -- Definitive guard: the instant a dap terminal's job exits, wipe the buffer
    -- so nvim-dap can never reuse a non-empty terminal (which nvim 0.12's
    -- jobstart({term=true}) rejects with "requires unmodified buffer").
    vim.api.nvim_create_autocmd("TermClose", {
      callback = function(args)
        if vim.b[args.buf] and vim.b[args.buf]["dap-type"] then
          vim.schedule(function() pcall(vim.api.nvim_buf_delete, args.buf, { force = true }) end)
        end
      end,
    })

    -- Azure Functions can't be launched under the debugger (the isolated worker
    -- needs `func start`), so the api gets its own flow (<leader>da): attach the
    -- bundled netcoredbg to the running worker, or start func then attach. The
    -- Functions project is found automatically — no need to be in its file.

    -- Attach netcoredbg to the worker whose binary is under proj_dir/bin (targets
    -- THIS worktree's process; no picker). Returns true once an attach fired.
    local function attach_worker(proj_dir)
      local pid = (vim.trim(vim.fn.system({ "pgrep", "-f", proj_dir .. "/bin" }))):match("%d+")
      if not pid then return false end
      local arch = (vim.trim(vim.fn.system({ "uname", "-m" })) == "arm64") and "osx-arm64" or "osx-x64"
      local ncdbg = vim.split(vim.fn.glob(vim.fn.expand(
        "~/.dotnet/tools/.store/easydotnet/*/easydotnet/*/tools/netcoredbg/" .. arch .. "/netcoredbg")), "\n")[1]
      if not ncdbg or ncdbg == "" then
        vim.cmd("Dotnet debug attach")
        return true
      end
      dap.adapters.coreclr = { type = "executable", command = ncdbg, args = { "--interpreter=vscode" } }
      dap.run({
        type = "coreclr",
        request = "attach",
        name = vim.fn.fnamemodify(proj_dir, ":t") .. " (pid " .. pid .. ")",
        processId = tonumber(pid),
        cwd = proj_dir,
      })
      return true
    end

    local function debug_functions(proj_dir)
      if attach_worker(proj_dir) then return end
      local ls = {}
      pcall(function()
        ls = vim.fn.json_decode(table.concat(
          vim.fn.readfile(proj_dir .. "/Properties/launchSettings.json"), "\n"))
      end)
      local profiles = {}
      for name in pairs((ls or {}).profiles or {}) do profiles[#profiles + 1] = name end
      table.sort(profiles)
      vim.ui.select(profiles, { prompt = "Tenant (func start + attach)" }, function(tenant)
        if not tenant then return end
        local prof_env = (ls.profiles[tenant] or {}).environmentVariables or {}
        if not herdr_run("api", proj_dir, { "func", "start" }, prof_env) then
          local env = vim.fn.environ()
          for k, v in pairs(prof_env) do env[k] = tostring(v) end
          vim.cmd("botright 15split | enew")
          vim.fn.jobstart({ "func", "start" }, { cwd = proj_dir, env = env, term = true })
          vim.cmd("stopinsert")
        end
        vim.notify("func starting… will attach when the worker is up", vim.log.levels.INFO)
        local tries, timer = 0, vim.uv.new_timer()
        timer:start(3000, 3000, vim.schedule_wrap(function()
          tries = tries + 1
          if attach_worker(proj_dir) then
            timer:stop(); timer:close()
          elseif tries >= 40 then
            timer:stop(); timer:close()
            vim.notify("Gave up waiting for the functions worker", vim.log.levels.WARN)
          end
        end))
      end)
    end

    -- Normal project: hand off to easy-dotnet's launch, scoped to the picked
    -- project via a .cs file hint (so it doesn't re-prompt for the project).
    local function debug_normal(proj_dir)
      local cs = vim.split(vim.fn.glob(proj_dir .. "/*.cs"), "\n")[1]
      if not cs or cs == "" then cs = vim.split(vim.fn.glob(proj_dir .. "/**/*.cs"), "\n")[1] end
      local client = require("easy-dotnet.rpc.rpc").global_rpc_client
      client:initialize(function()
        client.workspace:debug({ use_default = false, use_launch_profile = true, file_path = cs })
      end)
    end

    -- <leader>dd: pick a runnable project, then route Azure Functions → func +
    -- attach, everything else → easy-dotnet launch. No need to be in the file.
    local function smart_dotnet_debug()
      local sln = require("easy-dotnet.parsers.sln-parse").try_get_selected_solution_file()
      local root = (sln and sln ~= "") and vim.fn.fnamemodify(sln, ":h") or vim.fn.getcwd()
      require("easy-dotnet.fs").find_async(root, {
        match = "%.csproj$",
        depth = 6,
        on_done = vim.schedule_wrap(function(paths)
          local projects = {}
          for _, p in ipairs(paths) do
            local ok, lines = pcall(vim.fn.readfile, p)
            local xml = ok and table.concat(lines, "\n") or ""
            local is_func = (xml:find("AzureFunctionsVersion") or xml:find("Functions%.Worker")) and true or false
            -- Blazor WASM is intentionally excluded: it can't be netcoredbg-debugged
            -- (run it with <leader>dr instead).
            local runnable = is_func
              or xml:find("OutputType>%s*Exe")
              or xml:find('Sdk="Microsoft%.NET%.Sdk%.Web')
            if runnable then
              projects[#projects + 1] = {
                name = vim.fn.fnamemodify(p, ":t:r"),
                dir = vim.fn.fnamemodify(p, ":h"),
                is_func = is_func,
              }
            end
          end
          table.sort(projects, function(a, b) return a.name < b.name end)
          if #projects == 0 then return vim.cmd("Dotnet debug profile") end
          vim.ui.select(projects, {
            prompt = "Debug project",
            format_item = function(p) return p.name .. (p.is_func and "  (functions → attach)" or "") end,
          }, function(proj)
            if not proj then return end
            if proj.is_func then debug_functions(proj.dir) else debug_normal(proj.dir) end
          end)
        end),
      })
    end

    -- <leader>dr: run the Blazor WASM client in a herdr tab (keeps it out of nvim).
    local function run_client()
      local sln = require("easy-dotnet.parsers.sln-parse").try_get_selected_solution_file()
      local root = (sln and sln ~= "") and vim.fn.fnamemodify(sln, ":h") or vim.fn.getcwd()
      require("easy-dotnet.fs").find_async(root, {
        match = "%.csproj$",
        depth = 6,
        on_done = vim.schedule_wrap(function(paths)
          local client_dir
          for _, p in ipairs(paths) do
            local ok, lines = pcall(vim.fn.readfile, p)
            if ok and table.concat(lines, "\n"):find("BlazorWebAssembly") then
              client_dir = vim.fn.fnamemodify(p, ":h")
              break
            end
          end
          if not client_dir then return vim.cmd("Dotnet run profile") end
          local ls = {}
          pcall(function()
            ls = vim.fn.json_decode(table.concat(
              vim.fn.readfile(client_dir .. "/Properties/launchSettings.json"), "\n"))
          end)
          local profiles = {}
          for name in pairs((ls or {}).profiles or {}) do profiles[#profiles + 1] = name end
          table.sort(profiles)
          vim.ui.select(profiles, { prompt = "Tenant (client run)" }, function(tenant)
            if not tenant then return end
            if not herdr_run("client", client_dir, { "dotnet", "run", "--launch-profile", tenant }, {}) then
              vim.cmd("Dotnet run profile")
            end
          end)
        end),
      })
    end

    vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: continue / start" })
    vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: toggle breakpoint" })
    vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: step over" })
    vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: step into" })
    vim.keymap.set("n", "<S-F11>", dap.step_out, { desc = "Debug: step out" })
    vim.keymap.set("n", "<leader>db", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "Debug: conditional breakpoint" })
    vim.keymap.set("n", "<leader>dd", smart_dotnet_debug, { desc = "Debug: pick project (functions = func + attach, else launch)" })
    vim.keymap.set("n", "<leader>dr", run_client, { desc = "Debug: run client (Blazor) in a herdr tab" })
    vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: toggle UI" })
    vim.keymap.set("n", "<leader>dx", function() dap.terminate() end, { desc = "Debug: terminate session" })
    vim.keymap.set("n", "<leader>dX", function()
      for _, s in pairs(dap.sessions()) do
        pcall(function() s:disconnect({ terminateDebuggee = true }) end)
      end
      pcall(dap.terminate)
    end, { desc = "Debug: terminate ALL sessions" })
    vim.keymap.set({ "n", "v" }, "<leader>de", function() dapui.eval() end, { desc = "Debug: eval expression" })
  end,
}

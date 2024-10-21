#!/bin/bash
capitalized_user="$(echo $USER | sed 's/.*/\u&/')"
echo "Hi, $capitalized_user"


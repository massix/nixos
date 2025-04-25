#!/usr/bin/env bash

read -r json_input
delegated=$(echo "$json_input" | jq -r .delegated)

if [[ "$delegated" == "null" ]]; then
  echo "$json_input"
else
  added_wait=$(echo "$json_input" | jq -r --compact-output '. * {"wait": "someday"}')
  echo "$added_wait"
  echo -e "\033[01;32mSet wait to someday\033[00m"
fi

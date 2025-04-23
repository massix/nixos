#!/usr/bin/env bash

read -r json_input
jira_ticket=$(echo "$json_input" | jq -r .jira)

if [[ "$jira_ticket" == "null" ]]; then
  echo "$json_input"
  echo -e "\033[01;33mWarning: No Jira Ticket present!\033[00m"
elif [[ "${jira_ticket:0:5}" == "https" ]]; then
  echo "$json_input"
else
  jira_uppercase="$(echo "$jira_ticket" | awk '{print toupper($0)}')"
  json_with_ticket="${json_input//${jira_ticket}/https://jira.questel.com/browse/${jira_uppercase}}"
  echo "$json_with_ticket"
  echo -e "\033[01;32mAdded Jira Information\033[00m"
fi

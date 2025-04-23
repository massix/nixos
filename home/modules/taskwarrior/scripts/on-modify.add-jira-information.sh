#!/usr/bin/env bash

read -r original_task
read -r modified_task

original_jira_ticket="$(echo "$original_task" | jq -r .jira)"
modified_jira_ticket="$(echo "$modified_task" | jq -r .jira)"

if [[ "${modified_jira_ticket}" == "null" ]]; then
  echo "$modified_task"
  echo -e "\033[01;33mWarning: No Jira Ticket present!\033[00m"
elif [[ "${modified_jira_ticket:0:5}" == "https" ]]; then
  echo "${modified_task}"
else
  jira_uppercase="$(echo "$modified_jira_ticket" | awk '{print toupper($0)}')"
  json_with_ticket="${modified_task//${modified_jira_ticket}/https://jira.questel.com/browse/${jira_uppercase}}"
  echo "$json_with_ticket"
  echo -e "\033[01;32mAdded Jira Information\033[00m"
fi

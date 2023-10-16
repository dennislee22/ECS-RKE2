#!/bin/bash

# Function to check if a Kubernetes namespace exists
namespace_exists() {
  local namespace="$1"
  kubectl get namespace "$namespace" &>/dev/null
  return $?
}

# Function to execute SQL query
execute_query() {
  local query="$1"
  local namespace="$2"
  local pod_name="$3"

  kubectl exec -n "$namespace" "$pod_name" -c db -- psql -U postgres -d sense -c "$query"
}

# Function to highlight text in red
highlight_red() {
  echo -e "\e[41;97m$1\e[0m"
}

# Prompt the user for the namespace
read -p "Enter the CML workspace name: " namespace

# Check if the specified namespace exists
if ! namespace_exists "$namespace"; then
  echo "Namespace '$namespace' does not exist."
  exit 1
fi

# Prompt the user to select a specific user or all users
read -p "Enter a username or 'all' for all users: " username

# Define the PostgreSQL pod name
pod_name="db-0"

# Initialize SQL statement
sql_statement=""

if [ "$username" = "all" ]; then
  sql_statement="SELECT username,namespace FROM users;"
else
  sql_statement="SELECT username,namespace FROM users WHERE username = '$username';"
fi

# Execute the SQL query
query_result=$(execute_query "$sql_statement" "$namespace" "$pod_name")

# Check if user not found
if [[ $query_result == *"0 rows"* ]]; then
  echo "The user $(highlight_red "$username") is not found in the CML workspace $namespace."
else
  echo "$query_result"
fi

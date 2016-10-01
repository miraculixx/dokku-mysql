#!/usr/bin/env bats
load test_helper

setup() {
  export ECHO_DOCKER_COMMAND="false"
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  export ECHO_DOCKER_COMMAND="false"
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:connect) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:connect"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:connect) error when no database name is given" {
  run dokku "$PLUGIN_COMMAND_PREFIX:connect" not_existing_service
  assert_contains "${lines[*]}" "Please specify a name for the database"
}

@test "($PLUGIN_COMMAND_PREFIX:connect) error when database and service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:connect" not_existing_service not_existing_database
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:connect) error when service exists but database does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:connect" l not_existing_database
  assert_contains "${lines[*]}" "Database not_existing_database is not configured!"
}


@test "($PLUGIN_COMMAND_PREFIX:connect) success" {
  export ECHO_DOCKER_COMMAND="true"
  run dokku "$PLUGIN_COMMAND_PREFIX:connect" l l
  password="$(cat "$PLUGIN_DATA_ROOT/l/dbs/l/PASSWORD")"
  user="$(cat "$PLUGIN_DATA_ROOT/l/dbs/l/USER")"
  assert_output "docker exec -i -t dokku.mysql.l mysql --user=$user --password=$password --database=l"
}


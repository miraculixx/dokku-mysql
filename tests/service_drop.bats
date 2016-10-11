#!/usr/bin/env bats
load test_helper

setup() {
  dokku apps:create my_app >&2
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
  rm "$DOKKU_ROOT/my_app" -rf
}

@test "($PLUGIN_COMMAND_PREFIX:drop) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:drop"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:drop) error when the app argument is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:drop" l
  assert_contains "${lines[*]}" "Please specify a database name"
}

@test "($PLUGIN_COMMAND_PREFIX:drop) error when db is linked" {
  run dokku "$PLUGIN_COMMAND_PREFIX:link" l my_app l
  run dokku "$PLUGIN_COMMAND_PREFIX:drop" l l
  assert_contains "${lines[*]}" "Cannot drop linked database"
}

@test "($PLUGIN_COMMAND_PREFIX:drop) success when db is not linked" {
  run dokku "$PLUGIN_COMMAND_PREFIX:drop" l l
  assert_contains "${lines[*]}" "Database l on service l destroyed!"
}

@test "($PLUGIN_COMMAND_PREFIX:drop) error when non existent db is dropped" {
  run dokku "$PLUGIN_COMMAND_PREFIX:drop" l not_existing_database
  assert_contains "${lines[*]}" "service l has no database not_existing_database configured"
}

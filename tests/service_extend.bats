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

@test "($PLUGIN_COMMAND_PREFIX:extend) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:extend"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:extend) error when the database argument is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:extend" l
  assert_contains "${lines[*]}" "Please specify a database name"
}

@test "($PLUGIN_COMMAND_PREFIX:extend) error when db is already extended" {
  run dokku "$PLUGIN_COMMAND_PREFIX:extend" l l
  assert_contains "${lines[*]}" "service l already has database l configured"
}

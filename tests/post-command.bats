#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

# Uncomment to enable stub debugging
# export CODECOV_STUB_DEBUG=/dev/tty

@test "calls codecov with custom file" {
  export BUILDKITE_PLUGIN_CODECOV_FILE="foo/bar/boof.xml"
  export BUILDKITE_COMMAND_EXIT_STATUS=0

  stub codecov "--verbose --file=foo/bar/boof.xml : echo 'uploading boof.xml'"

  run $PWD/hooks/post-command

  assert_output --partial "uploading boof.xml"
  assert_success
  unstub codecov
}

@test "calls codecov with default glob if not overridden" {
  export BUILDKITE_COMMAND_EXIT_STATUS=0

  stub codecov "--verbose --file=dist/coverage/**/*.xml : echo 'uploading default files'"

  run $PWD/hooks/post-command

  assert_output --partial "uploading default files"
  assert_success
  unstub codecov
}

@test "does not call codecov if job failed" {
  export BUILDKITE_COMMAND_EXIT_STATUS=1

  run $PWD/hooks/post-command

  assert_output "--- :codecov: Skipping upload because job failed"
  assert_success
}

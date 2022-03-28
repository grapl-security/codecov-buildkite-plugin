#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

# Uncomment to enable stub debugging
# export DOCKER_STUB_DEBUG=/dev/tty

setup() {
    export BUILDKITE_JOB_ID="1-2-3-4"
    export BUILDKITE_COMMAND_EXIT_STATUS=0

    export DEFAULT_IMAGE="docker.cloudsmith.io/grapl/releases/codecov"
    export DEFAULT_TAG="latest"
    docker_user="$(id -u):$(id -g)"
    readonly docker_user

    # This is the default docker run command that we use, up to the
    # point where we specify the specific container to use, and the
    # arguments to it. This much of the command is constant, so we're
    # just defining it up front to make stubbing out `docker` less
    # verbose.
    export docker_run_cmd="run --init --interactive --tty --rm --user=${docker_user} --label=\"com.buildkite.job-id=${BUILDKITE_JOB_ID}\" --mount=type=bind,source=\"$(pwd)\",destination=/workdir,readonly --workdir=/workdir --env=CODECOV_TOKEN --env=BUILDKITE --env=BUILDKITE_BRANCH --env=BUILDKITE_BUILD_NUMBER --env=BUILDKITE_BUILD_URL --env=BUILDKITE_COMMIT --env=BUILDKITE_JOB_ID --env=BUILDKITE_PROJECT_SLUG --"
}

teardown() {
    unset BUILDKITE_COMMAND_EXIT_STATUS

    unset BUILDKITE_PLUGIN_CODECOV_FILE
    unset BUILDKITE_PLUGIN_CODECOV_IMAGE
    unset BUILDKITE_PLUGIN_CODECOV_IMAGE_TAG
    unset BUILDKITE_PLUGIN_CODECOV_FAIL_JOB_ON_ERROR
}

@test "does not call codecov if job failed" {
  export BUILDKITE_COMMAND_EXIT_STATUS=1

  run $PWD/hooks/post-command

  assert_output "--- :codecov: Skipping upload because job failed"
  assert_success
}

@test "calls codecov with default values" {
  stub docker \
       "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} --verbose --file=dist/coverage/**/*.xml --rootDir=/workdir : echo 'uploading default files'"

  run $PWD/hooks/post-command

  assert_output --partial "uploading default files"
  assert_success
  unstub docker
}

@test "can override default file" {
  export BUILDKITE_PLUGIN_CODECOV_FILE="foo/bar.xml"

  stub docker \
       "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} --verbose --file=foo/bar.xml --rootDir=/workdir : echo 'overriding default file glob'"

  run $PWD/hooks/post-command

  assert_output --partial "overriding default file glob"
  assert_success
  unstub docker
}

@test "can override default image" {
  export BUILDKITE_PLUGIN_CODECOV_IMAGE=foo/codecov

  stub docker \
     "${docker_run_cmd} foo/codecov:${DEFAULT_TAG} --verbose --file=dist/coverage/**/*.xml --rootDir=/workdir : echo 'overrode the default image'"

  run $PWD/hooks/post-command

  assert_output --partial "overrode the default image"
  assert_success
  unstub docker
}

@test "can override default image tag" {
  export BUILDKITE_PLUGIN_CODECOV_TAG=v6.6.6

  stub docker \
     "${docker_run_cmd} ${DEFAULT_IMAGE}:v6.6.6 --verbose --file=dist/coverage/**/*.xml --rootDir=/workdir : echo 'overrode the default tag'"

  run $PWD/hooks/post-command

  assert_output --partial "overrode the default tag"
  assert_success
  unstub docker
}

@test "can override everything" {
  export BUILDKITE_PLUGIN_CODECOV_FILE=blah.xml
  export BUILDKITE_PLUGIN_CODECOV_IMAGE=testing/codecov
  export BUILDKITE_PLUGIN_CODECOV_TAG=v1.2.3

  stub docker \
     "${docker_run_cmd} testing/codecov:v1.2.3 --verbose --file=blah.xml --rootDir=/workdir : echo 'overrode everything'"

  run $PWD/hooks/post-command

  assert_output --partial "overrode everything"
  assert_success
  unstub docker
}

@test "an error fails the job by default" {
    unset BUILDKITE_PLUGIN_CODECOV_FAIL_JOB_ON_ERROR

    stub docker \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} --verbose --file=dist/coverage/**/*.xml --rootDir=/workdir --nonZero : echo 'failed, and exit with 1'; exit 1"

    run $PWD/hooks/post-command

    assert_output --partial "failed, and exit with 1"
    assert_failure
    unstub docker
}

@test "error behavior can be overridden" {
    export BUILDKITE_PLUGIN_CODECOV_FAIL_JOB_ON_ERROR=false

    stub docker \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} --verbose --file=dist/coverage/**/*.xml --rootDir=/workdir : echo 'failed, but exit with 0'; exit 0"

    run $PWD/hooks/post-command

    assert_output --partial "failed, but exit with 0"
    assert_success
    unstub docker
}

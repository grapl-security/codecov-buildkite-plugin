# Codecov Buildkite Plugin

:warning: **Sunsetting This Repository** :warning:

Work has stopped on this plugin. The repository will still be
available in an archived state, but users are encouraged to either
fork a copy or find alternatives. The `codecov` container image we
provided will no longer be available, but you can use an alternative
or build your own from this repository (the `ENTRYPOINT` _must_ be
`codecov`). If you continue using the code from this repository, you
will need to specify an `image` in your plugin configuration (see
below).

Uploads test coverage files to https://coverage.io using the [Codecov
Uploader][uploader]. Because it uses a container image, you do not
need to have the `codecov` binary installed on your build agents to
use this plugin.

## Examples

By default, all files matching the glob `dist/coverage/**/*xml` will
be uploaded to https://coverage.io.

```yml
steps:
  - command: make test
    plugins:
      - grapl-security/codecov#v0.1.5:
          image: docker.mycompany.com/codecov
```

To override this glob, add a `file` property:

```yml
steps:
  - command: make test
    plugins:
      - grapl-security/codecov#v0.1.5:
          image: docker.mycompany.com/codecov
          file: output/cobertura.xml
```

This can also be set this globally using the
`BUILDKITE_PLUGIN_CODECOV_FILE` environment variable.

The plugin runs the `codecov` uploader using a Docker container, which
must be set with the `image` configuration value.

```yml
steps:
  - command: make test
    plugins:
      - grapl-security/codecov#v0.1.5:
          image: foobar/codecov
```

If you want to override this globally, set the
`BUILDKITE_PLUGIN_CODECOV_IMAGE` environment variable.

By default, the `latest` tag of this image is used. You would like to
override this, as well:

```yml
steps:
  - command: make test
    plugins:
      - grapl-security/codecov#v0.1.5:
          image: foobar/codecov
          tag: v1.2.3
```

This can also be set this globally using the
`BUILDKITE_PLUGIN_CODECOV_TAG` environment variable.

If using the `latest` tag of the image, it can be useful to explicitly
pull the image before running. Since the `latest` tag will change over
time, this ensures that you always get the _actual_ latest
image. While this is generally not a problem if you are using
short-lived or single-use agents, longer-lived agents would continue
to use whatever image was tagged `latest` when they ran their first
`codecov` upload.

To explicitly pull the image, set `always_pull` to `true`.

```yml
steps:
  - command: make test
    plugins:
      - grapl-security/codecov#v0.1.5:
          image: foobar/codecov
          tag: latest
          always_pull: true
```

By default, this plugin will fail a job if Codecov does not
succesfully run. If you do not want to do this, use the
`fail_job_on_error` parameter:

```yml
steps:
  - command: make test
    plugins:
      - grapl-security/codecov#v0.1.5:
          image: docker.mycompany.com/codecov
          fail_job_on_error: false
```

## Configuration
Configuration flags are organized by thematic category.

### `codecov` Uploader Flags

#### `file` (optional, string)

A file name or glob for the coverage files to upload to
https://coverage.io. The value is passed as the `--file` argument to
the [Codecov Uploader][uploader].

Defaults to `dist/coverage/**/*.xml`.

#### `flags` (optional, string)

Flag the upload to group coverage metrics. The value is passed as the
`--flags` [argument](https://docs.codecov.com/docs/flags) to the
[Codecov Uploader][uploader].

### Error Handling

#### `fail_job_on_error` (optional, boolean)

Whether or not an error in Codecov will fail the job. This can be
useful for catching misconfigurations and errors in your Codecov
setup, at the expense of failing jobs that would otherwise succeed.

Defaults to `true`.

### Container Image Configuration

#### `image` (requried, string)

The container image with the Codecov Uploader binary that the plugin
uses. Any container used should have the `codecov` binary as its
entrypoint.

#### `tag` (optional, string)

The container image tag the plugin uses.

Defaults to `latest`.

#### `always_pull` (optional, boolean)

Whether or not to perform an explicit `docker pull` of the configured
image before running. Useful when using the `latest` tag to ensure you
are always using the _actual_ latest image.

Defaults to `false`.

## Building and Contributing

Requires `make`, `docker`, the Docker `buildx` plugin, and Docker Compose v2.

`make all` will run all formatting, linting, testing, and image building.

Run `make help` to see all available targets, with brief descriptions.

Alternatively, you may also use [Gitpod](https://gitpod.io).

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/grapl-security/codecov-buildkite-plugin)

### Useful Background Information for Contributors

- [Buildkite Plugin Docs](https://buildkite.com/docs/plugins):
  Provides a general overview of what Buildkite plugins are and how they are used.
- [Writing Buildkite Plugins](https://buildkite.com/docs/plugins/writing):
  Provides more in-depth information on how to actually create a plugin.
- [Buildkite Plugin Linter](https://github.com/buildkite-plugins/buildkite-plugin-linter):
  Repository for the tool used to ensure Buildkite plugins conform to various conventions.
- [Buildkite Plugin Tester](https://github.com/buildkite-plugins/buildkite-plugin-tester):
  The testing framework used to exercise the plugin. See the [tests](./tests) directory.
- [Docker Buildx Bake](https://docs.docker.com/engine/reference/commandline/buildx_bake/):
  The tool we use to build our Codecov container image. See [docker-bake.hcl](./docker-bake.hcl) for configuration.
- [Pants](https://pantsbuild.org):
  The build system we use in this repository. See [pants.toml](./pants.toml) for configuration.

## Codecov GPG Key

The [codecov_pgp_keys.asc](./codecov_pgp_keys.asc) file was downloaded
from https://keybase.io/codecovsecurity/pgp_keys.asc on 2021-08-10,
per the instructions at
https://about.codecov.io/blog/introducing-codecovs-new-uploader/.

Its fingerprint is `27034E7FDB850E0BBC2C62FF806BB28AED779869`,
which can be verified by examining the output of

```shell
gpg --show-keys codecov_pgp_keys.asc
```

The output should match the following:

```
pub   rsa4096 2021-05-24 [SC]
      27034E7FDB850E0BBC2C62FF806BB28AED779869
uid                      Codecov Uploader (Codecov Uploader Verification Key) <security@codecov.io>
sub   rsa4096 2021-05-24 [E]
```

This key is used to verify the Codecov Uploader artifact that is built
into the container this plugin uses (see [Dockerfile](./Dockerfile))

[uploader]: https://github.com/codecov/uploader

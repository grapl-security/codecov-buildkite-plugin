# Codecov Buildkite Plugin

TESTING

More testing

Uploads test coverage files to https://coverage.io using the [Codecov
Uploader][uploader].

At the moment, this plugin is chiefly concerned with Grapl's needs,
and may not be sufficiently generalized or flexible enough for all
uses.

## Example

By default, all files matching the glob `dist/coverage/**/*xml` will
be uploaded to https://coverage.io.

```yml
steps:
  - command: make test
    plugins:
      - grapl-security/codecov#v0.1.5
```

To override this glob, add a `file` property:

```yml
steps:
  - command: make test
    plugins:
      - grapl-security/codecov#v0.1.5:
          file: output/cobertura.xml
```

This can also be set this globally using the
`BUILDKITE_PLUGIN_CODECOV_FILE` environment variable.

The plugin runs the `codecov` uploader using a Docker container. The
default image is `docker.cloudsmith.io/grapl/releases/codecov`, but this
can be overriden.

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

By default, this plugin will fail a job if Codecov does not
succesfully run. If you do not want to do this, use the
`fail_job_on_error` parameter:

```yml
steps:
  - command: make test
    plugins:
      - grapl-security/codecov#v0.1.5:
          fail_job_on_error: false
```

## Configuration

### `file` (optional, string)

A file name or glob for the coverage files to upload to
https://coverage.io. The value is passed as the `--file` argument to
the [Codecov Uploader][uploader].

Defaults to `dist/coverage/**/*.xml`.

### `flags` (optional, string)

Flag the upload to group coverage metrics.
The value is passed as the `--flags` [argument](https://docs.codecov.com/docs/flags) to
the [Codecov Uploader][uploader].

### `image` (optional, string)

The container image with the Codecov Uploader binary that the plugin
uses. Any container used should have the `codecov` binary as its
entrypoint.

Defaults to `docker.cloudsmith.io/grapl/releases/codecov`.

### `tag` (optional, string)

The container image tag the plugin uses.

Defaults to `latest`.

### `fail_job_on_error` (optional, boolean)

Whether or not an error in Codecov will fail the job. This can be
useful for catching misconfigurations and errors in your Codecov
setup, at the expense of failing jobs that would otherwise succeed.

Defaults to `true`.

## Building

Requires `make`, `docker`, the Docker `buildx` plugin, and `docker-compose`.

`make all` will run all formatting, linting, testing, and image building.

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

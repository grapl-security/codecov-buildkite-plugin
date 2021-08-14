# Codecov Buildkite Plugin

Uploads test coverage files to https://coverage.io using the [Codecov
Uploader][uploader].

At the moment, this plugin is chiefly concerned with Grapl's needs,
and may not be sufficiently generalized or flexible enough for all
uses.

NOTE: Currently, the plugin only handles the execution of the
`codecov` binary, but does not supply it. It must be present on the
`$PATH` on the Buildkite agent machine. In the future, the plugin will
be responsible for the binary as well.

## Example

By default, all files matching the glob `dist/coverage/**/*xml` will
be uploaded to https://coverage.io.

```yml
steps:
  - command: make test
    plugins:
      - grapl-security/codecov#v0.0.1
```

To override this glob, add a `file` property:

```yml
steps:
  - command: make test
    plugins:
      - grapl-security/codecov#v0.0.1:
          file: output/cobertura.xml
```

## Configuration

### file (optional, string)

A file name or glob for the coverage files to upload to
https://coverage.io. The value is passed as the `--file` argument to
the [Codecov Uploader][uploader]


[uploader]: https://github.com/codecov/uploader

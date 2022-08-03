variable "CODECOV_VERSION" {
  # The version of the Codecov Uploader (for Linux) to download from
  # https://uploader.codecov.io. This will also be incorporated into
  # the image tag.
  #
  # See https://uploader.codecov.io/linux/latest for the current
  # version.
  #
  # Update this frequently, as the Uploader is under active
  # development.
  #
  # Alternatively, supply a value for `$CODECOV_VERSION` in the
  # environment when calling `docker buildx bake`.
  default = "v0.2.5"
}

group "default" {
  targets = ["codecov"]
}

target "codecov" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "release"
  args = {
    CODECOV_VERSION = "${CODECOV_VERSION}"
  }
  labels = {
    "org.opencontainers.image.authors" = "https://graplsecurity.com"
    "org.opencontainers.image.source"  = "https://github.com/grapl-security/codecov-buildkite-plugin",
    "org.opencontainers.image.vendor"  = "Grapl, Inc."
  }
  tags = [
    # We always push everything to our "raw" repository first;
    # promotion happens elsewhere.
    "docker.cloudsmith.io/grapl/raw/codecov:latest",
    "docker.cloudsmith.io/grapl/raw/codecov:${CODECOV_VERSION}"
  ]
}

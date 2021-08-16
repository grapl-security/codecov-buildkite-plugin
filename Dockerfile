FROM ubuntu:21.04 AS base

# The version of the Codecov Uploader to download from
# https://uploader.codecov.io
ARG CODECOV_VERSION

RUN apt-get update && \
    apt-get install --yes \
    curl=7.74.0-1ubuntu2.1 \
    gpg=2.2.20-1ubuntu3

WORKDIR /workdir

COPY codecov_pgp_keys.asc codecov_pgp_keys.asc

RUN gpg --import codecov_pgp_keys.asc && \
    curl --verbose --remote-name "https://uploader.codecov.io/${CODECOV_VERSION}/linux/codecov" && \
    curl --verbose --remote-name "https://uploader.codecov.io/${CODECOV_VERSION}/linux/codecov.SHA256SUM" && \
    curl --verbose --remote-name "https://uploader.codecov.io/${CODECOV_VERSION}/linux/codecov.SHA256SUM.sig" && \
    gpg --verify codecov.SHA256SUM.sig codecov.SHA256SUM && \
    sha256sum --check codecov.SHA256SUM && \
    chmod a+x codecov

FROM gcr.io/distroless/cc:nonroot AS release
COPY --from=base /workdir/codecov /codecov
ENTRYPOINT ["/codecov"]

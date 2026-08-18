# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A minimal Docker build definition that packages Apache Spark (with a Hadoop-provided distribution) into a single container image. There is no application source code here — the repository's only purpose is to produce and publish the `spark` Docker image.

## Build system

The `Dockerfile` is a two-stage build:

1. **`buildImage` stage** (`debian:stretch`): downloads and extracts Hadoop and the Hadoop-less Spark binary tarball from Apache archive mirrors.
2. **Final stage** (`openjdk:8-alpine`): copies Spark's `bin`/`sbin`/`jars` and the Kubernetes `entrypoint.sh`, then layers in Hadoop's common/hdfs/yarn/mapreduce jars so Spark can talk to HDFS/YARN. The image entrypoint is Spark's own `entrypoint.sh` (used for Spark-on-Kubernetes driver/executor pods).

Versions are controlled via `ENV` vars at the top of each Dockerfile stage — `HADOOP_VERSION`, `SPARK_VERSION`, `SCALA_VERSION` — and must be kept in sync between the two stages when bumped. `version.txt` holds the image tag version used by CI and must be bumped separately when releasing a new version.

The `Makefile` drives build/tag/push and is parameterized entirely through variables (override via `make VAR=value ...`):

- `IMAGE` (default `spark`)
- `VERSION` (default `2.4.0`, but CI overrides it from `version.txt`)
- `REPOSITORY` (default `nexus01:8083`)
- `BUILD_ARGS` (extra `docker build` args, e.g. proxy settings)

Common commands:

```sh
# Build the image locally, tagged IMAGE:VERSION
make build

# Build behind a proxy (see README.md)
make BUILD_ARGS='--build-arg http_proxy=http://XXX:YYY --build-arg https_proxy=http://XXX:YYY' tag

# Build + tag as REPOSITORY/IMAGE:VERSION
make tag

# Build + tag + push to the Nexus registry (default target: `make` == `make push`)
make push
```

There is no lint step, no test suite, and no application code to run — validation is "does the image build and does the container start."

## CI/CD

`Jenkinsfile` defines the pipeline used on the `gitlab` GitLab connection:

1. **Init** — logs the running node.
2. **Build spark docker image** — runs `make build` with `VERSION` read from `version.txt`.
3. **Publish spark images on Nexus** — runs `make push`, but only on the `master` branch.

The workspace is deleted after every run (`post { always { deleteDir() } }`).

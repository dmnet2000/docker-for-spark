Spark Docker
===

Docker image build definition packaging Apache Spark (built without a bundled Hadoop distribution) together with Hadoop client libraries, for use as a Spark-on-Kubernetes driver/executor image.

## Image contents

- **Base image**: `openjdk:8-alpine`
- **Spark**: `2.4.0` (Scala 2.12, Hadoop-less build)
- **Hadoop**: `3.0.3` (common/hdfs/yarn/mapreduce client jars, used so Spark can access HDFS/YARN)

Spark and Hadoop are downloaded from the Apache archive in a separate build stage (`debian:stretch`) and only the required binaries/jars are copied into the final Alpine-based image, keeping it slim.

The container entrypoint is Spark's own Kubernetes `entrypoint.sh`.

Exposed ports:

| Port | Purpose                      |
|------|-------------------------------|
| 4040 | Spark application UI          |
| 8080 | Spark master UI                |
| 8081 | Spark worker UI                |
| 7077 | Spark master (RPC)             |
| 6066 | Spark master REST submission   |

## Requirements

- Docker
- `make`

## Build

Build the image locally (tagged `IMAGE:VERSION`, default `spark:2.4.0`):

```
make build
```

Build behind a proxy:

```
make BUILD_ARGS='--build-arg http_proxy=http://XXX:YYY --build-arg https_proxy=http://XXX:YYY' tag
```

Build and tag as `REPOSITORY/IMAGE:VERSION`:

```
make tag
```

Build, tag, and push to the Nexus registry (default `make` target):

```
make push
```

### Configurable variables

Override any of these via `make VAR=value ...`:

| Variable | Default |
|----------|---------|
| `IMAGE` | `spark` |
| `VERSION` | `2.4.0` |
| `REPOSITORY` | `nexus01.intranet.previmedical.it:8083` |
| `BUILD_ARGS` | *(empty)* |

## Versioning

The image version is tracked in `version.txt` and is used by the Jenkins pipeline as the `VERSION` build argument; bump it when releasing a new image version.

## CI/CD

The `Jenkinsfile` pipeline (GitLab connection `gitlab-previmedical`) builds the image on every run via `make build`, and additionally publishes it to Nexus via `make push` when the branch is `master`.

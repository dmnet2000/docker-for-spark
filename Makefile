DOCKER=docker
IMAGE=spark
VERSION=2.4.0
REPOSITORY=nexus01.intranet.previmedical.it:8083
BUILD_ARGS=

all: push

build:
	$(DOCKER) build $(BUILD_ARGS) -f Dockerfile -t $(IMAGE):$(VERSION) .

tag: build
	$(DOCKER) tag $(IMAGE):$(VERSION) $(REPOSITORY)/$(IMAGE):$(VERSION)

push: tag
	$(DOCKER) push $(REPOSITORY)/$(IMAGE):$(VERSION)


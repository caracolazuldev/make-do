
# # #
# Build/Tag (and optionally publish) Docker images
#
# Default tag is the current date and time in the format vYYYYMMDD-HHMMSS
# Override the default tag by setting the TAG_NAME environment variable
#
# **REQUIRED ENVIRONMENT VARIABLES**
#
# CI_REGISTRY/IMAGE_NAME - used to compose the fully-qualified image name
#
# Registry Credentials:
# CI_REGISTRY_USER
# CI_REGISTRY_PASSWORD
#
# **OVERRIDING BUILD**
#
# BUILD_ARGS - space-separated key-value pairs. --build-arg is auto-prefixed to each pair
# BUILD_SECRETS - space-separated secrets. --secret is auto-prefixed to each secret
# NO_CACHE - if set, disables the use of the Docker build cache
#
# BUILD_IMAGE_DIR - the directory containing the Dockerfile, defaults to the location of this file.
#
# BUILD_OPTIONS - additional options to pass to docker build
#

CI_REGISTRY_IMAGE ?= ${CI_REGISTRY}/${IMAGE_NAME}
TAG_NAME ?= $(shell date +v%Y%m%d-%H%M%S)

BUILD_IMAGE_DIR ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ifdef NO_CACHE
$(info BUILD CACHE DISABLED)
else
$(info USING BUILD CACHE)
endif

login:
	# Logging in to the Container Registry ${CI_REGISTRY}
	@docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}

publish: login tag
	docker push --all-tags ${CI_REGISTRY_IMAGE}

tag:
	docker build \
	$(if ${NO_CACHE},--no-cache) \
	$(foreach key_val, ${BUILD_ARGS}, --build-arg ${key_val}) \
	$(foreach key_val, ${BUILD_SECRETS}, --secrets ${key_val}) \
	${BUILD_OPTIONS} \
	${BUILD_IMAGE_DIR} \
	-t ${CI_REGISTRY_IMAGE}:${TAG_NAME} \
	-t ${CI_REGISTRY_IMAGE}:latest


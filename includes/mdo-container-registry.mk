# # #
# Build/Tag (and optionally publish) Docker images
#
# Make-do Makefile Library Version: 2.0.1
# https://github.com/caracolazuldev/make-do
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
export BUILD_ARGS # space-separated key-value pairs. --build-arg is auto-prefixed to each pair
export BUILD_SECRETS # space-separated secrets. --secret is auto-prefixed to each secret
export NO_CACHE # if set, disables the use of the Docker build cache
export BUILD_IMAGE_DIR # the directory containing the Dockerfile, defaults to the location of this file.
export BUILD_OPTIONS # additional options to pass to docker build

export CI_REGISTRY_IMAGE ?= ${CI_REGISTRY}/${IMAGE_NAME}
export TAG_NAME ?= $(shell date +v%Y%m%d-%H%M%S)

export BUILD_IMAGE_DIR ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

login:
	# Logging in to the Container Registry ${CI_REGISTRY}
	@docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}

publish: login
	NO_CACHE=true $(MAKE) -f $(lastword $(MAKEFILE_LIST)) build tag
	docker push --all-tags ${CI_REGISTRY_IMAGE}

tag: build
	docker tag ${CI_REGISTRY_IMAGE}:latest ${CI_REGISTRY_IMAGE}:${TAG_NAME}

build:
ifdef NO_CACHE
	$(info BUILD CACHE DISABLED)
else
	$(info USING BUILD CACHE)
endif
	docker build \
	-t ${CI_REGISTRY_IMAGE}:latest \
	$(if ${NO_CACHE},--no-cache) \
	$(foreach key_val, ${BUILD_ARGS}, --build-arg ${key_val}) \
	$(foreach key_val, ${BUILD_SECRETS}, --secrets ${key_val}) \
	${BUILD_OPTIONS} \
	${BUILD_IMAGE_DIR}


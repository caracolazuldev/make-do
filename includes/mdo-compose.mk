# # #
# Docker Compose Utilities
#
# Make-do Makefile Library Version: 2.0.1
# https://github.com/caracolazuldev/make-do
# # #

# enable use of env's in make recipes
# and help keep .env up to date since includes are always prerequisites
include .env

DKC ?= docker compose
COMPOSE_FILENAME ?= compose.yaml

# set the project directory to the repo root by default
# only used (as of this time) when generating the compose.yaml
DKC_PROJ_DIR ?= .

export DOCKER_DEFAULT_PLATFORM ?= linux/amd64

docker-platform:
	$(info DOCKER_DEFAULT_PLATFORM: $(DOCKER_DEFAULT_PLATFORM))

rebuild: .env ${COMPOSE_FILENAME} stop
	$(DKC) build --no-cache

clean-up: .env down
	$(DKC) rm

reset:
	$(DKC) down --volumes

services: ## List all services
	@$(DKC) config --services

#
# Helper functions for make recipes
#

task-up = $(if $(shell $(DKC) ps -q $1),$1 is running)
exec-or-run = $(if $(call task-up,$1),exec,run --rm) $1
warn-if-not-up = $(if $(call task-up,$1),,$(warn $1 is not running))

#
# Wrapped Docker Compose commands
#

# Commands we especially want to ensure have an up-to-date compose.yaml file
# or that we alter the default behavior (e.g. up -d, run --rm)
# and a couple included for symmetry (down, exec)
SUB_CMD_ABLE := pull build up down run exec logs

# passes additional arguments to docker compose using $(filter-out $@,$(MAKECMDGOALS))
${SUB_CMD_ABLE} : .env ${COMPOSE_FILENAME}
	$(DKC) $@ \
		$(if $(filter $@,up),-d) \
		$(if $(filter $@,run),--rm) \
		$(if $(filter $@,logs),--follow) \
		$(filter-out $@,$(MAKECMDGOALS))

ifneq ($(filter ${SUB_CMD_ABLE},$(MAKECMDGOALS)),)
# Prevent errors when non-targets are passed for sub-commands
%:
	@# No-Op
endif

#
# Generate the .env
#

# # #
# Default ENV file includes
# conf/*.env
# Does not descend into subdirectories (-maxdepth 1)
define default-env-includes
$(strip \
	$(shell find conf -maxdepth 1 -type f -name '*.env' | sort) \
)
endef

ENV_INCLUDES ?= ${default-env-includes}

.env: ${ENV_INCLUDES}
ifndef ENV_INCLUDES
	$(error ENV_INCLUDES is not set)
endif
	@# Ensure that each file ends with a newline
	@for file in $^; do \
		if [ -n "$$(tail -c 1 "$$file" | tr -d '\n')" ]; then \
			echo >> "$$file"; \
		fi; \
	done
	@ echo '# ' > $@
	@ echo '# WARNING: Generated Configuration using - $^' >> $@
	@ echo '# ' >> $@
	@cat $^ >>$@
	@echo "Generated .env using $^"

#
# Generate the Compose File
#

# # #
# Default compose files
# docker/*.yml|*.yaml
# *.profile.* files sorted last
# Does not descend into subdirectories (-maxdepth 1)
define default-compose-file-includes
$(strip \
	$(shell find docker -maxdepth 1 -type f \
		-name '*.yml' -o -name '*.yaml' \
		| grep -v profile | sort) \
	$(shell find docker -maxdepth 1 -type f \
		-name '*.profile.yml' -o -name '*.profile.yaml' | sort) \
)
endef

COMPOSE_FILES ?= ${default-compose-file-includes}

ifdef DEBUG
$(info COMPOSE_FILES=${COMPOSE_FILES})
endif

${COMPOSE_FILENAME}: .env ${COMPOSE_FILES}
ifndef COMPOSE_FILES
	$(error COMPOSE_FILES is not set)
endif
	@ echo '# ' > $@
	@ echo '# WARNING: Generated Configuration using - $^' >> $@
	@ echo '# ' >> $@
	@# We set --project-directory so that we can store our profiles in a
	@# subdirectory without changing the base path.
	$(DKC) --project-directory ${DKC_PROJ_DIR} $(foreach f,$(filter-out .env,$^),-f $f) config >> $@ $(if ${DEBUG},,2>/dev/null)

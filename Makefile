include includes/help.mk-do
include includes/require.mk-do

MAKE_INCLUDES_PATH ?= /usr/local/include/#
DEV_INSTALL ?= ${--dev}# link instead of deploy files

MDO_INCLUDES := $(shell find includes -name '*.mk-do' | sed 's/includes\///g')

default: help

define install-library
	cp includes/${@} ${MAKE_INCLUDES_PATH}${@}
endef

define link-library
	test -L ${MAKE_INCLUDES_PATH}${@} || \
	ln -s $$(pwd)/includes/${@} ${MAKE_INCLUDES_PATH}${@}
endef

define rm-library
	- test -f ${MAKE_INCLUDES_PATH}${*} && rm ${MAKE_INCLUDES_PATH}${*}
endef

define unlink-library
	- test -L ${MAKE_INCLUDES_PATH}${*} && unlink ${MAKE_INCLUDES_PATH}${*}
endef

%.mk-do:
	$(if ${DEV_INSTALL},$(link-library),$(install-library))

uninstall-%:
	$(if ${DEV_INSTALL},$(unlink-library),$(rm-library))

install: ${MDO_INCLUDES}

uninstall: $(foreach inc,${MDO_INCLUDES},uninstall-${inc})

includes/config.mk-do:
	$(eval sources = $(shell find src/ -name '*.awk' ))
	@for src in ${sources}; do \
		$(MAKE) -s -f includes/embed-awk.mk-do embed-awk -- --target=$@ --embed-file="$$src"; \
	done;

release: includes/config.mk-do | require-env-RELEASE_VERSION
	./update-version.sh ${RELEASE_VERSION}
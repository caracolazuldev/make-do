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

release: includes/config.mk-do | require-env-RELEASE_VERSION
	@$(MAKE) -s update-version \
	update-readme-overview \
	update-makedo-includes

update-version:
	@echo "Updating version to ${RELEASE_VERSION}..."
	./update-version.sh ${RELEASE_VERSION}
	@echo "Updating MKDO_VERSION in MakeDo.mk..."
	@sed -i "s/^MKDO_VERSION ?=.*/MKDO_VERSION ?= ${RELEASE_VERSION}/" MakeDo.mk

update-readme-overview:
	@echo "Updating README.md ## Include Index section..."
	@echo "" > tmp_overview
	@echo "The source of each include is the best reference. Here is an incomplete list of some of the includes, and what they provide." >> tmp_overview
	@echo "" >> tmp_overview
	@for file in $(shell find includes -name '*.mk-do' | sort); do \
		desc=$$(grep -m 1 -E '^[[:space:]]*#[[:space:]]*[[:alnum:]]' $$file | sed 's/^[[:space:]]*#[[:space:]]*//'); \
		name=$$(basename $$file); \
		echo "* \`$$name\` - $$desc" >> tmp_overview; \
	done
	@echo "" >> tmp_overview
	@sed -i '/## Include Index/,/## /{//!d}' README.md
	@sed -i '/## Include Index/r tmp_overview' README.md
	@rm tmp_overview

update-makedo-includes:
	@echo "Updating MakeDo.mk include directives..."
	@touch tmp_makedo
	@for file in $(shell find includes -name '*.mk-do' | sort); do \
		name=$$(basename $$file); \
		echo "# include $$name" >> tmp_makedo; \
	done
	# @echo "#-:" >> tmp_makedo
	@sed -i '/#:- includes/,/#-:/c\#:- includes\n#-:' MakeDo.mk
	@sed -i '/#:- includes/r tmp_makedo' MakeDo.mk
	@rm tmp_makedo

#
# Build config.mk-do
includes/config.mk-do:
	$(eval sources = $(shell find src/ -name '*.awk' ))
	@for src in ${sources}; do \
		$(MAKE) -s -f includes/embed-awk.mk-do embed-awk -- --target=$@ --embed-file="$$src"; \
	done;


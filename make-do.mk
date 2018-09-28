# Set some expectations and include general utils

# use checkbashisms to validate your scripts for use with sh.
export SHELL := sh

###
# Variables
###

# for makefiles that include this file, provide:
THIS_DIR = $(shell pwd)
# for use in this file, or use at your own risk:
this-dir := $(dir $(lastword $(MAKEFILE_LIST)))

# TODO: configure
MAKE_DO_INSTALL := /usr/local/include/make-do

-include $(THIS_DIR)/.env-config

###
# Features
###

include $(MAKE_DO_INSTALL)/util/require-env.mk
include $(MAKE_DO_INSTALL)/util/cli.mk

# Enable declaration of modules in a hidden file.
# any declared module can be executed as if it were a target
MODULES_DEF_FILE := $(THIS_DIR)/.modules
MODULES := $(shell test -f $(MODULES_DEF_FILE) && cat $(MODULES_DEF_FILE))
.PHONY: $(MODULES)

$(MODULES):
	@cd $@ && $(MAKE)

###
# Reset the default goal/target so above targets don't interfere with expectations.
.DEFAULT_GOAL :=

# Do Not define any targets below this point.

# not quite what we were going for.
# put enough effort, that maybe someday it will be useful??
#define init-this-dir :=
#$(realpath $(dir $(subst $(lastword $(MAKEFILE_LIST)), ,$(MAKEFILE_LIST) ) ) )
#endef

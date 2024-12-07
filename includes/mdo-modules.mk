# # #
#
# Module Framework (Deprecated? - needs work)
#
# Make-do Makefile Library Version: 2.0.0
# https://github.com/caracolazuldev/make-do
#
#
# Create functional units (modules) of make scripts.
# Eases keeping build directories separate from build-scripts.
#
# Adds declared modules as targets to the Makefile that includes this library.
# This hides sub-targets from the top-level Makefile, providing some order.
#
# Includes a system for providing default configuration values.
# TODO: reconcile configuration features with mdo-config.mk library.
#

###
# Variables
###

# For makefiles that include this file, provide the location of the module.
# Do not use this as a build destination.
# Make-do Modules are intended to use separated build directories and should always
# create targets in the current directory.
THIS_DIR := $(realpath $(dir $(firstword $(MAKEFILE_LIST))))
#$(info THIS_DIR $(THIS_DIR))
#$(info MAKEFILE_LIST $(MAKEFILE_LIST))

###
# Load files containing default variable assignments.
# Argument must be a directory.
#
# For nested modules, support direct execution by loading defaults from a parent directory.
# We will search up the directory tree until a directory is found that does not contain a .defaults file.
#
#	Includes start at the highest in the directory tree because consumers of modules should have precedence.
# Recommended that defaults file only use ?= assignments.
#
#	dir blindly strips off the last component of a path, be it file or dir, so we use it to refer to the parent dir.
define build-defaults-include-list
$(if $(realpath $(dir $(1))/.defaults),$(call build-defaults-include-list,$(realpath $(dir $(1))))) $(realpath $(1)/.defaults)
endef
include $(call build-defaults-include-list,$(THIS_DIR))

# Enable declaration of modules in a hidden file.
# any declared module can be executed as if it were a target
MODULES_DEF_FILE := $(THIS_DIR)/.modules
MODULES := $(shell test -f $(MODULES_DEF_FILE) && cat $(MODULES_DEF_FILE))
.PHONY: $(MODULES)

# make modules available as targets
$(MODULES):
	$(MAKE) -f ${THIS_DIR}/$@/Makefile

# Prevent re-loading make-do libraries:
#ifneq ( $(MDO_LOADED), TRUE)

###
# Reset the default goal/target so above targets don't interfere with expectations.
.DEFAULT_GOAL :=

# Do Not define any targets below this point.

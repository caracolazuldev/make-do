# # #
# Utilities for using and managing environment configuration files.
#
# TO USE:
# Insert the following at the begining of your Makefile, listing all of your config files:
#	CONFIG_INCLUDES = conf/project.conf conf/db.conf
#	include utils/configure-utils.mk
#
# IMPORTANT: each of your config files must have a template file (.tpl). Config files must have a .conf file-extension.
#
# To declare defaults for your project, include a .conf file, or include another defaults file loaded before the config.
#
# SAMPLE: export PROJECT_ROOT ?= /var/www/# comments like this are used in user-prompts.
#	prompt: export PROJECT_ROOT ( comments liek this are used in user-prompts. ) = [/var/www/]?
#
# TIP: include a trailing-slash when configuring paths. 
# TIP: terminate paths with a hash/sharp to avoid the error of trailing-white-space.
# WARNING: escape spaces in paths in your config-include list. 
#
# FEATURES:
# Includes the files in the CONFIG_INCLUDES list.
#
# Generates a conf file from a template of the same basename and extension, .tpl. Simply including the .conf file can trigger this rule if the file doesn't exist. If a variable is defined either by the environment or previous inclusion of the same file, the value will be offered as the default.
#
# Can non-interactively update a config file with values from the environment.
#
# Set AUTO_INCLUDE_CONFS instead of CONFIG_INCLUDES to include files that have a .tpl file in conf/.
# If the files conf/project.tpl, conf/db.tpl exist: CONFIG_INCLUDES will contain conf/project.conf conf/db.conf
#
# e.g. AUTO_INCLUDE_CONFS = true 
# i.e. empty is false 
#
# Provides an implicit recipe for %.conf files. This causes missing configuration files to be automatically (and interactively) generated.
#
# Provides a target, "reconfigure" that will interactively prompt you to enter the config values. Since the config file is always loaded first, you can run configure multiple times, and existing configs will be loaded as default values.
#
# Use `make add-config` to easily add new configs to your template. Specify the basename of your config file, and your new variable will be appended to the template file.
#
# # #

CACHED_DG := ${.DEFAULT_GOAL}# ensure we don't interfere with the default goal

# # #
# Shell-escape spaces.
# e.g. $(call escape-spaces, string with spaces)
#
space := 
space += # hack that exploits implicit space added when concatenating assignment
escape-spaces = $(subst ${space},\${space},$(strip $1))

# # #
# keep track of this location
this-dir := $(call escape-spaces,$(realpath $(dir $(lastword $(MAKEFILE_LIST)))))/

ifdef AUTO_INCLUDE_CONFS
CONFIG_INCLUDES = $(subst .tpl,.conf,$(shell find conf -name *.tpl))
endif

ifndef CONFIG_INCLUDES
$(error CONFIG_INCLUDES must be set before including configure-utils.mk)
endif
include ${CONFIG_INCLUDES}

###
# generate a list of variable names by parsing strings on stdin
#
# operates on lines containing an = sign
# discards 'export' if present
#
# e.g. $(eval THEVARS := $(shell $(conf_get_var_names) < ${*}.tpl))
define conf_get_var_names :=
awk '{ if ( index($$0, "=") ) { \
    equals = index($$0, "="); envar = substr($$0, 0, equals-1); \
    if ( index(envar, "export") ) envar = substr(envar, length("export ")+1); \
    print envar; \
}}'
endef

###
# Interactively generate a conf file from a template of the same basename and extension, .tpl.
# If the variable is defined either by the environment or previous inclusion of the same file, 
# the value will be offered as the default.
#
# Exports the variables to be replaced before calling the interactive shell script.
#
# Simply including the .conf file can trigger this rule if the file doesn't exist.
#
%.conf: | ${this-dir}prompt-for-configs.sh-is-exec
	@$(eval THEVARS := $(shell $(conf_get_var_names) < ${*}.tpl))
	$(foreach var,${THEVARS},$(eval export ${var})) \
	${this-dir}prompt-for-configs.sh ${*}.tpl ${@}

%-is-exec:
	chmod a+x ${*}

reconfigure:
	$(MAKE) -RrB ${CONFIG_INCLUDES}
.PHONY: reconfigure

# # #
# Shell command to replace {{TOKENs}} in a file
# Copy a template and then replace the tokens in the copy.
#
REPLACE_TOKENS = perl -p -i -e 's%\{\{([^}]+)\}\}%defined $$ENV{$$1} ? $$ENV{$$1} : $$&%eg'

.DEFAULT_GOAL := ${CACHED_DG}


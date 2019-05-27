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
# WARNING: escape spaces in paths your config-include list. 
#
# FEATURES:
# Auto-includes the files in the CONFIG_INCLUDES list.
#
# Provides a target, "configure" that will interactively prompt you to enter the config values. Since the config file is always loaded first, you can run configure multiple times, and existing configs will be loaded as default values.
# # #

include ${CONFIG_INCLUDES}

# # #
# Shell-escape spaces.
# e.g. $(call escape-spaces, string with spaces)
#
space := 
space += # hack that exploits implicit space added when concatenating assignment
escape-spaces = $(subst ${space},\${space},$(strip $1))

# # #
# Shell command to replace {{TOKENs}} in a file
# Copy a template and then replace the tokens in the copy.
#
REPLACE_TOKENS = perl -p -i -e 's%\{\{([^}]+)\}\}%defined $$ENV{$$1} ? $$ENV{$$1} : $$&%eg'

# # #
# keep track of this location
this-dir := $(call escape-spaces,$(realpath $(dir $(lastword $(MAKEFILE_LIST)))))/

%.conf: | ${this-dir}prompt-for-configs.sh-is-exec
	${this-dir}prompt-for-configs.sh ${*}.tpl ${@}

configure:
	$(MAKE) -RrB ${CONFIG_INCLUDES}

%-is-exec:
	chmod a+x ${*}

.DEFAULT_GOAL := 

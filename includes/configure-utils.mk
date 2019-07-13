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

ifdef AUTO_INCLUDE_CONFS
CONFIG_INCLUDES = $(subst .tpl,.conf,$(shell find conf -name *.tpl))
endif

ifndef CONFIG_INCLUDES
$(error CONFIG_INCLUDES must be set before including configure-utils.mk)
endif
include ${CONFIG_INCLUDES}

# # #
# generate a list of variable names by parsing strings on stdin
# e.g. $(eval THEVARS := $(shell $(conf_get_var_names) < ${*}.tpl))
#
define conf_get_var_names
awk '\
/=/ { print parse_var($$0); } \
function parse_var(s, 	var) { var = parse_declaration(s); sub("export","",var); return trim(var); } \
function parse_declaration(s) { match(s,/[^?=]*/); return substr(s,RSTART, RLENGTH); } \
${awk_utils}'
endef

# # # 
# Prompt for config values following a template file.
# e.g. - $(interactive-config) ${*}.tpl 
#
define interactive-config
awk -v WRITE_CONFIG='${@}' '\
BEGIN { \
	printf "\nGenerating Configuration of %s.\n","WRITE_CONFIG" ; print "( Press Enter to continue. C to cancel. )" ; \
	getline user < "-" ; if ( user ) { bailed = 1; exit 0; } \
	\
	print "\nLeave blank for default [value].\n" ; \
} \
/=/ { \
	declaration = parse_declaration($$0); \
	the_var = parse_var($$0); \
	default_val = trim(ENVIRON[the_var]); \
	helptext = parse_help($$0); \
	\
	printf "("helptext") " declaration "? [" default_val "] "; getline user < "-"; \
	configs[the_var] = (user) ? user : default_val ; \
	review[the_var] = sprintf("%s = %s %s", declaration, configs[the_var], helptext) ;\
} \
END { \
	if ( bailed ) { exit 0 } \
	\
	print "\nReview Changes:"; for (i in review) { print review[i]; } \
	\
	printf "\nCommit these changes? [Y/n]"; getline user < "-"; \
	if ( user == "Y" || user == "y" ) { \
		system("rm \"WRITE_CONFIG\" 2>/dev/null"); \
		while ( (getline line < FILENAME) > 0 ) { emit_config(line); } \
	}\
} \
function emit_config(line) { \
	if ( match(line,/=/)) { \
		the_var = parse_var(line); token = "{{" the_var "}}"; \
		\
		system("echo '\''" line "'\'' | sed '\''s/" token "/" configs[the_var] "/g'\'' >> \"WRITE_CONFIG\""); \
	} else { \
		system("echo '\''" line "'\'' >> \"WRITE_CONFIG\""); \
	} \
} \
function parse_var(s, 	var) { var = parse_declaration(s); sub("export","",var); return trim(var); } \
function parse_declaration(s) { match(s,/[^?=]*/); return substr(s,RSTART, RLENGTH); } \
function parse_help(s) { match($$0,/[^#]*$$/); return trim(substr($$0,RSTART,RLENGTH)); } \
${awk_utils}'
endef

define awk_utils
' \
function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s } \
function rtrim(s) { sub(/[ \t\r\n]+$$/, "", s); return s } \
function trim(s) { return rtrim(ltrim(s)); } \
function alert(label, txt) { print label " [" txt "]" } \
'
endef

###
# Interactively generate a conf file from a template of the same basename and extension, .tpl.
# If the variable is defined either by the environment or previous inclusion of the same file, 
# the value will be offered as the default.

# # #
# Creates a config file from a tpl.
#
# Exports the variables to be replaced before calling the interactive shell script.
#
%.conf:
	@$(eval THEVARS := $(shell $(conf_get_var_names) < ${*}.tpl))
	@$(foreach var,${THEVARS},$(eval export ${var})) \
	$(interactive-config) ${*}.tpl

%.conf-save:
	@$(eval THEVARS := $(shell $(conf_get_var_names) < ${*}.tpl))
	@$(foreach var,${THEVARS},$(eval export ${var})) \
	$(REPLACE_TOKENS) <${*}.tpl >${*}.conf

# # #
# -Rr, doesn't load special vars or targets; 
# -B forces re-building (the config files);
reconfigure:
	$(MAKE) -RrB ${CONFIG_INCLUDES}
.PHONY: reconfigure

# # #
# Shell command to replace {{TOKENs}} in a file
# Copy a template and then replace the tokens in the copy.
#
REPLACE_TOKENS = perl -p -e 's%\{\{([^}]+)\}\}%defined $$ENV{$$1} ? $$ENV{$$1} : $$&%eg'

.DEFAULT_GOAL := ${CACHED_DG}


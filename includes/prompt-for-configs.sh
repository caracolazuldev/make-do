#!/bin/sh

# # #
# Generates an include file for Gnu Make using scoped environment variables to replace tokens in a template.
# 
# Example implicit rule for generating .conf files from .tpl files:
# %.conf: 
#	./prompt-for-configs.sh ${*}.tpl ${@}
#
# Values can only come from the environment, or from user-prompt.
# To re-configure a file, including the config file will cause the existing values to be used by default.
#
# WARNING: ignores lines that do not contain an 'export'.
# SAMPLE: export PROJECT_ROOT ?= /var/www/# comments like this are used in user-prompts.
#	prompt: export PROJECT_ROOT ( comments liek this are used in user-prompts. ) = [/var/www/]?
#
# TIP: include a trailing-slash when configuring paths. 
# TIP: terminate paths with a hash/sharp to avoid the error of trailing-white-space.
#
# Example re-configure target where ${CONFIG_INCLUDES} contains a list of .conf files:
# configure:
#	$(MAKE) -RrB ${CONFIG_INCLUDES} 	# -Rr, doesn't load special vars or targets; -B forces re-building (the config files)
#
# # #

printf '\nGenerating Configuration of %s.\n' "$2"
printf '( Press Enter to continue. C to cancel. )'
read -r yes
if ( [ -n "$yes" ] ); then
	exit 0
fi
printf '\nLeave blank for default [value].\n'

parse_vars_from_input() {
	test "${conf_conf#*=}" = "$conf_conf" && return;	# discard lines that aren't assignments

	conf_var_declaration=$(echo "$conf_conf" | sed -s 's/\([^=?]*\).*/\1/')
	conf_var=${conf_var_declaration#*export} # remove 'export'
	conf_var=$(echo "${conf_var}" | awk '{$1=$1}1') # trim spaces

	conf_default=$(eval echo \"'$'$conf_var\\c\")
	conf_default=$(echo "${conf_default}" | awk '{$1=$1}1') # trim spaces

	conf_helptxt=$(echo "$conf_conf" | sed -s 's/[^#]*#*\([^#]*\)$/\1/')
	test -n "$conf_helptxt" && conf_help="( $conf_helptxt )"	# show provided help
}

# get vars to set from the tpl:
while IFS= read -r conf_conf; do
	parse_vars_from_input
	
	echo ${conf_help} ${conf_var_declaration}? [${conf_default}]' \c'
	read -r conf_reply </dev/tty
	if [ -z "$conf_reply" ]; then
		conf_reply="$conf_default"
	fi
	eval ${conf_var}="'$conf_reply'"
done < "$1"


printf '\nReview Changes:\n'
while IFS= read -r conf_conf; do
	parse_vars_from_input

	echo "$conf_var_declaration" = "$conf_default" "$conf_help"
done < "$1"

printf '\nCommit these changes? (Y/N) [N]'
read -r yes

if ( [ "$yes" = 'Y' ] || [ "$yes" = 'y' ] ); then
	perl -p -e 's#\{\{([^}]+)\}\}#defined $ENV{$1} ? $ENV{$1} : $&#eg' < "$1" >"$2"
else
	echo - aborted -
fi

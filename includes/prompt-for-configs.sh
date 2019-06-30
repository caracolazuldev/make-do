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
printf 'Continue? (Y/N) [Y]'
read -r yes
if ( [ "$yes" = 'n' ] || [ "$yes" = 'N' ] || [ -n "$yes" ] ); then
	exit 0
fi
printf '\nLeave blank for default [value].\n'

# get vars to set from the tpl:
while IFS= read -r conf; do
	test "${conf#*=}" = "$conf" && continue;	# discard lines that aren't assignments

	var_declaration=$(echo "$conf" | sed -s 's/\([^=?]*\).*/\1/')
	the_var=${var_declaration#*export} # remove 'export'
	the_var=$(echo "${the_var}" | awk '{$1=$1}1') # trim spaces

	default=$(eval echo -n \"'$'$the_var\")
	default=$(echo "${default}" | awk '{$1=$1}1') # trim spaces

	helptxt=$(echo "$conf" | sed -s 's/[^#]*#*\([^#]*\)$/\1/')
	test -n "$helptxt" && help="($helptxt )"	# show provided help
	
	echo -n ${var_declaration} ${help}= [${default}]?' '
	read -r reply </dev/tty
	if [ -z "$reply" ]; then
		reply="$default"
	fi
	eval ${the_var}="'$reply'"
done < "$1"


printf '\nReview Changes:\n'
while IFS= read -r conf; do
	test "${conf#*=}" = "$conf" && continue;	# discard lines that aren't assignments

	var_declaration=$(echo "$conf" | sed -s 's/\([^=?]*\).*/\1/')
	the_var=${var_declaration#*export} # remove 'export'
	the_var=$(echo "${the_var}" | awk '{$1=$1}1') # trim spaces

	helptxt=$(echo "$conf" | sed -s 's/[^#]*#*\([^#]*\)$/\1/')
	test -n "$helptxt" && help="#$helptxt"	# show provided help
	default=$(eval echo -n \"'$'$the_var\")

	echo "$var_declaration" = "$default" "$help"
done < "$1"

printf '\nCommit these changes? (Y/N) [N]'
read -r yes

if ( [ "$yes" = 'Y' ] || [ "$yes" = 'y' ] ); then
	perl -p -e 's#\{\{([^}]+)\}\}#defined $ENV{$1} ? $ENV{$1} : $&#eg' < "$1" >"$2"
else
	echo - aborted -
fi

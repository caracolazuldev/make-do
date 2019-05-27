#!/bin/sh

# # #
# Generates an include file for Gnu Make from scoped environment variables.
# 
# Example implicit rule for generating .conf files from .tpl files:
# %.conf: 
#	./prompt-for-configs.sh ${*}.tpl ${@}
#
# Values can only come from the environment, or from user-prompt.
# To re-configure a file, including the config file will cause the existing values to be used by default.
#
# Example re-configure target where ${CONFIG_INCLUDES} contains a list of .conf files:
# configure:
#	$(MAKE) -RrB ${CONFIG_INCLUDES} 	# -Rr, doesn't load special vars or targets; -B forces re-building (the config files)
#
# # #


printf '\nGenerating Configuration.\n'
printf '\nLeave blank for default value.\n'

# get vars to set from the tpl:
while IFS= read -r conf; do
	test "${conf#*export}" = "$conf" && continue;
	the_var=$(echo "$conf" | sed -s 's/export[[:space:]]*\([^[:space:]]*\).*/\1/')
	help=$(echo "$conf" | sed -s 's/[^#]*#\(.*\)$/(\1 ) / ')
	default=$(eval echo -n \"'$'$the_var\")
	printf 'export %s %s= [%s]? ' "$the_var" "$help" "$default"
	read reply </dev/tty
	if [ -z "$reply" ]; then
		reply="$default"
	fi
	eval ${the_var}="$reply"
done < "$1"


printf '\nReview Changes:\n'
while IFS= read -r conf; do
	test "${conf#*export}" = "$conf" && continue;
	the_var=$(echo "$conf" | sed -s 's/export[[:space:]]*\([^[:space:]]*\).*/\1/')
	help=$(echo "$conf" | sed -s 's/[^#]*#\(.*\)$/\1/ ')
	default=$(eval echo -n \"'$'$the_var\")
	printf 'export %s = %s#%s\n' "$the_var" "$default" "$help" 
done < "$1"

printf '\nCommit these changes? [Y/n]'
read yes

if ( [ "$yes" = 'Y' ] || [ "$yes" = 'y' ] ); then
	perl -p -e 's#\{\{([^}]+)\}\}#defined $ENV{$1} ? $ENV{$1} : $&#eg' < "$1" >"$2"
else
	echo - aborted -
fi

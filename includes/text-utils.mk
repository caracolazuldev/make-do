###
# Shell-escape spaces.
# e.g. $(call escape-spaces, string with spaces)
#
space := 
space += # hack that exploits implicit space added when concatenating assignment
escape-spaces = $(subst ${space},\${space},$(strip $1))

###
# Shell command to replace {{TOKENs}} in a file
# Copy a template and then replace the tokens in the copy.
#
REPLACE_TOKENS = perl -p -i -e 's%\{\{([^}]+)\}\}%defined $$ENV{$$1} ? $$ENV{$$1} : $$&%eg'
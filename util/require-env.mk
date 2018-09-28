
###
# Generates an error if a variable is not defined.
# Use as an order-only prerequisite to targets, i.e. after a pipe (|) character.
#  e.g. target: prereq | require-env-BUILD_HOME
#
require-env-%:
	@$(if ${${*}},, $(error required env $* is not defined))
	@ echo '$$${*} is "${${*}}"'

###
# Generates an error if a variable is not defined.
# Use to generate an error for all targets, or for a single target in a recipe.
# e.g. $(call require-env, PROJ_ROOT)
define require-env
$(if ${${strip $1}},,$(error required env ${1} is not defined))
endef

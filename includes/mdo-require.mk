# # #
# Generates an error if a variable is not defined.
#
# Make-do Makefile Library Version: 2.0.3
# https://github.com/caracolazuldev/make-do
# # #

#
# Use as an order-only prerequisite to targets, i.e. after a pipe (|) character.
#  e.g. target: prereq | require-env-BUILD_HOME
DEBUG_REQUIRE_ENV = # leave empty for false
require-env-%:
	@ $(if ${${*}},, $(error required env $* is not defined))
	@ $(if $(strip ${DEBUG_REQUIRE_ENV}),echo '$$${*} is "${${*}}"')

#
# As a macro function
# e.g. $(call require-env, PROJ_ROOT)
require-env = $(if ${$(strip ${1})},,$(error required env ${1} is not defined))

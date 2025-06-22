# # #
# Make Do fetcher.
#
# USAGE: 
# - include this file in your project Makefile.
# - set MKDO_VERSION
# - select libraries by including them in your Makefile, 
# - or un-comment here
#
# Auto-detects `wget` or `curl` commands.
# Provides the make function $(http-fetch)
# # #

#:- includes
# include auto-includes.mk-do
# include cli.mk-do
# include compose.mk-do
# include config.mk-do
# include container-registry.mk-do
# include embed-awk.mk-do
# include git.mk-do
# include help.mk-do
# include modules.mk-do
# include require.mk-do
# include wp.mk-do
#-:

#:- version
MKDO_VERSION ?= 2.1.0
#-:

MKDO_FETCH_URL ?= https://raw.githubusercontent.com/caracolazuldev/make-do/refs

%.mk-do:
	$(eval MKDO_FETCH_URI := $(if $(findstring .,${MKDO_VERSION}), \
		tags/${MKDO_VERSION}/includes, \
		heads/${MKDO_VERSION}/includes))
	@$(http-fetch) ${MKDO_FETCH_URL}/${MKDO_FETCH_URI}/$@
	@echo "Installed $@"

define http-fetch
	$(if $(shell command -v curl >/dev/null 2>&1 && echo curl), \
		curl -Ls -o $@, \
	$(if $(shell command -v wget >/dev/null 2>&1 && echo wget), \
		wget -qO $@, \
	$(error "neither curl nor wget is installed")\
	))
endef

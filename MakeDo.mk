# # #
# Make Do fetcher.
# Provides a *.mk-do recipe to download raw files from github.
#
# Provides the make function $(http-fetch) when included in your project.
#
# Requires and auto-detects either `wget` or `curl` commands.
#
# USAGE: 
# 
# For quick install:
# - include this file in your project Makefile.
# - un-comment includes below or add them to your Makefile
# - includes will be fetched (made) on next run.
#
# For more control:
# - `MKDO_VERSION=9.2.7 make -f MakeDo.mk <list includes>` will fetch to your working dir.
#
# For dev (main) branch or other branch:
# - `MKDO_VERSION=main make -f MakeDo.mk <list includes>`
#
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

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

#:-
# include compose.mk-do
#-:

#:-
MKDO_VERSION ?= 2.1.0
#-:

%.mk-do:
	$(eval MKDO_REPO ?= https://raw.githubusercontent.com/caracolazuldev/make-do)
	@$(http-fetch) ${MKDO_REPO}/refs/tags/${MKDO_VERSION}/includes/$@
	@echo "Installed $@"

define http-fetch
	$(if $(shell command -v curl >/dev/null 2>&1 && echo curl), \
		curl -Ls -o $@, \
	$(if $(shell command -v wget >/dev/null 2>&1 && echo wget), \
		wget -qO $@, \
	$(error "neither curl nor wget is installed")\
	))
endef

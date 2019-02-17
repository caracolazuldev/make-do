######
#
# Magic make, looks for *.mk files in sub-directories and includes them.
# Default target just lists includes.
#
# `make ls` finds all targets in include files, or use tab-completion.
#
# For path-dependent targets in includes, you can get the location of the include with:
# this-dir := $(dir $(lastword $(MAKEFILE_LIST)))
#
# Recomended to create a symlink in the root of your project to this file.
#
# Recommended Style Guide: http://clarkgrubb.com/makefile-style-guide
# Reference: https://www.gnu.org/software/make/manual/make.html
#
######

# defined before includes, so that included targets are not the default target.
.PHONY: includes
includes:
	@echo = sub-makes found =
	@echo $(make-includes) | tr ' ' "\n"
	@echo
	@echo Use \`\> make ls\` for available commands.

make-includes := $(shell find . -name '*.mk')
include $(make-includes)
# auto-include "Makefile" for the current directory only:
ifeq "$(shell [ -f Makefile ] && echo true)" "true"
include Makefile
endif

# restrict listing if file=glob passed
ifdef file
list_files := $(shell echo "$(MAKEFILE_LIST)" | tr ' ' "\n" | grep $(file) )
else
list_files := $(MAKEFILE_LIST)
endif

.PHONY: list ls
ls list:
	@# search all include files for targets.
	@# ... excluding special targets, and output dynamic rule definitions unresolved.
	@# tr | sort | uniq to avoid re-printing the same file.
	@for inc in $(shell echo $(list_files) | tr ' ' "\n" | sort | uniq); do \
		echo ' =' $$inc '= '; \
		grep -Eo '^[^\.#[:blank:]]+.*:.*' $$inc | grep -v '=' | \
		cut -f 1 | sort | sed 's/.*/  &/' | sed -n 's/:.*$$//p' | \
		tr $$ \\\ | tr \(\) % \
	; done

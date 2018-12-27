
util-module-init: Makefile
	touch .modules .defaults

Makefile:
	echo 'include make-do.mk' > $@
	@echo '' >>$@
	@echo 'all:' >>$@


util-module-init:
	touch .modules .defaults
	echo 'include make-do.mk' > Makefile
	@echo '' >>Makefile
	@echo 'all:' >>Makefile

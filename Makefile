
install: THIS_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
install:
	ln -s $(THIS_DIR) /usr/local/include/make-do
	ln -s $(THIS_DIR)/make-do.mk /usr/local/include/make-do.mk

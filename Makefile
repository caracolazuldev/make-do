
install: THIS_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
install: uninstall completions
	-@ cp -a $(THIS_DIR) /usr/local/include/make-do
	-@ cp $(THIS_DIR)/make-do.mk /usr/local/include/make-do.mk

system-install:
	-@ ln -s /usr/local/include/make-do/mdo /usr/local/bin/mdo

.PHONY: completions
completions:
	-@ cp $(THIS_DIR)/completions /etc/bash_completion.d/make-do

dev-install: THIS_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
dev-install: uninstall completions
	-@ test -L /usr/local/include/make-do || ln -s $(THIS_DIR) /usr/local/include/make-do
	-@ test -L /usr/local/include/make-do.mk || ln -s $(THIS_DIR)/make-do.mk /usr/local/include/make-do.mk

uninstall:
	-@ test -d /usr/local/include/make-do && rm -r /usr/local/include/make-do
	-@ test -L /usr/local/include/make-do && unlink /usr/local/include/make-do
	-@ unlink /usr/local/include/make-do.mk

# pip3:
# 	apt install python3-pip -y
# 	pip3 --version
#
# yq: pip3
# 	pip3 install jq
# 	pip3 install yq
# 	yq --version

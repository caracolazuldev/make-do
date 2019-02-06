
# Configure directory locations.
# WARNING: these values will not update paths in the scripts themselves.
# Patches welcome.
# 
cmd_path ?= /usr/local/bin/mdo
include_file_path ?= /usr/local/include
install_dir ?= ${include_file_path}/make-do

install: THIS_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST})))
install: uninstall completions
	cp -a ${THIS_DIR} ${install_dir}
	rm ${install_dir}/.git -rf
	cp ${THIS_DIR}/make-do.mk ${include_file_path}/make-do.mk

system-install:
	-@ ln -s ${install_dir}/mdo ${cmd_path}
	chmod go+x ${install_dir}/mdo

.PHONY: completions
completions:
	-@ cp ${THIS_DIR}/completions /etc/bash_completion.d/make-do
	-@ chmod go+r /etc/bash_completions.d/make-do

dev-install: THIS_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST})))
dev-install: uninstall completions
	-@ test -L ${install_dir} || ln -s ${THIS_DIR} ${install_dir}
	-@ test -L ${include_file_path}/make-do.mk || ln -s ${THIS_DIR}/make-do.mk ${include_file_path}/make-do.mk

uninstall:
	# trying both uninstall methods:
	- test -d ${install_dir} && rm -r ${install_dir}
	- test -L ${install_dir} && unlink ${install_dir}
	- unlink ${include_file_path}/make-do.mk
	# unsintall bash_completions
	rm -f /etc/bash_completions.d/make-do

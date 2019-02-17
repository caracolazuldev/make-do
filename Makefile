
# Configure directory locations.
# WARNING: these values will not update paths in the scripts themselves.
# Patches welcome.
#
cmd_path ?= /usr/local/bin
include_file_path ?= /usr/local/include
install_dir ?= ${include_file_path}/make-do
THIS_DIR := $(realpath $(dir $(firstword ${MAKEFILE_LIST})))

install: uninstall cmds

mdo-install:
	cp -a ${THIS_DIR} ${install_dir}
	rm ${install_dir}/.git -rf
	cp ${THIS_DIR}/includes/make-do.mk ${include_file_path}/make-do.mk

cmds: completions
	-@ ln -s ${install_dir}/mdo ${cmd_path}/mdo
	- rm -f $(THIS_DIR)/mdo-util/mdo-util
	$(MAKE) -C $(THIS_DIR)/mdo-util generate-cmd
	-@ ln -s ${install_dir}/mdo-util/mdo-util ${cmd_path}/mdo-util
	chmod -R a+x ${install_dir}

.PHONY: completions
completions:
	cp ${THIS_DIR}/.completions /etc/bash_completion.d/make-do
	chmod a+r /etc/bash_completion.d/make-do
	@# MDO UTIL Command:
	cp ${THIS_DIR}/mdo-util/.completions /etc/bash_completion.d/mdo-util
	chmod a+r /etc/bash_completion.d/mdo-util
	# Recommended: source /etc/bash_completion.d/*
	# to enable mdo completions for this login session.

dev-install: uninstall completions
	- test -L ${install_dir} || ln -s ${THIS_DIR} ${install_dir}
	- test -L ${include_file_path}/make-do.mk || ln -s ${THIS_DIR}/includes/make-do.mk ${include_file_path}/make-do.mk

uninstall:
	# trying both uninstall methods:
	- test -d ${install_dir} && rm -r ${install_dir}
	- test -L ${install_dir} && unlink ${install_dir}
	- unlink ${include_file_path}/make-do.mk
	# unsintall bash_completions
	rm -f /etc/bash_completion.d/make-do
	rm -f /etc/bash_completion.d/mdo-util
	# uninstall cmds
	rm -f ${cmd_path}/mdo
	rm -f ${cmd_path}/mdo-util

# Configure directory locations.
# WARNING: these values will not update paths in the scripts themselves.
# Patches welcome.
#
cmd_path ?= /usr/local/bin
include_file_path ?= /usr/local/include
install_dir ?= ${include_file_path}/make-do
THIS_DIR := $(realpath $(dir $(firstword ${MAKEFILE_LIST})))

all: uninstall install

.PHONY: completions
completions:
	cp ${THIS_DIR}/.completions /usr/local/etc/bash_completion.d/make-do
	cp ${THIS_DIR}/mdo-util/.completions /usr/local/etc/bash_completion.d/mdo-util
	chmod a+r /usr/local/etc/bash_completion.d/mdo-util
	chmod a+r /usr/local/etc/bash_completion.d/make-do
	@ echo To enable mdo completions for this login session,
	@ echo source /usr/local/etc/bash_completion.d/\*

${include_file_path}/make-do.mk:
	cp ${THIS_DIR}/includes/make-do.mk ${include_file_path}/make-do.mk

${install_dir}: ${include_file_path}/make-do.mk
	cp -a ${THIS_DIR} ${install_dir}
	- rm ${install_dir}/.git -rf
	chmod -R a+x ${install_dir}

# ${install_dir} via links
.PHONY: dev-library
dev-library:
	- test -L ${install_dir} || ln -s ${THIS_DIR} ${install_dir}
	- test -L ${include_file_path}/make-do.mk || ln -s ${THIS_DIR}/includes/make-do.mk ${include_file_path}/make-do.mk

.PHONY: generate-mdo-util
generate-mdo-util: ${install_dir}
	- rm -f ${install_dir}/mdo-util/mdo-util
	$(MAKE) -C ${install_dir}/mdo-util -f ${install_dir}/mdo-util/generate-cmd.mk

install: ${install_dir} generate-mdo-util completions
	-@ ln -s ${install_dir}/mdo-util/mdo-util ${cmd_path}/mdo-util
	-@ ln -s ${install_dir}/mdo ${cmd_path}/mdo
	chmod -R a+x ${install_dir}

dev-install: dev-library install

.PHONY: uninstall-completions
uninstall-completions:
	rm -f /usr/local/etc/bash_completion.d/mdo-util
	rm -f /usr/local/etc/bash_completion.d/make-do

.PHONY: uninstall-library
uninstall-library:
	@# unink if dev-install
	- test -L ${install_dir} && unlink ${install_dir}
	- test -d ${install_dir} && rm -r ${install_dir}
	- unlink ${include_file_path}/make-do.mk

.PHONY: uninstall
uninstall: uninstall-completions uninstall-library
	rm -rf ${cmd_path}/mdo
	rm -rf ${cmd_path}/mdo-util

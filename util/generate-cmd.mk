
util-generate-cmd: CMD_DIR ?= ${THIS_DIR}
util-generate-cmd: CMD_FILE ?= $(notdir ${CMD_DIR})
util-generate-cmd: util-generate-cmd-completions
	@ test ! -f "${CMD_FILE}" || ( echo command would be overwritten && false )
	@ echo '#!/usr/bin/env bash' > ${CMD_FILE}
	@ echo >> ${CMD_FILE}
	echo make -C ${CMD_DIR} '"$$@"' >> ${CMD_FILE}
	chmod ug+x ${CMD_FILE}

util-generate-cmd-completions: completions
	# TODO replace my_cmd in completions file
	# TODO link your completions file to /etc/bash_completion.d/my_cmd

completions:
	cp $(MAKE_DO_INSTALL)/util/completions.example completions


generate-cmd: CMD_DIR ?= ${THIS_DIR}
generate-cmd: CMD_FILE ?= $(notdir ${CMD_DIR})
generate-cmd: .completions
	@ test ! -f "${CMD_FILE}" || ( echo command would be overwritten && false )
	@ echo '#!/usr/bin/env sh' > ${CMD_FILE}
	@ echo >> ${CMD_FILE}
	echo make -f ${CMD_DIR}/Makefile '"$$@"' >> ${CMD_FILE}
	chmod ug+x ${CMD_FILE}
	@ echo generated command, ${CMD_FILE}

# TODO replace my_cmd in completions file
# TODO link your completions file to /etc/bash_completion.d/my_cmd
generate-cmd-completions:
.completions:
	cp $(MAKE_DO_INSTALL)/util/completions.example .completions
	@ echo completions generated

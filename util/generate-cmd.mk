
util-generate-cmd: CMD_DIR ?= ${THIS_DIR}
util-generate-cmd: CMD_FILE ?= $(notdir ${CMD_DIR}))
util-generate-cmd:
	@ test ! -f "${CMD_FILE}" || ( echo command would be overwritten && false )
	@ echo '#!/usr/bin/env bash' > ${CMD_FILE}
	@ echo >> ${CMD_FILE}
	echo make -C ${CMD_DIR} '"$$@"' >> ${CMD_FILE}
	chmod ug+x ${CMD_FILE}

# TODO
# util-generate-completions:

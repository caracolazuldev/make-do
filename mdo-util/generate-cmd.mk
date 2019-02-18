$(info $(shell pwd))

.PHONY: generate-cmd
generate-cmd: CMD_DIR ?= $(shell pwd)
generate-cmd: CMD_FILE ?= $(notdir ${CMD_DIR})
generate-cmd: .completions
	test ! -f "${CMD_FILE}" || ( echo command would be overwritten && false )
	echo '#!/bin/bash' > ${CMD_FILE}
	echo >> ${CMD_FILE}
	echo MAKE_CMD="'"make --no-builtin-rules --no-builtin-variables --quiet"'" >> ${CMD_FILE}
	echo '$${MAKE_CMD} -f ${CMD_DIR}/Makefile "$$@"' >> ${CMD_FILE}
	echo >> ${CMD_FILE}
	chmod ug+x ${CMD_FILE}
	@ echo generated command, ${CMD_FILE}

.PHONY: generate-cmd-completions
generate-cmd-completions: .completions

.completions:
	# TODO replace my_cmd in completions file
	# TODO link your completions file to /etc/bash_completion.d/my_cmd
	cp $(MAKE_DO_INSTALL)/mdo-util/completions.example .completions
	@ echo completions generated

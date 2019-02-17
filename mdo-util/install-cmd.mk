
BIN_DIR ?= /usr/local/bin

install-cmd: CMD_DIR ?= $(THIS_DIR)
install-cmd: CMD_FILE ?= $(notdir $(CMD_DIR))
install-cmd:
	test -L $(BIN_DIR)/$(CMD_FILE) || sudo -n ln -s $(CMD_DIR)/$(CMD_FILE) $(BIN_DIR)/$(CMD_FILE)
	@# always use an || with test so it is not interpreted as an error by make:
	test -f .completions && sudo cp .completions /etc/bash_completion.d/$(CMD_FILE).sh || true

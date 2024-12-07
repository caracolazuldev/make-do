# # #
#
# Make-do Makefile Library Version: 2.0.1
# https://github.com/caracolazuldev/make-do
# # #

define user-confirm
	@while true; do \
	  read -p '$(strip ${1})'' [y/n]: ' yn ;\
		case $$yn in \
			[Yy]* ) break;; \
			[Nn]* ) echo "Aborted" && exit 1;; \
			* ) echo "Please answer yes or no.";; \
		esac \
	done \

endef

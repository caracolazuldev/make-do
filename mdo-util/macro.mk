##
# generate m4-defines for environment vars
# tokens are delimited as {{ENV_VAR}}
define export-to-templates
	 export -p | sed -n "s/export \([^=]*\)='\([^']*\)'$$/define(\`<<\1>>'\,\`\2')dnl/p"
endef

##
# exports the environment to the template to configure the target.
# - $(call configure,config.tpl,config)
define configure
	$(call export-to-templates) | cat - $(1) |	m4 - > $(2)
endef

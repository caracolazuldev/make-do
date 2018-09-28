
# generate m4-defines for environment vars
# tokens are delimited as m4_ENV_VAR_m4
# invoke m4 with -P to prefix macros with 'm4_'
define m4-defines
	 export -p | sed -n "s/export \([^=]*\)='\([^']*\)'$$/m4_define(\`m4_\1_m4'\,\`\2')m4_dnl/p"
endef

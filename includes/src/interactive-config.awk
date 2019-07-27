# # #
# Awk program for interactive configuration.
# 
# Takes a template (.tpl) on standard-input and outputs contents
# for a configuration (.conf) file.
#
# Tokens are recognized by {{double-curl-braces}}.
# Token replacements are the values from variables in the environment.
#

BEGIN {
	FILENAME = ARGV[1];
	CONF_FILE = (ARGC > 2) ? ARGV[2] : "/dev/fd/1";

	prompt("( Press Enter to continue. C to cancel. )\n") ;
	if ( ! getline usrReply < "-" || usrReply ) { exit 0; }

	blnYes = 0;
	while ( ! blnYes ) {
		prompt("\nReview Changes:" get_conf_values() "\n"); 

		usrReply = "";
		prompt("\nIs this correct? [Y/n]");
		if ( getline usrReply < "-" == 0 ) { exit 0; }

		blnYes = ( usrReply == "Y" || usrReply == "y" );

		if ( blnYes ) {
			# reset line pointer;	# truncate output file;
			close(FILENAME); 		print "" > CONF_FILE;
			while ( (getline line < FILENAME) > 0 ) { emit_config(line); }
			prompt("Configuration saved.\n\n");
		}
	}
	exit;
}

function get_conf_values() {
	prompt("Leave blank for default [value].\n") ;
	preview = "";
	close(FILENAME); # reset filepointer
	while ( (getline line < FILENAME) > 0 ) {
		if (match(line,/=/)) {
			preview = preview prompt_for_var(line);
		}
	}
	return preview;
}

function prompt_for_var(line) {
	declaration = parse_declaration(line);
	the_var = parse_var(line);
	default_val = trim(
		( (configs[the_var]) ? configs[the_var] : ENVIRON[the_var] )
	);
	helptext = parse_help(line);
	if (helptext) { helptext = "(" helptext ") "; }

	prompt( helptext declaration "? [" default_val "] ");
	if ( ! getline usrReply < "-" ) { exit 0; }

	configs[the_var] = (usrReply) ? usrReply : default_val ;
	return sprintf("\n%s = %s# %s", declaration, configs[the_var], helptext) ;
}

function parse_var(s, 	var) {
	var = parse_declaration(s);
	sub("export","",var); return trim(var);
}
function parse_declaration(s) {
	match(s,/[^?=]*/); return substr(s,RSTART, RLENGTH); 
}
function parse_help(s) {
	match(s,"[^#}]+$"); return trim(substr(s,RSTART,RLENGTH));
}
function emit_config(line) {
	if ( match(line,/=/)) {
		the_var = parse_var(line);
		token = "\\{\\{" the_var "\\}\\}";
		gsub( token, configs[the_var], line);
	} 
	print line >> CONF_FILE;
}

# # #
# Utils
# # #
function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }
function alert(label, txt) { printf "\n%s [%s]", label, txt | "cat 1>&2" }
function prompt(s) { printf "%s", s | "cat 1>&2" }

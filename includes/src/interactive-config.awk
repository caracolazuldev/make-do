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
	getline user < "-" ; if ( user ) { exit 2; }

	while ( ! confirmed ) {
		prompt("Leave blank for default [value].\n") ;
		parse_tpl();

		prompt("\nReview Changes:\n"); 
		for (i in review) { prompt(review[i] "\n"); }

		prompt("\nIs this correct? [Y/n]"); getline user < "-";
		if ( user == "" ) { exit 2; }

		confirmed = ( user == "Y" || user == "y" );

		if ( confirmed ) {
			# reset line pointer;	# truncate output file;
			close(FILENAME); 		print "" > CONF_FILE;
			while ( (getline line < FILENAME) > 0 ) { emit_config(line); }
			prompt("Configuration saved.\n\n");
		}
	}
	exit;
}

function parse_tpl() {
	close(FILENAME); # reset filepointer
	while ( (getline line < FILENAME) > 0 ) {
		if (match(line,/=/)) {
			prompt_for_var(line);
		}
	}
}

function prompt_for_var(line) {
	declaration = parse_declaration(line);
	the_var = parse_var(line);
	default_val = trim(
		( (configs[the_var]) ? configs[the_var] : ENVIRON[the_var] )
	);
	helptext = parse_help(line);

	prompt("("helptext") " declaration "? [" default_val "] ");
	getline user < "-";

	configs[the_var] = (user) ? user : default_val ;
	review[the_var] = sprintf("%s = %s# %s", declaration, configs[the_var], helptext) ;
}

function parse_var(s, 	var) {
	var = parse_declaration(s);
	sub("export","",var); return trim(var);
}
function parse_declaration(s) {
	match(s,/[^?=]*/); return substr(s,RSTART, RLENGTH); 
}
function parse_help(s) {
	match(s,"[^#]*$");
	return trim(substr(s,RSTART,RLENGTH));
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

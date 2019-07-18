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
	prompt(sprintf("\nGenerating Configuration of %s.\n", WRITE_CONFIG)); prompt("( Press Enter to continue. C to cancel. )\n") ;
	getline user < "-" ; if ( user ) { bailed = 2; exit; }

	prompt("\nLeave blank for default [value].\n") ;
}
/=/ {
	declaration = parse_declaration($0);
	the_var = parse_var($0);
	default_val = trim(ENVIRON[the_var]);
	helptext = parse_help($0);

	prompt("("helptext") " declaration "? [" default_val "] "); getline user < "-";
	configs[the_var] = (user) ? user : default_val ;
	review[the_var] = sprintf("%s = %s # %s", declaration, configs[the_var], helptext) ;
}
END {
	if ( bailed ) { exit bailed }

	prompt("\nReview Changes:\n"); for (i in review) { prompt(review[i]); }

	prompt("\nCommit these changes? [Y/n]"); getline user < "-";
	if ( user == "Y" || user == "y" ) {
		while ( (getline line < FILENAME) > 0 ) { emit_config(line); }
	}
}

function emit_config(line) {
	if ( match(line,/=/)) {
		the_var = parse_var(line);
		token = "/{{" the_var "}}/";
		gsub( token, configs[the_var], line);
	} 
	print line;
}

function parse_var(s, 	var) { var = parse_declaration(s); sub("export","",var); return trim(var); }
function parse_declaration(s) { match(s,/[^?=]*/); return substr(s,RSTART, RLENGTH); }
function parse_help(s) { match($0,"[^#]*$");	return trim(substr($0,RSTART,RLENGTH)); }

# # #
# Utils
# # #
function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }
function alert(label, txt) { print label " [" txt "]" }
function prompt(s) { printf "%s", s | "cat 1>&2" }

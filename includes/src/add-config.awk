
function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }

function alert(label, txt) { printf "\n%s [%s]", label, txt | "cat 1>&2" }
function prompt(s) { printf "%s", s | "cat 1>&2" }

BEGIN {
	STDIN = "-"
	filename = ""
	prompt("\nFile-name? "); getline filename <STDIN
	if ( filename == "" ) { exit }

	if ( match(filename,/\.conf$|\.tpl$/) ) {
		gsub(/\.conf$|\.tpl$/, "", filename); # remove suffix
	}
	filename = filename ".tpl"

	while ( 1 ) {
		name = ""
		prompt("\nConfig Name? "); getline name <STDIN
		if ( name == "" ) { exit }

		prompt("Help text? "); getline help <STDIN
		prompt("export? [yes] "); getline no_exp <STDIN

		prefix = (no_exp) ? "" : "export " ;

		print prefix name " ?= {{" name "}}# " help >> filename
		prompt(prefix name " ?= {{" name "}}# " help " >>" filename)
	}
	exit
}
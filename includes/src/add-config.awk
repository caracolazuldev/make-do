
BEGIN {
	while ( "true" ) {
		filename = "";
		prompt("\nFile-name? "); getline filename <"-";
		if ( filename == "" ) { exit; }

		if ( match(filename,/\.conf$|\.tpl$/) ) {
			gsub(/\.conf$|\.tpl$/, "", filename); # remove suffix
		}
		filename = filename ".tpl";
		
		prompt("Config Name? "); getline name <"-";
		prompt("Help text? "); getline help <"-";
		prompt("export? [yes] "); getline noex <"-";
		prefix = (noex) ? "" : "export ";

		print prefix name " = {{" name "}}#" help >> filename;
		prompt("Generated config template: " filename);
	}
	exit;
}

function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }
function alert(label, txt) { printf "\n%s [%s]", label, txt | "cat 1>&2" }
function prompt(s) { printf "%s", s | "cat 1>&2" }
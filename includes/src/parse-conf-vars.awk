# # #
# Awk program that produces a list of variables declared in a file.
#

/=/ { print parse_var($0); }
function parse_var(s, 	var) { var = parse_declaration(s); sub("export","",var); return trim(var); }
function parse_declaration(s) { match(s,/[^?=]*/); return substr(s,RSTART, RLENGTH); }
function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }
function alert(label, txt) { print label " [" txt "]" }

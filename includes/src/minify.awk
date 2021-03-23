# # #
# Minify an awk script so it is a single line. See code
# Created for the purpose of embedding in a make macro (define statement).
# 
# ! NOTE: the rule that removes comments from the end of lines
# is a bit frail. Double-quotes or a right-curly will cause the comment
# to not be removed (and cause an error). The regex is meant to miss pound/hash
# inside of a string. Missing a right-curly-brace or semi-colon is for good
# measure.
#
# ! NOTE: tabs and consecutive spaces in strings will be altered by this script.
#

{
    if ( match($0, /^[[:blank:]]*#/) ) { next; } # skip comment-only lines
    gsub(/#[^"};]*$/, ""); # rm comments at the end of a line (like this one)
    gsub(/[\t]+/, ""); # rm tabs anywhere in line
    gsub(/[[:blank:]]+$/, ""); # rm trailing whitespace
    gsub(/[[:blank:]]{2,}/, " "); # rm repeated whitespace
    if ( match($0, /[^{};]{1}$/) ) { $0 = $0 ";" } # add semi-colons
    gsub(/[\n\r]+$/, ""); # rm line-endings
    
    printf "%s", $0; 
}

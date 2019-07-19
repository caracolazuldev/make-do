# # #
# Remove line-endings and extra whitespace from an awk script to aid in 
# embedding in a make macro (define statement).
# 
# ! NOTE: the rule that removes comments from the end of lines
# is a bit frail. Double-quotes or a right-curly will cause the comment
# to not be removed (and cause an error). The regex is meant to miss pound/hash
# inside of a string. Missing a right-curly-brace or semi-colon is for good
# measure.
#
# ! NOTE: consecutive spaces in strings will be altered by this script.
#

{
    if ( match($0, /^[[:blank:]]*#/) ) { next; }
    gsub(/#[^"};]*$/, ""); # kill comments at the end of a line (like this one)
    gsub(/[\n\r]+$/, "");
    gsub(/[\t]+/, "");
    gsub(/[[:blank:]]{2,}/, " ");
    printf "%s", $0; 
}

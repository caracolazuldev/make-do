# # #
# Remove line-endings and extra whitespace from an awk script to aid in 
# embedding in a make macro (define statement).
#

{
    if ( match($0, /^[[:space:]]*#/) ) { next; }
    gsub(/[\n\r]?$/, "");
    gsub(/[\t]+/, "");
    gsub(/[[:blank:]]{2,}/, " ");
    printf "%s", $0; 
}

# # #
#
# TODO: comments 
# TODO: can this be even smarter?
# 
#   file:///home/mzd/work/drafting/awk/Statements_002fLines.html#Statements_002fLines
#   ,    {    ?    :    ||    &&    do    else
#
#   A newline at any other point is considered the end of the statement.9 
#
# # #
# # #
# Minify an awk script so it is a single line.
# Created for the purpose of embedding in a make macro (define statement).
#
# ! NOTE: tabs and consecutive spaces in strings will be altered by this script.
#
# ! NOTE: Some implicit line-continuation is not suported. If a function call
#       is split over more than 2 lines, use explicit line-continuation ( \ ).
#
# ! NOTE: lines with hashes in strings or regex can not support the same
#       delimiter in comments; no error is generated for these cases and your code will fail.
#

{
    # remove comments:
    if ( $0 ~ /^[[:blank:]]*#/ ) next

    if ( $0 ~ /\/.*#.*\// )
        gsub(/#[^\/]*$/, "") # breaks when slash is in comment after regex
    else if ( $0 ~ /".*#.*"/ )
        gsub(/#[^"]*$/, "") # breaks when double-quote is in comment after string
    else
        gsub(/#.*$/, "")

    gsub(/^[[:blank:]]+/, "") # rm leading whitespace
    gsub(/[\t]+/, "") # rm tabs anywhere in line
    gsub(/[[:blank:]]+$/, "") # rm trailing whitespace

    # add semi-colons, unless...
    # implicit line continuation: https://www.gnu.org/software/gawk/manual/gawk.html#Statements_002fLines
    # or explicit line continuation
    # or opening a conditional or function definition
    if ( $0 !~ /,$|\{$|\?$|:$|\|\|$|&&$|do$|else$|\($|\\$/ ) {
        if (! ( $0 ~ /^if|^while|^for|^function/ && $0 ~ /\)$/ ) ) {
            # and not ends with block, semi, or colon (for switches)
            if ( $0 ~ /[^{};:]{1}$/ ) $0 = $0 ";" # ...add a semi-colon
        }
    }

    gsub(/\\$/, " "); # rm continuations
    gsub(/[[:space:]]{2,}/, " ") # rm repeated whitespace

    if ( $0 ~ /do$|else$/ ) $0 = $0 " " # ensure trailing space

    printf "%s", $0; # without line-break
}

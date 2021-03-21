# # #
# Embed an awk script as a macro (multi-line definition) to a make-file
#
# Requires that the input is escaped appropriately;
# using minify.awk and recipe-escape.awk.
#
# Wraps the script contents in an abstracted awk invocation: $(AWK) '<source>'
#
# Minimal requirement is to set SOURCE_FILE in the environment.
# The macro will be named for the SOURCE_FILE, unless overridden by DEFINE_NAME.
#
# It is recommended that you add your `define` declaration to the file so you 
# can control placement and add a comment. If it does not exist, the
# declaration will be added to the end of the file. Subsequent runs will
# replace an existing definition.
#
# SAMPLE INTEGRATION: (see update-embeds.mk for ommitted details)
#
#  embed-awk:
#     cat ${EMBED_FILE} | $(AWK) -f src/minify.awk | $(AWK) -f src/recipe-escape.awk > ${TMP_SOURCE}
#      cp ${OUTFILE} ${TMP_TARGET}	
#      SOURCE_FILE="${TMP_SOURCE}" $(AWK) -f src/embed-script-in-make.awk <${TMP_TARGET} >${OUTFILE}
#      rm ${TMP_TARGET} ${TMP_SOURCE}
#
BEGIN {
    DEFINE_BODY = readfile(ENVIRON["SOURCE_FILE"]);
    
    DEFINE_NAME = ENVIRON["DEFINE_NAME"];
    if (! DEFINE_NAME ) { DEFINE_NAME = ENVIRON["SOURCE_FILE"]; }
    DEFINE_NAME = rtrim(DEFINE_NAME);

    # we expect recipe-escape.awk to include a trailing-backslash:
    DEFINE_BODY = rtrim(DEFINE_BODY);
    gsub(/\\$/, "", DEFINE_BODY);

    # wrap the source with an awk invocation.
    DEFINE_BODY = "$(AWK) '" DEFINE_BODY "'";
   
    start_define = "define[[:blank:]]+" DEFINE_NAME "[[:blank:]]?$";
    definition = "define " DEFINE_NAME "\n" DEFINE_BODY "\nendef";
}

/define/,/^endef/ {
    if ( $0 ~ start_define ) {
        found = replacing = 1;
    }
    if ( replacing && $0 ~ /^endef/ ) {
        replacing = 0;
        print definition;
        next;
    }
}
{ if (! replacing ) { print } }

END {
    if ( ! found ) {
        print "\n" definition;
    }
}

function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }

# read an entire file at once
function readfile(file,     contents)
{
    while ((getline line < file) > 0)
        contents = contents line
    close(file)

    return contents
}
# # #
# Awk program to search and replace.
# Especially for a delimited block spanning multiple lines.
#
# NOTE: since we use strings instead of regex-constants, regex should not be
# delimited. i.e. "^This is a regex", not "/^This is a regex/".
#
BEGIN {
    BLOCK_START = ENVIRON["SEARCH"];
    BLOCK_END = ENVIRON["BLOCK_END"];
    if ( ! BLOCK_END ) {
        BLOCK_END = BLOCK_START;
    }
    REPLACE = ENVIRON["REPLACE"];
}

BLOCK_START,BLOCK_END {
    if ( $0 ~ BLOCK_START ) {
        replacing = 1;
    }
    if ( $0 ~ BLOCK_START && $0 ~ BLOCK_END ) {
        if ( BLOCK_START == BLOCK_END ) {
            search = BLOCK_START;
        } else {
            search = BLOCK_START ".*" BLOCK_END;
        }
        gsub(search, REPLACE);
        replacing = 0;
    }
    if ( replacing && $0 ~ BLOCK_END ) {
        replacing = 0;
        print REPLACE;
        next;
    }
}
{ if (! replacing ) { print } }

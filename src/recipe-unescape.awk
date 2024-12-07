# # #
# Inverse to recipe-escape.awk (for debugging presumably).
#
{
    gsub(/[\$]{2}/, "$");
    gsub(/[[:blank:]]?\\[[:blank:]]?$/, "");
    gsub(/'\''/, "'");
    print ; 
}
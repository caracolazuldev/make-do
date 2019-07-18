# # #
# Awk program to escape a command to be used in a make recipe.
# Mainly, escape dollar-signs, single-quotes, and new-lines.
#
{
    gsub(/\$/, "$$");
    gsub(/'/, "'\\''");
    print $$0 " \\" ;
}
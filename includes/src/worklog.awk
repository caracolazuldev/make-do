
BEGIN {
	REPO = ENVIRON["GIT_REPO"]
}

{
	print $0 " in " REPO
}

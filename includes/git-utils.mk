
# # #
# This is not very mature: likely to change
#
# Requires a variable, ${REPOS} that is a space-delimited list of repo names (do not include '.git').
#
# Executes common git commands for each configured repo; e.g. to get the status, or the current branch, fetch, etc...
#
# Be sure to set the ${REPO_BASE_URL}.
#

GITHUB_ORG ?= ginkgostreet
REPOS_BASE_URL ?= git@github.com:${GITHUB_ORG}/#

%-clone:
	[ -d ${*} ] && true || git clone ${REPOS_BASE_URL}${*}.git

clone repos: $(foreach repo, ${REPOS}, ${repo}-clone)

%-fetch:
	@ echo ' - ' git fetch ${*} ' - '
	@ git -C "${*}" fetch

fetch: $(foreach repo, ${REPOS}, ${repo}-fetch)

%-status:
	@ echo
	@ echo ' - ' git status ${*} ' - '
	@ git -C "${*}" status --short

status: $(foreach repo, ${REPOS}, ${repo}-status)

%-branch:
	@ $(eval BRANCH_NAME := $(shell git -C "${*}" branch | grep '^*' | tr -d '*'))
	@ echo ' - ' ${*} [ ${BRANCH_NAME} ]

branch: $(foreach repo, ${REPOS}, ${repo}-branch)

%-logs:
	@ echo
	@ echo '###' git log ${*} '###'
	@ echo
	@ git -C "${*}" log -n 4 --oneline

logs: $(foreach repo,${REPOS}, ${repo}-logs)

%-pull:
	echo "${*}"; git -C "${*}" pull

pull: $(foreach repo, ${REPOS}, ${repo}-pull)

clean-%:
	- cd ${*} && $(MAKE) clean

clean: $(foreach repo, ${REPOS}, clean-${repo})

build-%:
	-cd ${*} && $(MAKE)

build: $(foreach repo, ${REPOS}, build-${repo})


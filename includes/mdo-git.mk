include mdo-require.mk

$(call require-env,GIT_REPOS)

# # #
# This is not very mature: likely to change
#
# Requires a variable, ${GIT_REPOS} that is a space-delimited list of repo names (do not include '.git').
#
# Executes common git commands for each configured repo; e.g. to get the 
# status, or the current branch, fetch, etc...
#
# Optionally override
# - GITHUB_ORG
# - GIT_REPOS_BASE_URL
#
GITHUB_ORG ?= ginkgostreet
GIT_REPOS_BASE_URL ?= git@github.com:${GITHUB_ORG}/#

%-clone:
	[ -d ${*} ] && true || git clone ${GIT_REPOS_BASE_URL}${*}.git

clone repos: $(foreach repo, ${GIT_REPOS}, ${repo}-clone)

%-fetch:
	@ echo ' - ' git fetch ${*} ' - '
	@ git -C "${*}" fetch

fetch: $(foreach repo, ${GIT_REPOS}, ${repo}-fetch)

%-status:
	@ echo
	@ echo ' - ' git status ${*} ' - '
	@ git -C "${*}" status --short --branch

status: $(foreach repo, ${GIT_REPOS}, ${repo}-status)

%-branch:
	@ $(eval BRANCH_NAME := $(shell git -C "${*}" branch | grep '^*' | tr -d '*'))
	@ echo ' - ' ${*} [ ${BRANCH_NAME} ]

branch: $(foreach repo, ${GIT_REPOS}, ${repo}-branch)

%-logs:
	@ echo
	@ echo '###' git log ${*} '###'
	@ echo
	@ git -C "${*}" log -n 4 --oneline

logs: $(foreach repo,${GIT_REPOS}, ${repo}-logs)

%-pull:
	echo "${*}"; git -C "${*}" pull

pull: $(foreach repo, ${GIT_REPOS}, ${repo}-pull)

clean-%:
	- $(MAKE) -C ${*} clean

clean: $(foreach repo, ${GIT_REPOS}, clean-${repo})

build-%:
	- $(MAKE) -C ${*}

build: $(foreach repo, ${GIT_REPOS}, build-${repo})

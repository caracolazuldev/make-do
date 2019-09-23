include mdo-require.mk

define HELP_TEXT
 - Git Repos -
 COMMANDS
	- clone
 	- status
	- branch
	- fetch
	- pull
	- logs

 SETUP
	repos:		alias of clone
	clean:		optimistically run `make clean` on all repos
	build:		optimistically run `make build` on all repos
	filemode:	set config core.filemode false

ENVIRONMENT CONFIG
	GIT_REPOS		repo names

	- optional overrides -
	GITHUB_ORG		
	GIT_REPOS_BASE_URL	if not hosted on github.com

endef

GITHUB_ORG ?= ginkgostreet
GIT_REPOS_BASE_URL ?= git@github.com:${GITHUB_ORG}/#

%-fmode:
	@ git -C "${*}" config core.filemode false

filemode: $(foreach repo, ${GIT_REPOS}, ${repo}-fmode)

%-clone:
	[ -d ${*} ] && true || git clone ${GIT_REPOS_BASE_URL}${*}.git

clone repos: $(foreach repo, ${GIT_REPOS}, ${repo}-clone)
	$(MAKE) -C filemode

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

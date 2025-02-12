PROJECT_NAME ?= base-docs


.PHONY: build-docs
build-docs:  ## build documentation
	docker build -t ${PROJECT_NAME}-docs ./docker/docs
	docker run --rm -it -v `pwd`/docs:/docs ${PROJECT_NAME}-docs bash -c "make clean html"

.PHONY: gitignore-default
gitignore:  ## create a .gitignore file from templates
	bash config/make-gitignore.sh

.PHONY: git-update
git-update:  ## git pull as base user
	if [ "$(shell whoami)" != "base" ]; then sudo -u base git pull; else git pull; fi

.PHONY: pre-commit-init
pre-commit-init:  ## initialize pre-commit
	python3 -m pip install --upgrade pre-commit
	pre-commit install --install-hooks --overwrite

.PHONY: pre-commit-clean
pre-commit-clean:  ## clean pre-commit
	pre-commit clean

.PHONY: pre-commit-update
pre-commit-update: pre-commit-clean pre-commit-init  ## update pre-commit and hooks

.PHONY: update
update: git-update build-docs  ## update project (runs git-update and build-docs)

.PHONY: update-config
update-config:  ## update config subtree
	git subtree pull --prefix config git@github.com:base-angewandte/config.git main --squash

.PHONY: help
help:  ## show this help message
	@echo 'usage: make [command] ...'
	@echo
	@echo 'commands:'
	@egrep -h '^(.+)\:.+##\ (.+)' ${MAKEFILE_LIST} | sed 's/-default//g' | sed 's/:.*##/#/g' | sort -t# -u -k1,1 | column -t -c 2 -s '#'

# Welcome to base Angewandte’s documentation!

This is the entry point for the documentation of all our applications. While every app has its own specific docs,
here you will find all the things common to our apps: how to deploy them in production environments, how to set
up a streamlined local development environment, how to contribute and how to use some common tools and setups for
our existing projects as well as when you set up a new application.

This repo follows the same documentation structure as our applications do. So you will find the main documentation
sources in the `./docs/` folder, where you can build it locally with [Sphinx](https://www.sphinx-doc.org/). See
below for infos on how to build.

The latest stable version of this documentation is also available on [TODO:readthedocslink](#)

## Building the docs

The easiest way to build the docs is to use `make build-docs` in the root folder of this repo. You will then
find the built documentation in _./docs/build/html/index.html_. The only requirement for this is, that you have
set up [Docker](https://www.docker.com/) and the `make` command is available on your system.

If you want to build the docs directly on your host machine with _Sphinx_ (without using a Docker container), you
need to have a recent version of Python (tested only with 3.11) and install all the packages listed in the
_./docker/docs/requirements.txt_ file. Then you can go to the _./docs/_ folder and do a `make clean html` to
build the docs, which will be also built to _./docs/build/html/index.html_.

If you are unsure how to do any of that, go to our publicly rendered version of this documentation and check out
the section on the local developer setup.

## Repo info

> What are all these additional files for?

For detailed information on how our repositories are structured, check out the repository structure section in
the built docs. Here is only a quick rundown for this specific documentation repo:q

- The _config_ directory contains our common base setup for linting, pre-commit hooks, and make commands. It is
  sourced from a dedicated config repository as a git subtree. Depending on the use case of the specific repository,
  most of the files contained in this folder will be either copied or symlinked into the repository's root folder.
- The _docker_ folder contains all configs and setup for docker images used by this application. In this specific case
  there is only one image for building the docs.
- The _docs_ folder contains the actual documentation of this repository, where the index page is generated from the
  `./docs/source/index.rst` file.
- All the files in the root folder that link to a file in the _config_ folder are used for linting and out pre-commit
  hooks. The _Makefile_ in the root folder contains only a subset of the commands in _config/base.mk_, and the
  `make gitignore` command was used to generate the _.gitignore_ file.

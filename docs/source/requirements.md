# Requirements

Depending on whether you want to set up a production, testing, or local development environment, there will be
different things you need to take care of. While the [](./local_dev_setup.md) is described in a separate section,
the following notes will focus on what is needed to get our applications running on a publicly reachable server,
either for testing purposes or to run in production.

The minimal setup needed, is a fresh Linux system, with [Docker](https://docs.docker.com/get-docker/) installed, and the `make` command available.
While in theory, this should run on any major Linux distribution, we suggest using [Debian](https://www.debian.org/),
or a Debian-based distro like [Ubuntu](https://ubuntu.com/). We usually test our applications only on Debian and Ubuntu.

The specific requirement and setup then depends on whether you want to:

- go for a single-server setup, where one machine is running all applications
- or a multi-server setup, where different machines host different (parts) of our applications

In any case we suggest to do the following on any server running any (parts) of our applications:

- install the [Docker Engine](https://docs.docker.com/engine/install/) for your specific distro
- install the `make` command (e.g. with `sudo apt install make`).
  ```{note}
  This holds only for minimal server setups. In more complex cases you might want to install the `build-essential`
  package instead (this will also install `make`). Especially in a local dev setup you will need it to manage
  python evironments. If you run into issues with building something on a test server, where you only installed
  `make`, try installing the `build-essential` first.
  ```
- for legacy reasons we currently need to also have the `docker-compose` command available, which was superseded by
  `docker compose`. If your specific docker installation provides both, you are all set. Otherwise, you can emulate
  the older _docker-compose_ command by doing the following:
  ```bash
  echo 'docker compose "$@"' | sudo tee /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  ```

To decide which path to take from here, a requirement is to understand how our different applications work together.
The following diagramme should help to explain this based on a single-server setup:

TODO: add diagramme

In case of a multi-server setup, you can decide to take some parts, e.g. the Portfolio frontend and backend, to be
hosted on a dedicated machine, similar to the Showroom frontend and backend, while keeping Baseauth on your main
machine serving as an entry point. In this case you will nevertheless need the _nginx_ component on every machine,
as it serves as the reverse proxy distribution incoming HTTP requests to either frontends or backends of each
application.

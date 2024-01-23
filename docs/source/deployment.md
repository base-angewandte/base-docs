# Deployment of base Applications

Before you start to deploy anything, make sure you meet all the [](./requirements.md).

## General setup procedure

The general principle for any setup is to deploy the most upstream service first, and the nginx service at the end.
So a common setup procedure just for Portfolio would take the following order:

- set up baseauth
- set up portfolio-backend
- set up portfolio-frontend
- set up nginx

If you also want to set up Showroom, you would squeeze the setup of showroom-backend and showroom-frontend in after
Portfolio is set up, but before nginx is set up.

## Multi-server setup procedure

On a multi-server-setup, where baseauth, Portfolio and Showroom are
all set up on different machines you would do the following:

- set up machine with baseauth:
  - set up baseauth
  - set up nginx
- set up machine with Portfolio:
  - set up portfolio-backend
  - set up portfolio-frontend
  - set up nginx
- set up machine with Showroom:
  - set up showroom-backend
  - set up showroom-frontend
  - set up nginx

In this scenario you will have to update the nginx config of that machine, that serves as the initial entry point
for user requests. But you could even set up a fourth machine only with nginx, which then serves as the first
reverse proxy. All other nginx containers on the other machines are only reverse proxies for the single services
they are hosting.

## Single-Server-Setup of Portfolio and Showroom

In this section we'll walk you through a setup of Portfolio and Showroom on a single machine.

TODO

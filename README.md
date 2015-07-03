TYPO3 Flow in Docker
====================

This repository contains a Docker base image for building containerized
**TYPO3 Flow** applications.

Use for development
-------------------

While in development, you may want to mount your TYPO3 Flow application from a
host-local directory into your container.

To do this, start your container like this:

    docker run --name flow-db \
               -e MYSQL_ROOT_PASSWORD=secret \
               -e MYSQL_PASSWORD=othersecret \
               -e MYSQL_USER=flow \
               -e MYSQL_DATABASE=flow \
               mariadb:latest
    docker run --name flow-web \
               --link flow-db:db \
               -v $PWD:/var/www \
               -p 80:80 \
               martinhelmich/flow:dev

The `-v $PWD:/var/www` mounts your local working directory into the container's
`/var/www` directory, from which the Flow application is served. The `-p 80:80`
maps the container port 80 to your host port 80, allowing your TYPO3 Flow
application to be accessed by `http://localhost`.

Use for production
------------------

In production, you'd typically want to bake your TYPO3 Flow application into a
custom Docker image. This is possible with this image, too, due to an
`ONBUILD ADD . /var/www` instruction in the Dockerfile.

Simply include a custom `Dockerfile` in your Flow application's root directory
with the following contents:

    FROM martinhelmich/flow:prod

Then build the image:

    docker build -t you/custom-flow-app .

And run it:

    docker run --name flow-web \
               --link flow-db:db \
               -p 80:80 \
               you/custom-flow-app

The `prod` image differs from the `dev` image in a few aspects:

1. Of course, the `FLOW_CONTEXT` environment variable is set to `PRODUCTION` in
   the `prod` image. Duh.
2. On startup, the TYPO3 Flow Cache will be warmed up by executing a
   `./flow flow:cache:warmup` on startup.
3. Furthermore, Doctrine migration will be executed if necessary on startup
   (unless the `FLOW_DB_DISABLE` environment variable was set).

Special behaviours
------------------

If you link a database container into the application container and use `db` as
the link alias, the start script will automatically write a `Settings.yaml` file
containing the database credentials needed for connecting to the linked container.

Running Flow shell commands
---------------------------

The easiest way to run Flow CLI commands is to use the [docker-flow](docker-flow)
command line tool. This command actually links a new, transient container to
your application container and executes the command in that container.

First, install the `docker-flow` CLI tool into your Flow application:

    curl https://raw.githubusercontent.com/martin-helmich/docker-flow/master/docker-flow > docker-flow
    chmod +x docker-flow

Then use it like the conventional `flow` command line utility, specifying the
name of your application container as the first parameter:

    ./docker-flow flow-web flow:cache:warmup

Various administration tasks
----------------------------

You can use the general Docker commands to run arbitrary commands or even start
an interactive shell for your TYPO3 Flow application.

Start a shell in a new container linked to the application container:

    docker run --rm -it --volumes-from <app-container-name> --user flow --workdir /var/www martinhelmich/flow:dev bash

You can also use `docker exec` to run administrative commands inside the same
container:

    docker exec <app-container-name> supervisorctl restart nginx

# Taiga Docker

Standalone docker image for [Taiga](https://taiga.io) open source agile project mangment tool.

This image embbed : Taiga-back, Taiga-front, Taiga-events & Nginx as reverse proxy

## Quick start

```
$ docker run --rm --name taiga -p 80:80 mikamboo/taiga
```

Taiga is running at [http://locahost](http://locahost)

Admin default credentials : `username = 'admin' password = '123123'`

## Build this image 

```
$ git clone https://github.com/mikamboo/docker-taiga.git
$ cd docker-taiga
$ docker built -t me/taiga .
$ cp env.sample env # Then edit env file to set your params
$ docker run --rm --name taiga -p 80:80 --env-file env me/taiga
```

## Parameters

To setup and deploy this image on your server you need to set `env` params. 
You can use provided `env.sample` file an pass it docker container start command

```
$ docker run -d --name taiga -p 80:80 --env-file env mikamboo/docker-taiga
```

Smple start script

```
#!/bin/sh

ENV_FILE=/root/docker/taiga/env
docker run -d --name taiga --env-file $ENV_FILE \
    -v /srv/taiga/taiga:/home/taiga \
    -v /srv/taiga/data/pgdb:/var/lib/postgresql \
    -v /srv/taiga/pgconf:/etc/postgresql \
    -p 8005:80 \
taiga
```

## TODO 

* Create a docker-compose stack (taiga, pgsql, ...)

## Resources 

* [Taiga install doc](http://taigaio.github.io/taiga-doc/dist/setup-production.html)
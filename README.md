# Taiga Docker

Standalone docker image for [Taiga](https://taiga.io) open source agile project mangment tool.

This image embbed : Taiga-back, Taiga-front, Taiga-events & Nginx as reverse proxy

## Quick start

```
$ docker run --rm --name taiga -p 80:80 mikamboo/taiga
```

Taiga is running at [http://locahost](http://locahost)

## Build this image 

```
$ git clone https://github.com/mikamboo/taiga-docker.git
$ cd taiga-docker
$ docker built -t me/taiga .
$ cp env.sample env # Then edit env file to set your params
$ docker run --rm --name taiga -p 80:80 --env-file env me/taiga
```

## Parameters

To setup and deploy this image on your server you need to set `env` params. 
You can use provided `env.sample` file an pass it docker container start command

```
$ docker run -d --name taiga -p 80:80 --env-file env mikamboo/taiga
```

## Resources 

* [Taiga install doc](http://taigaio.github.io/taiga-doc/dist/setup-production.html)
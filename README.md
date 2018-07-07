[appurl]: http://serviio.org/
[hub]: https://hub.docker.com/r/cina/serviio/
[ffmpeg]: https://hub.docker.com/r/jrottenberg/ffmpeg/
[lsio]: https://hub.docker.com/r/lsiocommunity/serviio/

## Serviio with FFMPEG 4

This container is based on [FFMPEG docker image][ffmpeg] with modification applied from [LinuxServer.io][lsio] Serviio image.

[Serviio][appurl] is a free media server. It allows you to stream your media files (music, video or images) to renderer devices (e.g. a TV set, Bluray player, games console or mobile phone) on your connected home network.

[![serviio](https://raw.githubusercontent.com/linuxserver/community-templates/master/lsiocommunity/img/serviio-icon.png)][appurl]

## Usage

```
docker create --name=serviio \
-v /etc/localtime:/etc/localtime:ro \
-v <path to data>:/config \
-v <path to media>:/media \
-v <path for transcoding>:/transcode \
-e PGID=<gid> -e PUID=<uid> \
-e SERVIIO_OPTS='serviio.cdsAnonymousAccess=true' \
--net=host cina/serviio
```

## Parameters

The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.


* `--net=host` - Set network type
* `-v /etc/localtime` for timesync - *optional*
* `-v /config` - Where serviio stores its configuration files etc.
* `-v /media` - Path to your media files, add more as necessary, see below.
* `-v /transcode` - Transcode folder - see below. -*optional, but recommended*
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e SERVIIO_OPTS` for additional java runtime options - see this [page](http://www.serviio.org/component/content/article/10-uncategorised/43-supported-system-properties)

It is based on [FFMPEG docker image][ffmpeg] with s6 overlay, for shell access whilst the container is running do `docker exec -it serviio /bin/bash`.

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up the application

The webui is at `<your-ip>:23423/console` 

Add as many media folder mappings as required with `-v /media/tv-shows` etc... 
Setting a mapping for transcoding `-v /transcode`  ensures that the container doesn't grow unneccesarily large.

## Info

* Shell access whilst the container is running: `docker exec -it serviio /bin/bash`
* To monitor the logs of the container in realtime `docker logs -f serviio`.

* container version number 

`docker inspect -f '{{ index .Config.Labels "build_version" }}' serviio`

* image version number

`docker inspect -f '{{ index .Config.Labels "build_version" }}' cina/serviio`


## Versions

+ **09.06.18:** Initial version 1.9.2 and ffmpeg to 4.0.

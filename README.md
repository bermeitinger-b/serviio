[appurl]: http://serviio.org/
[hub]: https://hub.docker.com/r/cina/serviio/
[ffmpeg]: https://hub.docker.com/r/jrottenberg/ffmpeg/
[lsio]: https://hub.docker.com/r/lsiocommunity/serviio/
## Serviio
**[Serviio][appurl] is a free media server. It allows you to stream your media files (music, video or images) to renderer devices (e.g. a TV set, Bluray player, games console or mobile phone) on your connected home network.**
This container is made by the vision of originality and compatibilty. This build was designed to follow [zip](http://forum.serviio.org/memberlist.php?mode=viewprofile&u=2&sid=47fff9ad505fde0bc0295130098c9a57)'s method to build windows installer transferred to Linux.
Source of code and information:
- [Serviio wiki page of building from source code](http://wiki.serviio.org/doku.php?id=build_ffmpeg_linux) 
- [Serviio download page](http://www.serviio.org/download)
- Source codes from http://download.serviio.org/opensource "repository".
- S6 layer and setup sampled from [lsio serviio][lsio] image - thanks for their team.

Image is based on [anapsix java image](https://hub.docker.com/r/anapsix/alpine-java).
## Usage
    docker create --name=serviio \
    -v /etc/localtime:/etc/localtime:ro \
    -v <path to data>:/config \
    -v <path to media>:/media \
    -v <path for transcoding>:/transcode \
    -e PGID=<gid> -e PUID=<uid> \
    -e SERVIIO_OPTS='serviio.cdsAnonymousAccess=true' \
    --net=host cina/serviio
## docker-compose.yml
    version: '2.4'
    
    volumes:
      serviio-config: 
        external: true
      serviio-start:
        external: true
    
    services:
      serviio:
        image: cina/serviio:test
        container_name: serviio
        volumes:
          - serviio-config:/config 
          - /tmp:/transcode 
          - /etc/localtime:/etc/localtime:ro 
          - /media:/media 
          - /mnt/storage/media:/mnt/storage/media 
        network_mode: 'host'
        mem_limit: 2gb
        environment:
          - 'SERVIIO_OPTS=-Dserviio.cdsAnonymousAccess=true'
          - 'PGID=996' 
          - 'PUID=997' 
        restart: unless-stopped
## Parameters
* `--net=host` - Only works with host networking (Needs UDP broadcast)
* `-v /etc/localtime` for timesync - *optional*
* `-v /config` - Configuration files
* `-v /media` - Media files
* `-v /transcode` - Transcode location
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e SERVIIO_OPTS` for additional java runtime options - see this [page](http://www.serviio.org/component/content/article/10-uncategorised/43-supported-system-properties)
### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.
In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

    $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)

## Setting up the application

The webui is at `<your-ip>:23423/console` 

Add as many media folder mappings as required with `-v /media/tv-shows` etc... 
Setting a mapping for transcoding `-v /transcode`  ensures that the container doesn't grow unnecessarily large.

## Info

- Shell access whilst the container is running: `docker exec -it serviio /bin/bash`
- To monitor the logs of the container in realtime `docker logs -f serviio`.




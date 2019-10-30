# Serviio

**[Serviio](appurl) is a free media server. It allows you to stream your media files (music, video or images) to renderer devices (e.g. a TV set, Bluray player, games console or mobile phone) on your connected home network.**
This container is made by the vision of originality and compatibilty. This build was designed to follow [zip](http://forum.serviio.org/memberlist.php?mode=viewprofile&u=2&sid=47fff9ad505fde0bc0295130098c9a57)'s method to build windows installer transferred to Linux.

The image was build from the following images:

- Image is based on [openjdk/8-jre-alpine](https://hub.docker.com/_/openjdk) image.
- FFMPEG is copied from [jrottenberg/ffmpeg:4.2-scratch](https://hub.docker.com/r/jrottenberg/ffmpeg) image.

## Usage

**Remember to create the volume folders `/config`, `/media`, `/transcoding`, `/app/serviio/log` on the host prior to running docker**

```bash
  docker create --name=serviio \
    -v /etc/localtime:/etc/localtime:ro \
    -v <path to data>:/config \
    -v <path to media>:/media:ro \
    -v <path for transcoding>:/transcode \
    -v <path for logging>:/app/serviio/log \
    --user "$(id -u):$(id -g)" \
    --network="host" \
    bermeitingerb/serviio:latest
```

## Parameters
- `--network="host"` - Only works with host networking (Needs UDP broadcast)
- `-v /etc/localtime` for timesync - *optional*
- `-v /config` - Configuration files
- `-v /media` - Media files
- `-v /transcode` - Transcode location

## Setting up the application

The webui is at `<your-ip>:23423/console` 

Add as many media folder mappings as required with `-v /media/tv-shows` etc... 
Setting a mapping for transcoding `-v /transcode`  ensures that the container doesn't grow unnecessarily large.

## Info

- Shell access whilst the container is running: `docker exec -it serviio /bin/bash`
- To monitor the logs of the container in realtime `docker logs -f serviio`.

## Sources
- First version: [LinuxServer](https://hub.docker.com/r/lsiocommunity/serviio/) (deprecated)
- Clone: [cina](https://hub.docker.com/r/cina/serviio/)
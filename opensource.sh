#!/bin/bash

PREF="/usr"
DEST="/tmp/opensource/destination"

FLDR=(  lame
	libogg
	rtmpdump
	freetype
	fontconfig
	speex
	libass
	opencore
	x264
	xvidcore
	ffmpeg
)
DOWN=(  "http://download.serviio.org/opensource/lame-3.99.5.tar.gz"
        "http://download.serviio.org/opensource/libogg-1.3.2.tar.gz"
        "http://download.serviio.org/opensource/rtmpdump.tar.gz"
        "http://download.serviio.org/opensource/freetype-2.4.11.tar.gz"
        "http://download.serviio.org/opensource/fontconfig-2.10.91.tar.gz"
        "http://download.serviio.org/opensource/speex-1.2rc1.tar.gz"
        "http://download.serviio.org/opensource/libass-0.10.1.tar.gz"
	"http://kent.dl.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-0.1.5.tar.gz"
        "http://download.serviio.org/opensource/last_x264.tar.bz2"
	"http://downloads.xvid.org/downloads/xvidcore-1.3.4.tar.gz"
	"http://download.serviio.org/opensource/ffmpeg-3.4.4.tar.bz2" 
)
CONF=(  "./configure --prefix=${PREF}"
	"./configure --prefix=${PREF}"
	"./configure --prefix=${PREF}"
	"./configure --prefix=${PREF}"
	"./configure --prefix=${PREF}"
	"./configure --prefix=${PREF}"
	"./configure --prefix=${PREF}"
	"./configure --prefix=${PREF}"
	"./configure --enable-static --disable-opencl --enable-pic --prefix=${PREF}"
	"cd build/generic && ./configure --enable-static --prefix=${PREF}"
	"./configure --enable-gpl --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libx264 --enable-nonfree --enable-postproc --enable-version3 --enable-librtmp --enable-libxvid --enable-libass --enable-libfdk_aac --disable-debug --disable-doc --disable-ffplay --prefix=${PREF}"
)

apk add --no-cache --virtual=build-dependencies build-base gcc jasper-dev jpeg-dev libc-dev lcms2-dev openssl-dev linux-headers nasm fribidi-dev expat-dev

# we need edge/testing for libfdk_aac
apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing fdk-aac-dev libtheora-dev libvorbis-dev

mkdir -p /tmp/opensource
cd /tmp/opensource

total=${#FLDR[*]}
for (( i=0; i<=$(( $total -1 )); i++ ))
do
	echo "Compiling ${FLDR[$i]}"
	mkdir "${FLDR[$i]}"
	cd "${FLDR[$i]}"
	wget "${DOWN[$i]}"
	extension="${DOWN[$i]##*.}"
	if [[ "$extension" == "gz" ]]; then
		tar -zx -f "${DOWN[$i]##*/}" --strip-components=1
	else
		tar -jx -f "${DOWN[$i]##*/}" --strip-components=1
	fi
	eval "${CONF[$i]}"  #configure
	make 
	make install
	make install DESTDIR=${DEST}
	cd /tmp/opensource/"${FLDR[$i]}"
	rm -rf * .[a-zA-Z_-]*
	cd ..
	rmdir "${FLDR[$i]}"
done

cd ${DEST}/usr/bin
wget "http://www.cybercom.net/~dcoffin/dcraw/dcraw.c"
gcc -v -o dcraw -O4 dcraw.c -lm -ljasper -ljpeg -llcms2
rm dcraw.c

apk del --purge build-dependencies
apk del fdk-aac-dev libtheora-dev libvorbis-dev
FROM java:7-jre

## Roboconf snapshot dockerfile
MAINTAINER Thomas Sarboni <max-k@post.com>

EXPOSE 8181

## Define environment variables
ENV projectname=roboconf \
    projectfqdn=net.roboconf \
    pkgname=roboconf-dm \
    fullname=roboconf-karaf-dist-dm \
    policy=releases \
    version=0.6 \
    baseurl=https://oss.sonatype.org/service/local/artifact/maven/redirect

## Download Roboconf
RUN wget -N --progress=bar:force:noscroll -O /opt/${fullname}.tar.gz \
 "${baseurl}?g=${projectfqdn}&r=${policy}&a=${fullname}&v=${version}&p=tar.gz" && \
 wget -N --progress=bar:force:noscroll -O /opt/${fullname}.tar.gz.sha1 \
 "${baseurl}?g=${projectfqdn}&r=${policy}&a=${fullname}&v=${version}&p=tar.gz.sha1" && \
 [ `sha1sum /opt/${fullname}.tar.gz | cut -d" " -f1` = `cat /opt/${fullname}.tar.gz.sha1` ]

## Unpack sources
RUN cd /opt && \
 tar -zxf ${fullname}.tar.gz && \
 ln -s ${fullname}-${version} ${fullname} && \
 rm -f ${fullname}.tar.gz ${fullname}.tar.gz.sha1

## Export Java home
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" >> /opt/${fullname}/bin/setenv

WORKDIR /opt/${fullname}

## Install Roboconf DM
RUN ./bin/karaf server & \
 sleep 5 && \
 ./bin/client -u karaf "feature:install service-wrapper" && \
 sleep 1 && \
 ./bin/client -u karaf "wrapper:install -n roboconf-dm" && \
 kill `pidof java`

## Copy the script in the image and give it the right permissions
COPY start.sh /opt/${fullname}/${pkgname}-docker-wrapper.sh
RUN chmod 775 /opt/${fullname}/${pkgname}-docker-wrapper.sh

## Indicate the default script
CMD /opt/${fullname}/${pkgname}-docker-wrapper.sh

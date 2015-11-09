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
    version=0.5 \
    baseurl=https://oss.sonatype.org/service/local/artifact/maven/redirect

## Download Roboconf
RUN wget --progress=bar:force:noscroll -O /opt/${fullname}.tar.gz \
 "${baseurl}?g=${projectfqdn}&r=${policy}&a=${fullname}&v=${version}&p=tar.gz" && \
 wget --progress=bar:force:noscroll -O /opt/${fullname}.tar.gz.sha1 \
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

## Install RoboConf DM
RUN ./bin/karaf server & \
 sleep 5 && \
 ./bin/client -u karaf "feature:install service-wrapper" && \
 ./bin/client -u karaf "wrapper:install -n roboconf-dm" && \
 kill `pidof java`

## Configure consoel logging
RUN sed -i 's/TRACE,\ roboconf/TRACE, stdout/' etc/org.ops4j.pax.logging.cfg

## Configure RabbitMQ messaging server
RUN sed -i 's/localhost/rc_rabbitmq/' etc/${projectfqdn}.messaging.rabbitmq.cfg

CMD ./bin/${pkgname}-wrapper /opt/${fullname}/etc/${pkgname}-wrapper.conf \
 wrapper.syslog.ident=${pkgname} wrapper.pidfile=/opt/${fullname}/data/${pkgname}.pid



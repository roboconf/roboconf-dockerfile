FROM java:7-jre

## Roboconf snapshot dockerfile
MAINTAINER The Roboconf Team <https://github.com/roboconf>

EXPOSE 8181

# Build the DM or the agent image.
# Default value: DM.
ARG RBCF_KIND=dm

## Define environment variables
ENV pkgname=roboconf-${RBCF_KIND} \
    fullname=roboconf-karaf-dist-${RBCF_KIND} \
    policy=releases \
    version=0.6 \
    baseurl=https://oss.sonatype.org/service/local/artifact/maven/redirect

## Download Roboconf
RUN wget -N --progress=bar:force:noscroll -O /opt/${fullname}.tar.gz \
 "${baseurl}?g=net.roboconf&r=${policy}&a=${fullname}&v=${version}&p=tar.gz" && \
 wget -N --progress=bar:force:noscroll -O /opt/${fullname}.tar.gz.sha1 \
 "${baseurl}?g=net.roboconf&r=${policy}&a=${fullname}&v=${version}&p=tar.gz.sha1" && \
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
 ./bin/client -u karaf "wrapper:install -n ${pkgname}" && \
 kill `pidof java`

## Copy the script in the image and give it the right permissions
COPY start.sh /opt/${fullname}/${pkgname}-docker-wrapper.sh
RUN chmod 775 /opt/${fullname}/${pkgname}-docker-wrapper.sh

## Indicate the default script
CMD /opt/${fullname}/${pkgname}-docker-wrapper.sh

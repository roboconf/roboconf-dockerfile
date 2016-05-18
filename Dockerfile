FROM java:7-jre

# Roboconf dockerfile
MAINTAINER The Roboconf Team <https://github.com/roboconf>

EXPOSE 8181

# Build the DM or the agent image.
# Default value: DM.
ARG RBCF_KIND=dm

# Version arguments.
# The version can include a "-SNAPSHOT" suffix.
# In this case, the Maven policy should be "snapshots" instead of "releases".
#
# By default, we pick up the last released version.
ARG MAVEN_POLICY=releases
ARG RBCF_VERSION=LATEST

## Define environment variables
ENV pkgname=roboconf-${RBCF_KIND} \
    fullname=roboconf-karaf-dist-${RBCF_KIND} \
    baseurl=https://oss.sonatype.org/service/local/artifact/maven/redirect

## Download Roboconf
RUN wget --progress=bar:force:noscroll -O /opt/${fullname}.tar.gz \
 "${baseurl}?g=net.roboconf&r=${MAVEN_POLICY}&a=${fullname}&v=${RBCF_VERSION}&p=tar.gz" && \
 wget --progress=bar:force:noscroll -O /opt/${fullname}.tar.gz.sha1 \
 "${baseurl}?g=net.roboconf&r=${MAVEN_POLICY}&a=${fullname}&v=${RBCF_VERSION}&p=tar.gz.sha1" && \
 [ `sha1sum /opt/${fullname}.tar.gz | cut -d" " -f1` = `cat /opt/${fullname}.tar.gz.sha1` ]

## Unpack sources
RUN cd /opt && \
 tar -zxf ${fullname}.tar.gz && \
 ln -s ${fullname}-* ${fullname} && \
 rm -f ${fullname}.tar.gz ${fullname}.tar.gz.sha1

## Export Java home
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" >> /opt/${fullname}/bin/setenv

WORKDIR /opt/${fullname}

## Install Roboconf DM
RUN ./bin/karaf server & \
 sleep 7 && \
 ./bin/client -u karaf "feature:install service-wrapper" && \
 sleep 5 && \
 ./bin/client -u karaf "wrapper:install -n ${pkgname}" && \
 kill `pidof java`

## Copy the script in the image and give it the right permissions
COPY start.sh /opt/${fullname}/${pkgname}-docker-wrapper.sh
RUN chmod 775 /opt/${fullname}/${pkgname}-docker-wrapper.sh

## Indicate the default script
CMD /opt/${fullname}/${pkgname}-docker-wrapper.sh

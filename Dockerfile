# Steps are defined and ordered to reduce the number and the size of layers.
# You can verify the size of every layer by using "docker history <img>".
# We need a JDK. And we need a minimalist OS.
FROM openjdk:7-jre-alpine

# Roboconf dockerfile
LABEL maintainer="The Roboconf Team" \
      github="https://github.com/roboconf"

# Expose the default's Karaf port (HTTP)
EXPOSE 8181

# We also need Bash for Karaf
RUN apk add --update bash && \
	rm -rf /var/cache/apk/*

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

# By default, download artifacts from Sonatype.
ARG BASE_URL="https://oss.sonatype.org/service/local/artifact/maven/redirect"

# Define environment variables
ENV pkgname=roboconf-${RBCF_KIND} \
    fullname=roboconf-karaf-dist-${RBCF_KIND}

# Copy the start script in the image
COPY start.sh /opt/${pkgname}-docker-wrapper.sh

# We do as many things as possible within this command.
# The goal is to have a single layer with the smallest size.
#
# * Install temporarily wget and SSL stuff.
# * Download the Roboconf distribution and unpack it
# * Configure Karaf ($JAVA_HOME is correctly configured in the base image)
# * Allow the local client to connect to Karaf instances (keys.properties)
# Remove temporary packages
RUN apk add --no-cache --virtual .bootstrap-deps wget ca-certificates && \
	wget --progress=bar:force:noscroll -O /opt/${fullname}.tar.gz "${BASE_URL}?g=net.roboconf&r=${MAVEN_POLICY}&a=${fullname}&v=${RBCF_VERSION}&p=tar.gz" && \
	wget --progress=bar:force:noscroll -O /opt/${fullname}.tar.gz.sha1 "${BASE_URL}?g=net.roboconf&r=${MAVEN_POLICY}&a=${fullname}&v=${RBCF_VERSION}&p=tar.gz.sha1" && \
	[ `sha1sum /opt/${fullname}.tar.gz | cut -d" " -f1` = `cat /opt/${fullname}.tar.gz.sha1` ] && \
	cd /opt && \
	tar -zxf ${fullname}.tar.gz && \
	ln -s ${fullname}-* ${fullname} && \
	rm -f ${fullname}.tar.gz ${fullname}.tar.gz.sha1 && \
	mv /opt/${pkgname}-docker-wrapper.sh /opt/${fullname}/ && \
	chmod 775 /opt/${fullname}/${pkgname}-docker-wrapper.sh && \
	sed -i 's/#karaf/karaf/g' /opt/${fullname}/etc/keys.properties && \
	echo "${fullname} (${RBCF_VERSION}), policy is '${MAVEN_POLICY}', from ${BASE_URL}" > /opt/${fullname}/roboconf-docker-build.txt && \
	apk del .bootstrap-deps && \
	rm -rf /var/cache/apk/*

## Set the working directory
WORKDIR /opt/${fullname} 

## Indicate the default script
CMD /opt/${fullname}/${pkgname}-docker-wrapper.sh

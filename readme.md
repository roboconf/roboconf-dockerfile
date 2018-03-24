# Roboconf Dockerfile
[![Build Status](http://travis-ci.org/roboconf/roboconf-dockerfile.png?branch=master)](http://travis-ci.org/roboconf/roboconf-dockerfile/builds)
[![License](https://img.shields.io/hexpm/l/plug.svg)](http://www.apache.org/licenses/LICENSE-2.0)
[![Join us on Gitter.im](https://img.shields.io/badge/gitter-join%20chat-brightgreen.svg)](https://gitter.im/roboconf/roboconf)
[![Web site](https://img.shields.io/badge/website-roboconf.net-b23e4b.svg)](http://roboconf.net)


<img src="http://roboconf.net/resources/img/nn-0.7-docker-images-for-roboconf.jpg" alt="Roboconf Dockerfile" width="400" />


What is Roboconf?
=================

Roboconf is both a platform and framework to manage elastic applications in the cloud.  
Elastic applications designate those whose deployment topology may vary over time (e.g. scaling up or down).
Roboconf manages deployments, probes, automatic reactions and reconfigurations. Beyond applications, Roboconf could also be defined as a « PaaS framework »: a solution to build PaaS (Platform as a Service). Most PaaS, such as Cloud Foundry or Openshift, target developers and support application patterns. However, some applications require more flexible architectures or design. Roboconf addresses such cases.

With Roboconf, there is no constraint about the programming language, the kind of application or the operating system. You define what you put in your platform, you specify all the interactions, administration procedures and so on.

Roboconf handles application life cycle: hot reconfiguration (e.g. for elasticity issues) and consistency 
(e.g. maintaining a consistent state when a component starts or stops, even accidentally). This relies on a messaging queue 
(currently [Rabbit MQ](https://www.rabbitmq.com)). Application parts know what they expose to and what they depend on from other parts.
The global idea is to apply to applications the concepts used in component technologies like OSGi. Roboconf achieves this in a non-intrusive
way, so that it can work with legacy Software.

<img src="http://roboconf.net/resources/img/roboconf-workflow.png" alt="Roboconf's workflow" style="max-width: 400px;" />

Application parts use the message queue to communicate and take the appropriate actions depending on what is deployed or started.
These *appropriate* actions are executed by plug-ins (such as bash or [Puppet](http://puppetlabs.com)). 

<img src="http://roboconf.net/resources/img/roboconf-architecture-example.jpg" alt="Roboconf's architecture" style="max-width: 400px;" />

Roboconf is distributed technology, based on AMQP 
and REST / JSon. It is IaaS-agnostic, and supports many well-known IaaS (including OpenStack, Amazon Web Services, Microsoft Azure, VMWare, 
as well as a "local" deployment plug-in for on-premise hosts). Please, [refer to the FAQ](http://roboconf.net/en/user-guide/faq.html) for more details.


How to use this image for the DM?
=================================

Roboconf involves a messaging solution.  
For new beginners, the most simple solution is to rely on HTTP messaging (which is directly
embedded in Roboconf's DM). With this configuration, use the following command to launch Roboconf's DM.

```bash
docker run -d -p 8181:8181 roboconf/roboconf-dm:latest
```

For production environments though, Roboconf's DM may require a fully-working RabbitMQ server.  
To start Roboconf using the official RabbitMQ image, please run the following commands:

```bash
# Run RabbitMQ in its own container.
docker run -d -p 5672:5672 -p 4369:4369 --name rc_rabbitmq -d rabbitmq:latest

# Run Roboconf's DM and link it with RabbitMQ.
docker run -d -p 8181:8181 --link rc_rabbitmq:rabbitmq roboconf/roboconf-dm:latest
```

You can then go to [http://localhost:8181/roboconf-web-administration](http://localhost:8181/roboconf-web-administration) or
[http://host-ip:8181/roboconf-web-administration](http://host-ip:8181/roboconf-web-administration) in a browser.

It is possible to modify the Roboconf configuration by setting environment variables.  
Here are the default values:

| Variable | Value | Description |
| -------- | :---: | ----------- |
| MESSAGING_TYPE | http | The messaging implementation to use (**http** or **rabbitmq**). |
| REDIRECT_LOGS | - | If defined, this variable redirects logs to the standard output. |

<!-- -->

If *MESSAGING_TYPE* is set to `http`.

| Variable | Value | Description |
| -------- | :---: | ----------- |
| HTTP_IP | localhost | The IP address of Roboconf's DM. This IP will be used by agents. |
| HTTP_PORT | 8181 | The port used by the DM to expose its web socket for agents. |

<!-- -->

If *MESSAGING_TYPE* is set to `rabbitmq`.

| Variable | Value | Description |
| -------- | :---: | ----------- |
| RABBITMQ_PORT_5672_TCP_ADDR | rc_rabbitmq | RabbitMQ's IP address (link to another Docker container by default). |
| RABBITMQ_PORT_5672_TCP_PORT | 5672 | RabbitMQ's port. |
| RABBITMQ_USER | guest | User name to connect to RabbitMQ. |
| RABBITMQ_PASS | guest | Password name to connect to RabbitMQ. |


To run it as a stand-alone using your own RabbitMQ server, you can use `-e` option to match your settings.  
For example, to connect to RabbitMQ server listening on IP 192.168.0.55 and port 5672 using *roboconf* as user and password:

```bash
# You can pass as many environment variables as necessary.
$ docker run -d -p 8181:8181 \
         -e MESSAGING_TYPE=rabbitmq \
         -e RABBITMQ_PORT_5672_TCP_ADDR=192.168.0.55 \
         -e RABBITMQ_USER=roboconf \
         -e RABBITMQ_PASS=roboconf \
         roboconf/roboconf-dm:latest
```

Once your container is started, you may have to login to deploy additional artifacts (e.g. target handlers in the DM).

```bash
$ docker exec -it <container_id> /bin/bash

# You can now interact with the container.

$ cd bin
$ ./client -u karaf

# You are now logged into Karaf.
# Do what you have to do and log out.

$ karaf > roboconf:target openstack
$ karaf > logout

# Then, exit the container.

$ exit
```


How to use this image for the agent?
====================================

Roboconf agents can also be launched from a Docker image.  
To launch such an image, use...

```bash
docker run -d roboconf/roboconf-agent:latest
```

Environment variables are the same than for the DM, with the following ones in addition.

| Variable | Value | Description |
| -------- | :---: | ----------- |
| AGENT_PARAMETERS | - | The agent parameters. Used to determine whether and where dynamic parameters are available. |
| AGENT_APPLICATION_NAME | - | The application's name. |
| AGENT_SCOPED_INSTANCE_PATH | - | The path of the instance associated with this agent. |
| AGENT_IP_ADDRESS_OF_THE_AGENT | - | To force the IP address of an agent (if not set, will be deduced). |

> Using **AGENT_PARAMETERS** implies all the configuration is passed dynamically
> by the DM. When used, you do not have to pass other environment variables.
> Parameters will be retrieved dynamically (including the messaging stuff).

Here are examples showing how to use this image.  

```bash
# Force the agent parameters
$ docker run -d -p 8181:8181 \
         -e AGENT_APPLICATION_NAME="my application name" \
         -e AGENT_SCOPED_INSTANCE_PATH="/vm1/app1" \
         -e AGENT_IP_ADDRESS_OF_THE_AGENT="192.168.1.19" \
         roboconf/roboconf-agent:latest

# Dynamic parameters passed through user data
$ docker run -d -p 8181:8181 \
         -e AGENT_PARAMETERS="@iaas-ec2" \
         roboconf/roboconf-agent:latest

# Dynamic parameters passed through a file
# (used as an example by the DM when it launches agents in Docker containers).
$ docker run -d -p 8181:8181 \
         -v /tmp/rbf:/tmp/dynamic-parameters \
         -e AGENT_PARAMETERS="/tmp/dynamic-parameters/user-data.txt" \
         roboconf/roboconf-agent:latest
```


How to build this image
=======================

This Dockerfile allows to build an image for Roboconf's DM and one for Roboconf agents.  
The Docker build has 3 arguments.

| Argument | Optional | Default | Description |
| -------- | :------: | :-----: | ----------- |
| RBCF_KIND | no | - | Must be either `dm` or `agent`. It is used to determine which image to build. |
| RBCF_VERSION | yes | LATEST | The version of Roboconf to use. It can include a "-SNAPSHOT" suffix. In this case, the Maven policy should be "snapshots" instead of "releases". **LATEST** is a special keyword for Nexus' API, which is used at build time to resolve the artifact to download. |
| MAVEN_POLICY | yes | releases | The Maven policy: should we search in the `snapshots` or in the `releases` repository? |
| BASE_URL | yes | https://oss.sonatype.org/service/local/artifact/maven/redirect | The REST API used to resolve the Maven artifacts (the Debian packages are stored as Maven artifacts). One could reference another Nexus instance or [a mock of it](https://github.com/roboconf/dockerized-mock-for-nexus-api). |

Releases should use 2 tags: `latest` and `<version>`.  
Example, to build the image for the DM (version 0.6)...

```
docker build \
		--build-arg RBCF_KIND=dm \
		--build-arg RBCF_VERSION=0.6 \ 
		-t roboconf/roboconf-dm:latest \
		-t roboconf/roboconf-dm:0.6 \
		.
```

And to build the image for the agent (version 0.6)...

```
docker build \
		--build-arg RBCF_KIND=agent \
		--build-arg RBCF_VERSION=0.6 \
		-t roboconf/roboconf-agent:latest \
		-t roboconf/roboconf-agent:0.6 \
		.
```

To release a snapshot version...

```
docker build \
		--build-arg RBCF_KIND=agent \
		--build-arg RBCF_VERSION=0.6-SNAPSHOT \
		--build-arg MAVEN_POLICY=snapshots \
		-t roboconf/roboconf-agent:latest \
		-t roboconf/roboconf-agent:0.6 \
		.
```

> By setting 2 tags, the latest tag will be updated on every release.    
> And older tags/versions will remain.

It is also possible to build images for the latest versions.  
But it is only recommended for development. Not to be pushed to Docker hub.

To build the last released version of Roboconf (if the version is not specified, only use one tag)...

```
docker build \
		--build-arg RBCF_KIND=agent \
		-t roboconf/roboconf-agent:latest \
		.
```

To build the last snapshot version of Roboconf (if the version is not specified, only use one tag)...

```
docker build \
		--build-arg RBCF_KIND=agent \
		--build-arg MAVEN_POLICY=snapshots \
		-t roboconf/roboconf-agent:latest \
		.
```

You can also build from your local Maven repository.  
You need to build [this Docker image](https://github.com/roboconf/dockerized-mock-for-nexus-api)
and run it as described in its [readme](https://github.com/roboconf/dockerized-mock-for-nexus-api/blob/master/readme.md).
Notice that **this mode does not support the LATEST version**. Then, run...

```properties
# 172.17.0.1: IP address of the host system for the docker0 network
docker build \
		--build-arg RBCF_KIND=agent \
		--build-arg RBCF_VERSION=0.9-SNAPSHOT \
		--build-arg BASE_URL="http://172.17.0.1:9090/redirect" \
		-t roboconf/roboconf-agent:latest-local \
		.
```

Please, refer to the [official Docker documentation](https://docs.docker.com/engine/reference/commandline/build/) for alternatives.

> Once images are built for both the DM and the agent, you can run tests with the **verify.sh** script.


License
=======

This Docker image and Roboconf are licensed under the terms of the [Apache license v2](https://www.apache.org/licenses/LICENSE-2.0).


Supported Docker versions
=========================

This image is officially supported on Docker version 1.9.0.  
Support for older versions (down to 1.6) is provided on a best-effort basis.  
Please see [the Docker installation documentation](https://docs.docker.com/installation/) for details on how to upgrade your Docker daemon.


User Feedback
=============

Documentation
-------------

Official Roboconf documentation is available on [Roboconf's web site](http://roboconf.net).


Issues
------

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/roboconf/roboconf-dockerfile/issues).


Contributing
------------

To contribute to this image, you can submit a pull-request to [Github repository](https://github.com/roboconf/roboconf-dockerfile).  
To contribute to Roboconf, please follow the contributing guidelines on [Roboconf's web site](http://roboconf.net).


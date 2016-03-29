Supported tags and respective `Dockerfile` links
================================================

- [`5.0`, `5` (*5.0/Dockerfile*)](https://github.com/roboconf/blob/<BLOB_ID>/Dockerfile)


What is Roboconf?
=================

Roboconf is a platform to manage elastic deployments in the cloud.
It manages deployments, probes, automatic reactions and reconfigurations. It can be defined as « PaaS framework »: a solution to build PaaS (Platform as a Service). Most PaaS, such as Cloud Foundry or Openshift, target developers and support application patterns. However, some applications require more flexible architectures or design. Roboconf addresses such cases.

With Roboconf, you can create PaaS for any programming language, any kind of application and any operating system. You define what you put in your platform, you specify all the interactions, administration procedures and so on.

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


How to use this image
=====================

Roboconf involves a messaging solution.  
For new beginners, the most simple solution is to rely on HTTP messaging (which is directly
embedded in Roboconf's DM). With this configuration, use the following command to launch Roboconf's DM.

```bash
$ docker run -it --rm -p 8181:8181 roboconf/roboconf-dm:latest
```

For production environments though, Roboconf's DM may require a fully-working RabbitMQ server.  
To start Roboconf using the official RabbitMQ image, please run the following commands:

```bash
# Run RabbitMQ in its own container.
$ docker run -it --rm -p 5672:5672 -p 4369:4369 --name rc_rabbitmq -d rabbitmq:latest

# Run Roboconf's DM and link it with RabbitMQ.
$ docker run -it --rm -p 8181:8181 --link rc_rabbitmq:rabbitmq roboconf/roboconf-dm:latest
```

You can then go to [http://localhost:8181/roboconf-web-administration](http://localhost:8181/roboconf-web-administration) or
[http://host-ip:8181/roboconf-web-administration](http://host-ip:8181/roboconf-web-administration) in a browser.

It is possible to modify the Roboconf configuration by setting environment variables.  
Here are the default values:

| Variable | Value | Description |
| :------: | :---: | ----------- |
| MESSAGING_TYPE | http | The messaging implementation to use (**http** or **rabbitmq**). |
| REDIRECT_LOGS | - | If defined, this variable redirects logs to the standard output. |

<!-- -->

If *MESSAGING_TYPE* is set to `http`.

| Variable | Value | Description |
| :------: | :---: | ----------- |
| HTTP_IP | localhost | The IP address of Roboconf's DM. This IP will be used by agents. |
| HTTP_PORT | 8181 | The port used by the DM to expose its web socket for agents. |

<!-- -->

If *MESSAGING_TYPE* is set to `rabbitmq`.

| Variable | Value | Description |
| :------: | :---: | ----------- |
| RABBITMQ_PORT_5672_TCP_ADDR | rc_rabbitmq | RabbitMQ's IP address (link to another Docker container by default). |
| RABBITMQ_PORT_5672_TCP_PORT | 5672 | RabbitMQ's port. |
| RABBITMQ_USER | guest | User name to connect to RabbitMQ. |
| RABBITMQ_PASS | guest | Password name to connect to RabbitMQ. |

To run it as a stand-alone using your own RabbitMQ server, you can use `-e` option to match your settings.  
For example, to connect to RabbitMQ server listening on IP 192.168.0.55 and port 5672 using *roboconf* as user and password:

```bash
# You can pass as many environment variables as necessary.
$ docker run -it --rm -p 8181:8181 \
         -e MESSAGING_TYPE=rabbitmq \
         -e RABBITMQ_PORT_5672_TCP_ADDR=192.168.0.55 \
         -e RABBITMQ_USER=roboconf \
         -e RABBITMQ_PASS=roboconf \
         roboconf/roboconf-dm:latest
```

Once your container is started, you may have to login to deploy target handlers in the DM.

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


How to build this image
=======================

Check this Git repository, open a shell terminal into it and type in `docker build -t roboconf/roboconf-dm:snapshot .`  
Or refer to the [official Docker documentation](https://docs.docker.com/engine/reference/commandline/build/) for alternatives.

Releases should use 2 tags.  
Example with Roboconf 0.6. This way, the latest tag will be updated on every release.  
And older versions will remained tagged.

```
docker build -t roboconf/roboconf-dm:latest -t roboconf/roboconf-dm:0.6 .
```


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

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/roboconf/roboconf-dockerfile-dm/issues).


Contributing
------------

To contribute to this image, you can submit a pull-request to [Github repository](https://github.com/roboconf/roboconf-dockerfile-dm).  
To contribute to Roboconf, please follow the contributing guidelines on [Roboconf's web site](http://roboconf.net/en/sources.html).


Supported tags and respective `Dockerfile` links
================================================

- [`5.0`, `5` (*5.0/Dockerfile*)](https://github.com/roboconf/blob/<BLOB_ID>/Dockerfile)

What is Roboconf?
=================

Roboconf is a distributed solution to deploy distributed applications.  
It is a deployment tool for the cloud, but not only. It allows to describe distributed applications
and handles deployment automatically of the entire application, or of a part of it. Consequently, Roboconf supports scale-up
and scale-down natively. Its main force is the support of dynamic (re)configuration. This provides a lot of flexibility and 
allows elastic deployments.

Roboconf takes as input the description of a whole application in terms of *components* and *instances*.  
From this model, it then takes the burden of launching Virtual Machines (VMs), deploying software on them, resolving dependencies 
between software components, updating their configuration and starting the whole stuff when ready.

Roboconf handles application life cycle: hot reconfiguration (e.g. for elasticity issues) and consistency 
(e.g. maintaining a consistent state when a component starts or stops, even accidentally). This relies on a messaging queue 
(currently [Rabbit MQ](https://www.rabbitmq.com)). Application parts know what they expose to and what they depend on from other parts.
The global idea is to apply to applications the concepts used in component technologies like OSGi. Roboconf achieves this in a non-intrusive
way, so that it can work with legacy Software.

Application parts use the message queue to communicate and take the appropriate actions depending on what is deployed or started.
These *appropriate* actions are executed by plug-ins (such as bash or [Puppet](http://puppetlabs.com)). 

Roboconf is distributed technology, based on AMQP 
and REST / JSon. It is IaaS-agnostic, and supports many well-known IaaS (including OpenStack, Amazon Web Services, Microsoft Azure, VMWare, 
as well as a "local" deployment plug-in for on-premise hosts).

History
-------

Roboconf was created to be the foundations of [Open PaaS](http://open-paas.org/).  
Open PaaS is an Enterprise Social Network, i.e. a platform dedicated to collaborations
within organizations (messaging, groups and projects management, video conference...). The project 
is led by [Linagora](http://linagora.com), which also works on Roboconf in collaboration with the *[Laboratoire Informatique de Grenoble](https://www.liglab.fr/)*.
This entity is part of the Research department in Computer Science and Software Engineering of [Université Joseph Fourier](https://www.ujf-grenoble.fr/),
in Grenoble, France.
  
<strong>Technical requirements</strong> for Open PaaS' foundations were clear.
	
* Support cloud deployments (public, private and hybrid clouds)
* Ensure developers could choose any solution they would (databases, servers, development languages...)
* Provide elasticity mechanisms (automatic load-adaptation...)
* Be fully open-source (as all the solutions used and developed by Linagora).

The real business value for the company was clearly about the applications to run in the cloud.  
At the time (end of 2012), some cloud solutions were emerging, but none of them matched all the criteria above.
Contacts between [Linagora](http://linagora.com) and [Université Joseph Fourier](https://www.ujf-grenoble.fr/) led to
a partnership to prototype such a solution with a focus on industrial applications. Roboconf was born...

Use Cases
---------

General use cases are listed [here](/slides/general/roboconf-use-cases.html).  
The following list includes cases we illustrated through samples, demos or for real requirements.

* **Legacy LAMP**: a classic web application based on an Apache load balancer, a web application deployed on Tomcat and MySQL as the database.  
The interest is to see how it is easy to add and remove new Tomcat servers. Tomcat instances are configured right after deployment. The connection
to MySQL is established at runtime and the load balancing configuration is updated on the fly.

* **M2M / IoT**: deploy and interconnect Software elements on embedded devices and in the cloud.  
The use case that was studied is about home sensors that send big data to analysis tools (such as [Hadoop](http://hadoop.apache.org/) or 
[Storm](http://storm.incubator.apache.org/) for real-time computation) deployed on the cloud. New devices can appear
or disappear and everything gets reconfigured in consequence. As a reminder, M2M means *machine to machine* and IoT *Internet of Things*.

* **Open PaaS**: an open-source Social Networking Service deployed in the cloud.  
[Open PaaS](http://open-paas.org) is a project which aims at developing a web collaboration suite for companies and organizations. 
It uses [NodeJS](http://nodejs.org/), [NPM](http://www.npmjs.org/) and various other Software ([Redis](http://redis.io/), [MongoDB](http://www.mongodb.org/), LDAP, etc).


How to use this image
=====================

Roboconf-DM requires a fully-working RabbitMQ server.

To start Roboconf using the official RabbitMQ image, please run the following commands :

```console
$ docker run -it --rm -p 5672:5672 -p 4369:4369 --name rc_rabbitmq -d rabbitmq:latest
$ docker run -it --rm -p 8181:8181 --link rc_rabbitmq:rabbitmq roboconf:latest
```

You can then go to `http://localhost:8181/roboconf-web-administration` or `http://host-ip:8181/roboconf-web-administration` in a browser.

The default Roboconf environment in the image :

	RABBITMQ_PORT_5672_TCP_ADDR:    rc_rabbitmq
	RABBITMQ_PORT_5672_TCP_PORT:    5672
	RABBITMQ_USER:			guest
	RABBITMQ_PASS:        		guest

To run it as a standalone using your own RabbitMQ server, you can use `-e` option to match your settings.

For example, to connect to RabbitMQ server listening on ip 192.168.0.55 and port 5672 using robonconf as user and password :

```console
$ docker run -it --rm -p 8181:8181 -e RABBITMQ_PORT_5672_TCP_ADDR=192.168.0.55 -e RABBITMQ_USER=roboconf -e RABBITMQ_PASS=roboconf roboconf:latest
```

License
=======

View [license information](https://www.apache.org/licenses/LICENSE-2.0) for the software contained in this image.

Supported Docker versions
=========================

This image is officially supported on Docker version 1.9.0.

Support for older versions (down to 1.6) is provided on a best-effort basis.

Please see [the Docker installation documentation](https://docs.docker.com/installation/) for details on how to upgrade your Docker daemon.

User Feedback
=============

Documentation
-------------

Offical Roboconf documentation is available here : [Roboconf website](http://roboconf.net/en/index.html).

Issues
------

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/roboconf/roboconf-dockerfile-dm/issues).

Contributing
------------

To contribute to this image, you can submit a pull-request to [Github repository](https://github.com/roboconf/roboconf-dockerfile-dm).

To contribute to Roboconf, please follow the contributing guidelines on [Roboconf website](http://roboconf.net/en/sources.html).


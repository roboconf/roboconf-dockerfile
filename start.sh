#!/bin/bash

#
# RabbitMQ configuration
#

rmq_ip="rc_rabbitmq"
rmq_port="5672"
rmq_user="guest"
rmq_pass="guest"

[ ! -z "$RABBITMQ_PORT_5672_TCP_ADDR" ] && rmq_ip="$RABBITMQ_PORT_5672_TCP_ADDR"
[ ! -z "$RABBITMQ_PORT_5672_TCP_PORT" ] && rmq_port="$RABBITMQ_PORT_5672_TCP_PORT"
[ ! -z "$RABBITMQ_USER" ] && rmq_user="$RABBITMQ_USER"
[ ! -z "$RABBITMQ_PASS" ] && rmq_pass="$RABBITMQ_PASS"

file=etc/net.roboconf.messaging.rabbitmq.cfg
sed -i "s/net.roboconf.messaging.rabbitmq.server.ip\s*=.*/net.roboconf.messaging.rabbitmq.server.ip = ${rmq_ip}:${rmq_port}/g" $file
sed -i "s/net.roboconf.messaging.rabbitmq.server.username\s*=.*/net.roboconf.messaging.rabbitmq.server.username = ${rmq_user}/g" $file
sed -i "s/net.roboconf.messaging.rabbitmq.server.password\s*=.*/net.roboconf.messaging.rabbitmq.server.password = ${rmq_pass}/g" $file


#
# HTTP configuration
#

http_ip="localhost"
http_port="8181"

[ ! -z "$HTTP_IP" ] && http_ip="$HTTP_IP"
[ ! -z "$HTTP_PORT" ] && http_port="$HTTP_PORT"

file=etc/net.roboconf.messaging.http.cfg
sed -i "s/net.roboconf.messaging.http.server.ip\s*=.*/net.roboconf.messaging.http.server.ip = ${http_ip}/g" $file
sed -i "s/net.roboconf.messaging.http.server.port\s*=.*/net.roboconf.messaging.http.server.port = ${http_port}/g" $file


#
# Messaging configuration
#

messaging_type="http"
[ ! -z "$MESSAGING_TYPE" ] && messaging_type="$MESSAGING_TYPE"

file=etc/net.roboconf.dm.configuration.cfg
if [ -f $file ]; then
	sed -i "s/messaging-type\s*=.*/messaging-type = ${messaging_type}/g" $file
fi

file=etc/net.roboconf.agent.configuration.cfg
if [ -f $file ]; then
	sed -i "s/messaging-type\s*=.*/messaging-type = ${messaging_type}/g" $file
fi


#
# Logging configuration
#

if [ ! -z $REDIRECT_LOGS ]; then
	sed -i "s/TRACE,\s*roboconf/TRACE, stdout/g" etc/org.ops4j.pax.logging.cfg
fi


#
# Agent configuration
#

file=etc/net.roboconf.agent.configuration.cfg
if [ -f $file ]; then

	agent_parameters=""
	agent_application_name=""
	agent_scoped_instance_path=""
	agent_ip_address_of_the_agent=""

	[ ! -z "$AGENT_PARAMETERS" ] && agent_parameters="$AGENT_PARAMETERS"
	[ ! -z "$AGENT_APPLICATION_NAME" ] && agent_application_name="$AGENT_APPLICATION_NAME"
	[ ! -z "$AGENT_SCOPED_INSTANCE_PATH" ] && agent_scoped_instance_path="$AGENT_SCOPED_INSTANCE_PATH"
	[ ! -z "$AGENT_IP_ADDRESS_OF_THE_AGENT" ] && agent_ip_address_of_the_agent="$AGENT_IP_ADDRESS_OF_THE_AGENT"

	sed -i "s/parameters\s*=.*/parameters = ${agent_parameters}/g" $file
	sed -i "s/application-name\s*=.*/application-name = ${agent_application_name}/g" $file
	sed -i "s/ip-address-of-the-agent\s*=.*/ip-address-of-the-agent = ${agent_ip_address_of_the_agent}/g" $file

	# "agent_scoped_instance_path" generally contains slashes. So, we use ~ as the SED separator.
	sed -i "s~scoped-instance-path\s*=.*~scoped-instance-path = ${agent_scoped_instance_path}~g" $file
fi


#
# Launch...
#

./bin/karaf server

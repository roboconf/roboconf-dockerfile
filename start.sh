# /bin/bash

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
sed -i "s/messaging-type\s*=.*/messaging-type = ${messaging_type}/g" $file


#
# Logging configuration
#
if [ ! -z $REDIRECT_LOGS ]; then
	sed -i 's/TRACE,\ roboconf/TRACE, stdout/' etc/org.ops4j.pax.logging.cfg
fi


#
# Launch...
#

./bin/${pkgname}-wrapper \
    /opt/${fullname}/etc/${pkgname}-wrapper.conf \
    wrapper.syslog.ident=${pkgname} \
    wrapper.pidfile=/opt/${fullname}/data/${pkgname}.pid

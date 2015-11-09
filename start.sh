# /bin/bash

ip="rc_rabbitmq"
port="5672"
user="guest"
pass="guest"

file=etc/net.roboconf.messaging.rabbitmq.cfg

[ ! -z "$RABBITMQ_PORT_5672_TCP_ADDR" ] && ip="$RABBITMQ_PORT_5672_TCP_ADDR"
[ ! -z "$RABBITMQ_PORT_5672_TCP_PORT" ] && port="$RABBITMQ_PORT_5672_TCP_PORT"
[ ! -z "$RABBITMQ_USER" ] && user="$RABBITMQ_USER"
[ ! -z "$RABBITMQ_PASS" ] && pass="$RABBITMQ_PASS"

echo "net.roboconf.messaging.rabbitmq.server.ip = ${ip}:${port}" > $file
echo "net.roboconf.messaging.rabbitmq.server.username = ${user}" >> $file
echo "net.roboconf.messaging.rabbitmq.server.password = ${pass}" >> $file

./bin/${pkgname}-wrapper \
    /opt/${fullname}/etc/${pkgname}-wrapper.conf \
    wrapper.syslog.ident=${pkgname} \
    wrapper.pidfile=/opt/${fullname}/data/${pkgname}.pid

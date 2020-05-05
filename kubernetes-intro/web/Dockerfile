FROM nginx:1.18-alpine

RUN deluser nginx \
 && addgroup -g 1001 -S nginx \
 && adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
 && chown nginx:nginx /var/cache/nginx \
 && chown nginx /var/run \
 && sed -e 's/^user /#&/' -i /etc/nginx/nginx.conf

COPY default.conf /etc/nginx/conf.d/

EXPOSE 8000

USER 1001

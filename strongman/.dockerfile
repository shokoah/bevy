FROM alpine:3.19

RUN apk update && apk add --no-cache \
    nginx \
    php82 \
    php82-fpm \
    php82-json \
    php82-session \
    php82-openssl \
    php82-curl \
    php82-mbstring \
    git \
    bash

# Install StrongMan
RUN git clone https://github.com/strongman/strongman.git /var/www/strongman

# Nginx config
COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /run/nginx /var/log/php82

EXPOSE 80

CMD php-fpm82 && nginx -g "daemon off;"

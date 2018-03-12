FROM ubuntu:xenial

RUN apt-get update && apt-get install -y wget && wget https://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/xUbuntu_16.04/Release.key && apt-key add Release.key && rm Release.key

RUN sh -c "echo 'deb http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/nginx.list"

RUN apt-get install -y patch nginx-custom nginx-ee && rm /etc/nginx/sites-enabled/default

COPY nginx-build.sh ./
RUN ./nginx-build.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY wordpress.conf /etc/nginx/global/wordpress.conf
COPY restrictions.conf /etc/nginx/global/restrictions.conf
COPY proxy.conf /etc/nginx/global/proxy.conf
COPY docker-entrypoint.sh /entrypoint.sh

COPY entrypoint.patch ./
RUN patch /entrypoint.sh entrypoint.patch && rm entrypoint.patch

RUN mkdir -p /var/lib/nginx/body

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

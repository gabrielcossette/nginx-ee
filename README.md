# Environment Variables

* `POST_MAX_SIZE`: Sets max size of post data allowed. Also affects file uploads (defaults to `64m`).
* `BEHIND_PROXY`: Set to `true` if this container is behind a reverse proxy (defaults to `false` unless `VIRTUAL_HOST` environment variable is set).
* `REAL_IP_HEADER`: Defines the request header that will be used to obtain the real client IP when `BEHIND_PROXY` is set to `true` (defaults to `X-Forwarded-For`).
* `REAL_IP_FROM`: Defines trusted addresses to obtain the real client IP when `BEHIND_PROXY` is set to `true` (defaults to `172.16.0.0/12`).
* `WP_CONTAINER_NAME`: Defines your Wordpress (PHP-FPM) container's name aka fastcgi_pass (defaults to `wordpress`).

# Nginx-EE 

Compile and install the latest nginx release with EasyEngine

![nginx-ee](https://raw.githubusercontent.com/VirtuBox/nginx-ee/master/nginx-ee.png)

-----
## Features
* Update Nginx to the Latest mainline release 
* Additonal modules
* TLS v1.3 Support

-----

## Additional modules 

Nginx current release : **v1.13.9**

* ngx_cache_purge
* memcached_nginx_module
* headers-more-nginx-module
* ngx_coolkit
* ngx_brotli
* redis2-nginx-module
* srcache-nginx-module
* ngx_http_substitutions_filter_module
* nginx-dynamic-tls-records-patch_1.13.0+
* Openssl 1.1.0
* ngx_http_auth_pam_module
* ngx_pagespeed (optional)
* naxsi WAF (optional)
-----

##  Nginx configuration 

* [Wiki](https://github.com/VirtuBox/nginx-ee/wiki/)

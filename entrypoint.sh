#!/bin/bash
set -e

common_post_max_size() {
	if [[ ! "${POST_MAX_SIZE}" =~ ^([0-9]+)([kKmMgG]?)$ ]]; then
		echo >&2 'error: invalid value "'"${POST_MAX_SIZE}"'" for POST_MAX_SIZE environment variable'
		exit 1
	fi

	local VALUE="${BASH_REMATCH[1]}"
	local UNIT="${BASH_REMATCH[2]}"

	# Nginx does not support Gigabyte unit, convert it to Megabytes
	if [ "${UNIT}" == "g" ] || [ "${UNIT}" == "G" ]; then
		VALUE="$(($VALUE * 1024))"
		UNIT="m"
	fi
	POST_MAX_SIZE="${VALUE}${UNIT}"
}

escape_sed() {
    echo "$1" | sed -e 's/[\/&]/\\&/g'
}

if [ "$1" == nginx ]; then
    : "${POST_MAX_SIZE:=64m}"
    : "${BEHIND_PROXY:=$([ -z ${VIRTUAL_HOST} ] && echo "false" || echo "true")}"
    : "${REAL_IP_HEADER:=X-Forwarded-For}"
    : "${REAL_IP_FROM:=172.17.0.0/16}"
    : "${WP_CONTAINER_NAME:=wordpress}"
    : "${CACHE:=none}"

    common_post_max_size

    sed -i 's/client_max_body_size *[0-9]\+[kKmM]\?/client_max_body_size '"${POST_MAX_SIZE}"'/' /etc/nginx/conf.d/default.conf

    sed -i 's/upload_max_filesize *= *[0-9]\+[kKmMgG]\?/upload_max_filesize='"${POST_MAX_SIZE}"'/' /etc/nginx/common/wordpress.conf
    sed -i 's/post_max_size *= *[0-9]\+[kKmMgG]\?/post_max_size='"${POST_MAX_SIZE}"'/' /etc/nginx/common/wordpress.conf
    sed -i 's/upload_max_filesize *= *[0-9]\+[kKmMgG]\?/upload_max_filesize='"${POST_MAX_SIZE}"'/' /etc/nginx/common/wpfc.conf
    sed -i 's/post_max_size *= *[0-9]\+[kKmMgG]\?/post_max_size='"${POST_MAX_SIZE}"'/' /etc/nginx/common/wpfc.conf
    sed -i 's/upload_max_filesize *= *[0-9]\+[kKmMgG]\?/upload_max_filesize='"${POST_MAX_SIZE}"'/' /etc/nginx/common/redis.conf
    sed -i 's/post_max_size *= *[0-9]\+[kKmMgG]\?/post_max_size='"${POST_MAX_SIZE}"'/' /etc/nginx/common/redis.conf
    
    sed -i 's/server changeme/server '"$(escape_sed "${WP_CONTAINER_NAME}")"'/' /etc/nginx/conf.d/upstream.conf

    if [ "${BEHIND_PROXY}" == "true" ]; then
        sed -i 's/real_ip_header .*;/real_ip_header '"$(escape_sed "${REAL_IP_HEADER}")"';/' /etc/nginx/common/proxy.conf
        sed -i 's/set_real_ip_from .*;/set_real_ip_from '"$(escape_sed "${REAL_IP_FROM}")"';/' /etc/nginx/common/proxy.conf
        grep -qF 'include common/proxy.conf;' /etc/nginx/conf.d/default.conf || \
        sed -i '/^}/i\    include common/proxy.conf;' /etc/nginx/conf.d/default.conf
    else
        sed -i '/include commom\/proxy.conf;/d' /etc/nginx/conf.d/default.conf
    fi

    if [ "${CACHE}" == "fastcgi" ]; then
        grep -qF 'include common/wpfc.conf;' /etc/nginx/conf.d/default.conf || \
        sed -i '/^}/i\    include common/wpfc.conf;' /etc/nginx/conf.d/default.conf
    else
        sed -i '/include commom\/wpfc.conf;/d' /etc/nginx/conf.d/default.conf
    fi

    if [ "${CACHE}" == "redis" ]; then
        grep -qF 'include common/redis.conf;' /etc/nginx/conf.d/default.conf || \
        sed -i '/^}/i\    include common/redis.conf;' /etc/nginx/conf.d/default.conf
    else
        sed -i '/include commom\/redis.conf;/d' /etc/nginx/conf.d/default.conf
    fi

    if [ "${CACHE}" == "none" ]; then
        grep -qF 'include common/wordpress.conf;' /etc/nginx/conf.d/default.conf || \
        sed -i '/^}/i\    include common/wordpress.conf;' /etc/nginx/conf.d/default.conf
    else
        sed -i '/include commom\/wordpress.conf;/d' /etc/nginx/conf.d/default.conf
    fi

    sed -i "s/server_name _/server_name $SITE www\.$SITE/" /etc/nginx/conf.d/default.conf
fi

exec "$@"

#!/usr/bin/env bash

## Set strict mode
## http://redsymbol.net/articles/unofficial-bash-strict-mode/
#set -euo pipefail


logPrefix="docker-init --"

pathAppRoot=/home/appuser/app


## php




compileOpcache ()
{
    # Move to app root.
    cd $pathAppRoot

    # Execute.
    # Execution is wrapped in a variable
    # to avod an exit code stopage in cases
    # when the command returns a error output.
    run=$(exec php artisan opcache:compile)

    # Print output.
    # TODO move to log
    echo "$run" >&1
}

calculatePmMaxChildren ()
{
    #
    usageEstimate=50000


    # Available memory in kb
    mem=$(cat /proc/meminfo | grep "MemAvailable:" | awk -F ' ' '{print $2}')

    #
    usableMem=$((($mem/100)*70))

    maxChildren=$(($usableMem/$usageEstimate))

    if [ "$maxChildren" -lt 1 ]; then
        maxChildren=1
    fi

    echo $maxChildren
}

getProcessingUnitCount ()
{
    nproc
}









echo 'Container deploy start' >&1

# touch /home/appuser/app/storage/logs/temp.log
# echo 'start' >> /home/appuser/app/storage/logs/temp.log




# UPDATE THE WEBROOT IF REQUIRED.
# if [[ ! -z "${WEBROOT}" ]] && [[ ! -z "${WEBROOT_PUBLIC}" ]]; then
#     sed -i "s#root /var/www/public;#root ${WEBROOT_PUBLIC};#g" /etc/nginx/sites-available/default.conf
# else
#     export WEBROOT=/home/appuser/app
#     export WEBROOT_PUBLIC=/home/appuser/app/public
# fi

# echo '01' >> /home/appuser/app/storage/logs/temp.log

# UPDATE COMPOSER PACKAGES ON BUILD.
## 💡 THIS MAY MAKE THE BUILD SLOWER BECAUSE IT HAS TO FETCH PACKAGES.
# if [[ ! -z "${COMPOSER_DIRECTORY}" ]] && [[ "${COMPOSER_UPDATE_ON_BUILD}" == "1" ]]; then
#     cd ${COMPOSER_DIRECTORY}
#     composer update && composer dump-autoload -o
# fi

# echo '02' >> /home/appuser/app/storage/logs/temp.log

# LARAVEL APPLICATION
# if [[ "${LARAVEL_APP}" == "1" ]]; then
#     # RUN LARAVEL MIGRATIONS ON BUILD.
#     if [[ "${RUN_LARAVEL_MIGRATIONS_ON_BUILD}" == "1" ]]; then
#         cd ${WEBROOT}
#         php artisan migrate
#     fi

#     # LARAVEL SCHEDULER
#     if [[ "${RUN_LARAVEL_SCHEDULER}" == "1" ]]; then
#         echo '* * * * * cd /var/www && php artisan schedule:run >> /dev/null 2>&1' > /etc/crontabs/root
#         crond
#     fi
# fi

# echo '03' >> /home/appuser/app/storage/logs/temp.log

# SYMLINK CONFIGURATION FILES.
# ln -s /etc/php7/php.ini /etc/php7/conf.d/php.ini
# ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf


# echo '04' >> /home/appuser/app/storage/logs/temp.log

# PRODUCTION LEVEL CONFIGURATION.
# if [[ "${PRODUCTION}" == "1" ]]; then
#     sed -i -e "s/;log_level = notice/log_level = warning/g" /etc/php/7.4/php-fpm.conf
#     sed -i -e "s/clear_env = no/clear_env = yes/g" /etc/php/7.4/php-fpm.d/www.conf
#     sed -i -e "s/display_errors = On/display_errors = Off/g" /etc/php/7.4/php.ini
# else
#     sed -i -e "s/;log_level = notice/log_level = notice/g" /etc/php/7.4/php-fpm.conf
#     sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.4/php-fpm.conf
# fi

# echo '05' >> /home/appuser/app/storage/logs/temp.log

# PHP & SERVER CONFIGURATIONS.
# if [[ ! -z "${PHP_MEMORY_LIMIT}" ]]; then
#     sed -i "s/memory_limit = 128M/memory_limit = ${PHP_MEMORY_LIMIT}M/g" /etc/php/7.4/conf.d/php.ini
# fi

# echo '06' >> /home/appuser/app/storage/logs/temp.log

# if [ ! -z "${PHP_POST_MAX_SIZE}" ]; then
#     sed -i "s/post_max_size = 50M/post_max_size = ${PHP_POST_MAX_SIZE}M/g" /etc/php/7.4/conf.d/php.ini
# fi

# echo '07' >> /home/appuser/app/storage/logs/temp.log

# if [ ! -z "${PHP_UPLOAD_MAX_FILESIZE}" ]; then
#     sed -i "s/upload_max_filesize = 10M/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}M/g" /etc/php/7.4/conf.d/php.ini
# fi


# echo '08' >> /home/appuser/app/storage/logs/temp.log

## pm.max
#TODO

pmMaxChildren=$(calculatePmMaxChildren)
puCount=$(getProcessingUnitCount)
sed -i -e "s/pm.max_children = .*$/pm.max_children = ${pmMaxChildren}/g" /etc/php/7.4/fpm/pool.d/app.conf
sed -i -e "s/pm.start_servers = .*$/pm.start_servers = $(($puCount * 4))/g" /etc/php/7.4/fpm/pool.d/app.conf
sed -i -e "s/pm.min_spare_servers = .*$/pm.min_spare_servers = $(($puCount * 2))/g" /etc/php/7.4/fpm/pool.d/app.conf
sed -i -e "s/pm.max_spare_servers = .*$/pm.max_spare_servers = $(($puCount * 4))/g" /etc/php/7.4/fpm/pool.d/app.conf
sed -i -e "s/pm.max_requests = .*$/pm.max_requests = 1000/g" /etc/php/7.4/fpm/pool.d/app.conf

echo "pm.max_children set to: $pmMaxChildren" >&1
echo "puCount: $puCount" >&1

#cat /proc/meminfo >&1

# echo '09' >> /home/appuser/app/storage/logs/temp.log

# find /etc/php/7.4/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# echo '10' >> /home/appuser/app/storage/logs/temp.log




## TEMP
# RUN LARAVEL MIGRATIONS ON BUILD.
# if [[ "${LUMEN_RUN_MIGRATION_ON_INIT}" == "1" ]]; then
#     echo "INIT - LUMEN_RUN_MIGRATION_ON_INIT: ${LUMEN_RUN_MIGRATION_ON_INIT}" >> /home/appuser/app/storage/logs/temp.log
#     # cd ${WEBROOT}
#     cd /home/appuser/app
#     php artisan migrate
# fi

# Lumen queue
# if [[ "${LUMEN_RUN_QUEUE}" == "1" ]]; then
#     echo "$logPrefix Integrate lumen queue into supervisord.conf." >&1
#     cat /etc/supervisord-program_lumen-worker.conf >> /etc/supervisord.conf
# #     echo "($logPrefix)" >&1

# #     echo "INIT - LUMEN_RUN_QUEUE: ${LUMEN_RUN_QUEUE}" >> /home/appuser/app/storage/logs/temp.log

# #     sed -i -e "s/lumenWorkerAutostart=false/autostart=true/g" /etc/supervisord.conf
# # else
# #     sed -i -e "s/lumenWorkerAutostart=false/autostart=false/g" /etc/supervisord.conf
# fi











# echo '11' >> /home/appuser/app/storage/logs/temp.log
# echo "$logPrefix 11." >&1

# echo "LUMEN_RUN_MIGRATION_ON_INIT: ${LUMEN_RUN_MIGRATION_ON_INIT}" >> /home/appuser/app/storage/logs/temp.log
# echo "LUMEN_RUN_SCHEDULER: ${LUMEN_RUN_SCHEDULER}" >> /home/appuser/app/storage/logs/temp.log
# echo "LUMEN_RUN_QUEUE: ${LUMEN_RUN_QUEUE}" >> /home/appuser/app/storage/logs/temp.log

# echo '12' >> /home/appuser/app/storage/logs/temp.log
# echo "$logPrefix 12." >&1


# echo '13' >> /home/appuser/app/storage/logs/temp.log
# echo "$logPrefix 13." >&1


# LARAVEL SCHEDULER
# if [[ "${LUMEN_RUN_SCHEDULER}" == "1" ]]; then
#     echo "INIT - LUMEN_RUN_SCHEDULER: ${LUMEN_RUN_SCHEDULER}" >> /home/appuser/app/storage/logs/temp.log
#     echo "* * * * * cd ${WEBROOT} && php artisan schedule:run >> /dev/null 2>&1" > /etc/crontabs/root
#     crond
# fi


## Remove supervisord subconfigurations from /etc.
# find /etc -type f -name supervisord-program_*.conf -delete



#echo "qqqqq: ${REDIS_SERVERS}"
##
echo "$logPrefix Initialization completed." >&1

#sed --version
#bash --version





## Set .env values
#if [[ -n "${APP_NAME}" ]]; then
#    sed -i -e "s|APP_NAME=.*$|APP_NAME=${APP_NAME}|g" "${pathAppRoot}/.env"
#fi
#
#if [[ -n "${WP_ENV}" ]]; then
#    sed -i -e "s|WP_ENV=.*$|WP_ENV=${WP_ENV}|g" "${pathAppRoot}/.env"
#fi
#
#if [[ -n "${WP_HOME}" ]]; then
#    sed -i -e "s|WP_HOME=.*$|WP_HOME=${WP_HOME}|g" "${pathAppRoot}/.env"
#fi
#
#if [[ -n "${DB_HOST}" ]]; then
#    sed -i -e "s|DB_HOST=.*$|DB_HOST=${DB_HOST}|g" "${pathAppRoot}/.env"
#fi
#
#if [[ -n "${DB_USER}" ]]; then
#    sed -i -e "s|DB_USER=.*$|DB_USER=${DB_USER}|g" "${pathAppRoot}/.env"
#fi
#
#if [[ -n "${DB_PASSWORD}" ]]; then
#    sed -i -e "s|DB_PASSWORD=.*$|DB_PASSWORD=${DB_PASSWORD}|g" "${pathAppRoot}/.env"
#fi
#
#if [[ -n "${DB_NAME}" ]]; then
#    sed -i -e "s|DB_NAME=.*$|DB_NAME=${DB_NAME}|g" "${pathAppRoot}/.env"
#fi


## Set additional WordPress plugin configuration values
if [[ -n "${REDIS_SERVERS}" ]]; then
    sed -i -e "s|\"127.0.0.1:6379\"|\"${REDIS_SERVERS}\"|g" "${pathAppRoot}/web/.configs/w3tc/master.php"
fi

if [[ -n "${AWS_IAM_KEY}" ]]; then
    sed -i -e "s|\"cdn.s3.key\".*$|\"cdn.s3.key\": \"${AWS_IAM_KEY}\",|g" "${pathAppRoot}/web/.configs/w3tc/master.php"
    sed -i -e "s|\"cdn.cf.key\".*$|\"cdn.cf.key\": \"${AWS_IAM_KEY}\",|g" "${pathAppRoot}/web/.configs/w3tc/master.php"
fi

if [[ -n "${AWS_IAM_SECRET}" ]]; then
    sed -i -e "s|\"cdn.s3.secret\".*$|\"cdn.s3.secret\": \"${AWS_IAM_SECRET}\",|g" "${pathAppRoot}/web/.configs/w3tc/master.php"
    sed -i -e "s|\"cdn.cf.secret\".*$|\"cdn.cf.secret\": \"${AWS_IAM_SECRET}\",|g" "${pathAppRoot}/web/.configs/w3tc/master.php"
fi

if [[ -n "${AWS_S3_BUCKET}" ]]; then
    sed -i -e "s|\"cdn.s3.bucket\".*$|\"cdn.s3.bucket\": \"${AWS_S3_BUCKET}\",|g" "${pathAppRoot}/web/.configs/w3tc/master.php"
    sed -i -e "s|\"cdn.cf.bucket\".*$|\"cdn.cf.bucket\": \"${AWS_S3_BUCKET}\",|g" "${pathAppRoot}/web/.configs/w3tc/master.php"
fi

if [[ -n "${AWS_S3_BUCKET_REGION}" ]]; then
    sed -i -e "s|\"cdn.s3.bucket.location\".*$|\"cdn.s3.bucket.location\": \"${AWS_S3_BUCKET_REGION}\",|g" "${pathAppRoot}/web/.configs/w3tc/master.php"
    sed -i -e "s|\"cdn.cf.bucket.location\".*$|\"cdn.cf.bucket.location\": \"${AWS_S3_BUCKET_REGION}\",|g" "${pathAppRoot}/web/.configs/w3tc/master.php"
fi


if [[ -n "${AWS_CLOUDFRONT_DOMAIN}" ]]; then
    sed -i -e "s|\"cdn.cf.id\".*$|\"cdn.cf.id\": \"$(echo $AWS_CLOUDFRONT_DOMAIN | cut -d'.' -f 1)\",|g" "${pathAppRoot}/web/.configs/w3tc/master.php"
fi

#if [[ -n "${AWS_CLOUDFRONT_ID}" ]]; then
#    sed -i -e "s|\"cdn.cf.id\".*$|\"cdn.cf.id\": \"${AWS_CLOUDFRONT_ID}\",|g" "${pathAppRoot}/web/.configs/w3tc/master.php"
#fi



#echo "QQQQ: ${WP_HOME}"
#echo "${pathAppRoot}"
#cat "${pathAppRoot}/.env"


## optimize opcache
# TODO solve exit code issue
# echo $(compileOpcache) >&1

#echo "install status check"
#installStatus="$(sudo -u nginx -- wp core is-installed --debug)"
#
#echo "$installStatus"
#
#sudo -u nginx -- wp core is-installed --debug
#
### run install if not already installed
#if ! sudo -u nginx -- wp core is-installed; then
#
#    echo "running wp core install"
#
#    sudo -u nginx -- wp core install \
#        --url="${WP_HOME}" \
#        --title=Test \
#        --admin_user=test \
#        --admin_password=qwerty12345 \
#        --admin_email=matija+wp_test@scrawlr.com \
#        --skip-email
#fi


#echo "<?php" > /home/appuser/app/web/wp/index.php
#echo "echo 'qqq'" >> /home/appuser/app/web/wp/index.php

#ls "${pathAppRoot}"
#ls "${pathAppRoot}/web"
#ls "${pathAppRoot}/web/wp"
#cat "${pathAppRoot}/web/wp/index.php"

# START SUPERVISOR.
#echo 'START SUPERVISOR' >> /home/appuser/app/storage/logs/temp.log
echo 'START SUPERVISOR' >&1
exec /usr/bin/supervisord -n -c /etc/supervisord.conf

#!/bin/sh

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
    echo $run >&1
}

calculatePmMaxChildren ()
{
    #
    usageEstimate=50000


    # Available memory in kb
    mem=$(cat /proc/meminfo | grep "MemAvailable:" | awk -F ' ' '{print $2}')

    #
    usableMem=$((($mem/100)*80))

    maxChildren=$(($usableMem/$usageEstimate))

    if [ "$maxChildren" -lt 1 ]; then
        maxChildren=1
    fi

    echo $maxChildren
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

# pmMaxChildren=$(calculatePmMaxChildren)
# sed -i -e "s/pm.max_children = 5/pm.max_children = ${pmMaxChildren}/g" /etc/php/7.4/php-fpm.d/www.conf
# echo "pm.max_children set to: $pmMaxChildren" >&1

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

##
# echo "$logPrefix Initialization completed." >&1

## optimize opcache
# TODO solve exit code issue
# echo $(compileOpcache) >&1

# START SUPERVISOR.
# echo 'START SUPERVISOR' >> /home/appuser/app/storage/logs/temp.log
# echo 'START SUPERVISOR' >&1
exec /usr/bin/supervisord -n -c /etc/supervisord.conf

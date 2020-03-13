# FROM nginx:mainline
FROM ubuntu:bionic

# Set base configurations
ARG php_version=7.4

ARG appPath=/home/appuser/app


ARG nginx_user_name=nginx
ARG nginx_user_id=25874


# ARG cont_user_group=appgroup
ARG cont_user_name=appuser
ARG cont_user_id=15874

ARG nginx_port=80


## Users
# RUN addgroup --system ${nginx_user_group} && \
#     adduser ${nginx_user_name} \
#         --system \
#         --gecos "" \
#         --disabled-password \
#         --no-create-home \
#         --uid ${nginx_user_id} \
#         --ingroup ${nginx_user_group}
RUN adduser ${nginx_user_name} \
        --system \
        --group \
        --gecos "" \
        --disabled-password \
        --disabled-login \
        --no-create-home \
        --uid ${nginx_user_id}

## Create the container user and corresponding user group.
RUN adduser ${cont_user_name} \
        --group \
        --gecos "" \
        --disabled-password \
        --uid ${cont_user_id}






# trust this project public key to trust the packages.
# ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# Configure Alpine repository based on the specified version.
# RUN echo "http://dl-cdn.alpinelinux.org/alpine/v${alpine_version}/main" > /etc/apk/repositories && \
    # echo "http://dl-cdn.alpinelinux.org/alpine/v${alpine_version}/community" >> /etc/apk/repositories
    # echo "https://dl.bintray.com/php-alpine/v${alpine_version}/php-{php_version}" >> /etc/apk/repositories

# make sure you can use HTTPS
# RUN apk --update add ca-certificates

# RUN cat /etc/*-release

# set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

## Set timezone
ENV TZ=UTC

##
# RUN apt-get update

RUN apt-get update && \
    apt-get install software-properties-common -y

RUN add-apt-repository ppa:ondrej/php && \
    add-apt-repository ppa:nginx/mainline

## Set build dependencies.
ENV build_deps \
        # python3 \
        python-setuptools \
        python-pip
        # wget
        # python3-pip
        # software-properties-common \
        # composer \

## Set python build dependencies for Python.
ENV build_deps_python \
        wheel

## Set persistent dependencies.
ENV persistent_deps \
        php${php_version} \
        php${php_version}-curl \
        php${php_version}-dom \
        php${php_version}-fpm \
        php${php_version}-gd \
        php${php_version}-imagick \
        php${php_version}-json \
        php${php_version}-opcache \
        php${php_version}-mysql \
        php${php_version}-zip \
        php${php_version}-xml \
        nginx \
        supervisor



# RUN apk --update --no-cache add less bash su-exec mysql-client freetype-dev libjpeg-turbo-dev libpng-dev \
#     && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
#     && docker-php-ext-install gd mysqli opcache



## Set persistent dependencies for Python.
ENV persistent_deps_python \
        supervisor-stdout

## Add apt repositories
# RUN apt update && \
#     apt install -y apt-transport-https lsb-release ca-certificates wget && \
#     wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
#     echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
# RUN apt-get update && \
#     apt-get install software-properties-common -y && \
#     add-apt-repository ppa:ondrej/php && apt update

# Install build dependencies
# RUN apt upgrade -y && apt update -y && \
#     apt install $build_deps -y

# Install build dependencies
RUN apt-get install -y --no-install-recommends $build_deps

# RUN add-apt-repository ppa:ondrej/php


# Install build dependencies
# RUN apk upgrade && apk update && \
#     apk add --no-cache --virtual .build-dependencies $build_deps

# RUN pip3 --version && pip list

# Install persistent dependencies
RUN apt-get install -y --no-install-recommends $persistent_deps

# Install persistent dependencies
# RUN apk add --update --no-cache --virtual .persistent-dependencies $persistent_deps

# RUN python2 -V
# RUN python3 -V
# RUN pip2 -V

# RUN ls /home

# Install supervisord-stdout
RUN pip install wheel
RUN pip install supervisor-stdout


##
# RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime
# RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN php -v
RUN nginx -v

# RUN apt purge php7.2*
# RUN apt purge php7.3*

RUN mkdir -p /run/php && \
    mkdir -p /run/nginx && \
    mkdir -p /run/supervisord && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /var/log/php && \
    mkdir -p /etc/nginx/sites-enabled && \
    mkdir -p /etc/nginx/sites-available


# ADD START SCRIPT, SUPERVISOR CONFIG, NGINX CONFIG AND RUN SCRIPTS.
ADD .docker/start.sh /start.sh
ADD .docker/supervisor/supervisord.conf /etc/supervisord.conf
ADD .docker/supervisor/supervisord-program_*.conf /etc/
ADD .docker/nginx/nginx.conf /etc/nginx/nginx.conf
ADD .docker/nginx/site.conf /etc/nginx/sites-available/default
# ADD .docker/php/php.ini /etc/php/${php_version}/fpm/php.ini
ADD .docker/php-fpm/php-fpm.conf /etc/php/${php_version}/fpm/php-fpm.conf
ADD .docker/php-fpm/pool.app.conf /etc/php/${php_version}/fpm/pool.d/app.conf
RUN chmod 755 /start.sh


# RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default





## Create the container user and corresponding user group.
# RUN addgroup -S ${cont_user_group} && adduser -S ${cont_user_name} -G ${cont_user_group}

## Expose the storage as a separate directory.
# RUN ln -s /home/${cont_user_name}/app/storage /home/${cont_user_name}/storage

# Run Composer install
# RUN composer install -n --no-progress --no-suggest --prefer-dist --profile --no-dev --no-scripts

# Finish composer
# RUN composer dump-autoload --no-scripts --no-dev --optimize

# remove build dep
# RUN apt remove $build_deps -y
# RUN apt autoremove -y
# RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# remove build dep
# RUN apk del .build-dependencies

# Remove build dep and artifacts
RUN apt-get update -y && \
    apt-get remove $build_deps -y && \
    apt-get clean -y && \
    apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /var/log/apt/* /var/log/*.log




# RUN ls /home/${cont_user_name}
##
# RUN chown ${cont_user_name}:${cont_user_group} -R /home/${cont_user_name}/app && chown ${cont_user_name}:${cont_user_group} -R /home/${cont_user_name}/storage

##
# RUN chown ${cont_user_name}:${cont_user_group} -R /home/${cont_user_name}/app/storage && chown ${cont_user_name}:${cont_user_group} -R /home/${cont_user_name}/storage


## TEMP TODO: update user permissions
# RUN chmod 777 -R /home/${cont_user_name}/app/storage
# RUN chmod g+s /home/${cont_user_name}/app/storage

USER ${cont_user_name}

# Set working directory
WORKDIR ${appPath}

# Copy application files into image
COPY . ${appPath}







# RUN ls -alh /etc/apk/repositories
# RUN du /etc/apk/repositories
# RUN du -h -d 1 -c /
# RUN du -h -d 1 -c /usr
# RUN du -h -d 1 -c /usr/lib
# RUN du -h -d 1 -c /usr/local
# RUN du -h -d 1 -c /usr/local/bin
# RUN ls -alh /usr/local/bin
# RUN df -h

##
USER root


##
RUN chown ${nginx_user_name}:${nginx_user_name} -R ${appPath}/web/app/uploads

# EXPOSE PORTS!
EXPOSE ${nginx_port}

# KICKSTART!
CMD ["/start.sh"]

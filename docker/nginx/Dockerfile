FROM nginx:1.24.0 as nginx-base-build

MAINTAINER Hein Hanekom <hein@sinov8.net>

# setup curl within the nginx image.
RUN apt-get update && apt-get install -y --no-install-recommends curl \
      && rm -rf /var/lib/apt/lists/*

# Setup Logging
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Delete the default welcome to nginx page.
RUN rm /usr/share/nginx/html/*


#################################################
# DEV BUILD
#################################################
FROM nginx-base-build as nginx-dev-build

# Copy over the custom nginx and default configs.
COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Start nginx in the foreground to play nicely with Docker.
CMD ["nginx", "-g", "daemon off;"]

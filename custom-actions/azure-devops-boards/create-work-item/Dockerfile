# Base image
FROM alpine:edge

# installes required packages for our script
RUN apk add --update --no-cache \
  bash \
  ca-certificates \
  curl \
  jq

# Copies your code file  repository to the filesystem
COPY entrypoint.sh /entrypoint.sh

# change permission to execute the script and
RUN chmod +x /entrypoint.sh

# file to execute when the docker container starts up
ENTRYPOINT ["/entrypoint.sh"]
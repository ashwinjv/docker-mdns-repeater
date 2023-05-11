FROM monstrenyatko/alpine AS builder
ARG MDNS_REPEATER_VERSION=local
ADD mdns-repeater.c mdns-repeater.c
RUN set -ex && \
    apk add build-base && \
    gcc -o /bin/mdns-repeater mdns-repeater.c -DMDNS_REPEATER_VERSION=\"${MDNS_REPEATER_VERSION}\"

FROM monstrenyatko/alpine

LABEL maintainer="Ashwin Venkatesan <ashwinjv@gmail.com>"

COPY --from=builder /bin/mdns-repeater /bin/mdns-repeater
RUN chown root:root /bin/mdns-repeater
RUN chmod 0755 /bin/mdns-repeater
RUN setcap cap_net_raw=+ep /bin/mdns-repeater
RUN apk update && apk add --no-cache docker-cli
RUN apk update && apk add --no-cache jq

ENV APP_NAME="mdns-repeater-app" \
    APP_BIN="/bin/mdns-repeater" \
    APP_USERNAME="daemon" \
    APP_GROUPNAME="daemon"

COPY run.sh /app/
RUN chown -R root:root /app
RUN chmod -R 0744 /app
RUN chmod 0755 /app/run.sh

ENTRYPOINT ["/app/run.sh"]
CMD ["mdns-repeater-app", "-f", "eth0", "docker0"]

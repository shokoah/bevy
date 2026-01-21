FROM alpine:3.19

RUN apk update && apk add --no-cache \
    strongswan \
    iproute2 \
    bash \
    curl

COPY ipsec.conf /etc/ipsec.conf
COPY ipsec.secrets /etc/ipsec.secrets
COPY strongswan.conf /etc/strongswan.conf

CMD ["ipsec", "start", "--nofork"]

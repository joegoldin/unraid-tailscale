FROM alpine:latest as build
RUN apk add --no-cache bash wget
WORKDIR /work
ARG VERSION
ENV VERSION ${VERSION}

RUN VERSION=$VERSION \
    && TSFILE="tailscale_${VERSION}_amd64.tgz" \
    && PACKAGE="https://pkgs.tailscale.com/stable/${TSFILE}" \
    && echo "Downloading $PACKAGE" \
    && wget $PACKAGE >/dev/null 2>&1 \
    && ret=$? \
    && if [ $ret -ne 0 ]; then \
         echo "Failed to download release" \
         && exit 1; \
       fi \
    && echo "Unpacking" \
    && DIR=$(mktemp -d -p .) \
    && (cd $DIR ; tar vxf ../${TSFILE} --strip-components=1 ) \
    && ln -s $DIR latest \
    && echo $(pwd)

FROM alpine:latest as deploy
RUN apk add --no-cache ca-certificates iptables iproute2
WORKDIR /app
COPY --from=build /work/latest /app
COPY docker-entrypoint.sh /app
CMD ["/app/docker-entrypoint.sh"]

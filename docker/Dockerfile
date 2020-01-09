FROM alpine:3.11
RUN apk update && apk add --no-cache ca-certificates
EXPOSE 8000
ARG KUBELOGIN_VERSION
RUN wget -O /kubelogin.zip https://github.com/int128/kubelogin/releases/download/$KUBELOGIN_VERSION/kubelogin_linux_amd64.zip && \
    unzip /kubelogin.zip && \
    rm /kubelogin.zip
USER daemon
ENTRYPOINT ["/kubelogin"]

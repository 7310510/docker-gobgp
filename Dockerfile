ARG go_version="1.11"

FROM golang:${go_version} as builder
ENV GOPATH /go
RUN go get -u github.com/golang/dep/cmd/dep \
    && mkdir -p $GOPATH/src/github.com/osrg \
    && git clone https://github.com/osrg/gobgp.git $GOPATH/src/github.com/osrg/gobgp
WORKDIR $GOPATH/src/github.com/osrg/gobgp
RUN $GOPATH/bin/dep ensure \
    && go build -o $GOPATH/bin/gobgp ./cmd/gobgp \
    && go build -o $GOPATH/bin/gobgpd ./cmd/gobgpd

FROM alpine:latest
WORKDIR /root
COPY --from=builder /go/bin/gobgp /usr/local/bin/gobgp
COPY --from=builder /go/bin/gobgpd /usr/local/bin/gobgpd
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
CMD ["/usr/local/bin/gobgpd", "-f", "/root/gobgpd.yaml"]
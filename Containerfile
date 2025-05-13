FROM ubuntu:24.04
RUN apt-get update
RUN apt-get install -y \
	make \
	golang-go \
	gcc-aarch64-linux-gnu

COPY . /go-fiovb
WORKDIR /go-fiovb

RUN make amd64

ENV CC=aarch64-linux-gnu-gcc
RUN make arm64

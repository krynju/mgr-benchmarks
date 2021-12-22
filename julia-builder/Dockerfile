FROM debian:bullseye-slim

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		build-essential libatomic1 python gfortran perl wget m4 cmake pkg-config curl git \
		ca-certificates \
	; \
	rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/
CMD	[ "bash", "juliabuild/build.sh" ]
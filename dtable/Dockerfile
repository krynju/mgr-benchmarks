FROM julia:1.8.0

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		g++ \
		curl \
		wget \
	; \
	rm -rf /var/lib/apt/lists/*
WORKDIR /tmp
RUN mkdir jlsysimage; \
    cd jlsysimage; \
    wget https://raw.githubusercontent.com/krynju/mgr-benchmarks/master/dtable/Project.toml; \
    wget https://raw.githubusercontent.com/krynju/mgr-benchmarks/master/dtable/Manifest.toml; \
    wget https://raw.githubusercontent.com/krynju/mgr-benchmarks/master/dtable/precompile.jl; \
    wget https://raw.githubusercontent.com/krynju/mgr-benchmarks/master/dtable/create_sysimage.jl; \
    julia -t4 create_sysimage.jl;
WORKDIR /home/dtable
CMD [ "bash", "runbenchmarks.sh" ]
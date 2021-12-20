FROM python:slim-bullseye
RUN	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		wget \
		gcc \
		python3-dev \
	; \
	rm -rf /var/lib/apt/lists/*

RUN wget https://raw.githubusercontent.com/krynju/mgr-benchmarks/master/dask/requirements.txt; \
	pip install -r requirements.txt; \
	rm requirements.txt

WORKDIR /home/dask
CMD [ "bash", "runbenchmarks.sh" ]
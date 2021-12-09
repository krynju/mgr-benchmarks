FROM krynju/julia-nightly-buster
WORKDIR /home
RUN git clone https://github.com/krynju/dtable_benchmarks.git; \
	cd dtable_benchmarks;
WORKDIR /home/dtable_benchmarks
CMD [ "bash", "run.sh" ]
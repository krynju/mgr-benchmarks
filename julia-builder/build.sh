git clone --branch kr/dtable-benchmarking https://github.com/krynju/julia.git
cd julia
make -j8 MARCH=x86-64
make binary-dist
cp -r *.tar.gz ../juliabuild/
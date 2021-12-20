using Pkg
Pkg.add("PackageCompiler")
Pkg.activate(".")
Pkg.instantiate()
using PackageCompiler
PackageCompiler.create_sysimage(
    ["BenchmarkTools", "CSV", "Dagger", "DataFrames", "OnlineStats", "Tables"];
    sysimage_path="sysimage.so",
    precompile_execution_file="precompile.jl",
)
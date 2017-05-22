__precompile__()

module QuTiP 
using PyCall
import PyCall: PyNULL, pyimport_conda, pycall
export qutip

using Compat
@compat import Base.show

###########################################################################
# quoted from PyPlot.jl
# Julia 0.4 help system: define a documentation object
# that lazily looks up help from a PyObject via zero or more keys.
# This saves us time when loading PyPlot, since we don't have
# to load up all of the documentation strings right away.
immutable LazyHelp
    o::PyObject
    keys::Tuple{Vararg{Compat.String}}
    LazyHelp(o::PyObject) = new(o, ())
    LazyHelp(o::PyObject, k::AbstractString) = new(o, (k,))
    LazyHelp(o::PyObject, k1::AbstractString, k2::AbstractString) = new(o, (k1,k2))
    LazyHelp(o::PyObject, k::Tuple{Vararg{AbstractString}}) = new(o, k)
end
@compat function show(io::IO, ::MIME"text/plain", h::LazyHelp)
    o = h.o
    for k in h.keys
        o = o[k]
    end
    if haskey(o, "__doc__")
        print(io, convert(AbstractString, o["__doc__"]))
    else
        print(io, "no Python docstring found for ", h.k)
    end
end
Base.show(io::IO, h::LazyHelp) = @compat show(io, "text/plain", h)
function Base.Docs.catdoc(hs::LazyHelp...)
    Base.Docs.Text() do io
        for h in hs
            @compat show(io, MIME"text/plain"(), h)
        end
    end
end

###########################################################################


const qutip = PyNULL()

# ref
# https://github.com/JuliaPy/PyPlot.jl/blob/master/src/PyPlot.jl#L166
# for f in plt_funcs
#     sf = string(f)
#     @eval @doc LazyHelp(plt,$sf) function $f(args...; kws...)
#         if !haskey(plt, $sf)
#             error("matplotlib ", version, " does not have pyplot.", $sf)
#         end
#         return pycall(plt[$sf], PyAny, args...; kws...)
#     end
# end


# export ducumented qutip API
include("utilities.jl")
include("sparse.jl")
include("simdiag.jl")
include("permute.jl")
include("parallel.jl")
include("ipynbtools.jl")
include("hardware_info.jl")
include("graph.jl")
include("fileio.jl")
include("about.jl")

include("tensor.jl")
include("qobj.jl")
include("partial_transpose.jl")
include("expect.jl")

include("metrics.jl")
include("entropy.jl")
include("countstat.jl")

include("three_level_atom.jl")
include("states.jl")
include("random_objects.jl")
include("continuous_variables.jl")
include("superoperator.jl")
include("superop_reps.jl")
include("subsystem_apply.jl")
include("operators.jl")

# include("bloch_redfield.jl")
# include("correlation.jl")
# include("eseries.jl")
# include("essolve.jl")
# include("floquet.jl")
# include("hsolve.jl")
# include("mcsolve.jl")
# include("mesolve.jl")
# include("propagator.jl")
# include("rcsolve.jl")
# include("rhs_generate.jl")
# include("sesolve.jl")
# include("solver.jl")
# include("steadystate.jl")
# include("stochastic.jl")
# include("memorycascade.jl")
# include("transfertensor.jl")
#
# include("settings.jl")
#
# include("bloch.jl")
# include("bloch3d.jl")
# include("distributions.jl")
# include("orbital.jl")
# include("tomography.jl")
# include("visualization.jl")
# include("wigner.jl")


const qutipfn = (utilities...,
                sparse...,
                simdiag_class...,
                permute...,
                parallel...,
                ipynbtools...,
                hardware_info_class...,
                graph...,
                fileio...,
                about_class...,
                tensor_class..., 
                qobj...,
                partial_transpose_class...,
                expect_class...,
                metrics...,
                entropy_class..., 
                countstat..., 
                three_level_atom...,
                states..., 
		        random_objects...,
                continuous_variables...,
                superoperator..., 
                superop_reps..., 
                subsystem_apply_class..., 
                operators...)

for f in qutipfn
    sf = string(f)
    @eval @doc LazyHelp(qutip,$sf) function $f(args...; kws...)
        if !haskey(qutip, $sf)
            error("qutip ", version, " does not have qutip.", $sf)
        end
        return pycall(qutip[$sf], PyAny, args...; kws...)
    end
end


function __init__()
    copy!(qutip, pyimport_conda("qutip", "qutip"))
    global const version = try
        convert(VersionNumber, qutip[:__version__])
    catch
        v"0.0" # fallback
    end
end



end # module


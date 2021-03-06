using Revise, DrWatson

@quickactivate :Pudley
import Pudley
const pdl = Pudley
using DataFrames
import IterTools
const It = IterTools



#=
-------------------------------------------------------------------
||Getting the data||
In which I get simulation results and load then into a DataFrame.
-------------------------------------------------------------------
=#

# In which I get the dir where the parameters are
paramsroot = datadir("parameters", "testprobe")

#= In which I specify what data I want. This is interactive. I ought to inspect
`paramsroot` to determine which data I want. Once I've decided I set it as a
variable. =#

readdir(paramsroot)

# i want all but the first

paramnames = readdir(paramsroot)[2:end-1]

#=
In which I get the full path of the parameters I want ⇒ `paramspath`
=#

paramspaths = map(name -> joinpath(paramsroot, name), paramnames )

#= In which I load the params and then filter because the .bson has uneeded
information such as :gitcommit and :gitpatch =#
paramss = map(path -> path |>
          load |>
          params -> [(k, v) for (k, v) in params if typeof(v) != String] |>
          Dict, paramspaths)

# In which i finally load the dataset

"""
function getnamehelper(param, extension)
Some types have whitespace when turned into strings (e.g. tuples).
This function get a dict of parameters and turn into a name (using DrWatson savename)
while removing the whitespace.
"""
function getnamehelper(param, extension)
    name =
        filter(!isspace, savename(param, extension; allowedtypes = typeof.(values(param))))
end

try
    datas = map(params -> DataFrame(load(datadir("sim", "testprobe",
                                                 getnamehelper(params, "csv")))), paramss)
catch e
    try
            datas = map(params -> DataFrame(load(datadir("sim", "testprobe",
                                                 getnamehelper(params, "csv")))), paramss)
    catch y
        warn("Ok, not reading the data for some fucking reason")
    end
end


#=
----------------------------------------------------------------------------------------------------------------------------------
||Filtering the data|||

 In which I apply some filters to the data. The data has lots of information I
have to zoom a subset:
----------------------------------------------------------------------------------------------------------------------------------
=#

# in which get only central and probe agent data:
filteredcentralprobes =
    map(data -> filter(x -> ((x.id == pdl.centralagentpos) || (x.id == pdl.probeagentpos)), data),
        datas)

datas = nothing

# * Until here I get wtf is happening

initial_probe = filter(x -> (x.id == 2) && (x.step == 0), data)
final_probe = filter(x -> (x.id == 2) && (x.step == 200), data)

# in which get the central and probe agent mean data over repetitions of the
# simulation:
mean_centralprobe = map(
    data -> combine(
        groupby(data, [:id, :step]),
        [:r, :old_σ, :old_o] .=> pdl.Stats.mean,),
    filteredcentralprobes)


# get data until a certain step
untilstep(step, data = mean_centralprobe) = filter(x -> x.step <= step, data)
until500data = untilstep(500)
until750data = untilstep(750)

# this is to get the data from a single parametrization for a single agent (for
# animations)
filteredid_df = filter(x -> x.probeo == 0.0 && x.id == 2, mean_centralprobe)

#=
----------------------------------------------------------------------------------------------------------------------------------
||Plotting the data||
----------------------------------------------------------------------------------------------------------------------------------
=#
colstoplot = (filter(x -> occursin("mean", x), names(until750data)))

function quickprobing(var, probevalue, data= until750data)

    probetitle(var, probevalue) =
        join([string(var), "for", "initial probeo=$(probevalue)"], " ")
    
    datatoplot = filter(x -> x.probeo == probevalue, data)
    titletoplot = probetitle(var, probevalue)

    qplot = pdl.timeplot(datatoplot,
                         var,titletoplot)

end

quickprobing_r(probevalue) = quickprobing(:r_mean, probevalue)
quickprobing_σ(probevalue) = quickprobing(:old_σ_mean, probevalue)
quickprobing_o(probevalue) = quickprobing(:old_o_mean, probevalue)


for pr in params[:probeo]
    pdl.Plots.plot(
        [quickprobing_r(pr), quickprobing_o(pr), quickprobing_σ(pr)]...,
        layout = (1, 3),
        titlefont = pdl.Plots.font("sans-serif", pointsize = round(7.0)),
        dpi = 200,
    )
    pdl.Plots.savefig(joinpath(plotsdir(), "probevalue$(pr).png"))
end


@async run(`nautilus ../plots`)


# Trying to animate
steps = []
r_means = []

anim = @animate for s in eachrow(filteredid_df)
    push!(steps , s.step)
    push!(r_means, s.r_mean)
    plot(steps, r_means)
end

gif(anim, "../plots/foobar.gif", fps=2)

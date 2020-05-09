using Revise, DrWatson

@quickactivate :Pudley
import Pudley
const pdl = Pudley
using DataFrames

function getnamehelper(param, extension)
    name = filter(!isspace, savename(param, extension; allowedtypes = typeof.(values(param))))
end


paramsroot = datadir("parameters", "testprobe")
paramsname = readdir(paramsroot)[1]
paramspath = joinpath(paramsroot,paramsname)
params = Dict([(k,v) for (k,v) in load(paramspath) if typeof(v) != String])

data = DataFrame(load(datadir("sim", "testprobe", getnamehelper(params, "csv"))))

filteredcentralprobe = filter(x-> ((x.id == pdl.centralagentpos) || (x.id == pdl.probeagentpos)), data)

# (
#     combine(groupby(filtered12data, [:probeo, :id, :step]), [:r, :old_σ, :old_o] .=> pdl.Stats.mean) |>
#     d -> filter(x-> x.probeo == 0.0, d) |>
#     d -> d[!, :step]
# )

mean_centralprobe = combine(groupby(filteredcentralprobe, [:probeo, :id, :step]), [:r, :old_σ, :old_o] .=> pdl.Stats.mean)

function quickprobing(var, probevalue)
    probetitle(var, probevalue) = join([string(var), "for" , "initial probeo=$(probevalue)"], " ")
    qplot = pdl.timeplot(
        filter(x-> x.probeo == probevalue, mean_centralprobe),
                         var,
                         probetitle(var, probevalue))
end

colstoplot = (filter(x -> occursin("mean", x ), names(mean_centralprobe)) )

quickprobing_r(probevalue) = quickprobing(:r_mean, probevalue)
quickprobing_σ(probevalue) = quickprobing(:old_σ_mean, probevalue)
quickprobing_o(probevalue) = quickprobing(:old_o_mean, probevalue)


for pr in params[:probeo]

pdl.Plots.plot([quickprobing_r(pr), quickprobing_o(pr),
                quickprobing_σ(pr)]...,
               layout = (1, 3),
               titlefont = pdl.Plots.font("sans-serif", pointsize = round(5.0)), dpi= 200)
    pdl.Plots.savefig(joinpath(plotsdir(), "probevalue$(pr).png"))
end

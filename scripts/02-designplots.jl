using Revise, DrWatson

@quickactivate :Pudley
import Pudley
const pdl = Pudley
using DataFrames

function getnamehelper(param, extension)
    name =
        filter(!isspace, savename(param, extension; allowedtypes = typeof.(values(param))))
end


paramsroot = datadir("parameters", "testprobe")
paramsname = readdir(paramsroot)[1]
paramspath = joinpath(paramsroot, paramsname)
params = Dict([(k, v) for (k, v) in load(paramspath) if typeof(v) != String])

data = DataFrame(load(datadir("sim", "testprobe", getnamehelper(params, "csv"))))

filteredcentralprobe =
    filter(x -> ((x.id == pdl.centralagentpos) || (x.id == pdl.probeagentpos)), data)

# (
#     combine(groupby(filtered12data, [:probeo, :id, :step]), [:r, :old_σ, :old_o] .=> pdl.Stats.mean) |>
#     d -> filter(x-> x.probeo == 0.0, d) |>
#     d -> d[!, :step]
# )

mean_centralprobe = combine(
    groupby(filteredcentralprobe, [:probeo, :id, :step]),
    [:r, :old_σ, :old_o] .=> pdl.Stats.mean,
)

until500data = filter(x -> x.step <= 500, mean_centralprobe)

function quickprobing(var, probevalue, data= until500data)
    probetitle(var, probevalue) =
        join([string(var), "for", "initial probeo=$(probevalue)"], " ")

    qplot = pdl.timeplot(
        filter(x -> x.probeo == probevalue, data),
        var,
        probetitle(var, probevalue),
    )

end


colstoplot = (filter(x -> occursin("mean", x), names(until500data)))

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


filteredid_df = filter(x -> x.probeo == 0.0 && x.id == 2, mean_centralprobe)

steps = []
r_means = []

anim = @animate for s in eachrow(filteredid_df)
    push!(steps , s.step)
    push!(r_means, s.r_mean)
    plot(steps, r_means)
end

gif(anim, "../plots/foobar.gif", fps=2)


foobar = groupby(until500data, :id)

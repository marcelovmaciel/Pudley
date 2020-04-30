import Pkg

using ClearStacktrace
using JuliaFormatter
format(".")
format("../../Pudley/src")

Pkg.activate("../../Pudley")

Pkg.instantiate()

Pkg.resolve()
Pkg.precompile()

import Revise
import Pudley
const pdl = Pudley


const zoomplotdenominators = [10, 100, 10000]


n = 100
t = 500
interval = (-10, 10)
agent_properties = [:r, :old_σ, :old_o]


for i = 1:10
    m = pdl.model_initialize(n = n, interval = interval)
    agent_properties = [:r, :old_σ, :old_o]

    data = pdl.Abm.run!(m, pdl.agent_step!, pdl.model_step!, t, adata = agent_properties)[1]

    p1 = pdl.timeplot(data, :r, "xr, $n agents, run $(i)")

    p2 = pdl.timeplot(data, :old_σ, "sigma, $n agents")

    p3 = pdl.timeplot(data, :old_o, "o, $n agents")

    r1c2, r2c2, r3c2 = (
        zoomplotdenominators .|>
            scaler -> pdl.zoomplot(data, :r, p1, pdl.zoomplotbounds, scaler, ", range/")
    )
    r1c3, r2c3, r3c3 = (
        zoomplotdenominators .|>
            scaler -> pdl.zoomplot(
            data,
            :r,
            p1,
            pdl.medianplotbounds,
            scaler,
            ", range = +- median * ",
        )
    )


    pdl.Plots.plot(
        p1,
        r1c2,
        r1c3,
        p2,
        r2c2,
        r2c3,
        p3,
        r3c2,
        r3c3,
        layout = (3, 3),
        dpi = 200,
        titlefont = pdl.Plots.font("sans-serif", pointsize = round(5.0)),
    )

    pdl.Plots.savefig("plot-n(100)/plot-n($n)-run($i).png")

end

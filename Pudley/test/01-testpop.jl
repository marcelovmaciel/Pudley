import Pkg

#Pkg.add("Revise")

import Revise

Pkg.activate("../../Pudley")

import Pudley #,  Pandas, Seaborn
const pdl = Pudley
using BenchmarkTools
using  Plots
Plots.gr(legend = false)
using Curry

#@code_warntype pdl.createpop(pdl.Agent_o, 2., (-5, 5), 500)

#@time pdl.createpop(pdl.Agent_o, 2., (-5, 5), 500)
#pairs = Array{Tuple{eltype(pop)}, 1}(undef, length(pop))

# plot_opinions(pop) = (sns.distplot ∘ pd.DataFrame ∘
#                       partial(map,(pdl.getopinion ∘ pdl.getbelief)))(pop)

#@time pdl.getpairs(pop)
#const p = 0.9

# getpairbs(pairs) = map(partial(map, pdl.getbelief), pairs)

# rlbelief(pairs) = (first.(getpairbs(pairs)), last.(getpairbs(pairs)))

# ax = plot_opinions(pop)
# ax.set_title("iteration 0")

# sns.savefig("imgs/plot0.png")
# plt.figure()

function getstatearray(pop;  simend = 500_000)
    result = Array{eltype(pop)}(undef, length(pop), simend)
    result[:, 1] .= deepcopy(pop)
    for i in range(2, stop = simend)
        pdl.uppudleypop!(pop)
        result[:, i] .= deepcopy(pop)
    end
    return(result)
end


function animateseries(simresult; interpolation = 5)
    fig1 = Plots.plot(show = false, xlabel = "iterations",
                ylabel = "opinions",
                    dpi = 80)
 anim =  Plots.@animate  for i in 1:size(simresult)[2]
        Plots.plot!(fig1,
              partial(map,(pdl.getopinion ∘ pdl.getbelief))(simresult[:,i]),
        linealpha = 0.2)
    end
    #   Plots.png("tseries")
    # Plots.gui(fig1)
    Plots.gif(anim, "anim_fps15.gif", fps = 15)
end


function plotseries(simresult;
             plotfn = (fig, x) ->  Plots.plot!(fig,
                                              partial(map,
                                                      (pdl.getopinion ∘ pdl.getbelief))(x)))
    fig1 = Plots.plot(show = false, xlabel = "iterations",
                ylabel = "opinions",
                    dpi = 200)
    for i in 1:size(simresult)[1]
        plotfn(fig1, simresult[i, :])
    end
    #Plots.png("tseries")
    Plots.gui(fig1)
    return(fig1)
end

function plotseries(simresult, ylim)
    plotseries(simresult,
               plotfn = (fig, x) ->  Plots.plot!(fig,
                                                partial(map,
                                                        (pdl.getopinion ∘ pdl.getbelief))(x),
                                                ylim = ylim,
                                                linealpha = 0.2))
               
end

pop = pdl.createpop(pdl.Agent_o, 2., (-5, 5), 50);

# @btime pdl.getjtointeract(pop, pop[1])
# @code_warntype pdl.getjtointeract(pop, pop[1])
# @code_warntype pdl.getbelief(pop[1])

# @code_warntype  pdl.getpairs(pop, pairs)

# @code_warntype  pdl.createpairs(pop)

# @btime pdl.createpop(pdl.Agent_o, 2., (-5, 5), 100);
# @code_warntype pdl.createpop(pdl.Agent_o, 2., (-5, 5), 100);

# @btime rand(pdl.Dist.DiscreteUniform(1, length(pop)))

# @btime pdl.emptypop(pdl.Agent_o, 500)

# @btime pdl.createbeliefs( 2., (-5, 5), 100)
# @btime pdl.fillpop( pdl.emptypop(pdl.Agent_o, 500), 2., (-5, 5) )
# @btime pdl.createpairs(pop)


# @code_warntype pdl.uppudleypop!(pop)
# @btime pdl.uppudleypop!(pop)
# @btime pdl.fillpairs!(pop,pairss)
# @btime (i -> pdl.getjtointeract(pop, i)).(pop)
result = getstatearray(pop);


inithist = histogram(partial(map, (pdl.getopinion ∘ pdl.getbelief))(result[:,1]), title = "initial condition")
Plots.png("inithist")


inithist = histogram(partial(map, (pdl.getopinion ∘ pdl.getbelief))(result[:,end]), title = "end condition")
Plots.png("endhist")


fig1 = plotseries(result, (-200,200))

Plots.png("test1_50")

fig2 = plotseries(result, (-20, 20))

Plots.png("test2_50")

fig3 = plotseries(result, (-5,5))

Plots.png("test3_50")

#plot(fig1, fig2, fig3,  layout = (3,1))



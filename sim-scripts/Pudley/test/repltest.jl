using Pkg
Pkg.activate("../")


using Revise
import Pudley
const  pdl  = Pudley


pdl.Belief(0.1, (-5, 5))


#stable
@code_warntype fill(5.0, (3, 3))



testAgent = pdl.Agent_o(5,  0.1, (-5,5))



@code_warntype pdl.createpop(pdl.Agent_o, 0.1, (-5.5), 2)

pop1 = pdl.createpop(pdl.Agent_o, 1., (-5, 5), 2)

#ns = pdl.updateijbelief!(pop1[1], pop1, 0.01, pdl.calculatep★)

#pdl.updatepop!(pop1, 1, 0.5)

pop1

pdl.updatepop!(pop1, 100, 0.5)

pop1
#pdl.updatepopsigma!(pop1, ns)

pop1

@doc supertype

(typeof(nw1) <:
 pdl.LG.AbstractGraph)




@code_warntype pdl.getjtointeract(pop1[1],pop1) #the same error happens here!!!!

pdl.getjtointeract(pop1[1],pop1).id #the same error happens here!!!!

#HERE


pdl.pick_issuebelief(pop1[1],  pdl.getjtointeract(pop1[1],pop1))

pdl.pick_issuebelief(pop1[1],  pdl.getjtointeract(pop1[1],pop1)) |> typeof

belieftuple = pdl.pick_issuebelief(pop1[1],  pdl.getjtointeract(pop1[1],pop1))


@code_warntype belieftuple |> x -> pdl.calculate_pstar(x[2], x[3], 0.9)


@code_warntype pdl.pick_issuebelief(pop1[1], pop1[2], 1)

b1,b2 = pdl.pick_issuebelief(pop1[1], pop1[2], 1)

@code_warntype

@time pdl.calculate_pstar(b1, b1, 0.9)




pop1 = pdl.createpop(pdl.Agent_o, 0.1, 5, 25)
@time pdl.add_neighbors!(pop1, pdl.LG.CompleteGraph)

@time pdl.updateibelief!(pop1[1], pop1, 0.9)



@time  pdl.ρ_update!(pop1[1], 0.01)


eltype(pdl.createpop(pdl.Agent_o, 0.1, 1, 5))

#-- test together ↓


#Do some sanity checking here for the calculate_pstar alternative implementation
parasect  = pdl.PoodlParam()

@doc pdl.create_initialcond

parasect.graphcreator

@code_warntype pdl.create_initialcond(parasect.agent_type,
                                      parasect.σ,
                                      parasect.n_issues,
                                      parasect.size_nw,
                                      parasect.graphcreator,
                                      parasect.propintransigents)

foopop = pdl.create_initialcond(parasect.agent_type,
                       parasect.σ,
                       parasect.n_issues,
                       parasect.size_nw * 5,
                       parasect.graphcreator,
                                parasect.propintransigents)

foopop[1] |> x -> fieldnames(typeof(x))

foopop[1] |> x-> getfield(x, :idealpoint)

foopop[1].idealpoint


pdl.calculate_pstar(foopop[1],foopop[5],1, 0.7)

foopop[1].idealpoint

foopop[2].idealpoint

p = 0.7
i_belief,j_belief = pdl.pick_issuebelief(foopop[1], foopop[2], 1)

num = p * (1 / (sqrt(2 * π ) * i_belief.σ ) )* exp(-((foopop[1].idealpoint - foopop[2].idealpoint)^2 / (2*i_belief.σ^2)))

denom= num + (1 - p)
alternative_pstar  = num / denom |> 



@doc pdl.pullidealpoints

@code_warntype pdl.pullidealpoints(foopop)

@code_warntype pdl.createstatearray(foopop, parasect.time)

@code_warntype pdl.create_initdf(foopop)

foodf = pdl.create_initdf(foopop)

@code_warntype pdl.update_df!(foopop, foodf, parasect.time)


pdl.agents_update!(foopop, parasect.p, parasect.σ, parasect.ρ)

pdl.update_df!(foopop, foodf, parasect.time)

foodf

foopop

@code_warntype pdl.outputfromsim(pdl.pullidealpoints(foopop))


@code_warntype pdl.createstatearray(foopop, parasect.time)

pdl.createstatearray(foopop,parasect.time)

@code_warntype pdl.agents_update!(foopop, parasect.p, parasect.σ, parasect.ρ)


@code_warntype pdl.runsim!(foopop,foodf,parasect.p, parasect.σ,
                           parasect.ρ, parasect.time)


@code_warntype pdl.one_run(parasect)

pdl.Agent_o |> typeof

typeof(pdl.LG.CompleteGraph) <: pdl.LG.SimpleGraphs.CompleteGraph

@doc pdl.LG.SimpleGraphs.CompleteGraph

typeof(typeof)


pdl.simple_run(parasect)

pdl.simstatesvec(parasect)

@code_warntype pdl.simstatesvec(parasect)

@code_warntype pdl.statesmatrix(parasect)


pdl.get_simpleinitcond(parasect)




#Testing memory allocations

pop1 = pdl.createpop(pdl.Agent_o, 0.1, 5, 25)
@time pdl.add_neighbors!(pop1, pdl.LG.CompleteGraph)

@time pdl.updateibelief!(pop1[1], pop1, 0.9)

@time  pdl.ρ_update!(pop1[1], 0.01)

@time pdl.agents_update!(pop1, 0.9, 0.01)


parasect  = pdl.PoodlParam()



foopop = pdl.create_initialcond(parasect.agent_type,
                       parasect.σ,
                       parasect.n_issues,
                       parasect.size_nw * 5,
                       parasect.graphcreator,
                                parasect.propintransigents)

@time pdl.runsim!(foopop,parasect.p, parasect.ρ, parasect.time)

# ↑↑↑↑↑↑↑↑ first run of this code leads to 422k allocations, the second to 14!!!

@time pdl.simple_run(parasect)

@time pdl.simple_run(parasect) |> pdl.pullidealpoints |> pdl.outputfromsim

@code_warntype pdl.simple_run(parasect) 


typeof(parasect)

parasect

pdl.Agent_o()

outsim = pdl.simple_run(parasect)

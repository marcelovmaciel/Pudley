import Pkg


Pkg.activate("../../Pudley")
Pkg.instantiate()

using Agents
using Distributions
using LightGraphs

mutable struct Agent_o{Posfield<:Int,Ofield<:AbstractFloat,Sigmafield<:AbstractFloat} <:
               AbstractAgent

    id::Posfield
    pos::Posfield
    o::Ofield
    oldo::Ofield
    oldσ::Sigmafield
    σ::Sigmafield

end

Agent_o() = Agent_o(0, 0, 0.0, 0.0, 2.0, 2.0)

space(n::Int, graph) = Space(graph(n))
space(n) = space(n, complete_graph)

function model(agentype, myspace, scheduler)
    ABM(agentype, myspace, scheduler = scheduler)
end


model(n) = model(Agent_o, space(n), fastest)

function emptypop(agent_type, n::Int)
    Vector{typeof(agent_type())}(undef, n)
end

function opinionarray(interval, n, distribution = Uniform)
    opinions = Vector{Float64}(undef, n)
    @. opinions = rand(distribution(interval[1], interval[2]))
    return (opinions)
end

function fillpop!(pop, opinionarray, σ, agent_type = Agent_o)
    poplen = length(pop)
    for i = 1:poplen
        pop[i] = agent_type(i, i, opinionarray[i], opinionarray[i], σ, σ)
    end
    return (pop)
end


function createpop(agent_type, n, σ, interval)
    fillpop!(emptypop(agent_type, n), opinionarray(interval, n), σ)
end

# createpop(n) = createpop(Agent_o, 2, (-5, 5),n)
function fillmodel!(m, population)
    for i = 1:length(population)
        add_agent!(population[i], i, m)
    end
    return (m)
end

function fillmodel!(m, n, σ, interval, agent_type = Agent_o)
    population = createpop(agent_type, n, σ, interval)
    for i = 1:n
        add_agent!(population[i], i, model)
    end
    return (m)
end

function getjtointeract(a, m)
    id2agent(rand(node_neighbors(a, m)), m)
end

# not okay the type stability here
# function getjstointeract(m)
#     js = Vector{typeof(id2agent(1,m))}(undef, nv(m))
#     for i in nodes(m)
#     js[i] = getjtointeract(i, m)
#     end
#     return(js)
# end

getopinion(a) = a.o
o(a) = getopinion(a)
oldo(a) = a.oldo
getσ(a) = a.σ
σ(a) = getσ(a)
oldσ(a) = a.oldσ

function changingterm★(i, j)
    -(oldo(i) - oldo(j))^2 / (2 * oldσ(i)^2)
end

function calculatep★(p::AbstractFloat, i, j)
    cterm = changingterm★(i, j)
    num = p * (1 / (√(2 * π) * oldσ(i))) * exp(cterm)
    denom = num + (1 - p)
    pstar = num / denom
    return (pstar)
end

function calc_posterior_o(p★, i, j)
    p★ * ((oldo(i) + oldo(j)) / 2) + (1 - p★) * oldo(i)
end

function update_o!(i, posterior_o)
    i.o = posterior_o
    nothing
end

function update_sigma!(i, posterior_sigma)
    i.σ = posterior_sigma
    nothing
end

function calcσ★(p★, i, j)
    √(oldσ(i)^2 * (1 - p★ / 2) + p★ * (1 - p★) * ((oldo(i) - oldo(j)) / 2)^2)
end

calcr(sigmastar, oldsigma) = sigmastar / oldsigma

function model_initialize(; n = 200, σ = 2.0, interval = (-5, 5), agent_type = Agent_o)
    m = model(n)
    population = createpop(agent_type, n, σ, interval)
    fillmodel!(m, population)
    return (m)
end

function agent_step!(a, m, p = 0.9)
    b = getjtointeract(a, m)
    p★ = calculatep★(p, a, b)
    σ★ = calcσ★(p★, a, b)
    newo = calc_posterior_o(p★, a, b) / calcr(σ★, σ(a))
    update_o!(a, newo)
    update_sigma!(a, σ★)
end

function model_step!(model)
    for i in keys(model.agents)
        a = id2agent(i, model)
        updateold(a)
    end
end

function updateold(a)
    a.oldo = a.o
    a.oldσ = a.σ
    return a
end

function model_step2!(model)
    model.agents = updateold.(dictionary(model.agents))
end

m = model_initialize()


@btime agent_step!(id2agent(1, m), m)
@btime model_step2!(m)
@btime model_step!(m)

using Dictionaries

n = 100_000

agent_properties = [:o, :σ]

when = map(i -> floor(Int, i), collect(range(0, step = 1000, stop = n)))

when[1] = 1



@btime step!(m, agent_step!, model_step!, 20_000, agent_properties, when = when)

using DataVoyager

Voyager(data)

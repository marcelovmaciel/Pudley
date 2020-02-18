mutable struct Agent_o{Posfield<:Int,Ofield<:AbstractFloat,Sigmafield<:AbstractFloat} <:
               Abm.AbstractAgent
    id::Posfield
    pos::Posfield
    old_o::Ofield
    new_o::Ofield
    old_σ::Sigmafield
    new_σ::Sigmafield
end

Agent_o() = Agent_o(0, 0, BigFloat(0), BigFloat(0), BigFloat(2), BigFloat(2))


space(n::Int, graph) = Abm.Space(graph(n))
space(n) = space(n, LG.complete_graph)

function model(agentype, myspace, scheduler)
    Abm.ABM(agentype, myspace, scheduler = scheduler)
end

myscheduler(m) = Abm.keys(m.agents)
model(n) = model(Agent_o, space(n), myscheduler)

function emptypop(agent_type, n::Int)
    Vector{typeof(agent_type())}(undef, n)
end

function opinionarray(interval, n, distribution = Dist.Uniform)
    opinions = Vector{BigFloat}(undef, n)
    @. opinions = BigFloat(rand(distribution(interval[1], interval[2])))
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
        Abm.add_agent!(population[i], i, m)
    end
    return (m)
end

function fillmodel!(m, n, σ, interval, agent_type = Agent_o)
    population = createpop(agent_type, n, σ, interval)
    for i = 1:n
        Abm.add_agent!(population[i], i, model)
    end
    return (m)
end

function getjtointeract(a, m = m)
    Abm.id2agent(rand(Abm.node_neighbors(a, m)), m)
end

# not okay the type stability here
function getjstointeract(m)
    js = Vector{typeof(Abm.id2agent(1, m))}(undef, Abm.nv(m))
    for i in Abm.nodes(m)
        js[i] = getjtointeract(i, m)
    end
    return (js)
end

getopinion(a) = a.old_o
o(a) = getopinion(a)
getσ(a) = a.old_σ
σ(a) = getσ(a)

function changingterm★(i, j)
    -(o(i) - o(j))^2 / (2 * σ(i)^2)
end

function calculatep★(p::AbstractFloat, i, j)
    cterm = changingterm★(i, j)
    num = p * (1 / (√(2 * π) * σ(i))) * exp(cterm)
    denom = num + (1 - p)
    pstar = num / denom
    return (pstar)
end

function calc_posterior_o(p★, i, j)
    p★ * ((o(i) + o(j)) / 2) + (1 - p★) * o(i)
end

function update_o!(i, posterior_o)
    i.new_o = posterior_o
    nothing
end

function update_sigma!(i, posterior_sigma)
    i.new_σ = posterior_sigma
    nothing
end

function calcσ★(p★, i, j)
    √(σ(i)^2 * (1 - p★ / 2) + p★ * (1 - p★) * ((o(i) - o(j)) / 2)^2)
end

calcr(sigmastar, oldsigma) = sigmastar / oldsigma


function model_initialize(;
    n = 200,
    σ = BigFloat(2),
    interval = (-5, 5),
    agent_type = Agent_o,
)
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

function updateold(a)
    a.old_o = a.new_o
    a.old_σ = a.new_σ
    return a
end

function model_step!(model)
    for i in keys(model.agents)
        agent = Abm.id2agent(i, model)
        updateold(agent)
    end
end

mutable struct Agent_o{Posfield<:Int,Ofield<:AbstractFloat,Sigmafield<:AbstractFloat} <:
               Abm.AbstractAgent
    id::Posfield
    pos::Posfield
    old_o::Ofield
    new_o::Ofield
    old_σ::Sigmafield
    new_σ::Sigmafield
    r::Ofield
end

function Agent_o()
    Agent_o(0, 0, big(0.0), big(0.0), big(2.0), big(2.0), big(0.0))
end


space(n::Int, graph) = Abm.Space(graph(n))
space(n) = space(n, LG.complete_graph)

function model(agentype, myspace, scheduler)
    Abm.ABM(agentype, myspace, scheduler = scheduler)
end

#myscheduler(m) = Abm.keys(m.agents)
#model(n) = model(Agent_o, space(n), myscheduler)
model(n) = model(Agent_o, space(n), Abm.by_id)

function emptypop(agent_type, n::Int)
    Vector{agent_type}(undef, n)
end


function opinionarray(interval, n, distribution = Dist.Uniform)
    opinions = Vector{BigFloat}(undef, n)
    @. opinions = big(rand(distribution(interval[1], interval[2])))

    return (opinions)
end

geto(a) = a.old_o
getσ(a) = a.old_σ



function fillpop!(pop, opinionarray, σ, agent_type = Agent_o)
    poplen = length(pop)
    pop[1] = agent_type(1, 1, big(0.0), big(0.0), big(1.0), big(1.0), big(0.0))
    for i = 2:poplen
        pop[i] = agent_type(i, i, opinionarray[i], opinionarray[i], σ, σ, big(0.0))
       # print(getfield(pop[i], :r))
        setfield!(pop[i], :r,  (geto(pop[i]) - geto(pop[1])) / σ(pop[1]))
    end
    return (pop)
end


function fillpop!(pop, opinion::BigFloat, σ, agent_type = Agent_o)
    poplen = length(pop)
    pop[1] = agent_type(1, 1, big(0.0), big(0.0), big(1.0), big(1.0), big(0.0))
    for i = 2:poplen
        pop[i] = agent_type(i, i, opinion, opinion, σ, σ, big(0.0))
        setfield!(pop[i], :r,
                  (geto(pop[i]) - geto(pop[1])) /getσ(pop[1]))
    end
    return (pop)
end


function createpop(agent_type, n, σ, interval)
    fillpop!(emptypop(agent_type, n), opinionarray(interval, n), σ)
end

function createpop(agent_type, n, σ, opinion::BigFloat)
    fillpop!(emptypop(agent_type, n), opinion, σ)
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
function getjstointeract(m)::Vector{Agent_o}
    js = Vector{typeof(Abm.id2agent(1, m))}(undef, Abm.nv(m))
    for i in Abm.nodes(m)
        js[i] = getjtointeract(i, m)
    end
    return (js)
end

function changingterm★(i, j)
    -(geto(i) - geto(j))^2 / (2 * getσ(i)^2)
end

function calculatep★(p::AbstractFloat, i, j)
    cterm = changingterm★(i, j)
    num = p * (1 / (√(2 * π) * getσ(i))) * exp(cterm)
    denom = num + (1 - p)
    pstar = num / denom
    return (pstar)
end

function calc_posterior_o(p★, i, j)
    p★ * ((geto(i) + geto(j)) / 2) + (1 - p★) * geto(i)
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
    √(getσ(i)^2 * (1 - p★ / 2) + p★ * (1 - p★) * ((geto(i) - geto(j)) / 2)^2)
end

function xr(a, m)
    central_agent = Abm.id2agent(1, m)
    xᵣₐ = (geto(a) - geto(central_agent)) / getσ(central_agent)
end


function xr!(a, m)
    central_agent = Abm.id2agent(1, m)
    xᵣₐ = (geto(a) - geto(central_agent)) / getσ(central_agent)
    a.r = xᵣₐ
end


#calcr(sigmastar, oldsigma) = sigmastar / oldsigma

function model_initialize(;
    n = 200,
    σ = big(1.0),
    interval = (-20, 20),
    agent_type = Agent_o,
)
    m = model(n)
    population = createpop(agent_type, n, σ, interval)
    fillmodel!(m, population)
    return (m)
end

function model_initialize(; n = 200, σ = big(1.0), opinion = big(1.0), agent_type = Agent_o)
    m = model(n)
    population = createpop(agent_type, n, σ, opinion)
    fillmodel!(m, population)
    return (m)
end


function agent_step!(a, m, p = 0.3)
    b = getjtointeract(a, m)
    p★ = calculatep★(p, a, b)
    σ★ = calcσ★(p★, a, b)
    newo = calc_posterior_o(p★, a, b) #/ calcr(σ★, σ(a))
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
        xr!(agent, model)
    end
end

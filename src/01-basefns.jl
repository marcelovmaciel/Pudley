mutable struct Agent_o{Posfield<:Int,
                       Ofield<:AbstractFloat,
                       Sigmafield<:AbstractFloat} <:Abm.AbstractAgent
    id::Posfield
    pos::Posfield
    old_o::Ofield
    new_o::Ofield
    old_σ::Sigmafield
    new_σ::Sigmafield
    r::Ofield
end

#the params of an empty agent
#(maybe use Parameters here, it would indeed simplify things)
const unitparams = NamedTuple{(:id, :pos, :old_o, :new_o,
                               :old_σ, :new_σ,:r)}((0, 0, big(0.0), big(0.0),
                                                    big(2.0), big(2.0),big(0.0)))
function Agent_o()
    Agent_o(unitparams...)
end

space(n::Int, graph) = Abm.GraphSpace(graph(n))
space(n) = space(n, LG.complete_graph)

function model(agentype, myspace, scheduler, p = 0.3)
    Abm.ABM(agentype, myspace, scheduler = scheduler,
            properties = Dict(:p => p))
end

model(n, p) = model(typeof(Agent_o()), space(n), Abm.by_id, p)

function emptypop(agent_type, n::Int)
    Vector{agent_type}(undef, n)
end

function opinionarray(interval, n, distribution = Dist.Uniform)
    opinions = Vector{BigFloat}(undef, n)
    @. opinions = big(rand(distribution(interval[1], interval[2])))
    return (opinions)
end

o(a::Agent_o) = a.old_o
σ(a::Agent_o) = a.old_σ

const centralagentpos = 1
const probeagentpos = 2

function fillpop!(pop, opinionarray, sigma, probeo,
                  agent_type = typeof(Agent_o()),
                  centralagentpos = centralagentpos,
                  probeagentpos = probeagentpos)
    # special agents constants
    poplen = length(pop)

    centralagent_fieldvalues = NamedTuple{(:id, :pos, :old_o,
                                           :new_o, :old_σ,
                                           :new_σ, :r)}((centralagentpos,
                                                         centralagentpos,
                                                         big(0.0), big(0.0),
                                                         big(1.0), big(1.0),
                                                         big(0.0)))

    probeagent_fieldvalues = NamedTuple{(:id, :pos, :old_o,
                                         :new_o, :old_σ,:new_σ,
                                         :r)}((probeagentpos, probeagentpos,
                                               big(probeo), big(probeo), big(1.0),
                                               big(1.0), big(0.0)))

    # special agents initialization
    pop[centralagentpos] = agent_type(centralagent_fieldvalues...)

    pop[probeagentpos] = agent_type(probeagent_fieldvalues...)

    # normal agents initialization
    for i = probeagentpos+1:poplen
        pop[i] = agent_type(i, i, opinionarray[i], opinionarray[i], sigma, sigma,
        big(0.0))

    end


    # agents actual r initialization
    for i = centralagentpos+1:poplen
        setr = (o(pop[i]) - o(pop[1])) / σ(pop[1])
        pop[i].r = setr
    end
 # (o(pop[i]) - o(pop[1])) / σ(pop[1])


    return(pop)
end

function createpop(agent_type, n, sigma, interval, probeo)
    fillpop!(emptypop(agent_type, n), opinionarray(interval, n), sigma, probeo)
end

function fillmodel!(m, population)
    for i = 1:length(population)
        Abm.add_agent!(population[i], i, m)
    end
    return (m)
end

function getjtointeract(a, m = m)
    m[rand(Abm.node_neighbors(a, m))]
end

# not okay the type stability here
function getjstointeract(m)::Vector{Agent_o}
    js = Vector{typeof(m[1])}(undef, Abm.nv(m))
    for i in Abm.nodes(m)
        js[i] = getjtointeract(i, m)
    end
    return (js)
end

function changingterm★(i, j)
    -(o(i) - o(j))^2 / (2 * σ(i)^2) # * Possible source of instability here
end

function calculatep★(p::AbstractFloat, i, j)
    cterm = changingterm★(i, j)
    num = p * (1 / (√(2 * π) * σ(i))) * exp(cterm) # * Another source of instability
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

function xr(a, m)
    central_agent = m[1]
    xᵣₐ = (o(a) - o(central_agent)) / σ(central_agent) # * Another source
end


function xr!(a, m)
    central_agent = m[1]
    xᵣₐ = (o(a) - o(central_agent)) / σ(central_agent) # * Another source
    a.r = xᵣₐ
end


function model_initialize(;
                          nagents = 200,
                          σ = big(1.0),
                          interval = (-20, 20),
                          agent_type = Agent_o,
                          probeo= 0.25,
                          p = 0.3)
    m = model(nagents, p)
    population = createpop(agent_type, nagents, σ, interval, probeo)
    fillmodel!(m, population)
    return (m)
end


function agent_step!(a, m)
    p = m.p
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
        agent = model[i]
        updateold(agent)
        xr!(agent, model)
    end
end

mutable struct Agent_o{
    Posfield <: Int,
    Ofield <: AbstractFloat,
    Sigmafield <: AbstractFloat} <: Abm.AbstractAgent
    id::Posfield
    pos::Posfield
    o::Ofield
    σ::Sigmafield 
end

Agent_o() = Agent_o(0,0,0., 2.)

space(n::Int, graph) = Abm.Space(graph(n))
space(n) = space(n, LG.complete_graph)

function model(agentype, myspace, scheduler)
    Abm.ABM(agentype, myspace,  scheduler = scheduler)
end

myscheduler(m) = Abm.keys(m.agents)
model(n) = model(Agent_o, space(n), myscheduler)

function emptypop(agent_type, n::Int)
    Vector{typeof(agent_type())}(undef,n)
end

function opinionarray(interval, n , 
        distribution = Dist.Uniform)
    opinions = Vector{Float64}(undef, n)
   @. opinions = rand(distribution(interval[1], interval[2]))
    return(opinions)
end

function fillpop!(pop,  opinionarray, σ,
        agent_type = Agent_o)  
    poplen = length(pop)
    for i in 1:poplen
        pop[i] = agent_type(i,i,opinionarray[i], σ)
    end
    return(pop)
end

    
function createpop(agent_type,n, σ, interval) 
    fillpop!(emptypop(agent_type, n), 
        opinionarray(interval, n),  σ)
end

# createpop(n) = createpop(Agent_o, 2, (-5, 5),n)
function fillmodel!(m, population) 
    for i in 1:length(population)
        Abm.add_agent!(population[i], i, m)
    end
    return(m)
end 

function fillmodel!(m, n, σ, interval, agent_type = Agent_o ) 
    population = createpop(agent_type,n, σ, interval) 
    for i in 1:n
        Abm.add_agent!(population[i], i, model)
    end
    return(m)
end 

function getjtointeract(a, m)
    Abm.id2agent(rand(Abm.node_neighbors(a,m)),m)
end

# not okay the type stability here
function getjstointeract(m)
    js = Vector{typeof(Abm.id2agent(1,m))}(undef, Abm.nv(m))
    for i in Abm.nodes(m)
    js[i] = getjtointeract(i, m)
    end
    return(js)
end

getopinion(a) = a.o
o(a) = getopinion(a)
getσ(a) = a.σ
σ(a)= getσ(a) 

function changingterm★(i,j) 
-(o(i) - o(j))^2 / (2 *σ(i)^2) 
end

function calculatep★(p::AbstractFloat, i, j) 
    cterm =  changingterm★(i,j)
    num = p * (1 / (√(2 * π) * σ(i))) * exp(cterm)
    denom = num + (1 - p)
    pstar  = num / denom
    return(pstar)
end

function calc_posterior_o(p★,i, j) 
    p★ * ((o(i) +o(j)) / 2) + (1 - p★) * o(i)
end

function update_o!(i,  posterior_o)
    i.o  = posterior_o
    nothing
end

function update_sigma!(i, posterior_sigma)
    i.σ = posterior_sigma
    nothing
end

function calcσ★(p★, i,j)
    √(σ(i)^2 * (1 - p★/2) + p★ * (1 - p★) * ((o(i) - o(j))/2)^2)
end

calcr(sigmastar, oldsigma) = sigmastar/oldsigma

function model_initialize(;n= 200,
        σ = 2.,
        interval =  (-5, 5),
        agent_type = Agent_o)
    m = model(n)
    population = createpop(agent_type, n,  σ, interval)
    fillmodel!(m, population)
    return(m)
end

function pudley_step!(m, p = 0.9 )
    js = deepcopy(getjstointeract(m))
    for i in Abm.nodes(m)
        a = Abm.id2agent(i,m)
        b = js[i]
        p★ = calculatep★(p, a, b)
        σ★ = calcσ★(p★, a, b)
        newo = calc_posterior_o(p★,a, b) / calcr(σ★, σ(a))
        update_o!(a, newo)
        update_sigma!(a, σ★)
    end
end

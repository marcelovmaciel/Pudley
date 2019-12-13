mutable struct Agent_o{
    Posfield <: Int,
    Ofield <: AbstractFloat,
    Sigmafield <: AbstractFloat} <: Abm.AbstractAgent
    id::Posfield
    pos::Posfield
    o::Ofield
    σ::Sigmafield 
end

function sampleopinion(
        interval::Tuple{Number, Number}, 
        distribution = Dist.Uniform) 
    #BigFloat may be needed
    rand(distribution(
                interval[1], 
                interval[2]))
end

Agent_o() = Agent_o(0,0,0., 2.)

space(n::Int, graph) = Abm.Space(graph(n))
space(n) = space(n, LG.complete_graph)

model(agentype, myspace, scheduler) = Abm.ABM(agentype, myspace, scheduler = scheduler)

model(n) = model(Agent_o, space(n), Abm.fastest)

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
function fillmodel!(model, pop) 
    for i in 1:length(pop)
        Abm.add_agent!(pop[i], i, model)
    end
    return(model)
end 

function fillmodel!(model, n, σ, interval, agent_type = Agent_o ) 
    pop = createpop(agent_type,n, σ, interval) 
    for i in 1:n
        Abm.add_agent!(pop[i], i, model)
    end
    return(model)
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
    num = p * (1 / (sqrt(2 * π ) * σ(i))) * exp(cterm)
    denom = num + (1 - p)
    pstar  = num / denom
    return(pstar)
end

function calc_posterior_o(p★,i, j) 
    p★ * ((o(i) +o(j) / 2) + (1 - p★) * o(i))
end

function update_o!(i,  posterior_o)
    i.o  = posterior_o
    nothing
end

function update_sigma!(i, posterior_sigma)
    i.σ = posterior_sigma
    nothing
end

function σtplus1(pstar, i,j)
    ((σ(i) * (1 - pstar/2) + pstar * (1 - pstar) * (o(i) - o(j)))/2)^2
end

calcr(sigmastar, oldsigma) = sigmastar/oldsigma

function model_initiation(;n= 200,
        σ = 2., 
        interval =  (-5, 5),
        agent_type = Agent_o)
    m = model(n)
    p= createpop(agent_type, n,  σ, interval)
    fillmodel!(m, p)
    return(m)   
end

function pudley_step!(m, p = 0.9 )
    js = getjstointeract(m)
    for i in Abm.nodes(m)
        a = Abm.id2agent(i,m)
        b = js[i]
        p★ = calculatep★(p, a, b)
        sigmatplus1 = σtplus1(p★, a, b)
        newo = calc_posterior_o(p★,a, b) 
        update_o!(a, newo)
        update_sigma!(a, sigmatplus1)
    end
end
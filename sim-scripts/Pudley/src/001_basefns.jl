#Structs for Agents and Beliefs --------------------

#Those abstract types are for later refactoring
abstract type  AbstractAgent end
#abstract type AbstractBelief end
#abstract type AgentAttribute end

"Concrete type for Agents' beliefs; comprised of opinion, uncertainty and an id (whichissue)"
mutable struct Belief{T1 <: Real}
    o::T1
    σ::T1
end


"""
    mutable struct Agent_o{T1 <: Integer, T2 <: Vector, T3 <: Real,
                       T4 <: Vector, T5 <: Tuple} <: AbstractAgent

Concrete type for an Agent which only change its opinion.

Fields:
 - id::Integer
 - ideo:: Vector
 - idealpoint::Real

"""
mutable struct Agent_o{T1 <: Integer, T2 <: Belief} <: AbstractAgent
    id::T1
    b::T2
end


"Belief(σ::T1, whichissue::T2,
         paramtuple::T3) where {T1 <: Real, T2 <: Integer, T3 <: NamedTuple}"
function Belief(σ::T1, interval::T2) where {T1 <: Real, T2<:Tuple}
    #maybe this should be inside the constructor ?? think about that...
    o = rand(Dist.Uniform(interval[1],interval[2]))
    return(Belief(o, σ))
end

"Agent_oσ(n_issues::Tint, id::Tint, σ::Treal,
           paramtuple::TNT) where {Tint <: Integer, Treal <: Real, TNT <: NamedTuple}"
function Agent_o(id::Tint, σ::Treal, interval::Tinter) where {Tint <: Integer,
                                                       Treal <: Real,
                                                       Tinter <: Tuple}
    b = Belief(σ, interval)
    return(Agent_o(id,b))
end


Agent_o() = Agent_o(1,0.1, (-5, 5))

 
"""
    createpop(agent_type::Type{Agent_o}, σ::Real,
    n_issues::Integer, size::Integer)::Vector{Agent_o}

Creates a  vector of agents of type Agent_o
"""
function createpop(agent_type, σ::Real, interval::Tuple,size::Integer)
    population = Array{typeof(agent_type())}(undef, size)
    for i in 1:size
        population[i] = agent_type(i,σ,interval)
    end
    return(population)
end


function getjtointeract(i::AbstractAgent,  population)
    whichj = rand(population)
    if whichj == i
        getjtointeract(i,population)
    else
        return(whichj)
    end
end

changingterm★(i,j) = (-((i.b.o - j.b.o)^2 / (2*i.b.σ^2)))


function calculatep★(i::AbstractAgent, j::AbstractAgent,
                  p::AbstractFloat)
    cterm =  changingterm★(i,j)
    num = p * (1 / (sqrt(2 * π ) * i.b.σ ) ) * exp(cterm)
    denom = num + (1 - p)
    pstar  = num / denom
    return(pstar)
end

"""
    calc_posterior_o(i_belief::Belief, j_belief::Belief, p::AbstractFloat)

Helper for update_step
Input = beliefs in an issue and confidence paramater; Output = i new opinion
"""
calc_posterior_o(i_belief::Belief, j_belief::Belief, p★::AbstractFloat) = (p★ *
                                                         ((i_belief.o + j_belief.o) / 2) +
                                                         (1 - p★) * i_belief.o )

"""
    update_o!(i::AbstractAgent, which_issue::Integer, posterior_o::AbstractFloat)

 update_step for changing opinion but not belief

"""
function update_o!(i::AbstractAgent,  posterior_o::AbstractFloat)
    i.b.o = posterior_o
    nothing
end

"""
    updateibelief!(i::Agent_o, population, p::AbstractFloat )

Main update fn; has two methods depending on the agent type

"""
function updateijbelief!(i::Agent_o, population,
                 p::AbstractFloat, ★calculator::Function)

    j = getjtointeract(i,population)
    p★ = ★calculator(i, j, p)
    copyib = Belief(i.b.o, i.b.σ)
    newsigma = (1 - p★/2) + p★*(1-p★)*((i.b.o - j.b.o)/2)^2
    update_o!(i, calc_posterior_o(i.b,j.b, p★))
    update_o!(j, calc_posterior_o(j.b, copyib, p★))
    return(newsigma)
end

function updatesigma!(i, nsigma)
    i.b.o = (i.b.o/ sqrt(nsigma))
end

function updatepopsigma!(population, nsigma)
    map(x -> (updatesigma!(x, nsigma)), population)
end


function updatepop!(pop, iterations, p )
    for iteration in 1:iterations
        ns = updateijbelief!(rand(pop), pop,
                             p, calculatep★)
        updatepopsigma!(pop, ns)
    end
end



# Types needed for the simulation

"Parameters for the simulation; makes the code cleaner"
Param.@with_kw struct PoodlParam{R<:Real}
    size_nw::Int = 2
    p::R = 0.9
    σ::R = 0.1
    time::Int = 2
#    ρ::R = 0.01
    agent_type = Agent_o
    graphcreator::Function = LG.CompleteGraph
#   propintransigents::R = 0.1
#   intranpositions::String = "random"
    p★calculator::Function = calculatep★
end



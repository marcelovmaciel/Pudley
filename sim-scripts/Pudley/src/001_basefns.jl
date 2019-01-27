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

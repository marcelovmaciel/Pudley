import Pkg

import Statistics, Distributions
Stats,Dist = Statistics, Distributions
#Those abstract types are for later refactoring

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


"This fn extracts a list of properties from another list.
If we have a container of composite types with field :o it will return a list of the :os."
function getpropertylist(list::Vector, whichproperty::Symbol)
    ((fieldcount(eltype(list)) > 0) ||
      throw(ArgumentError( "can't get a propertyfrom a type without fields ")))
    apropertylist = similar(list, fieldtype(eltype(list), whichproperty))
    for (keys, values) in enumerate(list)
       apropertylist[keys] = getfield(values, whichproperty)
    end
    return(apropertylist)
end

"calculatemeanopinion(ideology) = getpropertylist(ideology, :o) |> Stats.mean"
calculatemeanopinion(ideology) = getpropertylist(ideology, :o) |> Stats.mean

Agent_o() = Agent_o(1,1,0.1,(head = 0., tail = 1.0))

#Agent_o()
"""
     createbetaparams(popsize::Integer)

Creates a list of parameters for posterior instantiation of Belief
"""
function createdistparams(popsize::Integer, distrange)
    popsize >= 2 || throw(DomainError(popsize, "popsize must be at least 2"))
    αs = range(1.1,  length = popsize , stop = 100) |> RD.shuffle
    βs = range(1.1, length = popsize , stop = 100) |> RD.shuffle
    betaparams = zip(αs,βs) |> x -> [(α = i[1], β = i[2]) for i in x]
end

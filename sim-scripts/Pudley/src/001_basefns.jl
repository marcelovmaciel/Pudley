#Structs for Agents and Beliefs --------------------

#Those abstract types are for later refactoring
abstract type  AbstractAgent end
#abstract type AbstractBelief end
#abstract type AgentAttribute end

"Concrete type for Agents' beliefs; comprised of opinion, uncertainty and an id (whichissue)"
mutable struct Belief{T1 <: Real, T2 <: Integer}
    o::T1
    σ::T1
    whichissue::T2
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
mutable struct Agent_o{T1 <: Integer, T2 <: Vector, T3 <: Real} <: AbstractAgent
    id::T1
    ideo::T2
    idealpoint::T3
end


"Belief(σ::T1, whichissue::T2,
         paramtuple::T3) where {T1 <: Real, T2 <: Integer, T3 <: NamedTuple}"
function Belief(σ::T1, whichissue::T2) where {T1 <: Real, T2 <: Integer}
    #maybe this should be inside the constructor ?? think about that...
    (0 < σ <= 1) || throw(DomainError(σ, "σ must be between 0 and 1"))
    o = rand(Dist.Uniform(-5,5))
    return(Belief(o, σ, whichissue))
end



"Agent_oσ(n_issues::Tint, id::Tint, σ::Treal,
           paramtuple::TNT) where {Tint <: Integer, Treal <: Real, TNT <: NamedTuple}"
function Agent_o(n_issues::Tint, id::Tint, σ::Treal) where {Tint <: Integer, Treal <: Real}
    ideology = [Belief(σ, issue) for issue in 1:n_issues ]
    idealpoint = calculatemeanopinion(ideology)
    return(Agent_o(id,ideology, idealpoint))
end

Agent_o() = Agent_o(1,1,0.1)


#=
this functions generalizes what i was previously doing with create_idealpoint.
That is, with createidealpoint i apply some measure to a list of attributes from the items of another list.
The latter is what this fn does.
=#
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
 

"""
    createpop(agent_type::Type{Agent_o}, σ::Real,
    n_issues::Integer, size::Integer)::Vector{Agent_o}

Creates a  vector of agents of type Agent_o
"""
function createpop(agent_type,
            σ::Real,  n_issues::Integer, size::Integer)
    population = Array{typeof(agent_type())}(undef, size)
    for i in 1:size
        population[i] = agent_type(n_issues, i,σ)
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

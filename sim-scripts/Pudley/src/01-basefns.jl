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

#import Distributions
#const  Dist = Distributions

"function Belief(σ::T, interval::T2) where {T1 <: Real, T2 <: NamedTuple}"
function Belief(σ::T1, whichissue::T2, interval::T3) where {T1 <: Real, T2 <:Integer, T3 <: NamedTuple}
    o = rand(Dist.Uniform(interval.head,interval.tail))
    return(Belief(o, σ, whichissue))
end

#Belief(0.1, 1, (head = 0.0, tail = 1.0 ))
"""
    mutable struct Agent_o{T1 <: Integer, T2 <: Vector, T3 <: Real,
                       T4 <: Vector, T5 <: Tuple} <: AbstractAgent

Concrete type for an Agent which only change its opinion.

Fields:
 - id::Integer
 - ideo:: Vector
 - idealpoint::Real
 - neighbors::Vector
 - certainissues::Vector
 - certainparams::NamedTuple

"""
mutable struct Agent_o{T1 <: Integer, T2 <: Vector, T3 <: Real,
                       T4 <: Vector, T5 <: NamedTuple} <: AbstractAgent
    id::T1
    ideo::T2
    idealpoint::T3
    neighbors::T4
    certainissues::T4
    certainparams::T5
end


"Agent_o(n_issues::Tint, id::Tint, σ::Treal,
           paramtuple::TNT) where {Tint <: Integer, Treal <: Real, TNT <: NamedTuple}"
function Agent_o(n_issues::Tint, id::Tint, σ::Treal,
           paramtuple::TNT) where {Tint <: Integer, Treal <: Real, TNT <: NamedTuple}
    ideology = [Belief(σ, issue, paramtuple) for issue in 1:n_issues ]
    idealpoint = calculatemeanopinion(ideology)
    return(Agent_o(id,ideology, idealpoint,[0], [0], paramtuple))
end


Agent_o() = Agent_o(1,1,0.1,(head = 0., β = 1.0))

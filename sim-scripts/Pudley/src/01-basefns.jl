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

getbelief(foo::Agent_o) = foo.b

getopinion(b::Belief) = b.o

getσ(b::Belief) = b.σ

function getjtointeract(population, i::AbstractAgent)
    whichj = rand(filter(x-> x != i,population))
    return(i,whichj)
end


#fix the allocs later
getpairs(pop) = Curry.partial(getjtointeract, pop::Vector).(pop)::Vector


changingterm★(i,j) = /(-((getopinion ∘ getbelief)(i) - (getopinion ∘ getbelief)(j))^2,
                         (2 * (getσ ∘ getbelief)(i)^2)) 


function calculatep★( p::AbstractFloat, i::AbstractAgent, j::AbstractAgent)
    cterm =  changingterm★(i,j)
    num = p * (1 / (sqrt(2 * π ) * (getσ ∘ getbelief)(i))) * exp(cterm)
    denom = num + (1 - p)
    pstar  = num / denom
    return(pstar)
end

"""
    calc_posterior_o(i_belief::Belief, j_belief::Belief, p::AbstractFloat)

Helper for update_step
Input = beliefs in an issue and confidence paramater; Output = i new opinion
"""
calc_posterior_o( p★::AbstractFloat,
                  i_belief::Belief,
                  j_belief::Belief) = (p★ * ((getopinion(i_belief) +
                                              getopinion(j_belief)) / 2) +
                                       (1 - p★) *
                                       getopinion(i_belief))

"""
    update_o!(i::AbstractAgent, which_issue::Integer, posterior_o::AbstractFloat)

 update_step for changing opinion but not belief

"""
function update_o!(i::AbstractAgent,  posterior_o::AbstractFloat)
    i.b.o = posterior_o
    nothing
end

function update_sigma!(i::AbstractAgent,  posterior_sigma::AbstractFloat)
    i.b.σ = posterior_sigma
    nothing
end


function getp★s(pairs::Vector, p = 0.9)
    pstars = Array{Float64, 1}(undef, length(pairs))
    for (idx,pair)  in enumerate(pairs)
        pstars[idx] = calculatep★( p,pair...)
    end
    return(pstars)
end

#refacroe tthis later
function calc_posterior_os(pairs)
    calc_posterior_o.(getp★s(pairs),
                      first.(map(Curry.partial(map, getbelief), pairs)),
                      last.(map(Curry.partial(map,getbelief), pairs)))
end



function σtplus1(pstar, i::Agent_o,j::Agent_o)
    (getσ(getbelief(i)) * (1 - pstar/2) +
     pstar * (1 - pstar) *
     ((getopinion(getbelief(i)) - getopinion(getbelief(j)))/2)^2)
end

σtplus1(pairs) = σtplus1.(getp★s(pairs), first.(pairs), last.(pairs))

calcr(sigmastar, oldsigma) = sigmastar/oldsigma

over(pairs) = calc_posterior_os(pairs) ./ calcr.(σtplus1(pairs),
                                                 getσ.(getbelief.(first.(pairs))))


function uppudleypop!(pop)
    pairs = getpairs(pop)
    newsigma = σtplus1(pairs)
    newos = over(pairs)
    update_o!.(pop, newos)
    update_sigma!.(pop, newsigma)
end


#Those abstract types are for later refactoring

#Structs for Agents and Beliefs --------------------

#Those abstract types are for later refactoring
abstract type  AbstractAgent end
#abstract type AbstractBelief end
#abstract type AgentAttribute end

mutable struct Agent_o <: AbstractAgent
    id::Int
    pos::Int
    interval::Tuple{Real, Real}
    o::Real
    σ::Real
end

function Agent_o(id::Int, pos::Int, σ::Real, interval::Tuple{Real, Real})
    o = BigFloat(rand(Dist.Uniform(interval[1], interval[2])))
    return(Agent_o(id,pos, interval, o, σ))
end

Agent_o() = Agent_o(0,0,0.1, (-5, 5))

space(n) = Abm.Space(LG.complete_graph(n))
# emptypop(agent_type, size) = Vector{typeof(agent_type())}(undef, size)

# emptybeliefs(size) = Vector{Belief}(undef, size)

# function fillbeliefs(bfs, σ, interval)
#     bfs .= Belief(σ, interval)
# end

# createbeliefs(σ, interval, size) = fillbeliefs(emptybeliefs(size), σ, interval)

# function fillpop(pop, σ, interval)
#     size = length(pop)
#     for i in 1:size
#         pop[i] =  eltype(pop)(i, Belief(BigFloat(σ), interval))
#     end
#     return(pop)

# end

# createpop(agent_type, σ, interval, size) = fillpop(emptypop(agent_type,size), σ, interval)

# getbelief(foo) = foo.b

# getopinion(b) = b.o

# getσ(b) = b.σ


# function getjtointeract(population::Vector{T}, i::T) where T
#     whichj = rand(population)
#     if i == whichj
#         getjtointeract(population, i)
#     end
#     return(i,whichj)
# end

# emptypairs(pop) = Vector{Tuple{eltype(pop), eltype(pop)}}(undef, length(pop))
# #fix the allocs later
# function fillpairs!(pop, pairs)
#     pairs .= (i -> getjtointeract(pop, i)).(pop)
# end

# createpairs(pop) = fillpairs!(pop, emptypairs(pop))

# changingterm★(i,j) = /(-((getopinion ∘ getbelief)(i) - (getopinion ∘ getbelief)(j))^2,
#                          (2 * (getσ ∘ getbelief)(i)^2)) 


# function calculatep★( p::AbstractFloat, i::AbstractAgent, j::AbstractAgent)
#     cterm =  changingterm★(i,j)
#     num = p * (1 / (sqrt(2 * π ) * (getσ ∘ getbelief)(i))) * exp(cterm)
#     denom = num + (1 - p)
#     pstar  = num / denom
#     return(pstar)
# end


# calc_posterior_o( p★::AbstractFloat,
#                   i_belief::Belief,
#                   j_belief::Belief) = (p★ * ((getopinion(i_belief) +
#                                               getopinion(j_belief)) / 2) +
#                                        (1 - p★) *
#                                        getopinion(i_belief))


# function update_o!(i::AbstractAgent,  posterior_o::AbstractFloat)
#     i.b.o  = posterior_o
#     nothing
# end

# function update_sigma!(i::AbstractAgent,  posterior_sigma::AbstractFloat)
#     i.b.σ = posterior_sigma
#     nothing
# end


# function getp★s(pairs::Vector, p = 0.9)
#     pstars = Array{BigFloat, 1}(undef, length(pairs))
#     for (idx,pair)  in enumerate(pairs)
#         pstars[idx] = calculatep★( p,pair...)
#     end
#     return(pstars)
# end

# #refacroe tthis later
# function calc_posterior_os(pairs)
#     calc_posterior_o.(getp★s(pairs),(getbelief ∘ first).(pairs),(getbelief ∘ last).( pairs))
# end

# function σtplus1(pstar, i::Agent_o,j::Agent_o)::BigFloat
#     (getσ(getbelief(i)) * (1 - pstar/2) +
#      pstar * (1 - pstar) *
#      ((getopinion(getbelief(i)) - getopinion(getbelief(j)))/2)^2)
# end

# σtplus1(pairs) = σtplus1.(getp★s(pairs), first.(pairs), last.(pairs))

# calcr(sigmastar, oldsigma) = sigmastar/oldsigma

# over(pairs)::Vector{BigFloat} = calc_posterior_os(pairs) ./ calcr.(σtplus1(pairs),
#                                                  getσ.(getbelief.(first.(pairs))))


# function uppudleypop!(pop)
#     pairs = createpairs(pop)
#     newsigma = σtplus1(pairs)
#     newos = over(pairs)
#     update_o!.(pop, newos)
#     update_sigma!.(pop, newsigma)
# end


#Those abstract types are for later refactoring

#Structs for Agents and Beliefs --------------------
mutable struct Agent_o <: Abm.AbstractAgent
    id::Int
    pos::Int
    interval::Tuple{Real, Real}
    o::Real
    σ::Real
end

function sampleopinion(
        interval::Tuple{Real, Real}, 
        distribution = Dist.Uniform) 
    BigFloat(rand(distribution(
                interval[1], 
                interval[2])))
end

function Agent_o(
        id::Int,
        pos::Int,
        σ::Real,
        interval::Tuple{Real, Real})
    o = sampleopinion(interval)
    return(Agent_o(id,pos, interval, o, σ))
end

Agent_o() = Agent_o(0,0,0.1, (-5, 5))

space(n, graph) = Abm.Space(graph(n))
space(n) = space(n, LG.complete_graph)

model(agentype, myspace, scheduler) = Abm.ABM(agentype, myspace, scheduler = scheduler)

model(n) = model(Agent_o, space(n), Abm.fastest)

function emptypop(agent_type, size) 
    Vector{typeof(agent_type())}(undef, size)
end

function fillpop!(pop, σ, interval)
    size = length(pop)
    for i in 1:size
        pop[i] =  eltype(pop)(i,i,σ, interval)
    end
end

function createpop(agent_type, σ, interval, size) 
    pop = emptypop(agent_type,size)
    fillpop!(pop, σ, interval)
    return(pop)
end


# function fillmodel!(model, n, σ, interval )
#     for i in 1:n
#         Abm.add_agent!(model, )

# end

# function getjtointeract(population::Vector{T}, i::T) where T
#     whichj = rand(population)s
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


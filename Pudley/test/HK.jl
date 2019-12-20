import Pkg
using Agents
using Distributions
using LightGraphs
using BenchmarkTools
using Transducers

mutable struct HKAgent{T<:AbstractFloat} <: AbstractAgent
    id::Int
    old_opinion::T
    new_opinion::T
end

myscheduler(m) = keys(m.agents)

function hk_model(;numagents = 100, ϵ=0.3)
    model = ABM(HKAgent, scheduler=myscheduler , properties = Dict(:ϵ => ϵ))
    for i in 1:numagents
        add_agent!(model, rand(), rand())
    end
    return model
end


get_old_opinion(agent)::Float64= agent.old_opinion

# function agent_step!(agent, model)
#     condition(j)= abs(get_old_opinion(agent) - get_old_opinion(j)) ≤  model.properties[:ϵ]
#     xfopinion = (Filter( condition ) |> Map(get_old_opinion))
#     xfbool = Keep(condition)
#     meanopinion = reduce(+, xfopinion, values(model.agents)) / reduce(+, xfbool, values(model.agents))
#     return(meanopinion) #agent.new_opinion = 
# end

function agent_step!(agent, model)
    agent.new_opinion =  mean(
        filter(j -> abs(get_old_opinion(agent) - j) < model.properties[:ϵ], 
          get_old_opinion.(values(model.agents))))
end

function model_step!(model)
    for i in keys(model.agents)
        model.agents[i].old_opinion = model.agents[i].new_opinion
    end
end


model = hk_model(numagents = 1000, ϵ=0.3)
when = map(i -> floor(Int, i),
           collect(range(0,step= 1000,stop = 20_000)))

agent_properties = [:old_opinion]
@btime  data = step!(model,
             agent_step!,model_step!,
              1_000, agent_properties, when = when) 







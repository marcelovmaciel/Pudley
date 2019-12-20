import Pkg

Pkg.activate("./Pudley")
Pkg.instantiate()
Pkg.precompile()

using Agents
using DataVoyager

mutable struct HKAgent{T <: AbstractFloat} <: AbstractAgent
    id::Int
    old_opinion::T
    new_opinion::T
end

myscheduler(m) = keys(m.agents)

function hk_model(;numagents = 100, ϵ = 0.4)
    model = ABM(HKAgent, scheduler = myscheduler, properties = Dict(:ϵ => ϵ))
    for i in 1:numagents
        o = rand()
        add_agent!(model, o, o)
    end
    return model
end

get_old_opinion(agent)::Float64 = agent.old_opinion

function boundfilter(agent,model) 
    filter(j->abs(get_old_opinion(agent) - j) < model.properties[:ϵ],
     get_old_opinion.(values(model.agents)))
end

function agent_step!(agent, model)
    agent.new_opinion = mean(boundfilter(agent,model))
end

function model_step!(model)
    for i in keys(model.agents)
        agent = id2agent(i, model)
        agent.old_opinion = agent.new_opinion
    end
end

function model_run(; numagents = 100, iterations = 50, ϵ= 0.3)
    model = hk_model(numagents = numagents, ϵ = ϵ)
    when = 0:5:iterations
    agent_properties = [:new_opinion]
    data = step!(
            model,
            agent_step!, 
            model_step!,
            iterations, 
            agent_properties,
            when = when
            ) 
    return(data)
end

data = model_run()
v = Voyager(data)
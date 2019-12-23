import Pkg

Pkg.activate("../../Pudley")
Pkg.instantiate()
Pkg.precompile()

# # HK (Hegselmann and Krause) opinion dynamics model

# This is an implementation of a simple version of the Hegselman and Krause
# [Hegselmann and Krause (2002)](http://jasss.soc.surrey.ac.uk/5/3/2.html) model.
# It is a model of opinion formation with the question: which
# parameters lead to consensus, polarization or fragmentation?

# It models interacting **groups** of agents (as opposed to interacting pairs, typical in
# the literature) in which it is assumed that if an agent disagrees too much with
# the opinion of a source of influence, the source can no longer influence the
# agent’s opinion. There is then a "bound of confidence". The model shows that the
# systemic configuration is heavily dependent on this parameter's value.

# The model has the following components:

# - A set of n Agents with opinions xᵢ in the range [0,1] as attribute; 
# - A bound ϵ in also in the range [0,1] (actually, the range of interesting results is
# approximately (0, 0.3]);
# - The update rule: at each step every agent adopts the mean of the opinions which are not
# beyond the confidence bound ( |xᵢ - xⱼ| ≤ ϵ);


# ## Core structures
# We start by defining the Agent type and initializing the model.
using Agents
using Distributions
using DataVoyager

mutable struct HKAgent{T <: AbstractFloat} <: AbstractAgent
    id::Int
    old_opinion::T
    new_opinion::T
end

myscheduler(m) = keys(m.agents)

function hk_model(;numagents = 100, ϵ = 0.4)
    model = ABM(HKAgent, scheduler = myscheduler,
                properties = Dict(:ϵ => ϵ))
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

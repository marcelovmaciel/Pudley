import Pkg

Pkg.activate("./Pudley")
Pkg.instantiate()
Pkg.precompile()

# # HK (Hegselmann and Krause) opinion dynamics model

# This is an implementation of a simple version of the Hegselman and Krause
# [Hegselmann and Krause (2002)](http://jasss.soc.surrey.ac.uk/5/3/2.html) model.
# It is a model of opinion formation with the question: which
# parameters' values lead to consensus, polarization or fragmentation?

# It models interacting **groups** of agents (as opposed to interacting pairs, typical in
# the literature) in which it is assumed that if an agent disagrees too much with
# the opinion of a source of influence, the source can no longer influence the
# agent’s opinion. There is then a "bound of confidence". The model shows that the
# systemic configuration is heavily dependent on this parameter's value.
# We implement it as an example of how to implement a Synchronous update schedule (http://jmckalex.org/compass/syn-and-asynch-expl.html) 
# In a Synchronous update schedule changes made to an agent are not seen by 
# other agents until the next clock tick — that is, 
# all agents update simultaneously [Wilensky 2015, p.286](https://mitpress.mit.edu/books/introduction-agent-based-modeling)


# The model has the following components:

# - A set of n Agents with opinions xᵢ in the range [0,1] as attribute; 
# - A bound ϵ in also in the range [0,1] (actually, the range of interesting results is
# approximately (0, 0.3]);
# - The update rule: at each step every agent adopts the mean of the opinions which are within
# the confidence bound ( |xᵢ - xⱼ| ≤ ϵ);


# ## Core structures
# We start by defining the Agent type and initializing the model.
# The Agent type has two fields so that we can implement the synchronous update.
using Agents
using Distributions: mean 
using DataVoyager


mutable struct HKAgent{T <: AbstractFloat} <: AbstractAgent
    id::Int
    old_opinion::T
    new_opinion::T
end


function hk_model(;numagents = 100, ϵ = 0.4)
    model = ABM(HKAgent, scheduler = fastest,
                properties = Dict(:ϵ => ϵ))
    for i in 1:numagents
        o = rand()
        add_agent!(model, o, o)
    end
    return model
end

# And some helper functions for the update rule. As there is a filter in the rule we implement it 
# outside the agent_step! method. Notice that the filter is applied to the  :old_opinion field .
get_old_opinion(agent)::Float64 = agent.old_opinion

function boundfilter(agent,model) 
    filter(j->abs(get_old_opinion(agent) - j) < model.properties[:ϵ],
     get_old_opinion.(values(model.agents)))
end

# Now we implement the agent_step! and model_step! methods. 
function agent_step!(agent, model)
    agent.new_opinion = mean(boundfilter(agent,model))
end

function model_step!(model)
    for i in keys(model.agents)
        agent = id2agent(i, model)
        agent.old_opinion = agent.new_opinion
    end
end

# From this implementation we see that to implement synchronous scheduling 
# we can define an Agent type with an old and new fields for attributes that 
# are changed through synchronous updating. In the agent_step! we use the old field
# and after updating all the agents new field we use the model_step! to update the model
# for the next iteration.

# Now we can define a method for our simulation run. 
# The parameter of interest is the :new_opinion field so we assign
# it to variable agent_properties and pass it to the step! method 
# to be collected in a DataFrame.
function model_run(; numagents = 10, iterations = 50, ϵ= 0.3)
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


# Finally we run three scenarios, collect the data and plot it.
using Plots
unicodeplots()

plotsim(data, ϵ) = plot(data[!, :step], data[!, :new_opinion],
 leg= false, group = data[!, :id], title = "ϵ = $(ϵ)")

plt_001,plt02,plt03 = map(e -> (model_run(ϵ= e), e) |>
t -> plotsim(t[1], t[2]), [0.01, 0.2, 0.3])

foreach(display, (plt001,plt02,plt03))



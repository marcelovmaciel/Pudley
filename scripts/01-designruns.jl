using Revise, DrWatson
@quickactivate :Pudley


import Pudley
const pdl = Pudley


n = 100
interval = (-10, 10)
probeo = [0.1, 0.25, 0.5]
initialconditions  = dict_list(@dict n  interval  probeo)


t = 5000
agent_properties = [:r, :old_σ, :old_o]
stepsvars =  @dict t agent_properties



for ic in initialconditions
    for repetition = 1:2
    m =  pdl.model_initialize(;ic...)
        data, _ = pdl.Abm.run!(m, pdl.agent_step!, pdl.model_step!, t, adata = agent_properties);
        name = filter(!isspace, savename(ic, "csv"; allowedtypes = typeof.(values(ic))) )
        save( datadir("sim", "testprobe", name), data)
    end
end

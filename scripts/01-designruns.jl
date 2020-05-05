using Revise, DrWatson
@quickactivate :Pudley

#add formating here

import Revise
import Pudley
const pdl = Pudley


n = 100
t = 5000
interval = (-10, 10)
agent_properties = [:r, :old_σ, :old_o]
probeo = 0.25

for repetition = 1:10
    m = pdl.model_initialize(n = n, interval = interval, probeo = probeo)
    data = pdl.Abm.run!(m, pdl.agent_step!, pdl.model_step!, t, adata = agent_properties)[1]
    pdl.threecol_iterplot(data, repetition)
end

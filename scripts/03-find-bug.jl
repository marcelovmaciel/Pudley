using Revise, DrWatson

@quickactivate :Pudley
import Pudley
const pdl = Pudley

unitparams = NamedTuple{(:id, :pos, :old_o, :new_o, :old_σ, :new_σ, :r)}((0, 0,
big(0.0), big(0.0), big(2.0), big(2.0), big(0.0)))


m = pdl.model_initialize()

foo = pdl.Agent_o()

setfield!(foo, :r , (pdl.o(foo) - pdl.o(foo)) / pdl.σ(foo))

getproperty(pdl.unitparams, :id)



interval = (-20, 20)

mean_interval(interv) = (max(interv...) + min(interv...)) / 2 

mean_interval(interval)     


typeof(pdl.Agent_o())
using Revise, DrWatson

@quickactivate :Pudley
import Pudley
const pdl = Pudley

unitparams = NamedTuple{(:id, :pos, :old_o, :new_o, :old_σ, :new_σ, :r)}((0, 0,
big(0.0), big(0.0), big(2.0), big(2.0), big(0.0)))





getproperty(pdl.unitparams, :id)

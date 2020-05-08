using Distributed
addprocs(4)
@everywhere using Revise, DrWatson

@everywhere @quickactivate :Pudley
@everywhere import Pudley
@everywhere const pdl = Pudley

@everywhere (
    nagents = 100;
    interval = (-10, 10); probeo = [0.001, 0.25, 0.5, 0.75];
    parameters = @dict nagents  interval  probeo;
    nsteps = 1000;
    agent_properties = [ :r, :old_σ, :old_o];
    name = filter(!isspace, savename(parameters, "csv"; allowedtypes = typeof.(values(parameters))))
    when = 1:25:(nsteps+1)
)

data, _  = pdl.Abm.paramscan(parameters, pdl.model_initialize;
                             adata = agent_properties, agent_step! = pdl.agent_step!,
                             model_step! = pdl.model_step!, n = nsteps, replicates = 48,
                             progress = true, parallel = true, when = when )

save(datadir("sim", "testprobe", name), data)

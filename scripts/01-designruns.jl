using Distributed
addprocs(4)
@everywhere using Revise, DrWatson

@everywhere @quickactivate :Pudley
@everywhere import Pudley
@everywhere const pdl = Pudley


@everywhere (
    nagents = 100;
    p = 0.1; 
    interval = (-10, 10); probeo = vcat(collect(LinRange(0, 2, 11)), [5., 10.]);
    parameters = @dict nagents  interval  probeo p ;
    nsteps = 1000;
    agent_properties = [ :r, :old_σ, :old_o];
    name = filter(!isspace, savename(parameters, "csv"; allowedtypes = typeof.(values(parameters))));
    when = 0:50:nsteps
)

data, _  = pdl.Abm.paramscan(parameters, pdl.model_initialize;
                             adata = agent_properties, agent_step! = pdl.agent_step!,
                             model_step! = pdl.model_step!, n = nsteps, replicates = 48,
                             progress = true, parallel = true, when = when)

paramname = filter(!isspace, savename(parameters, "bson"; allowedtypes = typeof.(values(parameters))))

safesave(datadir("parameters", "testprobe", paramname), parameters)
safesave(datadir("sim", "testprobe", name), data)

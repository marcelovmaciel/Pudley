using Distributed
addprocs(4)
@everywhere using Revise, DrWatson

@everywhere @quickactivate :Pudley
@everywhere import Pudley
@everywhere const pdl = Pudley


# @everywhere (
#     nagents = 100;
#     interval = (-10, 10); probeo = [0.001, 0.25];
#     parameters = dict_list(@dict nagents  interval  probeo);
#     nsteps = 1000;
#     agent_properties = [ :r, :old_σ, :old_o];
#     when = 1:25:(nsteps+1)
# )

# for ic in parameters
#     m =  pdl.model_initialize(;ic...)
#     data, _  = pdl.Abm.run!(m, pdl.agent_step!, pdl.model_step!, nsteps,
#                             adata = agent_properties, replicates = 48, progress = true, parallel = true, when = when )
#     name = filter(!isspace, savename(ic, "csv"; allowedtypes = typeof.(values(ic))))
#     save( datadir("sim", "testprobe", name), data)
# end


@everywhere (
    nagents = 100;
    interval = (-10, 10); probeo = vcat(collect(LinRange(0, 2, 11)), [5., 10.]);
    parameters = @dict nagents  interval  probeo;
    nsteps = 1000;
    agent_properties = [ :r, :old_σ, :old_o];
    name = filter(!isspace, savename(parameters, "csv"; allowedtypes = typeof.(values(parameters))));
    when = 0:50:nsteps
)

paramname = filter(!isspace, savename(parameters, "bson"; allowedtypes = typeof.(values(parameters))))
tagsave(datadir("parameters", "testprobe", paramname), parameters)


data, _  = pdl.Abm.paramscan(parameters, pdl.model_initialize;
                             adata = agent_properties, agent_step! = pdl.agent_step!,
                             model_step! = pdl.model_step!, n = nsteps, replicates = 48,
                             progress = true, parallel = true, when = when)

save(datadir("sim", "testprobe", name), data)

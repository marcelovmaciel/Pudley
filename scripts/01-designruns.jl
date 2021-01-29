
using Distributed
addprocs(3)
@everywhere using Revise, DrWatson

@everywhere @quickactivate :Pudley
@everywhere import Pudley
@everywhere const pdl = Pudley


@everywhere prb = collect(LinRange(0, 1, 11))

@everywhere function runplz(i)
    global prb
    nagents = 5000;
    p = 0.5;
    interval = (0, 1); probeo = prb[i];
    parameters = @dict nagents  interval  probeo p ;
    nsteps = 200;
    agent_properties = [ :r, :old_σ, :old_o];
    name = filter(!isspace, savename(parameters, "csv"; allowedtypes = typeof.(values(parameters))));
    when = 0:50:nsteps


    data, _  = pdl.Abm.paramscan(parameters, pdl.model_initialize;
                                 adata = agent_properties, agent_step! = pdl.agent_step!,
                                 model_step! = pdl.model_step!, n = nsteps, replicates = 48,
                                 progress = true, parallel = true, when = when)

    paramname = filter(!isspace, savename(parameters, "bson"; allowedtypes = typeof.(values(parameters))))

    safesave(datadir("parameters", "testprobe", paramname), parameters)
    safesave(datadir("sim", "testprobe", name), data)

    data = nothing

end


runplz(1)
runplz(2)
runplz(3)
runplz(4)
runplz(5)
runplz(6)
runplz(7)
runplz(8)
runplz(9)
runplz(10)

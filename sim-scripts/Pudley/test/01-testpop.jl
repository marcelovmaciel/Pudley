import Pkg

#Pkg.add("Revise")

import Revise

Pkg.activate("../../Pudley")
Pkg.instantiate()

import Pudley, Pandas, Seaborn
const pdl = Pudley
const pd = Pandas
const sns = Seaborn
using Curry

pop = pdl.createpop(pdl.Agent_o, 0.1, (0.0, 1.0), 500)

opinions = (sns.distplot ∘ pd.DataFrame ∘
            partial(map,(pdl.getopinion ∘ pdl.getbelief)))(pop)


pairs = pdl.getpairs(pop)

       



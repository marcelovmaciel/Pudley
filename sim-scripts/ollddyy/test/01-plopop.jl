import Pkg

Pkg.activate("../../Pudley")
Pkg.instantiate()
foreach(Pkg.add, ("PyPlot", "Pandas",
                  "DataFrames", "Seaborn"))

import Pudley

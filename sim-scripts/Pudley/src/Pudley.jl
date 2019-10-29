module Pudley

import LightGraphs, MetaGraphs, Distributions, DataFrames
import Parameters, ProgressMeter, JLD2, Random, Statistics, StatsBase, Pkg
using PyCall
import Curry


const Dist = Distributions
const DF = DataFrames
const Param = Parameters
const LG = LightGraphs
const Meter = ProgressMeter
const RD = Random
const Stats = Statistics

# package code goes here
include("01-basefns.jl")
#include("02_runfns.jl")
#include("03_analysisHelpers.jl")

end # module


include("AiMTools.jl")
include("D:\\Julia\\AiMTools_Legacy\\creds.jl")
using JSON3, DataFrames

using .AiMTools

session = Session(myHeader,myBaseURL) |> activateSession!

table = "AeSBldC"
crit = ["facId" => "0001"]

blds = makeRequest(table,crit,header) |> parseResponse



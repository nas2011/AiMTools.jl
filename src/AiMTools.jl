module AiMTools

using DataFrames, HTTP, JSON3, PrettyTables, Dates

include("core.jl")
include("dateFunctions.jl")
include("properties.jl")
include("assets.jl")

export 
#Core
header,
baseURL,
APIDtFmt,
Session,
activateSession!,
makeRequest, 
parseResponse,
queryRequest,
#DateFunctions
parseDate,
parseDateTime,
decToHrMin,
requestDate,
requestDateSpan,
parsePunchTime,
#Property
getBldgInfo,
#Assets
getActiveSerSysAssets,
getAssetStatuses,
getAssetsByBldg,
getAssetsByNum,
getAssets,
getAssetAttributes


end

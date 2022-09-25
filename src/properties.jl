#Property related functions

"""Gets everything from property table AeSBldC"""
function getBldgInfo()
    bldgTable = "AeSBldC"
    makeRequest(bldgTable,header) |> parseResponse
end
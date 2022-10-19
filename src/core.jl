global header = false
global baseURL = false
global APIDtFmt = false

using Dates

#Session Functions

"""Pass session a header as a vector of string pairs, a base url, and an optional date format string. Use the activateSession!(yourSessionHere) command to set these variables for the
session. If no date format is passed, DateFormat("y-m-dTHH:MM:SS-HH:MM") is used by default."""
struct Session
    header::Vector{Pair{String,String}}
    baseURL::String 
    APIDtFmt::DateFormat

    Session(header,baseURL) = new(header,baseURL,DateFormat("y-m-dTHH:MM:SS-HH:MM"));
    Session(header,baseURL,APIDtFmt) = new(header,baseURL,APIDtFmt);
end

function activateSession!(session::Session)
    global header = session.header
    global baseURL = session.baseURL
    global APIDtFmt = session. APIDtFmt
    return true
end



#Parsing

"Parse response takes an HTTP.Response object for a JSON response and returns a dataframe"
function parseResponse(r::HTTP.Response)
    respStr = String(r.body)
    jsObj = JSON3.read(respStr)
    resVec = jsObj.ResultSet.Results
    df = DataFrame()
    foreach(resVec) do x
        append!(df,DataFrame(x.fields), cols = :union)
    end
    return df
end


#Request Functions

"Formats criteria from vector of pairs to the necessary string for inclusion in a request"
function criteriaString(criteria::Vector{Pair{String,String}})
    parts = map(criteria) do x
        join(x,"=")
    end
    join([parts...],"&")|>
    y-> join(["&",y])|>
    y-> replace(y," "=> "%20") |>
    y-> replace(y, ":" => "%3A")
end

#Table Requests
"""
makeRequest(tableName::String,criteria::Vector{Pair{String,String}},
header::Vector{Pair{String,String}};url = baseURL,rowLimit = 10000)

Enter the table name and a vector of criteria pairs. Returns an HTTP.Response object
"""
function makeRequest(tableName::String,criteria::Vector{Pair{String,String}},
header::Vector{Pair{String,String}};url = baseURL,rowLimit = 10000)
    critStr = criteriaString(criteria)
    fullURL = join([url,"tableName=",tableName,"&rowLimit=$rowLimit",critStr])
    r = HTTP.request("GET", fullURL, header)
    body = r.body
    json = JSON3.read(body)
    size = json.ResultSet.total
    if size > rowLimit @warn "Result set $size which is larger larger than row limit, you are missing data" end
    return r
end

function makeRequest(tableName::String,criteria::Vector{Pair{String,String}}
    ;url = baseURL,rowLimit = 10000)
        critStr = criteriaString(criteria)
        fullURL = join([url,"tableName=",tableName,"&rowLimit=$rowLimit",critStr])
        r = HTTP.request("GET", fullURL, header)
        body = r.body
        json = JSON3.read(body)
        size = json.ResultSet.total
        if size > rowLimit @warn "Result set $size which is larger larger than row limit, you are missing data" end
        return r
    end


function makeRequest(tableName::String,
    header::Vector{Pair{String,String}};url = baseURL,rowLimit = 10000)
        fullURL = join([url,"tableName=",tableName,"&rowLimit=$rowLimit"])
        r = HTTP.request("GET", fullURL, header)
        body = r.body
        json = JSON3.read(body)
        size = json.ResultSet.total
        if size > rowLimit @warn "Result set is $size which is larger than row limit, you are missing data" end
        return r
end

#Query Requests

function queryRequest(queryName::String,screenName::String, criteria::Vector{Pair{String,String}},
    header::Vector{Pair{String,String}};url = baseURL,rowLimit = 10000)
        critStr = criteriaString(criteria)
        fullURL = join([url,"filterName=",queryName,"&screenName=", screenName, "&rowLimit=$rowLimit",critStr])
        r = HTTP.request("GET", fullURL, header)
        body = r.body
        json = JSON3.read(body)
        size = json.ResultSet.total
        if size > rowLimit @warn "Result set is $size which is larger than row limit, you are missing data" end
        return r
end

function queryRequest(queryName::String,screenName::String,
    header::Vector{Pair{String,String}};url = baseURL,rowLimit = 10000)
        fullURL = join([url,"filterName=",queryName,"&screenName=", screenName, "&rowLimit=$rowLimit"])
        r = HTTP.request("GET", fullURL, header)
        body = r.body
        json = JSON3.read(body)
        size = json.ResultSet.total
        if size > rowLimit @warn "Result set is $size which is larger than row limit, you are missing data" end
        return r
end
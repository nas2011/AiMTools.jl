# AiMTools

AiMTools.jl is a package for working with the AssetWorks AiM REST API. It provides core functions for making requests and turning the JSON formatted requests into DataFrames for further use.

### Getting Started

You can handle using your credentials in many different ways. One way using basic auth is to create a credential file that has the following:

```julia

myHeader = ["Authorization" => "Basic {B64Encoded(YourUsername:YourPassword)}"]
myBaseURL = {Your BaseURL for REST API}

```

Create a new session and activate it

```julia

session = Session(myHeader,myBaseURL) |> activateSession!

julia> true
```

You can pipe your session to ```activateSession!``` directly or pass it as a parameter. Either way, the ```activateSession!``` function will set your base url and your authorization for the session. You can also pass an optional ```DateFormat``` to the session for use in parsing date times if the default does not work for your needs, otherwise a default will be created for you.

After that you can begin creating requests

```julia

table = "AeSBldC"
crit = ["facId" => "0001"]
resp = makeRequest(table,crit)   # Returns an HTTP response
#=Alternative method taking an explicit header parameter
You can override the session header if you need to make a request
from a different user in an active session. =#
resp = makeRequest(table,crit,header)  
```


In general, the use pattern is to specify a table of interest, search criteria in the form of a vector of pairs and run the search. One thing of note is that the request functions also have a keyword argument of ```rowLimit``` that is set to 10,000 by default. You can override this as needed by passing ```rowLimt = {newLimit}``` and get additional data. Anytime your search query returns more rows than you accept based on the rowLimit keyword a warning will appear to tell you that you are missing data.

```julia

┌ Warning: Result set 53270 which is larger larger than row limit, you are missing data
└ @ Main.AiMTools d:\Julia\AiMTools\src\core.jl:72

```


Most likely you will be interested in the data, not the response and ```parseResponse``` is provided as a convenience to handle getting the JSON response into a DataFrame. It is set up as a single parameter function so you can directly pipe the request.

```julia

makeRequest(table,crit,header) |> parseResponse  # Returns a DataFrame of the the data returned from your query
```


The package also supports using personal queries using the same pattern:

```julia

queryRequest(queryName, screenName) |> parseResponse

#Explicit Header Version
queryRequest(queryName, screenName, header) |> parseResponse
```

### Why Do This

You are likely thinking, "Why would you do this?" 

It's just another tool in the arsenal. It has been very helpful for automating complex analyses and summaries as well as automating reports. Using PrettyTables.jl it is relatively easy to format html tables with direct links into AiM that can be very convenient. For example I have a scheduled report that sends a summary of all the notes entered for that day to me in an email. It is extremely convenient to scan these all in one spot and be able to click a link into the phase for futher investigation.

Additionally, DataFrames.jl is an exceptional tool for doing data analysis, and being my primary tool of choice for that task, this was a simple way to get data quickly into a Julia script.

With a little imagination you can see how these simple base tools can let you build up arbitrarily complex convenience and summary function.
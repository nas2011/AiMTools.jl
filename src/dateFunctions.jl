#Date Functions
"""Convenience function for parsing column to datetime. Uses a separate dateformat."""
function parseDateTime(col::Vector{String})
    dtFmt = "y-m-dTHH:MM:SS"
    map(col) do x
        stop = findlast(x->x=='-',x) -1
        DateTime(x[1:stop],dtFmt)
    end
end


"""Convenience function turns a decimal hour number to a compound period of hours and minutes for time math"""
function decToHrMin(val::Float64)
    hr = floor(val)
    minutes = (val-hr) * 60 |> floor
    return Dates.CompoundPeriod(Hour(hr),Minute(minutes))
end


"""Convenience function for transforming columns. Uses the APIDtFmt set for the session."""
function parseDate(col::Vector{<:Any})
    return Date.(col,APIDtFmt)
end

function parseDate(dtString::String)
    return Date.(dtString,APIDtFmt)
end


"""
```requestDate(date::Date)```

Formats a Date in API compliant format for use in queries.

"""
function requestDate(date::Date)
    string(date, "%2000%3A00%3A00")
end

"""
```requestDate(datetime::DateTime)```

Formats a DateTime in API compliant format for use in queries.
"""
function requestDate(datetime::DateTime)
    parts = split(string(datetime), "T")
    date = parts[1]
    timeparts = split(parts[2], ".")
    time = timeparts[1]
    newTime = replace(time, ":" => "%3A")
    return string(date, "%20", newTime)
end

"""
```requestDate(year::Int, month::Int, day::Int, hour::Int)```

Takes in year, month, day, and hour as integers and formats as API compliant format for use in queries.
***Note*** Time must be in 24hr format
"""
function requestDate(year::Int, month::Int, day::Int, hour::Int)
    @assert length(string(year)) == 4 "Must use 4 digit year"
    @assert (1 <= month <= 12) "Month must be in range 1-12"
    @assert day <= 31 "Maximum day is 31"
    vals = map([year, month, day]) do x
        lpad(x, 2, "0")
    end
    string(join(vals, "-"), "%20", lpad(hour,2,"0"), "%3A00%3A00")
end


"""
```requestDate(year::Int, month::Int, day::Int)```

Takes in year, month, and day as integers and formats as API compliant format for use in queries.
"""
function requestDate(year::Int, month::Int, day::Int)
    @assert length(string(year)) == 4 "Must use 4 digit year"
    @assert (1 <= month <= 12) "Month must be in range 1-12"
    @assert day <= 31 "Maximum day is 31"
    vals = map([year, month, day]) do x
        lpad(x, 2, "0")
    end
    string(join(vals, "-"), "%2000%3A00%3A00")
end

""" 
```requestDateSpan(date::Date)```

Takes in a Date and returns tuple of API compliant format times representing the start of the given date and the end.
""" 
function requestDateSpan(date::Date)
    start = requestDate(date)
    stop = replace(start, "%2000%3A00%3A00" => "%2023%3A59%3A59")
    return (start, stop)
end


"""Parses punch clock time to a time object"""
function parsePunchTime(col::Vector{<:Any})
    hrFmt = dateformat"HHMM"
    map(col) do x
        if !ismissing(x)
            st = lpad(x,4,"0")
            Time(st,hrFmt)
        else
            missing
        end
    end
end
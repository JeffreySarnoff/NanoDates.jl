module NanoDates

export NanoDate, UTC, LOCAL, TimeZone,
    ISONanoDateFormat,
    ndnow, ndnow_strict, ndtoday,
    date_time,
    nanodate2rata, rata2nanodate,
    nanodate2unixnanos, nanodate2unixmicros, nanodate2unixmillis, nanodate2unixseconds,
    unixnanos2nanodate, unixmicros2nanodate, unixmillis2nanodate, unixseconds2nanodate,
    firsthourofday, firstminuteofhour, firstsecondofminute, firstmillisecondofsecond,
    firstmicrosecondofmillisecond, firstnanosecondofmicrosecond,
    lasthourofday, lastminuteofhour, lastsecondofminute, lastmillisecondofsecond,
    lastmicrosecondofmillisecond, lastnanosecondofmicrosecond,
    format, parse,
    canonical,
    timestamp, reset_timekeeping,
    CapitalT, SmallCapitalT,
    SingleSpace, Underscore,
    SmallWhiteCircle, SmallWhiteStar

using Dates
using Dates: AbstractDateTime, UTC, CompoundPeriod,
    quarter, format, value, days,
    toms, tons, UTD, UTM

export AbstractDateTime,
    quarter, value, days, format

using Parsers
# using InlineStrings ambiguity

struct LOCAL <: TimeZone end

include("constants.jl")
include("nanodate.jl")
include("accessors.jl")
include("conversions.jl")
include("compare.jl")
include("interop.jl")
include("arith.jl")
include("adjusters.jl")
include("fastintmath.jl")
include("compound.jl")
include("compoundperiod.jl")
include("strings.jl")
include("dateformat.jl")
include("validargs.jl")
include("timestamp.jl")
include("io.jl")
include("ndnow.jl")
include("convertperiods.jl")
include("ranges.jl")

function __init__()
    reset_timekeeping()
end

end  # NanoDates


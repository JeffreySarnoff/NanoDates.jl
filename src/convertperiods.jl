# allow periods to be expressed in Nanoseconds
widevalue(@nospecialize(x::Period))  = Int128(Dates.value(x))
tonanos(x::Nanosecond)  = widevalue(x)
tonanos(x::Microsecond) = widevalue(x) * 1_000
tonanos(x::Millisecond) = widevalue(x) * 1_000_000
tonanos(x::Second)  = widevalue(x) * 1_000_000_000
tonanos(x::Minute)  = widevalue(x) * (1_000_000_000 * 60)
tonanos(x::Hour)    = widevalue(x) * (1_000_000_000 * (60 * 60))
tonanos(x::Day)     = widevalue(x) * (1_000_000_000 * (60 * 60 * 24))
tonanos(x::Week)    = widevalue(x) * (1_000_000_000 * (60 * 60 * 24 * 7))
tonanos(x::Month)   = widevalue(x) *  2629746000000000 # * Int(Month(1))
tonanos(x::Quarter) = widevalue(x) *  7889238000000000 # * Int(Quarter(1))
tonanos(x::Year)    = widevalue(x) * 31556952000000000 # * Int(Year(1))

tonanos(x::Time) = Int128(Dates.value(x))
tonanos(x::Date) = Int128(Dates.value(x)) * NanosecondsPerDay
tonanos(x::DateTime) = Int128(Dates.value(x)) * NanosecondsPerMillisecond
tonanos(x::NanoDate) = tonanos(x.datetime) + x.nanosecs.value

for P in AllPeriods
    @eval tonanos(::Type{$P}) = tonanos($P(1))
end

function tonanos(x::Dates.CompoundPeriod)
    isempty(x) && return 0
    mapfoldl(tonanos, +, x.periods)
end

function safeconvert(::Type{P}, x::Period) where {P<:Period}
    fld(tonanos(x), tonanos(P))
end

function safeconvert(::Type{P}, x::Dates.CompoundPeriod) where {P<:Period}
    fld(tonanos(x), tonanos(P))
end

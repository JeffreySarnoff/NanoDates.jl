Base.isone(x::Dates.Period) = isone(Dates.value(x))
Base.iszero(x::Dates.CompoundPeriod) = isempty(x)

const DatePeriod0 = Period[Year(0), Month(0), Day(0)]
const TimePeriod0 = Period[Hour(0), Minute(0), Second(0), Millisecond(0),
    Microsecond(0), Nanosecond(0)]
const DateTimePeriod0 = Period[Year(0), Month(0), Day(0),
    Hour(0), Minute(0), Second(0), Millisecond(0)]
const NanoDatePeriod0 = Period[Year(0), Month(0), Day(0),
    Hour(0), Minute(0), Second(0), Millisecond(0),
    Microsecond(0), Nanosecond(0)]

const YMD = (Year, Month, Day)
const HMS = (Hour, Minute, Second)
const McN = (Millisecond, Microsecond, Nanosecond)

const HMSs = (HMS..., Millisecond)
const HMSss = (HMS..., Millisecond, Microsecond)
const HMSsss = (HMS..., McN...)

const YMDHMS = (YMD..., HMS...)
const YMDHMSs = (YMD..., HMSs...)
const YMDHMSss = (YMD..., HMSss...)
const YMDHMSsss = (YMD..., HMSsss...)

#=
ymd(x::Date) = yearmonthday(x)
ymd(x::DateTime) = ymd(fld(value(x), 86_400_000_000_000))

function hms(x::Time)
    secs = fld(value(x), NanosecondsPerSecond)
    mins, secs = fldmod(secs, SecondsPerMinute)
    hrs, mins = fldmod(mins, MinutesPerHour)
    map((period, count)->period(count), HMS, (hrs, mins, secs))
end

hms(x::DateTime) = hms(Time(x))

ymdhms(x::DateTime) = (ymd(x)..., hms(x)...,)
ymdhms(x::Date) = ymdhms(DateTime(x))

ymdhmss(x::DateTime) = (ymd(x)..., hmss(x)...,)
ymdhmss(x::Date) = ymdhmss(DateTime(x))


periods(x::Date) =
    map((period, count)->period(count), YMD, ymd(x))

periods(x::DateTime) =
    map((period, count)->period(count), YMDHMS, yearmonthday(x))

periods(x::NanoDate) =
    map((period, count)->period(count), YMDHMSsss, ymdhmss(x))

function Base.convert(::Type{Vector{Dates.Period}}, x::Date)
    y,m,d = yearmonthday(x)
    result = similar(DatePeriod0)
    result .= (Year(y), Month(m), Day(d))
    result
end


const DateTime_periods =
    Dates.Period[Year(2000), Month(1), Day(1),
     Hour(0), Minute(0), Second(0), Millisecond(0)]
const DateTime_compound = 
    CompoundPeriod(DateTime_periods)

# Dates defines CompoundPeriod(t::Time)
Dates.CompoundPeriod(d::Date) =
    Year(d) + Month(d) + Day(d)
=#
function cps(dt::DateTime)
    ymd = trunc(dt, Day)
    hmss = cnurt(dt, Day)
    result = Period[Year(ymd), Month(ymd), Day(ymd),
                    Hour(hmss), Minute(hmss), Second(hmss), Millisecond(hmss)]
    result
end


Dates.CompoundPeriod(nd::NanoDate) =
    Year(nd) + Month(nd) + Day(nd) +
    Hour(nd) + Minute(nd) + Second(nd) +
    Millisecond(nd) + Microsecond(nd) + Nanosecond(nd)

#=
Dates.Date(yr::Year, utc::Bool=false) =
    Date(year(utc ? now(UTC) : now()))
=#

Dates.Date(mn::Month, utc::Bool=false) =
    Date(year(utc ? now(UTC) : now()), value(mn))

Dates.Date(dy::Day, utc::Bool=false) =
    Date(year(utc ? now(UTC) : now()), 1, value(dy))

function Dates.Date(cperiod::CompoundPeriod, utc::Bool=false)
    ccperiod = trunc(canonical(cperiod), Day)
    yr = year(ccperiod)
    if iszero(yr)
        result = Date(year(utc ? now(UTC) : now()))
    else
        result = Date(yr)
    end
    result += Month(month(ccperiod)-1)
    result += Day(day(ccperiod)-1)
    result
end

#=
for P in (:Hour, :Minute, :Second, :Millisecond, :Microsecond, :Nanosecond)
    @eval Dates.Date(p::$P, utc::Bool=false) = utc ? today(UTC) : today()
end
=#

#=
Dates.DateTime(yr::Year, utc::Bool=false) =
    DateTime(Date(yr, utc))
=#

Dates.DateTime(mn::Month, utc::Bool=false) =
    DateTime(Date(mn, utc))

Dates.DateTime(dy::Day, utc::Bool=false) =
    DateTime(Date(dy, utc))

for (P,Q) in ((:Hour, :Day), (:Minute, :Hour), 
              (:Second, :Minute), (:Millisecond, :Second))
  @eval function Dates.DateTime(p::$P; utc::Bool=false)
            thenanodate = trunc(NanoDate(utc ? now(UTC) : now()), $Q)
            cperiod = canonical(p)
            thenanodate + cperiod
        end
end

for P in (:Microsecond, :Nanosecond)
    @eval Dates.DateTime(p::$P, utc::Bool=false) = utc ? now(UTC) : now()
end

function Dates.Time(cperiod::CompoundPeriod)
    cperiod = canonicalize(cperiod)
    cnotused = Year(cperiod) + Quarter(cperiod) + Month(cperiod) + Week(cperiod) + Day(cperiod)
    if !isempty(cnotused)
        cperiod -= cnotused
    end
    hr = Hour(cperiod)
    result = Time(hr)
    cperiod = cperiod - hr
    result + cperiod
end

function Dates.DateTime(cperiod::CompoundPeriod, utc::Bool=false)
    ccperiod = canonical(cperiod)
    yr = year(ccperiod)
    if iszero(yr)
        result = DateTime(year(utc ? now(UTC) : now()))
    else
        result = DateTime(yr)
    end
    md = month(ccperiod)
    dy = day(ccperiod)
    result += Month(md - !iszero(md))
    result += Day(dy - !iszero(dy))
#    result += Day(day(ccperiod)-1)
    result += cnurt(ccperiod, Day)
    result
end

#=
NanoDate(yr::Year, utc::Bool=false) =
    NanoDate(DateTime(yr, utc))
=#

NanoDate(mn::Month, utc::Bool=false) =
    NanoDate(DateTime(mn, utc))

NanoDate(dy::Day, utc::Bool=false) =
    NanoDate(DateTime(dy, utc))

for (P,Q) in ((:Hour, :Day), (:Minute, :Hour), 
              (:Second, :Minute), (:Millisecond, :Second),
              (:Microsecond, :Millisecond), (:Nanosecond, :Microsecond))
  @eval function NanoDate(p::$P, utc::Bool=false)
            thenanodate = trunc(NanoDate(utc ? now(UTC) : now()), $Q)
            cperiod = canonical(p)
            thenanodate + cperiod
        end
end

function NanoDate(cperiod::CompoundPeriod, utc::Bool=false)
    ccperiod = canonical(cperiod)
    yr = year(ccperiod)
    if iszero(yr)
        result = NanoDate(year(utc ? now(UTC) : now()))
    else
        result = NanoDate(yr)
    end
    md = month(ccperiod)
    dy = day(ccperiod)
    result += Month(md - !iszero(md))
    result += Day(dy - !iszero(dy))
#    result += Day(day(ccperiod)-1)
    result += cnurt(ccperiod, Day)
    result
end

# length, iterate
Base.length(cperiod::CompoundPeriod) = length(cperiod.periods)

# reverse to process smaller period types before larger period types
Base.iterate(cperiod::CompoundPeriod) = Base.iterate(reverse(cperiod.periods))
Base.iterate(cperiod::CompoundPeriod, state) = Base.iterate(reverse(cperiod.periods), state)

function Base.:(+)(nd::NanoDate, cperiod::CompoundPeriod)
    for p in cperiod
        nd += p
    end
    nd
end
Base.:(+)(cperiod::CompoundPeriod, nd::NanoDate) = nd + cperiod

function Base.:(-)(nd::NanoDate, cperiod::CompoundPeriod)
    for p in cperiod
        nd -= p
    end
    nd
end

function Base.:(*)(a::Integer, b::CompoundPeriod)
    b = canonicalize(b)
    accum = similar(b.periods)
    for idx in eachindex(accum)
       accum[idx] = a * b.periods[idx]
    end
    CompoundPeriod(accum)
end

Base.:(*)(b::CompoundPeriod, a::Integer) = a * b

function Base.:(fld)(a::CompoundPeriod, b::Integer)
    b = canonicalize(a)
    accum = similar(a.periods)
    for idx in eachindex(accum)
       accum[idx] = fld(a.periods[idx], b)
    end
    CompoundPeriod(accum)
end

function Base.:(cld)(a::CompoundPeriod, b::Integer)
    b = canonicalize(a)
    accum = similar(a.periods)
    for idx in eachindex(accum)
       accum[idx] = cld(a.periods[idx], b)
    end
    CompoundPeriod(accum)
end

function Base.:(div)(a::CompoundPeriod, b::Integer)
    b = canonicalize(a)
    accum = similar(a.periods)
    for idx in eachindex(accum)
       accum[idx] = div(a.periods[idx], b)
    end
    CompoundPeriod(accum)
end



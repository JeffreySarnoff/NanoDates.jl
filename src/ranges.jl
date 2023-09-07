const EmptyCompoundPeriod = Day(0) + Hour(0)

Base.zero(cperiod::Dates.CompoundPeriod) = EmptyCompoundPeriod

Base.sign(cperiod::Dates.CompoundPeriod) =
    if isempty(cperiod)
       0
    else
      sign((canonical(cperiod)).periods[1])
    end

Base.abs(cperiod::Dates.CompoundPeriod) =
    if sign(cperiod) === -1
       -cperiod
    else
       cperiod
    end

Dates.value(cperiod::Dates.CompoundPeriod) =
    sum(map(tons, cperiod.periods))

Base.convert(::Type{Nanosecond}, cperiod::Dates.CompoundPeriod) =
    Nanosecond(Dates.value(cperiod))
Base.convert(::Type{Microsecond}, cperiod::Dates.CompoundPeriod) =
    Microsecond(fld(Dates.value(cperiod), 1_000))
Base.convert(::Type{Millisecond}, cperiod::Dates.CompoundPeriod) =
    Millisecond(fld(Dates.value(cperiod), 1_000_000))
Base.convert(::Type{Second}, cperiod::Dates.CompoundPeriod) =
    Second(fld(Dates.value(cperiod), 1_000_000_000))

Base.convert(::Type{Minute}, cperiod::Dates.CompoundPeriod) =
    Minute(fld(fld(Dates.value(cperiod), 1_000_000), 60_000))
Base.convert(::Type{Hour}, cperiod::Dates.CompoundPeriod) =
    Hour(fld(fld(Dates.value(cperiod), 1_000_000), 3_600_000))
Base.convert(::Type{Day}, cperiod::Dates.CompoundPeriod) =
    Day(fld(fld(Dates.value(cperiod), 24_000_000), 3_600_000))
Base.convert(::Type{week}, cperiod::Dates.CompoundPeriod) =
    Day(fld(fld(Dates.value(cperiod), 24_000_000), 25_200_000))


const InSeconds = Union{Nanosecond, Microsecond, Millisecond, Second, Minute, Hour, Day, Week}

function Base.collect(sr::StepRange{NanoDate,P}) where {P<:InSeconds}
    srspan = convert(P, sr.stop - sr.start)
    srstep = convert(P, sr.step)
    steps  = fld(Dates.value(srspan), Dates.value(srstep)) + 1
    gather = Vector{NanoDate}(undef, steps)
    for i in eachindex(gather)
        gather[i] = sr.start + (i-1) * sr.step
    end
    gather
end

Base.:(:)(a::NanoDate, b::NanoDate) = (:)(a, Day(1), b)

Dates.guess(a::NanoDate, b::NanoDate, c) = floor(Int64, (Int128(value(b)) - Int128(value(a))) / tons(c))
Dates.len(a::NanoDate, b::NanoDate, c) = Int64(div(value(b - a), tons(c)))

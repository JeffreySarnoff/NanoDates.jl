#=
import Dates: Year, Quarter, Month, Week, Day,
              Hour, Minute, Second, Millisecond, 
              Microsecond, Nanosecond,
              year, quarter, month, week, day,
              hour, minute, second, millisecond,
              microsecond, nanosecond
=#
import Dates: quarter

for (P,p) in ((:Year, :year), 
              (:Quarter, :quarter), (:Month, :month), 
              (:Week, :week), (:Day, :day), 
              (:Hour, :hour), (:Minute, :minute), (:Second, :second),
              (:Millisecond, :millisecond), 
              (:Microsecond, :microsecond), (:Nanosecond, :nanosecond))
    @eval begin
        Dates.$P(x::Dates.$P) = x
        Dates.$p(x::Dates.$P) = value(x)
  
        Dates.$P(x::CompoundPeriod) = Dates.$P(x.periods)
        Dates.$p(x::CompoundPeriod) = Dates.$p(x.periods)

        function Dates.$P(x::Vector{Period})
            idx = findfirst(v -> isa(v, $P), x)
            if isnothing(idx)
                Dates.$P(0)
            else
                x[idx]
            end
        end

        Dates.$p(x::Vector{Period}) = value(Dates.$P(x))
    end
end

function canonical(x::CompoundPeriod)
    isempty(x) && return x
    y = canonicalize(x)
    isone(length(y.periods)) && return y.periods[1]
    if !iszero(Dates.quarter(y))
       q = Quarter(y)
       y -= q
       y += convert(Month, q)
   end
   if !iszero(Dates.week(y))
       w = Week(y)
       y -= w
       y += convert(Day, y)
   end
   y
end

function canonical(x::Period)
    iszero(x) && return x
    y = canonicalize(x)
    isone(length(y.periods)) && return y.periods[1]
    if !iszero(Dates.quarter(y))
       q = Quarter(y)
       y -= q
       y += convert(Month, q)
    end
    if !iszero(Dates.week(y))
       w = Week(y)
       y -= w
       y += convert(Day, y)
    end
    y
end

# trunc a compoundperiod and cnurt

Base.trunc(x::CompoundPeriod, ::Type{Year}) = Year(canonical(x)) + Day(0)
Base.trunc(x::CompoundPeriod, ::Type{Month}) = let c = canonical(x)
    Year(c) + Month(c)
end
Base.trunc(x::CompoundPeriod, ::Type{Day}) = let c = canonical(x)
    Year(c) + (Month(c) + Day(c))
end
Base.trunc(x::CompoundPeriod, ::Type{Hour}) = let c = canonical(x)
    Year(c) + (Month(c) + Day(c) + Hour(c))
end
Base.trunc(x::CompoundPeriod, ::Type{Minute}) = let c = canonical(x)
    Year(c) + (Month(c) + Day(c) + Hour(c) + Minute(c))
end
Base.trunc(x::CompoundPeriod, ::Type{Second}) = let c = canonical(x)
    Year(c) + (Month(c) + Day(c) + Hour(c) + Minute(c) + Second(c))
end
Base.trunc(x::CompoundPeriod, ::Type{Millisecond}) = let c = canonical(x)
    Year(c) + (Month(c) + Day(c) + Hour(c) + Minute(c) + Second(c) +
     Millisecond(c))
end
Base.trunc(x::CompoundPeriod, ::Type{Microsecond}) = let c = canonical(x)
    Year(c) + (Month(c) + Day(c) + Hour(c) + Minute(c) + Second(c) +
     Millisecond(c) + Microsecond(c))
end
Base.trunc(x::CompoundPeriod, ::Type{Nanosecond}) = canonical(x)

cnurt(x::CompoundPeriod, ::Type{Nanosecond}) = let c = canonical(x)
     c - trunc(x, Nanosecond)
end
cnurt(x::CompoundPeriod, ::Type{Microsecond}) = let c = canonical(x)
     c - trunc(x, Microsecond)
end
cnurt(x::CompoundPeriod, ::Type{Millisecond}) = let c = canonical(x)
     c - trunc(x, Millisecond)
end

cnurt(x::CompoundPeriod, ::Type{Second}) = let c = canonical(x)
     c - trunc(x, Second)
end
cnurt(x::CompoundPeriod, ::Type{Minute}) = let c = canonical(x)
     c - trunc(x, Minute)
end
cnurt(x::CompoundPeriod, ::Type{Hour}) = let c = canonical(x)
     c - trunc(x, Hour)
end

cnurt(x::CompoundPeriod, ::Type{Day}) = let c = canonical(x)
     c - trunc(x, Day)
end
cnurt(x::CompoundPeriod, ::Type{Month}) = let c = canonical(x)
     c - trunc(x, Month)
end
cnurt(x::CompoundPeriod, ::Type{Year}) = let c = canonical(x)
     c - trunc(x, Year)
end

canonical(x::Time) =
Hour(x) + Minute(x) + Second(x) +
Millisecond(x) + Microsecond(x) + Nanosecond(x)



Base.isequal(x::NanoDate, y::NanoDate) =
    isequal(x.datetime, y.datetime) && isequal(x.nanosecs, y.nanosecs)

Base.isequal(x::NanoDate, y::Date) =
    isequal(x.datetime, y) && iszero(x.nanosecs)
Base.isequal(x::Date, y::NanoDate) =
    isequal(x, y.datetime) && iszero(y.nanosecs)

Base.isequal(x::NanoDate, y::DateTime) =
    isequal(x.datetime, y) && iszero(x.nanosecs)
Base.isequal(x::DateTime, y::NanoDate) =
    isequal(x, y.datetime) && iszero(y.nanosecs)

Base.isless(x::NanoDate, y::NanoDate) =
    isless(x.datetime, y.datetime) ||
    (isequal(x.datetime, y.datetime) && isless(x.nanosecs, y.nanosecs))

Base.isless(x::NanoDate, y::Date) = isless(x.datetime, y)
Base.isless(x::Date, y::NanoDate) = 
    isless(x, y.datetime) ||
    (isequal(x, y.datetime) && !iszero(y.nanosecs))

Base.isless(x::NanoDate, y::DateTime) = isless(x.datetime, y)
Base.isless(x::DateTime, y::NanoDate) = 
    isless(x, y.datetime) ||
    (isequal(x, y.datetime) && !iszero(y.nanosecs))

Base.:(==)(x::NanoDate, y::NanoDate) =
    (x.datetime == y.datetime) && (x.nanosecs == y.nanosecs)
Base.:(<)(x::NanoDate, y::NanoDate) =
    (x.datetime < y.datetime) || (x.datetime == y.datetime && x.nanosecs < y.nanosecs)
Base.:(<=)(x::NanoDate, y::NanoDate) =
    (x.datetime < y.datetime) || (x.datetime == y.datetime && x.nanosecs <= y.nanosecs)
Base.:(>)(x::NanoDate, y::NanoDate) =
    (x.datetime > y.datetime) || (x.datetime == y.datetime && x.nanosecs > y.nanosecs)
Base.:(>=)(x::NanoDate, y::NanoDate) =
    (x.datetime > y.datetime) || (x.datetime == y.datetime && x.nanosecs >= y.nanosecs)

for (T) in (:DateTime, :Date)
  @eval begin
    Base.:(==)(x::NanoDate, y::$T) = (x.datetime == y) && iszero(x.nanosecs)
    Base.:(==)(x::$T, y::NanoDate) = (x == y.datetime) && iszero(y.nanosecs)

    Base.:(<)(x::NanoDate, y::$T) = (x.datetime < y)
    Base.:(<)(x::$T, y::NanoDate) = (x < y.datetime)
    Base.:(>)(x::NanoDate, y::$T) = (x.datetime > y) || (x.datetime == y && !iszero(x.nanosecs))
    Base.:(>)(x::$T, y::NanoDate) = (x > y.datetime) 

    Base.:(<=)(x::NanoDate, y::$T) = (x < y) || (x == y)
    Base.:(<=)(x::$T, y::NanoDate) = (x < y) || (x == y)
    Base.:(>=)(x::NanoDate, y::$T) = (x > y) || (x == y)
    Base.:(>=)(x::$T, y::NanoDate) = (x > y) || (x == y)
  end
end

const AllPeriods = (:Nanosecond, :Microsecond, :Millisecond, :Second, :Minute, :Hour, :Day, :Week, :Month, :Quarter, :Year)

for P in AllPeriods
    @eval Base.isless(::Type{$P}, ::Type{$P}) = false
end

# allow period type relative duration determination
for shortidx in 1:length(AllPeriods)-1
    short = AllPeriods[shortidx]
    for longidx in shortidx+1:length(AllPeriods)
        long = AllPeriods[longidx]
        @eval Base.isless(::Type{$short}, ::Type{$long}) = true
        @eval Base.isless(::Type{$long}, ::Type{$short}) = false
    end
end

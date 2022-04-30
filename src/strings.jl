#=
    struct wrapped character constants for NanoDate formats
=#

struct SepDateTime char::Char  end
struct SepSubsecs  char::Char  end

const CapitalT   = SepDateTime('T')
const SmallT     = SepDateTime('ᴛ')
const InvisbleT  = SepDateTime(' ')
const EmptyT     = SepDateTime('⦰')         # reversed empty set 0x29b0

const Underscore       = SepSubsecs('_')
const SmallWhiteCirlce = SepSubsecs('◦')
const SmallWhiteStar   = SepSubsecs('⭒')
const SingleSpace      = SepSubsecs(' ')
const NoSeparation     = SepSubsecs('⦰')    # reversed empty set 0x29b0


# one white space 
const SpaceChar = ' '

# standin for the empty char
const EmptyChar = '⦰'       # reversed empty set 0x29b0

# separate date from time
const CapitalT = 'T'
const SmallT='ᴛ'




const TSep = SepDateTime(CapitalT)
const tSep = SepDateTime(SmallT)

const CircleSep = SepSubsecs(SmallWhiteCircle)
const UnderscoreSep = SepSubsecs(Underscore)
const StarSep = SepSubsecs(SmallWhiteStar)


#=
        make a string representation from a NanoDate
=#

function Base.string(nd::NanoDate) =
    nanodate_string(nd)

function nanodate_string(nd)
    str = string(nd.datetime)
    millis = millisecond(nd)
    nanos = value(nd.nanosecs)
    if millis == 0 && nanos != 0
        str *= ".000"
    end
    padded = ""
    if nanos != 0
        if nanos % 1_000 !== 0
            padded = lpad(nanos, 6, '0')
        else
            padded = lpad(div(nanos, 1_000), 3, '0')
        end
    end
    str * padded
end


function Base.string(nd::NanoDate; sep::Char=EmptyChar)
    if sep === EmptyChar
        nanodate_string(nd)
    else
        nanodate_string(nd, sep)
    end
end

function nanodate_string(nd, sep)
    str = string(nd.datetime)
    
    nanos = value(nd.nanosecs)
    nanos === 0 && return str
    micros, nanos = fldmod(nanos, 1_000)

    millis = millisecond(nd.datetime)
    if millis === 0 str = str * ".000" end

    if nanos === 0
        padded = sep * lpad(micros, 3, '0')
    elseif micros === 0
        padded = sep * "000" * sep * lpad(nanos, 3, '0')
    else
        padded = sep * lpad(micros, 3, '0') * sep * lpad(nanos, 3, '0')
    end
    str * padded
end

function Dates.format(nd::NanoDate, df::DateFormat=NANODATE_FORMAT; sep::CharString="")
    str = Dates.format(nd.datetime, df)
    nsubsecfields = 0
    lasttoken = df.tokens[end]
    if isa(lasttoken, Dates.DatePart) &&
       typeof(lasttoken).parameters[1] === 's'
          nsubsecfields = lasttoken.width
    end
    nanos = value(nd.nanosecs)
    iszero(nanos) && return str
    cs, ns = divrem(nanos, 1_000)
    millis = millisecond(nd.datetime)
    if nsubsecfields > 1
        str = str * sep * lpad(cs, 3, '0')
        iszero(ns) && return str
        if nsubsecfields > 2
            str = str * sep * lpad(ns, 3, '0')
        end
    end
    str
end

function Time(s::String)
    n = length(s)
    n <= 12 && return Dates.Time(s)
    timefromstring(s)
end

function timefromstring(s::String)
    dotidx = findlast(x -> x == '.', s)
    if isnothing(dotidx) || length(s) - dotidx <= 3
        return parse(Time, s)
    else
        secs, subsecs = split(s, '.')
        secs *= "." * subsecs[1:3]
        subsecs = subsecs[4:end]
        tm = parse(Time, secs)
        isubsecs = Meta.parse("1" * subsecs)
        micros, nanos = divrem(isubsecs, 1_000)
        micros = mod(micros, 1_000)
        return tm + Microsecond(micros) + Nanosecond(nanos)
    end
end

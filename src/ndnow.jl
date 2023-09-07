const NanosAtStart = time_ns()
@inline nanos_elapsed() = reinterpret(Int64, time_ns() - NanosAtStart)


UTC0::NanoDate = NanoDate(now(UTC))
LOCAL0::NanoDate = NanoDate(now())
NANOS0::UInt64 = time_ns()

NSkeep::UInt64 = zero(UInt64)
NSincr::UInt16 = zero(UInt16)

function reset_timekeeping()
    global UTC0, LOCAL0, NANOS0, NSkeep, NSincr

    NSincr = zero(UInt16)
    NSkeep = zero(UInt64)

    now_utc, now_local = now(UTC), now()
    now_ns = time_ns()

    NANOS0 = now_ns
    millis0, micronanos0 = fldmod(now_ns, 1_000_000)

    UTC0   = NanoDate(now_utc) - Nanosecond(now_ns)
    LOCAL0 = NanoDate(now_local) - Nanosecond(now_ns)
end


# --------> nonstrict (ignores rollover)

function ndnow(::Type{UTC})
    global UTC0
    millis, submillis = ndnow_ns_nonstrict()
    NanoDate(UTC0+millis, submillis)
end

function ndnow(::Type{LOCAL})
    global LOCAL0
    millis, submillis = ndnow_ns_nonstrict()
    NanoDate(LOCAL0+millis, submillis)
end

function ndnow_ns_nonstrict()
    global NSincr, NSkeep

    ns = time_ns()

    if ns > NSkeep         # this branch >98%
        NSkeep = ns
        NSincr = 0x0000
    else                   # ns >= NSkeep
        NSincr += 0x0001
        ns += NSincr
    end
    
    millis, submillis = fldmod(ns, 1_000_000)
    Millisecond(millis), Nanosecond(submillis)
end


# --------> strict (accounts for rollover)

function ndnow_strict(::Type{UTC})
    global UTC0
    millis, submillis = ndnow_ns_strict()
    NanoDate(UTC0+millis, submillis)
end

function ndnow_strict(::Type{LOCAL})
    global LOCAL0
    millis, submillis = ndnow_ns_strict()
    NanoDate(LOCAL0+millis, submillis)
end

function ndnow_ns_strict()
    global NSincr, NSkeep

    ns = time_ns()

    if ns > NSkeep                  # this branch >98%
        NSkeep = ns
        NSincr = 0x0000
    elseif ns === NSkeep            # this branch  <2%
        NSincr += 0x0001
        ns += NSincr
    else                            # almost never
        reset_timekeeping()
        ns = ndnow_ns()
    end
    
    millis, submillis = fldmod(ns, 1_000_000)
    Millisecond(millis), Nanosecond(submillis)
end


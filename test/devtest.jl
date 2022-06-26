using Dates, NanoDates
import Parsers as P

nd = NanoDate(2022, 6, 18,  12, 15, 30,  123, 456, 789);
ndstr = string(nd); ndstrlen = length(ndstr);

dfmt(::Type{NanoDate}) = "::Type{NanoDate}"
dfmt(nd::NanoDate) = "nd::NanoDate"
dfmt(x) = "unrecognized"

po1s = P.Options(stripwhitespace=true, stripquoted=true, dateformat="yyyy-mm-ddTHH:MM:SS.s");
po2s = P.Options(stripwhitespace=true, stripquoted=true, dateformat="yyyy-mm-ddTHH:MM:SS.ss");
po3s = P.Options(stripwhitespace=true, stripquoted=true, dateformat="yyyy-mm-ddTHH:MM:SS.sss");

po1n = P.Options(stripwhitespace=true, stripquoted=true, dateformat="yyyy-mm-ddTHH:MM:SS.n");
po2n = P.Options(stripwhitespace=true, stripquoted=true, dateformat="yyyy-mm-ddTHH:MM:SS.nn");
po3n = P.Options(stripwhitespace=true, stripquoted=true, dateformat="yyyy-mm-ddTHH:MM:SS.nnn");


tryxparse(::Type{NanoDate}, str::String, pos::Int64, 
          strlen::Int64, po::P.Options) =
    P.xparse(NanoDate, ndstr, pos, strlen, po1s)


tryparsed(ndstr::AbstractString) = tryparse(NanoDate, ndstr);
println((tryparsed(ndstr), ndstr))

tryxparsed(ndstr::AbstractString) = xparse(NanoDate, ndstr);
println((tryxparsed(ndstr), ndstr))



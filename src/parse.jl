# module ICS

function feed(data::String, ::Val{:UID})
    UUID(data)
end

function feed(data::String, ::Val{:SEQUENCE})
    parse(Int, data)
end

function feed(data::String, ::Val{:GEO})
    NamedTuple{(:lat, :long)}(map(x -> parse(Float64, x), split(data, ';')))
end

function feed(data::String, ::Union{Val{:DTSTART}, Val{:DTEND}, Val{:DTSTAMP}})
    len = length(data)
    if len == 8
        parse(Date, data, DateFormat("yyyymmdd"))
    elseif len == 15
        parse(DateTime, data, DateFormat("yyyymmdd\\THHMMSS"))
    elseif len == 16
        parse(DateTime, data, DateFormat("yyyymmdd\\THHMMSS\\Z"))
    end
end

function feed(data::String, ::Val{:RRULE})
    (; map(split(data, ';')) do kv
        k,v = split(kv, '=')
        val = k in ("INTERVAL", "BYMONTH", "BYMONTHDAY") ? parse(Int, v) : v
        Symbol(k) => val
    end...)
end

function feed(data::String, ::Any)
    data
end

function feed(dict::Dict, tag::String)
    body = get(dict, tag, nothing)
    body === nothing ? missing : feed(body, Val(Symbol(tag)))
end

function Base.parse(::Type{VEvent}, data::AbstractString)
    io = IOBuffer(data)
    LF = '\n'
    dict = Dict()
    lasttag = nothing
    while !eof(io)
        line = readuntil(io, LF)
        isempty(line) && continue
        if first(line) == ' '
            dict[lasttag] *= line[2:end]
        else
            n = findfirst(isequal(':'), line)
            tag = line[1:n-1]
            body = line[n+1:end]
            dict[tag] = body
            lasttag = tag
        end
    end
    summary = feed(dict, "SUMMARY")
    uid = feed(dict, "UID")
    sequence = feed(dict, "SEQUENCE")
    status = feed(dict, "STATUS")
    transp = feed(dict, "TRANSP")
    rrule = feed(dict, "RRULE")
    dtstart = feed(dict, "DTSTART")
    dtend = feed(dict, "DTEND")
    dtstamp = feed(dict, "DTSTAMP")
    categories = feed(dict, "CATEGORIES")
    location = feed(dict, "LOCATION")
    geo = feed(dict, "GEO")
    description = feed(dict, "DESCRIPTION")
    url = feed(dict, "URL")
    VEvent(summary, uid, sequence, status, transp, rrule, dtstart, dtend, dtstamp, categories, location, geo, description, url)
end

function feed(data::String, ::Val{:VERSION})
    VersionNumber(data)
end

function Base.parse(::Type{VCalendar}, data::AbstractString)
    io = IOBuffer(data)
    LF = '\n'
    dict = Dict()
    events = Vector{VEvent}()
    lasttag = nothing
    while !eof(io)
        line = readuntil(io, LF)
        isempty(line) && continue
        if line == "BEGIN:VEVENT"
            data = readuntil(io, "END:VEVENT")
            event = parse(VEvent, string(line, LF, data))
            push!(events, event)
        elseif first(line) == ' '
            dict[lasttag] *= line[2:end]
        else
            n = findfirst(isequal(':'), line)
            tag = line[1:n-1]
            body = line[n+1:end]
            dict[tag] = body
            lasttag = tag
        end
    end
    version = feed(dict, "VERSION")
    prodid = feed(dict, "PRODID")
    calscale = feed(dict, "CALSCALE")
    method = feed(dict, "METHOD")
    VCalendar(version, prodid, calscale, method, events)
end

# module ICS

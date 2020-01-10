# module ICS

using Dates
using UUIDs

const RRule = NamedTuple
const Geo = NamedTuple{(:lat, :long), Tuple{Float64, Float64}}

struct VEvent
    summary::Union{Missing,String}
    uid::Union{Missing,UUID}
    sequence::Union{Missing,Int}
    status::Union{Missing,String}
    transp::Union{Missing,String}
    rrule::Union{Missing,RRule}
    dtstart::Union{Missing,Date,DateTime}
    dtend::Union{Missing,Date,DateTime}
    dtstamp::Union{Missing,Date,DateTime}
    categories::Union{Missing,String}
    location::Union{Missing,String}
    geo::Union{Missing,Geo}
    description::Union{Missing,String}
    url::Union{Missing,String}
end

struct VCalendar
    version::Union{Missing,VersionNumber}
    prodid::Union{Missing,String}
    calscale::Union{Missing,String}
    method::Union{Missing,String}
    events::Vector{VEvent}
end

# module ICS

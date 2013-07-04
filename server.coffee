#{{{ HTTP file server
express = require 'express'
app = express()
app.use express.static __dirname
#}}}
#{{{ API handle posts
app.post '/api', (req, res) ->
  console.log req, res
  res.end()
#}}}
#{{{ API server

#}}}
#{{{ mangle kml data into json
convertKmlToJson = -> #{{{
    result = []

    extractRoutes = (xml) ->
        lines = xml.split '\n'
        routes = []
        current = {}
        for line in lines
            line.replace /<SimpleData name="([^"]*)">([^<]*)/, (_, key, val) ->
                current[key] = val if val
            line.replace /<LineString><coordinates>([^<]*)/, (_, coords) ->
                current.path = (coords.split " ").map (coord) ->
                    [lng, lat] = coord.split ","
                    [+lat, +lng]
                routes.push current
                current = {}
        routes

    extractIntersections = (xml) ->
        lines = xml.split '\n'
        intersections = []
        current = {}
        for line in lines
            line.replace /<SimpleData name="([^"]*)">([^<]*)/, (_, key, val) ->
                current[key] = val if val
            line.replace /<Point><coordinates>([^<]*)/, (_, coord) ->
                [lng, lat] = coord.split ","
                current.point = [+lat, +lng]
                intersections.push current
                current = {}
        intersections

    types =
        "0": "Dummyværdier... skal matche værdier i data"
        "1": "1.-2. klasse"
        "2": "3.-4. klasse"
        "3": "5.-6. klasse"
        "4": "7.-8. klasse"
        "5": "9.-10. klasse"

    handleArea = (routes, intersections, id) ->
        result.push
            name: routes[0].skole or id
            id: id
            routeTypes: types
            intersectionTypes: types
            routes: ({type: route.skoleruter, path: route.path} for route in routes)
            intersections: ({type: intersection.krydstype, point: intersection.point} for intersection in intersections)

    done = ->
        schoolList = {}
        result.sort (a,b) -> if a.name < b.name then -1 else 1
        for school in result
            schoolList[school.name] = school.id
            fs.writeFileSync "api/" + school.id, JSON.stringify school
        fs.writeFileSync "api/schools", JSON.stringify schoolList

    fs = require 'fs'

    (require 'glob') 'kml/*', (err, dirs) ->
      for dir in dirs
        routeXml = fs.readFileSync "#{dir}/route.kml", "utf-8"
        intersectionXml = fs.readFileSync "#{dir}/intersection.kml", "utf-8"
        handleArea (extractRoutes routeXml), (extractIntersections intersectionXml), dir.slice(4)
      done()
    #}}}
#}}}
#{{{main
app.listen process.env.PORT || 8080
convertKmlToJson()
#}}}

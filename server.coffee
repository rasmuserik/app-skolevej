# Dummy/demo server and data mangler
#
# Piece of code for development purpose, will be replaced by real backend later on.
# Does the following
#
# - mangle skolevej-data into json
# - serves local directory, including api/ which gets generated data to what would be expected from api
# - handles posts/saving of changes of data by writing it to stdout
#
#{{{ HTTP file server

express = require 'express'
app = express()
app.use express.static __dirname

#}}}
#{{{ API handle posts

app.use express.bodyParser()
app.post '/api/*', (req, res) ->
  console.log req, res
  console.log req.body
  res.end()

#}}}
#{{{ mangle kml data into json

convertKmlToJson = ->
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
        fs.mkdirSync "api" if not fs.existsSync "api"
        result.sort (a,b) -> if a.name < b.name then -1 else 1
        for school in result
            schoolList[school.name] = school.id
            fs.writeFileSync "api/" + school.id, JSON.stringify school
        fs.writeFileSync "api/schools", JSON.stringify schoolList
        console.log "created datafiles in api/"

    fs = require 'fs'

    (require 'glob') 'kml/*', (err, dirs) ->
      for dir in dirs
        routeXml = fs.readFileSync "#{dir}/route.kml", "utf-8"
        intersectionXml = fs.readFileSync "#{dir}/intersection.kml", "utf-8"
        handleArea (extractRoutes routeXml), (extractIntersections intersectionXml), dir.slice(4)
      done()

#}}}
#{{{main

port = process.env.PORT || 8080
app.listen port
console.log "starte demo-server on port " + port
convertKmlToJson()

#}}}

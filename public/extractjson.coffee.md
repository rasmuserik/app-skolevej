#  mangle kml data into json

Remember: npm install glob

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

    handleArea = (routes, intersections, id) ->
        result.push
            name: routes[0].skole or id
            id: id
            routeTypes:
                "1": "Dummyværdier... skal matche værdier i data"
                "2": "1.-3. klasse"
                "4": "4.-5. klasse"
            intersectionTypes:
                "1": "Dummyværdier... skal matche værdier i data"
                "2": "1.-3. klasse"
                "4": "4.-5. klasse"
            routes: ({type: route.skoleruter, path: route.path} for route in routes)
            intersections: ({type: intersection.krydstype, point: intersection.point} for intersection in intersections)

    done = ->
        console.log JSON.stringify result

    fs = require 'fs'

    (require 'glob') 'kml/*', (err, dirs) ->
      for dir in dirs
        routeXml = fs.readFileSync "#{dir}/route.kml", "utf-8"
        intersectionXml = fs.readFileSync "#{dir}/intersection.kml", "utf-8"
        handleArea (extractRoutes routeXml), (extractIntersections intersectionXml), dir.slice(4)
      done()

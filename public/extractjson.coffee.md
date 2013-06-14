# npm install glob

    result = []

    extractIntersections = (xml) ->
        xml

    extractRoutes = (xml) ->
        xml

    handleArea = (routes, intersections) ->
        result.push [routes, intersections]

    done = ->
        result

    fs = require 'fs'

    (require 'glob') 'kml/*', (err, dirs) ->
      for dir in dirs
        routeXml = fs.readFileSync "#{dir}/route.kml", "utf-8"
        intersectionXml = fs.readFileSync "#{dir}/route.kml", "utf-8"
        handleArea extractRoutes routeXml, extractIntersections intersectionXml
      done()

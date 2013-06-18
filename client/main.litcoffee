# ![logo](https://solsort.com/_logo.png) Skolevejseditor

Utility for editing skoleveje.

Currently just code getting to know leaflet


## Load data

    Meteor.startup ->
        doExport = ->
            ($ "#exportPopUp").remove() 
            html = '<form id="exportPopUp" method="GET" action="http://example.com/form/submit" target="_blank">'
            for school in data
                # TODO: check htmlsyntax below is correct
                id = school.id.trim()
                html += "<span class=\"exportPopUpOption\">"
                html += "<input type=\"checkbox\" id=\"popup#{id}\" name=\"#{id}\" checked />"
                html += "<label for=\"popup#{id}\">#{school.name}</label>"
                html += "</span>"
            html += '<div style="text-align:right"><input type="submit" value="Download" /></div>'
            html += '</form>'
            $popup = $ html
            ($ "#map").append($popup)
            $popup.on "submit", -> $popup.remove()




        SchoolChoice = L.Control.extend
            options: { position: 'topright' }
            onAdd: (map) -> 
                select = L.DomUtil.create 'select', "schoolselect"
                select.onmousedown = L.DomEvent.stopPropagation # https://github.com/Leaflet/Leaflet/issues/936
                select.ontouchstart = L.DomEvent.stopPropagation # https://github.com/Leaflet/Leaflet/issues/936
                select.onchange = (e) ->
                    showSchool select.selectedIndex
                select.name = "school"
                for school in data
                    option = L.DomUtil.create 'option', undefined, select
                    option.innerHTML = school.name
                select

        Button = L.Control.extend
            options: {position: 'topright' }
            initialize: (content, fn) ->
                @_content = content
                @_fn = fn
                console.log this
                # Button.prototype.initialize.call this
            onAdd: ->
                button = L.DomUtil.create 'button', 'button'
                button.innerHTML = @_content
                button.onclick = @_fn
                button
                

        routeColors = 
            0: "purple"
            1: "red"
            2: "blue"
            3: "green"
            4: "yellow"
            5: "white"

        currentSchool = undefined;
        data = undefined
        map = undefined
        items = undefined


        createStatusPopUp = ->
            statusPopUp = L.DomUtil.create 'div'

        updateStatusPopUpRoute = (e) ->
            console.log "route", e
            status = L.DomUtil.create 'div', undefined, statusPopUp
            status.innerHTML = "Kind: " +  e.target.options.routeType
            console.log status, statusPopUp
            "TODO"

        updateStatusPopUpIntersection = (e) ->
            console.log "intersection"
            "TODO"
            
        showSchool = (i) ->
            items.clearLayers()
            currentSchool = data[i]
            console.log data[i]
            for route in currentSchool.routes
                polyline = new L.Polyline route.path, 
                    color: (routeColors[route.type] or "black")
                    routeType: route.type or "type missing"

                polyline.on "click", updateStatusPopUpRoute

                polyline.addTo items
            for intersection in currentSchool.intersections
                marker = new L.Marker intersection.point, 
                    icon: L.divIcon {className: "intersection type#{intersection.type}"}
                    intersectionType: intersection.type or "type missing"

                marker.on "click", updateStatusPopUpIntersection

                marker.addTo items
            map.fitBounds items.getBounds()

        latLng2array = (latLng) -> [latLng.lat, latLng.lng]

        statusSaving = -> "TODO"
        statusSavingDone = -> "TODO"
        upload = ->
            setTimeout statusSavingDone, 2000
            console.log "TODO: upload", currentSchool
            "TODO"

        saveAndUpload = ->
            statusSaving()
            currentSchool.routes = []
            currentSchool.intersections = []
            items.eachLayer (layer) ->
                if layer.options.routeType
                    currentSchool.routes.push
                        path: layer.getLatLngs().map latLng2array 
                        type: layer.options.routeType
                if layer.options.intersectionType
                    currentSchool.intersections.push
                        type: layer.options.intersectionType
                        point: latLng2array layer.getLatLng()
            upload()

        Meteor.http.get "/data.json", (err, result) ->
            throw err if err
            window.data = data = result.data

            map = L.map 'map',
                attributionControl: false
            L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png').addTo(map);

            window.items = items = new L.FeatureGroup()
            items.addTo(map).bringToFront()

            showSchool 0

            drawControl = new L.Control.Draw
                draw:
                    marker: 
                        icon: L.divIcon {className: "intersection type1"}
                    polyline: 
                        shapeOptions:
                            color: '#0f0'
                    polygon: false
                    circle: false
                    rectangle: false
                edit: { featureGroup: items }

            map.addControl drawControl
            map.addControl new SchoolChoice() 
            map.addControl new Button "Eksportér", doExport

            map.on 'draw:created', (event) ->
                layerType = event.layerType
                layer = event.layer
                if layerType is "marker"
                    layer.addTo items
                if layerType is "polyline"
                    layer.addTo items
                console.log event

            map.on 'draw:edited draw:deleted draw:created', saveAndUpload

            createStatusPopUp()

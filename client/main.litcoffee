# ![logo](https://solsort.com/_logo.png) Skolevejseditor

Utility for editing skoleveje.

Currently just code getting to know leaflet


## Load data

    Meteor.startup ->
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

        routeColors = 
            1: "red"
            2: "blue"
            3: "green"
            4: "yellow"
            5: "white"

        currentSchool = undefined;
        data = undefined
        map = undefined
        items = undefined

        showSchool = (i) ->
            items.clearLayers()
            currentSchool = data[i]
            for route in currentSchool.routes
                (new L.Polyline route.path, 
                    color: (routeColors[route.type] or "black")
                    routeType: route.type or "type missing"
                ).addTo(items)
            for intersection in currentSchool.intersections
                marker = new L.Marker intersection.point, 
                    icon: L.divIcon {className: "intersection type#{intersection.type}"}
                    intersectionType: intersection.type or "type missing"
                marker.bindPopup "Kryds type " + intersection.type
                marker.addTo items
            layers2data()

        latLng2array = (latLng) -> [latLng.lat, latLng.lng]

        layers2data = ->
            console.log "before", (JSON.stringify currentSchool).slice(0, 800)
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
            console.log " after", (JSON.stringify currentSchool).slice(0, 800)

        Meteor.http.get "/data.json", (err, result) ->
            throw err if err
            window.data = data = result.data

            map = L.map('map').setView([55.3997225, 10.3852104], 13)
            L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png',{
                attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
                }).addTo(map);

            window.items = items = new L.FeatureGroup()
            items.addTo(map).bringToFront()

            showSchool 0

            drawControl = new L.Control.Draw
                edit: { featureGroup: items }

            map.addControl drawControl
            map.addControl(new SchoolChoice())


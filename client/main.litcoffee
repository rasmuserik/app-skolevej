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

        showSchool = (i) ->
            items.clearLayers()
            for route in data[i].routes
                (new L.Polyline route.path, {color: (routeColors[route.type] or "black")}).addTo(items)
            for intersection in data[i].intersections
                marker = new L.Marker intersection.point, 
                    icon: L.divIcon {className: "intersection type#{intersection.type}"}
                marker.bindPopup "Kryds type " + intersection.type
                marker.addTo items

        data = undefined
        map = undefined
        items = undefined

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


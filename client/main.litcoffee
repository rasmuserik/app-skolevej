# ![logo](https://solsort.com/_logo.png) Skolevejseditor

Utility for editing skoleveje.

Currently just code getting to know leaflet


## Load data

    Meteor.startup ->
        SchoolChoice = L.Control.extend
            options: { position: 'topright' }
            onAdd: (map) -> 
                select = L.DomUtil.create('select', 'schoolselect')
                select.onmousedown = L.DomEvent.stopPropagation # https://github.com/Leaflet/Leaflet/issues/936
                select.onchange = (e) ->
                    showSchool select.selectedIndex
                    console.log select, select.selectedIndex, select.options[select.selectedIndex], e
                select.name = "school"
                for school in data
                    option = L.DomUtil.create 'option', "shooloption", select
                    option.value = school.name
                    option.innerHTML = school.name
                    option.onchange = (e) ->
                        console.log "option", e
                select

        showSchool = (i) ->
            items.clearLayers()
            for route in data[i].routes
                (new L.Polyline route.path, {weight: 5, color: "blue"}).addTo(items)

        data = undefined
        map = undefined
        items = undefined

        Meteor.http.get "/data.json", (err, result) ->
            throw err if err
            data = result.data

            map = L.map('map').setView([55.3997225, 10.3852104], 13)
            L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png',{
                attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
                }).addTo(map);

            window.items = items = new L.FeatureGroup()

            #for school in data.slice(10, 11)
            #    for route in school.routes
            #        (new L.Polyline route.path, {weight: 5, color: "blue"}).addTo(items)
            showSchool 10

            items.addTo(map).bringToFront()

            drawControl = new L.Control.Draw
                edit: { featureGroup: items }

            map.addControl drawControl
            map.addControl(new SchoolChoice())

            intersection = new L.CircleMarker new L.LatLng(55.3897225, 10.3852104), 
                weight: 10
                color: "blue"
            map.addLayer intersection

            intersection2 = new L.Marker new L.LatLng(55.3997225, 10.3852104), 
                clickable: true
                draggable: true
            map.addLayer intersection2
            intersection2.bindPopup "Hello"


            #intersection = new L.CircleMarker new L.LatLng(55.369091599305875,10.455253617240372), 
            #    weight: 10
            #    color: "blue"
            #map.addLayer intersection


# ![logo](https://solsort.com/_logo.png) Skolevejseditor

Utility for editing skoleveje.

Currently just code getting to know leaflet


## Load data

    Meteor.startup ->
        SchoolChoice = L.Control.extend
            options: { position: 'top' }
            onAdd: ->
                L.DomUtil.create 'div', 'hello'

        data = Meteor.http.get "/data.json", (err, data) ->
            throw err if err
            data = data.data
    
            #map = L.map('map', {drawControl: true}).setView([55.3997225, 10.3852104], 13)
            map = L.map('map').setView([55.3997225, 10.3852104], 13)
            L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png',{
                attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
                }).addTo(map);
    
            window.items = new L.FeatureGroup()
    
            for school in data.slice(10, 11)
                for route in school.routes
                    (new L.Polyline route.path, {weight: 5, color: "blue"}).addTo(items)
    
            items.addTo(map).bringToFront()
    
            drawControl = new L.Control.Draw
                edit: { featureGroup: items }
    
            #map.addControl drawControl
            #map.addControl new SchoolChoice()
            MyControl = L.Control.extend
                options: { position: 'topright' }
                onAdd: (map) -> 
                    content = L.DomUtil.create('div', 'my-custom-control')
                    console.log "Add mycontrol", content
                    content.innerHTML = "hello"
                    content
            map.addControl(new MyControl())
    
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
    

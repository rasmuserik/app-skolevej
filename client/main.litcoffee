# ![logo](https://solsort.com/_logo.png) Skolevejseditor

Utility for editing skoleveje.

Currently just code getting to know leaflet


    Meteor.startup ->
        map = L.map('map').setView([55.3997225, 10.3852104], 15)
        L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png',{
            attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(map);

        latlngs =[new L.LatLng(55.386295025268723, 10.450133559597615), new L.LatLng(55.386264905760044, 10.450051880305967), new L.LatLng(55.386234574502474, 10.450056237566631), new L.LatLng(55.386116617854078, 10.45000935450595), new L.LatLng(55.386038784617114, 10.449912782344079), new L.LatLng(55.386026999460029, 10.449004531310745), new L.LatLng(55.386010539971899, 10.448566161069097), new L.LatLng(55.385898564991848, 10.447407185204975), new L.LatLng(55.385875043011659, 10.447322105025675), new L.LatLng(55.38567849003865, 10.44581509737051), new L.LatLng(55.385574512115561, 10.445034055568406), new L.LatLng(55.385378379777293, 10.44342815754827), new L.LatLng(55.385212355927258, 10.442238741340798), new L.LatLng(55.3850634930048, 10.441116996304412), new L.LatLng(55.385044270836019, 10.440986909596592)]
        window.path = path =  new L.Polyline latlngs, 
            weight: 5
            color: "red"

        path.addTo(map).bringToFront()
        path.on "click", (e) ->
            console.log e.latlng

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


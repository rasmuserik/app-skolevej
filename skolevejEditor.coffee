window.skolevejEditor = (mapId, apiUrl) ->

  # Utility function for changing a latLng object into a two-element array.
  latLng2array = (latLng) -> [latLng.lat, latLng.lng]

  #{{{4 State

  # Data for the current school, including routes and intersections
  currentSchool = undefined

  # Reference to the Leaflet map-object
  map = undefined

  # The layer containing the routes and intersections.
  items = undefined

  # Keep track of what kind of route/intersection will be created.
  # Whenever a route/intersection type is changed, this will also
  # be the default for newly reated ones
  defaultRouteType = undefined
  defaultIntersectionType = undefined

  # keep track of whether we are editing
  editing = undefined

  # Export popup {{{4
  #
  # Create a popup, with a form of checkboxes for each of the schools,
  # and a download-button that submits the form to _blank
  #
  # This is bound to a button created in initMap
  doExport = ->
    ($ "#exportPopUp").remove()
    html = '<form id="exportPopUp" method="GET" action="' + apiUrl + "/export" + '" target="_blank">'
    for name, id of schools
      html += "<span class=\"exportPopUpOption\">"
      html += "<input type=\"checkbox\" id=\"popup#{id}\" name=\"#{id}\" checked />"
      html += "<label for=\"popup#{id}\">#{name}</label>"
      html += "</span>"
    html += '<div style="text-align:right"><input type="submit" value="Download" /></div>'
    html += '</form>'
    $popup = $ html
    ($ "#map").append($popup)
    $popup.on "submit", -> $popup.remove()

  # Button object {{{4
  #
  # Used when creating a button for export popup (in initMap)
  Button = L.Control.extend
    options: {position: 'topright' }
    initialize: (content, fn) ->
      @_content = content
      @_fn = fn
    onAdd: ->
      button = L.DomUtil.create 'button', 'button'
      button.innerHTML = @_content
      button.onclick = @_fn
      button


  # SchoolChoice dropdown {{{4
  # with list of schools, used for changing/choosing current school
  #
  # Instantiated in initMap
  SchoolChoice = L.Control.extend
    options: { position: 'topright' }
    onAdd: (map) ->
      select = L.DomUtil.create 'select', "schoolselect"
      select.onmousedown = L.DomEvent.stopPropagation # https://github.com/Leaflet/Leaflet/issues/936
      select.ontouchstart = L.DomEvent.stopPropagation # https://github.com/Leaflet/Leaflet/issues/936
      select.onchange = (e) ->
        loadAndShowSchool select.selectedIndex
      select.name = "school"
      for name, id of schools
        option = L.DomUtil.create 'option', undefined, select
        option.innerHTML = name
      select

  # saveIndicator status message in buttom right corner {{{4
  saveIndicator = new L.Control.Attribution
    prefix: "Saving..."

  # routeColors preset colors for the route types {{{4
  routeColors =
    0: "purple"
    1: "red"
    2: "blue"
    3: "green"
    4: "yellow"
    5: "pink"

  # Status pop up with route/intersection type {{{4
  #
  # Common parts of creating popups for routes and interesections
  createPopUp = (e, types, currentType, selectFn) ->
    return if editing
    popup = L.popup()
    popup.setLatLng e.latlng
    select = L.DomUtil.create "select"
    for type, desc of types
        option = L.DomUtil.create 'option', undefined, select
        option.value = type
        option.selected = true if type is currentType
        option.innerHTML = desc
    select.onchange = (e) ->
      selectFn (Object.keys types)[e.target.selectedIndex]
      saveAndUpload()
      map.closePopup()
    popup.setContent select
    popup.openOn map

  # route-specific parts of creating a popup
  statusPopUpRoute = (e) ->
    createPopUp e, currentSchool.routeTypes, e.target.options.routeType, (type) ->
      defaultRouteType = type
      route = e.layer
      route.options.color = (routeColors[route.type] or "black")
      route.options.routeType = type

  # intersection-specific parts of creating a popup
  statusPopUpIntersection = (e) ->
    createPopUp e, currentSchool.intersectionTypes, e.target.options.intersectionType, (type) ->
      defaultIntersectionType = type
      e.layer.options.intersectionType = type

  # renderCurrentSchool - transform data into map layer {{{4
  renderCurrentSchool = () ->
    items.clearLayers()
    for route in currentSchool.routes
      polyline = new L.Polyline route.path,
        color: (routeColors[route.type] or "black")
        routeType: route.type or "type missing"

      polyline.on "click", statusPopUpRoute

      polyline.addTo items
    for intersection in currentSchool.intersections
      marker = new L.Marker intersection.point,
        icon: L.divIcon {className: "intersection type#{intersection.type}"}
        intersectionType: intersection.type or "type missing"

      marker.on "click", statusPopUpIntersection
      marker.addTo items

  # loadAndShowSchool(i) #{{{4
  #
  # download data from api for a given school, and display it on screen
  loadAndShowSchool = (i) ->
    url = apiUrl + "/" + (id for name, id of schools)[i]
    $.get url, (res) ->
      currentSchool = JSON.parse res
      renderCurrentSchool()
      map.fitBounds items.getBounds()

  # post the data to the API, while showing a "saving" indicator {{{4
  upload = ->
    map.addControl saveIndicator
    $.post "#{apiUrl}/#{currentSchool.id}", {new: JSON.stringify currentSchool}, ->
      map.removeControl saveIndicator

  # saveAndUpload {{{4
  #
  # save visual map data into the data structure, and then upload it
  saveAndUpload = ->
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
    renderCurrentSchool()
    upload()

  # initMap - initialise map{{{4
  # and add various controls etc.
  initMap = ->
    map = L.map mapId
    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png',
      attribution: '<a href="http://osm.org/copyright">OpenStreetMap</a>'
    ).addTo(map)

    items = new L.FeatureGroup()
    items.addTo(map).bringToFront()

    loadAndShowSchool 0

    map.addControl new L.Control.Draw
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
    map.addControl new SchoolChoice()
    map.addControl new Button "Eksportér", doExport

    map.on 'draw:editstart', -> editing = true
    map.on 'draw:editstop', -> editing = false
    map.on 'draw:created', (event) ->
      layerType = event.layerType
      layer = event.layer
      if layerType is "marker"
        layer.options.intersectionType = defaultIntersectionType || 1
        layer.addTo items
      if layerType is "polyline"
        layer.options.routeType = defaultRouteType || 1
        layer.addTo items
    map.on 'draw:edited draw:deleted draw:created', ->
        setTimeout saveAndUpload, 0
    map.on 'layerremove', -> map.closePopup()

  # main {{{4
  #
  # load a list of the scools, and then initialise the map
  $.get apiUrl + "/schools", (res) -> #{{{4
    window.schools = JSON.parse res
    initMap()

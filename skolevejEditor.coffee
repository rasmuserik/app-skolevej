window.skolevejEditor = (mapId, apiUrl) ->
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

  SchoolChoice = L.Control.extend
    options: { position: 'topright' }
    onAdd: (map) -> 
      select = L.DomUtil.create 'select', "schoolselect"
      select.onmousedown = L.DomEvent.stopPropagation # https://github.com/Leaflet/Leaflet/issues/936
      select.ontouchstart = L.DomEvent.stopPropagation # https://github.com/Leaflet/Leaflet/issues/936
      select.onchange = (e) ->
        showSchool select.selectedIndex
      select.name = "school"
      for name, id of schools
        option = L.DomUtil.create 'option', undefined, select
        option.innerHTML = name
      select

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

  saveIndicator = new L.Control.Attribution
    prefix: "Saving..."


  routeColors = 
    0: "purple"
    1: "red"
    2: "blue"
    3: "green"
    4: "yellow"
    5: "pink"

  currentSchool = undefined
  map = undefined
  items = undefined
  defaultRouteType = undefined
  defaultIntersectionType = undefined


  createPopUp = (e, types, currentType, selectFn) ->
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

  statusPopUpRoute = (e) ->
    createPopUp e, currentSchool.routeTypes, e.target.options.routeType, (type) ->
      defaultRouteType = type
      route = e.layer
      route.options.color = (routeColors[route.type] or "black")
      route.options.routeType = type

  statusPopUpIntersection = (e) ->
    createPopUp e, currentSchool.intersectionTypes, e.target.options.intersectionType, (type) ->
      defaultIntersectionType = type
      e.layer.options.intersectionType = type

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

  showSchool = (i) ->
    url = apiUrl + "/" + (id for name, id of schools)[i]
    console.log "url:", url
    $.get url, (res) ->
      currentSchool = JSON.parse res
      renderCurrentSchool()
      map.fitBounds items.getBounds()

  latLng2array = (latLng) -> [latLng.lat, latLng.lng]


  statusShowing = 0
  statusSaving = -> 
    ++statusShowing
    map.addControl saveIndicator if statusShowing is 1
  statusSavingDone = -> 
    --statusShowing
    map.removeControl saveIndicator if statusShowing is 0

  upload = ->
    setTimeout statusSavingDone, 2000
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
    renderCurrentSchool()
    upload()

  initMap = ->
    map = L.map mapId,
      attributionControl: false
    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png').addTo(map);

    window.items = items = new L.FeatureGroup()
    items.addTo(map).bringToFront()

    showSchool 0

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

    map.on 'draw:created', (event) ->
      layerType = event.layerType
      layer = event.layer
      if layerType is "marker"
        layer.options.intersectionType = defaultIntersectionType || 1
        layer.addTo items
      if layerType is "polyline"
        layer.options.routeType = defaultRouteType || 1
        layer.addTo items
    map.on 'draw:edited draw:deleted draw:created', saveAndUpload
    map.on 'layerremove', -> map.closePopup()

  $.get apiUrl + "/schools", (res) ->
    window.schools = JSON.parse res
    initMap()

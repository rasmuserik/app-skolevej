// Generated by CoffeeScript 1.6.2
(function() {
  window.skolevejEditor = function(mapId, apiUrl) {
    var Button, SchoolChoice, createPopUp, currentSchool, defaultIntersectionType, defaultRouteType, doExport, initMap, items, latLng2array, loadAndShowSchool, map, renderCurrentSchool, routeColors, saveAndUpload, saveIndicator, statusPopUpIntersection, statusPopUpRoute, upload;

    latLng2array = function(latLng) {
      return [latLng.lat, latLng.lng];
    };
    currentSchool = void 0;
    map = void 0;
    items = void 0;
    defaultRouteType = void 0;
    defaultIntersectionType = void 0;
    doExport = function() {
      var $popup, html, id, name;

      ($("#exportPopUp")).remove();
      html = '<form id="exportPopUp" method="GET" action="' + apiUrl + "/export" + '" target="_blank">';
      for (name in schools) {
        id = schools[name];
        html += "<span class=\"exportPopUpOption\">";
        html += "<input type=\"checkbox\" id=\"popup" + id + "\" name=\"" + id + "\" checked />";
        html += "<label for=\"popup" + id + "\">" + name + "</label>";
        html += "</span>";
      }
      html += '<div style="text-align:right"><input type="submit" value="Download" /></div>';
      html += '</form>';
      $popup = $(html);
      ($("#map")).append($popup);
      return $popup.on("submit", function() {
        return $popup.remove();
      });
    };
    Button = L.Control.extend({
      options: {
        position: 'topright'
      },
      initialize: function(content, fn) {
        this._content = content;
        return this._fn = fn;
      },
      onAdd: function() {
        var button;

        button = L.DomUtil.create('button', 'button');
        button.innerHTML = this._content;
        button.onclick = this._fn;
        return button;
      }
    });
    SchoolChoice = L.Control.extend({
      options: {
        position: 'topright'
      },
      onAdd: function(map) {
        var id, name, option, select;

        select = L.DomUtil.create('select', "schoolselect");
        select.onmousedown = L.DomEvent.stopPropagation;
        select.ontouchstart = L.DomEvent.stopPropagation;
        select.onchange = function(e) {
          return loadAndShowSchool(select.selectedIndex);
        };
        select.name = "school";
        for (name in schools) {
          id = schools[name];
          option = L.DomUtil.create('option', void 0, select);
          option.innerHTML = name;
        }
        return select;
      }
    });
    saveIndicator = new L.Control.Attribution({
      prefix: "Saving..."
    });
    routeColors = {
      0: "purple",
      1: "red",
      2: "blue",
      3: "green",
      4: "yellow",
      5: "pink"
    };
    createPopUp = function(e, types, currentType, selectFn) {
      var desc, option, popup, select, type;

      popup = L.popup();
      popup.setLatLng(e.latlng);
      select = L.DomUtil.create("select");
      for (type in types) {
        desc = types[type];
        option = L.DomUtil.create('option', void 0, select);
        option.value = type;
        if (type === currentType) {
          option.selected = true;
        }
        option.innerHTML = desc;
      }
      select.onchange = function(e) {
        selectFn((Object.keys(types))[e.target.selectedIndex]);
        saveAndUpload();
        return map.closePopup();
      };
      popup.setContent(select);
      return popup.openOn(map);
    };
    statusPopUpRoute = function(e) {
      return createPopUp(e, currentSchool.routeTypes, e.target.options.routeType, function(type) {
        var route;

        defaultRouteType = type;
        route = e.layer;
        route.options.color = routeColors[route.type] || "black";
        return route.options.routeType = type;
      });
    };
    statusPopUpIntersection = function(e) {
      return createPopUp(e, currentSchool.intersectionTypes, e.target.options.intersectionType, function(type) {
        defaultIntersectionType = type;
        return e.layer.options.intersectionType = type;
      });
    };
    renderCurrentSchool = function() {
      var intersection, marker, polyline, route, _i, _j, _len, _len1, _ref, _ref1, _results;

      items.clearLayers();
      _ref = currentSchool.routes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        route = _ref[_i];
        polyline = new L.Polyline(route.path, {
          color: routeColors[route.type] || "black",
          routeType: route.type || "type missing"
        });
        polyline.on("click", statusPopUpRoute);
        polyline.addTo(items);
      }
      _ref1 = currentSchool.intersections;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        intersection = _ref1[_j];
        marker = new L.Marker(intersection.point, {
          icon: L.divIcon({
            className: "intersection type" + intersection.type
          }),
          intersectionType: intersection.type || "type missing"
        });
        marker.on("click", statusPopUpIntersection);
        _results.push(marker.addTo(items));
      }
      return _results;
    };
    loadAndShowSchool = function(i) {
      var id, name, url;

      url = apiUrl + "/" + ((function() {
        var _results;

        _results = [];
        for (name in schools) {
          id = schools[name];
          _results.push(id);
        }
        return _results;
      })())[i];
      return $.get(url, function(res) {
        currentSchool = JSON.parse(res);
        renderCurrentSchool();
        return map.fitBounds(items.getBounds());
      });
    };
    upload = function() {
      map.addControl(saveIndicator);
      return $.post("" + apiUrl + "/" + currentSchool.id, {
        "new": JSON.stringify(currentSchool)
      }, function() {
        return map.removeControl(saveIndicator);
      });
    };
    saveAndUpload = function() {
      currentSchool.routes = [];
      currentSchool.intersections = [];
      items.eachLayer(function(layer) {
        if (layer.options.routeType) {
          currentSchool.routes.push({
            path: layer.getLatLngs().map(latLng2array),
            type: layer.options.routeType
          });
        }
        if (layer.options.intersectionType) {
          return currentSchool.intersections.push({
            type: layer.options.intersectionType,
            point: latLng2array(layer.getLatLng())
          });
        }
      });
      renderCurrentSchool();
      return upload();
    };
    initMap = function() {
      map = L.map(mapId, {
        attributionControl: false
      });
      L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png').addTo(map);
      items = new L.FeatureGroup();
      items.addTo(map).bringToFront();
      loadAndShowSchool(0);
      map.addControl(new L.Control.Draw({
        draw: {
          marker: {
            icon: L.divIcon({
              className: "intersection type1"
            })
          },
          polyline: {
            shapeOptions: {
              color: '#0f0'
            }
          },
          polygon: false,
          circle: false,
          rectangle: false
        },
        edit: {
          featureGroup: items
        }
      }));
      map.addControl(new SchoolChoice());
      map.addControl(new Button("Eksportér", doExport));
      map.on('draw:created', function(event) {
        var layer, layerType;

        layerType = event.layerType;
        layer = event.layer;
        if (layerType === "marker") {
          layer.options.intersectionType = defaultIntersectionType || 1;
          layer.addTo(items);
        }
        if (layerType === "polyline") {
          layer.options.routeType = defaultRouteType || 1;
          return layer.addTo(items);
        }
      });
      map.on('draw:edited draw:deleted draw:created', function() {
        return setTimeout(saveAndUpload, 0);
      });
      return map.on('layerremove', function() {
        return map.closePopup();
      });
    };
    return $.get(apiUrl + "/schools", function(res) {
      window.schools = JSON.parse(res);
      return initMap();
    });
  };

}).call(this);

# ![logo](https://solsort.com/_logo.png) Skolevejseditor

Utility for editing skoleveje. Documentation below is in danish, as it is target a small group of danish people to whom this is handed over.

## Indhold

- `skolevejEditor.*` script med simpel editor til skoleveje
- `server.coffee` dummy/test-server, konverterer date fra `../skolevej-odense-kommune/1.2/app/Data/kml` til json der er lettere at arbejde med, og starter en lokal server http-server, (uden database, men blot skriver gemte kortændringer til stdout)
- `index.html` eksempel på html-kode der indlejrer editoren
- `lib/` dependencies (jquery+leaflet.draw)

All code is written in coffeescript, which can also be compiled into somewhat readable javascript.

## Kørsel af demo

Installer node, og derefter:

    sudo npm install -g coffee-script
    git clone git@bitbucket.org:hammertimedk/skolevej-odense-kommune.git # privat repos, kræver adgang
    git clone https://github.com/rasmuserik/app-skolevej.git
    cd app-skolevej
    npm install
    coffee server.coffee

og navigér så til http://localhost:8080/

## Indlejring af skolevejseditor i side.

Scriptet `skolevejEditor.js` eksporterer en global funktion: `skolevejEditor(mapId, apiUrl)` hvor mapId er id på det tag i dokumentet som skal erstattes at skolevejseditoren, og apiUrl er en base-url til api'et der skal kaldes. Scriptet forventer at leaflet, leaflet.draw og jquery er loaded.

## Api

Skolevejseditoren forventer følgende rest-api

- `$API/schools` - returnerer et json object hvor nøgler er navne på skoler, og værdier er skolernes id'er
- `$API/$SCHOOL_ID` - returnere et skolevejsobjekt med data om vejtyper/klassetrin, samt ruter og kryds
- POST `$API/$SCHOOL_ID` - gemmer nye data for skolen (dummy-serveren gemmer ikke, men skriver blot til stdout)
- `$API/export` - får ønskede skoler der skal exporteres (er ikke implementeret i dummy-serveren)

Kør eventuelt `server.coffee` og ret en browser mod endpointet ie. http://localhost:8080/api/5 for at se eksempel på forventet data.

## Credits

- Map editor and viewer: Leaflet and Leaflet.draw
- Map data / tiles: OpenStreetMap
- Utility: jQuery

# Vejledning

I øverste højre hjørne vælges den ønskede skole.

Ved at klikke på eksisterende ruter og kryds, kan man se og ændre hvilke klassetrin de er vurderet til. Det valgte klassetrin bliver også det nye default for nye ruter eller kryds.

Værktøj til at tegne og redigere ruter og kryds findes i venstre side af skærmen. "polyline" og "marker" svarer henholdsvis til rute og kryds.

Ændringer gemmes direkte på serveren, og der vises en statusindikator nederst i højre hjørne `Saving...` indtil de er gemt.

Eksport af data foregår ved `Eksportér` knappen, hvor man først vælge hvilke skoler man ønsker eksporteret, og derefter klikker `Download` for at downloade resultatet.
# Backlog

- √sync code with javascript version
- enten legend eller sattelit
- skole draggable marker - opdateres i databasen
- √dismiss på eksportdialog

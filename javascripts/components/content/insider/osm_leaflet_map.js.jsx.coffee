###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin             - общие стили для компонентов.
* RequestBuilderMixin     - модуль запросов в API.
* leaflet                 - модуль для работы с картами.
* format                  - модуль работы с форматированием строк.
* keyMirror               - модуль создания "зеркального" хэша.
###
StylesMixin = require('components/mixins/styles')
RequestBuilderMixin = require('components/application/mixins/request_builder')
L = require('leaflet')
format = require('string-template')
#subjectDistricts = require('./subject_districts')
keyMirror = require('keymirror')


###* Константы
* _COLORS         - цвета
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

OsmLeafletMap = React.createClass


   _FEATURE_STYLES:
      district:
         basic:
            weight: 1,
            opacity: 1,
            fillColor: _COLORS.success
            color: 'blue',
            dashArray: '3',
            fillOpacity: 0.3
         noData:
            fillColor: _COLORS.light
         lowLevel:
            fillColor: _COLORS.alert
         midLevel:
            fillColor: _COLORS.exclamation
         highlight:
            weight: 5,
            color: '#666',
            dashArray: '',
            fillOpacity: 0.7

   _MAP_PARAMS:
      urlTemplate: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      leafletOptions:
         maxZoom: 19
         minZoom: 7
         attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
      view:
         point: [54.71034215, 55.98495483]
         zoom: 4
      bounds:
         southWest:
            lat: 51
            lng: 53.5
         northEast:
            lat: 57
            lng: 60

   _GIS_ENDPOINTS:
      districts: 'gis/boundary_polygons'

   _MAP_CONTAINER_ID: 'mapid'

   _INFO_VIEWER_TEMPLATES:
      main: [
         '<div>'
            '<div style="text-align: center;">{caption}</div>'
            '{targetIndex}'
            '<ul style="list-style-type:none;margin:0;padding:0;">{viewablePropertiesList}</ul>'
         '</div>'
         ].join ''
      li: [
         '<li>'
            '<span style="display:inline-block;font-size:11px;color:#666666;width:200px;">'
               '{caption}: '
            '</span>'
            '<span>{value}</span>'
         '</li>'
         ].join ''
      inventory:
         targetIndex: [
            '<div>Загружено: '
               '<span style="font-size: 20px; color:{color};">{percentage} %</span>'
             '</div>'
            ].join ''

   _LEGEND_VIWER_TEMPLATES:
      main: [
         '<ul style="list-style-type:none;margin:0;padding:0;">{legendItemsList}</ul>'
      ].join ''
      li: [
         '<li style="display: flex; align-items: center;">'
            '<div style="display: inline-block; background-color:{itemColor}; '
                        'border: 1px solid lightgray; border-radius: 3px; '
                        'width: 50px; height: 25px"></div>'
            '<span style="font-size:11px;color:#666666; padding: 10px;">{itemCaption}</span>'
         '</li>'
      ].join ''

   _LEVELS_TOOLBAR_TEPLATES:
      main:
         '<ul style="list-style-type:none;margin:0;padding:0;">{levelsButtonList}</ul>'
      li: [
         '<li>'
            '<input type="radio" name="viewableLevel" '
                   'value={levelName} {checked}/>{levelCaption}'
         '</li>'
      ].join ''

   # @const [String] - наименование суффика стиля для выделения определенного
   #                   уровня показателя
   _LEVEL_STYLE_SUFFIX: 'Level'

   _LEVEL_RADIO_INPUT_NAME: 'viewableLevel'

   # @const [Object] -  параметры уровней соотношений показателей.
   _RATIO_LEVELS:
      inventory:
         empty:
            level: 0
            color: _COLORS.light
            caption: 'нет данных о загрузке'
         low:
            name: 'low'
            level: 30
            caption: 'до 30% загружено'
            color: _COLORS.alert
         mid:
            name: 'mid'
            level: 80
            caption: 'до 80% загружено'
            color: _COLORS.exclamation
         high:
            name: 'high'
            level: 100
            caption: 'более 80% загружено'
            color: _COLORS.success

   # @const {Object} - выводимые уровни.
   _VIEWABLE_LEVELS:
      inventory:
         name: 'inventory'
         caption: 'инвентаризация'
      population:
         name: 'population'
         caption: 'население'
      salary:
         name: 'salary'
         caption: 'зарплаты'

   _CHARS:
      empty: ''
      dash: '-'

   _DISTRICT_ADMIN_LEVEL: 6

   _map: null
   _districtsGeoJson: null
   _infoViewer: null
   _legendViewer: null
   _levelsToolbar: null

   mixins: [RequestBuilderMixin]

   styles:
      container:
         height: 800
      viewerContainer:
         backgroundColor: _COLORS.light
         background: 'rgba(255,255,255,0.8)'
         minHeight: '100px'
         padding: '5px'
         boxShadow: '0 0 15px rgba(0,0,0,0.2)'
      hidden:
         display: 'none'
      shown:
         display: ''
      infoViewer:
         width: '250px'
      legendViewer:
         width: '200px'
      levelsToolbar:
         minHeight: null

   getInitialState: ->
      subjectDistricts: null
      viewableLevel: @_VIEWABLE_LEVELS.inventory

   render: ->
      `(
         <div id={this._MAP_CONTAINER_ID}
            style={this.styles.container}>
         </div>
      )`

   componentDidUpdate: (prevProps, prevState) ->
      if !prevState.subjectDistricts? and @state.subjectDistricts?
         @_addDistrictsToMap(@state.subjectDistricts)

      if prevState.viewableLevel.name isnt @state.viewableLevel.name
         @_legendViewer.update(@_RATIO_LEVELS[@state.viewableLevel.name])
         @_districtsGeoJson.removeFrom(@_map)
         @_addDistrictsToMap(@state.subjectDistricts)

   componentDidMount: ->
      mapParams = @_MAP_PARAMS
      mapViewParams = mapParams.view
      mapBoundsParams = mapParams.bounds
      southWestB = mapBoundsParams.southWest
      northEastB = mapBoundsParams.northEast
      southWest = L.latLng(southWestB.lat, southWestB.lng) # крайняя юго-западная точка
      northEast = L.latLng(northEastB.lat, northEastB.lng) # крайняя сереро-восточная точка

      @_map = L.map(@_MAP_CONTAINER_ID,
         maxBounds: L.latLngBounds(southWest, northEast)
      ).setView(mapViewParams.point, mapViewParams.zoom)

      L.tileLayer(mapParams.urlTemplate, mapParams.leafletOptions).addTo(@_map)

      @_requestDistricts()

      @_addInfoViewer()
      @_addLegend()
      @_addLevelsToolbar()

   _addDistrictsToMap: (subjectDistricts) ->
      @_districtsGeoJson = L.geoJson(subjectDistricts, {
         style: @_getDisctrictStyle,
         onEachFeature: @_onEachDistrict
      }).addTo(@_map)

   _addInfoViewer: ->
      @_infoViewer = L.control()
      mapViewer = this

      @_infoViewer.onAdd = (map) ->
         @_div = L.DomUtil.create('div', 'info')
         styles = mapViewer.styles
         Object.assign(@_div.style, styles.viewerContainer, styles.infoViewer)
         @update()
         @_div

      @_infoViewer.update = (properties) ->
         if properties?
            viewableLevel = mapViewer.state.viewableLevel
            viewableLevels = mapViewer._VIEWABLE_LEVELS
            viewablePropertiesList =
               mapViewer._getViwablePropertiesList(properties)

            targetIndexElement =
               switch viewableLevel.name
                  when viewableLevels.inventory.name
                     mapViewer._getInventoryTargetIndex(properties)

            @_div.innerHTML =
               format(
                  mapViewer._INFO_VIEWER_TEMPLATES.main,
                  caption: properties.header
                  targetIndex: targetIndexElement
                  viewablePropertiesList: viewablePropertiesList
               )
         else
            @_div.innerHTML = mapViewer._CHARS.empty

      @_infoViewer.addTo(@_map)

   _addLegend: ->
      @_legendViewer = L.control({position: 'bottomright'});
      mapViewer = this
      viewableRatioLevels = @_RATIO_LEVELS[@state.viewableLevel.name]

      @_legendViewer.onAdd = (viewableLevel) ->
         @_div = L.DomUtil.create('div', 'info legend')
         styles = mapViewer.styles

         Object.assign(@_div.style,
                       styles.viewerContainer,
                       styles.legendViewer)

         @_div.innerHTML = mapViewer._getHtmlLegend(viewableRatioLevels)
         @_div

      @_legendViewer.update = (viewableRatioLevels) ->
         if viewableRatioLevels?
            @_div.innerHTML = mapViewer._getHtmlLegend(viewableRatioLevels)
            Object.assign(@_div.style, mapViewer.styles.shown)
         else
            Object.assign(@_div.style, mapViewer.styles.hidden)

      @_legendViewer.addTo(@_map)

   _getHtmlLegend: (viewableRatioLevels)->
      templates = @_LEGEND_VIWER_TEMPLATES
      legendItemsList = []

      for levelName, levelParams of viewableRatioLevels
         legendItemsList.push(
            format(
               templates.li,
               itemColor: levelParams.color
               itemCaption: levelParams.caption
            )
         )

      format(
         templates.main,
         legendItemsList: legendItemsList.join(@_CHARS.empty)
      )

   _CHECKED_MARKER: 'checked'

   _addLevelsToolbar: ->
      @_levelsToolbar = L.control({position: 'topleft'});
      mapViewer = this
      viewableLevel = @state.viewableLevel

      # if viewableRatioLevels? and !_.isEmpty(viewableRatioLevels)
      @_levelsToolbar.onAdd = (map) ->
         @_div = L.DomUtil.create('div', 'levels-toolbar')
         styles = mapViewer.styles
         templates = mapViewer._LEVELS_TOOLBAR_TEPLATES
         viewableLevels = mapViewer._VIEWABLE_LEVELS
         levelsButtonList = []

         Object.assign(@_div.style,
                       styles.viewerContainer,
                       styles.levelsToolbar)

         for levelName, levelParams of viewableLevels
            levelNameValue = levelParams.name
            checkedValue =
               if levelNameValue is viewableLevel.name
                  mapViewer._CHECKED_MARKER

            levelsButtonList.push(
               format(
                  templates.li
                  levelName: levelNameValue
                  levelCaption: levelParams.caption
                  checked: checkedValue
               )
            )

         @_div.innerHTML =
            format(
               templates.main,
               levelsButtonList: levelsButtonList.join(mapViewer._CHARS.empty)
            )

         @_div

      @_levelsToolbar.addTo(@_map)

      levelsRadio = document.getElementsByName(@_LEVEL_RADIO_INPUT_NAME)

      if levelsRadio? and !_.isEmpty(levelsRadio)
         for inputRadio in levelsRadio
            inputRadio.onchange = @_onChangeViewableLevel

   _onChangeViewableLevel: (event) ->
      event.stopPropagation()
      @setState
         viewableLevel: @_VIEWABLE_LEVELS[event.target.value]

   _getInventoryTargetIndex: (properties) ->
      inventoryTemplates = @_INFO_VIEWER_TEMPLATES.inventory
      inventoryData = properties.inventory
      importedCount = inventoryData.imported.value
      exportedCount = inventoryData.exported.value
      ratioPercentage = @_getPercentageOfProperties(importedCount, exportedCount)
      ratioLevelColor =
         @_getExportedImportedRatioLevel(exportedCount, importedCount).color

      if ratioPercentage >= 0
         format(
            inventoryTemplates.targetIndex,
            percentage: ratioPercentage
            color: ratioLevelColor
         )


   _getViwablePropertiesList: (properties) ->
      viewableData = properties[@state.viewableLevel.name]
      chars = @_CHARS

      if viewableData? and !_.isEmpty(viewableData)
         listItems = []
         listItemTemplate = @_INFO_VIEWER_TEMPLATES.li

         for _itemName, item of viewableData
            listItems.push(
               format(
                  listItemTemplate,
                  caption: item.caption
                  value: item.value or chars.dash
               )
            )

         listItems.join chars.empty

   _getDisctrictStyle: (district) ->
      districtProperties = district.properties
      districtStyles = @_FEATURE_STYLES.district
      districtStyle = _.clone(districtStyles.basic)
      viewableLevel = @state.viewableLevel.name

      additionStyle =
         @_getDistrictAdditionStyle(districtProperties)

      Object.assign(districtStyle, additionStyle)

      districtStyle

   _getDistrictAdditionStyle: (districtProperties) ->
      inventoryData = districtProperties.inventory
      viewableLevel = @state.viewableLevel.name
      viewableLevles = @_VIEWABLE_LEVELS
      districtStyles = @_FEATURE_STYLES.district

      switch viewableLevel
         when viewableLevles.inventory.name
            if @_isHasInventoryDataWithImpExp(inventoryData)
               ratioLevel = @_getExportedImportedRatioLevel(
                  inventoryData.exported.value,
                  inventoryData.imported.value
               ).name

               ratioLevelStyleName =
                  [ratioLevel, @_LEVEL_STYLE_SUFFIX].join(@_CHARS.empty)
               districtStyles[ratioLevelStyleName]
            else
               districtStyles.noData

   _isHasInventoryDataWithImpExp: (inventoryData) ->
      inventoryData? and !_.isEmpty(inventoryData) and
      inventoryData.imported? and inventoryData.imported.value and
      inventoryData.exported? and inventoryData.exported.value

   _getExportedImportedRatioLevel: (exportedCount, importedCount) ->
      expImpRatio = @_getPercentageOfProperties(importedCount, exportedCount)
      ratioLevels = @_RATIO_LEVELS.inventory
      lowLevel = ratioLevels.low
      midLevel = ratioLevels.mid
      highLevel = ratioLevels.high

      if expImpRatio >= 0 and expImpRatio <= lowLevel.level
         lowLevel
      else if expImpRatio > lowLevel.level and expImpRatio <= midLevel.level
         midLevel
      else
         highLevel

   _getPercentageOfProperties: (part, total) ->
      if part? && total?
         +((part / total) * 100).toFixed(2)

   _onEachDistrict: (feature, layer) ->
      layer.on(
         mouseover: @_highlightDistrict
         mouseout: @_highlightResetDistrict
         click: @_zoomToDistrict
      )

   _highlightDistrict: (event) ->
      layer = event.target;

      layer.setStyle(@_FEATURE_STYLES.district.highlight)

      if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge)
         layer.bringToFront()

      @_infoViewer.update(layer.feature.properties)

   _highlightResetDistrict: (event) ->
      @_districtsGeoJson.resetStyle(event.target)

      @_infoViewer.update()

   _zoomToDistrict: (event) ->
      @_map.fitBounds(event.target.getBounds())

   _getDistricts: (error, response) ->
      @setState subjectDistricts: @_getResponseData(error, response).data

   _requestDistricts: ->
      #boundary: 'gis/boundary_polygons.json'

      @_sendRequest(
         endpoint: @_constructEndpoint(@_API_ACTIONS.index, @_GIS_ENDPOINTS.districts)
         requestType: @_REQUEST_TYPES.get
         queryParams:
            admin_level: @_DISTRICT_ADMIN_LEVEL
         callback: @_getDistricts
      )


module.exports = OsmLeafletMap

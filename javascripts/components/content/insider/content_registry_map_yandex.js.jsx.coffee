###* Зависимости: модули
* request         - модуль для работы с HTTP запросами.
* string-template - модуль для формирования строк из шаблонов.
* keymirror       - модуль для генерации "зеркального" хэша.
###
request = require('superagent')
format = require('string-template')
keyMirror = require('keymirror')

###* Зависимости: компоненты
* AjaxLoader      - индикатор загрузки.
###
AjaxLoader = require('components/core/ajax_loader')

ContentInstanceMapYandex = React.createClass

   _ADDRRESS_ENDPOINT_TEMPLATE: "{0}/{1}/addresses.json"
   _REFS: keyMirror(
      map: null
   )
   _INSTANCE_PROPERTY: 'properties'
   _INSTANCE_RIGHTHOLDER: 'rightholders'

   getInitialState: ->
      loaderTarget: null

   render: ->
      loaderTarget = @state.loaderTarget
      isLoaderShown = loaderTarget?
      refs = @_REFS
      mapRef = refs.map

      `(
         <div>
            <div id={mapRef}
                 ref={mapRef}
                 style={{height: 500, width: 800 }}>
            </div>
            <AjaxLoader target={loaderTarget}
                        isShown={isLoaderShown}/>
         </div>
      )`

   componentDidMount: ->
      @_requestInstanceAddress()

      @setState loaderTarget: @refs[@_REFS.map]

   _requestInstanceAddress: ->
      if Object.keys(@props)[0] == 'propertyID'
         instance = @_INSTANCE_PROPERTY
         instanceId = @props.propertyID
      else
         instance = @_INSTANCE_RIGHTHOLDER
         instanceId = @props.rightholderID
      endpoint = format(@_ADDRRESS_ENDPOINT_TEMPLATE, [instance, instanceId])
      mapComponent = this

      request.get(endpoint)
      .set('Accept', 'application/json')
      .end (error, res) ->

         if error? and !res.errors?

         else
            mapNode = ReactDOM.findDOMNode(mapComponent)
            addresses = JSON.parse(res.text).addresses
            script = document.createElement('script')
            script.src = "https://api-maps.yandex.ru/2.1/?lang=ru_RU"
            script.type = "text/javascript"

            script.onload = ->
               ymaps.ready(mapComponent._mapInit(addresses))
            mapNode.appendChild(script)


   _mapInit: (addresses) ->
      yandexMapComponent = this
      ->
         mainMap = new ymaps.Map('map',
            center: [54.72, 55.94]
            zoom: 9
            controls: ['zoomControl', 'fullscreenControl', 'typeSelector']
         )

         if addresses.error? or addresses[0].address.error? or addresses[0].address.length == 0
            # Значит адрес не задан, текст с информацией здесь - addresses.error.
            yandexMapComponent.setState loaderTarget: null
            geocoder = ymaps.geocode('Республика Башкортостан', results: 1)
            geocoder.then(
               (res) ->
                  defaultGeo = res.geoObjects.get(0)
                  coords = defaultGeo.geometry.getCoordinates()
                  if addresses.error?
                     textError = addresses.error
                  else if addresses[0].address.length == 0
                     textError = 'Адрес не задан'
                  else
                     textError = addresses[0].address.error
                  mainMap.balloon.open(coords, textError)
                  bounds = defaultGeo.properties.get('boundedBy')
                  mainMap.setBounds(bounds)
            )

         else
            myCollection = new ymaps.GeoObjectCollection()
            i = 0

            # Обрабатываем каждый адрес и находим координаты, затем к каждому
            #  адресу добавляем метку.
            while i < addresses.length
               geocoder = ymaps.geocode(addresses[i]['address'], results: 1)
               index_type = 0
               count_addresses = addresses.length

               geocoder.then(
                  (res) ->
                     # Выбираем первый результат геокодирования.
                     firstGeoObject = res.geoObjects.get(0)
                     coords = firstGeoObject.geometry.getCoordinates()
                     if addresses[index_type]['room_number']?
                        room = ', № помещения ' + addresses[index_type]['room_number']
                     else
                        room = ''
                     mainMap.balloon.open(coords, addresses[index_type]['type'] + ' адрес: '+
                           firstGeoObject.properties.get('text') + room)
                     myPlacemark = new (ymaps.Placemark)(coords,
                        preset: 'islands#blueStretchyIcon')

                     # Добавляем метки в коллекцию.
                     myCollection.add(myPlacemark)
                     # Добавляем коллекцию на карту.
                     mainMap.geoObjects.add(myCollection)

                     # Смотря сколько адресов у объекта выводим через коллекцию
                     #  объектов или просто через одну метку.
                     if addresses.length > 1
                        mainMap.setBounds(myCollection.getBounds())
                     else
                        bounds = firstGeoObject.properties.get('boundedBy')
                        mainMap.setBounds(bounds)

                     index_type += 1
                     yandexMapComponent.setState loaderTarget: null

                  (err) ->
                     # Тут должна быть обработка ошибки.
                     yandexMapComponent.setState loaderTarget: null
               )
               i++



module.exports = ContentInstanceMapYandex

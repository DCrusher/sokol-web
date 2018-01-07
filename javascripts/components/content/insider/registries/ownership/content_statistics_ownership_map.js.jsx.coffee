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

ContentStatisticsMapOwnership = React.createClass

   _ADDRRESS_ENDPOINT_TEMPLATE: "ownerships/statistics.json"
   _REFS: keyMirror(
      map: null
   )

   # @const {Object} - используемые символы.
   _D_CHARS:
      slash: '/'
      semicolon: '; '
      space: ' '
      empty: ''
      comma: ','
      newLine: '</br>'

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
                 style={{height: 900, width: 1250 }}>
            </div>
            <AjaxLoader target={loaderTarget}
                        isShown={isLoaderShown}/>
         </div>
      )`

   componentDidMount: ->
      @_requestInstanceAddress()

      @setState loaderTarget: @refs[@_REFS.map]

   _requestInstanceAddress: ->
      endpoint = @_ADDRRESS_ENDPOINT_TEMPLATE
      mapComponent = this

      request.get(endpoint)
      .set('Accept', 'application/json')
      .end (error, res) ->

         if error? and !res.errors?

         else
            mapNode = ReactDOM.findDOMNode(mapComponent)
            statistics = JSON.parse(res.text).statistics_data
            script = document.createElement('script')
            script.src = "https://api-maps.yandex.ru/2.1/?lang=ru_RU"
            script.type = "text/javascript"

            script.onload = ->
               ymaps.ready(mapComponent._mapInit(statistics))
            mapNode.appendChild(script)


   _mapInit: (statistics) ->
      yandexMapComponent = this
      ->
         mainMap = new ymaps.Map('map',
            center: [54.72, 55.94]
            zoom: 9
            controls: ['zoomControl', 'fullscreenControl', 'typeSelector']
         )

         if statistics.error? or statistics[0].address.error? or statistics[0].address.length == 0
            # Значит адрес не задан, текст с информацией здесь - addresses.error.
            yandexMapComponent.setState loaderTarget: null
            geocoder = ymaps.geocode('Республика Башкортостан', results: 1)
            geocoder.then(
               (res) ->
                  defaultGeo = res.geoObjects.get(0)
                  coords = defaultGeo.geometry.getCoordinates()
                  if statistics.error?
                     textError = statistics.error
                  else if statistics[0].address.length == 0
                     textError = 'Адрес не задан'
                  else
                     textError = statistics[0].address.error
                  mainMap.balloon.open(coords, textError)
                  bounds = defaultGeo.properties.get('boundedBy')
                  mainMap.setBounds(bounds)
            )

         else
            myCollection = new ymaps.GeoObjectCollection()

            # Обрабатываем каждый адрес и находим координаты, затем к каждому
            #  адресу добавляем метку.
            for item in statistics
               itemAddress = item.address
               geocoder = ymaps.geocode(itemAddress, results: 1)
               chars = yandexMapComponent._D_CHARS
               count_addresses = statistics.length

               geocoder.then(
                  ((res) ->
                     # Выбираем первый результат геокодирования.
                     firstGeoObject = res.geoObjects.get(0)
                     coords = firstGeoObject.geometry.getCoordinates()
                     statisticItem = this

                     ownerships_land = statisticItem.ownerships_land
                     ownerships_estate = statisticItem.ownerships_estate
                     sum_payments_land = statisticItem.sum_payments_land
                     sum_payments_estate = statisticItem.sum_payments_estate

                     balloonData = {
                        iconContent:
                           [
                              ownerships_land
                              chars.slash
                              sum_payments_land
                              chars.semicolon
                              ownerships_estate
                              chars.slash
                              sum_payments_estate
                           ].join chars.empty
                        balloonContent:
                           [
                              '<b>'
                              statisticItem.name_rightholder
                              chars.newLine
                              'Адрес: </b>'
                              firstGeoObject.properties.get('text')
                              chars.newLine
                              '<b> Количество договоров по земельным участкам: </b>'
                              ownerships_land
                              chars.comma
                              ' сумма платежей: '
                              sum_payments_land
                              chars.newLine
                              '<b> Количество договоров по недвижимости: </b>'
                              ownerships_estate
                              chars.comma
                              ' сумма платежей: '
                              sum_payments_estate
                           ].join ''
                     }

                     # В зависимости от уплаченной суммы (в общем) цвет значков разный.
                     if statisticItem.num_payments == 0
                        geoPlacemark = new ymaps.Placemark(coords, balloonData,
                           {preset: 'islands#redStretchyIcon'})
                     else if statisticItem.num_payments < 10000000
                        geoPlacemark = new ymaps.Placemark(coords, balloonData,
                           {preset: 'islands#darkgreenStretchyIcon'})
                     else
                        geoPlacemark = new ymaps.Placemark(coords, balloonData,
                           {preset: 'islands#blackStretchyIcon'})

                     # Добавляем метки в коллекцию.
                     myCollection.add(geoPlacemark)
                     # Добавляем коллекцию на карту.
                     mainMap.geoObjects.add(myCollection)

                     # Выводим метки через коллекцию объектов.
                     mainMap.setBounds(myCollection.getBounds())

                     yandexMapComponent.setState loaderTarget: null
                  ).bind(item),

                  (err) ->
                     # Тут должна быть обработка ошибки.
                     yandexMapComponent.setState loaderTarget: null
               )

module.exports = ContentStatisticsMapOwnership

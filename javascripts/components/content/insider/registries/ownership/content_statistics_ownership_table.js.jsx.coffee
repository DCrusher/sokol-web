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

ContentStatisticTableOwnership = React.createClass

   _ADDRRESS_ENDPOINT_TEMPLATE: "ownerships/statistics.json"
   _REFS: keyMirror(
      map: null
   )

   getInitialState: ->
      loaderTarget: null

   render: ->
      refs = @_REFS
      mapRef = refs.map

      `(
         <div>
            <div id={mapRef}
                 style={{height: 900, width: 1250 }}>

            </div>
         </div>
      )`

   componentDidMount: ->
      @_requestStatistics()

   _requestStatistics: ->
      endpoint = @_ADDRRESS_ENDPOINT_TEMPLATE

      request.get(endpoint)
      .set('Accept', 'application/json')
      .end (error, res) ->

         if error? and !res.errors?

         else
            #mapNode = ReactDOM.findDOMNode(this)
            statistics = JSON.parse(res.text).statistics_data
            @_statisticsTable(statistics)

   _statisticsTable: (statistics) ->


module.exports = ContentStatisticTableOwnership
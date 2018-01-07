
###* Зависимости: модули
* keyMirror - модуль для генерации "зеркальных хэшей"
###
keyMirror = require('keymirror')

# Корень ресурса (не работает нормально с серверным рендерингом)
APIRoot = [
            location.protocol
            '//'
            location.host
            '/'
          ].join('')
###*
* Модуль для хранения констант flux сервисоной части клиентской логики.
###
module.exports =
   endpointConstants:
      formats:
         json: 'json'
         xlsx: 'xlsx'
   APIEndpoints:
      ownership: [APIRoot, 'ownerships'].join('/')
      property: [APIRoot, 'properties'].join('/')
      rightholder: [APIRoot, 'rightholders'].join('/')
      documental_basis: [APIRoot, 'documental_bases'].join('/')
      payment: [APIRoot, 'payments'].join('/')
      manual_view: [APIRoot, 'manuals'].join('/')
      manual: [APIRoot, 'admin','manuals'].join('/')
      user: [APIRoot, 'admin', 'users'].join('/')
      calculation_constant: [APIRoot, 'admin', 'calculations', 'calculation_constants'].join('/')
      calculation_procedure: [APIRoot, 'admin', 'calculations', 'calculation_procedures'].join('/')
      factor: [APIRoot, 'admin', 'calculations', 'factors'].join('/')
   PayloadSources: keyMirror(
      SERVER_ACTION: null
      VIEW_ACTION: null
   )
   ActionTypes: keyMirror(
      SELECTOR_DICTIONARY_REQUEST: null
      SELECTOR_DICTIONARY_RESPONSE: null
      SELECTOR_INSTANCES_REQUEST: null
      SELECTOR_INSTANCES_RESPONSE: null
      TABLE_USER_FILTER_REQUEST: null
      TABLE_USER_FILTER_RESPONSE: null
   )
   APIMethods: keyMirror(
      index: null
      new: null
      show: null
      create: null
      update: null
      destroy: null
      export: null
   )
   APITypes: keyMirror(
      request: null
      response: null
   )
   EventTypes:
      CHANGE_EVENT: 'change'
   AcceptTypes:
      JSON: 'application/json'

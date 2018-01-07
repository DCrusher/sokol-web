
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
* Модуль для хранения констант flux для административной части сайта
###
module.exports =
   APIEndpoints:
      ROOT:                      APIRoot

      RIGHTHOLDERS_ROOT:         [APIRoot, 'rightholders'].join('/')
      RIGHTHOLDERS:              [APIRoot, 'rightholders.json'].join('/')
      NEW_RIGHTHOLDER:           [APIRoot, 'rightholders', 'new.json'].join('/')
      GROUP_DESTROY_RIGHTHOLDERS:  [APIRoot, 'rightholders', 'group_destroy.json'].join('/')

      DB_ROOT:                   [APIRoot, 'documents'].join('/')
      DB:                        [APIRoot, 'documents.json'].join('/')
      NEW_DB:                    [APIRoot, 'documents', 'new.json'].join('/')

      PROPERTIES_ROOT:           [APIRoot, 'properties'].join('/')
      PROPERTIES:                [APIRoot, 'properties.json'].join('/')
      NEW_PROPERTIES:            [APIRoot, 'properties', 'new.json'].join('/')
      GROUP_DESTROY_PROPERTIES:  [APIRoot, 'properties', 'group_destroy.json'].join('/')

      OWNERSHIPS_ROOT:           [APIRoot, 'ownerships'].join('/')
      OWNERSHIPS:                [APIRoot, 'ownerships.json'].join('/')
      NEW_OWNERSHIP:             [APIRoot, 'ownerships', 'new.json'].join('/')

      PAYMENTS_ROOT:             [APIRoot, 'payments'].join('/')
      PAYMENT_TO_GENERATIVE:     [APIRoot, 'payments', '{0}', 'to_generative.json'].join('/')
      PAYMENT_CLARIFIED_ATTR:    [APIRoot, 'payments', '{0}', 'clarified_attributes.json'].join('/')
      PAYMENTS_ACCEPT:           [APIRoot, 'payments', 'accept.json'].join('/')
      PAYMENTS_REJECT:           [APIRoot, 'payments', 'reject.json'].join('/')
      PAYMENTS_CLARIFY:          [APIRoot, 'payments', 'clarify.json'].join('/')
      PAYMENTS_CLARIFYING:       [APIRoot, 'payments', 'clarifying.json'].join('/')

   StandardMessages:
      COMMON_ERROR: 'Что-то пошло не так, пожалуйста, попробуйте снова'
   PayloadSources: keyMirror(
      SERVER_ACTION: null
      VIEW_ACTION: null)
   EventTypes:
      CHANGE_EVENT: 'change'
   ActionTypes:
      Rightholder: keyMirror(
         RIGHTHOLDERS_REQUEST: null
         RIGHTHOLDERS_RESPONSE: null
         RIGHTHOLDER_GET_REQUEST: null
         RIGHTHOLDER_GET_RESPONSE: null
         RIGHTHOLDER_NEW_REQUEST: null
         RIGHTHOLDER_NEW_RESPONSE: null
         RIGHTHOLDER_CREATE_REQUEST: null
         RIGHTHOLDER_CREATE_RESPONSE: null
         RIGHTHOLDER_EDIT_REQUEST: null
         RIGHTHOLDER_EDIT_RESPONSE: null
         RIGHTHOLDER_DELETE_REQUEST: null
         RIGHTHOLDER_DELETE_RESPONSE: null
         RIGHTHOLDER_GROUP_DELETE_REQUEST: null
         RIGHTHOLDER_GROUP_DELETE_RESPONSE: null
      )
      DocumentalBasis: keyMirror(
         DB_REQUEST: null
         DB_RESPONSE: null
      )
      Property: keyMirror(
         PROPERTIES_REQUEST: null
         PROPERTIES_RESPONSE: null
         PROPERTY_GET_REQUEST: null
         PROPERTY_GET_RESPONSE: null
         PROPERTY_NEW_REQUEST: null
         PROPERTY_NEW_RESPONSE: null
         PROPERTY_CREATE_REQUEST: null
         PROPERTY_CREATE_RESPONSE: null
         PROPERTY_EDIT_REQUEST: null
         PROPERTY_EDIT_RESPONSE: null
         PROPERTY_DELETE_REQUEST: null
         PROPERTY_DELETE_RESPONSE: null
         PROPERTY_GROUP_DELETE_REQUEST: null
         PROPERTY_GROUP_DELETE_RESPONSE: null
      )

      Ownership: keyMirror(
         OWNERSHIPS_REQUEST: null
         OWNERSHIPS_RESPONSE: null
         OWNERSHIP_GET_REQUEST: null
         OWNERSHIP_GET_RESPONSE: null
         OWNERSHIP_NEW_REQUEST: null
         OWNERSHIP_NEW_RESPONSE: null
         OWNERSHIP_CREATE_REQUEST: null
         OWNERSHIP_CREATE_RESPONSE: null
         OWNERSHIP_EDIT_REQUEST: null
         OWNERSHIP_EDIT_RESPONSE: null
         OWNERSHIP_DELETE_REQUEST: null
         OWNERSHIP_DELETE_RESPONSE: null
         OWNERSHIP_DOWNLOAD_DOCUMENT_REQUEST: null
         OWNERSHIP_DOWNLOAD_DOCUMENT_RESPONSE: null
      )

      Payment: keyMirror(
         TO_GENERATIVE_REQUEST: null
         TO_GENERATIVE_RESPONSE: null
         CLARIFIED_ATTR_GET_REQUEST: null
         CLARIFIED_ATTR_GET_RESPONSE: null
         CLARIFIED_ATTR_SET_REQUEST: null
         CLARIFIED_ATTR_SET_RESPONSE: null
         CLARIFYING_REQUEST: null
         CLARIFYING_RESPONSE: null
         ACCEPT_REQUEST: null
         ACCEPT_RESPONSE: null
         CLARIFY_REQUEST: null
         CLARIFY_RESPONSE: null
         REJECT_REQUEST: null
         REJECT_RESPONSE: null
     )

###* Зависимости: модули
* keyMirror - модуль для генерации "зеркальных хэшей"
###
keyMirror = require('keymirror')

# из-за серверного пререндеринга  не получается использовать
# BOM-объекты - они ломают серверный пререндеринг, даже если пытаться
# проверить на udefined
# TODO придумать способ получать корень ресурса (возможно сделать проброс из rails)
# APIRoot = "http://localhost:3000" #location.protocol + "//" + location.host #
APIRoot = [
            location.protocol
            '//'
            location.host
            '/'
          ].join('')

###*
* Модуль для хранения констант flux для входа, сессий и редактирования профиля
###
module.exports =
   APIEndpoints:
      ROOT:              APIRoot
      SIGNIN:            APIRoot + '/signin'
      SIGNOUT:           APIRoot + '/signout.json'
      SIGNIN_AUTH:       APIRoot + '/sessions.json'
      USER_ACTIONS:      APIRoot + '/user_actions.json'

      PERSONAL_MANAGER:  [APIRoot, 'personal', 'manager.json'].join('/')
      PERSONAL_AVATAR:   [APIRoot, 'personal', 'avatar.json'].join('/')
      PERSONAL_MANAGEMENT_STRUCTURE: [APIRoot, 'personal', 'management_structure.json'].join('/')

      PROFILE_ROOT:      [APIRoot, 'personal', 'profile'].join('/')
      PROFILE:           [APIRoot, 'personal', 'profile.json'].join('/')
      PROFILE_CHP:       [APIRoot, 'personal', 'profile', 'change_password.json'].join('/')
      PROFILE_EXCHANGE_CONSTANTS: [APIRoot, 'personal', 'profile', 'exchange_constants.json'].join('/')

      USER_FILTERS_ROOT: [APIRoot, 'personal', 'user_filters'].join('/')
      USER_FILTERS:      [APIRoot, 'personal', 'user_filters.json'].join('/')
      NEW_FILTER:        [APIRoot, 'personal', 'user_filters', 'new.json'].join('/')
   StandardMessages:
      COMMON_ERROR: 'Что-то пошло не так, пожалуйста, попробуйте снова'
   PayloadSources: keyMirror(
      SERVER_ACTION: null
      VIEW_ACTION: null)
   ActionTypes:
      Session: keyMirror(
         SIGNIN_REQUEST: null
         SIGNIN_RESPONSE: null
         SIGNOUT_REQUEST: null
         SIGNOUT_RESPONSE: null
         REDIRECT: null
      ),
      Profile: keyMirror(
         PROFILE_GET_REQUEST: null
         PROFILE_GET_RESPONSE: null
         PROFILE_EDIT_REQUEST: null
         PROFILE_EDIT_RESPONSE: null
         PROFILE_CHP_REQUEST: null
         PROFILE_CHP_RESPONSE: null
         PROFILE_GET_EXCHANGE_CONSTANTS_REQUEST: null
         PROFILE_GET_EXCHANGE_CONSTANTS_RESPONSE: null
         PROFILE_SET_EXCHANGE_CONSTANTS_REQUEST: null
         PROFILE_SET_EXCHANGE_CONSTANTS_RESPONSE: null
      ),
      UserFilter: keyMirror(
         USER_FILTERS_REQUEST: null
         USER_FILTERS_RESPONSE: null
         USER_FILTER_NEW_REQUEST: null
         USER_FILTER_NEW_RESPONSE: null
         USER_FILTER_CREATE_REQUEST: null
         USER_FILTER_CREATE_RESPONSE: null
         USER_FILTER_GET_RESPONSE: null
         USER_FILTER_GET_REQUEST: null
         USER_FILTER_EDIT_RESPONSE: null
         USER_FILTER_EDIT_REQUEST: null
         USER_FILTER_DELETE_RESPONSE: null
         USER_FILTER_DELETE_REQUEST: null
      )
   AcceptTypes:
      json: 'application/json'
   EventTypes:
      CHANGE_EVENT: 'change'


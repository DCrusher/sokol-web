SokolAppDispatcher = require('../dispatcher/app_dispatcher')
SokolFluxConstants = require('../constants/flux_constants')
EventEmitter = require('events').EventEmitter
assign = require('object-assign')

ActionTypes = SokolFluxConstants.ActionTypes
endpoints = SokolFluxConstants.APIEndpoints
CHANGE_EVENT = SokolFluxConstants.EventTypes.CHANGE_EVENT

_rememberToken = ''#sessionStorage.getItem('rememberToken')
_login = null #sessionStorage.getItem('email')
_errors = []

###*
* @param {String} - последнее событие.
###
_lastInteraction = undefined

SessionStore = assign({}, EventEmitter.prototype,
   emitChange: ->
      @emit(CHANGE_EVENT)

   addChangeListener: (callback) ->
      @on(CHANGE_EVENT, callback)

   removeChangeListener: (callback) ->
      @removeListener(CHANGE_EVENT, callback)

   isLoggedIn: ->
      return !!_rememberToken

   getRememberToken: ->
      return _rememberToken

   getLogin: ->
      return _login

   getErrors: ->
      return _errors

   getLastInteration: ->
      return _lastInteraction

   dispatcherIndex: SokolAppDispatcher.register((payload) ->
      action = payload.action
      _lastInteraction = action.type

      switch _lastInteraction
         when ActionTypes.Session.SIGNIN_RESPONSE
            if action.json
               # Token will always live in the session, so that the API can grab it with no hassle
               # sessionStorage.setItem 'email', action.json.email
               # sessionStorage.setItem 'rememberToken', action.json.remember_token
               user = action.json.user
               _login = user.login
               _rememberToken = user.remember_token
               _errors = []
            if action.errors
               _errors = action.errors
            SessionStore.emitChange()
         when ActionTypes.Session.SIGNOUT_RESPONSE
            _email = null
            _rememberToken = null
            # sessionStorage.removeItem 'email'
            # sessionStorage.removeItem 'rememberToken'
            SessionStore.emitChange()

      return true
   )
)

# SessionStore.dispatchToken = SokolAppDispatcher.register((payload) ->
#    action = payload.action

#    switch action.type
#       when ActionTypes.LOGIN_RESPONSE
#          if action.json
#             # Token will always live in the session, so that the API can grab it with no hassle
#             # sessionStorage.setItem 'email', action.json.email
#             # sessionStorage.setItem 'rememberToken', action.json.remember_token
#             user = action.json.user
#             _email = user.email
#             _rememberToken = user.remember_token
#             _errors = []
#          if action.errors
#             _errors = action.errors
#          SessionStore.emitChange()
#       when ActionTypes.LOGOUT
#          _email = null
#          # sessionStorage.removeItem 'email'
#          # sessionStorage.removeItem 'rememberToken'
#          SessionStore.emitChange()

#    return true
# )

module.exports = SessionStore

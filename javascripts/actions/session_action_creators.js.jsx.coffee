SokolAppDispatcher = require('../dispatcher/app_dispatcher')
SokolFluxConstants = require('../constants/flux_constants')
WebAPIUtils = require('../utils/web_api_utils')

ActionTypesSession = SokolFluxConstants.ActionTypes.Session

module.exports =
   ###*
   * Фукнция создания запроса в БЛ на аутентификацию.
   *
   * @param {String} login    - логин/электронная почта пользователя
   * @param {String} password - пароль
   * @return
   ###
   signin: (login, password) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypesSession.SIGNIN_REQUEST
         login: login
         password: password
      )

      WebAPIUtils.signin login, password

   ###*
   * Функция создания запроса в БЛ на уничтожение сессии пользователя.
   *
   * @return
   ###
   signout: ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypesSession.SIGNOUT_REQUEST

      WebAPIUtils.signout()
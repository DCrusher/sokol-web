SokolAppDispather = require('../dispatcher/app_dispatcher')
SokolFluxConstants = require('../constants/flux_constants')

ActionTypes = SokolFluxConstants.ActionTypes

module.exports =
   ###*
   * Функция создания серверного действия в ответ на получение
   *  результатов аутентификации.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveSigninResult: (json, errors) ->
      SokolAppDispather.handleServerAction
         type: ActionTypes.Session.SIGNIN_RESPONSE
         json: json
         errors: errors

   ###*
   * Функция создания серверного действия в ответ на получение
   *  результатов уничтожения сессии пользователя.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveSignoutResult: (json, errors) ->
      SokolAppDispather.handleServerAction
         type: ActionTypes.Session.SIGNOUT_RESPONSE
         json: json
         errors: errors

   ###*
   * Функция создания серверного действия в ответ на получение АРМов
   *  с действиями пользоватля.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUserActions: (json, errors) ->
      SokolAppDispather.handleServerAction
         type: ActionTypes.Session.USER_ACTIONS_RESPONSE
         json: json
         errors: errors


###* Зависимости: модули
* SokolAppDispather  - flux диспетчер
* FluxConstants - константы для пользовательской архитектуры flux
###
SokolAppDispather = require('../dispatcher/app_dispatcher')
FluxConstants = require('../constants/flux_constants')

# Типы действий
ActionTypes = FluxConstants.ActionTypes

###*
*  Модуль создания серверных пользовательских действий
###
module.exports =

   #================================ Профиль ==============================

   ###*
   * Функция создания серверного действия в ответ
   *         на получение данных по профилю.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveProfile:(json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Profile.PROFILE_GET_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос редактирования данных профиля.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveProfileEditResult:(json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Profile.PROFILE_EDIT_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос редактирование пароля профиля.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveProfileEditPassword:(json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Profile.PROFILE_CHP_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия на получение констант форматов обмена.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveExchangeConstants:(json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Profile.PROFILE_GET_EXCHANGE_CONSTANTS_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия на установку форматов обмена.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveSetExchangeConstantsResult:(json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Profile.PROFILE_SET_EXCHANGE_CONSTANTS_RESPONSE
         json: json
         errors: errors
      )

   #================================ Фильтры пользователя ==============================

   ###* Функция создания серверного действия в ответа на запрос пользовательских
   *  фильтров.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUserFilters: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.UserFilter.USER_FILTERS_RESPONSE
         json: json
         errors: errors
      )

   ###* Функция создания серверного действия в ответ на запрос пользовательских
   *  фильтров.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUserFilterFields: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.UserFilter.USER_FILTER_NEW_RESPONSE
         json: json
         errors: errors
      )

   ###* Функция создания серверного действия в ответ на запрос пользовательского
   *  фильтра.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUserFilter: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.UserFilter.USER_FILTER_GET_RESPONSE
         json: json
         errors: errors
      )

   ###* Функция создания серверного действия в ответа на запрос создания
   *  пользовательского фильтра.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUserFilterCreationResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.UserFilter.USER_FILTER_CREATE_RESPONSE
         json: json
         errors: errors
      )

   ###* Функция создания серверного действия в ответа на запрос редактирования
   *  пользовательского фильтра.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUserFilterEditingResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.UserFilter.USER_FILTER_EDIT_RESPONSE
         json: json
         errors: errors
      )

   ###* Функция создания серверного действия в ответа на запрос удаления
   *  пользовательского фильтра.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUserFilterDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.UserFilter.USER_FILTER_DELETE_RESPONSE
         json: json
         errors: errors
      )
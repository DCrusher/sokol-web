
###* Зависимости: модули
* SokolAppDispather          - flux диспетчер
* SokolFluxConstants         - константы для пользовательской архитектуры flux
* WebAPIUtils                - модуль утилит взаимодействия с пользовательским API системы
###
SokolAppDispatcher = require('../dispatcher/app_dispatcher')
SokolFluxConstants = require('../constants/flux_constants')
WebAPIUtils = require('../utils/web_api_utils')

# типы действий
ActionTypes = SokolFluxConstants.ActionTypes

###*
* модуль создания клиентских пользовательских действий.
###
module.exports =

   #================================ Профиль ==============================

   ###*
   * Функция запроса данных по профилю. Делает запрос на получение
   *  данных для динамической формы - все поля со значениями, валидаторами,
   *  перечислениями и т.д.
   *
   * @return
   ###
   getProfile: ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Profile.PROFILE_GET_REQUEST
      )
      WebAPIUtils.getProfile()

   ###*
   * Функция создания пользовательского запроса на редактирование данных профиля.
   *
   * @param {Object} requestParams - параметры запроса.
   * @return
   ###
   editProfile: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Profile.PROFILE_EDIT_REQUEST
      )
      WebAPIUtils.editProfile(requestParams)

   ###*
   * Функция отправки запроса на смену пароля пользователя.
   *
   * @param {Object} requestParams - параметры запроса.
   * @return
   ###
   editPassword: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Profile.PROFILE_CHP_REQUEST
      )
      WebAPIUtils.editPassword(requestParams)

   ###*
   * Функция отправки запроса на получения констант форматов обмена.
   *
   * @param {Object} requestParams - параметры запроса.
   * @return
   ###
   getExchangeConstants: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Profile.PROFILE_GET_EXCHANGE_CONSTANTS_REQUEST
      )
      WebAPIUtils.getExchangeConstants(requestParams)

   ###*
   * Функция отправки запроса на задание констант форматов обмена.
   *
   * @param {Object} requestParams - параметры запроса.
   * @return
   ###
   setExchangeConstants: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Profile.PROFILE_SET_EXCHANGE_CONSTANTS_REQUEST
      )
      WebAPIUtils.setExchangeConstants(requestParams)

   #================================ Фильтры пользователя ==============================

   ###*
   * Функция создания запроса на получение пользовательских фильтров.
   *
   * @param {String} modelName - имя модели.
   * @return
   ###
   getUserFilters: (modelName) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.UserFilter.USER_FILTERS_REQUEST
      )

      WebAPIUtils.getUserFilters modelName

   ###*
   * Функция запроса полей для формы создания нового фильтра.
   *
   * @return
   ###
   getUserFilterFields: ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.UserFilter.USER_FILTER_NEW_REQUEST
      )
      WebAPIUtils.getUserFilterFields()

   ###*
   * Функция запроса экзмепляра пользовательского фильтра.
   *
   * @param {String} filterID - идентификатор пользовательского фильтра.
   * @return
   ###
   getUserFilter: (filterID) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.UserFilter.USER_FILTER_GET_REQUEST
      )
      WebAPIUtils.getUserFilter filterID

   ###*
   * Функция создания запроса на создание пользовательского фильтра.
   *
   * @param {Object} requestParams - параметры запроса.
   * @return
   ###
   createUserFilter: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.UserFilter.USER_FILTER_CREATE_REQUEST
      )

      WebAPIUtils.createUserFilter requestParams

   ###*
   * Функция создания запроса на редактирование параметров пользовательского фильтра.
   *
   * @param {Object} requestParams - параметры запроса.
   * @param {String} filterID     - идентификатор фильтра.
   * @return
   ###
   editUserFilter: (requestParams, filterID) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.UserFilter.USER_FILTER_EDIT_REQUEST
      )

      WebAPIUtils.editUserFilter requestParams, filterID

   ###*
   * Функция удаления пользовательского фильтра.
   *
   * @param {String} filterID - идентификатор удаляемого пользовательского фильтра.
   * @return
   ###
   deleteUserFilter: (filterID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.UserFilter.USER_FILTER_DELETE_REQUEST

      WebAPIUtils.deleteUserFilter(filterID)


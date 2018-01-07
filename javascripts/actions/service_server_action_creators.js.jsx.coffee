
###* Зависимости: модули
* SokolAppDispather    - flux диспетчер
* ServiceFluxConstants - константы для сервисной части архитектуры flux
###
SokolAppDispather = require('../dispatcher/app_dispatcher')
ServiceFluxConstants = require('../constants/service_flux_constants')

# Типы действий
ActionTypes = ServiceFluxConstants.ActionTypes

###*
*  Модуль создания серверных административных действий
###
module.exports =

   ###*
   * Функция создания серверного действия в ответ на запрос словаря поля выбора (Selector)
   *
   * @param {Object} json       - результат запроса.
   * @param {Object} errors     - ошибки.
   * @param {Number} identifier - идентификатор.
   * @return
   ###
   receiveSelectorDictionary: (json, errors, identifier) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.SELECTOR_DICTIONARY_RESPONSE
         json: json
         errors: errors
         identifier: identifier
      )

   ###* Функция создания серверного действия в ответ на запрос экземпляров поля выбора (Selector)
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveSelectorInstances: (json, errors, identifier) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.SELECTOR_INSTANCES_RESPONSE
         json: json
         errors: errors
         identifier: identifier
      )

   ###* Функция создания серверного действия в ответ на запрос экземпляров поля выбора (Selector)
   *
   * @param {Object} json                - результат запроса
   * @param {Object} errors              - ошибки
   * @param {Number, String} componentID - идентификатор компонента, отправившего запрос.
   * @param {String} model               - имя модели компонента, отправившего запрос.
   * @param {String} APIMethod           - метод обращения в API.
   * @param {String} customMethod        - наименование пользовательского метода обращения в API.
   * @return
   ###
   dataResponse: (json, errors, componentID, model, APIMethod, customMethod) ->
      eventType =
         componentID: componentID
         model: model
         type: ServiceFluxConstants.APITypes.response
         APIMethod: APIMethod
         customMethod: customMethod

      SokolAppDispather.handleServerAction(
         type: eventType
         json: json
         errors: errors
      )


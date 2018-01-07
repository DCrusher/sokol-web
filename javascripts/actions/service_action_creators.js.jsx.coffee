###* Зависимости: модули
* SokolAppDispather     - flux диспетчер
* ServiceFluxConstants - константы для сервисной части клиентской логики архитектуры flux
* ServiceWebAPIUtils   - модуль утилит взаимодействия с API системы
###
SokolAppDispatcher = require('../dispatcher/app_dispatcher')
ServiceFluxConstants = require('../constants/service_flux_constants')
ServiceWebAPIUtils = require('../utils/service_web_api_utils')

# типы действий
ActionTypes = ServiceFluxConstants.ActionTypes

# тип запроса для формирования eventType
ServiceFluxConstants.APITypes._REQUEST_TYPE
###*
* модуль создания клиентских сервисных действий
###
module.exports =
   ###*
   * Функция получения словаря для поля выбора Selector.
   *
   * @param {Object} requestParams     - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @param {String} requestEndpoint   - адрес запроса.
   * @param {Number} requestIdentifier - идентификатор селектора, отправившего запрос.
   * @return
   ###
   getSelectorDictionary: (requestParams, requestEndpoint, requestIdentifier) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.SELECTOR_DICTIONARY_REQUEST
      )
      ServiceWebAPIUtils.getSelectorDictionary requestParams,
                                               requestEndpoint,
                                               requestIdentifier

   ###*
   * Функция выбранных экземпляров в поле выбора Selector.
   *
   * @param {Object} requestEndpoint   - адрес запроса экземпляров.
   * @param {Number} requestIdentifier - идентификатор селектора, отправившего запрос.
   * @param {Object} requestFilter - фильтр запроса.
   * @return
   ###
   getSelectorInstances: (requestEndpoint, requestIdentifier, requestFilter) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.SELECTOR_INSTANCES_REQUEST
      )
      ServiceWebAPIUtils.getSelectorInstances requestEndpoint,
                                              requestIdentifier,
                                              requestFilter

   ###*
   * Общая функция запроса данных. Генерирует событие для диспетчера и
   *  вызывает функцию запроса данных в API. Может использоваться в компонентах
   *  DataTable, DynamicForm.
   *
   * @param {Object} params - параметры запроса данных. Вид:
   *        {Object} requestData         - отправляемые данные запроса.
   *        {Number, String} instanceID  - идентификатор экземпляра, по которому
   *                                       делается запрос.
   *        {Number, String} componentID - идентификатор компонента.
   *        {String} model               - имя модели компонента.
   *        {String} subResource         - адрес вложенного ресурса.
   *        {String} APIMethod           - метод обращения в API.
   *        {String} format              - запрашиваемый формат, если не задан
   *                                       используется json.
   *        {Boolean} isFileRequest      - флаг запроса файла. Если флаг положительный
   *                                       будет просто выполнена установка location
   *                                       браузера вместо стандартой отправки ajax-запроса.
   *    {Object} customSendParams - произвольные параметры отправки запроса.
   * @return
   ###
   dataRequest: (params) ->
      requestParams = params.requestParams
      componentID = params.componentID
      model = params.model
      APIMethod = params.APIMethod

      eventType =
         componentID: componentID
         model: model
         type: ServiceFluxConstants.APITypes.request
         APIMethod: APIMethod

      SokolAppDispatcher.handleViewAction(
         type: eventType
      )

      ServiceWebAPIUtils.dataRequest params
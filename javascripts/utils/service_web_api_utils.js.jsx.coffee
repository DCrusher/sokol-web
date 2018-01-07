###* Зависимости: модули
* ServiceServerActionCreators  - модуль создания серверных административных действий
* ServiceFluxConstants         - константы для административной архитектуры flux
* request                    - библиотека для AJAX взаимодействия с API бизнес-логики
###
ServiceServerActionCreators = require('../actions/service_server_action_creators')
ServiceFluxConstants = require('../constants/service_flux_constants')
request = require('superagent')
format = require('string-template')
queryString = require('query-string')

###* Константы
* @param {String} _JSON_ACCEPT - тип данных для запроса
###
_JSON_ACCEPT = ServiceFluxConstants.AcceptTypes.JSON

# # пути взаимодействия с API
endpoints = ServiceFluxConstants.APIEndpoints

# # типовые сообщения
# messages = ServiceFluxConstants.StandardMessages


###* TODO - рассмотреть целесообразность вынесения в отдельный модуль.
* Функция получения ошибок из ответа сервера
*
* @param {Object} response - хэш с параметрами ответа сервера.
* @return {Object} - хэш с ошибками.
###
_getErrors = (response) ->
   responseText = response.text
   responseStatus = response.status
   STANDART_ERROR = ["Произошла ошибки при запросе.\n",
                     "Ответ: ", responseText].join('')

   # проверим статус ответа, если статус ошибочный - нужно вернуть ошибку
   if responseStatus == 404 || responseStatus == 400
      responseObj = JSON.parse(response.text)

      # Если в распарсеном ответе есть член - ошибки - вернем его.
      #  Иначе вернем стандартную ошибку.
      if responseObj.hasOwnProperty 'errors'
         responseObj.errors
      else
         { errors: STANDART_ERROR }


###*
* Модуль утилит сервисного взаимодействия с API
###
module.exports =

   # @const {String} - имя параметра типа данных запроса.
   _ACCEPT_PARAM_NAME: 'Accept'

   # @const {Object} - используемые символы.
   _CHARS:
      point: '.'
      empty: ''
      question: '?'
      slash: '/'

   ###*
   * Функция запроса в API данных для справочника компонента селектора (Selector)
   *
   * @param {Object} requestParams  - хэш параметров запроса. Вид:
   *                 {Number} page               - активная страница.
   *                 {Number} perPage            - кол-во на странице.
   *                 {Object} filter             - хэш параметров фильтра.
   *                 {Number, String} instanceID - идентификатор записи.
   * @param {String} requestEndpoint - адрес API.
   * @param {Number} requestIdentifier - идентификатор селектора, отправившего запрос.
   * @return
   ###
   getSelectorDictionary: (requestParams, requestEndpoint, requestIdentifier) ->
      params =
         page: requestParams.page
         per_page: requestParams.perPage
         matched_params:  JSON.stringify(requestParams.filter)

      request.get(requestEndpoint)
         .query(params)
         .set('Accept', _JSON_ACCEPT)
         .end (error, res) ->
            errors = []
            json = undefined
            if res
               errors = _getErrors(res)
               # если нет ошибок считаем результат
               unless errors?
                  json = JSON.parse res.text

               ServiceServerActionCreators.receiveSelectorDictionary json,
                                                                     errors,
                                                                     requestIdentifier

   ###*
   * Функция запроса в API данных по выбранных записям компонента селектора (Selector)
   *
   * @param {String} requestEndpoint   - адрес API.
   * @param {Number} requestIdentifier - идентификатор селектора, отправившего запрос.
   * @param {Object} requestFilter - фильтра запроса.
   * @return
   ###
   getSelectorInstances: (requestEndpoint, requestIdentifier, requestFilter) ->

      params =
         if requestFilter?
            matched_params:  JSON.stringify(requestFilter)
            is_build_hierarchy: false
         else
            {}

      params.is_serialized = true

      request.get(requestEndpoint)
         .query(params)
         .set('Accept', _JSON_ACCEPT)
         .end (error, res) ->
            errors = []
            json = undefined
            if res
               errors = _getErrors(res)
               # если нет ошибок считаем результат
               unless errors?
                  json = JSON.parse res.text

               ServiceServerActionCreators.receiveSelectorInstances json,
                                                                    errors,
                                                                    requestIdentifier

   ###*
   * Функция запроса в API данных по модели и методу, входящих в параметры.
   *
   * @param {Object} params - параметры запроса данных. Вид:
   *        {Object} requestData         - отправляемые данные запроса.
   *        {Number, String} instanceID  - идентификатор экземпляра, по которому
   *                                       делается запрос.
   *        {Number, String} componentID - идентификатор компонента.
   *        {String} model               - имя модели компонента.
   *        {String} subResource         - адрес вложенного ресурса модели.
   *        {String} APIMethod           - метод обращения в API.
   *        {String} format              - запрашиваемый формат, если не задан
   *                                       используется json.
   *        {Boolean} isFileRequest      - флаг запроса файла. Если флаг положительный
   *                                       будет просто выполнена установка location
   *                                       браузера вместо стандартой отправки ajax-запроса.
   *                                       (пока так проще, возможно позже переделаем)
   *                                       (пока реализовано только для show).
   *        {Object} customSendParams    - произвольные параметры отправки запроса.
   * @return
   ###
   dataRequest: (params) ->
      ###*
      * Функция обработки ответа из API. Принимает и обработывает
      *  ошибки и результат запроса. Затем вызывает функцию приема данных
      *  из модуля создания серверных действий.
      *
      * @param {Object} error - ошибки (TODO: проверить и доработать).
      * @param {Object} res - объект ответа.
      * @return
      ###
      requestCallback = (error, res) ->
         errors = undefined
         json = undefined

         if res?
            errors = _getErrors(res)
            json = JSON.parse(res.text)

            ServiceServerActionCreators.dataResponse json,
                                                  errors,
                                                  componentID,
                                                  model,
                                                  APIMethod,
                                                  customEndpoint
      ###*
      * Функция конвертации параметров запроса набора данных в формат, ожидаемый
      *  на API.
      *
      * @param {Object} data               - параметры для запроса.
      * @param {String, Number} instanceID - идентификатор экземпляра. Данный
      *                                      параметр добавляется в параметры,
      *                                      передаваемые в API толmко в случае
      *                                      если заданы связанные сущности
      *                                      data.relations.
      * @param {String} APIMethod          - метод для которого формируются данные.
      * @return {Object}
      ###
      getRequestData = (requestData, instanceID, APIMethod) ->
         APIMethods = ServiceFluxConstants.APIMethods
         relations = JSON.stringify(requestData.relations)
         filterParams = JSON.stringify(requestData.filter)
         operationData = requestData.data
         indexMethod = APIMethods.index
         newMethod = APIMethods.new
         showMethod = APIMethods.show
         createMethod = APIMethods.create
         updateMethod = APIMethods.update
         destroyMethod = APIMethods.destroy
         exportMethod = APIMethods.export
         accompanyingData =JSON.stringify(requestData.accompanying)

         switch APIMethod
            # Коллекция экземпляров.
            when indexMethod
               page: requestData.page
               per_page: requestData.perPage
               matched_params: filterParams
               relations: relations
               accompanying: accompanyingData
               instance_id: instanceID if relations?
            # Существующий экземпляр.
            when showMethod
               relations: relations
            # Создание экземпляра.
            when createMethod
               data: operationData
               otherParams:
                  relations: relations
                  accompanying: accompanyingData
            # Обновление экземпляра.
            when updateMethod
               data: operationData
               otherParams:
                  relations: relations
                  accompanying: accompanyingData
            # Удаление экземпляра.
            when destroyMethod
               relations: relations
            # Экспорт данных.
            when exportMethod
               matched_params: filterParams
               relations: relations
               export_format: requestData.format
               records_on_file: requestData.recordsOnFile
               is_localize_captions: requestData.isLocalizeCaptions
               is_use_serializer: requestData.isUseAppliedSerializer

      requestData = params.requestData
      componentID = params.componentID
      instanceID = params.instanceID
      model = params.model
      subResource = params.subResource
      APIMethod = params.APIMethod
      customSendParams = params.customSendParams
      formats = ServiceFluxConstants.endpointConstants.formats
      format = params.format || formats.json
      isFileRequest = params.isFileRequest
      acceptName = @_ACCEPT_PARAM_NAME
      chars = @_CHARS
      emptyChar = chars.empty
      slashChar = chars.slash
      APIMethods = ServiceFluxConstants.APIMethods
      APIEndpoints = ServiceFluxConstants.APIEndpoints
      modelEndpoint = APIEndpoints[model]
      indexMethod = APIMethods.index
      newMethod = APIMethods.new
      showMethod = APIMethods.show
      createMethod = APIMethods.create
      updateMethod = APIMethods.update
      destroyMethod = APIMethods.destroy
      exportMethod = APIMethods.export
      endpointFormat = "#{chars.point}#{format}"

      if customSendParams? and !_.isEmpty(customSendParams)
         customEndpoint = customSendParams.endpoint
         customMethod = customSendParams.method
         customFullEndpoint = "#{modelEndpoint}#{slashChar}#{customEndpoint}#{endpointFormat}"

         request[customMethod](customFullEndpoint)
                .send(requestData.data)
                .query(accompanying: JSON.stringify(requestData.accompanying))
                .set(acceptName, _JSON_ACCEPT)
                .end requestCallback
      else
         switch APIMethod
            # Коллекция экземпляров.
            when indexMethod
               params = getRequestData(requestData, instanceID, indexMethod)
               endpointElements = [modelEndpoint]

               if subResource?
                  endpointElements =
                     endpointElements.concat(
                        [
                           slashChar
                           subResource
                        ]
                     )
               endpointElements.push endpointFormat

               #"#{modelEndpoint}#{endpointFormat}"

               request.get(endpointElements.join emptyChar)
                      .query(params)
                      .set(acceptName, _JSON_ACCEPT)
                      .end requestCallback

            # Каркас для нового экземпляра.
            when newMethod
               request.get("#{modelEndpoint}#{slashChar}#{newMethod}#{endpointFormat}")
                      .set(acceptName, _JSON_ACCEPT)
                      .end requestCallback

            # Существующий экземпляр.
            when showMethod
               params = getRequestData(requestData, null, showMethod)
               showEndpoint = "#{modelEndpoint}#{slashChar}#{instanceID}#{endpointFormat}"

               if isFileRequest
                  @_getFile(showEndpoint, params)
               else
                  request.get(showEndpoint)
                         .query(params)
                         .set(acceptName, _JSON_ACCEPT)
                         .end requestCallback

            # Создание экземпляра.
            when createMethod
               params = getRequestData(requestData, null, createMethod)

               request.post("#{modelEndpoint}#{endpointFormat}")
                      .send(params.data)
                      .query(params.otherParams)
                      .set(acceptName, _JSON_ACCEPT)
                      .end requestCallback

            # Обновление экземпляра.
            when updateMethod
               params = getRequestData(requestData, null, updateMethod)

               request.patch("#{modelEndpoint}#{slashChar}#{instanceID}#{endpointFormat}")
                      .send(params.data)
                      .query(params.otherParams)
                      .set(acceptName, _JSON_ACCEPT)
                      .end requestCallback

            # Удаление экземпляра.
            when destroyMethod
               request.del("#{modelEndpoint}#{slashChar}#{instanceID}#{endpointFormat}")
                      .query(getRequestData(requestData, null, destroyMethod))
                      .set(acceptName, _JSON_ACCEPT)
                      .end requestCallback

            # Экспорт данных.
            when exportMethod
               request.get("#{modelEndpoint}#{slashChar}#{exportMethod}#{endpointFormat}")
                      .query(getRequestData(requestData, null, exportMethod))
                      .set(acceptName, _JSON_ACCEPT)
                      .end requestCallback

   ###*
   * Функция получения файла из API. Склеивает url запроса файла и передаваемые
   *  параметры.
   *
   * @param {String} url - строка адреса, запроса файла.
   * @param {Object} params - параметры запроса.
   * @return
   ###
   _getFile: (url, params) ->
      chars = @_CHARS
      urlParams = queryString.stringify(params)
      urlWithParams =
         [
            url
            chars.question
            urlParams
         ].join chars.empty

      location.assign(urlWithParams)
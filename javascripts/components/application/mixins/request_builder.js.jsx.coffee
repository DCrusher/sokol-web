###* @jsx React.DOM ###

###* Зависимости: модули
* request          - модуль работы с ajax-запросами.
* keymirror        - модуль для генерации "зеркального" хэша.
###
request = require('superagent')
keyMirror = require('keymirror')

module.exports =
   # @const {Object} - элементы для построения адреса взаимодейтсвия с API.
   _ENDPOINT_METHODS:
      new: 'new'

   # @const {Object} - методы взаимодейтсвия с API.
   _API_ACTIONS: keyMirror(
      index: null
      new: null
      show: null
      create: null
      update: null
      delete: null
   )

   # @const {Object} - способы отправки запросов в API.
   _REQUEST_TYPES: keyMirror(
      get: null
      post: null
   )

   # @const {Object} - элементы для формирования параметров формата взаимодействия с API.
   _FORMAT_ELEMENTS:
      format: 'json'
      acceptRequest: 'Accept'
      acceptFormat: 'application/json'

   # @const {Object} - набор используемых символов.
   _RB_CHARS:
      empty: ''
      point: '.'
      slash: '/'

   # @const {Object} - возможные коды ответов.
   _RESPONSE_CODES:
      ok: 200
      bad: 400
      forbidden: 403
      notFound: 404
      serverError: 500

   ###*
   * Функция получения ответа из параметров ответа.
   *
   * @param {Object} error   - ошибка.
   * @param {Object} response - результат запроса(ответ).
   * @return {Object} - считанные параметры:
   *    {Array} errors - массив ошибок.
   *    {Object} data  - данные ответа.
   ###
   _getResponseData: (error, response) ->
      codes = @_RESPONSE_CODES
      responseStatus = response.status
      data  = JSON.parse(response.text)

      if error? or responseStatus in [codes.bad, codes.notFound]
         errors = _.concat([error], response.errors)

      errors: errors
      data: data

   ###*
   * Функция отправки запроса в API по переданным параметрам.
   *
   * @param {Object} params - параметры запроса. Вид:
   *     {String} endpoint      - адрес взаимодействия.
   *     {Object} requestParams - параметры данных запроса.
   *     {Object} queryParams   - сопутствующие параметры для запроса.
   *     {String} requestType   - тип взаимодействия с API.
   *     {Function} callback    - обработчик ответа.
   * @return
   ###
   _sendRequest:(params) ->
      endpoint = params.endpoint
      requestParams = params.requestParams
      queryParams = params.queryParams
      requestType = params.requestType or @_REQUEST_TYPES.get
      callback = params.callback
      formatElements = @_FORMAT_ELEMENTS

      request[requestType](endpoint)
             .send(requestParams)
             .query(queryParams)
             .set(formatElements.acceptRequest, formatElements.acceptFormat)
             .end(callback)
   ###*
   * Функция подготовки адреса взаимодейтсвия с API.
   *
   * @param {String} action       - наименование действия.
   * @param {String} resourceName - наименование ресурса.
   * @param {String} instanceKey  - ключ запрашиваемого экземляра ресурса.
   * @param {Boolean} isNotReduceStandard - флаг запрещающий приводит стандартные
   *                                        методы к пути до ресурса(кроме new).
   * @return {String} - адрес взаимодействия с API.
   ###
   _constructEndpoint: (action, resourceName, instanceKey, isNotReduceStandard) ->
      endpointMethods = @_ENDPOINT_METHODS
      formatElements =
      actions = @_API_ACTIONS
      chars = @_RB_CHARS
      jsonFormat = @_FORMAT_ELEMENTS.format
      standardActionNames = _.keys(actions)
      emptyChar = chars.empty
      slashChar = chars.slash
      pointChar = chars.point
      newElement = endpointMethods.new
      isStandardAction = _.includes(standardActionNames, action)
      isNewAction = action is actions.new
      isShowAction = action is actions.show

      endpointBasis = [slashChar, resourceName].join emptyChar
      endpointPostfix = [pointChar, jsonFormat].join emptyChar

      endpointElements =
         if isNewAction
            [endpointBasis, slashChar, newElement, endpointPostfix]
         else if isShowAction and instanceKey?
            [endpointBasis, slashChar, instanceKey, endpointPostfix]
         else if isStandardAction and !isNotReduceStandard
            [endpointBasis, endpointPostfix]
         else if instanceKey?
            [endpointBasis, slashChar, instanceKey, slashChar, action, endpointPostfix]
         else
            [endpointBasis, slashChar, action, endpointPostfix]

      endpointElements.join emptyChar
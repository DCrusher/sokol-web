
###* Зависимости: модули
* InsiderServerActionCreators  - модуль создания серверных административных действий
* InsiderFluxConstants         - константы для административной архитектуры flux
* request                    - библиотека для AJAX взаимодействия с API бизнес-логики
* string-template            - модуль для формирования строк из шаблонов.
###
InsiderServerActionCreators = require('../actions/insider_server_action_creators')
InsiderFluxConstants = require('../constants/insider_flux_constants')
request = require('superagent')
format = require('string-template')

###* Константы
* @param {String} _JSON_ACCEPT - тип данных для запроса
###
_JSON_ACCEPT = 'application/json'

# пути взаимодействия с API
endpoints = InsiderFluxConstants.APIEndpoints
# типовые сообщения
messages = InsiderFluxConstants.StandardMessages

###*
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
* Модуль утилит взаимодействия с API инсайдерской части
###
module.exports =

   #================================ Правообладатели  ==========================

   ###*
   * Функция запроса в API всех правообладателей. По завершению запроса
   *  создает серверное действие receiveRightholders.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getRightholders: (requestParams) ->
      params =
         page: requestParams.page
         per_page: requestParams.perPage
         matched_params:  JSON.stringify(requestParams.filter)
      request.get(endpoints.RIGHTHOLDERS)
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

            InsiderServerActionCreators.receiveRightholders json, errors

   ###*
   * Функция запроса в API полей для создания нового правообладателя
   *  По завершению запроса создает серверное действие receiveRightholderFields
   *
   * @return
   ###
   getRightholderFields: ->
      request.get(endpoints.NEW_RIGHTHOLDER)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse res.text

         InsiderServerActionCreators.receiveRightholderFields json, error

   ###*
   * Функция отправки запроса на создание нового правообладателя в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   createRightholder: (params) ->
      request.post(endpoints.RIGHTHOLDERS)
      .send(params.data)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         InsiderServerActionCreators.receiveRightholderCreationResult json, errors

   ###*
   * Функция запроса в API данных по конкретному правообладателю.
   *
   * @param {String} rightholderID - идентификатор пользовательского действия.
   * @return
   ###
   getRightholder: (rightholderID) ->
      rightholderEndpoint = "#{endpoints.RIGHTHOLDERS_ROOT}/#{rightholderID}.json"

      request.get(rightholderEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         InsiderServerActionCreators.receiveRightholder json, error

   ###*
   * Функция отправки запроса на редактирование правообладателя в API
   *
   * @param {Object} params - параметры запроса.
   * @param {String} rightholderID - идентификатор правообладателя.
   * @return
   ###
   editRightholder: (params, rightholderID) ->
      rightholderEditEndpoint = "#{endpoints.RIGHTHOLDERS_ROOT}/#{rightholderID}.json"

      request.patch(rightholderEditEndpoint)
      .send(params.data)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         InsiderServerActionCreators.receiveRightholderEditResult json, errors

   ###*
   * Функция отправки запроса на удаление правообладателя в API
   *
   * @param {String} rightholderID - идентификатор удаляемого правообладателя
   * @return
   ###
   deleteRightholder: (rightholderID) ->
      rightholderEndpoint = "#{endpoints.RIGHTHOLDERS_ROOT}/#{rightholderID}.json"

      request.del(rightholderEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         InsiderServerActionCreators.receiveRightholderDeleteResult json, errors

   ###*
   * Функция отправки запроса на удаление правообладателя в API
   *
   * @param {Object} data - хэш с параметрами на отправку. Вид:
   *     {Object} markedKeys    - хэш с параметрами отмеченных строк и
   *                              строк со снятой отметкой.
   *     {Object} processedData - специфичные данные для операции, подготовленные
   *                              пользовательскими обработчиками.
   *     {Boolean} isAllMarked  - флаг отметки всех строк.
   *     {Object} filterParams  - параметры фильтра.
   * @return
   ###
   deleteRightholders: (data) ->
      request.del(endpoints.GROUP_DESTROY_RIGHTHOLDERS)
             .send(data)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                InsiderServerActionCreators.receiveRightholdersDeleteResult json, errors

   #================================ Документальные основания ==================

   ###*
   * Функция запроса в API всех документальных оснований. По завершению запроса
   *  создает серверное действие receiveRightholders.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getDocumentalBases: (requestParams) ->
      params =
         page: requestParams.page
         per_page: requestParams.perPage
         matched_params:  JSON.stringify(requestParams.filter)
      request.get(endpoints.DB)
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

            InsiderServerActionCreators.receiveDocumentalBases json, errors


   #================================ Собственность  ============================

   ###*
   * Функция запроса в API всех правообладателей. По завершению запроса
   *  создает серверное действие receiveRightholders.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getProperties: (requestParams) ->
      params =
         page: requestParams.page
         per_page: requestParams.perPage
         matched_params: JSON.stringify(requestParams.filter)

      request.get(endpoints.PROPERTIES)
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

            InsiderServerActionCreators.receiveProperties json, errors

   ###*
   * Функция запроса в API полей для создания нового правообладателя
   *  По завершению запроса создает серверное действие receiveRightholderFields
   *
   * @return
   ###
   getPropertyFields: ->
      request.get(endpoints.NEW_PROPERTIES)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse res.text

         InsiderServerActionCreators.receivePropertyFields json, error

   ###*
   * Функция отправки запроса на создание нового правообладателя в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   createProperty: (params) ->

      request.post(endpoints.PROPERTIES)
      .send(params.data)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         InsiderServerActionCreators.receivePropertyCreationResult json, errors

   ###*
   * Функция запроса в API данных по конкретному правообладателю.
   *
   * @param {String} propertyID - идентификатор пользовательского действия.
   * @return
   ###
   getProperty: (propertyID) ->
      propertyEndpoint = "#{endpoints.PROPERTIES_ROOT}/#{propertyID}.json"

      request.get(propertyEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         InsiderServerActionCreators.receiveProperty json, error

   ###*
   * Функция отправки запроса на редактирование правообладателя в API
   *
   * @param {Object} params - параметры запроса.
   * @param {String} propertyID - идентификатор правообладателя.
   * @return
   ###
   editProperty: (params, propertyID) ->
      propertyEditEndpoint = "#{endpoints.PROPERTIES_ROOT}/#{propertyID}.json"

      request.patch(propertyEditEndpoint)
      .send(params.data)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         InsiderServerActionCreators.receivePropertyEditResult json, errors

   ###*
   * Функция отправки запроса на удаление правообладателя в API
   *
   * @param {String} propertyID - идентификатор удаляемого правообладателя
   * @return
   ###
   deleteProperty: (propertyID) ->
      propertyEndpoint = "#{endpoints.PROPERTIES_ROOT}/#{propertyID}.json"

      request.del(propertyEndpoint)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                InsiderServerActionCreators.receivePropertyDeleteResult json, errors

   ###*
   * Функция отправки запроса на удаление правообладателя в API
   *
   * @param {Object} data - хэш с параметрами на отправку. Вид:
   *     {Object} markedKeys    - хэш с параметрами отмеченных строк и
   *                              строк со снятой отметкой.
   *     {Object} processedData - специфичные данные для операции, подготовленные
   *                              пользовательскими обработчиками.
   *     {Boolean} isAllMarked  - флаг отметки всех строк.
   *     {Object} filterParams  - параметры фильтра.
   * @return
   ###
   deleteProperties: (data) ->
      request.del(endpoints.GROUP_DESTROY_PROPERTIES)
             .send(data)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                InsiderServerActionCreators.receivePropertiesDeleteResult json, errors

   #================================ Правообладания  ============================

   ###*
   * Функция запроса в API всех правообладаний. По завершению запроса
   *  создает серверное действие receiveOwnerships.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} matchedParams - параметры выборки.
   * @return
   ###
   getOwnerships: (requestParams) ->
      params =
         page: requestParams.page
         per_page: requestParams.perPage
         matched_params:  JSON.stringify(requestParams.filter)
      request.get(endpoints.OWNERSHIPS)
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

            InsiderServerActionCreators.receiveOwnerships json, errors

   ###*
   * Функция запроса в API полей для создания нового правообладания
   *  По завершению запроса создает серверное действие receiveOwnershipFields
   *
   * @return
   ###
   getOwnershipFields: ->
      request.get(endpoints.NEW_OWNERSHIP)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse res.text

         InsiderServerActionCreators.receiveOwnershipFields json, error

   ###*
   * Функция отправки запроса на создание нового правообладания в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   createOwnership: (params) ->
      request.post(endpoints.OWNERSHIPS)
      .send(params.data)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         InsiderServerActionCreators.receiveOwnershipCreationResult json, errors

   ###*
   * Функция запроса в API данных по конкретному правообладанию.
   *
   * @param {String} ownershipID - идентификатор правообладания.
   * @return
   ###
   getOwnership: (ownershipID) ->
      ownershipEndpoint = "#{endpoints.OWNERSHIPS_ROOT}/#{ownershipID}.json"

      request.get(ownershipEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         InsiderServerActionCreators.receiveOwnership json, error

   ###*
   * Функция отправки запроса на редактирование правообладания в API
   *
   * @param {Object} params - параметры запроса.
   * @param {String} ownershipID - идентификатор правообладания.
   * @return
   ###
   editOwnership: (params, ownershipID) ->
      ownershipEditEndpoint = "#{endpoints.OWNERSHIPS_ROOT}/#{ownershipID}.json"

      request.patch(ownershipEditEndpoint)
      .send(params.data)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         InsiderServerActionCreators.receiveOwnershipEditResult json, errors

   ###*
   * Функция отправки запроса на удаление правообладания в API
   *
   * @param {String} ownershipID - идентификатор удаляемого правообладания
   * @return
   ###
   deleteOwnership: (ownershipID) ->
      ownershipEndpoint = "#{endpoints.OWNERSHIPS_ROOT}/#{ownershipID}.json"

      request.del(ownershipEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         InsiderServerActionCreators.receiveOwnershipDeleteResult json, errors

   ###*
   * Функция отправки запроса на удаление правообладания в API
   *
   * @param {String} ownershipID - идентификатор удаляемого правообладания
   * @return
   ###
   getRentContract: (ownershipID) ->
      request.get("#{endpoints.OWNERSHIPS_ROOT}/download.json")
      .query({ownership_id: ownershipID})
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)
               window.location = json.url

            InsiderServerActionCreators.receiveOwnershipDownloadContractResult json, errors

   ###*
   * Функция отправки запроса на формирование формы документа.
   *
   * @param {String} ownershipID - идентификатор правообладания.
   * @param {Object} params - параметры запроса. Вид:
   *                 'document' - тип документа.
   *                 'format'   - формат.
   * @return
   ###
   getDocumentForm: (ownershipID, params) ->
      request.get("#{endpoints.OWNERSHIPS_ROOT}/#{ownershipID}/document_form.json")
      .query({doc_type: params.document, doc_format: params.format})
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            if errors?
               alert(errors)
            else
               json = JSON.parse(res.text)
               window.open(json.url, '_blank')

            InsiderServerActionCreators.receiveOwnershipDownloadContractResult json, errors

   #================================ Платежи  ============================

   ###*
   * Функция отправки запроса на перевод платежа в статус "порождающего".
   *
   * @param {Number} paymentID - идентификатор платежа.
   * @return
   ###
   paymentToGenerative: (paymentID) ->
      toGenerativeEndpoint = format(endpoints.PAYMENT_TO_GENERATIVE, paymentID)

      request.post(toGenerativeEndpoint)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                InsiderServerActionCreators.receiveToGenerative json, errors

   ###*
   * Функция отправки запроса на подтверждение(принятие) платежей.
   *
   * @param {Array<Object>} acceptedPayments - параметры принимаемых платежей
   *                                           (payment: [key], plan: [key]).
   * @return
   ###
   acceptPayments: (acceptedPayments) ->
      request.post(endpoints.PAYMENTS_ACCEPT)
             .send({acceptable: JSON.stringify(acceptedPayments)})
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                InsiderServerActionCreators.receivePaymentsAccept json, errors
   ###*
   * Функция запроса на отклонение платежей.
   *
   * @param {Array} rejectedPayments - отклоняемые платежи.
   * @return
   ###
   rejectPayments: (rejectedPayments) ->
      request.post(endpoints.PAYMENTS_REJECT)
             .send({rejected: rejectedPayments})
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                InsiderServerActionCreators.receivePaymentsReject json, errors

   ###*
   * Функция запроса отправки платежей на уточнение.
   *
   * @param {Array} clarifyPayments - уточняемые платежи.
   * @return
   ###
   clarifyPayments: (clarifyPayments) ->
      request.post(endpoints.PAYMENTS_CLARIFY)
             .send({clarified: clarifyPayments})
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                InsiderServerActionCreators.receivePaymentsClarify json, errors

   ###*
   * Функция запроса отправки платежей на уточнение.
   *
   * @param {Boolean} isAllMarked - флаг отмеченности всех платежей.
   * @param {Object<Array>} markedParams  - параметры отметок экземпляров.
   * @return
   ###
   clarifyingPayments: (isAllMarked, markedParams) ->
      request.post(endpoints.PAYMENTS_CLARIFYING)
             .send({marked_params: markedParams, is_all_marked: isAllMarked})
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                printedFormUrl = json.printed_form_url

                if printedFormUrl?
                   window.location = printedFormUrl


                InsiderServerActionCreators.receivePaymentsClarifying json, errors

   ###*
   * Функция запроса на отправку платежа на уточнение.
   *
   * @param {Array} paymentID - уточняемые платежи.
   * @return
   ###
   getClarifiedAttributes: (paymentID) ->
      clarifiedAttributesEndpoint = format(endpoints.PAYMENT_CLARIFIED_ATTR, paymentID)

      request.get(clarifiedAttributesEndpoint)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                InsiderServerActionCreators.receiveClarifiedAttributes json, errors

   ###*
   * Функция запроса на отправку платежа на уточнение.
   *
   * @param {Object} requestParams - параметры запроса.
   * @param {Array} paymentID - уточняемые платежи.
   * @return
   ###
   setClarifiedAttributes: (requestParams, paymentID) ->
      clarifiedAttributesEndpoint = format(endpoints.PAYMENT_CLARIFIED_ATTR, paymentID)

      request.post(clarifiedAttributesEndpoint)
             .send(requestParams.data)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                InsiderServerActionCreators.receiveSetClarifiedAttributesResult json, errors

###* Зависимости: модули
* SokolAppDispather    - flux диспетчер
* InsiderFluxConstants - константы для архитектуры flux инсайдеров
* InsiderWebAPIUtils     - модуль утилит взаимодействия с административным API системы
###
SokolAppDispatcher = require('../dispatcher/app_dispatcher')
InsiderFluxConstants = require('../constants/insider_flux_constants')
InsiderWebAPIUtils = require('../utils/insider_web_api_utils')

# типы действий
ActionTypes = InsiderFluxConstants.ActionTypes

###*
* модуль создания клиентских административных действий
###
module.exports =
  #================================ Правообладатели ===========================

   ###
   * Функция запроса всех правообладателей через утилиты взаимодействия с инсайдерской API.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getRightholders: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Rightholder.RIGHTHOLDERS_REQUEST
      )
      InsiderWebAPIUtils.getRightholders(requestParams)

   ###*
   * Функция запроса полей для формы создания нового правообладателя
   *
   * @return
   ###
   getRightholderFields: ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Rightholder.RIGHTHOLDER_NEW_REQUEST
      )
      InsiderWebAPIUtils.getRightholderFields()

   ###*
   * Функция создания пользовательского запроса на создание нового правообладателя.
   *
   * @param {Object} requestParams - параметры запроса.
   * @return
   ###
   createRightholder: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Rightholder.RIGHTHOLDER_CREATE_REQUEST
      )
      InsiderWebAPIUtils.createRightholder(requestParams)

   ###*
   * Функция запроса данных по правообладателю.
   *
   * @param {Number} rightholderID - идентификатор правообладателя.
   * @return
   ###
   getRightholder: (rightholderID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Rightholder.RIGHTHOLDER_GET_REQUEST

      InsiderWebAPIUtils.getRightholder(rightholderID)

   ###*
   * Функция создания пользовательского запроса на редактирование данных правообладателя.
   *
   * @param {Object} requestParams - параметры запроса.
   * @param {String} rightholderID     - идентификатор правообладателя.
   * @return
   ###
   editRightholder: (requestParams, rightholderID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Rightholder.RIGHTHOLDER_EDIT_REQUEST

      InsiderWebAPIUtils.editRightholder(requestParams, rightholderID)

   ###*
   * Функция удаления правообладателя.
   *
   * @param {String} rightholderID - идентификатор удаляемого правообладателя.
   * @return
   ###
   deleteRightholder: (rightholderID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Rightholder.RIGHTHOLDER_DELETE_REQUEST

      InsiderWebAPIUtils.deleteRightholder(rightholderID)

   ###*
   * Функция массового удаления правообладателей.
   *
   * @param {Object} data - хэш с параметрами на отправку. Вид:
   *     {Object} markedKeys    - хэш с параметрами отмеченных строк и
   *                              строк со снятой отметкой.
   *     {Object} processedData - специфичные данные для операции, подготовленные
   *                              пользовательскими обработчиками.
   *     {Boolean} isAllMarked  - флаг отметки всех строк.
   *     {Object} filterParams - параметры фильтра.
   * @return
   ###
   deleteRightholders: (data) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Property.RIGHTHOLDER_GROUP_DELETE_REQUEST

      InsiderWebAPIUtils.deleteRightholders(data)

  #================================ Документальные обоснования =================

   ###
   * Функция запроса всех документальных обоснований через утилиты взаимодействия
   *  с инсайдерской API.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getDocumentalBases: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.DocumentalBasis.DB_REQUEST
      )
      InsiderWebAPIUtils.getDocumentalBases(requestParams)

  #================================ Собственность ==============================

   ###
   * Функция запроса всей имущества через утилиты взаимодействия с инсайдерской API.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getProperties: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Property.PROPERTIES_REQUEST
      )
      InsiderWebAPIUtils.getProperties(requestParams)

   ###*
   * Функция запроса полей для формы создания новой имущества
   *
   * @return
   ###
   getPropertyFields: ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Property.PROPERTY_NEW_REQUEST
      )
      InsiderWebAPIUtils.getPropertyFields()

   ###*
   * Функция создания пользовательского запроса на создание новой имущества.
   *
   * @param {Object} requestParams - параметры запроса.
   * @return
   ###
   createProperty: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Property.PROPERTY_CREATE_REQUEST
      )
      InsiderWebAPIUtils.createProperty(requestParams)

   ###*
   * Функция запроса данных по имущества.
   *
   * @param {Number} propertyID - идентификатор имущества.
   * @return
   ###
   getProperty: (propertyID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Property.PROPERTY_GET_REQUEST

      InsiderWebAPIUtils.getProperty(propertyID)

   ###*
   * Функция создания пользовательского запроса на редактирование данных имущества.
   *
   * @param {Object} requestParams - параметры запроса.
   * @param {String} propertyID     - идентификатор имущества.
   * @return
   ###
   editProperty: (requestParams, propertyID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Property.PROPERTY_EDIT_REQUEST

      InsiderWebAPIUtils.editProperty(requestParams, propertyID)

   ###*
   * Функция удаления имущества.
   *
   * @param {String} propertyID - идентификатор удаляемой имущества.
   * @return
   ###
   deleteProperty: (propertyID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Property.PROPERTY_DELETE_REQUEST

      InsiderWebAPIUtils.deleteProperty(propertyID)

   ###*
   * Функция массового удаления имущества.
   *
   * @param {Object} data - хэш с параметрами на отправку. Вид:
   *     {Object} markedKeys    - хэш с параметрами отмеченных строк и
   *                              строк со снятой отметкой.
   *     {Object} processedData - специфичные данные для операции, подготовленные
   *                              пользовательскими обработчиками.
   *     {Boolean} isAllMarked  - флаг отметки всех строк.
   *     {Object} filterParams - параметры фильтра.
   * @return
   ###
   deleteProperties: (data) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Property.PROPERTY_GROUP_DELETE_REQUEST

      InsiderWebAPIUtils.deleteProperties(data)

#================================ Правообладания ==============================

   ###
   * Функция запроса всех правообладаний через утилиты взаимодействия с инсайдерской API.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getOwnerships: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Ownership.OWNERSHIPS_REQUEST
      )
      InsiderWebAPIUtils.getOwnerships(requestParams)

   ###*
   * Функция запроса полей для формы создания нового правообладания
   *
   * @return
   ###
   getOwnershipFields: ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Ownership.OWNERSHIP_NEW_REQUEST
      )
      InsiderWebAPIUtils.getOwnershipFields()

   ###*
   * Функция создания пользовательского запроса на создание нового правообладания.
   *
   * @param {Object} requestParams - параметры запроса.
   * @return
   ###
   createOwnership: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Ownership.OWNERSHIP_CREATE_REQUEST
      )
      InsiderWebAPIUtils.createOwnership(requestParams)

   ###*
   * Функция запроса данных по правообладанию.
   *
   * @param {Number} ownershipID - идентификатор правообладания.
   * @return
   ###
   getOwnership: (ownershipID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Ownership.OWNERSHIP_GET_REQUEST

      InsiderWebAPIUtils.getOwnership(ownershipID)

   ###*
   * Функция создания пользовательского запроса на редактирование данных правообладания.
   *
   * @param {Object} requestParams - параметры запроса.
   * @param {String} ownershipID     - идентификатор правообладания.
   * @return
   ###
   editOwnership: (requestParams, ownershipID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Ownership.OWNERSHIP_EDIT_REQUEST

      InsiderWebAPIUtils.editOwnership(requestParams, ownershipID)

   ###*
   * Функция удаления правообладания.
   *
   * @param {String} ownershipID - идентификатор удаляемого правообладания.
   * @return
   ###
   deleteOwnership: (ownershipID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Ownership.OWNERSHIP_DELETE_REQUEST

      InsiderWebAPIUtils.deleteOwnership(ownershipID)

   ###*
   * Функция скачивания договора аренды.
   *
   * @param {String} ownershipID - идентификатор правообладания аренды.
   * @return
   ###
   getRentContract: (ownershipID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Ownership.OWNERSHIP_DOWNLOAD_DOCUMENT_REQUEST

      InsiderWebAPIUtils.getRentContract(ownershipID)

   ###*
   * Функция запроса на формирование формы документа.
   *
   * @param {String} ownershipID - идентификатор правообладания аренды.
   * @param {Object} params - параметры запроса. Вид:
   *                 'document' - тип документа.
   *                 'format'   - формат.
   * @return
   ###
   getDocumentForm: (ownershipID, params) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Ownership.OWNERSHIP_DOWNLOAD_DOCUMENT_REQUEST

      InsiderWebAPIUtils.getDocumentForm(ownershipID, params)


#================================ Платежи ==============================
   ###*
   * Функция подготовки запроса на перевод платежа в раздят "порождающих".
   *
   * @param {Object} paymentID - идентификатор платежа.
   * @return
   ###
   paymentToGenerative: (paymentID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Payment.TO_GENERATIVE_REQUEST

      InsiderWebAPIUtils.paymentToGenerative(paymentID)

   ###*
   * Функция подготовки запроса на принятие платежей.
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
   acceptPayments: (data) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Payment.ACCEPT_REQUEST

      InsiderWebAPIUtils.acceptPayments(data.processedData)

   ###*
   * Функция подготовки запроса на отклонение платежей.
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
   rejectPayments: (data) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Payment.REJECT_REQUEST

      InsiderWebAPIUtils.rejectPayments(data.processedData)

   ###*
   * Функция подготовки запроса отправки платежей на уточнение.
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
   clarifyPayments: (data) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Payment.CLARIFY_REQUEST

      InsiderWebAPIUtils.clarifyPayments(data.processedData)

   ###*
   * Функция подготовки запроса отправки платежей для формирования запроса на уточнение.
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
   clarifyingPayments: (data) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Payment.CLARIFYING_REQUEST

      InsiderWebAPIUtils.clarifyingPayments(data.isAllMarked,
                                            data.markedKeys)

   ###*
   * Функция подготовки запроса получения уточняемых аттрибутов платежа.
   *
   * @param {Object} paymentID - идентификатор платежа.
   * @return
   ###
   getClarifiedAttributes: (paymentID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Payment.CLARIFIED_ATTR_GET_REQUEST

      InsiderWebAPIUtils.getClarifiedAttributes(paymentID)

   ###*
   * Функция подготовки запроса получения уточняемых аттрибутов платежа.
   *
   * @param {Object} requestParams - параметры запроса.
   * @param {Object} paymentID - идентификатор платежа.
   * @return
   ###
   setClarifiedAttributes: (requestParams, paymentID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Payment.CLARIFIED_ATTR_SET_REQUEST

      InsiderWebAPIUtils.setClarifiedAttributes(requestParams, paymentID)
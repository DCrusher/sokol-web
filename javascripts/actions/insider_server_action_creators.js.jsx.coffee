###* Зависимости: модули
* SokolAppDispather  - flux диспетчер
* InsiderFluxConstants - константы для административной архитектуры flux
###
SokolAppDispather = require('../dispatcher/app_dispatcher')
InsiderFluxConstants = require('../constants/insider_flux_constants')

# Типы действий
ActionTypes = InsiderFluxConstants.ActionTypes

###*
*  Модуль создания серверных административных действий
###
module.exports =

   #================================ Правообладатели ===========================

   ###*
   * Функция создания серверного действия в ответ на получение всех правообладателей.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveRightholders: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Rightholder.RIGHTHOLDERS_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на получение полей правообладателей.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveRightholderFields: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Rightholder.RIGHTHOLDER_NEW_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на запрос создания правообладателя.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveRightholderCreationResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Rightholder.RIGHTHOLDER_CREATE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на получение данных по правообладателю.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveRightholder: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Rightholder.RIGHTHOLDER_GET_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на запрос
   *  редактирования данных правообладателя.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveRightholderEditResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Rightholder.RIGHTHOLDER_EDIT_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *  на запрос удаления правообладателя.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveRightholderDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Rightholder.RIGHTHOLDER_DELETE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *  на запрос группового удаления правообладателей.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveRightholdersDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Rightholder.RIGHTHOLDER_GROUP_DELETE_RESPONSE
         json: json
         errors: errors
      )


   #================================ Документальные обоснования ================

   ###*
   * Функция создания серверного действия в ответ на получение всех документальных оснований.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveDocumentalBases: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.DocumentalBasis.DB_RESPONSE
         json: json
         errors: errors
      )


   #================================ Собственность =============================

   ###*
   * Функция создания серверного действия в ответ на получение всей собственности.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveProperties: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Property.PROPERTIES_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на получение полей собственности.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyFields: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Property.PROPERTY_NEW_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на запрос создания собственности.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyCreationResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Property.PROPERTY_CREATE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на получение данных по собственнности.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveProperty: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Property.PROPERTY_GET_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на запрос
   *  редактирования данных собственности.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyEditResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Property.PROPERTY_EDIT_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *  на запрос удаления собственности.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Property.PROPERTY_DELETE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *  на запрос массового удаления собственности.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertiesDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Property.PROPERTY_GROUP_DELETE_RESPONSE
         json: json
         errors: errors
      )

   #================================ Правообладания =============================

   ###*
   * Функция создания серверного действия в ответ на получение всех правообладаний.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveOwnerships: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Ownership.OWNERSHIPS_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на получение полей правообладания.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveOwnershipFields: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Ownership.OWNERSHIP_NEW_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на запрос создания правообладания.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveOwnershipCreationResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Ownership.OWNERSHIP_CREATE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на получение данных по правообладанию.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveOwnership: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Ownership.OWNERSHIP_GET_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на запрос
   *  редактирования данных правообладания.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveOwnershipEditResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Ownership.OWNERSHIP_EDIT_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *  на запрос удаления правообладания.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveOwnershipDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Ownership.OWNERSHIP_DELETE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *  на запрос удаления правообладания.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveOwnershipDownloadContractResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Ownership.OWNERSHIP_DOWNLOAD_DOCUMENT_RESPONSE
         json: json
         errors: errors
      )

   #================================ Платежи  ============================

   ###*
   * Функция создания серверного действия в ответ на перевод
   *  платежа в состояние "порождающего".
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveToGenerative: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Payment.TO_GENERATIVE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на запрос аттрибутов
   *  на уточнение.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveClarifiedAttributes: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Payment.CLARIFIED_ATTR_GET_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на установку аттрибутов на
   *  уточнение.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveSetClarifiedAttributesResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Payment.CLARIFIED_ATTR_SET_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *  на принятия платежей.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePaymentsAccept: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Payment.ACCEPT_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *  на отклонения платежей.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePaymentsReject: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Payment.REJECT_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *  на отправку платежей на уточнение.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePaymentsClarify: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Payment.CLARIFY_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *  на отправку платежей на уточнение.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePaymentsClarifying: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Payment.CLARIFYING_RESPONSE
         json: json
         errors: errors
      )
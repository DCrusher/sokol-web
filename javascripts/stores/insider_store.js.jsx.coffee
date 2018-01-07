
###* Зависимости: модули
* SokolAppDispather          - flux диспетчер
* InsiderFluxConstants         - константы для административной архитектуры flux
* AdminWebAPIUtils           - модуль утилит взаимодействия с административным API системы
* EventEmitter               - модуль для работы с системой событий
* assign                     - модуль для слияния объектов
###
SokolAppDispatcher = require('../dispatcher/app_dispatcher')
InsiderFluxConstants = require('../constants/insider_flux_constants')
EventEmitter = require('events').EventEmitter
assign = require('object-assign')

###* Константы
* {String} _CHANGE_EVENT - тип события на изменение хранилища
###
_CHANGE_EVENT = InsiderFluxConstants.EventTypes.CHANGE_EVENT

# Типы событий
ActionTypes = InsiderFluxConstants.ActionTypes

###*
* @param {Object} - хэш с данными по правообладателями. Вид:
*     {Array} records         - набор записей.
*     {Object} paginateParams - параметры постраничного вывода. Вид:
*           {Number} totalPages       - общее кол-во страниц.
*           {Object} entriesStatistic - параметры статистики по возвращенным записям. Вид:
*              {Number} start - с какой.
*              {Number} end   - по какую.
*              {Number} total - сколько всего.
*     {entityParams} - хэш с данными по отображаемой сущности. Вид:
*           {Object} fieldParams      - параметры полей сущности,
*                                       возвращаемые ModelReader.
*           {Object} externalEntities - параметры внешних связанных сущносей,
*                                       возвращаемые ModelReader
###
_rightholdersResult = {}

# {Object} - хэш с данными по правообладателю.
_rightholderParams = {}

# {Object} - результат создания правообладателя.
_rightholderCreationResult = {}

# {Object} - результат редактирования данных правообладателя.
_rightholderEditResult = undefined

# {Object} - результат удаления правообладателя.
_rightholderDeleteResult = undefined

# {Object} - результат группового удаления имущества.
_rightholdersDeleteResult = undefined

# {Array} - массив, для хранения всех документальных оснований
_documentalBasesResult = []



# {Object} - хэш с данными по имуществу. Вид аналогичен правообладателям.
_propertiesResult = {}

# {Object} - хэш с данными по полям имущества.
_propertyFields = {}

_propertyData = {}

# {Object} - результат создания имущества.
_propertyCreationResult = {}

# {Object} - результат редактирования данных имущества.
_propertyEditResult = undefined

# {Object} - результат удаления имущества.
_propertyDeleteResult = undefined

# {Object} - результат группового удаления имущества.
_propertiesDeleteResult = undefined


# {Array} - массив, для хранения всех правообладаний.
_ownershipsResult = []

# {Object} - результат создания правообладания.
_ownershipCreationResult = {}

# {Object} - хэш полей правообладания.
_ownershipFields = {}

# {Object} - хэш с данными по правообладанию.
_ownershipData = {}

# {Object} - результат редактирования данных правообладания.
_ownershipEditResult = undefined

# {Object} - результат удаления правообладания.
_ownershipDeleteResult = undefined

# {Object} - результат скачивания документа.
_ownershipDowloadResult = undefined

# {Object} - результат перевода платежа в состояние "порождающего".
_paymentToGenerativeResult = undefined

# {Object} - результат принятия платежей.
_paymentsAcceptResult = undefined

# {Object} - результат отклонения платежей.
_paymentsRejectResult = undefined

# {Object} - результат отправки платежей на уточнение.
_paymentsClarifyResult = undefined

# {Object} - результат формирования уточнения по платежам.
_paymentsClarifyingResult = undefined

# {Object} - параметры уточняемых аттрибутов платежа.
_paymentClarifiedAttributes = undefined

# {Object} - результат установки аттрибутов на уточнение для платежа.
_paymentSetClarifiedAttributesResult = undefined

# {String} - последнее событие.
_lastInteraction = undefined

###*
* модуль хранилища клиентских состояний для инсайдерской части.
###
InsiderStore = assign({}, EventEmitter.prototype,
   emitChange: ->
      @emit(_CHANGE_EVENT)

   addChangeListener: (callback) ->
      @on(_CHANGE_EVENT, callback)

   removeChangeListener: (callback) ->
      @removeListener(_CHANGE_EVENT, callback)

   ###*
   * Геттер последнего события
   * @return {String}
   ###
   getLastInteraction: ->
      _lastInteraction

   ###*
   * Геттер  параметров всех правообладателей.
   *
   * @return {Object}
   ###
   getRightholders: ->
      _rightholdersResult

   ###*
   * Геттер полей правообладателей.
   *
   * @return {Object}
   ###
   getRightholderFields: ->
      _rightholderFields

   ###*
   * Геттер данных по правообладателю.
   *
   * @return {Object}
   ###
   getRightholderParams: ->
      _rightholderParams


   ###*
   * Геттер результата создания правообладателя.
   *
   * @return {Object}
   ###
   getRightholderCreationResult: ->
      _rightholderCreationResult

   ###*
   * Геттер результата редактирования данных правообладателя.
   *
   * @return {Object}
   ###
   getRightholderEditResult: ->
      _rightholderEditResult

   ###*
   * Геттер результата удаления правообладателя.
   *
   * @return {Object}
   ###
   getRightholderDeleteResult: ->
      _rightholderDeleteResult

   ###*
   * Геттер результата группового удаления правообладателей.
   *
   * @return {Object}
   ###
   getRightholdersDeleteResult: ->
      _rightholdersDeleteResult

   ###*
   * Геттер всех документальных оснований.
   *
   * @return {Array}
   ###
   getDocumentalBases: ->
      _documentalBasesResult.documents

   ###*
   * Геттер параметров полей  документальных оснований.
   *
   * @return {Object}
   ###
   getDocumentalBasesFieldParams: ->
      _documentalBasesResult.filedParams

   ###*
   * Геттер кол-ва страниц с данными документальных оснований.
   *
   * @return {Number}
   ###
   getDocumentalBasesPageCount: ->
      _documentalBasesResult.totalPages

   ###*
   * Геттер параметров статистики записей документальных оснований.
   *  (с какой, по какую, сколько всего)
   *
   * @return {Object}
   ###
   getDocumentalBasesEntriesStatistic: ->
      _documentalBasesResult.entriesStatistic

   ###*
   * Геттер всей имущества
   *
   * @return {Array}
   ###
   getProperties: ->
      _propertiesResult

   ###*
   * Геттер полей имущества.
   *
   * @return {Object}
   ###
   getPropertyFields: ->
      _propertyFields

   ###*
   * Геттер данных по имущества.
   *
   * @return {Object}
   ###
   getPropertyData: ->
      _propertyData

   ###*
   * Геттер результата создания имущества.
   *
   * @return {Object}
   ###
   getPropertyCreationResult: ->
      _propertyCreationResult

   ###*
   * Геттер результата редактирования данных имущества.
   *
   * @return {Object}
   ###
   getPropertyEditResult: ->
      _propertyEditResult

   ###*
   * Геттер результата удаления имущества.
   *
   * @return {Object}
   ###
   getPropertyDeleteResult: ->
      _propertyDeleteResult

   ###*
   * Геттер результата группового удаления имущества.
   *
   * @return {Object}
   ###
   getPropertiesDeleteResult: ->
      _propertiesDeleteResult


   ###*
   * Геттер всех правообладаний
   *
   * @return {Array}
   ###
   getOwnerships: ->
      _ownershipsResult.ownerships

   ###*
   * Геттер параметров полей правообладаний.
   *
   * @return {Object}
   ###
   getOwnershipsFieldParams: ->
      _ownershipsResult.filedParams

   ###*
   * Геттер кол-ва страниц с данными правообладания.
   *
   * @return {Number}
   ###
   getOwnershipsPageCount: ->
      _ownershipsResult.totalPages

   ###*
   * Геттер параметров статистики записей правообладания. (с какой, по какую, сколько всего)
   *
   * @return {Object}
   ###
   getOwnershipsEntriesStatistic: ->
      _ownershipsResult.entriesStatistic

   ###*
   * Геттер полей правообладаний.
   *
   * @return {Object}
   ###
   getOwnershipFields: ->
      _ownershipFields

   ###*
   * Геттер данных по правообладанию.
   *
   * @return {Object}
   ###
   getOwnershipData: ->
      _ownershipData

   ###*
   * Геттер результата создания правообладания.
   *
   * @return {Object}
   ###
   getOwnershipCreationResult: ->
      _ownershipCreationResult

   ###*
   * Геттер результата редактирования данных правообладания.
   *
   * @return {Object}
   ###
   getOwnershipEditResult: ->
      _ownershipEditResult

   ###*
   * Геттер результата удаления правообладания.
   *
   * @return {Object}
   ###
   getOwnershipDeleteResult: ->
      _ownershipDeleteResult

   ###*
   * Геттер результата скачивания документа правообладания.
   *
   * @return {Object}
   ###
   getOwnershipDowloadResult: ->
      _ownershipDowloadResult

   ###*
   * Геттер результата перевода платежа в статус "порождающего".
   *
   * @return {Object}
   ###
   getPaymentToGenerativeResult: ->
      _paymentToGenerativeResult

   ###*
   * Геттер результата принятия платежей.
   *
   * @return {Object}
   ###
   getPaymentsAcceptResult: ->
      _paymentsAcceptResult

   ###*
   * Геттер результата отклонения платежей.
   *
   * @return {Object}
   ###

   getPaymentsRejectResult: ->
      _paymentsRejectResult

   ###*
   * Геттер результата уточненния платежей.
   *
   * @return {Object}
   ###
   getPaymentsClarifyResult: ->
      _paymentsClarifyResult

   ###*
   * Геттер результата отправки платежей на уточнение.
   *
   * @return {Object}
   ###
   getPaymentsClarifyingResult: ->
      _paymentsClarifyingResult

   ###*
   * Геттер аттрибутов для уточнения платежа.
   *
   * @return {Object}
   ###
   getPaymentClarifiedAttributes: ->
      _paymentClarifiedAttributes

   ###*
   * Геттер результата установки аттрибутов для уточнения платежа.
   *
   * @return {Object}
   ###
   getSetPaymentClarifiedAttributesResult: ->
      _paymentSetClarifiedAttributesResult

   dispatcherIndex: SokolAppDispatcher.register (payload) ->
      source = payload.source
      action = payload.action
      result = action.json
      errors = action.errors
      isViewAction = source is InsiderFluxConstants.PayloadSources.VIEW_ACTION
      _lastInteraction = action.type

      # Пока не обрабатываем события интерфейса.
      return if isViewAction

      switch _lastInteraction
         # событие на возврат всех правообладателей
         when ActionTypes.Rightholder.RIGHTHOLDERS_RESPONSE
            _rightholdersResult = result
            InsiderStore.emitChange()
         # событие на возврат полей для правообладателя.
         when ActionTypes.Rightholder.RIGHTHOLDER_NEW_RESPONSE
            _rightholderFields = result.fields
            _rightholderParams = action
            InsiderStore.emitChange()
         # событие на возврат данных по правообладателя.
         when ActionTypes.Rightholder.RIGHTHOLDER_GET_RESPONSE
            _rightholderParams = action
            InsiderStore.emitChange()
         # событие на результат создания правообладателя.
         when ActionTypes.Rightholder.RIGHTHOLDER_CREATE_RESPONSE
            _rightholderCreationResult = action
            InsiderStore.emitChange()
         # событие на возврат результата редактирование данных правообладателя.
         when ActionTypes.Rightholder.RIGHTHOLDER_EDIT_RESPONSE
            _rightholderEditResult = action
            InsiderStore.emitChange()
         # событие на возврат результата удаления правообладателя.
         when ActionTypes.Rightholder.RIGHTHOLDER_DELETE_RESPONSE
            _rightholderDeleteResult = action
            InsiderStore.emitChange()
         # событие на возврат результата группового удаления правообладателей.
         when ActionTypes.Rightholder.RIGHTHOLDER_GROUP_DELETE_RESPONSE
            _rightholdersDeleteResult = action
            InsiderStore.emitChange()

         # событие на возврат всех документальных оснований
         when ActionTypes.DocumentalBasis.DB_RESPONSE
            _documentalBasesResult = result
            InsiderStore.emitChange()

         # событие на возврат всей имущества
         when ActionTypes.Property.PROPERTIES_RESPONSE
            _propertiesResult = result
            InsiderStore.emitChange()
         # событие на возврат полей для имущества
         when ActionTypes.Property.PROPERTY_NEW_RESPONSE
            _propertyFields = action
            InsiderStore.emitChange()
         # событие на возврат данных по конкретному имуществу.
         when ActionTypes.Property.PROPERTY_GET_RESPONSE
            _propertyData = action
            InsiderStore.emitChange()
         # событие на результат создания имущества.
         when ActionTypes.Property.PROPERTY_CREATE_RESPONSE
            _propertyCreationResult = action
            InsiderStore.emitChange()
         # событие на возврат результата редактирования данных конкретной имущества.
         when ActionTypes.Property.PROPERTY_EDIT_RESPONSE
            _propertyEditResult = action
            InsiderStore.emitChange()
         # событие на возврат результата удаления имущества.
         when ActionTypes.Property.PROPERTY_DELETE_RESPONSE
            _propertyDeleteResult = action
            InsiderStore.emitChange()
         # событие на возврат результата группового удаления имущества.
         when ActionTypes.Property.PROPERTY_GROUP_DELETE_RESPONSE
            _propertiesDeleteResult = action
            InsiderStore.emitChange()

         # событие на возврат всех правообладаний.
         when ActionTypes.Ownership.OWNERSHIPS_RESPONSE
            _ownershipsResult = result
            InsiderStore.emitChange()
         # событие на возврат полей правообладания.
         when ActionTypes.Ownership.OWNERSHIP_NEW_RESPONSE
            _ownershipFields = action
            InsiderStore.emitChange()
         # событие на возврат данных по конкретному правообладанию.
         when ActionTypes.Ownership.OWNERSHIP_GET_RESPONSE
            _ownershipData = action

            InsiderStore.emitChange()
         # событие на результат создания правообладания.
         when ActionTypes.Ownership.OWNERSHIP_CREATE_RESPONSE
            _ownershipCreationResult = action

            InsiderStore.emitChange()
         # событие на возврат результата редактирования данных конкретного правообладания.
         when ActionTypes.Ownership.OWNERSHIP_EDIT_RESPONSE
            _ownershipEditResult = action

            InsiderStore.emitChange()
         # событие на возврат результата удаления правообладания.
         when ActionTypes.Ownership.OWNERSHIP_DELETE_RESPONSE
            _ownershipDeleteResult = action
            InsiderStore.emitChange()
         # событие на возврат результата скачивания документа правоотношения.
         when ActionTypes.Ownership.OWNERSHIP_DOWNLOAD_DOCUMENT_RESPONSE
            _ownershipDowloadResult = action
            InsiderStore.emitChange()

         # ========= ПЛАТЕЖИ ========= #
         # Принятие платежей.
         when ActionTypes.Payment.TO_GENERATIVE_RESPONSE
            _paymentToGenerativeResult = action
            InsiderStore.emitChange()

         # Принятие платежей.
         when ActionTypes.Payment.ACCEPT_RESPONSE
            _paymentsAcceptResult = action
            InsiderStore.emitChange()

         # Отклонение платежей.
         when ActionTypes.Payment.REJECT_RESPONSE
            _paymentsRejectResult = action
            InsiderStore.emitChange()

         # Отправка на уточнение.
         when ActionTypes.Payment.CLARIFY_RESPONSE
            _paymentsClarifyResult = action
            InsiderStore.emitChange()

         # Формирования уточнения по платежам.
         when ActionTypes.Payment.CLARIFYING_RESPONSE
            _paymentsClarifyingResult = action
            InsiderStore.emitChange()

         # Получение аттрибутов для уточнения.
         when ActionTypes.Payment.CLARIFIED_ATTR_GET_RESPONSE
            _paymentClarifiedAttributes = action
            InsiderStore.emitChange()

         # Отправка уточненных аттрибутов.
         when ActionTypes.Payment.CLARIFIED_ATTR_SET_RESPONSE
            _paymentSetClarifiedAttributesResult = action
            InsiderStore.emitChange()
   )

module.exports = InsiderStore


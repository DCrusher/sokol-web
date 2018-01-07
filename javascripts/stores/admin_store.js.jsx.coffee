###* Зависимости: модули
* SokolAppDispather          - flux диспетчер
* AdminFluxConstants         - константы для административной архитектуры flux
* AdminWebAPIUtils           - модуль утилит взаимодействия с административным API системы
* EventEmitter               - модуль для работы с системой событий
* assign                     - модуль для слияния объектов
###
SokolAppDispatcher = require('../dispatcher/app_dispatcher')
AdminFluxConstants = require('../constants/admin_flux_constants')
EventEmitter = require('events').EventEmitter
assign = require('object-assign')

# Типы событий
ActionTypes = AdminFluxConstants.ActionTypes

###* ========= ПОЛЬЗОВАТЕЛИ ========= *###

###*
* @param {Object} - хэш параметров по всем пользователям. Вид:
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
*
###
_usersResult = {}

###*
* @param {Object} - хэш параметров пользователя (нового или существующего). Вид:
*     {Object} externalEntities - параметры внешних связок модели.
*     {Object} fields           - параметры полей модели.
*     {Object} reflectionsMap   - параметры карты связок.
###
_userResult = {}

###*
* @param {Object} - результат создания пользователя.
###
_userCreationResult = {}

###*
* @param {Object} - результат редактирования данных пользователя.
###
_userEditResult = {}

###*
* @param {Object} - результат удаления пользователя.
###
_userDeleteResult = {}

###*
* @param {Object} - результат блокирования пользователя.
* @param {Object} - результат группового удаления пользователей.
###
_usersDeleteResult = {}

###*
* @param {Object} - результат блокиовки пользователя.
###
_userBlockResult = {}

###*
* @param {Object} - результат групповой блокировки пользователей.
###
_usersBlockResult = {}

###*
* @param {Object} - результат установки пароля пользователю.
###
_userChangePasswordResult = {}


###*
* @param {Object} - хэш параметров по  АРМов назначенных пользователю и доступных для назначения.
*                   Вид:
*                   {Array} appointedWorkplaces - массив с хэшами параметров полей на текущей странице.
*                   {Number} pageCount          - общее кол-во страниц с данными.
*                   {Object} entriesStatistic   - хэш с параметрами статистики записей
*                                                 (с какой записи по какую, сколько всего).
*                   {Object} filedParams      - хэш с параметрами полей.
*
###
_assingedWorkplaces = {}

###*
* @param {Object} - хэш параметров полей назначенных АРМов.
###
_assignedWorkplacesFieldParams = {}

###*
* @param {Object} - результат назначения АРМов пользователю.
###
_assignWorkplacesResult = {}


###* ========= АРМы ========= *###

###*
* @param {Object} - параметры пользовательских АРМов.
###
_workplacesResult = {}

###*
* @param {Object} - параметры АРМа(нового или существующего):
###
_workplaceResult = {}

###*
* @param {Object} - результат создания АРМа.
###
_workplaceCreationResult = undefined

###*
* @param {Object} - результат редактирования данных АРМа.
###
_workplaceEditResult = undefined

###*
* @param {Object} - результат удаления АРМа.
###
_workplaceDeleteResult = undefined

###*
* @param {Object} - хэш параметров по действиям назначенным АРМу и доступных для назначения.
*                   Вид:
*                   {Array} appointedActions - массив с хэшами параметров полей на текущей странице.
*                   {Number} pageCount          - общее кол-во страниц с данными.
*                   {Object} entriesStatistic   - хэш с параметрами статистики записей
*                                                 (с какой записи по какую, сколько всего).
*                   {Object} filedParams      - хэш с параметрами полей.
*
###
_assingedActions = {}

###*
* @param {Object} - хэш параметров полей назначенных действий.
###
_assignedActionsFieldParams = {}

###*
* @param {Object} - результат назначения действий АРМу.
###
_assignActionsResult = {}


###* ========= ПОЛЬЗОВАТЕЛЬСКИЕ ДЕЙСТВИЯ ========= *###

###*
* @param {Object} - параметры пользовательских действий.
###
_actionsResult = {}

###*
* @param {Object} - параметры пользовательского действия (нового или существующего).
###
_actionResult = {}

###*
* @param {Object} - результат создания пользовательского действия.
###
_actionCreationResult = {}

###*
* @param {Object} - результат редактирования данных пользовательского действия.
###
_actionEditResult = undefined

###*
* @param {Object} - результат удаления пользовательского действия.
###
_actionDeleteResult = undefined


###* ========= ТИПЫ СОБСТВЕННОСТИ ========= *###

###*
* @param {Array} - массив, для хранения всех типов собственности.
###
_propertyTypesResult = {}

###*
* @param {Object} - параметры типа имущества (нового или существующего).
###
_propertyTypeResult = {}

###*
* @param {Object} - результат создания типа собственности.
###
_propertyTypeCreationResult = {}

###*
* @param {Object} - результат редактирования данных типа собственности.
###
_propertyTypeEditResult = undefined

###*
* @param {Object} - результат удаления типа собственности.
###
_propertyTypeDeleteResult = undefined


###* ========= ТИПЫ ДОКУМЕНТОВ ========= *###

###*
* @param {Object} - параметры типов документов.
###
_documentTypesResult = {}

###*
* @param {Object} - параметры типа документа (нового или существующего).
###
_documentTypeResult = {}

###*
* @param {Object} - результат создания типа документа.
###
_documentTypeCreationResult = {}

###*
* @param {Object} - результат редактирования данных типа докуметна.
###
_documentTypeEditResult = undefined

###*
* @param {Object} - результат удаления типа документа.
###
_documentTypeDeleteResult = undefined


###* ========= ТИПЫ ПРАВООБЛАДАНИЙ ========= *###

###*
* @param {Object} - параметры типов правоотношений.
###
_ownershipTypesResult = {}

###*
* @param {Object} - параметры типа правообладания(нового или существующего).
###
_ownershipTypeResult = {}

###*
* @param {Object} - результат создания типа правоотношений.
###
_ownershipTypeCreationResult = {}

###*
* @param {Object} - результат редактирования данных типа правоотношений.
###
_ownershipTypeEditResult = undefined

###*
* @param {Object} - результат удаления типа правоотношений.
###
_ownershipTypeDeleteResult = undefined


###* ========= ПАРАМЕТРЫ ИМУЩЕСТВА ========= *###

###*
* @param {Object} - параметры типов параметров имущества.
###
_propertyParametersResult = {}

###*
* @param {Object} - параметры параметра имущества (нового или существующего).
###
_propertyParameterResult = {}

###*
* @param {Object} - результат создания параметра имущества.
###
_propertyParameterCreationResult = {}

###*
* @param {Object} - результат редактирования данных параметра имущества.
###
_propertyParameterEditResult = undefined

###*
* @param {Object} - результат удаления параметра имущества.
###
_propertyParameterDeleteResult = undefined

###*
* @param {String} - последнее событие.
###
_lastInteraction = undefined

###*
* модуль хранилища клиентских состояний для административной части.
###
AdminStore = assign({}, EventEmitter.prototype,
   ###* Константы
   * {String} _CHANGE_EVENT - тип события на изменение хранилища
   ###
   _CHANGE_EVENT: AdminFluxConstants.EventTypes.CHANGE_EVENT

   emitChange: ->
      @emit(@_CHANGE_EVENT)

   addChangeListener: (callback) ->
      @on(@_CHANGE_EVENT, callback)

   removeChangeListener: (callback) ->
      @removeListener(@_CHANGE_EVENT, callback)

   ###* ========= ПОЛЬЗОВАТЕЛИ ========= *###

   ###*
   * Геттер параметров всех пользователей.
   *
   * @return {Object}
   ###
   getUsers: ->
      _usersResult

   ###*
   * Геттер параметров пользователя (нового или существующего).
   *
   * @return {Object}
   ###
   getUser: ->
      _userResult

   ###*
   * Геттер результата создания пользователя
   *
   * @return {Object}
   ###
   getUserCreationResult: ->
      _userCreationResult

   ###*
   * Геттер результата редактирования данных пользователя
   *
   * @return {Object}
   ###
   getUserEditResult: ->
      _userEditResult

   ###*
   * Геттер результата удаления пользователя
   *
   * @return {Object}
   ###
   getUserDeleteResult: ->
      _userDeleteResult

   ###*
   * Геттер результата группового удаления пользователей.
   *
   * @return {Object}
   ###
   getUsersDeleteResult: ->
      _usersDeleteResult

   ###*
   * Геттер результата задания пароля пользователю.
   *
   * @return {Object}
   ###
   getUserChangePasswordResult: ->
      _userChangePasswordResult

   ###*
   * Геттер результата блокировки пользователя.
   *
   * @return {Object}
   ###
   getUserBlockResult: ->
      _userBlockResult

   ###*
   * Геттер результата групповой блокировки пользователя.
   *
   * @return {Object}
   ###
   getUsersBlockResult: ->
      _usersBlockResult

   ###*
   * Геттер всех назначенных пользователю АРМов и АРМов, доступных для назначения.
   *
   * @return {Array}
   ###
   getAssignedWorkplaces: ->
      _assingedWorkplaces.assigned_workplaces

   ###*
   * Геттер параметров полей всех назначенных пользователю АРМов и АРМов, доступных для назначения.
   *
   * @return {Object}
   ###
   getAssignedWorkplacesFieldParams: ->
      _assingedWorkplaces.filedParams

   ###*
   * Геттер кол-ва страниц с данными пользователей
   *
   * @return {Number}
   ###
   getAssignedWorkplacesPageCount: ->
      _assingedWorkplaces.totalPages

   ###*
   * Геттер параметров статистики записей (с какой, по какую, сколько всего)
   *
   * @return {Object}
   ###
   getAssignedWorkplacesEntriesStatistic: ->
      _assingedWorkplaces.entriesStatistic

   ###*
   * Геттер результат назначения АРМов пользователю.
   *
   * @return {Object}
   ###
   getAssignWorkplacesResult: ->
      _assignWorkplacesResult


   ###* ========= АРМы ========= *###

   ###*
   * Геттер всех АРМов.
   *
   * @return {Object}
   ###
   getWorkplaces: ->
      _workplacesResult

   ###*
   * Геттер параметров АРМа (нового или существующего).
   *
   * @return {Object}
   ###
   getWorkplace: ->
      _workplaceResult

   ###*
   * Геттер результата создания АРМа
   *
   * @return {Object}
   ###
   getWorkplaceCreationResult: ->
      _workplaceCreationResult

   ###*
   * Геттер результата редактирования данных АРМа
   *
   * @return {Object}
   ###
   getWorkplaceEditResult: ->
      _workplaceEditResult

   ###*
   * Геттер результата удаления АРМа
   *
   * @return {Object}
   ###
   getWorkplaceDeleteResult: ->
      _workplaceDeleteResult

   ###*
   * Геттер всех назначенных АРМу действий и действий, доступных для назначения.
   *
   * @return {Array}
   ###
   getAssignedActions: ->
      _assingedActions.assigned_actions

   ###*
   * Геттер параметров полей всех назначенных АРМу действий и действий, доступных для назначения.
   *
   * @return {Object}
   ###
   getAssignedActionsFieldParams: ->
      _assingedActions.filedParams

   ###*
   * Геттер кол-ва страниц с данными действий
   *
   * @return {Number}
   ###
   getAssignedActionsPageCount: ->
      _assingedActions.totalPages

   ###*
   * Геттер параметров статистики записей (с какой, по какую, сколько всего)
   *
   * @return {Object}
   ###
   getAssignedActionsEntriesStatistic: ->
      _assingedActions.entriesStatistic

   ###*
   * Геттер результата назначения действий АРМу.
   *
   * @return {Object}
   ###
   getAssignActionsResult: ->
      _assignActionsResult


   ###* ========= ПОЛЬЗОВАТЕЛЬСКИЕ ДЕЙСТВИЯ ========= *###

   ###*
   * Геттер всех пользовательских действий
   *
   * @return {Array}
   ###
   getActions: ->
      _actionsResult

   ###*
   * Геттер параметров пользовательского дейтсвия (нового или существующего).
   *
   * @return {Object}
   ###
   getAction: ->
      _actionResult

   ###*
   * Геттер результата создания пользовательского действия
   *
   * @return {Object}
   ###
   getActionCreationResult: ->
      _actionCreationResult

   ###*
   * Геттер результата редактирования данных пользовательского действия
   *
   * @return {Object}
   ###
   getActionEditResult: ->
      _actionEditResult

   ###*
   * Геттер результата удаления пользовательского действия.
   *
   * @return {Object}
   ###
   getActionDeleteResult: ->
      _actionDeleteResult

   ###* ========= ТИПЫ ИМУЩЕСТВА ========= *###

   ###*
   * Геттер всех типов собственности.
   *
   * @return {Object}
   ###
   getPropertyTypes: ->
      _propertyTypesResult

   ###*
   * Геттер параметров типов имущества (нового или существующего).
   *
   * @return {Object}
   ###
   getPropertyType: ->
      _propertyTypeResult

   ###*
   * Геттер результата создания типа собственности.
   *
   * @return {Object}
   ###
   getPropertyTypeCreationResult: ->
      _propertyTypeCreationResult

   ###*
   * Геттер результата редактирования данных типа собственности.
   *
   * @return {Object}
   ###
   getPropertyTypeEditResult: ->
      _propertyTypeEditResult

   ###*
   * Геттер результата удаления типа собственности.
   *
   * @return {Object}
   ###
   getPropertyTypeDeleteResult: ->
      _propertyTypeDeleteResult


   ###* ========= ТИПЫ ДОКУМЕНТОВ ========= *###

   ###*
   * Геттер всех типов документа.
   *
   * @return {Array}
   ###
   getDocumentTypes: ->
      _documentTypesResult

   ###*
   * Геттер параметров типа документов (нового или существующего).
   *
   * @return {Object}
   ###
   getDocumentType: ->
      _documentTypeResult

   ###*
   * Геттер результата создания типа документа.
   *
   * @return {Object}
   ###
   getDocumentTypeCreationResult: ->
      _documentTypeCreationResult

   ###*
   * Геттер результата редактирования данных типа документа
   *
   * @return {Object}
   ###
   getDocumentTypeEditResult: ->
      _documentTypeEditResult

   ###*
   * Геттер результата удаления типа документа.
   *
   * @return {Object}
   ###
   getDocumentTypeDeleteResult: ->
      _documentTypeDeleteResult


   ###* ========= ТИПЫ ПРАВООБЛАДАНИЙ ========= *###

   ###*
   * Геттер всех типов правоотношений.
   *
   * @return {Array}
   ###
   getOwnershipTypes: ->
      _ownershipTypesResult

   ###*
   * Геттер параметров типа правоотношений (нового или существующего).
   *
   * @return {Object}
   ###
   getOwnershipType: ->
      _ownershipTypeResult

   ###*
   * Геттер результата создания типа правоотношений
   *
   * @return {Object}
   ###
   getOwnershipTypeCreationResult: ->
      _ownershipTypeCreationResult

   ###*
   * Геттер результата редактирования данных типа правоотношений
   *
   * @return {Object}
   ###
   getOwnershipTypeEditResult: ->
      _ownershipTypeEditResult

   ###*
   * Геттер результата удаления типа правоотношений.
   *
   * @return {Object}
   ###
   getOwnershipTypeDeleteResult: ->
      _ownershipTypeDeleteResult


   ###* ========= ПАРАМЕТРЫ ИМУЩЕСТВА ========= *###

   ###*
   * Геттер всех типов основного параметра.
   *
   * @return {Array}
   ###
   getPropertyParameters: ->
      _propertyParametersResult

   ###*
   * Геттер параметров параметра имущества (нового или существующего).
   *
   * @return {Object}
   ###
   getPropertyParameter: ->
      _propertyParameterResult

   ###*
   * Геттер результата создания типа основного параметра.
   *
   * @return {Object}
   ###
   getPropertyParameterCreationResult: ->
      _propertyParameterCreationResult

   ###*
   * Геттер результата редактирования данных типа основного параметра.
   *
   * @return {Object}
   ###
   getPropertyParameterEditResult: ->
      _propertyParameterEditResult

   ###*
   * Геттер результата удаления типа основного параметра.
   *
   * @return {Object}
   ###
   getPropertyParameterDeleteResult: ->
      _propertyParameterDeleteResult

   ###*
   * Геттер последнего события
   * @return {String}
   ###
   getLastInteraction: ->
      _lastInteraction

   dispatcherIndex: SokolAppDispatcher.register (payload) ->
      source = payload.source
      action = payload.action
      result = action.json
      errors = action.errors
      isViewAction = source is AdminFluxConstants.PayloadSources.VIEW_ACTION
      _lastInteraction = action.type

      # Пока не обрабатываем события интерфейса.
      return if isViewAction

      switch _lastInteraction

         # ========= ПОЛЬЗОВАТЕЛИ ========= #

         # набор пользователей.
         when ActionTypes.User.USERS_RESPONSE
            _usersResult = result
            AdminStore.emitChange()

         # поля пользователя (новый пользователь).
         when ActionTypes.User.NEW_RESPONSE
            _userResult = result
            AdminStore.emitChange()

         # параметры пользователя (просмотр/редактирование).
         when ActionTypes.User.GET_RESPONSE
            _userResult = result
            AdminStore.emitChange()

         # результат создания пользователя.
         when ActionTypes.User.CREATE_RESPONSE
            _userCreationResult = action
            AdminStore.emitChange()

         # результат редактирования данных пользователя.
         when ActionTypes.User.EDIT_RESPONSE
            _userEditResult = action
            AdminStore.emitChange()

         # результат удаления пользователя.
         when ActionTypes.User.DELETE_RESPONSE
            _userDeleteResult = action
            AdminStore.emitChange()

         # результат группового удаления пользователей.
         when ActionTypes.User.GROUP_DELETE_RESPONSE
            _usersDeleteResult = result
            AdminStore.emitChange()

         # результат смену пароля пользователя.
         when ActionTypes.User.CHANGE_PASSWORD_RESPONSE
            _userChangePasswordResult = action
            AdminStore.emitChange()

         # результат блокировки пользователя.
         when ActionTypes.User.BLOCK_RESPONSE
            _userBlockResult = action
            AdminStore.emitChange()

         # результат групповой блокировки пользователей.
         when ActionTypes.User.GROUP_BLOCK_RESPONSE
            _usersBlockResult = action
            AdminStore.emitChange()

         # возврат АРМов, назначенных пользователю.
         when ActionTypes.User.ASSIGNED_WORKPLACES_RESPONSE
            _assingedWorkplaces = result
            AdminStore.emitChange()

         # результат назначения АРМов пользователю.
         when ActionTypes.User.ASSIGN_WORKPLACES_RESPONSE
            _assignWorkplacesResult = action
            AdminStore.emitChange()

         # ========= АРМы ========= #

         # набор АРМов.
         when ActionTypes.Workplace.WP_RESPONSE
            _workplacesResult = result
            AdminStore.emitChange()

         # поля АРМа (новый АРМ).
         when ActionTypes.Workplace.WP_NEW_RESPONSE
            _workplaceResult = result
            AdminStore.emitChange()

         # параметры АРМа (просмтор/редактирование).
         when ActionTypes.Workplace.WP_GET_RESPONSE
            _workplaceResult = result
            AdminStore.emitChange()

         # результат создания АРМа.
         when ActionTypes.Workplace.WP_CREATE_RESPONSE
            _workplaceCreationResult = action
            AdminStore.emitChange()

         # результат редактирования данных АРМа.
         when ActionTypes.Workplace.WP_EDIT_RESPONSE
            _workplaceEditResult = action
            AdminStore.emitChange()

         # результат удаления АРМа.
         when ActionTypes.Workplace.WP_DELETE_RESPONSE
            _workplaceDeleteResult = action
            AdminStore.emitChange()

         # возврат АРМов, назначенных пользователю.
         when ActionTypes.Workplace.ASSIGNED_ACTIONS_RESPONSE
            _assingedActions = result
            AdminStore.emitChange()

         # возврат результата назначения АРМов пользователю.
         when ActionTypes.Workplace.ASSIGN_ACTIONS_RESPONSE
            _assignActionsResult = action
            AdminStore.emitChange()

         # ========= ДЕЙСТВИЯ ПОЛЬЗОВАТЕЛЯ ========= #

         # набор пользовательских действий.
         when ActionTypes.Action.ACTIONS_RESPONSE
            _actionsResult = result
            AdminStore.emitChange()

         # поля пользовательских действий (новое пользовательское действие).
         when ActionTypes.Action.ACTIONS_NEW_RESPONSE
            _actionResult = result
            AdminStore.emitChange()

         # данные пользовательского действия (просмотр или редактирование).
         when ActionTypes.Action.ACTIONS_GET_RESPONSE
            _actionResult = result
            AdminStore.emitChange()

         # результат создания пользовательского действия.
         when ActionTypes.Action.ACTIONS_CREATE_RESPONSE
            _actionCreationResult = action
            AdminStore.emitChange()

         # результат редактирование данных пользовательского действия.
         when ActionTypes.Action.ACTIONS_EDIT_RESPONSE
            _actionEditResult = action
            AdminStore.emitChange()

         # результат удаления пользовательского действия.
         when ActionTypes.Action.ACTIONS_DELETE_RESPONSE
            _actionDeleteResult = action
            AdminStore.emitChange()

         # ========= ТИПЫ ИМУЩЕСТВА ========= #

         # набор типов имущества.
         when ActionTypes.PropertyType.PROPERTY_TYPES_RESPONSE
            _propertyTypesResult = result
            AdminStore.emitChange()

         # поля типа имущества (новый тип)
         when ActionTypes.PropertyType.PROPERTY_TYPES_NEW_RESPONSE
            _propertyTypeResult = result
            AdminStore.emitChange()

         # данные по типу имущества (просмотр/редактирование).
         when ActionTypes.PropertyType.PROPERTY_TYPES_GET_RESPONSE
            _propertyTypeResult = result
            AdminStore.emitChange()

         # результат создания типа собственности.
         when ActionTypes.PropertyType.PROPERTY_TYPES_CREATE_RESPONSE
            _propertyTypeCreationResult = action
            AdminStore.emitChange()

         # результат редактирования данных типа собственности.
         when ActionTypes.PropertyType.PROPERTY_TYPES_EDIT_RESPONSE
            _propertyTypeEditResult = action
            AdminStore.emitChange()

         # возврат результата удаления типа собственности.
         when ActionTypes.PropertyType.PROPERTY_TYPES_DELETE_RESPONSE
            _propertyTypeDeleteResult = action
            AdminStore.emitChange()

         # ========= ТИПЫ ДОКУМЕНТОВ ========= #

         # событие на возврат всех типов документов.
         when ActionTypes.DocumentType.DOCUMENT_TYPES_RESPONSE
            _documentTypesResult = result
            AdminStore.emitChange()

         # полея для типа документа (новый тип документа).
         when ActionTypes.DocumentType.DOCUMENT_TYPE_NEW_RESPONSE
            _documentTypeResult = result
            AdminStore.emitChange()

         # данные по типу документа (просмотр или редактирование).
         when ActionTypes.DocumentType.DOCUMENT_TYPE_GET_RESPONSE
            _documentTypeResult = result
            AdminStore.emitChange()

         # результат создания типа документа.
         when ActionTypes.DocumentType.DOCUMENT_TYPE_CREATE_RESPONSE
            _documentTypeCreationResult = action
            AdminStore.emitChange()

         # результат редактирования данных типа документа.
         when ActionTypes.DocumentType.DOCUMENT_TYPE_EDIT_RESPONSE
            _documentTypeEditResult = action
            AdminStore.emitChange()

         # результат удаления типа документа.
         when ActionTypes.DocumentType.DOCUMENT_TYPE_DELETE_RESPONSE
            _documentTypeDeleteResult = action
            AdminStore.emitChange()

         # ========= ТИПЫ ПРАВООБЛАДАНИЙ ========= #

         # набор типов правоотношений.
         when ActionTypes.OwnershipType.OWNERSHIP_TYPES_RESPONSE
            _ownershipTypesResult = result
            AdminStore.emitChange()

         # поля типа правоотношения (новый тип).
         when ActionTypes.OwnershipType.OWNERSHIP_TYPE_NEW_RESPONSE
            _ownershipTypeResult = result
            AdminStore.emitChange()

         # параметры типа правоотношения (просмотр или редактирование).
         when ActionTypes.OwnershipType.OWNERSHIP_TYPE_GET_RESPONSE
            _ownershipTypeResult = result
            AdminStore.emitChange()

         # результат создания типа правоотношения.
         when ActionTypes.OwnershipType.OWNERSHIP_TYPE_CREATE_RESPONSE
            _ownershipTypeCreationResult = action
            AdminStore.emitChange()

         # результат редактирования данных типа правоотношения.
         when ActionTypes.OwnershipType.OWNERSHIP_TYPE_EDIT_RESPONSE
            _ownershipTypeEditResult = action
            AdminStore.emitChange()

         # результата удаления типа правоотношения.
         when ActionTypes.OwnershipType.OWNERSHIP_TYPE_DELETE_RESPONSE
            _ownershipTypeDeleteResult = action
            AdminStore.emitChange()

         # ========= ПАРАМЕТР ИМУЩЕСТВА ========= #

         # набор типов правоотношений.
         when ActionTypes.PropertyParameter.PROPERTY_PARAMETERS_RESPONSE
            _propertyParametersResult = result
            AdminStore.emitChange()

         # поля типа правоотношения (новый тип).
         when ActionTypes.PropertyParameter.PROPERTY_PARAMETER_NEW_RESPONSE
            _propertyParameterResult = result
            AdminStore.emitChange()

         # данные типа правоотношения (просмотр или редактирование).
         when ActionTypes.PropertyParameter.PROPERTY_PARAMETER_GET_RESPONSE
            _propertyParameterResult = result
            AdminStore.emitChange()

         # результат создания типа правоотношения.
         when ActionTypes.PropertyParameter.PROPERTY_PARAMETER_CREATE_RESPONSE
            _propertyParameterCreationResult = action
            AdminStore.emitChange()

         # результат редактирования данных типа правоотношения.
         when ActionTypes.PropertyParameter.PROPERTY_PARAMETER_EDIT_RESPONSE
            _propertyParameterEditResult = action
            AdminStore.emitChange()

         # результат удаления типа правоотношения.
         when ActionTypes.PropertyParameter.PROPERTY_PARAMETER_DELETE_RESPONSE
            _propertyParameterDeleteResult = action
            AdminStore.emitChange()
   )


module.exports = AdminStore

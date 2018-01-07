
###* Зависимости: модули
* SokolAppDispather          - flux диспетчер
* AdminFluxConstants         - константы для административной архитектуры flux
* AdminWebAPIUtils           - модуль утилит взаимодействия с административным API системы
###
SokolAppDispatcher = require('../dispatcher/app_dispatcher')
AdminFluxConstants = require('../constants/admin_flux_constants')
AdminWebAPIUtils = require('../utils/admin_web_api_utils')

# типы действий
ActionTypes = AdminFluxConstants.ActionTypes

###*
* модуль создания клиентских административных действий
###
module.exports =


   #================================ Пользователи ==============================


   ###*
   * Функция запроса всех пользователей через утилиты взаимодействия с
   *  административным API сайта
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   *        Члены хэша верхнего уровня - это поля по которым назначено условие, зарезервированное
   *        слово - all (поиск по всем). Значение каждого параметра верхнего уровня - это
   *        хэш параметров поиска по данному полю. В хэше параметров поиска по полю могут быть
   *        следующие члены:
   *        {String} (обязательное) expr - строка поиска
   *        {String} match - тип соответствия. Возможны варианты:
   *          (по-умолчанию) "like"    - поиск подстроки expr в значении поля
   *                         "eq"      - строгое равенство
   *                         "less"    - field.value > expr
   *                         "greater" - field.value > expr
   *                         "not"     - field.value != expr
   *           Примеры:
   *               { all: { expr: "Абра-кадабра" } }    - поиск по всем полям на соответствие выражению.
   *                 { email: { expr: "@bashkortostan.ru" },
   *                   gender: { expr: "man", match: "eq" } } - поиск всех пользователей мужского пола,
   *                                                            с почтой в домене bashkortostan.ru.
   * @return
   ###
   getUsers: (requestParams) -> #(page, perPage, matchedParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.User.USERS_REQUEST
      )
      AdminWebAPIUtils.getUsers(requestParams) #(page, perPage, matchedParams)


   ###*
   * Функция запроса полей для формы создания нового пользователя
   *
   * @return
   ###
   getUserFields: ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.User.NEW_REQUEST
      )
      AdminWebAPIUtils.getUserFields()

   ###*
   * Функция создания пользовательского запроса на создание нового пользователя
   *
   * @param {Object} requestData - параметры запроса.
   * @return
   ###
   createUser: (requestData) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.User.CREATE_REQUEST
      )
      AdminWebAPIUtils.createUser(requestData)

   ###*
   * Функция создания пользовательского запроса на редактирование данных пользователя
   *
   * @param {Object} requestData - параметры запроса.
   * @param {String} userID     - идентификатор пользователя.
   * @return
   ###
   editUser: (requestData, userID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.User.EDIT_REQUEST

      AdminWebAPIUtils.editUser(requestData, userID)

   ###*
   * Функция создания действия запроса на удаление пользователя.
   *
   * @param {String} userID     - идентификатор пользователя
   * @return
   ###
   deleteUser: (userID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.User.DELETE_REQUEST

      AdminWebAPIUtils.deleteUser(userID)

   ###*
   * Функция создания действия запроса на удаление пользователей.
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
   deleteUsers: (data) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.User.GROUP_DELETE_REQUEST

      AdminWebAPIUtils.deleteUsers(data)

   ###*
   * Функция запроса данных по пользователю. Делает запрос на получение
   *  данных для динамической формы - все поля со значениями, валидаторами,
   *  перечислениями и т.д.
   *
   * @return
   ###
   getUser: (userID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.User.GET_REQUEST

      AdminWebAPIUtils.getUser(userID)

   ###*
   * Функция отправки запроса на смену пароля пользователя.
   *
   * @param {Object} requestData - параметры запроса.
   * @param {String, Number} userID - ИД пользователя.
   * @return
   ###
   changePasswordUser: (requestData, userID) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.User.CHANGE_PASSWORD_REQUEST
      )
      AdminWebAPIUtils.changePasswordUser(requestData, userID)

   ###*
   * Функция отправки запроса на блокировку/разблокировку пользователя
   *
   * @param {String, Number} userID - ИД пользователя.
   * @return
   ###
   blockUser: (userID) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.User.BLOCK_REQUEST
      )
      AdminWebAPIUtils.blockUser(userID)

   ###*
   * Функция отправки запроса на блокировку пользователей
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
   blockUsers: (data) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.User.GROUP_BLOCK_REQUEST
      )
      AdminWebAPIUtils.blockUsers(data)

   ###*
   * Функция отправки запроса на получение назначенных и возможных для назначения АРМов
   *  пользователя.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page          - страница..
   *     {Number} perPage       - кол-во записей на странице..
   *     {Object} metchedParams - параметры выборки.
   *     {Number} instanceID    - идентификатор пользователя.
   * @return
   ###
   getAssignedWorkplaces: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.User.ASSIGNED_WORKPLACES_REQUEST
      )
      AdminWebAPIUtils.getAssignedWorkplaces(requestParams.instanceID)

   ###*
   * Функция отправки запроса на назначение АРМов пользователю.
   *
   * @param {Object} data - хэш с параметрами на отправку. Вид:
   *     {Object} markedKeys    - хэш с параметрами отмеченных строк и
   *                              строк со снятой отметкой.
   *     {Object} processedData - специфичные данные для операции, подготовленные
   *                              пользовательскими обработчиками.
   *     {Boolean} isAllMarked  - флаг отметки всех строк.
   *     {Object} filterParams - параметры фильтра.
   * @param {String} userID - идентификатор пользователя для которого производится
   *                          назначение.
   * @return
   ###
   assignWorkplaces: (data, userID) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.User.ASSIGN_WORKPLACES_REQUEST
      )
      AdminWebAPIUtils.assignWorkplaces(data, userID)


   #================================ АРМы ======================================


   ###
   * Функция запроса всех АРМов через утилиты взаимодействия с
   *     административным API сайта
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getWorkplaces: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Workplace.WP_REQUEST
      )
      AdminWebAPIUtils.getWorkplaces(requestParams)
      return

   ###*
   * Функция запроса полей для формы создания нового АРМа
   *
   * @return
   ###
   getWorkplaceFields: ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Workplace.WP_NEW_REQUEST
      )
      AdminWebAPIUtils.getWorkplaceFields()

   ###*
   * Функция создания пользовательского запроса на создание нового АРМа
   *
   * @param {Object} requestData - параметры запроса.
   * @return
   ###
   createWorkplace: (requestData) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Workplace.WP_CREATE_REQUEST
      )
      AdminWebAPIUtils.createWorkplace(requestData)

   ###*
   * Функция создания пользовательского запроса на редактирование данных АРМа
   *
   * @param {Object} requestData - параметры запроса.
   * @param {String} workplaceID     - идентификатор АРМа
   * @return
   ###
   editWorkplace: (requestData, workplaceID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Workplace.WP_EDIT_REQUEST

      AdminWebAPIUtils.editWorkplace(requestData, workplaceID)

   ###*
   * Функция запроса данных по АРМу. Делает запрос на получение
   *  данных для динамической формы - все поля со значениями, валидаторами,
   *  перечислениями и т.д.
   *
   * @return
   ###
   getWorkplace: (workplaceID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Workplace.WP_GET_REQUEST

      AdminWebAPIUtils.getWorkplace(workplaceID)

   ###*
   * Функция удаления АРМа
   *
   * @param {String} workplaceID     - идентификатор АРМа
   * @return
   ###
   deleteWorkplace: (workplaceID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Workplace.WP_DELETE_REQUEST

      AdminWebAPIUtils.deleteWorkplace(workplaceID)

   ###*
   * Функция отправки запроса на получение назначенных и возможных для назначения действий
   *  АРМа.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page          - страница.
   *     {Number} perPage       - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   *     {Number} instanceID    - идентификатор АРМа.
   * @return
   ###
   getAssignedActions: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Workplace.ASSIGNED_ACTIONS_REQUEST
      )
      AdminWebAPIUtils.getAssignedActions(requestParams.instanceID)

   ###*
   * Функция отправки запроса на назначение действий АРМу.
   *
   * @param {Object} data - хэш с параметрами на отправку. Вид:
   *     {Object} markedKeys    - хэш с параметрами отмеченных строк и
   *                              строк со снятой отметкой.
   *     {Object} processedData - специфичные данные для операции, подготовленные
   *                              пользовательскими обработчиками.
   *     {Boolean} isAllMarked  - флаг отметки всех строк.
   *     {Object} filterParams - параметры фильтра.
   * @param {String} workplaceID - идентификатор АРМа для которого производится
   *                               назначение.
   * @return
   ###
   assignActions: (data, workplaceID) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Workplace.ASSIGN_ACTIONS_REQUEST
      )
      AdminWebAPIUtils.assignActions(data, workplaceID)


   #================================ Типы собственности ========================


   ###*
   * Функция запроса всех типов собственности через утилиты взаимодействия с
   *     административным API сайта
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getPropertyTypes: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.PropertyType.PROPERTY_TYPES_REQUEST
      )
      AdminWebAPIUtils.getPropertyTypes(requestParams)

   ###*
   * Функция запроса полей для формы создания нового типа собственности.
   *
   * @return
   ###
   getPropertyTypeFields: ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.PropertyType.PROPERTY_TYPES_NEW_REQUEST
      )
      AdminWebAPIUtils.getPropertyTypeFields()

   ###*
   * Функция создания пользовательского запроса на создание нового типа собственности.
   *
   * @param {Object} requestData - параметры запроса.
   * @return
   ###
   createPropertyType: (requestData) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.PropertyType.PROPERTY_TYPES_CREATE_REQUEST
      )
      AdminWebAPIUtils.createPropertyType(requestData)

   ###*
   * Функция запроса данных по типу собственности. Делает запрос на получение
   *  данных для динамической формы - все поля со значениями, валидаторами,
   *  перечислениями и т.д.
   *
   * @param {String, Number} propertyTypeID - идентификатор типа.
   * @return
   ###
   getPropertyType: (propertyTypeID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.PropertyType.PROPERTY_TYPES_GET_REQUEST

      AdminWebAPIUtils.getPropertyType(propertyTypeID)

   ###*
   * Функция создания пользовательского запроса на редактирование данных типа собственности.
   *
   * @param {Object} requestData - параметры запроса.
   * @param {String} propertyTypeID - идентификатор типа собственности.
   * @return
   ###
   editPropertyType: (requestData, propertyTypeID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.PropertyType.PROPERTY_TYPES_EDIT_REQUEST

      AdminWebAPIUtils.editPropertyType(requestData, propertyTypeID)

   ###*
   * Функция удаления типа собственности.
   *
   * @param {String} propertyTypeID - идентификатор удаляемого типа собственности.
   * @return
   ###
   deletePropertyType: (propertyTypeID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.PropertyType.PROPERTY_TYPES_DELETE_REQUEST

      AdminWebAPIUtils.deletePropertyType(propertyTypeID)


   #================================ Типы документов ========================
   ###*
   * Функция запроса всех типов документов через утилиты взаимодействия с
   *     административным API сайта
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getDocumentTypes: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.DocumentType.DOCUMENT_TYPES_REQUEST
      )
      AdminWebAPIUtils.getDocumentTypes(requestParams)

   ###*
   * Функция запроса полей для формы создания нового типа документов.
   *
   * @return
   ###
   getDocumentTypeFields: ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.DocumentType.DOCUMENT_TYPE_NEW_REQUEST
      )
      AdminWebAPIUtils.getDocumentTypeFields()

   ###*
   * Функция создания пользовательского запроса на создание нового типа документов.
   *
   * @param {Object} requestData - параметры запроса.
   * @return
   ###
   createDocumentType: (requestData) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.DocumentType.DOCUMENT_TYPE_CREATE_REQUEST
      )
      AdminWebAPIUtils.createDocumentType(requestData)

   ###*
   * Функция запроса данных по типу документов. Делает запрос на получение
   *  данных для динамической формы - все поля со значениями, валидаторами,
   *  перечислениями и т.д.
   *
   * @return
   ###
   getDocumentType: (documentTypeID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.DocumentType.DOCUMENT_TYPE_GET_REQUEST

      AdminWebAPIUtils.getDocumentType(documentTypeID)

   ###*
   * Функция создания пользовательского запроса на редактирование данных типа документов.
   *
   * @param {Object} requestData - параметры запроса.
   * @param {String} documentTypeID - идентификатор типа документов.
   * @return
   ###
   editDocumentType: (requestData, documentTypeID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.DocumentType.DOCUMENT_TYPE_EDIT_REQUEST

      AdminWebAPIUtils.editDocumentType(requestData, documentTypeID)

   ###*
   * Функция удаления типа документов.
   *
   * @param {String} documentTypeID - идентификатор удаляемого типа документов.
   * @return
   ###
   deleteDocumentType: (documentTypeID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.DocumentType.DOCUMENT_TYPE_DELETE_REQUEST

      AdminWebAPIUtils.deleteDocumentType(documentTypeID)


   #================================ Типы правоотношений =======================


   ###*
   * Функция запроса всех типов правоотношений через утилиты взаимодействия с
   *     административным API сайта
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getOwnershipTypes: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.OwnershipType.OWNERSHIP_TYPES_REQUEST
      )
      AdminWebAPIUtils.getOwnershipTypes(requestParams)

   ###*
   * Функция запроса полей для формы создания нового типа правоотношений.
   *
   * @return
   ###
   getOwnershipTypeFields: ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.OwnershipType.OWNERSHIP_TYPE_NEW_REQUEST
      )
      AdminWebAPIUtils.getOwnershipTypeFields()

   ###*
   * Функция создания пользовательского запроса на создание нового типа правоотношений.
   *
   * @param {Object} requestData - параметры запроса.
   * @return
   ###
   createOwnershipType: (requestData) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.OwnershipType.OWNERSHIP_TYPE_CREATE_REQUEST
      )
      AdminWebAPIUtils.createOwnershipType(requestData)

   ###*
   * Функция запроса данных по типу правоотношений. Делает запрос на получение
   *  данных для динамической формы - все поля со значениями, валидаторами,
   *  перечислениями и т.д.
   *
   * @return
   ###
   getOwnershipType: (ownershipTypeID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.OwnershipType.OWNERSHIP_TYPE_GET_REQUEST

      AdminWebAPIUtils.getOwnershipType(ownershipTypeID)

   ###*
   * Функция создания пользовательского запроса на редактирование данных типа правоотношений.
   *
   * @param {Object} requestData - параметры запроса.
   * @param {String} ownershipTypeID - идентификатор типа правоотношений.
   * @return
   ###
   editOwnershipType: (requestData, ownershipTypeID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.OwnershipType.OWNERSHIP_TYPE_EDIT_REQUEST

      AdminWebAPIUtils.editOwnershipType(requestData, ownershipTypeID)

   ###*
   * Функция удаления типа правоотношений.
   *
   * @param {String} ownershipTypeID - идентификатор удаляемого типа правоотношений.
   * @return
   ###
   deleteOwnershipType: (ownershipTypeID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.OwnershipType.OWNERSHIP_TYPE_DELETE_REQUEST

      AdminWebAPIUtils.deleteOwnershipType(ownershipTypeID)


   #================================ Типы основного параметра ==================


   ###*
   * Функция запроса всех типов основного параметра через утилиты взаимодействия с
   *     административным API сайта
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getPropertyParameters: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.PropertyParameter.PROPERTY_PARAMETERS_REQUEST
      )
      AdminWebAPIUtils.getPropertyParameters(requestParams)

   ###*
   * Функция запроса полей для формы создания нового типа основного параметра.
   *
   * @return
   ###
   getPropertyParameterFields: ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_NEW_REQUEST
      )
      AdminWebAPIUtils.getPropertyParameterFields()

   ###*
   * Функция создания пользовательского запроса на создание нового типа основного параметра.
   *
   * @param {Object} requestData - параметры запроса.
   * @return
   ###
   createPropertyParameter: (requestData) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_CREATE_REQUEST
      )
      AdminWebAPIUtils.createPropertyParameter(requestData)

   ###*
   * Функция запроса данных по типу основного параметра. Делает запрос на получение
   *  данных для динамической формы - все поля со значениями, валидаторами,
   *  перечислениями и т.д.
   *
   * @return
   ###
   getPropertyParameter: (propertyParameterID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_GET_REQUEST

      AdminWebAPIUtils.getPropertyParameter(propertyParameterID)

   ###*
   * Функция создания пользовательского запроса на редактирование данных типа основного параметра.
   *
   * @param {Object} requestData - параметры запроса.
   * @param {String} propertyParameterID - идентификатор типа основного параметра.
   * @return
   ###
   editPropertyParameter: (requestData, propertyParameterID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_EDIT_REQUEST

      AdminWebAPIUtils.editPropertyParameter(requestData, propertyParameterID)

   ###*
   * Функция удаления типа основного параметра.
   *
   * @param {String} propertyParameterID - идентификатор удаляемого типа основного параметра.
   * @return
   ###
   deletePropertyParameter: (propertyParameterID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_DELETE_REQUEST

      AdminWebAPIUtils.deletePropertyParameter(propertyParameterID)


   #================================ Пользовательские действия =================


   ###
   * Функция запроса всех пользовательских действий через утилиты взаимодействия
   *     с административным API сайта
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getActions: (requestParams) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Action.ACTIONS_REQUEST
      )
      AdminWebAPIUtils.getActions(requestParams)

   ###*
   * Функция запроса полей для формы создания нового пользовательского дейстыия
   *
   * @return
   ###
   getActionFields: ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Action.ACTIONS_NEW_REQUEST
      )
      AdminWebAPIUtils.getActionFields()

   ###*
   * Функция создания пользовательского запроса на создание нового
   *    пользовательского действия.
   *
   * @param {Object} requestData - параметры запроса.
   * @return
   ###
   createAction: (requestData) ->
      SokolAppDispatcher.handleViewAction(
         type: ActionTypes.Action.ACTIONS_CREATE_REQUEST
      )
      AdminWebAPIUtils.createAction(requestData)

   ###*
   * Функция запроса данных по пользовательскому действию. Делает запрос на
   *  получение данных для динамической формы - все поля со значениями,
   *  валидаторами, перечислениями и т.д.
   *
   * @return
   ###
   getAction: (actionID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Action.ACTIONS_GET_REQUEST

      AdminWebAPIUtils.getAction(actionID)

   ###*
   * Функция создания пользовательского запроса на редактирование данных
   *     пользовательского действия.
   *
   * @param {Object} requestData - параметры запроса.
   * @param {String} actionID     - идентификатор пользовательского действия.
   * @return
   ###
   editAction: (requestData, actionID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Action.ACTIONS_EDIT_REQUEST

      AdminWebAPIUtils.editAction(requestData, actionID)

   ###*
   * Функция удаления пользовательского действия
   *
   * @param {String} actionID - идентификатор удаляемого пользовательского действия
   * @return
   ###
   deleteAction: (actionID) ->
      SokolAppDispatcher.handleViewAction
         type: ActionTypes.Action.ACTIONS_DELETE_REQUEST

      AdminWebAPIUtils.deleteAction(actionID)


###* Зависимости: модули
* SokolAppDispather  - flux диспетчер
* AdminFluxConstants - константы для административной архитектуры flux
###
SokolAppDispather = require('../dispatcher/app_dispatcher')
AdminFluxConstants = require('../constants/admin_flux_constants')

# Типы действий
ActionTypes = AdminFluxConstants.ActionTypes

###*
*  Модуль создания серверных административных действий
###
module.exports =


   #================================ Пользователи ==============================


   ###*
   * Функция создания серверного действия в ответ
   *         на получение всех пользователей
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUsers: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.User.USERS_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение данных по пользователю.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUser: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.User.GET_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение полей пользователя.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUserFields: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.User.NEW_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос создания пользователя.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUserCreationResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.User.CREATE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос редактирования данных пользователя.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUserEditResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.User.EDIT_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос удаления пользователя.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUserDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.User.DELETE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос группового удаления пользователей.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUsersDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.User.GROUP_DELETE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос редактирование пароля пользователя.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUserChangePasswordResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.User.CHANGE_PASSWORD_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос блокировки пользователя.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUserBlockResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.User.BLOCK_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос групповой блокировки пользователей.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveUsersBlockResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.User.GROUP_BLOCK_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на запрос
   *         АРМов назначенных пользователю и АРМов, доступных для назначения.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveAssignedWorkplaces: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.User.ASSIGNED_WORKPLACES_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на запрос
   *         назначения АРМов пользователю.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveWorkplacesAssignResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.User.ASSIGN_WORKPLACES_RESPONSE
         json: json
         errors: errors
      )

   #================================ АРМы ======================================


   ###*
   * Функция создания серверного действия в ответ
   *         на получение всех АРМов
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveWorkplaces: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Workplace.WP_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение полей АРМа
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveWorkplaceFields: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Workplace.WP_NEW_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение данных по АРМу
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveWorkplace: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Workplace.WP_GET_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос создания АРМа
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveWorkplaceCreationResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Workplace.WP_CREATE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос редактирования данных АРМа
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveWorkplaceEditResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Workplace.WP_EDIT_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос удаления ARMa.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveWorkplaceDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Workplace.WP_DELETE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на запрос
   *         действий, назначенных АРМу и действий, доступных для назначения.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveAssignedActions: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Workplace.ASSIGNED_ACTIONS_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ на запрос
   *         назначения действий АРМу.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveActionsAssignResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Workplace.ASSIGN_ACTIONS_RESPONSE
         json: json
         errors: errors
      )


   #================================ Типы собственности ========================

   ###*
   * Функция создания серверного действия в ответ
   *         на получение всех типов собственности
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyTypes: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.PropertyType.PROPERTY_TYPES_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение полей типов собственности
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyTypeFields: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.PropertyType.PROPERTY_TYPES_NEW_RESPONSE
         json: json
         errors: errors
      )


   ###*
   * Функция создания серверного действия в ответ
   *         на запрос создания типа собственности
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyTypeCreationResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.PropertyType.PROPERTY_TYPES_CREATE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение данных по типу собственности
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyType: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.PropertyType.PROPERTY_TYPES_GET_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос редактирования данных типа собственности
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyTypeEditResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.PropertyType.PROPERTY_TYPES_EDIT_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос удаления типа собственности.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyTypeDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.PropertyType.PROPERTY_TYPES_DELETE_RESPONSE
         json: json
         errors: errors
      )


   #================================ Типы документов ===========================

   ###*
   * Функция создания серверного действия в ответ
   *         на получение всех типов документов
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveDocumentTypes: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.DocumentType.DOCUMENT_TYPES_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение полей типов документов
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveDocumentTypeFields: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.DocumentType.DOCUMENT_TYPE_NEW_RESPONSE
         json: json
         errors: errors
      )


   ###*
   * Функция создания серверного действия в ответ
   *         на запрос создания типа документов
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveDocumentTypeCreationResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.DocumentType.DOCUMENT_TYPE_CREATE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение данных по типу документов
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveDocumentType: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.DocumentType.DOCUMENT_TYPE_GET_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос редактирования данных типа документов
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveDocumentTypeEditResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.DocumentType.DOCUMENT_TYPE_EDIT_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос удаления типа документов.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveDocumentTypeDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.DocumentType.DOCUMENT_TYPE_DELETE_RESPONSE
         json: json
         errors: errors
      )


   #================================ Типы провоотношений =======================

   ###*
   * Функция создания серверного действия в ответ
   *         на получение всех типов провоотношений
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveOwnershipTypes: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.OwnershipType.OWNERSHIP_TYPES_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение полей типов провоотношений
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveOwnershipTypeFields: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.OwnershipType.OWNERSHIP_TYPE_NEW_RESPONSE
         json: json
         errors: errors
      )


   ###*
   * Функция создания серверного действия в ответ
   *         на запрос создания типа провоотношений
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveOwnershipTypeCreationResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.OwnershipType.OWNERSHIP_TYPE_CREATE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение данных по типу провоотношений
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveOwnershipType: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.OwnershipType.OWNERSHIP_TYPE_GET_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос редактирования данных типа провоотношений
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveOwnershipTypeEditResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.OwnershipType.OWNERSHIP_TYPE_EDIT_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос удаления типа провоотношений.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveOwnershipTypeDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.OwnershipType.OWNERSHIP_TYPE_DELETE_RESPONSE
         json: json
         errors: errors
      )


   #================================ Типы основного параметра ==================

   ###*
   * Функция создания серверного действия в ответ
   *         на получение всех типов основного параметра
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyParameters: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.PropertyParameter.PROPERTY_PARAMETERS_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение полей типов основного параметра
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyParameterFields: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_NEW_RESPONSE
         json: json
         errors: errors
      )


   ###*
   * Функция создания серверного действия в ответ
   *         на запрос создания типа основного параметра
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyParameterCreationResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_CREATE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение данных по типу основного параметра
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyParameter: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_GET_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос редактирования данных типа основного параметра
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyParameterEditResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_EDIT_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос удаления типа основного параметра.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receivePropertyParameterDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_DELETE_RESPONSE
         json: json
         errors: errors
      )


   #================================ Пользовательские действия =================


   ###*
   * Функция создания серверного действия в ответ
   *         на получение всех пользовательских действий
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveActions: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Action.ACTIONS_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение полей пользовательских действий
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveActionFields: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Action.ACTIONS_NEW_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос создания пользовательского действия
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveActionCreationResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Action.ACTIONS_CREATE_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на получение данных по пользовательскому действию
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveAction: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Action.ACTIONS_GET_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос редактирования данных пользовательского действия
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveActionEditResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Action.ACTIONS_EDIT_RESPONSE
         json: json
         errors: errors
      )

   ###*
   * Функция создания серверного действия в ответ
   *         на запрос удаления пользовательского действия.
   *
   * @param {Object} json   - результат запроса
   * @param {Object} errors - ошибки
   * @return
   ###
   receiveActionDeleteResult: (json, errors) ->
      SokolAppDispather.handleServerAction(
         type: ActionTypes.Action.ACTIONS_DELETE_RESPONSE
         json: json
         errors: errors
      )

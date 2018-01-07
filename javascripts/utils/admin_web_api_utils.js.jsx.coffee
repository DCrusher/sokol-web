
###* Зависимости: модули
* AdminServerActionCreators  - модуль создания серверных административных действий
* AdminFluxConstants         - константы для административной архитектуры flux
* request                    - библиотека для AJAX взаимодействия с API бизнес-логики
* string-template            - модуль для формирования строк из шаблонов.
###
AdminServerActionCreators = require('../actions/admin_server_action_creators')
AdminFluxConstants = require('../constants/admin_flux_constants')
request = require('superagent')
format = require('string-template')

###* Константы
* @param {String} _JSON_ACCEPT - тип данных для запроса
###
_JSON_ACCEPT = 'application/json'


# пути взаимодействия с API
endpoints = AdminFluxConstants.APIEndpoints
# типовые сообщения
messages = AdminFluxConstants.StandardMessages

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
* Модуль утилит взаимодействия с API административной части системы.
###
module.exports =


   #================================ Пользователи ==============================


   ###*
   * Функция запроса в API всех пользователей. По завершению запроса
   *  создает серверное действие receiveAllUsers.
   *
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
   getUsers: (requestParams) -> #, page, perPage, filterParams) ->
      params =
         page: requestParams.page
         per_page: requestParams.perPage
         matched_params: JSON.stringify(requestParams.filter)
      request.get(endpoints.USERS)
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

            AdminServerActionCreators.receiveUsers json, errors

   ###*
   * Функция запроса в API данных по конкретному пользователю. По завершению запроса
   *  создает серверное действие receiveUser.
   *
   * @param {String} userID - идентификатор пользователя
   * @return
   ###
   getUser: (userID) ->
      userEndpoint = "#{endpoints.USERS_ROOT}/#{userID}.json"

      request.get(userEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)
            else

         AdminServerActionCreators.receiveUser json, error

   ###*
   * Функция запроса в API полей для создания нового пользователя.
   *  По завершению запроса создает серверное действие receiveNewUserFields
   *
   * @return
   ###
   getUserFields: ->
      request.get(endpoints.NEW_USER)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse res.text

         AdminServerActionCreators.receiveUserFields json, error
         return
      return


   ###*
   * Функция отправки запроса на создания нового пользователя в API
   *
   * @param {Object} params - параметры нового пользователя.
   * @return
   ###
   createUser: (params) ->
      request.post(endpoints.USERS)
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

         AdminServerActionCreators.receiveUserCreationResult json, errors


   ###*
   * Функция отправки запроса на редактирование пользователя в API.
   *
   * @param {Object} params - параметры пользователя.
   * @param {String} userID - идентификатор пользователя.
   * @return
   ###
   editUser: (params, userID) ->
      userEditEndpoint = "#{endpoints.USERS_ROOT}/#{userID}.json"

      request.patch(userEditEndpoint)
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

         AdminServerActionCreators.receiveUserEditResult json, errors

   ###*
   * Функция отправки запроса на удаление пользователя в API
   *
   * @param {String} userID - идентификатор, удаляемого пользователя
   * @return
   ###
   deleteUser: (userID) ->
      userEndpoint = "#{endpoints.USERS_ROOT}/#{userID}.json"

      request.del(userEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receiveUserDeleteResult json, errors

   ###*
   * Функция отправки запроса на групповое удаление пользователей в API
   *
   * @param {Object} data - хэш с параметрами на отправку. Вид:
   *     {Object} markedKeys    - хэш с параметрами отмеченных строк и
   *                              строк со снятой отметкой.
   *     {Object} processedData - специфичные данные для операции, подготовленные
   *                                     пользовательскими обработчиками.
   *     {Boolean} isAllMarked  - флаг отметки всех строк.
   *     {Object} filterParams  - параметры фильтра.
   * @return
   ###
   deleteUsers: (data) ->
      groupDestroyEndpoint = endpoints.GROUP_DESTROY_USERS

      request.del(groupDestroyEndpoint)
      .send(
         marked_rows: data.markedKeys
         is_all_marked: data.isAllMarked
      )
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receiveUsersDeleteResult json, errors

   ###*
   * Функция отправки запроса на групповую блокировку пользователей в API.
   *
   * @param {Object} data - хэш с параметрами на отправку. Вид:
   *     {Object} markedKeys    - хэш с параметрами отмеченных строк и
   *                              строк со снятой отметкой.
   *     {Object} processedData - специфичные данные для операции, подготовленные
   *                                     пользовательскими обработчиками.
   *     {Boolean} isAllMarked  - флаг отметки всех строк.
   *     {Object} filterParams  - параметры фильтра.
   * @return
   ###
   blockUsers: (data) ->
      groupBlockEndpoint = endpoints.GROUP_BLOCK_USERS
      requestParams =
         marked_rows: data.markedKeys
         is_all_marked: data.isAllMarked

      request.post(groupBlockEndpoint)
      .send(requestParams)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receiveUsersBlockResult json, errors

   ###*
   * Функция отправки запроса на смену пароля пользователя в API.
   *
   * @param {Object} params         - параметры для запроса.
   * @param {String, Number} userID - идентификатор пользователя.
   * @return
   ###
   changePasswordUser: (params, userID) ->
      changePasswordEndpoint = format(endpoints.CHANGE_PASSWORD_USER, userID)

      request.post(changePasswordEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .send(params.data)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)


         AdminServerActionCreators.receiveUserChangePasswordResult json, errors

   ###*
   * Функция отправки запроса на блокировку/разблокировку пользователя в API
   *
   * @param {String, Number} userID - идентификатор пользователя.
   * @return
   ###
   blockUser: (userID) ->
      blockEndpoint = format(endpoints.BLOCK_USER, userID)

      request.post(blockEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)


         AdminServerActionCreators.receiveUserBlockResult json, errors

   ###*
   * Функция запроса в API данных по назначенным/доступным для назначения АРМам.
   *
   * @param {String} userID - идентификатор пользователя
   * @return
   ###
   getAssignedWorkplaces: (userID) ->
      assignedWorkplacesEndpoint = format(endpoints.ASSIGNED_WORKPLACES, userID)

      request.get(assignedWorkplacesEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)
            else

         AdminServerActionCreators.receiveAssignedWorkplaces json, error

   ###*
   * Функция  запроса в API на назначение АРМов пользователю.
   *
   * @param {Object} data - хэш с параметрами на отправку. Вид:
   *     {Object} customData    - сопутствующие пользовательские данные.
   *     {Object} markedKeys    - хэш с параметрами отмеченных строк и
   *                              строк со снятой отметкой.
   *     {Object} processedData - специфичные данные для операции, подготовленные
   *                                     пользовательскими обработчиками.
   *     {Boolean} isAllMarked  - флаг отметки всех строк.
   *     {Object} filterParams  - параметры фильтра.
   * @param {String} userID - идентификатор АРМа.
   * @return
   ###
   assignWorkplaces: (data, userID) ->
      assignedEndpoint = format(endpoints.ASSIGN_WORKPLACES, userID)
      requestParams =
         custom_data: data.customData
         user:
            marked_rows: data.markedKeys
            is_all_marked: data.isAllMarked

      request.post(assignedEndpoint)
      .send(requestParams)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)
            else

         AdminServerActionCreators.receiveWorkplacesAssignResult json, error

   #================================ АРМы ======================================


   ###*
   * Функция запроса в API всех АРМов. По завершению запроса
   *  создает серверное действие receiveWorkplaces.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getWorkplaces: (requestParams) ->
      params =
         page: requestParams.page
         per_page: requestParams.perPage
         matched_params:  JSON.stringify(requestParams.filter)
      request.get(endpoints.WORKPLACES)
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

            AdminServerActionCreators.receiveWorkplaces json, errors

   ###*
   * Функция запроса в API полей для создания нового АРМа.
   *  По завершению запроса создает серверное действие receiveWorkplaceFields
   *
   * @return
   ###
   getWorkplaceFields: ->
      request.get(endpoints.NEW_WORKPLACE)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->

         if res

            errors = _getErrors(res)

            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse res.text

         AdminServerActionCreators.receiveWorkplaceFields json, error
         return
      return

   ###*
   * Функция запроса в API данных по конкретному АРМу. По завершению запроса
   *  создает серверное действие receiveWorkplace.
   *
   * @param {String} workplaceID - идентификатор АРМа.
   * @return
   ###
   getWorkplace: (workplaceID) ->
      workplaceEndpoint = "#{endpoints.WORKPLACES_ROOT}/#{workplaceID}.json"

      request.get(workplaceEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)

            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receiveWorkplace json, error

   ###*
   * Функция отправки запроса на создания нового АРМа в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   createWorkplace: (params) ->
      request.post(endpoints.WORKPLACES)
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

         AdminServerActionCreators.receiveWorkplaceCreationResult json, errors

   ###*
   * Функция отправки запроса на редактирование АРМа в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   editWorkplace: (params, workplaceID) ->
      workplaceEditEndpoint = "#{endpoints.WORKPLACES_ROOT}/#{workplaceID}.json"

      request.patch(workplaceEditEndpoint)
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

         AdminServerActionCreators.receiveWorkplaceEditResult json, errors

   ###*
   * Функция отправки запроса на удаление АРМа в API.
   *
   * @param {String} workplaceID - идентификатор, удаляемого АРМа.
   * @return
   ###
   deleteWorkplace: (workplaceID) ->
      WorkplaceEndpoint = "#{endpoints.WORKPLACES_ROOT}/#{workplaceID}.json"

      request.del(WorkplaceEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receiveWorkplaceDeleteResult json, errors

   ###*
   * Функция запроса в API данных по назначенным/доступным для назначения действиям.
   *
   * @param {String} actionID - идентификатор АРМа
   * @return
   ###
   getAssignedActions: (actionID) ->
      assignedActionsEndpoint = format(endpoints.ASSIGNED_ACTIONS, actionID)

      request.get(assignedActionsEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)
            else

         AdminServerActionCreators.receiveAssignedActions json, error

   ###*
   * Функция  запроса в API на назначение действий АРМу.
   *
   * @param {Object} data - хэш с параметрами на отправку. Вид:
   *     {Object} markedKeys    - хэш с параметрами отмеченных строк и
   *                              строк со снятой отметкой.
   *     {Object} processedData - специфичные данные для операции, подготовленные
   *                                     пользовательскими обработчиками.
   *     {Boolean} isAllMarked  - флаг отметки всех строк.
   *     {Object} filterParams  - параметры фильтра.
   * @param {String} workplaceID - идентификатор АРМа.
   * @return
   ###
   assignActions: (data, workplaceID) ->
      assignedEndpoint = format(endpoints.ASSIGN_ACTIONS, workplaceID)
      requestParams =
         workplace:
            marked_rows: data.markedKeys
            is_all_marked: data.isAllMarked

      request.post(assignedEndpoint)
      .send(requestParams)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)
            else

         AdminServerActionCreators.receiveActionsAssignResult json, error


   #================================ Типы собственности ========================


   ###*
   * Функция запроса в API всех типов собственности. По завершению запроса
   *  создает серверное действие receivePropertyTypes.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getPropertyTypes: (requestParams) ->
      params =
         page: requestParams.page
         per_page: requestParams.perPage
         matched_params:  JSON.stringify(requestParams.filter)
      request.get(endpoints.PROPERTY_TYPES)
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

            AdminServerActionCreators.receivePropertyTypes json, errors

   ###*
   * Функция запроса в API полей для создания нового типа собственности
   *  По завершению запроса создает серверное действие receivePropertyTypesFields
   *
   * @return
   ###
   getPropertyTypeFields: ->
      request.get(endpoints.NEW_PROPERTY_TYPES)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse res.text

         AdminServerActionCreators.receivePropertyTypeFields json, error
         return
      return

   ###*
   * Функция отправки запроса на создания нового типа собственности в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   createPropertyType: (params) ->
      request.post(endpoints.PROPERTY_TYPES)
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

         AdminServerActionCreators.receivePropertyTypeCreationResult json, errors

   ###*
   * Функция запроса в API данных по конкретному типу собственности. По завершению запроса
   *  создает серверное действие receivePropertyType.
   *
   * @param {String} propertyTypeID - идентификатор типа собственности.
   * @return
   ###
   getPropertyType: (propertyTypeID) ->
      PropertyTypeEndpoint = "#{endpoints.PROPERTY_TYPES_ROOT}/#{propertyTypeID}.json"

      request.get(PropertyTypeEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receivePropertyType json, error

   ###*
   * Функция отправки запроса на редактирование типа собственности в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   editPropertyType: (params, propertyTypeID) ->
      PropertyTypeEditEndpoint = "#{endpoints.PROPERTY_TYPES_ROOT}/#{propertyTypeID}.json"

      request.patch(PropertyTypeEditEndpoint)
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

         AdminServerActionCreators.receivePropertyTypeEditResult json, errors

   ###*
   * Функция отправки запроса на удаление типа собственности в API
   *
   * @param {String} propertyTypeID - идентификатор удаляемого типа собственности
   * @return
   ###
   deletePropertyType: (propertyTypeID) ->
      PropertyTypeEndpoint = "#{endpoints.PROPERTY_TYPES_ROOT}/#{propertyTypeID}.json"

      request.del(PropertyTypeEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receivePropertyTypeDeleteResult json, errors


   #================================ Типы документо   в ========================


   ###*
   * Функция запроса в API всех типов документов. По завершению запроса
   *  создает серверное действие receivePropertyTypes.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getDocumentTypes: (requestParams) ->
      params =
         page: requestParams.page
         per_page: requestParams.perPage
         matched_params:  JSON.stringify(requestParams.filter)
      request.get(endpoints.DOCUMENT_TYPES)
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

            AdminServerActionCreators.receiveDocumentTypes json, errors

   ###*
   * Функция запроса в API полей для создания нового типа документов
   *  По завершению запроса создает серверное действие receiveDocumentTypesFields
   *
   * @return
   ###
   getDocumentTypeFields: ->
      request.get(endpoints.NEW_DOCUMENT_TYPES)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse res.text

         AdminServerActionCreators.receiveDocumentTypeFields json, error
         return
      return

   ###*
   * Функция отправки запроса на создания нового типа документов в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   createDocumentType: (params) ->
      request.post(endpoints.DOCUMENT_TYPES)
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

         AdminServerActionCreators.receiveDocumentTypeCreationResult json, errors

   ###*
   * Функция запроса в API данных по конкретному типу документов. По завершению запроса
   *  создает серверное действие receiveDocumentType.
   *
   * @param {String} documentTypeID - идентификатор типа документов.
   * @return
   ###
   getDocumentType: (documentTypeID) ->
      DocumentTypeEndpoint = "#{endpoints.DOCUMENT_TYPES_ROOT}/#{documentTypeID}.json"

      request.get(DocumentTypeEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receiveDocumentType json, error

   ###*
   * Функция отправки запроса на редактирование типа документов в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   editDocumentType: (params, documentTypeID) ->
      DocumentTypeEditEndpoint = "#{endpoints.DOCUMENT_TYPES_ROOT}/#{documentTypeID}.json"

      request.patch(DocumentTypeEditEndpoint)
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

         AdminServerActionCreators.receiveDocumentTypeEditResult json, errors

   ###*
   * Функция отправки запроса на удаление типа документов в API
   *
   * @param {String} documentTypeID - идентификатор удаляемого типа документов
   * @return
   ###
   deleteDocumentType: (documentTypeID) ->
      DocumentTypeEndpoint = "#{endpoints.DOCUMENT_TYPES_ROOT}/#{documentTypeID}.json"

      request.del(DocumentTypeEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receiveDocumentTypeDeleteResult json, errors


   #================================ Типы правоотношений ========================


   ###*
   * Функция запроса в API всех типов правоотношений. По завершению запроса
   *  создает серверное действие receivePropertyTypes.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getOwnershipTypes: (requestParams) ->
      params =
         page: requestParams.page
         per_page: requestParams.perPage
         matched_params:  JSON.stringify(requestParams.filter)
      request.get(endpoints.OWNERSHIP_TYPES)
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

            AdminServerActionCreators.receiveOwnershipTypes json, errors

   ###*
   * Функция запроса в API полей для создания нового типа правоотношений
   *  По завершению запроса создает серверное действие receiveOwnershipTypesFields
   *
   * @return
   ###
   getOwnershipTypeFields: ->
      request.get(endpoints.NEW_OWNERSHIP_TYPES)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse res.text

         AdminServerActionCreators.receiveOwnershipTypeFields json, error
         return
      return

   ###*
   * Функция отправки запроса на создания нового типа правоотношений в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   createOwnershipType: (params) ->
      request.post(endpoints.OWNERSHIP_TYPES)
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

         AdminServerActionCreators.receiveOwnershipTypeCreationResult json, errors

   ###*
   * Функция запроса в API данных по конкретному типу правоотношений. По завершению запроса
   *  создает серверное действие receiveOwnershipType.
   *
   * @param {String} ownershipTypeID - идентификатор типа правоотношений.
   * @return
   ###
   getOwnershipType: (ownershipTypeID) ->
      OwnershipTypeEndpoint = "#{endpoints.OWNERSHIP_TYPES_ROOT}/#{ownershipTypeID}.json"

      request.get(OwnershipTypeEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receiveOwnershipType json, error

   ###*
   * Функция отправки запроса на редактирование типа правоотношений в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   editOwnershipType: (params, ownershipTypeID) ->
      OwnershipTypeEditEndpoint = "#{endpoints.OWNERSHIP_TYPES_ROOT}/#{ownershipTypeID}.json"

      request.patch(OwnershipTypeEditEndpoint)
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

         AdminServerActionCreators.receiveOwnershipTypeEditResult json, errors

   ###*
   * Функция отправки запроса на удаление типа правоотношений в API
   *
   * @param {String} ownershipTypeID - идентификатор удаляемого типа правоотношений
   * @return
   ###
   deleteOwnershipType: (ownershipTypeID) ->
      OwnershipTypeEndpoint = "#{endpoints.OWNERSHIP_TYPES_ROOT}/#{ownershipTypeID}.json"

      request.del(OwnershipTypeEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receiveOwnershipTypeDeleteResult json, errors


   #================================ Типы основного параметра ==================


   ###*
   * Функция запроса в API всех типов основного параметра. По завершению запроса
   *  создает серверное действие receivePropertyTypes.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getPropertyParameters: (requestParams) ->
      params =
         page: requestParams.page
         per_page: requestParams.perPage
         matched_params:  JSON.stringify(requestParams.filter)
      request.get(endpoints.PROPERTY_PARAMETERS)
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

            AdminServerActionCreators.receivePropertyParameters json, errors

   ###*
   * Функция запроса в API полей для создания нового типа основного параметра
   *  По завершению запроса создает серверное действие receivePropertyParametersFields
   *
   * @return
   ###
   getPropertyParameterFields: ->
      request.get(endpoints.NEW_PROPERTY_PARAMETERS)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse res.text

         AdminServerActionCreators.receivePropertyParameterFields json, error
         return
      return

   ###*
   * Функция отправки запроса на создания нового типа основного параметра в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   createPropertyParameter: (params) ->
      request.post(endpoints.PROPERTY_PARAMETERS)
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

         AdminServerActionCreators.receivePropertyParameterCreationResult json, errors

   ###*
   * Функция запроса в API данных по конкретному типу основного параметра. По завершению запроса
   *  создает серверное действие receivePropertyParameter.
   *
   * @param {String} propertyParameterID - идентификатор типа основного параметра.
   * @return
   ###
   getPropertyParameter: (propertyParameterID) ->
      PropertyParameterEndpoint = "#{endpoints.PROPERTY_PARAMETERS_ROOT}/#{propertyParameterID}.json"

      request.get(PropertyParameterEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receivePropertyParameter json, error

   ###*
   * Функция отправки запроса на редактирование типа основного параметра в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   editPropertyParameter: (params, propertyParameterID) ->
      PropertyParameterEditEndpoint = "#{endpoints.PROPERTY_PARAMETERS_ROOT}/#{propertyParameterID}.json"

      request.patch(PropertyParameterEditEndpoint)
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

         AdminServerActionCreators.receivePropertyParameterEditResult json, errors

   ###*
   * Функция отправки запроса на удаление типа основного параметра в API
   *
   * @param {String} propertyParameterID - идентификатор удаляемого типа основного параметра
   * @return
   ###
   deletePropertyParameter: (propertyParameterID) ->
      PropertyParameterEndpoint = "#{endpoints.PROPERTY_PARAMETERS_ROOT}/#{propertyParameterID}.json"

      request.del(PropertyParameterEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receivePropertyParameterDeleteResult json, errors


   #================================ Пользовательские действия =================


   ###*
   * Функция запроса в API всех пользовательских действий. По завершению запроса
   *  создает серверное действие receiveActions.
   *
   * @param {Object} requestParams - хэш с параметрами запроса. Вид:
   *     {Number} page    - страница.
   *     {Number} perPage - кол-во записей на странице.
   *     {Object} metchedParams - параметры выборки.
   * @return
   ###
   getActions: (requestParams) ->
      params =
         page: requestParams.page
         per_page: requestParams.perPage
         matched_params:  JSON.stringify(requestParams.filter)
      request.get(endpoints.ACTIONS)
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


            AdminServerActionCreators.receiveActions json, errors

   ###*
   * Функция запроса в API полей для создания нового пользовательского действия
   *  По завершению запроса создает серверное действие receiveActionsFields
   *
   * @return
   ###
   getActionFields: ->
      request.get(endpoints.NEW_ACTION)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse res.text

         AdminServerActionCreators.receiveActionFields json, error
         return
      return

   ###*
   * Функция отправки запроса на создания нового пользовательского действия в API
   *
   * @param {Object} params - параметры запроса.
   * @return
   ###
   createAction: (params) ->
      request.post(endpoints.ACTIONS)
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

         AdminServerActionCreators.receiveActionCreationResult json, errors

   ###*
   * Функция запроса в API данных по конкретному пользоваьтельского действия. По завершению запроса
   *  создает серверное действие .
   *
   * @param {String} actionID - идентификатор пользовательского действия.
   * @return
   ###
   getAction: (actionID) ->
      ActionEndpoint = "#{endpoints.ACTIONS_ROOT}/#{actionID}.json"

      request.get(ActionEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receiveAction json, error

   ###*
   * Функция отправки запроса на редактирование пользовательского действия в API
   *
   * @param {Object} params - параметры запроса.
   * @param {String, Number} actionID - идентификатор экземпляра.
   * @return
   ###
   editAction: (params, actionID) ->
      ActionEditEndpoint = "#{endpoints.ACTIONS_ROOT}/#{actionID}.json"

      request.patch(ActionEditEndpoint)
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

         AdminServerActionCreators.receiveActionEditResult json, errors

   ###*
   * Функция отправки запроса на удаление пользовательского действия в API
   *
   * @param {String} actionID - идентификатор удаляемого типа недвижимости
   * @return
   ###
   deleteAction: (actionID) ->
      ActionEndpoint = "#{endpoints.ACTIONS_ROOT}/#{actionID}.json"

      request.del(ActionEndpoint)
      .set('Accept', _JSON_ACCEPT)
      .end (error, res) ->
         errors = undefined
         json = undefined

         if res
            errors = _getErrors(res)
            # если нет ошибок считаем результат
            unless errors?
               json = JSON.parse(res.text)

         AdminServerActionCreators.receiveActionDeleteResult json, errors

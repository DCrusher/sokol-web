
###* Зависимости: модули
* ServerActionCreators       - модуль создания серверных действий
* UserServerActionCreators   - модуль создания серверных пользовательских действий
* SokolFluxConstants         - константы для пользовательской архитектуры flux
* request                    - библиотека для AJAX взаимодействия с API бизнес-логики
###
ServerActionCreators = require('../actions/server_action_creators')
UserServerActionCreators = require('../actions/user_server_action_creators')
SokolFluxConstants = require('../constants/flux_constants')
request = require('superagent')


###* Константы
* @param {String} _JSON_ACCEPT - тип данных для запроса
###
_JSON_ACCEPT = 'application/json'

# пути взаимодействия с API
endpoints = SokolFluxConstants.APIEndpoints
# типовые сообщения
messages = SokolFluxConstants.StandardMessages

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
* Модуль утилит взаимодействия с API пользовательской части системы.
###
module.exports =

   #================================ Аутентификация ==============================

   ###*
   * Функция отправки запроса в БЛ на аутентификацию.
   *
   * @param {String} login    - логин/электронная почта пользователя.
   * @param {String} password - пароль.
   * @return
   ###
   signin: (login, password) ->
      request.post(endpoints.SIGNIN_AUTH)
             .send(
                login: login
                password: password
                grant_type: 'password')
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                json = null
                errors = null

                if res
                   if res.status in [400, 404]
                      errors = _getErrors(res)
                   else
                      json = JSON.parse(res.text)

                ServerActionCreators.receiveSigninResult json, errors


   ###*
   * Функция отрпавки запроса в БЛ на выход из аутентификации (уничтожение
   *  сессии пользователя)
   *
   * @return
   ###
   signout: ->
      request.del(endpoints.SIGNOUT)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                json = null
                errors = null

                if res
                   if res.status in [400, 404]
                      errors = _getErrors(res)
                   else
                      json = JSON.parse(res.text)

                ServerActionCreators.receiveSignoutResult json, errors

   #================================ Действия пользователя ==============================

   ###*
   * Функция отрпавки запроса в БЛ на получения пользовательских АРМов с разрешенными
   *  действиями.
   *
   * @return
   ###
   getAllUserActions: ->
      request.get(endpoints.USER_ACTIONS)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                json = null
                errors = null

                if res
                   if res.status in [400, 404]
                      errors = _getErrors(res)
                   else
                      json = JSON.parse(res.text)

                ServerActionCreators.receiveUserActions json, errors

   #================================ Профиль ==============================

   ###*
   * Функция запроса в API данных по профилю. По завершению запроса
   *  создает серверное действие receiveProfile.
   *
   * @return
   ###
   getProfile: ->
      request.get(endpoints.PROFILE)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                UserServerActionCreators.receiveProfile json, error

   ###*
   * Функция отправки запроса на редактирование профиля в API.
   *
   * @param {Object} params - параметры профиля.
   * @return
   ###
   editProfile: (params) ->
      request.patch(endpoints.PROFILE)
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

                UserServerActionCreators.receiveProfileEditResult json, errors

   ###*
   * Функция отправки запроса на смену пароля в профиле в API.
   *
   * @param {Object} params         - параметры - текущий пароль/пароль/подтверждение
   * @return
   ###
   editPassword: (params)->
      request.post(endpoints.PROFILE_CHP)
             .send(params.data)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   unless errors?
                      json = JSON.parse(res.text)

                UserServerActionCreators.receiveProfileEditPassword json, errors

   ###*
   * Функция отправки запроса на получение констант обмена.
   *
   * @param {Object} requestParams - параметры запроса.
   * @return
   ###
   getExchangeConstants: (requestParams) ->
      request.get(endpoints.PROFILE_EXCHANGE_CONSTANTS)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   unless errors?
                      json = JSON.parse(res.text)

                UserServerActionCreators.receiveExchangeConstants json, errors

   ###*
   * Функция отправки запроса на задание констант форматов обмена.
   *
   * @param {Object} requestParams - параметры запроса.
   * @return
   ###
   setExchangeConstants: (requestParams) ->
      request.post(endpoints.PROFILE_EXCHANGE_CONSTANTS)
             .send(requestParams.data)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   unless errors?
                      json = JSON.parse(res.text)

                UserServerActionCreators.receiveSetExchangeConstantsResult json, errors

   #================================ Фильтры пользователя ==============================

   ###*
   * Функция отправки запроса в БЛ на получение пользовательских фильтров.
   *
   * @param {Object} modelName - имя модели.
   * @return
   ###
   getUserFilters: (modelName) ->
      request.get(endpoints.USER_FILTERS)
             .query({model: modelName})
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                  # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                UserServerActionCreators.receiveUserFilters json, errors

   ###*
   * Функция запроса в API полей для создания нового пользовательского фильтра.
   *  По завершению запроса создает серверное действие receiveUserFilterFields
   *
   * @return
   ###
   getUserFilterFields: ->
      request.get(endpoints.NEW_FILTER)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse res.text

                UserServerActionCreators.receiveUserFilterFields json, errors

   ###*
   * Функция запроса в API полей для создания нового пользовательского фильтра.
   *  По завершению запроса создает серверное действие receiveUserFilter
   *
   * @param {String} filterID - идентификатор пользовательского фильтра.
   * @return
   ###
   getUserFilter: (filterID) ->
      filterEndpoint = "#{endpoints.USER_FILTERS_ROOT}/#{filterID}.json"

      request.get(filterEndpoint)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse res.text

                UserServerActionCreators.receiveUserFilter json, errors

   ###*
   * Функция отправки запроса в БЛ на создание пользовательского фильтра.
   *
   * @param {Object} filterParams - сохраняемые параметры фильтра.
   * @return
   ###
   createUserFilter: (filterParams) ->
      request.post(endpoints.USER_FILTERS)
             .send(filterParams.data)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                  # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                UserServerActionCreators.receiveUserFilterCreationResult json,
                                                                         errors

   ###*
   * Функция отправки запроса на редактирование пользовательского фильтра в API.
   *
   * @param {Object} params        - параметры фильтра.
   * @param {String} filterID - идентификатор фильтра.
   * @return
   ###
   editUserFilter: (params, filterID) ->
      filterEditEndpoint = "#{endpoints.USER_FILTERS_ROOT}/#{filterID}.json"

      request.patch(filterEditEndpoint)
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

                UserServerActionCreators.receiveUserFilterEditingResult json,
                                                                        errors

   ###*
   * Функция отправки запроса на удаление правообладателя в API
   *
   * @param {String} filterID - идентификатор удаляемого правообладателя
   * @return
   ###
   deleteUserFilter: (filterID) ->
      filtersDeleteEndpoint = "#{endpoints.USER_FILTERS_ROOT}/#{filterID}.json"

      request.del(filtersDeleteEndpoint)
             .set('Accept', _JSON_ACCEPT)
             .end (error, res) ->
                errors = undefined
                json = undefined

                if res
                   errors = _getErrors(res)
                   # если нет ошибок считаем результат
                   unless errors?
                      json = JSON.parse(res.text)

                UserServerActionCreators.receiveUserFilterDeleteResult json,
                                                                       errors


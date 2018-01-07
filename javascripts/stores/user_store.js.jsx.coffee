
###* Зависимости: модули
* SokolAppDispather          - flux диспетчер
* SokolFluxConstants         - константы для пользовательской архитектуры flux
* EventEmitter               - модуль для работы с системой событий
* assign                     - модуль для слияния объектов
###
SokolAppDispatcher = require('../dispatcher/app_dispatcher')
SokolFluxConstants = require('../constants/flux_constants')
EventEmitter = require('events').EventEmitter
assign = require('object-assign')

###* Константы
* {String} _CHANGE_EVENT - тип события на изменение хранилища
###
_CHANGE_EVENT = SokolFluxConstants.EventTypes.CHANGE_EVENT

# Типы событий
ActionTypes = SokolFluxConstants.ActionTypes

###* ========= Профиль ========= *###

###*
* @param {Array} - массив с данными по текущему профилю.
###
_profileData = {}

###*
* @param {Object} - результат редактирования данных текущего профиля.
###
_profileEditResult = {}

###*
* @param {Object} - результат установки пароля текущего профиля.
###
_profileEditPasswordResult = {}

###*
* @param {Object} - константы форматов обмена.
###
_exchangeConstants = {}

###*
* @param {Object} - результат установки констант форматов обмена.
###
_setExchangeConstantsResult = {}


###* ========= Фильтры пользователя ========= *###

###*
* @param {Object} - пользовательские фильтры.
###
_userFilters = []

###*
* @param {Object} - параметры по фильтру.
###
_userFilterParams = {}

###*
* @param {Object} - результат создания пользовательского фильтра.
###
_userFilterCreationResult = {}

###*
* @param {Object} - результат редактирования пользовательского фильтра.
###
_userFilterEditingResult = {}

###*
* @param {Object} - результат удаления пользовательского фильтра.
###
_userFilterDeleteResult = {}

###*
* @param {String} - последнее событие.
###
_lastInteraction = null

###*
* модуль хранилища клиентских состояний для пользовательской части.
###
UserStore = assign({}, EventEmitter.prototype,
   emitChange: ->
      @emit(_CHANGE_EVENT)

   addChangeListener: (callback) ->
      @on(_CHANGE_EVENT, callback)

   removeChangeListener: (callback) ->
      @removeListener(_CHANGE_EVENT, callback)

   ###* ========= Профиль ========= *###

   ###*
   * Геттер данных по профилю.
   *
   * @return {Object}
   ###
   getProfileData: ->
      _profileData

   ###*
   * Геттер результата редактирования данных профиля.
   *
   * @return {Object}
   ###
   getProfileEditResult: ->
      _profileEditResult

   ###*
   * Геттер результата задания пароля профиля.
   *
   * @return {Object}
   ###
   getProfileEditPasswordResult: ->
      _profileEditPasswordResult

   ###*
   * Геттер констант форматов обмена.
   *
   * @return {Object}
   ###
   getExchangeConstants: ->
      _exchangeConstants

   ###*
   * Геттер результата установки констант форматов обмена.
   *
   * @return {Object}
   ###
   getSetExchangeConstantsResult: ->
      _setExchangeConstantsResult


   ###* ========= Фильтры пользователя ========= *###

   ###*
   * Геттер пользовательских фильтров.
   *
   * @return {Array}
   ###
   getUserFilters: ->
      _userFilters

   ###*
   * Геттер параметров фильтра.
   *
   * @return {Object}
   ###
   getUserFilter: ->
      _userFilterParams

   ###*
   * Геттер результата создания пользовательского фильтра.
   *
   * @return {Object}
   ###
   getUserFilterCreationResult: ->
      _userFilterCreationResult

   ###*
   * Геттер результата редактирования пользовательского фильтра.
   *
   * @return {Object}
   ###
   getUserFilterEditingResult: ->
      _userFilterEditingResult

   ###*
   * Геттер результата удаления пользовательского фильтра.
   *
   * @return {Object}
   ###
   getUserFilterDeleteResult: ->
      _userFilterDeleteResult

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
      _lastInteraction = action.type
      profileTypes = ActionTypes.Profile
      userFilterTypes = ActionTypes.UserFilter
      isViewAction = source is SokolFluxConstants.PayloadSources.VIEW_ACTION

      # Пока не обрабатываем события интерфейса.
      return if isViewAction

      switch _lastInteraction
         # Возврат данных профиля.
         when profileTypes.PROFILE_GET_RESPONSE
            _profileData = result
            UserStore.emitChange()
         # Редактирование данных профиля.
         when profileTypes.PROFILE_EDIT_RESPONSE
            _profileEditResult = action
            UserStore.emitChange()
         # Редактирование пароля пользователя.
         when profileTypes.PROFILE_CHP_RESPONSE
            _profileEditPasswordResult = action
            UserStore.emitChange()
         # Получение констант формата обмена.
         when profileTypes.PROFILE_GET_EXCHANGE_CONSTANTS_RESPONSE
            _exchangeConstants = action
            UserStore.emitChange()
         # Получение результата установки констант формата обмена.
         when profileTypes.PROFILE_SET_EXCHANGE_CONSTANTS_RESPONSE
            _setExchangeConstantsResult = action
            UserStore.emitChange()

         # Получение набора пользовательских фильтров.
         when userFilterTypes.USER_FILTERS_RESPONSE
            _userFilters = action
            UserStore.emitChange()
         # Получение параметров фильтра(поля нового или экзмепляра)
         when userFilterTypes.USER_FILTER_NEW_RESPONSE, userFilterTypes.USER_FILTER_GET_RESPONSE
            _userFilterParams = action
            UserStore.emitChange()
         # Создание пользователького фильтра.
         when userFilterTypes.USER_FILTER_CREATE_RESPONSE
            _userFilterCreationResult = action
            UserStore.emitChange()
         # Редактирование пользователького фильтра.
         when userFilterTypes.USER_FILTER_EDIT_RESPONSE
            _userFilterEditingResult = action
            UserStore.emitChange()
         # Удаление пользователького фильтра.
         when userFilterTypes.USER_FILTER_DELETE_RESPONSE
            _userFilterDeleteResult = action
            UserStore.emitChange()
   )

module.exports = UserStore
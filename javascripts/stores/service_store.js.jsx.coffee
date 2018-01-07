###* Зависимости: модули
* SokolAppDispather    - flux диспетчер
* ServiceFluxConstants - константы для сервисной части архитектуры flux
* EventEmitter         - библиотека для создания событий.
* assign               - библиотека для мержа хэшей.
* lodash                - модуль служебных операций.
###
SokolAppDispatcher = require('../dispatcher/app_dispatcher')
ServiceFluxConstants = require('../constants/service_flux_constants')
EventEmitter = require('events').EventEmitter
assign = require('object-assign')
_ = require('lodash')

EventEmitter.defaultMaxListeners = Infinity

###* Константы
# Типы событий
###
ActionTypes = ServiceFluxConstants.ActionTypes

###*
* @param {Object} - хэш для хранения всех данных для компонентов.
*           Структура: model -> componentID -> method
###
_serviceStore = {}

###*
* @param {Object} - хэш для хранения словарей поля выбора(Selector).
###
_selectorDictionaries = {}

###*
* @param {Object} - хэш для хранения выбранных экземпляров поля выбора(Selector).
###
_selectorInstances = {}

###*
* @param {String} - последнее событие.
###
_lastInteraction = undefined

###*
* @param {Object} - последний объект события.
###
_lastEvent = undefined

###*
* @param {String} - последнее идентификатор компонента Selector, по которому было взаимодействие.
###
_lastSelectorIdentifier = undefined

###*
* модуль хранилища состояний для сервисной части.
###
ServiceStore = assign({}, EventEmitter.prototype,
    _CHANGE_EVENT: ServiceFluxConstants.EventTypes.CHANGE_EVENT

   emitChange: ->
      @emit(@_CHANGE_EVENT)

   addChangeListener: (callback) ->
      @on(@_CHANGE_EVENT, callback)

   removeChangeListener: (callback) ->
      @removeListener(@_CHANGE_EVENT, callback)

   ###*
   * Геттер последнего события
   * @return {String}
   ###
   getLastInteraction: ->
      _lastInteraction

   getLastInteractionSelectorIdentifier: ->
      _lastSelectorIdentifier

   getSelectorDictionaries: ->
      _selectorDictionaries

   getSelectorInstances: ->
      _selectorInstances

   ###* ========= СТАНДАРТНЫЕ МЕТОДЫ ХРАНИЛИЩА ========= *###

   ###*
   * Геттер объектов последнего события.
   *
   * @return {Object}
   ###
   getLastEvent: ->
      _lastEvent

   ###*
   * Функция-предикат для проверки совпадения последнего события
   *  переданным параметрам.
   *
   * @param {String} model - имя модели компонента.
   * @param {Number, String} componentID - идентификатор компонента.
   * @param {String} APIMethod - имя метода компонента.
   * @return {Boolean}
   ###
   isLastInteraction: (model, componentID, APIMethod)->
      lastEvent = _lastEvent

      if lastEvent? and !_.isEmpty(lastEvent)
         lastEvent.model is model and
         lastEvent.componentID is componentID and
         lastEvent.APIMethod is APIMethod
      else
         false

   ###
   * Функция-предикат для определния было ли последнее событие для конкретного
   *  компонента. Проверка идет по имени модели и идентификатору компонента.
   *
   * @param {String} model               - имя модели.
   * @param {String, Number} componentID - идентификатор компонента.
   * @return {Boolean}
   ###
   isEventOccuredForComponent: (model, componentID) ->
      lastEvent = _lastEvent

      if lastEvent and !_.isEmpty(lastEvent)
         lastEvent.model is model and lastEvent.componentID is componentID
      else
         false

   ###*
   * Функция-предикат для определения было ли последенее событие для конкретной
   *  модели.
   *
   * @param {String} model - имя модели.
   * @return {Boolean}
   ###
   isEventOccuredForModel: (model) ->
      lastEvent = _lastEvent

      if lastEvent and !_.isEmpty(lastEvent)
         lastEvent.model is model
      else
         false

   ###*
   * Функция получения данных для конкретного экземпляра компонента.
   *
   * @param {String} model               - имя модели компонента.
   * @param {Number, String} componentID - идентификатор компонента.
   * @param {String} method              - имя метода компонента.
   * @param {String} customMethod        - имя произвольного метода компонента.
   * @return {Object}
   ###
   getData: (model, componentID, method, customMethod) ->
      componentData = _serviceStore[model] and _serviceStore[model][componentID]

      if componentData?
         if customMethod?
            componentData[customMethod]
         else if method?
            componentData[method]

   ###*
   * Функция получения данных для конкретного экземпляра компонента по
   *  параметрам события.
   *
   * @param {Object} eventParams - параметры события.
   * @return {Object}
   ###
   getDataByEvent: (eventParams) ->
      @getData(eventParams.model,
               eventParams.componentID,
               eventParams.APIMethod,
               eventParams.customMethod)

   # TODO: реализовать подход к удалению данных для конкретного компонента
   #       (таблицы) при его размонтировании.

   dispatcherIndex: SokolAppDispatcher.register (payload) ->
      source = payload.source
      action = payload.action
      result = action
      errors = action.errors
      eventType = action.type

      if eventType?
         componentID = eventType.componentID
         model = eventType.model
         APIMethod = eventType.APIMethod
         customMethod = eventType.customMethod
         APIType = eventType.type
         isViewAction = source is ServiceFluxConstants.PayloadSources.VIEW_ACTION
         _lastEvent = eventType
         operationResult = _.cloneDeep(result)

      # Пока не обрабатываем события интерфейса.
      return if isViewAction

      # Если работаем с параметрезированным событием - записываем результат
      #  в общий хэш данных.
      # Иначе работаем по обычной схеме.
      if _.isPlainObject(eventType)
         # Записываем результат по пути model -> componentID -> APIMethod
         unless _serviceStore[model]?
            _serviceStore[model] = {}

         unless _serviceStore[model][componentID]?
            _serviceStore[model][componentID] = {}

         if customMethod?
            _serviceStore[model][componentID][customMethod] = operationResult
         else
            unless _serviceStore[model][componentID][APIMethod]?
               _serviceStore[model][componentID][APIMethod] = {}

            _serviceStore[model][componentID][APIMethod] = operationResult

         ServiceStore.emitChange()
      else
         _lastInteraction = eventType
         switch _lastInteraction
            when ActionTypes.SELECTOR_DICTIONARY_RESPONSE
               _selectorDictionaries = result.json
               _lastSelectorIdentifier = action.identifier
               ServiceStore.emitChange()
            when ActionTypes.SELECTOR_INSTANCES_RESPONSE
               _selectorInstances = result.json
               _lastSelectorIdentifier = action.identifier

               ServiceStore.emitChange()

   )


module.exports = ServiceStore
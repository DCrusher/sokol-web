###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* HelpersMixin     - функции-хэлперы для компонентов.
* RequestBuilderMixin - модуль взаимодействия с API.
* ImplementationStore        - модуль-хранилище стандартных реализаций.
* keymirror        - модуль для генерации "зеркального" хэша.
* lodash           - модуль служебных операций.
###
StylesMixin = require('components/mixins/styles')
HelpersMixin = require('components/mixins/helpers')
RequestBuilderMixin = require('components/application/mixins/request_builder')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* AjaxLoader    - индикатор загрузки.
* DynamicForm   - динамическая форма.
###
AjaxLoader = require('components/core/ajax_loader')
DynamicForm = require('components/core/dynamic_form')

###* Константы
* _COLORS               - цвета
* _COMMON_PADDING       - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius

###* Прикладной компонент - подготовитель печатных форм.
*
* @props
*     {Object} instance            - запись экземпляра для которого подготавливается
*                                    печатная форма.
* @state
*     {String} preparerState  - наименование текущего состояния компонента
*     {Object} analyseContent - параметры для создания формы наполнения для анализа.
###

AnalysePreparer = React.createClass

   # @const {String} - наименование ресурса с которым взаимодействуют компонент
   #                   (корень ресурса).
   _RESOURCE_ROOT: 'analyses'

   # @const {Object} - наименования возможных состояний компонента.
   _PREPARER_STATES: keyMirror(
      init: null
      contentReady: null
      done: null
   )

   # @const {Object} - используемые наименования ссылок.
   _REFS: keyMirror(
      analyseContentForm: null
   )

   # @const {Object} - статичные параметры для динамической формы заполнения данными
   #                   анализа.
   _ANALYSE_DYNAMIC_FORM_PARAMS:
      modelParams:
         name: 'analyse'
      externalEntitiesParams:
         isAllowAllExternalToExternal: true
      isUseImplementation: true
      isMergeImplementation: true

   # @const {Object} - текст-пояснение для загрузчика.
   _LOADER_INSCRIPTION: 'Загружается форма для проведения анализа...'

   mixins: [RequestBuilderMixin]

   styles:
      container:
         minWidth: 200
         minHeight: 100

   getInitialState: ->
      preparerState: 'init'


   render: ->
      `(
         <div style={this.styles.container}>
            {this._getContent()}
            <AjaxLoader isShown={this._isInitState()}
                        text={this._LOADER_INSCRIPTION}
                     />
         </div>
      )`

   componentWillMount: ->
      @_sendInitRequest()

   _getContent: ->
      ImplementationStore =
         require('components/content/implementations/implementation_store')

      if @_isContentReady()
         `(
            <DynamicForm ref={this._REFS.analyseContentForm}
                         presetParams={this.state.analyseContent}
                         customSubmitHandler={this._onSubmitAnalyse}
                         implementationStore={ImplementationStore}
                         {...this._ANALYSE_DYNAMIC_FORM_PARAMS}
                     />
         )`

   ###*
   * Функция-обработчик на отправку запроса формы.
   *
   * @param {Object} formData          - данные формы для отправки.
   * @param {Object} _updateIdentifier - результат запроса(ответ).
   * @return
   ###
   _onSubmitAnalyse: (formData, _updateIdentifier) ->
      analyzedInstance = @props.instance

      @_sendRequest(
         endpoint: @_constructEndpoint(@_API_ACTIONS.index, @_RESOURCE_ROOT)
         requestType: @_REQUEST_TYPES.post
         requestParams: formData
         queryParams:
            analyse_procedure_id: 1
            analyzed_object: JSON.stringify(
               key: analyzedInstance.key
               model: analyzedInstance.model
            )

         callback: @_getAnalyseReleasedResponse
      )

   ###*
   * Функция-обработчик сохранения экземпляра анализа. Получает ответ, финализирует
   *  запрос в динамической форме на сохранения данных запроса, из ответа получает
   *  ссылку на файл и если ссылка задана - загружает файл.
   *
   * @param {Object} error    - объект ошибок.
   * @param {Object} response - объект ответа.
   * @return
   ###
   _getAnalyseReleasedResponse: (error, response) ->
      response = JSON.parse(response.text)

      @refs[@_REFS.analyseContentForm].finalizeRequest(response)

      if response.file?
         location.href = response.file

   ###*
   * Функция обработки ответа на запрос списка доступных печатных форм. Устанавливает
   *  список доступных форм в состояние компонента.
   *
   * @param {Object}  error   - ошибки.
   * @param {Object} response - результат запроса(ответ).
   * @return
   ###
   _getInitAnalyseList: (error, response) ->
       console.log response

   ###*
   * Функция получения содержимого для построения формы наполнения данными для
   *  проведения анализа.
   *
   * @return
   ###
   _getAnalyseContent: (error, response) ->
      analyseContent = JSON.parse(response.text)

      @setState
         analyseContent: analyseContent
         preparerState: @_PREPARER_STATES.contentReady

   ###*
   * Функция-предикат для определения находится ли компонент в инициализационной
   *  стадии.
   *
   * @return {Boolean}
   ###
   _isInitState: ->
      @state.preparerState is @_PREPARER_STATES.init

   ###*
   * Функция-предикат для определения находится ли компонент с стадии готовой,
   *  к построению содержимого
   *
   * @return {Boolean}
   ###
   _isContentReady: ->
      @state.preparerState is @_PREPARER_STATES.contentReady

   ###*
   * Функция отправки начального запроса на получения списка доступных
   *  печатных форм.
   *
   * @return
   ###
   _sendInitRequest: ->
      @_sendRequest(
         endpoint: @_constructEndpoint(@_ENDPOINT_METHODS.new, @_RESOURCE_ROOT)
         requestType: @_REQUEST_TYPES.get
         queryParams:
            analyse_procedure_id: 1
         callback: @_getAnalyseContent
      )


module.exports = AnalysePreparer
###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin         - общие стили для компонентов.
* HelpersMixin        - функции-хэлперы для компонентов.
* async               - модуль для асинхронной работы с функциями.
* keymirror        - модуль для генерации "зеркального" хэша.
* form-serialize        - модуль для серилизации данных формы.

###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
async = require('async')
keyMirror = require('keymirror')
serialize = require('form-serialize')

###* Зависимости: компоненты
* Flasher    - список сообщений.
* FormInput  - текстовое поле ввода формы с валидациями.
* DropDown   - выпадающий список.
* Button     - кнопка.
* AjaxLoader - индикатор загрузки.
###
Flasher = require('components/core/flasher')
FormInput = require('components/core/form_input')
DropDown = require('components/core/dropdown')
Button = require('components/core/button')
AjaxLoader = require('components/core/ajax_loader')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding

###* Компонент: статическая форма ввода
*
* @props:
*     {Array<Object>} fields - массив полей. Каждое поле описывается хэшем вида:
*                              {
*                                 {String} type: - тип поля ('text'(по-умолчанию),
*                                                            'password',
*                                                            'date',
*                                                            'number').
*                                 {String, Number} value: - значение.
*                                 {String} name:          - имя поля.
*                                 {String} caption:       - выводимый заголовок.
*                                 {String} defaultValue:  - значение по-умолчанию (задаваемое
*                                                           полю при сбрасывании)
*                                 {Boolean} isHidden:     - флаг скрытого поля.
*                              }
*     {Obejct<Object, String, Function>} fluxParams   - хэш с параметрами.
*                                        flux-архитектуры для работы с данными:
*                               {Object} store        - хранилище flux, изменения которого слушаем.
*                             {Function} sendRequest  - функция отправки данных формы.
*                             {Funciton} getResponse  - функция получения данных из хранилища flux.
*                               {String} responseType - тип события в хранилище, которое слушаем.
*     {Object} modelParams   - параметры модели по которому создаётся поле. Вид:
*                 {String} name    - имя экземпляра модели, по которому заполняется поле.
*                 {String} caption - заголовок поля, по которму заполняется поле.
*                                   (для корректного формирования значений формы).
*
*     {String} submitCaption - надпись на кнопке отправки формы (при пустом
*                              значении будет надпись по умолчанию).
*     {String} resetCaption  - надпись на кнопке очистки формы (при пустом
*                              значении будет надпись по умолчанию).
*     {String} recordID      - идентификатор записи по которой будет осуществлятся
*                              отправка данных.
*     {String} successInscription - текст, возвращаемый в обработчик onSuccess(если задан),
*                                   если данный параметр не задан - возвращается надпись
*                                   по-умолчанию.
*     {Function} onSuccess   - обработчик, запускаемый после удачной отправки формы. Аргументы:
*           {Object} response           - ответ, возвращенный БЛ.
*           {String} successInscription - сообщение об успешном выполнении.
*           {Number} recordID           - идентификатор по которому была отправка запроса.
* @state:
*     {Boolean} isRefreshed     - флаг того что форма была сброшена.
*     {Object} validationResult - хэш с результатами валидации.
*     {String} requestStatus    - идентификатор, результата отправки формы:
*                                 'ready'     - компонент готов к запросу.
*                                 'requested' - компонент отправил запрос.
*                                 'responded' - компонент получил ответ.
*     {React-DOM-Node} activityTarget - целевой узел для плавающих компонентов.
###
StaticForm = React.createClass
   _SUBMIT_DEFAULT_CAPTION: 'Сохранить'
   _RESET_DEFAULT_CAPTION: 'Сбросить'
   _SUCCESS_INSCRIPTION_DEFAULT: 'Запись успешно обновлена'

   # @const {Object} - параметры объекта сообщений по-умолчанию.
   _FLASHER_DEFAULT_PARAMS:
      caption:
         error: 'Возникли ошибки при сохранении'
      messages:
         success:
            text: 'Запрос успешно выполнен'
            type: 'success'

   # @const {Object} - хэш возможных сосояний компонента
   _REQUEST_STATUSES: keyMirror(
      ready: null
      requested: null
      responded: null
   )

   # @const {Object} - набор используемых ссылок.
   _REFS: keyMirror(
      staticForm: null
      fields: null
   )

   # @const {Object} - набор символов.
   _CHARS:
      colon: ':'
      space: ' '
      empty: ''

   # @const {Object} - параметры кнопок.
   _BUTTON_PARAMS:
      submit:
         type: 'submit'
         icon: 'save'
      reset:
         type: 'reset'
         icon: 'refresh'

   # @const {String} - тип иконки ajax-загрузчика.
   _LOADER_VIEW: 'spinner'


   styles:
      commandWrapper:
         textAlign: 'right'
         padding: _COMMON_PADDING
         borderTopWidth: 1
         borderTopStyle: 'solid'
         borderTopColor: _COLORS.hierarchy3
         marginTop: _COMMON_PADDING
      buttonSubmit:
         marginRight: _COMMON_PADDING

   propTypes:
      fields: React.PropTypes.arrayOf(React.PropTypes.object)
      modelParams: React.PropTypes.object
      fluxParams: React.PropTypes.object
      submitCaption: React.PropTypes.string
      resetCaption: React.PropTypes.string
      recordID: React.PropTypes.oneOfType([
            React.PropTypes.string,
            React.PropTypes.number
         ])
      onSuccess: React.PropTypes.func
      successInscription: React.PropTypes.string

   getInitialState: ->
      isRefreshed: false
      validationResult: {}
      requestStatus: @_REQUEST_STATUSES.ready
      activityTarget: {}

   render: ->
      fieldsCount = @props.fields.length
      submitCaption = @props.submitCaption || @_SUBMIT_DEFAULT_CAPTION
      resetCaption = @props.resetCaption || @_RESET_DEFAULT_CAPTION
      flasherContent = @_getFlasherContent()
      isRequesting = @state.requestStatus is @_REQUEST_STATUSES.requested
      refs = @_REFS
      buttonParams = @_BUTTON_PARAMS

      `(
         <form onSubmit={this._onSubmit}
               onReset={this._onReset}
               ref={refs.staticForm} >
            <Flasher formMessages={this.state.validationResult}
                     customMessages={flasherContent.messages}
                     caption={flasherContent.caption} />
            <StaticFormFields ref={refs.fields}
                              modelParams={this.props.modelParams}
                              fields={this.props.fields}
                              isReset={this.state.isRefreshed}
                              onChange={this._resetRefreshed} />
            <div style={this.styles.commandWrapper}>
               <Button type={buttonParams.submit.type}
                       title={submitCaption}
                       caption={submitCaption}
                       tabIndex={fieldsCount}
                       styleAddition={this.styles.buttonSubmit}
                       icon={buttonParams.submit.icon} />
               <Button type={buttonParams.reset.type}
                       title={resetCaption}
                       caption={resetCaption}
                       tabIndex={fieldsCount + 1}
                       icon={buttonParams.reset.icon} />
            </div>
            <AjaxLoader isShown={isRequesting}
                        target={this.state.activityTarget}
                        view={this._LOADER_VIEW} />
         </form>
       )`

   componentDidMount: ->
      @props.fluxParams.store.addChangeListener @_onChange
      @setState activityTarget: @refs.staticForm


   comonentWillUnmount: ->
      @props.fluxParams.store.removeChangeListener @_onChange

   ###*
   * Функция сброса флага обновленности
   *
   * @return
   ###
   _resetRefreshed: ->
      @setState
         isRefreshed: false

   ###*
   * Функция получения данных для списка сообщений (Flasher) с результатами запроса.
   *
   * @return {Object} - хэш для flasher - caption  - заголовок для Flasher-a
   *                                      messages - массив(формат нужен для Flahser-a),
   *                                                 содержащее сообщение об успехе запроса.
   ###
   _getFlasherContent: ->
      flasherCaption = ''
      successMessages = []
      flasherParams = @_FLASHER_DEFAULT_PARAMS

      if @state.requestStatus is @_REQUEST_STATUSES.responded

         # Если нет ошибок - формируем результат успешного запроса.
         if $.isEmptyObject(@state.validationResult)
            successMessages.push flasherParams.messages.success
         else
            flasherCaption = flasherParams.caption.error

      caption: flasherCaption
      messages: successMessages

   ###*
   * Функция получения результата запроса. Считывает ошибки и устанавливает их в
   *  состояние ошибок валидации.
   *
   * @return
   ###
   _getResponse: ->
      response = @props.fluxParams.getResponse()
      errors = {}

      if response.errors?
         errors = response.errors
      else
         @_emitSuccess(response.json)

      @setState
         validationResult: errors
         requestStatus: @_REQUEST_STATUSES.responded

   ###*
   * Обработчик на изменение состояния хранилища.
   *
   * @return
   ###
   _onChange: ->
      fluxParams = @props.fluxParams
      storeLastInteraction = fluxParams.store.getLastInteraction()

      if storeLastInteraction is fluxParams.responseType
         @_getResponse()

   ###*
   * Обработчик сброса полей формы.
   *
   * @param {Event-obj} event - объект события.
   ###
   _onReset: (event) ->
      event.preventDefault()

      @setState
         validationResult: {}
         isRefreshed: true
         requestStatus: @_REQUEST_STATUSES.ready

   ###*
   * Обработчик отправки данных формы.
   *
   * @param {Event-obj} event - объект события.
   ###
   _onSubmit: (event) ->
      event.preventDefault()

      @_validateFieldsAndSubmit()

      @_resetRefreshed()

   ###*
   * Обработчик успешного результата запроса формы.
   *  Запускает обработчик на успешное обнолвение формы.
   *
   * @param {Object} response - возвращенный ответ.
   * @return
   ###
   _emitSuccess: (response) ->
      onSuccessHandler = @props.onSuccess
      successInscription = @props.successInscription || @_SUCCESS_INSCRIPTION_DEFAULT

      if onSuccessHandler?
         onSuccessHandler(response, successInscription, @props.recordID)

   ###*
   * Функция проверки полей формы на корректность. Параллельно асинхронно выполняет
   *  функции валидации.
   *
   * @return
   ###
   _validateFieldsAndSubmit: ->
      staticForm = this
      formFieldsRefs = @refs.fields.refs

      # Tсли объект с валидацями не пустой - продолжим.
      if !$.isEmptyObject(formFieldsRefs)
         validationFunctions = {}

         for fieldName, staticFormField of formFieldsRefs
            validationFunctions[fieldName] = staticFormField.refs.field.validate

         # Асинхронно выполним все функции валидации, и в
         # колбэке получим результат выполнения валидаций.
         async.parallel validationFunctions, (errors, result) ->
            isHasErrors = false

            # переберем все результаты валидации
            for key of result
               resultValidation = result[key]

               if result.hasOwnProperty key

                  # если есть какой-то результат - это ошибка
                  if resultValidation
                     isHasErrors = true
                     break

            # если есть ошибки - сохраняем их в состоянии компонента
            # иначе - запускаем отправку данных формы
            if isHasErrors
               staticForm._saveValidationResult(result, formFieldsRefs)
            else
               staticForm._submitFormData()

   ###*
   * Функция проверки на наличие ошибок валидации. Если хэши текущего результата
   *  валидации и результатов, полученных из последней проверки.
   *
   * @param {Object} validationResult - хэш с результатами валидации.
   * @param {Object} formFields       - хэш парметров полей формы с валидациями.
   * @return
   ###
   _saveValidationResult: (validationResult, formFields) ->
      chars = @_CHARS
      flasherOutput = {}

      for resName, res of validationResult
         if res?
            fieldParams = formFields[resName].props.field
            fieldCaption = fieldParams.caption
            fieldReflection = fieldParams.reflection
            fieldReflectionName = fieldReflection.name if fieldReflection?

            validationCaption =
               if fieldReflectionName?
                  [
                     fieldCaption
                     chars.colon
                     fieldReflectionName
                  ].join chars.colon
               else
                  fieldCaption

            flasherOutput[validationCaption] = res

      # Проверим на идентичность хэша результата валидации в состоянии компонента
      #  и аргумента, переданного в функцию.
      # Если хэши не равны - установим новое значение результата валидации в состояние
      #  а также флаг того, что форма готова к отправке.
      if JSON.stringify(@state.validationResult) isnt JSON.stringify(flasherOutput)
         @setState
            validationResult: flasherOutput
            requestStatus: @_REQUEST_STATUSES.ready

   ###*
   * Функция отправки данных формы.
   *
   * @return
   ###
   _submitFormData: ->
      # Получаем данные формы.
      formData = serialize(ReactDOM.findDOMNode(this))

      dataForRequest =
         data: formData
         #relations: @props.modelRelations

      # Отправляем запрос формы.
      @props.fluxParams.sendRequest(dataForRequest, @props.recordID)

      # Меняем состояние на - запрошено, сбрасываем результаты валидации.
      @setState
         requestStatus: @_REQUEST_STATUSES.requested
         validationResult: {}

   ###*
   * Функция сброса флага обновленности.
   *
   * @return
   ###
   _resetRefreshed: ->
      @setState
         isRefreshed: false

###* Компонент: набор полей статической формы. Часть компонента StaticForm.
*
* @props:
*     {Array} fields      - хэш с полями формы.
*     {Object} modelParams   - параметры модели по которому создаётся поле. Вид:
*                     {String} name - имя экземпляра модели, по которому заполняется поле.
*                     {String} caption - заголовок поля, по которму заполняется поле.
*                              (для корректного формирования значений формы).
*     {String} isReset    - флаг того что поля формы сбрасываются(очищаются).
*     {Function} onChange - обработчик запускаемый при изменении значения в поле ввода.
* @state
*
###
StaticFormFields = React.createClass

   # @const {String} - префикс ссылки на поле.
   _FIELD_REF_PREF: 'field'

   # @const {Object} - симолы.
   _CHARS:
      empty: ''
      sqBrStart: '['
      sqBrEnd: ']'

   styles:
      common:
         padding: _COMMON_PADDING
         width: '100%'

   render: ->
      formFields = []

      # переберем все поля
      for field, index in @props.fields

         formFields.push `(
                              <StaticFormField key={index}
                                               field={field}
                                               modelParams={this.props.modelParams}
                                               tabIndex={index + 1}
                                               isReset={this.props.isReset}
                                               ref={this._getFieldRef(field.name)}
                                               onChange={this.props.onChange} />
                          )`

      `(
         <table style={this.styles.common}>
            <tbody>
               {formFields}
            </tbody>
         </table>
      )`

   ###*
   * Функция генерации ссылки на поле.
   *
   * @param {String} name - имя поля
   ###
   _getFieldRef: (name) ->
      chars = @_CHARS

      [
         @_FIELD_REF_PREF
         chars.sqBrStart
         name
         chars.sqBrEnd
      ].join chars.empty

###* Компонент: поле статической формы. Часть компонента StaticForm.
*  в зависимости от типа поля создает различные поля.
*
* @props:
*     {Object} field      - хэш с параметрами поля
*     {Object} modelParams   - параметры модели по которому создаётся поле. Вид:
*                     {String} name - имя экземпляра модели, по которому заполняется поле.
*                     {String} caption - заголовок поля, по которму заполняется поле.
*                              (для корректного формирования значений формы).
*     {String} isReset    - флаг того что поле формы сбрасывается(очищается)
*     {Function} onChange - обработчик запускаемый при изменении значения в поле ввода
* @state
*
###
StaticFormField = React.createClass
   _PLACEHOLDER: 'введите значение'

   mixins: [HelpersMixin]

   styles:
      hiddenRow:
         display: 'none'
      cell:
         padding: _COMMON_PADDING - 2
         fontSize: 13
         color: _COLORS.hierarchy2
         fontStyle: 'italic'
      captionCell:
         textAlign: 'right'
      fieldCell:
         textAlign: 'left'
         minWidth: 250

   render: ->
      field = @props.field

      formField = `( <FormInput ref="field"
                                field={field}
                                title={field.caption}
                                modelParams={this.props.modelParams}
                                tabIndex={this.props.tabIndex}
                                isReset={this.props.isReset}
                                placeholder={this._PLACEHOLDER}
                                onChange={this.props.onChange} /> )`

      computedCaptionStyle = @computeStyles @styles.cell,
                                            @styles.captionCell
      computedFieldStyle = @computeStyles @styles.cell,
                                          @styles.fieldCell

      rowStyle = if field.isHidden
                    @styles.hiddenRow

      `(
         <tr style={rowStyle}>
            <td style={computedCaptionStyle}>
               {field.caption}
            </td>
            <td style={computedFieldStyle}>
               {formField}
            </td>
         </tr>
      )`

module.exports = StaticForm


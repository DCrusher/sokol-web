###* @jsx React.DOM ###

###* Зависимости: модули.
* SessionActionCreators - flux-создатель пользовательских действий для аутентификации.
* SessionStore          - хранилище-контроллер для аутентификации.
* StylesMixin           - общие стили для компонентов
* AssetsMixin           - модуль общих функций работы с ресурсами, привязанных к среде исполнения.
* keymirror             - модуль для генерации "зеркального" хэша.
* lodash                - модуль служебных операций.
###
SessionActionCreators = require("../../actions/session_action_creators")
SessionStore = require("../../stores/session_store")
StylesMixin = require('../mixins/styles')
AssetsMixin = require('../mixins/assets')
fluxConstants = require('constants/flux_constants')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* Input - поле ввода.
###
#Input = require('../core/input')

###* Зависимости: компоненты
* AjaxLoader - компонент ajax-загрузчика
* Flasher    - компонент списка сообщений (для отображения ошибок)
###
AjaxLoader = require("../core/ajax_loader")
Flasher = require("../core/flasher")

###* Константы
* _COLORS               - цвета
* _COMMON_PADDING       - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding

###* Компонент формы аутентификации.
* Имеет поля логина/пароля и кнопку отправки запроса.
* Отправляет запрос на сервер для проверки корректности введенных данных.
* При неудачном входе выдает сообщение, отправленное ему сервером
* При удачном входе перенаправляет на главную страницу
* @props :
*   {String} caption - заголовок формы
* @state :
*   {Object} formState    - строка-идентификатор состояний компонента:
*                            'init'         - начальная инициализация
*                            'requesting'   - запрос данных
*                            'dataReceived' - данные получены
*                            'dataRendered' - данные отрисованы
*   {Array} errors         -  ошибки.
*   {String} passwordInput - значение введеное в поле ввода
###
SigninForm = React.createClass
   # @const {Object} - хэш возможных сосояний компонента
   _FORM_STATES: keyMirror(
      init: null
      requesting: null
      dataReceived: null
      dataRendered: null
   )

   # @const {String} - наименование типа сообщения-ошибка для компонента вывода сообщений.
   _ERROR_MESSAGE_TYPE: 'error'

   mixins: [AssetsMixin]

   styles:
      common:
         position: 'fixed'
         height: '100%'
         width: '100%'
      form:
         padding: 5
         display: 'inline-block'
         textAlign: 'left'
         color: _COLORS.hierarchy3
         marginTop: 45
         fontSize: 15
         # maxWidth: 335
         # margin: '0 auto'
      signinFormCell:
         #verticalAlign: 'top'
         textAlign: 'right'
         width: '50%'
      table:
         height: '100%'
         lineHeight: '2em'
      tableCell:
         height: '100%'
      formInput:
         padding: 6,
         maxWidth: '13em'
         borderStyle: 'solid'
         borderWidth: 1
         borderColor: _COLORS.hierarchy3
         borderRadius: 3
      formSubmit:
         height: '100%'
         padding: 0
         minWidth: 50
         borderRadius: 3
         borderStyle: 'solid'
         borderColor: _COLORS.hierarchy3
         borderWidth: 1
         cursor: 'pointer'
      caption:
         fontSize: 16
         fontWeight: 'normal'
         margin: _COMMON_PADDING

   PropTypes:
      caption: React.PropTypes.string

   getInitialState: ->
      # флаг того что идет запрос
      formState: @_FORM_STATES.init
      errors: []
      passwordInput: ''

   componentDidMount: ->
      SessionStore.addChangeListener(@_onChange)

   componentWillUnmount: ->
      SessionStore.removeChangeListener(@_onChange)

   render: ->
      isRequesting = @state.formState is @_FORM_STATES.requesting

      `(

         <table style={this.styles.common}>
           <tbody>
             <tr>
               <td style={this.styles.signinFormCell}>
                  <form id="signinForm"
                        style={this.styles.form}
                        onSubmit={this._onSubmit}>

                     <h4 style={this.styles.caption}>{this.props.caption}</h4>

                     {this._getFlasher()}
                     <table style={this.styles.table}>
                        <tbody>
                           <tr>
                             <td style={this.styles.tableCell}>

                                <input name="login" ref="login"
                                       placeholder="имя пользователя"
                                       style={this.styles.formInput}/><br />
                                <input name="password" ref="password"
                                       placeholder="пароль" type="password"
                                       value={this.state.passwordInput}
                                       onChange={this._handlerPasswordInputChange}
                                       style={this.styles.formInput}/>
                              </td>
                              <td style={this.styles.tableCell}>
                                <input type='submit'
                                       value='Войти'
                                       ref='signinButton'
                                       disabled={isRequesting}
                                       style={this.styles.formSubmit} />
                                <AjaxLoader isShown={isRequesting}
                                            target={this.state.activityTarget}
                                            view='spinner' />
                              </td>
                           </tr>
                        </tbody>
                     </table>

                   </form>
               </td>
               <td>
                  <img src={this._getAssetPath(this.props.logo)}/>
               </td>
             </tr>
           </tbody>
         </table>
      )`

      #'assets/sokol_logo.svg'

   componentDidUpdate: (prevProps, prevState) ->
      formState = @state.formState

      if formState is @_FORM_STATES.dataReceived

         @setState
            activityTarget: @refs.signinButton
            formState: @_FORM_STATES.dataRendered

   ###*
   * Функция получения объекта вывода сообщений при наличии ошибок.
   *
   * @return {React-DOM-Node} - список ошибок.
   ###
   _getFlasher: ->
      errors = @state.errors

      if errors? and !_.isEmpty errors
         `(<Flasher customMessages={errors} />)`

   ###*
   * Обработчик события из session_store, срабатывающий при получении
   *   ответа с сервера.
   *
   * @return
   ###
   _onChange: ->
      errors = @_prepareErrorsForFlasher(SessionStore.getErrors())

      @setState
         errors: errors
         formState: @_FORM_STATES.dataReceived
         passwordInput: ''

      if _.isEmpty errors
         window.location.href = fluxConstants.APIEndpoints.ROOT #location.protocol + "//" + location.host
   ###*
   * Обработчик на событие отправки запроса с формы.
   *   Устаналивает событие начала запроса (ошибки сброшены,
   *   показан ajax-загрузчик), передает логин и пароль в
   *   в метод login создателя действий session_action_creator.
   *
   * @param {event-object} event - DOM-событие
   * @return
   ###
   _onSubmit: (event) ->
      event.preventDefault()
      @setState
         errors: []
         formState: @_FORM_STATES.requesting
         activityTarget: @refs.signinButton

      login = ReactDOM.findDOMNode(@refs.login).value
      password = ReactDOM.findDOMNode(@refs.password).value
      # вызываем метод аутенификации
      SessionActionCreators.signin(login, password)

   ###*
   * Функция подготовки массива ошибок для корректной работы компонента
   *  Flasher.
   *
   * @param {Array<String>} errors - набор ошибок.
   * @return {Array<Object>} - набор сообщений ошибок.
   ###
   _prepareErrorsForFlasher: (errors) ->
      if errors? and !_.isEmpty(errors)
         errorMessageType = @_ERROR_MESSAGE_TYPE

         errors.map (error) ->
            text: error
            type: errorMessageType


   ###*
   * Обработчик ввода значение в поле пароля.
   *   Устанавливает состояние passwordInput,
   *   для того чтобы оно всегда оставалось актуальным.
   *
   * @param {event-object} event - параметры DOM-событий.
   ###
   _handlerPasswordInputChange: (event) ->
      @setState
         passwordInput: event.target.value

module.exports = SigninForm
window.SigninForm = SigninForm
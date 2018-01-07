###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов
* HelpersMixin     - функции-хэлперы для компонентов
* keymirror        - модуль для генерации "зеркального" хэша.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
keyMirror = require('keymirror')

###* Зависимости: компоненты
* Dialog - диалоговое окно.
* Button - кнопка.
* Input  - поле ввода.
###
Dialog = require('./dialog')
Button = require('./button')
Input = require('./input')

###* Константы
* _COLOR          - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding

###* Компонент: Диалоговое взаимодействия. Служит для вывода важных уведомлений,
*               введения подтверждений от пользователя и т.д.
* @props:
*     {String} text               - текст диалога.
*     {String} caption            - заголовок диалога.
*     {String} type               - строка-идентификатор типа диалога взаимодействия. Варианты:
*                                  'info'    - информационное сообщение.
*                                  'error'   - сообщение об ошибке.
*                                  'confirm' - запрос подтверждения.
*                                  'put'     - запрос ввода.
*     {Object, String,... } value - значение, возвращаемое в функцию обратного вызова
*                                   при подтверждении.
*     {Function} callback         - обработчик, запускаемый при подтверждении.
*     {Function} onHide           - обработчик на cкрытие диалога взаимодействия.
* @state
*     {Boolean} isShown    - флаг показа диалога.
###
DialogInteraction = React.createClass
   # @const - возможные типы диалогов взаимодействия.
   _DI_TYPES: keyMirror (
      info: null
      error: null
      confirm: null
      put: null
   )

   # @const - возможные иконки диалога
   _DI_ICONS:
      info: 'info-circle'
      confirm: 'question-circle'
      error: 'exclamation-triangle'
      put: 'keyboard-o'

   # @const - выводимые заголовки по-умолчанию.
   _DI_CAPTIONS_DEFAULTS:
      info: 'Сообщение'
      error: 'Ошибка'
      confirm: 'Подтверждение'
      put: 'Ввод'

   # @const - возможные заголовки на кнопках
   _BUTTON_CAPTIONS:
      ok: 'OK'
      yes: 'Да'
      no: 'Нет'
      ready: 'Готово'
      cancel: 'Отмена'
   # @const - подсказка на поле ввода при типе диалога - put.
   _PUT_TITLE: 'Введите значение'

   mixins: [HelpersMixin]

   styles:
      common:
         padding: _COMMON_PADDING
         minWidth: 300
         color: _COLORS.hierarchy2
      textWrapper:
         padding: _COMMON_PADDING * 2
         fontSize: 16
         borderBottomColor: _COLORS.hierarchy4
         borderBottomStyle: 'solid'
         borderBottomWidth: 1
      iconCell:
         fontSize: 50
      buttonsWrapper:
         padding: _COMMON_PADDING
         textAlign: 'right'
      buttonCommon:
         width: 70
      buttonHidden:
         display: 'none'
      buttonWithMargin:
         marginRight: _COMMON_PADDING
      errorHeader:
         backgroundColor: _COLORS.alert
      infoHeader:
         backgroundColor: _COLORS.info
      confirmHeader:
         backgroundColor: _COLORS.exclamation

   propTypes:
      text: React.PropTypes.string
      caption: React.PropTypes.string
      type: React.PropTypes.oneOf([
         'info'
         'error'
         'confirm'
         'put'
      ])
      callback: React.PropTypes.func
      onHide: React.PropTypes.func

   getInitialState: ->
      isShown: !!@props.text || !!@props.caption
      putValue: ''

   componentWillReceiveProps: (nextProps) ->
      nextText = nextProps.text
      nextCaption = nextProps.caption
      currentText = @props.text

      #if nextText isnt currentText
      @setState isShown: !!nextText || !!nextCaption


   render: ->
      dialogParams = @_getDialogParams()

      `(
         <Dialog isShown={this.state.isShown}
                 isModal={true}
                 isMovable={false}
                 content={dialogParams.content}
                 caption={this._getDialogCaption()}
                 onHide={this.props.onHide}
                 styleAdditionHeader={dialogParams.styleAdditionHeader} />
       )`

   ###*
   * Обработчик клика по главной кнопке, которая в зависимости от типа диалога
   *  вызывает обработчик обратного вызова (confirm, put) и закрывает диалог.
   *
   * @return
   ###
   _onClickBasic: ->
      types = @_DI_TYPES
      type = @props.type
      isConfirm = type is types.confirm
      isPut = type is types.put

      if isConfirm or isPut
         value = if isConfirm then @props.value else @state.putValue
         @props.callback value

      @_hideDialog()

   ###*
   * Обработчик клика по второстепенной кнопке предназначенной для скрытия диалога.
   *
   * @return
   ###
   _onClickSecondary: ->
      @_hideDialog()

   ###*
   * Обработчик на изменение значения в поле ввода при диалоге "put".
   *
   * @param {String} value - значение в поле.
   * @return
   ###
   _onChangePutInput: (value) ->
      @setState putValue: value

   ###*
   * Функция скрытия диалога. Вызывает обработчик обратного вызова, если задан.
   *
   * @return
   ###
   _hideDialog: ->
      onHideHandler = @props.onHide
      onHideHandler() if onHideHandler

      @setState isShown: false

   ###*
   * Функция получения заголовка диалога в зависимости от типа и заданного в
   *  параметрах заголовка.
   *
   * @return {String} - заголовок.
   ###
   _getDialogCaption: ->
      @props.caption || @_DI_CAPTIONS_DEFAULTS[@props.type]

   ###*
   * Функция получения параметров диалогового окна. В зависимости от типа генерирует
   *  различное содержание.
   *
   * @return {Object<React-DOM-Node, Object>} - параметры диалога. Вид:
   *        {React-DOM-Node} content                - содержимое.
   *        {Object, null} styleAdditionHeader - доп. стиль для заголовка.
   ###
   _getDialogParams: ->
      types = @_DI_TYPES
      dialogType = @props.type
      styleAdditionHeader = null
      styleName = "#{dialogType}Header"
      buttonCaptions = @_BUTTON_CAPTIONS
      captions =
         basic: buttonCaptions.ok
      dialogIcon = @_DI_ICONS[dialogType]
      dialogContent = @props.text

      switch dialogType
         when types.confirm
            captions =
              basic: buttonCaptions.yes
              secondary: buttonCaptions.no
         when types.put
            captions =
               basic: buttonCaptions.ready
               secondary: buttonCaptions.cancel
            dialogContent =
               `(
                  <Input title={this._PUT_TITLE}
                         onChange={this._onChangePutInput} />
               )`


      isHasSecondaryButton = captions.secondary?

      computedStyleBasicButton =
         @computeStyles @styles.buttonCommon,
                        isHasSecondaryButton and @styles.buttonWithMargin

      computedStyleSecondaryButton =
         @computeStyles @styles.buttonCommon,
                        !isHasSecondaryButton and @styles.buttonHidden

      content =
         `(
            <table style={this.styles.common}>
               <tbody>
                  <tr>
                     <td rowSpan={2}
                         style={this.styles.iconCell}  >
                        <i className={"fa fa-"+dialogIcon} />
                     </td>
                     <td style={this.styles.textWrapper}>
                        {dialogContent}
                     </td>
                  </tr>
                  <tr>
                     <td style={this.styles.buttonsWrapper}>
                        <Button caption={captions.basic}
                                styleAddition={computedStyleBasicButton}
                                onClick={this._onClickBasic} />
                        <Button caption={captions.secondary}
                                styleAddition={computedStyleSecondaryButton}
                                onClick={this._onClickSecondary} />
                     </td>
                  </tr>
               </tbody>
            </table>
          )`

      content: content
      styleAdditionHeader: @styles[styleName]

module.exports  = DialogInteraction
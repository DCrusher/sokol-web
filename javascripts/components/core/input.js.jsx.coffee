###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* HelpersMixin     - функции-хэлперы для компонентов.
* AnimationsMixin  - набор анимаций для компонентов.
* AnimateMixin     - библиотека добавляющая компонентам
                     возможность исользования анимации.
* keymirror        - модуль для генерации "зеркального" хэша.
* lodash           - модуль служебных операций.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
AnimationsMixin = require('../mixins/animations')
AnimateMixin = require('react-animate')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* Button       - кнопка
* PopupBaloon - компонент всплывашки
* Label        - лейбл
###
Button = require('components/core/button')
PopupBaloon = require('components/core/popup_baloon')
Label = require('components/core/label')

###* Константы
* _COLORS               - цвета
* _COMMON_PADDING       - значение отступа
* _COMMON_BORDER_RADIUS - значение скругления углов, alias - _CBR
* _ICON_CONTAINER_WIDTH - общая ширина ячеек с иконками
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius
_CBR = [_COMMON_BORDER_RADIUS, 'px'].join('')
_ICON_CONTAINER_WIDTH = constants.iconContainerWidth

###* Компонент: Поле ввода
*
* @props:
*     {String} placeholder        - строка-заполнитель для приглашения ввода.
*     {String} name               - имя поля ввода
*     {String} title              - подсказка на поле ввода
*     {String} caption            - заголовок для поля ввода. Если задан пустой, заголовок не формируется. Если
*                                   параметр задан формируется кликабельный компонент лейбла.
*     {String} captionPosition    - позиция размещения заголовка. Возможные значения:
*                                   'left'   - слева,  (по-умолчанию)
*                                   'right'  - справа,
*                                   'top'    - сверху,
*                                   'bottom' - снизу.
*     {String} value              - значение в поле ввода
*     {String} type               - тип поля ввода.  Возможны варианты полей ввода
*                                   html, для ввода текстовой информации:
*                                   "text", "number","date", "datetime", "boolean"
*     {String} idPrefix           - префикс для идентификатора поля ввода. Параметр предназначен для создания уникального
*                                   идентификатора элемента на основе имени и данного параметра для случая множественного
*                                   полей с одинаковым именем.
*     {Number} caretPosition      - позиция каретки в поле ввода.
*     {Number} tabIndex           - индекс таба для задания последовательности перехода
*                                   по клавише "Tab"
*     {Number} maxWidth           - максимальная ширина поля ввода.
*     {Number} minWidth           - минимальная ширина поля ввода.
*     {Number} inputHeight        - высота контейнера для поля ввода. Параметр нужен,
*                                   чтобы задать произвольную высоту для поля ввода.
*     {Object} decimalDimension   - размерность поля ввода дробных чисел. Если данный параметр
*                                   не задан(в частности scale - пустой) задает любой шаг приращения.
*                                   Вид:
*                                   {Number} precision - общая длинна поля (пока не используется).
*                                   {Number} scale     - кол-во знаков после запятой. Параметр
*                                                        используется для задания шага приращения поля.
*     {Object} style              - стили для поля (перезапись стилей по-умолчанию)
*     {Object} styleAddition      - дополнительные стили (если нужен стиль по
*                                   умолчанию + что-то ещё). Вид:
*                       {Object} caption   - доп. стили для лейбла.
*                       {Object} container - доп. стили для контейнера.
*                       {Object} input     - доп. стили для поля ввода.
*                       {Object} textArea  - доп. стили для области ввода текста(если в компоненте
*                                            задан флаг isTextArea)
*     {Object} leadIcon           - хэш с параметрами иконки вначале строки:
*                                   {String} name - имя иконки (из FontsAwesome)
*                                               имя иконки в начале строки ввода
*                                   {String} type - тип иконки в начае строки ввода.
*                                            Возможные типы:
*                                              "static"  - просто иконка
*                                              "info"    - иконка информации(синяя)
*                                              "error"   - иконка ошибки(красная)
*                                              "success" - иконка успеха(зеленая)
*                                   {String} title - надпись, выводимая при наведении на иконку
*     {Object} popupParams        - хэш с параметрами всплывашки:
*                                   {String} popupContent - содержимое всплывашки.
*                                   {String} typeEvent - тип события показа всплывашки
*                                            Возможные типы событий:
*                                              "focusIn" - фокусировка
*                                              "focusOut" - расфокусировка
*                                              "onInput" - изменение значения поля ввода
*                                              "onInputEnd" - по истечении времени после изменения
*                                                              значения поля ввода.
*                                   {String} verticalPosition - вертикальная позиция всплывашки.
*                                   {String} horizontalPosition - горизонтальная позиция всплывашки.
*                                   {Number} closeTimout - время в мс, через которое всплывашка
*                                            исчезнет.
*                                   {Number} opacity - прозрачность всплывашки.
*     {String} loaderIconTitle    - подсказка, выводимая при наведении на иконку ajax-запроса
*     {Boolean} isSearch          - флаг того, что это поле поиска (добавляется лидирующая иконка поиска).
*
*     {Boolean} isTextArea        - флаг того, что это поле ввода многострочного текста.
*                                   По-умолчанию = false.
*     {Boolean} isAjaxRequest     - флаг выполнения Ajax-запроса. (по-умолчанию = false)
*     {Boolean} isEmbedded        - флаг встраиваемого поля (без иконок, кнопок, анимации, рамок).
*                                   (по-умолчанию = false)
*     {Boolean} isNeedClearButton - флаг того что нужна кнопка очистки. (по-умолчанию = true)
*     {Boolean} isStretchable     - флаг растягиваемого по контенту поля ввода
*                                   (по-умолчанию = false)
*     {Boolean} isReadOnly        - флаг поля только для чтения (редактирование не доступно).
*                                   (по-умолчанию = false).
*    {Boolean} enableCaretControl - флаг разрешения управления позицией каретки через
*                                   параметр @props.caretPosition. (по-умолчанию = false).
*     {Function} onClick          - обработчик на клик по компоненту. Аргументы:
*                                   {Object} event - объект события.
*     {Function} onChange         - обработчик на ввод значения в поле.
*     {Function} onFocus          - обработчик на приход фокуса в компонента.
*     {Function} onBlur           - обработчик на потерю фокуса компонента.
*     {Function} onKeyDown        - обработчик на нажатие клавиши на клавиатуре.
*     {Function} onClear          - обработчик на очистку поля.
*     {Function} onEmitValue      - обработчик на событие "отдачи" значения. Данное
*                                   вызывается по нажатию клавиши Enter, а также
*                                   по клику на лидирующую иконку поиска в поле поиска
*                                   при isSearch = true. Аргументы:
*                                   {String, Number} value - значение в поле ввода.
* @state
*     {Number} caretPosition      - позиция каретки в поле ввода.
*     {String} inputValue            - значение в поле ввода.
*     {Number} stretchableInputWidth - ширина растягиваемого поля ввода.
*     {Boolean} isInFocus            - флаг, того что компонент в фокусе.
*     {Boolean} isFlag               - флаг поля-флага.
*     {React-Element, false} target  - целевой компонент для всплывашки.
*
###
Input = React.createClass
   # @const {Number} - минимально возможная ширина.
   _MIN_INPUT_WIDTH: 25

   # @const {String} - подсказка на кнопке очистке поля.
   _CLEAR_BUTTON_TITLE: 'Очистить'

   # @const {String} - маркер поля только для чтения.
   _READONLY_MARKER: 'readOnly'

   # @const {String} - маркер отметки поля-чекбокса.
   _CHECKED_MARKER: 'checked'

   # @const {String} - имя класса для иконки загрузки.
   _LOADER_ICON_NAME: 'fa fa-spinner fa-pulse'

   # @const {Object} - ключи для доступа к параметрам числового поля.
   _NUMBER_PARAMS_KEYS: keyMirror(
      step: null
   )

   # @const {Object} - возможные типы полей ввода формы.
   _INPUT_TYPES: keyMirror(
      text: null
      file: null
      number: null
      boolean: null
      date: null
      datetime: null
   )

   # @const {Object} - возможные типы событий, на которые реагирует всплывашка.
   _POPUP_TYPE_EVENTS: keyMirror(
      focusIn: null
      focusOut: null
      onInput: null
      onInputEnd: null
   )

   # @const {Object} - используемые символы.
   _CHARS:
      empty: ''
      space: ' '
      point: '.'
      underscore: '_'
      zone: 'Z',
      zero: '0',
      one: '1'

   # @const {Object} - возможные позиции заголовка.
   _CAPTION_POSITIONS: keyMirror(
      left: null
      right: null
      top: null
      bottom: null
   )

   # @const {Object} - параметры лидирующей иконки в поле поиска.
   _SEARCH_LEAD_ICON_PARAMS:
      name: 'search'
      title: 'Поиск'

   # @const {Number} - код клавиши Enter
   _ENTER_KEY_CODE: 13

   # @const {String} - шаг "по-умолчанию" для поля ввода дробных чисел
   _DEFAULT_DECIMAL_STEP: 'any'

   # @const {String} - строка-заменитель для поля заполнения даты и времени.
   _DATETIME_INPUT_TYPE_SUBSTITUTE: 'datetime-local'

   # @const {Number} - Прозрачность всплывашки по умолчанию.
   _POPUP_OPACITY: 0.9

   # @const {Number} - Время, через которое всплывашка покажется, после того, как ей будет скинут
   #  целевой элемент.
   _POPUP_DELAY_SHOW_TIMEOUT: 0

   # @const {Number} - Прозрачность всплывашки по умолчанию.
   _POPUP_DELAY_FOR_ON_INPUT_END_EVENT: 1000

   # @const {String} - наименование типа поля ввода - флаг.
   _CHECKBOX_INPUT_TYPE: 'checkbox'

   # @const {String} - наименование ссылки на поле.
   _INPUT_REF: 'input'

   # @const {String} - строковое отрицательное значение флага.
   _FALSE_STR_VALUE: 'false'

   # @const {String} - кол-во строк для поля ввода текста по-умолчанию.
   _TEXT_AREA_DEFAULT_ROWS_COUNT: 3

   mixins: [HelpersMixin, AnimateMixin, AnimationsMixin.glowBorder]

   styles:
      common:
         color: _COLORS.hierarchy3
         textAlign: 'center'
         padding: 0
         glowColor: _COLORS.light
         boxShadow: 'none'
         backgroundColor: _COLORS.light
         width: '100%'
         boxSizing: 'border-box'
      textArea:
         glowColor: _COLORS.light
         borderColor: _COLORS.hierarchy3
         borderRadius: _COMMON_BORDER_RADIUS
         padding: _COMMON_PADDING
         fontSize: 13
         width: '95%'
      readOnlyInput:
         color: _COLORS.hierarchy3
      embeddedInputContainer:
         display: 'inline-block'
         borderWidth: 0
      complexContainer:
         width: '100%'
      stretchableContainer:
         width: ''
      glowBorder:
         boxShadow: ['0 0 ', _COMMON_PADDING, 'px '].join('')
         glowColor: _COLORS.main
      stretchSizePicker:
         fontSize: 13
         display: 'none'
      input:
         width: '100%'
         borderWidth: 0
         color: _COLORS.hierarchy2
         fontSize: 13
      checkboxInput:
         width: ''
      leadIconCell:
         textAlign: 'center'
         width: 17
         paddingLeft: _COMMON_PADDING
      inputCell:
         padding: _COMMON_PADDING - 1
      clearCell:
         width: 1
      # leadIconCellHide:
      #    display: 'none'
      # leadIconCommon:
      #    cursor: 'pointer'
      #    height: 16
      #    display: 'block'
      #    fontSize: 16
      # leadIconStatic:
      #    color: _COLORS.hierarchy3
      # leadIconInfo:
      #    color: _COLORS.info
      # leadIconSuccess:
      #    color: _COLORS.success
      # leadIconError:
      #    color: _COLORS.alert
      clearButton:
         marginTop: 1
      clearIconCell:
         textAlign: 'center'
         padding: 0
      loaderIcon:
         padding: 2
         display: 'none'
      loaderIconShown:
         display: 'inline-block'
      inlineElementsContainer:
         display: 'inline-flex'
         alignItems: 'center'
      inlineElement:
         display: 'inline-block'

   propTypes:
      placeholder: React.PropTypes.string
      name: React.PropTypes.string
      value:  React.PropTypes.oneOfType([
         React.PropTypes.string,
         React.PropTypes.number,
         React.PropTypes.bool
      ])
      caption: React.PropTypes.string
      idPrefix: React.PropTypes.oneOfType([
         React.PropTypes.string,
         React.PropTypes.number
      ])
      captionPosition: React.PropTypes.oneOf(['left', 'right', 'top', 'bottom'])
      title: React.PropTypes.string
      decimalDimension: React.PropTypes.object
      style: React.PropTypes.object
      styleAddition: React.PropTypes.object
      popupParams: React.PropTypes.object
      type: React.PropTypes.oneOf(['text', 'date', 'datetime', 'password', 'number', 'boolean'])
      caretPosition: React.PropTypes.number
      tabIndex: React.PropTypes.number
      inputHeight: React.PropTypes.number
      maxWidth: React.PropTypes.number
      minWidth: React.PropTypes.number
      leadIcon: React.PropTypes.object
      isAjaxRequest: React.PropTypes.bool
      isTextArea: React.PropTypes.bool
      isNeedClearButton: React.PropTypes.bool
      isStretchable: React.PropTypes.bool
      isEmbedded: React.PropTypes.bool
      isReadOnly: React.PropTypes.bool
      enableCaretControl: React.PropTypes.bool
      loaderIconTitle: React.PropTypes.string
      onInput: React.PropTypes.func
      onFocus: React.PropTypes.func
      onBlur: React.PropTypes.func
      onClear: React.PropTypes.func
      onKeyDown: React.PropTypes.func

   getDefaultProps: ->
      captionPosition: 'left'
      placeholder: 'Введите значение'
      leadIconType: 'static'
      type: 'text'
      loaderIconTitle: 'Выполняется запрос'
      tabIndex: 1
      isAjaxRequest: false
      isTextArea: false
      isNeedClearButton: true
      isStretchable: false
      isEmbedded: false
      isReadOnly: false
      enableCaretControl: false

   getInitialState: ->
      inputValue: @_prepareFieldValue()
      stretchableInputWidth: @_MIN_INPUT_WIDTH
      isInFocus: false
      isFlag: @_isFlagInput()
      popupTarget: undefined

   componentWillReceiveProps: (nextProps) ->
      nextValue = nextProps.value
      currentIsFlag = @state.isFlag
      nextIsFlag = @_isFlagInput(nextProps.type)

      if nextValue isnt undefined and (@refs.input? and (@refs.input.value isnt nextValue))
         @setState inputValue: @_prepareFieldValue(nextProps)
      else if @props.popupParams?
         @_popupAction(nextValue)

      # Если флаг поля-флага меняется - переустановим флаг в состоянии.
      if currentIsFlag isnt nextIsFlag
         @setState isFlag: nextIsFlag

   render: ->
      inputElement = @_getInput()
      caption = @props.caption

      if caption?
         @_getInputWithLabel(inputElement, @props.name, caption)
      else
         inputElement

   componentDidUpdate: (prevProps, prevState) ->
      @_setCaretPosition() if @props.enableCaretControl

      # Если поле растягиваемое и предыдущее значение отличается от текущего -
      #  запустим функцию получения размера поля ввода.
      if @props.isStretchable
         prevInputValue = prevState.inputValue
         currentInputValue = @state.inputValue

         if currentInputValue isnt prevInputValue
            @setState stretchableInputWidth: @_getStretchableInputWidth()

   ###*
   * Функция получения элемента ввода.
   *
   * @return {React-Element} - элемент ввода.
   ###
   _getInput: ->
      if @state.isFlag
         @_getInputContent()
      else if @props.isTextArea
         @_getTextArea()
      else
         `(
            <div style={this._getContainerStyle()}
                 title={this.props.title}
                 onFocus={this._onFocus}
                 onBlur={this._onBlur}
                 onClick={this._onClick}
               >
               {this._getInputContent()}
               {this._getStretchSizePicker()}
            </div>
         )`

   ###*
   * Функция получения элемента ввода с лейблом.
   *
   * @param {React-element} inputElement - элемент ввода.
   * @param {String} inputElementName    - имя элемента ввода.
   * @param {String} caption             - заголовок.
   * @return {React-Element} - элемент ввода.
   ###
   _getInputWithLabel: (inputElement, inputElementName, caption) ->
      captionPositions = @_CAPTION_POSITIONS
      leftPos = captionPositions.left
      rightPos = captionPositions.right
      topPos = captionPositions.top
      bottomPos = captionPositions.bottom
      styleAddition = @props.styleAddition
      captionStyle = styleAddition.caption if styleAddition?
      captionPosition = @props.captionPosition
      isCaptionFirst = _.includes([leftPos, topPos], captionPosition)
      isInlineLayout = _.includes([leftPos, rightPos], captionPosition)

      ###*
      * Функция оборачивания элемента в строчно-блочный контейнер для строчного размещения
      *
      * @param {React-element} element - элемент.
      * @return {React-element}
      ###
      wrapToInlineContainer = ((element) ->
          `(
               <div style={this.styles.inlineElement}>{element}</div>
           )`
      ).bind(this)

      captionElement =
         `(
             <label htmlFor={this._getInputId()}
                    style={captionStyle} >
                {caption}
             </label>
          )`

      if isInlineLayout
         captionElement = wrapToInlineContainer(captionElement)
         inputElement = wrapToInlineContainer(inputElement)

      if isCaptionFirst
         firstElement = captionElement
         secondElement = inputElement
      else
         firstElement = inputElement
         secondElement = captionElement

      containerStyle = @styles.inlineElementsContainer if isInlineLayout

      `(
          <span style={containerStyle}
                title={this.props.title}>
             {firstElement}
             {secondElement}
          </span>
      )`

   ###*
   * Функция формирования области ввода текста, в случае если компонент формируется
   *  в режиме области текста @state.isTextArea.
   *
   * @return {React-Element} - содержимое поля ввода.
   ###
   _getTextArea: ->
      `(
         <textarea ref={this._INPUT_REF}
                   title={this.props.title}
                   style={this._getTextAreaStyle()}
                   name={this.props.name}
                   placeholder={this._getPlaceholder()}
                   rows={this._TEXT_AREA_DEFAULT_ROWS_COUNT}
                   value={this.state.inputValue}
                   onChange={this._onChangeInput}
                   onBlur={this._onBlur}
                   onFocus={this._onFocus}
                   onKeyDown={this._onKeyDown}
               >
         </textarea>
       )`

   ###*
   * Функция получения содержимого поля ввода.
   *
   * @param {String} inputType - тип поля ввода.
   * @return {React-Element} - содержимое поля ввода.
   ###
   _getInputContent: (inputType) ->
      isEmbedded = @props.isEmbedded
      isReadOnly = @props.isReadOnly
      isAjaxRequest = @props.isAjaxRequest
      isFlag = @state.isFlag
      fieldType = @props.type
      readOnly = @_READONLY_MARKER if isReadOnly
      fieldStep = @_getDecimalStep()
      inputValue = @state.inputValue
      chars = @_CHARS

      if isFlag
         fieldType = @_CHECKBOX_INPUT_TYPE
         checked = @_CHECKED_MARKER if @_isChecked()

      if fieldType is @_INPUT_TYPES.datetime
         fieldType = @_DATETIME_INPUT_TYPE_SUBSTITUTE

      inputElement =
         `(
            <input ref={this._INPUT_REF}
                   title={this.props.title}
                   type={fieldType}
                   step={fieldStep}
                   style={this._getInputStyle()}
                   placeholder={this._getPlaceholder()}
                   tabIndex={this.props.tabIndex}
                   name={this.props.name}
                   id={this._getInputId()}
                   value={this.state.inputValue}
                   checked={checked}
                   onChange={this._onChangeInput}
                   onBlur={this._onBlur}
                   onFocus={isEmbedded ? this.props.onFocus : null}
                   onKeyDown={this._onKeyDown}
                   readOnly={readOnly}
                />
         )`

      if isEmbedded
         @_getEmbeddedInput inputElement
      else
         @_getComplexInput inputElement

   ###*
   * Функция получения внедряемого(простого) поля ввода.
   *
   * @param {React-Element} inputElement - DOM-элемент поле ввода.
   * @return {React-Element} - структура сложного поля ввода.
   ###
   _getEmbeddedInput: (inputElement) ->
      `(
         <div>
            {inputElement}
            {this._getLoader()}
         </div>
      )`

   ###*
   * Функция получения структуры сложного поля ввода - с различными кнопками, анимацией.
   *
   * @param {React-Element} inputElement - DOM-элемент поле ввода.
   * @return {React-Element} - структура сложного поля ввода.
   ###
   _getComplexInput: (inputElement) ->
      `(
         <table ref='inputContainer'
                title={this.props.title}
                style={this._getComplexContainerStyle()}
                cellPadding={0}>
            <tbody>
               <tr>
                  {this._getLeadIconCell()}
                  <td style={this._getInputCellStyle()}>
                     {inputElement}
                     {this._getPopupBaloon()}
                  </td>
                  <td style={this.styles.clearCell}>
                     {this._getClearButton()}
                  </td>
                  <td>
                     {this._getLoader()}
                  </td>
               </tr>
            </tbody>
         </table>
      )`

   ###*
   * Функция формирования скомпанованного стиля для контейнера комплексного поля
   *  ввода (заголовок + поле ввода).
   *
   * @return {Object} - стиль.
   ###
   _getComplexContainerStyle: ->
      styleAddition = @props.styleAddition
      containerAdditionStyle = styleAddition.container if styleAddition?

      @computeStyles @styles.complexContainer,
                     containerAdditionStyle

   ###*
   * Функция получения иконки загрузчика.
   *
   * @return {React-Element}
   ###
   _getLoader: ->
      `(
         <i style={this._getLoaderStyle()}
            className={this._LOADER_ICON_NAME}
            title={this.props.loaderIconTitle}></i>
      )`

   ###*
   * Функция передачи компонента всплывашки в случае, если он определен
   *
   * @return {React-Element}
   ###
   _getPopupBaloon: ->
      popupParams = @props.popupParams
      if popupParams
         opacity = popupParams.opacity || @_POPUP_OPACITY
         target = @state.popupTarget
         isShow = target?

         `(
            <PopupBaloon popupContent={popupParams.popupContent}
               opacity={opacity}
               isShow={isShow}
               icon={popupParams.icon}
               target={target}
               verticalPosition={popupParams.verticalPosition}
               horizontalPosition={popupParams.horizontalPosition}/>
         )`

   ###*
   * Функция получения кнопки очистки поля
   *
   * @return {React-Element}
   ###
   _getClearButton: ->
      if @props.isNeedClearButton
         isShown = if @state.isFlag
                      @_isChecked()
                   else
                      !!@state.inputValue
         `(
            <Button isClear={true}
                    isShown={isShown}
                    isDisabled={this.props.isReadOnly}
                    title={this._CLEAR_BUTTON_TITLE}
                    styleAddition={this._getClearButtonStyleAddition()}
                    onClick={this._onClickClear} />
          )`

   ###*
   * Функция формирования идентификатора поля ввода на основе имени и заданного префикса.
   *
   * @return {String}
   ###
   _getInputId: ->
      [
         @props.idPrefix
         @props.name
      ].join @_CHARS.underscore

   ###*
   * Функция получения доп. стиля для кнопки очисти поля ввода.
   *
   * @return {Object} - скомпанованный стиль.
   ###
   _getClearButtonStyleAddition: ->
      styleAddition = @props.styleAddition
      buttonStyleAddition = styleAddition.clear if styleAddition?

      @computeStyles @styles.clearButton, buttonStyleAddition

   ###*
   * Функция получения узла для получения размеров при растягивающимся поле ввода
   *
   * @return {React-Element}
   ###
   _getStretchSizePicker: ->
      if @props.isStretchable
         `(
            <span style={this.styles.stretchSizePicker}
                  ref='stretchSizePicker'>
               {this.state.inputValue}
            </span>
          )`

   ###*
   * Функия получения ячейки с иконкой в начале строки.
   *  Проверяет наличние параметров иконки. Если иконка задана - формирует объект,
   *  иначе ничего не формирует
   *
   * @return {React-Element, undefined} - объект иконки
   ###
   _getLeadIconCell: ->
      leadIconProp = @props.leadIcon
      styleAddition = @props.styleAddition

      leadIconParams =
         if @props.isSearch
            _.merge(_.clone(@_SEARCH_LEAD_ICON_PARAMS), (leadIconProp or {}))
         else
            leadIconProp

      if leadIconParams and !_.isEmpty leadIconParams
         isHasEmitValueHandler = @props.onEmitValue?

         `(
            <td style={this.styles.leadIconCell}>
               <Label icon={leadIconParams.name}
                      title={leadIconParams.title}
                      type={leadIconParams.type}
                      isAccented={isHasEmitValueHandler}
                      isWithoutPadding={true}
                      isLink={true}
                      onClick={this._onClickLeadIcon}
                   />
            </td>
          )`

   ###*
   * Функция шага для ввода дробных чисел. Считывает параметр кол-ва дробных знаков
   *  числа, если параметр задан, то формирует шаг, с заданным кол-вом знаков,
   *  если параметр размерности задан, но имеет пустые значения, значит шаг
   *  по-умолчанию любой.
   *
   * @return {String, Number, undefined} - размерность шага.
   ###
   _getDecimalStep: ->
      if @props.type is @_INPUT_TYPES.number
         decimalDimension = @props.decimalDimension
         chars = @_CHARS
         zeroChar = chars.zero
         decimalScale = decimalDimension.scale if decimalDimension?

         if decimalScale?
            [
               zeroChar
               chars.point
               _.repeat(zeroChar, decimalScale - 1)
               chars.one
            ].join chars.empty
         else if decimalDimension?
            @_DEFAULT_DECIMAL_STEP

   ###*
   * Функция получения стиля для таблицы-контейнера элементов поля ввода
   *
   * @return {Object} - скомпанованный стиль
   ###
   _getContainerStyle: ->
      styleProp = @props.style
      styleAddition = @props.styleAddition
      containerAdditionStyle = styleAddition.container if styleAddition?
      isStretchable = @props.isStretchable
      isEmbedded = @props.isEmbedded
      isReadOnly = @props.isReadOnly
      containerStyle = if styleProp then styleProp else @styles.common

      # Cтиль для обертки (внешние границы).
      @computeStyles containerStyle,
                     isStretchable and @styles.stretchableContainer,
                     StylesMixin.mixins.inputBorder,
                     containerAdditionStyle,
                     isEmbedded and @styles.embeddedInputContainer,
                     !isEmbedded and !isReadOnly and @_getGlowStyle()

   ###*
   * Функция получения стиля для контейнера-ячейки поля ввода. Задает дополнительную
   *  высоту, если она задана через параметр @props.inputHeight.
   *
   * @return {Object} - скомпанованный стиль
   ###
   _getInputCellStyle: ->
      inputHeight = @props.inputHeight

      @computeStyles @styles.inputCell,
                     inputHeight? and { height: inputHeight }

   ###*
   * Функция получения стиля для поля ввода. Если задана опция растягивания по вводу
   *  @props.isStretchable - задает ширину поля ввода в зависимости от содержимого.
   *
   * @return {Object} - скомпанованный стиль
   ###
   _getTextAreaStyle: ->
      styleAddition = @props.styleAddition
      areaAdditionStyle = styleAddition.textArea if styleAddition?

      @computeStyles @styles.textArea,
                     areaAdditionStyle,
                     !@props.isEmbedded and !@propsisReadOnly and @_getGlowStyle()

   ###*
   * Функция получения стиля для поля ввода. Если задана опция растягивания по вводу
   *  @props.isStretchable - задает ширину поля ввода в зависимости от содержимого.
   *
   * @return {Object} - скомпанованный стиль
   ###
   _getInputStyle: ->
      isStretchable = @props.isStretchable
      isReadOnly = @props.isReadOnly
      isFlag = @state.isFlag
      inputValue = @state.inputValue
      maxWidth = @props.maxWidth
      minWidth = @props.minWidth
      styleAddition = @props.styleAddition
      inputAdditionStyle = styleAddition.input if styleAddition?

      @computeStyles @styles.input,
                     isFlag and @styles.checkboxInput,
                     inputAdditionStyle,
                     isStretchable and { width: @state.stretchableInputWidth },
                     isReadOnly and @styles.readOnlyInput,
                     maxWidth? and { maxWidth: maxWidth },
                     minWidth? and { minWidth: minWidth }

   ###*
   * Функция получения стиля для анимации подсветки рамки. Получает нужный стиль,
   *  только для компонента, на котором находится фокус (@state.isInFocus)
   *
   * @return {Object. undefined} - стиль для анмации
   ###
   _getGlowStyle: ->
      if @state.isInFocus
         chars = @_CHARS

         boxShadow: [
            @styles.glowBorder.boxShadow
            chars.space
            @getAnimatedStyle('animate-glow-border').glowColor
         ].join chars.empty

   ###*
   * Функция получения скомпанованного стиля иконки вначале строки.
   *
   * @param {Object} leadIconParams - параметры лидирующей иконки.
   * @return {Object} - скомпанованный стиль
   ###
   _getLeadIconStyle: (leadIconParams) ->
      styles = @styles

      specificStyle =
         switch leadIconParams.type
            when 'static' then styles.leadIconStatic
            when 'info' then styles.leadIconInfo
            when 'error' then styles.leadIconError
            when 'success' then styles.leadIconSuccess

      @computeStyles styles.leadIconCommon,
                     specificStyle

   ###*
   * Функция получения стиля ajax-загрузчика
   *
   * @return {Object} - скомпанованный стиль
   ###
   _getLoaderStyle: ->
      # стиль для иконки загрузчика
      @computeStyles @styles.loaderIcon,
         @props.isAjaxRequest and @styles.loaderIconShown

   ###*
   * Функция формирования текста-хранителя для поля ввода.
   *
   * @return {String}
   ###
   _getPlaceholder: ->
      if @props.isReadOnly then @_CHARS.empty else @props.placeholder

   ###*
   * Функция получения ширины растягиваемого поля ввода. Берет скрытый элемент
   *  с тем же текстом, что и в поле ввода, получает его ширину и если она больше
   *  минимальной возвращает её, иначе возвращает минимальную
   *
   * @return {Number, undefined} - ширина растягиваемого поля.
   ###
   _getStretchableInputWidth: ->
      if @props.isStretchable
         minWidth = @_MIN_INPUT_WIDTH

         if @isMounted()
            stretchSizePicker = $(@refs.stretchSizePicker)
            stretchSizePickerWidth = stretchSizePicker.outerWidth() + 3

            if stretchSizePickerWidth > minWidth
               stretchSizePickerWidth
            else
               minWidth
         else
             minWidth

   ###*
   * Функция передачи ссылки в popupTarget. Вызывается setTimeout`ом
   *
   * @return
   ###
   _getPopupBaloonTarget:->
      @setState popupTarget: @refs.inputContainer

   _setCaretPosition: ->
      inputDOM = ReactDOM.findDOMNode(@refs.input)
      inputCaretPosition = inputDOM.selectionEnd
      trueCaretPosition = @props.caretPosition || @state.caretPosition

      if inputCaretPosition isnt trueCaretPosition
         inputDOM.selectionStart = trueCaretPosition
         inputDOM.selectionEnd = trueCaretPosition
      #   newCaretPosition = @props.caretPosition


   ###*
   * Функция-предикат для определения является поле полем-флагом.
   *
   * @param {Boolean}
   ###
   _isFlagInput: (type) ->
      type ||= @props.type

      type is @_INPUT_TYPES.boolean

   ###*
   * Функция-предикат для определения является ли "выбранным"(функция для полей-флагов).
   *
   * @return {Boolean}
   ###
   _isChecked: ->
      inputValue = @state.inputValue
      inputValue and (inputValue isnt @_FALSE_STR_VALUE)

   ###*
   * Обработчик прихода фокуса в компонент. Пробрасывает событие в обработчик,
   *  переданный через параметры, запускает анимацию подсветки рамки.
   *
   * @param {Object} event - объект события
   * @return
   ###
   _onFocus: (event) ->
      onFocusHandler = @props.onFocus
      onFocusHandler event if onFocusHandler
      popupParams = @props.popupParams
      # запустим анимацию
      @_glowIn()

      if popupParams and popupParams.typeEvent is @_POPUP_TYPE_EVENTS.onFocusIn
         popupTarget = @refs.inputContainer

      @setState
         isInFocus: true
         popupTarget: popupTarget

   ###*
   * Обработчик потери фокуса компонентом. Пробрасывает событие в обработчик,
   *  переданный через параметры, запускает сброс анимации подсветки рамки.
   *
   * @param {Object} event - объект события
   * @return
   ###

   _onBlur: (event) ->
      onBlurHandler = @props.onBlur
      onBlurHandler event if onBlurHandler
      popupParams = @props.popupParams
      # запустим выход из анимации
      @_glowOut()

      if popupParams and popupParams.typeEvent is @_POPUP_TYPE_EVENTS.onFocusOut
         popupTarget = @refs.inputContainer

      @setState
         isInFocus: false
         popupTarget: popupTarget

   ###*
   * Обработчик нажатия клавиши клавиатуры в поле ввода.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onKeyDown: (event) ->
      onKeyDownHandler = @props.onKeyDown
      onEmitValueHandler = @props.onEmitValue
      isSearch = @props.isSearch

      onKeyDownHandler(event) if onKeyDownHandler?

      # Если была нажата клавиша Enter, то
      if event.keyCode is @_ENTER_KEY_CODE
         # Останавливаем проброс события для поискового поля или
         #  многострочного поля ввода, т.к. кто-то ниже по стеку вызова
         #  иногда прерывает событие или обрезает значение,
         #  тем самым в поле не ставятся переносы строк.
         if isSearch or @props.isTextArea
            event.stopPropagation()

         # Отменяем поведение по умолчанию, для поискового поля, т.к. он может
         #  располагаться в формах
         event.preventDefault() if isSearch

         if onEmitValueHandler?
            onEmitValueHandler(event.target.value)

   ###*
   * Обработчик клика на лидирующую иконку поля ввода. Для поискового поля
   *  запускает возврат значения, если задан обработчик на возврат значения.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickLeadIcon: (event) ->
      if @props.isSearch
         onEmitValueHandler = @props.onEmitValue

         onEmitValueHandler @state.inputValue if onEmitValueHandler?
   ###*
   * Обработчик клика по компоненту.
   *
   * @param {Object} event - параметры события.
   * @return
   ###
   _onClick: (event) ->

      # Принудительная фокусировка на поле ввода. Данный подход был сделан из-за
      #  возникших ситуаций с размещенными полями ввода на вложенных объектах
      #  (DataTable -> Selector -> ArbitraryArea -> DataTable -> Input) при которых
      #  при клике не происходил фокус в поле ввода.
      #  Это потенциально опасный хак, который предположительно может сломать
      #  порядок фокусировки.
      ReactDOM.findDOMNode(event.target).focus()

      onClickHandler = @props.onClick
      onClickHandler event if onClickHandler?

   ###*
   * Обработчик клика по кнопке очистке поля ввода. Пробрасывает событие в обработчик,
   *  переданный через параметры. Очищает поле, запуском функции _inputValueHandler
   *  с передачей пустого значения.
   *
   * @return
   ###
   _onClickClear: ->
      onClearHandler = @props.onClear
      onClearHandler() if onClearHandler?

      @_inputValueHandler null
      @refs.input.focus()

   ###*
   * Обработчик изменения значения в поле поиска.
   *
   * @return
   ###
   _onChangeInput: (event) ->
      eventTarget = event.target
      inputValue = if @state.isFlag
                      eventTarget.checked
                   else
                      eventTarget.value

      @_inputValueHandler inputValue, event

   ###*
   * Обработчик ввода значения в поле. Устанавливает значение поля ввода в
   *  состояние. Пробрасывает значение в обработчик, переданный через параметры.
   *
   * @param {String} value - значение в поле.
   * @param {Object, undefined} event - объект события.
   * @return
   ###
   _inputValueHandler: (value, event) ->
      onChangeHandler = @props.onChange
      isInitSet = false  # заглушка для компонента FormInput

      # Передадим обработчику значение из поля ввода (если он задан).
      if onChangeHandler
         onChangeHandler value, isInitSet, event

      if @props.popupParams?
         @_popupAction value

      caretPosition =
         if event? and event.target? and @props.enableCaretControl
            event.target.selectionEnd
         else
            0

      @setState
         inputValue: value
         caretPosition: caretPosition

   ###*
   * Функция, срабатывающая для всплывашки по событию изменения значения поля ввода.
   *  onInputEnd - если поле ввода не пустое, задает задержку
   *     показа всплывашки и обнуляет текущую цель и текущую задержку.
   *  onInput - показывает всплывашку только в том случае, если в
   *     поле ввода не пустое.
   *  В остальных случаях - просто обнуляет цель для всплывашки, поскольку на момент, когда в поле
   *     ввода что-то пишется всплывашка на вход в фокус (или выход из него) не должна показываться.
   *
   * @param {String} value - значение поля ввода.
   * @return
   ###
   _popupAction: (value) ->
      popupTypeEvents = @_POPUP_TYPE_EVENTS
      switch @props.popupParams.typeEvent
         when popupTypeEvents.onInputEnd
            clearTimeout @_timeoutForPopup
            timeout = @_POPUP_DELAY_FOR_ON_INPUT_END_EVENT
            if value
               @_timeoutForPopup = setTimeout(@_getPopupBaloonTarget, timeout)
            popupTarget = false
         when popupTypeEvents.onInput
            if value
               popupTarget = @refs.inputContainer
            else
               popupTarget = false
         else
            popupTarget = false

      @setState popupTarget: popupTarget

   ###*
   * Функция подготовки значения в поле. Отдельно обрабатывает тип данных дата/время.
   *  Для типа данных дата/время отбрасывает последний символ зоны
   *  (если он присутствует), иначе поле не поймет заданное ему значение.
   *
   * @param {Object} props - свойства с которыми работаем.
   * @return {String, Number, Boolean}
   ###
   _prepareFieldValue: (props) ->
      props ||= @props
      propsValue = props.value
      isDateTime = (props.type is @_INPUT_TYPES.datetime)

      if isDateTime and propsValue? and (_.last(propsValue) is @_CHARS.zone)
         propsValue.slice(0, -1)
      else
         propsValue

module.exports = Input
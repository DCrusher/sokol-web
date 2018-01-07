###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов
* HelpersMixin     - функции-хэлперы для компонентов
* AnimationsMixin  - набор анимаций для компонентов
* AnimateMixin     - библиотека добавляющая компонентам
*                    возможность исользования анимации
* keymirror        - модуль для генерации "зеркального" хэша.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
AnimationsMixin = require('../mixins/animations')
AnimateMixin = require('react-animate')
keyMirror = require('keymirror')

###* Константы
* _COLORS               - цвета
* _COMMON_PADDING       - значение отступа
* _COMMON_BORDER_RADIUS - значение скругления углов
* _ICON_CONTAINER_WIDTH - константа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius
_ICON_CONTAINER_WIDTH = constants.iconContainerWidth

###* Компонент: Кнопка
*
* @props:
*     {String, Number} caption        - надпись на кнопке
*     {String, Number} value          - значение кнопки (что она возвращает по клику)
*     {String} title                  - подсказка при наведении курсора.
*     {Number} tabIndex               - индекс таба для задания последовательности перехода
*                                       по клавише "Tab"
*     {String} type                   - тип кнопки (может быть submit, reset или обычная)
*     {String} className              - имя класса.
*     {Object} style                  - стили для кнопки (перезапись стилей по умолчанию)
*     {Object} styleAddition          - дополнительные стили (если нужен стиль по
*                                       умолчанию + что-то ещё)
*     {String} iconPosition           - позиция иконки. Варианты:
*                                      'left' - слева (по умолчанию)
*                                      'right' - справа
*     {String} icon                   - название иконки без префикса
*     {Object} dimension              - хэш параметров размеров.
*     {Object} tipModeParams          - хэш параметров подсказки. Структура:
*                                         {String} tipType - тип подсказки. Варианты:
*                                            'question' - иконка с вопросительным знаком
*                                            'info' - иконка 'i'
*                                            'exclamation' - иконка '!' + стиль - красный цвет
*                                         {Object} PopupParams - объект с параметрами всплывашки:
*                                            {Number} closeTimeout - время после события потери
*                                               наведения, после которого всплывашка должна скрыться.
*                                            {Number} showTimeout - время после события наведения,
*                                               после которого всплывашка должна показаться.
*     {Boolean} isResetDefaultHeight  - флаг сброса высоты кнопки по-умолчанию. (по-умолчанию = false)
*     {Boolean} isContentAtTheCorners - флаг разнесения содержимого по разным сторонам
*                                       правое - вправо, левое - влево (по умолчанию = false)
*     {Boolean} isWithoutPadding      - флаг кнопки без внутренних отступов по краям
*                                       (по умолчанию = false)
*     {Boolean} isShown               - флаг показа кнопки (по-умолчанию = true)
*     {Boolean} isLink                - флаг кнопки-ссылки (по-умолчанию = false)
*     {Boolean} isClear               - флаг кнопки для очистки (крестик) (по-умолчанию = false)
*     {Boolean} isDisabled            - флаг выключения кнопки (по-умолчанию = false)
*     {Boolean} isMain                - флаг главной кнопки (выделяется цветом)
*                                         (по-умолчанию = false)
*     {Boolean} isActive              - флаг того что кнопка ативирована (по-умолчанию = false). Если
*                                       кнопка активирвана, она не будет реагировать на клики.
*     {Boolean} isDeactivatable       - флаг, разрешающий даективацию активированной кнопки. По-умолчанию
*                                       активированная кнопка не порождает событие клика, при положительном
*                                       значении данного флага активированная кнопка порождает событие
*                                       с пустым значением. (по-умолчанию =false).
*     {Boolean} isTrigger             - флаг, указывающий на то, что кнопка является checkbox'ом.
*                                         При этом, если флаг isActive поднят, значит Checkbox
*                                         должен быть активным. (по-умолчанию = false).
*     {Function} onKeyDown            - обработчик нажатия клавиши клавиатуры на кнопке. Аргументы:
*                                       {Event-object} event - объект события.
*     {Function} onClick              - обработчик клика по кнопке. Аргументы:
*                                       {Object} value       - значение, заданное кнопке.
*                                       {Event-object} event - объект события.
*     {Function} onDoubleClick        - обработчик двойного клика по кнопке. Аргументы:
*                                       {Event-object} event - объект события.
*     {Function} onFocus              - обработчик фокусировки на кнопке. Аргументы:
*                                       {Event-object} event - объект события.
*     {Function} onBlur               - обработчик протери фокуса кнопкой. Аргументы:
*                                       {Event-object} event - объект события.
*     {Function} onMouseDown          - обработчик на нажатие кнопки мыши. Аргументы:
*                                       {Event-object} event - объект события.
*     {Function} onMouseUp            - обработчик на отпуск кнопки мыши. Аргументы:
*                                       {Event-object} event - объект события.
* @state
*     {Boolean} isFocused            - флаг нахождения кнопки в фокусе.
*     {Boolean} isPressed            - флаг "нажатости" кнопки (кнопка мыши
*                                      ещё не отпущена).
*     {Boolean} isHovered            - флаг нахождения курсора над кнопкой.
*     {Boolean} isTriggerActive      - статус триггера (включен/выключен).
*     {React-Element} tipTarget      - цель для всплывашки.
*
###
Button = React.createClass

   # @const {Object} - маркеры позиционирования.
   _POSITION_MARKERS: keyMirror(
      both: null
      left: null
      right: null
   )

   # @const {Object} - задержка для всплывашки по умолчанию.
   _DEFAULT_TIP_DELAY:
      show: 1000
      close: 1500
      click: 4

   # @const {Object} - иконки по-умолчанию.
   _DEFAULT_ICONS:
      info: 'info-circle'
      question: 'question-circle'
      exclamation: 'exclamation-circle'

   # @const {Object} - используемые символы.
   _CHARS:
      empty: ''

   # @const {Object} - используемые маркеры.
   _MARKERS: keyMirror(
      disabled: null
      checked: null
   )

   # @const {Object} - наименования используемых ссылок.
   _REFS:
      tip: 'isTip'

   # @const {String} - символ для кнопки очистки.
   _CLEAR_CHAR: '×'

   # @const {String} - идентификатор позиционирования области всплывашки.
   _TIP_LAYOUT_ANCHOR: 'window'

   # @const {String} - идентификатор иконки '!'.
   _EXCLAMATION_TYPE: 'exclamation'

   # @const {String} - заголовок по-умолчанию для стандартной кнопки очистки.
   _DEFAULT_CLEAR_TITLE: 'Очистить'

   # @const {String} - префикс класса для иконок FontAwesome
   _FA_ICON_PREFIX: 'fa fa-'

   # @const {String} - наименование типа ввода - чекбокса.
   _CHECKBOX_INPUT: 'checkbox'

   mixins: [HelpersMixin, AnimateMixin, AnimationsMixin.highlight]

   styles:
      common:
         padding: _COMMON_PADDING
         borderRadius: _COMMON_BORDER_RADIUS
         borderWidth: 1
         borderStyle: 'solid'
         color: _COLORS.hierarchy1
         borderColor: _COLORS.hierarchy3
         cursor: 'pointer'
         minHeight: 32
         textOverflow: 'ellipsis'
         overflow: 'hidden'
      resetedHeight:
         minHeight: ''
      clear:
         borderWidth: 0
         backgroundColor: 'transparent'
         fontSize: 20
         padding: 0
         minHeight: 15
         color: _COLORS.hierarchy2
      link:
         color: _COLORS.link1
         cursor: 'pointer'
         borderWidth: 0
         backgroundColor: 'transparent'
         textOverflow: 'ellipsis'
         overflow: 'hidden'
         # textDecoration: 'underline'
      inFocus:
         color: _COLORS.highlight1
         boxShadow: "0 0 5px #{_COLORS.secondary}"
      withoutPadding:
         padding: 0
      leftPaddingElement:
         paddingLeft: _COMMON_PADDING - 1
         paddingRight: 3
         textAlign: 'left'
      rightPaddingElement:
         paddingRight: _COMMON_PADDING
         paddingLeft: 3
         textAlign: 'right'
      bothPaddingElement:
         paddingRight: _COMMON_PADDING
         paddingLeft: _COMMON_PADDING
         textAlign: 'center'
      leftFloatElement:
         float: 'left'
      rightFloatElement:
         float: 'right'
      active:
         backgroundColor: _COLORS.light
         borderWidth: 2
         borderColor: _COLORS.main
         borderStyle: 'solid'
         color: _COLORS.main
      activeInLinkMode:
         borderWidth: 0
         borderBottomWidth: 1
         paddingTop: 1
         borderBottomColor: _COLORS.main
      inactiveInLinkMode:
         borderBottomWidth: 0
      main:
         backgroundColor: _COLORS.main
         borderWidth: 0
         padding: _COMMON_PADDING + 1
         color: _COLORS.light
      mainPressed:
         backgroundColor: _COLORS.secondary
         boxShadow: 'inset 0 3px 5px rgba(0,0,0,0.125)'
      highlight:
         color: _COLORS.highlight1
      pressed:
         backgroundColor: _COLORS.hierarchy4
         boxShadow: 'inset 0 3px 5px rgba(0,0,0,0.125)'
      tableWrapper:
         width: '100%'
      tableWrapperWithNested:
         tableLayout: 'fixed'
      disabled:
         cursor:'default'
         color: _COLORS.hierarchy3
         cursor: 'auto'
         #padding: _COMMON_PADDING
      hidden:
         display: 'none'
      checkboxContainer:
         margin: 0
         display: 'inline-block'
         float: 'right'
         height: 16
      checkbox:
         margin: 0
      PopupBaloonStyle:
         marginLeft: 4
         marginTop: 5
      exclamationStyle:
         color: _COLORS.alert

   propTypes:
      caption: React.PropTypes.oneOfType [
            React.PropTypes.string
            React.PropTypes.number
            React.PropTypes.object
         ]
      title: React.PropTypes.oneOfType [
            React.PropTypes.string
            React.PropTypes.number
            React.PropTypes.object
         ]
      dimension: React.PropTypes.object
      type: React.PropTypes.string
      style: React.PropTypes.object
      styleAddition: React.PropTypes.object
      iconPosition: React.PropTypes.string
      isResetDefaultHeight: React.PropTypes.bool
      isContentAtTheCorners: React.PropTypes.bool
      isWithoutPadding: React.PropTypes.bool
      isShown: React.PropTypes.bool
      isClear: React.PropTypes.bool
      isLink: React.PropTypes.bool
      isDisabled: React.PropTypes.bool
      isMain: React.PropTypes.bool
      isActive: React.PropTypes.bool
      isDeactivatable: React.PropTypes.bool
      onClick: React.PropTypes.func

   getDefaultProps: ->
      type: 'button'
      iconPosition: 'left'
      isResetDefaultHeight: false
      isContentAtTheCorners: false
      isShown: true
      isClear: false
      isLink: false
      isDisabled: false
      isMain: false
      isActive: false
      isDeactivatable: false

   getInitialState: ->
      isTriggerActive: @props.isActive
      tipTarget: undefined
      isFocused: false
      isHovered: false

   componentWillReceiveProps: (nextProps) ->
      if nextProps.isTrigger and nextProps.isActive isnt @props.isActive
         @setState isTriggerActive: nextProps.isActive

   render: ->
      `(
         <button type={this.props.type}
                 disabled={this.props.isDisabled ? this._MARKERS.disabled : null}
                 style={this._getButtonStyle()}
                 title={this._getButtonTitle()}
                 tabIndex={this.props.tabIndex}
                 className={this.props.className}
                 onKeyDown={this.props.onKeyDown}
                 onClick={this._onClick}
                 onDoubleClick={this.props.onDoubleClick}
                 onMouseDown={this._onMouseDown}
                 onMouseUp={this._onMouseUp}
                 onMouseEnter={this._onMouseEnter}
                 onMouseLeave={this._onMouseLeave}
                 onFocus={this._onFocus}
                 onBlur={this._onBlur}
               >
            {this._getButtonContent()}
         </button>
      )`

   ###*
   * Функция получения контента кнопки. В зависимости от позиций, заданных в
   *  параметрах формирует надпись и иконку в разной последовательности
   *
   * @return {React-Element} - содержимое кнопки (контент)
   ###
   _getButtonContent: ->
      icon = @props.icon
      isClear = @props.isClear
      caption = @props.caption
      isTipModeParams =- @props.tipModeParams?
      positionMarkers = @_POSITION_MARKERS
      iconComponent = @_getIcon() if icon or isClear or isTipModeParams

      if caption
         captionComponent = caption

      # в зависимости от заданной позиции иконки разместим её в разметке
      switch @props.iconPosition
         when positionMarkers.right
            leftElement = captionComponent
            rightElement = iconComponent
         else
            leftElement = iconComponent
            rightElement = captionComponent

      isExistIcon = iconComponent?
      isExistCaption = captionComponent? and (captionComponent isnt @_CHARS.empty)
      isSingleElement = !isExistCaption or !isExistIcon

      leftPaddingMarker = if isSingleElement
                             positionMarkers.both
                          else
                             positionMarkers.left

      rightPaddingMarker = if isSingleElement
                              positionMarkers.both
                           else
                              positionMarkers.right

      `(
         <span>
            {this._getElement(leftElement, leftPaddingMarker)}
            {this._getElement(rightElement, rightPaddingMarker)}
            {this._getCheckbox()}
         </span>
       )`

   ###*
   * Функция получения елемента содержимого кнопки. Задает дополнительные стили
   *  для элементов в зависимости от переданного маркера.
   *
   * @param {Object} element        - выводимый объект.
   * @param {String} positionMarker - маркер позиции.
   * @return {React-Element} - элемент содержимого кнопки.
   ###
   _getElement: (element, positionMarker)->
      if element?
         styles = @styles
         elementStyle = styles["#{positionMarker}PaddingElement"]
         atTheCorenerStyle = if @props.isContentAtTheCorners
                                styles["#{positionMarker}FloatElement"]
         withoutPaddingStyle = if @props.isWithoutPadding
                                  styles.withoutPadding

         computedStyle = @computeStyles elementStyle,
                                        atTheCorenerStyle,
                                        withoutPaddingStyle

         `(
            <span style={computedStyle}>
               {element}
            </span>
         )`

   ###*
   * Функция получения триггера
   *
   * @return {React-Element} - Триггер.
   ###
   _getCheckbox: ->
      if @props.isTrigger
         checkedMarker = @_MARKERS.checked if @state.isTriggerActive

         `(
            <span style={this.styles.checkboxContainer}>
               <input style={this.styles.checkbox}
                      type={this._CHECKBOX_INPUT}
                      onChange={this._onCheckboxClick}
                      checked={checkedMarker}
                    />
            </span>
         )`

   ###*
   * Функция получения иконки кнопки.
   *
   * @return {React-Element, String} - иконка
   ###
   _getIcon: ->
      tipModeParams = @props.tipModeParams
      tipType = tipModeParams and tipModeParams.type
      defaultIcons = @_DEFAULT_ICONS
      faIconPrefix = @_FA_ICON_PREFIX
      iconName = @props.icon


      if tipModeParams?
         tipIcon = defaultIcons[tipModeParams.tipType]
         `(
            <i className={faIconPrefix + tipIcon}
               ref={this._REFS.tip}>
               {this._getPopupBaloon()}
            </i>
         )`
      else if iconName?
         `(<i className={faIconPrefix + iconName}></i>)`
      else if @props.isClear
         @_CLEAR_CHAR


   ###*
   * Функция получения всплывающего заголовка для кнопки очистки. Если заголовок
   *  задан через свойства, то возвращает его. Иначе, если это кнопка очистки -
   *  возвращает стандартный заголовок кнопки очистки.
   *
   * @return {String, undefined}
   ###
   _getButtonTitle: ->
      unless @props.tipModeParams?
         isClear = @props.isClear
         propTitle = @props.title

         if propTitle?
            propTitle
         else if isClear
            @_DEFAULT_CLEAR_TITLE

   ###*
   * Функция получение скомпанованного стиля кнопки. Проверяет не является ли кнопка
   *  кнопкой-ссылкой, проверяет не задан ли для кнопки кастомный стиль.
   *
   * @return {Object} - скомпанованный стиль кнопки
   ###
   _getButtonStyle: ->
      customStyle = @props.style
      customStyleAddition = @props.styleAddition
      styles = @styles
      # allowAnimationStyle = !@props.isDisabled and
      isResetDefaultHeight = @props.isResetDefaultHeight
      isLink = @props.isLink or @props.isInfo or @props.isQuestion
      isClear = @props.isClear
      isWithoutPadding = @props.isWithoutPadding
      isPressed = @state.isPressed
      isFocused = @state.isFocused
      isMain = @props.isMain
      isDisabled = @props.isDisabled
      isShown = @props.isShown
      isActive = @props.isActive
      dimensionStyle = @_getDimensionStyle()
      isTrigger = @props.isTrigger
      isTriggerActive = @state.isTriggerActive
      isExclamationStyle = @props.tipModeParams and
         @props.tipModeParams.tipType is @_EXCLAMATION_TYPE

      # Если это кнопка-ссылка - зададим основной стиль ссылки, и заданим
      #  цвет текста основного стиля как цвет ссылки(для анимации).
      # Иначе - стандартно.
      if isLink
         styles.common.color = _COLORS.link1
         buttonStyle = styles.link
      else
         styles.common.color = _COLORS.dark
         buttonStyle = styles.common

      # Если задан стиль у кнопки - считаем его.
      if customStyle and !_.isEmpty customStyle
         buttonStyle = customStyle
         @_checkAndSetCutomAnimationParams customStyle

      # Если задан дополнительный стиль у кнопки - проверим на наличие важных
      #  для анмации параметров.
      if customStyleAddition and !$.isEmptyObject customStyleAddition
         @_checkAndSetCutomAnimationParams customStyleAddition

      isPressedMain = isPressed and !isLink and !isClear and !isActive and !isTrigger
      isPressedTrigger = isTrigger and isTriggerActive

      pressedStyle =
         if isPressedMain or isPressedTrigger
            if isMain then @styles.mainPressed else @styles.pressed

      @computeStyles buttonStyle,
                     isWithoutPadding and @styles.withoutPadding,
                     isResetDefaultHeight and @styles.resetedHeight,
                     isClear and @styles.clear,
                     isFocused and !isLink and !isClear and @styles.inFocus,
                     isMain and @styles.main,
                     dimensionStyle,
                     pressedStyle,
                     customStyleAddition and customStyleAddition,
                     @_getAnimateStyle(),
                     isDisabled and styles.disabled,
                     isActive and !isTrigger and @styles.active,
                     isLink and isActive and @styles.activeInLinkMode,
                     isLink and !isActive and @styles.inactiveInLinkMode,
                     !isShown and styles.hidden,
                     isExclamationStyle and styles.exclamationStyle

   ###*
   * Функция получения стилей размеров кнопки, если они были заданы.
   *
   * @return {Object} - стили размеров.
   ###
   _getDimensionStyle: ->
      dimension = @props.dimension
      dimStyle = {}

      if dimension? and !_.isEmpty dimension
         width = dimension.width
         height = dimension.height

         if width? and !$.isEmptyObject width
            maxWidth = width.max
            minWidth = width.min

            if maxWidth?
               dimStyle.maxWidth = maxWidth
            if minWidth
               dimStyle.minWidth = minWidth

         if height? and !_.isEmpty height
            maxHeight = height.max
            minHeight = height.min

            if maxHeight?
               dimStyle.maxHeight = maxHeight
            if minHeight
               dimStyle.minHeight = minHeight

      dimStyle

   ###*
   * Функция получения стиля табличного контейнера для контента кнопки. Проверяет
   *  были заданы стили через свойства. Если были, проверяет была ли задана
   *  ширина кнопки. Если была - задает дополнительный стиль для контейнера, чтобы
   *  он не выходил за пределы кнопки.
   *
   * @return {Object} - скомпанованный стиль контейнера
   ###
   _getContentContainerStyle: ->
      @computeStyles @styles.tableWrapper,
         @props.style and @props.style.width and @styles.tableWrapperWithNested

   ###*
   * Функция получения цветов до и после наведения. В зависимости от того, задал
   *  ли пользователь цвета и от того, каков тип кнопки, возвращает цвета без
   *  наведения и с наведением.
   *
   * @return {Object} - Цвета перед и после наведения
   ###
   _getCurrentColors: ->
      propsStyle = @props.style
      propsStyleAddition = @props.styleAddition

      if propsStyle? and !$.isEmptyObject(propsStyle)
         colorNormal = propsStyle.color
      else if propsStyleAddition? and !$.isEmptyObject(propsStyleAddition)
         colorNormal = propsStyleAddition.color


      if @props.isMain
         colorNormal ||= _COLORS.light
         colorHover = _COLORS.dark
      else if @props.isLink
         colorNormal ||= _COLORS.link1
         colorHover = _COLORS.highlight1
      else if @props.isClear
         colorNormal ||= _COLORS.hierarchy2
         colorHover = _COLORS.highlight1

      normal: colorNormal
      hover: colorHover


   ###*
   * Функция, возвращающая всплывашку.
   *  Зависимости: Popup-baloon - Компонент всплывашки
   *
   * @return {Read-Element} - всплывашка.
   ###
   _getPopupBaloon: ->
      PopupBaloon = require('./popup_baloon')
      popupParams = @props.tipModeParams.popupParams || {}
      defaultTipDeley = @_DEFAULT_TIP_DELAY
      popupParams.target = @refs.isTip

      if @state.isPressed
         popupParams.isTrigger = true
         popupParams.delayShowTimout = defaultTipDeley.click
         popupParams.delayCloseTimout = defaultTipDeley.click
      else
         if @state.isHovered
            unless popupParams.delayShowTimout
               popupParams.delayShowTimout = defaultTipDeley.show
            popupParams.isShow = true
         else
            unless popupParams.delayCloseTimout
               popupParams.delayCloseTimout = defaultTipDeley.close
            popupParams.isShow = false

      `(
         <PopupBaloon {...popupParams}
                      popupContent={this.props.title}
                      horizontalPosition={this._POSITION_MARKERS.right}
                      layoutAnchor={this._POPUP_BALOON_LAYOUT_ANCHOR}
                      styleAddition={this.styles.PopupBaloonStyle}
                   />
      )`

   ###*
   * Функция-предикат для определиня интерактивна ли кнопка (она не задизейблина
   *  и не активирована)
   *
   * @return {Boolean}
   ###
   _isLiveButton: ->
      !@props.isDisabled and (!@props.isActive or @props.isTrigger)

   ###*
   * Обработчик на клик по кнопке. Пробрасывает событие на оброботчик, переданный
   *  в параметрах (при наличии)
   *
   * @param {Object} event - объкект события.
   * @return
   ###
   _onClick: (event) ->
      # Для обычных кнопок сбросим поведение по-умолчанию(ведет себя странно в формах)
      event.preventDefault() unless @props.type or @props.isTrigger

      if @props.isTrigger
         @setState isTriggerActive: !@state.isTriggerActive

         if @props.onClick
            @props.onClick @props.value, event
      else if @props.onClick and (!@props.isActive or @props.isDeactivatable)
         @props.onClick @props.value, event

      @setState
         isFocused: false

   ###*
   * Обработчик на клик по триггеру.
   *
   * @param {Object} event - объкект события.
   * @return
   ###
   _onCheckboxClick: (event)->
      false

   ###*
   * Обработчик на фокус.
   *
   * @param {Event-object} event - объкект события.
   * @return
   ###
   _onFocus: (event) ->
      onFocusHandler = @props.onFocus
      onFocusHandler(event) if onFocusHandler?

      @setState isFocused: true

   ###*
   * Обработчик на потерю фокуса
   *
   * @param {Event-object} event - объкект события.
   * @return
   ###
   _onBlur: (event) ->
      onBlurHandler = @props.onBlur
      onBlurHandler(event) if onBlurHandler?

      @setState isFocused: false

   ###*
   * Обаботчик на нажатие кнопки мыши.
   *
   * @param {Object} event - объкект события.
   * @return
   ###
   _onMouseDown: (event)->
      onMouseDownHandler = @props.onMouseDown

      onMouseDownHandler event if onMouseDownHandler?

      @setState isPressed: true

   ###*
   * Обаботчик на отпускание кнопки мыши.
   *
   * @param {Object} event - объкект события.
   * @return
   ###
   _onMouseUp: (event) ->
      onMouseUpHandler = @props.onMouseUp

      onMouseUpHandler event if onMouseUpHandler?

      @setState isPressed: false


   ###*
   * Обработчик на вход курсора мыши на элемента.
   *  В зависимости свойств задает начальный и конечный цвета анимации.
   *
   * @param {Object} event - параметры события.
   * @return
   ###
   _onMouseEnter: (event) ->
      event.stopPropagation()
      event.preventDefault()

      if @_isLiveButton()
         color = @_getCurrentColors()
         @_animationHighlightIn(color.normal, color.hover) if @isMounted()

      @setState isHovered: true


   ###*
   * Обработчик выхода курсора мыши за пределы элемента.
   *  В зависимости свойств задает начальный и конечный цвета анимации.
   *
   * @param {Object} event - параметры события.
   * @return
   ###
   _onMouseLeave: (event) ->
      #this._onMouseUp
      color = @_getCurrentColors()
      @_animationHighlightOut(color.hover, color.normal) if @isMounted()

      @setState isHovered: false

   ###*
   * Функция проверки стиля на наличие параметров, вляющих на анимацию (цвет текста)
   *  В слуачае выявления таких параметров - устанавливает в основной стиль.
   *
   * @param {Object} style - хэш с параметрами стиля
   ###
   _checkAndSetCutomAnimationParams: (style) ->
      # Если задан цвет - установим его значение в основной стиль (для анимации).
      if style.color
         @styles.common.color = style.color


module.exports = Button

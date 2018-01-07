###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* HelpersMixin     - функции-хэлперы для компонентов.
* AnimationsMixin  - набор анимаций для компонентов.
* AnimateMixin     - библиотека добавляющая компонентам
*                    возможность исользования анимации.
* keymirror        - модуль для генерации "зеркального" хэша.
* lodash           - модуль служебных операций.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
AnimationsMixin = require('../mixins/animations')
AnimateMixin = require('react-animate')
keyMirror = require('keymirror')
_ = require('lodash')

###* Константы
* _COLORS               - цвета
* _COMMON_PADDING       - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius

###* Компонент - Лейбл. Для отображения текстовой или графической информации
*  с возможностью вывода подсказки(доп. информации) и анимации при наведении.
*
* @props
*     {String, Object} content - содержимое лейбла.
*     {String, Object} title   - выводимая подсказка.
*     {Object} styleAddition   - дополнительные стили лейбла (можно задать произвольный)
*                                для различных элементов лейбла. Вид:
*                                {Object} common - общий стиль для лейбла.
*                                {Object} icon   - стиль для иконки.
*     {Boolean} isLink         - флаг лейбла-ссылки. По-умолчанию = false
*     {Boolean} isBlock        - флаг лейбла располагаемого как блочный элемент (как div).
*                                По-умолчанию = false.
*     {Boolean} isInlineBlock  - флаг лейбла располагаемого как блочно-строчный элемент.
*                                По-умолчанию = false.
*   {Boolean} isWithoutPadding - флаг отсутствия отступов у содержимого слева и справа.
*                                По-умолчанию = false.
*     {Boolean} isRounded      - флаг скругленный границ лейбла.
*                                По-умолчанию = false.
*     {Boolean} isOutlined     - флаг обведенного лейбла. Заливка заменяется
*                                закрашенными границами лейбла.
*                                По-умолчанию = false.
*     {Boolean} isAccented     - флаг акцентируемости на лейбле (при наведении
*                                выполняется подсветка). По-умолчанию = true
*     {String} icon            - наименование отображаемой иконки.
*     {String} iconPosition    - позиционирование иконки. Варианты:
*                                'left'  - слева (по-умолчанию).
*                                'right' - справа.
*                                'top'   - сверху.
*                                'bottom'- снизу.
*     {Number} fontSize        - размер шрифта.
*     {String} type            - тип лейбла. Варианты:
*                                'ordinary'         - серый (по-умолчанию),
*                                'ordinaryLight'    - светло-серый,
*                                'success'          - зеленый,
*                                'successLight'     - светло-зеленый,
*                                'exclamation'      - оранжевый,
*                                'exclamationLight' - светло-оранжевый,
*                                'alert'            - красный,
*                                'alertLight'       - светло-красный,
*                                'info'             - синий,
*                                'infoLight'        - светло-синий,
*    {Function} onClick        - обработчик клика по лейблу.
###
Label = React.createClass
   # @const {Object} - используемые символы.
   _CHARS:
      empty: ''

   # @const {Object} - возможные позиции иконки.
   _ICON_POSITIONS: keyMirror(
      left: null
      right: null
      top: null
      bottom: null
   )

   # @const {Object} - задержка для всплывашки по умолчанию.
   _DEFAULT_TIP_DELAY:
      show: 1000
      close: 1500
      click: 4

   # @const {Object} - суффиксы для модификации наименования применяемого стиля
   #                   в зависимости от заданных параметров.
   _SPECIFIC_SUFFIXES:
      link: 'Link'

   # @const {String} - префикс класса для иконок FontAwesome.
   _FA_ICON_PREFIX: 'fa fa-'

   # @const {String} - "якорь" для всплывашки.
   _POPUP_ANCHOR: 'window'

   mixins: [
      HelpersMixin
      AnimateMixin
      AnimationsMixin.highlight
   ]

   styles:
      common:
         cursor: 'pointer'
         fontSize: 13
         fontFamily: 'Arial'
         paddingLeft: _COMMON_PADDING
         paddingRight: _COMMON_PADDING
         paddingTop: 2
         paddingBottom: 2
         textAlign: 'center'
      hidden:
         display: 'none'
      resetAccented:
         cursor: 'normal'
      commonAdditionLink:
         paddingTop: 0
         paddingBottom: 0
      displayBlock:
         display: 'block'
      displayInlineBlock:
         display: 'inline-block'
      roundedBorder:
         borderRadius: _COMMON_BORDER_RADIUS
      withoutPadding:
         paddingLeft: 0
         paddingRight: 0
         paddingTop: 0
         paddingBottom: 0
      popupBaloon:
         maxWidth: 350
      icon:
         padding: 2
      iconWithContent:
         padding: 4
      outlinedScaffold:
         borderStyle: 'solid'
         backgroundColor: ''
      ordinary:
         color: _COLORS.hierarchy2
         backgroundColor: _COLORS.hierarchy4
      ordinaryLight:
         color: _COLORS.hierarchy3
         backgroundColor: _COLORS.light
      success:
         color: _COLORS.successDark
         backgroundColor: _COLORS.success
      successLight:
         color: _COLORS.success
         backgroundColor: _COLORS.successLight
      exclamation:
         color: _COLORS.exclamationDark
         backgroundColor: _COLORS.exclamation
      exclamationLight:
         color: _COLORS.exclamation
         backgroundColor: _COLORS.exclamationLight
      alert:
         color: _COLORS.alertDark
         backgroundColor: _COLORS.alert
      alertLight:
         color: _COLORS.alert
         backgroundColor: _COLORS.alertLight
      info:
         color: _COLORS.infoDark
         backgroundColor: _COLORS.info
      infoLight:
         color: _COLORS.info
         backgroundColor: _COLORS.infoLight
      ordinaryLink:
         color: _COLORS.hierarchy2
      ordinaryLightLink:
         color: _COLORS.hierarchy3
      successLink:
         color: _COLORS.successDark
      successLightLink:
         color: _COLORS.success
      exclamationLink:
         color: _COLORS.exclamationDark
      exclamationLightLink:
         color: _COLORS.exclamation
      alertLink:
         color: _COLORS.alertDark
      alertLightLink:
         color: _COLORS.alert
      infoLink:
         color: _COLORS.link1
      infoLightLink:
         color: _COLORS.info

   PropTypes:
      content: React.PropTypes.oneOfType([
         React.PropTypes.object
         React.PropTypes.string
      ])
      title: React.PropTypes.oneOfType([
         React.PropTypes.object
         React.PropTypes.string
      ])
      customStyle: React.PropTypes.object
      isLink: React.PropTypes.bool
      isBlock: React.PropTypes.bool
      isInlineBlock: React.PropTypes.bool
      isWithoutPadding: React.PropTypes.bool
      isRounded: React.PropTypes.bool
      isOutlined: React.PropTypes.bool
      isAccented: React.PropTypes.bool
      type: React.PropTypes.string
      icon: React.PropTypes.string
      iconPosition: React.PropTypes.string

   getDefaultProps: ->
      isLink: false
      isBlock: false
      isInlineBlock: false
      isWithoutPadding: false
      isRounded: false
      isOutlined: false
      isAccented: true
      type: 'ordinary'
      iconPosition: 'left'

   getInitialState: ->
      isHovered: false

   render: ->
      labelElements = @_getLabelElements()

      `(
         <label style={this._getStyle()}
                title={this._getTitle()}
                onMouseEnter={this._onMouseEnter}
                onMouseLeave={this._onMouseLeave}
                onClick={this.props.onClick}
              >
            {labelElements.left}
            {labelElements.right}
            {this._getPopupTitle()}
         </label>
       )`

   ###*
   * Функция получения иконки лейбла. Создает элемент иконки, если наименование
   *  иконки задано через свойства.
   *
   * @return {React-Element, undefined}
   ###
   _getLabelIcon: ->
      iconName = @props.icon
      isHasContent = @props.content?
      styleAddition = @props.styleAddition

      if iconName
         iconAdditionStyle = styleAddition.icon if styleAddition?
         iconStyle =
            if isHasContent
               @styles.iconWithContent
            else
               @styles.icon

         computedIconStyle = @computeStyles iconStyle, iconAdditionStyle

         `(
            <i style={computedIconStyle}
               className={this._FA_ICON_PREFIX + this.props.icon}></i>
          )`

   ###*
   * Функция получения всплывающей подсказки через компонент PopupBaloon.
   *  Если в свойстве title задано сложное содержимое подсказки (Object) -
   *  то получает всплывающую подсказку.
   *
   * @return {React-Element, undefined}
   ###
   _getPopupTitle: ->
      title = @props.title

      if title and React.isValidElement(title)
         PopupBaloon = require('./popup_baloon')
         defaultTipDeley = @_DEFAULT_TIP_DELAY
         popupParams = {}

         if @state.isHovered
            popupParams.delayShowTimout = defaultTipDeley.show
            popupParams.isShow = true
         else
            popupParams.delayCloseTimout = defaultTipDeley.close
            popupParams.isShow = false

         #styleAddition={this.styles.PopupBaloonStyle}

         `(
            <PopupBaloon {...popupParams}
                         target={this}
                         popupContent={title}
                         layoutAnchor={this._POPUP_ANCHOR}
                         styleAddition={this.styles.popupBaloon}
                     />
         )`

   ###*
   * Функция получения содержимого лейбла (content + icon), расположенных в
   *  зависимости от позиции иконкци (слева/справа).
   *
   * @return {Object} - набор из левого и правого элемента содержимого.
   ###
   _getLabelElements: ->
      labelContent = @props.content
      labelIcon = @_getLabelIcon()
      iconPosition = @props.iconPosition
      iconPositions = @_ICON_POSITIONS
      isVerticalPositioning = @_isIconVerticalPositioning()
      isHasIcon = labelIcon?
      isHasContent = labelContent

      ###*
      * Фнукия помещения элемента в блочный контейнер.
      *
      * @param {React-element} element - оборачиваемый элемент.
      * @return {React-element}
      ###
      wrapToBlock = (element) ->
         `(
             <div>{element}</div>
          )`

      if isVerticalPositioning
         labelContent = wrapToBlock(labelContent)
         labelIcon = wrapToBlock(labelIcon)

      if iconPosition in [iconPositions.right, iconPositions.bottom]
         left: labelContent
         right: labelIcon
      else
         left: labelIcon
         right: labelContent

   ###*
   * Функция получения выводимой стандартной подсказки. Возвращает значение
   *  если подскзка задана в виде обычного текста.
   *
   * @return {String}
   ###
   _getTitle: ->
      title = @props.title

      title if title? and _.isString(title)

   ###*
   * Функция получения стиля лейбла.
   *
   * @return {Object}
   ###
   _getStyle: ->
      styleAddition = @props.styleAddition
      commonStyleAddition = styleAddition.common if styleAddition?
      isIconVerticalPositioning = @_isIconVerticalPositioning()
      isInlineBlockDisplay = @props.isInlineBlock or isIconVerticalPositioning

      @computeStyles @styles.common,
                     !@props.isAccented and @styles.resetAccented,
                     @props.isLink and @styles.commonAdditionLink,
                     @props.isBlock and @styles.displayBlock,
                     isInlineBlockDisplay and @styles.displayInlineBlock,
                     @props.isRounded and @styles.roundedBorder,
                     @props.isWithoutPadding and @styles.withoutPadding,
                     !@_isHasViewInfo() and @styles.hidden
                     @_getSpecificStyle(),
                     commonStyleAddition,
                     @props.fontSize and fontSize: @props.fontSize
                     @props.isAccented and @_getAnimateStyle()

   ###*
   * Функция получения "специфичного" стиля для определенного типа лейбла.
   *
   * @return {Object} - объект стиля.
   ###
   _getSpecificStyle: ->
      specificSuffixes = @_SPECIFIC_SUFFIXES
      linkSuffix = specificSuffixes.link if @props.isLink
      emptyChar = @_CHARS.empty

      specificStyleName =
         [
            @props.type
            linkSuffix
         ].join emptyChar

      @_modifyStyleByFlags(@styles[specificStyleName])

   ###*
   * Функция-предикат для определения ситуации, когда не задано никакой информации
   *  для отображения (ни иконки, ни содержимого).
   *
   * @return {Boolean}
   ###
   _isHasViewInfo: ->
      icon = @props.icon
      content = @props.content

      icon? or content?

   ###*
   * Функция-предикат для определения задано ли вертикальное
   *  позиционирование иконки лейбла.
   *
   * @return {Boolean}
   ###
   _isIconVerticalPositioning: ->
      iconPosition = @props.iconPosition
      iconPositions = @_ICON_POSITIONS
      !!~_.indexOf([iconPositions.top, iconPositions.bottom], iconPosition)

   ###*
   * Обработчик на вход мыши на лейбл. Запускает анимацию подсветки.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onMouseEnter: (event) ->
      specificStyle = @_getSpecificStyle()

      @_animationHighlightIn(specificStyle.color)

      @setState isHovered: true

   ###*
   * Обработчик на выход мыши с лейбл. Запускает анимацию подсветки.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onMouseLeave: (event) ->
      specificStyle = @_getSpecificStyle()

      @_animationHighlightOut(null, specificStyle.color)

      @setState isHovered: false

   ###*
   * Функция модификации специфичного стиля лейбла по флагам (пока
   *  преобразование идет только по флагу @props.isOutlined)
   *
   * @param {Object} specificStyle - специфичный стиль лейбла.
   * @return {Object}
   ###
   _modifyStyleByFlags: (specificStyle) ->
      chars = @_CHARS
      emptyChar = chars.empty
      isOutlined = @props.isOutlined

      if isOutlined and specificStyle
         styleColor = specificStyle.color
         specificStyle.borderColor = styleColor

         @computeStyles specificStyle, @styles.outlinedScaffold
      else
         specificStyle

module.exports = Label
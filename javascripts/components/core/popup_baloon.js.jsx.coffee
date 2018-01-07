###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов
* HelpersMixin     - функции-хэлперы для компонентов
* keymirror        - модуль для генерации "зеркального" хэша.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
PureRenderMixin = React.addons.PureRenderMixin
keyMirror = require('keymirror')

###* Зависимости: компоненты
* ArbitraryArea - компонент всплывающей произвольной области.
###
ArbitraryArea = require('./arbitrary_area')

###* Константы
* _COLORS         - цвета.
* _COMMON_PADDING - значение отступа.
* _ICON_CONTAINER_WIDTH - константа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius
_ICON_CONTAINER_WIDTH = constants.iconContainerWidth

###* Компонент: Вслывающая подсказка
*
*
* @props
*     {React-Element, false} target  - целевой компонент.
*     {Object, String} popupContent  - содержимое компонента всплывашки.
*     {Object} styleAddition         - дополнительные стили (если нужен стиль по умолчанию + что-то
*                                      ещё).
*     {String} horizontalPosition    - горизонтальная позиция компонента. Варианты:
*                                        'left' - слева (по умолчанию)
*                                        'right' - справа.
*     {String} verticalPosition      - вертикальная позиция компонента. Варманты:
*                                        'bottom' - снизу (по умолчанию)
*                                        'top' - сверху.
*     {String} icon                  - название иконки из FontAwesome (без префиксов).
*     {String} iconPosition          - позиция иконки относительно содержимого компонента. Варианты:
*                                        'right' - справа (по умолчанию)
*                                        'left' - слева.
*     {String} animation             - тип анимации. Варианты:
*                                           "slideDown"  - "выезд" вниз.
*                                           "slideUp"    - "выезд" вверх.
*                                           "slideRight" - "выезд" вправо.
*                                           "slideLeft " - "выезд" влево.
*                                           "fade"       - плавное появление.
*     {String} layoutAnchor          - идентификатор позиционирования области в DOM. Варианты:
*                                      'window' (по-умолчанию). position='fixed'.
*                                      'parent'                 position='absolute'.
*     {Function} onHide              - функция, срабатывающая при закрытии.
*     {Function} onClick             - обработчик клика по области (в любом месте).
*     {Number} closeTimout           - время в мс, через которое всплывашка исчезнет.
*     {Number} delayCloseTimout      - время в мс, через которое всплывашка появится после
*                                      прокидывания цели.
*     {Number} delayShowTimout       - время в мс, через которое всплывашка исчезнет после
*                                      исчезновения цели.
*     {Number} opacity               - Прозрачность компонента.
*     {Boolean} isShow               - флаг показа всплывашки.
* @state
*     {Number} opacity               - Текущая прозрачность компонента, необходима для смены
*                                      прозрачности при наведении.
*     {Boolean} isShow               - флаг показа всплывашки.
###

PopupBaloon = React.createClass
   # @const {Object} - прозрачность по умолчанию.
   _DEFAULT_OPACITY:
      top: 1
      bottom: 0

   # @const {Object} - значения позиций всплывашки.
   _POSITIONS: keyMirror(
      left: null
      right: null
      top: null
      bottom: null
   )

   # @const {Number} - задержка по умолчанию.
   _DEFAULT_DELAY: 0

   # Для хранения таймаута показа.
   _showTimeout: null

   # Для хранения таймаута скрытия.
   _hideTimeout: null

   mixins: [HelpersMixin, PureRenderMixin]

   styles:
      arbitraryAreaStyleAddition:
         whiteSpace: 'normal'
         backgroundColor: 'transparent'
         overflow: 'visible'
         border: 0
         marginTop: 5
         marginBottom: 10
         maxWidth: 250
      iconStyle:
         width: _ICON_CONTAINER_WIDTH
      iconRightStyle:
         paddingLeft: _COMMON_PADDING
      iconLeftStyle:
         paddingRight: _COMMON_PADDING
      triangle:
         position: "absolute"
         width: 0
         height: 0
         borderLeft: "7px solid transparent"
         borderRight: "7px solid transparent"
      triangleCommonBottom:
         borderBottomWidth: 10
         borderBottomStyle: 'solid'
      triangleCommonTop:
         borderTopWidth: 10
         borderTopStyle: 'solid'
      triangleUpBorder:
         borderBottomColor: _COLORS.hierarchy3
         top:-10
      triangleUpBackground:
         borderBottomColor: _COLORS.light
         top:-8
      triangleDownBorder:
         borderTopColor: _COLORS.hierarchy3
         bottom: -10
      triangleDownBackground:
         borderTopColor: _COLORS.light
         bottom: -8
      triangleToRight:
         right: _COMMON_PADDING
      triangleToLeft:
         left: _COMMON_PADDING
      containerStyle:
         color: _COLORS.hierarchy2
         cursor: 'pointer'
         backgroundColor: _COLORS.light
         border: '1px solid'
         borderColor: _COLORS.hierarchy3
         padding: 10
         borderRadius: _COMMON_BORDER_RADIUS
         fontSize: 12
         whiteSpace: 'pre-line'

   propTypes:
      opacity: React.PropTypes.number

   getDefaultProps: ->
      delayCloseTimout: 0
      delayShowTimout: 0
      horizontalPosition: 'left'
      verticalPosition: 'bottom'
      animation: 'fade'
      layoutAnchor: 'parent'
      iconPosition: 'right'

   getInitialState: ->
      opacity: @_getOpacity(true)

   componentWillUpdate: (nextProps, nextState) ->
      delayCloseTimout = nextProps.delayCloseTimout || @_DEFAULT_DELAY
      delayShowTimout = nextProps.delayShowTimout || @_DEFAULT_DELAY
      isShow = @state.isShow
      clearTimeout @_showTimeout
      clearTimeout @_hideTimeout

      if nextProps.isTrigger
         if @state.isShow
            @_hideTimeout = setTimeout @_deleteTarget, delayCloseTimout
         else
            @_showTimeout = setTimeout @_addTarget, delayShowTimout
      else
         if nextProps.isShow
            @_showTimeout = setTimeout @_addTarget, delayShowTimout
         else
            @_hideTimeout = setTimeout @_deleteTarget, delayCloseTimout
      false

   render: ->
      position = @_getPopupPosition()
      target = @state.isShow and @props.target
      styleAddition = @computeStyles @styles.arbitraryAreaStyleAddition,
                                     @props.styleAddition
      `(
         <ArbitraryArea target={target}
                        content={this._getContent()}
                        layoutAnchor={this.props.layoutAnchor}
                        styleAddition={styleAddition}
                        animation={this.props.animation}
                        position={position}
                        isCatchFocus={false}
                        isCloseOnBlur={true}
                        closeTimout={this.props.closeTimout}
                        onHide={this.props.onHide}
                        isTriggerOnSameTarget={false}
                        onClick={this.props.onClick}/>
       )`

   componentWillUnmount: ->
      clearTimeout @_showTimeout
      clearTimeout @_hideTimeout

   ###*
   * Функция, определяющая параметры позиционирования для ArbitraryArea
   *
   * @return {object} - объект с параметрами позиционирования.
   ###
   _getPopupPosition: ->
      position = @_POSITIONS
      horizontalPosition = @props.horizontalPosition
      verticalPosition = @props.verticalPosition
      verticalResult = {}
      horizontalResult = {}

      if horizontalPosition is position.right
         horizontalResult.right = position.right
      else
         horizontalResult.left = position.left

      if verticalPosition is position.top
         verticalResult.bottom = position.top
      else
         verticalResult.top = position.bottom

      horizontal: horizontalResult
      vertical: verticalResult

   ###*
   * Функция, создающая и возвращающая содержимое всплывашки
   *  В зависимости от положения иконки и наличия кнопки закрытия располагает
   *  иконку по центру слева, либо в верхнем правом углу под кнопкой закрытия.
   *
   * @return {React-DOM-Node} - сорержимое для ArbitraryArea c всплывашкой.
   ###
   _getContent: ->
      if @props.icon
         iconComponent =
            `(
               <i className={'fa fa-'+this.props.icon}></i>
            )`
         leftPosition = @_POSITIONS.left
         iconPosition = @props.iconPosition
         isLeftPosition = iconPosition is leftPosition
         styles = @styles
         styleIcon = @computeStyles styles.iconStyle,
                                    isLeftPosition and styles.iconLeftStyle,
                                    !isLeftPosition and styles.iconRightStyle

         tdIcon =
            `(
              <td style={styleIcon}>
                 {iconComponent}
              </td>
            )`

      tdContent =
         `(
           <td>
              {this.props.popupContent}
           </td>
         )`

      switch iconPosition
         when leftPosition
            leftElement = tdIcon
            rightElement = tdContent
         else
            rightElement = tdIcon
            leftElement = tdContent

      computedTriangleStyle = @_getComputedTriangleStyle()

      `(
         <div style={{opacity: this.state.opacity}}
              onMouseOut={this._onMouseOut}
              onMouseOver={this._onMouseOver}>
            <div style={computedTriangleStyle.border}></div>
            <div style={computedTriangleStyle.background}></div>
            <table style={this.styles.containerStyle}>
               <tbody>
                  <tr>
                     {leftElement}
                     {rightElement}
                  </tr>
               </tbody>
            </table>
         </div>
      )`

   ###*
   * Функция, возвращающая стиль двух треугольников, накладывающихся друг на
   *  друга (Border - черный треугольник, Background - белый)
   *  В зависисмости от вертикального и горизонтального положения всплывашки
   *  формирует стили треугольников.
   *
   * @return {Object} - Стили треугольников.
   ###
   _getComputedTriangleStyle: ->
      positions = @_POSITIONS
      horizontalPosition = @props.horizontalPosition
      verticalPosition = @props.verticalPosition
      rightPosition = @_POSITIONS.right
      leftPosition = @_POSITIONS.left
      styles = @styles
      triangleCommonBottom = styles.triangleCommonBottom
      verticalPositionIsTop = verticalPosition is positions.top
      triangleCommonTop = styles.triangleCommonTop
      triangleToRight = styles.triangleToRight
      triangleToLeft = styles.triangleToLeft

      additionStyleBorder =
         @computeStyles verticalPositionIsTop and styles.triangleDownBorder,
                        verticalPositionIsTop and triangleCommonTop,
                        !verticalPositionIsTop and styles.triangleUpBorder,
                        !verticalPositionIsTop and triangleCommonBottom

      additionStyleBackground =
         @computeStyles verticalPositionIsTop and styles.triangleDownBackground,
                        verticalPositionIsTop and triangleCommonTop,
                        !verticalPositionIsTop and styles.triangleUpBackground,
                        !verticalPositionIsTop and triangleCommonBottom

      border = @computeStyles styles.triangle,
         additionStyleBorder,
         horizontalPosition is rightPosition and triangleToRight
         horizontalPosition is leftPosition and triangleToLeft

      background = @computeStyles @styles.triangle,
         additionStyleBackground,
         horizontalPosition is rightPosition and triangleToRight
         horizontalPosition is leftPosition and triangleToLeft

      border: border
      background: background

   ###*
   * Функция, возвращающая значение прозрачности в зависимости от входного параметра и корректности
   *  содержащегося в свойствах значении прозрачности. Если на вход пришло false - возвращаем 1,
   *  иначе возвращаем значение прозрачности, заданное в свойствах. (или, если оно невалидно, 1)
   * @return {Number} - значение прозрачности
   ###
   _getOpacity: (isSource) ->
      defOpacity = @_DEFAULT_OPACITY
      topRange =  defOpacity.top
      bottomRange = defOpacity.bottom

      if isSource
         opacityProp = @props.opacity
         isInCorrectRange = isFinite(opacityProp) and
           opacityProp > bottomRange and opacityProp <= topRange

         if isInCorrectRange
            opacityProp
         else
            topRange
      else
         topRange

   ###*
   * Функция, устанавливающая прозрачность при наведении на компонент.
   *
   * @return
   ###
   _onMouseOut: ->
     @setState opacity: @_getOpacity(true)

   ###*
   * Функция, устанавливающая прозрачность в 1 при выходе курсора за пределы компонента.
   *
   * @return
   ###
   _onMouseOver: ->
      @setState opacity: @_getOpacity(false)

   ###*
   * Функция, устанавливающая флаг показа всплывашки в true.
   *
   * @return
   ###
   _addTarget: ->
      @setState isShow: true

   ###*
   * Функция, устанавливающая флаг показа всплывашки в false.
   *
   * @return
   ###
   _deleteTarget: ->
      @setState isShow: false


module.exports = PopupBaloon

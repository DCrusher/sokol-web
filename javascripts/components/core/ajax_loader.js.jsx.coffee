###* @jsx React.DOM ###

###* Зависимости
* StylesMixin  - общие стили для компонентов.
* HelpersMixin - примесь с функциями-хэлперами для компонентов.
* keymirror             - модуль для генерации "зеркального" хэша.
* lodash                - модуль служебных операций.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
keyMirror = require('keymirror')
_ = require('lodash')

###* Константы
* _COLORS               - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = _CP = constants.commonPadding

###* Компонент индикатора Ajax-загрузки (вращающающийся значок).
*
* @props:
*     {String} text         - выводимый текст-пояснение.
*     {String} textSecondary - выводимый второстепенный текст-пояснение
*     {String} textPosition - позиционирование текста. Варианты:
*                             'top' - сверху от индикатора.
*                             'bottom' - снизу от индикатора. (по-умолчанию).
*     {String} title        - всплывающая подсказка на индикаторе.
*     {String} view         - тип загрузчка (отображаемый сивмол). Варианты (из FontAwesome):
*                             'refresh'        - стрелки. (по-умолчанию)
*                             'spinner'        - круг из точек.
*                             'circle-o-notch' - кольцо с пазом.
*                             'cog'            - шестерня
*     {Object} styleAddition - доп. стиль.
*     {Object} layoutSize    - начальный размер подложки загрузчика.
*     {React-Element} target - целевой узел, на котором позиционируется загрузчик.
*     {Boolean} isStatic     - флаг статичного индикаторов(позиционирование = static)
*                              (по-умолчанию = false).
*     {Boolean} isWithoutSubstrate - флаг загрузчика без фона. (по-умолчанию = false).
*     {Boolean} isShown      - флаг показа компонента. (по-умолчанию = false)
*     {Boolean} isAdaptive   - флаг адаптивного загрузчика - размер иконки подстраивается
*                            под наименьший размер. (по-умолчанию =false)
* @state:
*     {Object} loaderOffset - параметры смещения загрузчика (на базе целевого узла).
*     {Object} loaderSize   - параметры размеров загрузчика (на базе целевого узла).
###
AjaxLoader = React.createClass
   _LOADER_TITLE: 'Идет загрузка'
   _LOADER_MIN_HEIGHT: 42
   _LOADER_MIN_WIDTH: 42

   # @const {Number} - минимальный размер шрифта для иконки при адаптивном загрузчике.
   _MIN_DEFAULT_FONT: 10

   # @const {Object} - возможные позиции текста-пояснения.
   _TEXT_POSITIONS: keyMirror(
      top: null
      bottom: null
   )

   mixins: [HelpersMixin]

   styles:
      common:
         position: 'fixed'
         display: 'none'
         textAlign: 'center'
         backgroundColor: _COLORS.opacityBackingLight
      staticPosition:
         position: 'static'
      withoutSubstrate:
         backgroundColor: null
      shown:
         display: ''
      image:
         fontSize: 40
         display: 'inline-block'
         position: 'relative'
         color: _COLORS.secondary
      imageCell:
         verticalAlign: 'middle'
      textContainer:
         display: 'inline-block'
         padding: _COMMON_PADDING
         backgroundColor: _COLORS.light
         fontSize: 14
      textSecondaryContainer:
         fontSize: 12
         backgroundColor: _COLORS.light
         color: _COLORS.hierarchy2

   propTypes:
      text: React.PropTypes.string
      textPosition: React.PropTypes.oneOf(['top', 'bottom'])
      isShown: React.PropTypes.bool
      isStatic: React.PropTypes.bool
      isWithoutSubstrate: React.PropTypes.bool
      isAdaptive: React.PropTypes.bool
      view: React.PropTypes.oneOf(['refresh', 'spinner', 'circle-o-notch', 'cog'])
      target: React.PropTypes.object


   getDefaultProps: ->
      isShown: false
      isStatic: false
      isWithoutSubstrate: false
      isAdaptive: false
      view: 'refresh'
      textPosition: 'bottom'

   getInitialState: ->
      loaderOffset: {}
      loaderSize: @props.layoutSize or {}

   componentWillReceiveProps: (nextProps) ->
      nextTarget = nextProps.target
      isExistNextTarget = nextTarget? and !_.isEmpty(nextTarget)

      # Если задан сдедующий целевой узел - зададим параметры позиционирования для
      #  индикатора загрузки.
      if isExistNextTarget
         @_setLocationParams(nextTarget)

   render: ->
      loaderTextRow = @_getLoaderTextRow()
      textPosition = @props.textPosition
      textPositions = @_TEXT_POSITIONS
      isBottomPosition = textPosition is textPositions.bottom
      isTopPosition = textPosition is textPositions.top

      `(<table style={this._getComputedStyle()}
               title={this.props.title || this._LOADER_TITLE} >
            <tbody>
               {isTopPosition ? loaderTextRow : null}
               <tr>
                  <td style={this.styles.imageCell}>
                     <i style={this._getIconStyle()}
                        className={'fa fa-' + this.props.view + ' fa-spin'}></i>
                  </td>
               </tr>
               {isBottomPosition ? loaderTextRow : null}
            </tbody>
        </table>)`

   ###*
   * Функция формирования строки с текстом-пояснением. Формируется только если
   *  для компонента задано свойства текста-пояснения (@props.text).
   *
   * @return {React-element}
   ###
   _getLoaderTextRow: ->
      text = @props.text
      textSecondary = @props.textSecondary

      if text?
         `(
             <tr>
                <td>
                  <div style={this.styles.textContainer}>
                     <span>{text}</span>
                     <br/>
                     <span style={this.styles.textSecondaryContainer}>
                        {textSecondary}
                     </span>
                  </div>
                </td>
             </tr>
          )`

   ###*
   * Фукнция получения стиля для контейнера-заполнителя индикатора загрузки.
   *
   * @return {Object} - скомпанованный стиль
   ###
   _getComputedStyle: ->
      @computeStyles @styles.common,
                     @props.isStatic and @styles.staticPosition,
                     @props.isWithoutSubstrate and @styles.withoutSubstrate,
                     @props.isShown and @styles.shown,
                     @props.styleAddition,
                     @state.loaderOffset,
                     @state.loaderSize

   ###*
   * Фукнция получения стиля для иконки загрузчика. Если задан флаг адаптивности
   *  получает адаптированный размер шрифта.
   *
   * @return {Object} - скомпанованный стиль
   ###
   _getIconStyle: ->
      @computeStyles @styles.image,
                     @props.isAdaptive and @_getAdaptedFontSize()


   _getAdaptedFontSize: ->
      loaderSize = @state.loaderSize

      if loaderSize? and !_.isEmpty(loaderSize)
         width = loaderSize.width
         height = loaderSize.height
         minDimension = Math.min(width, height)
         minDefaultDimension = @_MIN_DEFAULT_FONT

         if minDimension < minDefaultDimension
            minDimension = minDefaultDimension

         fontSize: minDimension

   ###*
   * Функция определения позиционных параметров индикатора загрузчика относительно
   *  целевого объекта.
   *
   * @return
   ###
   _setLocationParams: (target) ->
      #$loader = $(ReactDOM.findDOMNode(this))
      # берем первый ближайщий DOM-элемент в нем будет загрузчик
      # $target = $(target.getDOMNode())
      # targetOffset = $target.offset()
      if target? and !_.isEmpty(target)
         targetClientRect = ReactDOM.findDOMNode(target).getBoundingClientRect()
         @setState
            loaderOffset:
               left: targetClientRect.left
               top: targetClientRect.top
            loaderSize:
               width: targetClientRect.width
               height: targetClientRect.height
         # loaderSize:
         #    width: target.getDOMNode().scrollWidth
         #    height: target.getDOMNode().scrollHeight


module.exports = AjaxLoader
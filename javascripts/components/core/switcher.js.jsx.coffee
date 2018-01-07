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

###* Компонент - Переключатель. Многопозиционный переключатель (две или более
*                позиции).
*
* @props
*     {Array<Object>} positions - набор позиций переключателя. Вид элемента:
*           {String} name         - имя позиции.
*           {String} caption      - заголовок позиции.
*           {String} icon         - иконка позиции.
*           {String} title        - выводимое пояснение на позиции.
*           {Boolean} isActivated - флаг "активированности" опции по-умолчанию.
*           {Boolean} isMain      - флаг-признак главной позиции (по-особому
*                                   выделяется весь компонент при активации позиции).
*     {Number} size             - размер переключателя (в пикселях). Если параметр не задан.
*                                 создается компонент со стандартными размерами.
*     {Number} activatedIndex   - индекс принудительно активированной позиции.
*     {Boolean} enableActivatedCaption  - флаг отображения заголовка активированной позиции.
*                                 По-умолчанию =false.
*     {Boolean} enableIcons     - флаг отображения иконок опций на позициях.
*                                 По-умолчанию =false.
*     {Function} onChange       - обработчик на изменение активированной позиции. Аргументы:
*                                 {Object} position - параметры активированной позиции.
*                                 {Number} activatedIndex - активированный индекс.
* @state
*     {Number} activatedPositionIndex - индекс активированной позиции.
###
Switcher = React.createClass

   # @const {Object} - возможные ключи параметров позиции.
   _POSITION_KEYS: keyMirror(
      name: null
      caption: null
      icon: null
      title: null
      isActivated: null
      isMain: null
   )

   # @const {Number} - величина приращения для ширины контейнера-заполнителя
   #                   ячейки позиции.
   _FILLER_WIDTH_INCREMENT: 2

   # @const {Number} - величина сокращения для шрифта иконки от общего размера компонента.
   _ICON_FONT_SIZE_DECREMENT: 7

   # @const {String} - префикс класса для иконок FontAwesome.
   _FA_ICON_PREFIX: 'fa fa-'

   mixins: [HelpersMixin]

   styles:
      container:
         borderRadius: 100
         borderStyle: 'solid'
         borderColor: _COLORS.hierarchy3
         borderWidth: 1
         backgroundColor: _COLORS.hierarchy4
         cursor: 'pointer'
         margin: 'auto'
      containerMainActivated:
         backgroundColor: _COLORS.main
      positionCellFiller:
         display: 'flex'
         alignItems: 'center'
         width: 18
         height: 16
      positionCell:
         verticalAlign: 'middle'
      tongue:
         display: 'flex'
         alignItems: 'center'
         width: 16
         height: 16
         borderRadius: 100
         borderStyle: 'solid'
         borderColor: _COLORS.hierarchy2
         borderWidth: 1
         backgroundColor: _COLORS.hierarchy3
         #background: "radial-gradient(circle, #{_COLORS.hierarchy4}, #{_COLORS.hierarchy3}, #{_COLORS.hierarchy2})"
      positionIcon:
         fontSize: 14
         position: 'relative'
         margin: 'auto'
      activatedPositionCaption:
         fontSize: 12
         color: _COLORS.dark
         whiteSpace: 'normal'
         lineHeight: '82%'
         textAlign: 'center'
         marginTop: 2

   PropTypes:
      positions: React.PropTypes.arrayOf(React.PropTypes.object).isRequired
      enableIcons: React.PropTypes.bool
      enableActivatedCaption: React.PropTypes.bool
      size: React.PropTypes.number
      activatedIndex: React.PropTypes.number

   getDefaultProps: ->
      enableIcons: false
      enableActivatedCaption: false

   getInitialState: ->
      activatedPositionIndex: @_getInitActivatedPositionIndex()

   render: ->
      `(
         <div>
            <table style={this._getContainerStyle()}
                   onClick={this._onClickTrigger}>
               <tbody>
                  <tr>{this._getPositionCells()}</tr>
               </tbody>
            </table>
            {this._getActivatedCaption()}
         </div>
      )`

   componentDidUpdate: (prevProps, prevState) ->
      currentActivatedIndex = @state.activatedPositionIndex
      prevActivatedIndex = prevState.activatedPositionIndex

      # Если индекс активированной позиции был изменен - вызываем обработчик на
      #  изменение активированной позиции(если был задан обработчик).
      if currentActivatedIndex isnt prevActivatedIndex
         onChangeHandler = @props.onChange

         if onChangeHandler?
            onChangeHandler @_getActivatedPosition(), currentActivatedIndex


   ###*
   * Функция подготовки ячеек таблицы с позициями переключателя. Формирует переменное
   *  кол-во элементов в зависимости от количества заданных позиций через параметр
   *  @props.positions.
   *
   * @return {Array<React-element>} - набор ячеек таблицы
   ###
   _getPositionCells: ->
      positions = @props.positions
      activatedPositionIndex = @state.activatedPositionIndex
      enableIcons = @props.enableIcons
      faIconPrefix = @_FA_ICON_PREFIX

      # Если заданы элементы позиций переключателя - создаем массив ячеек таблицы.
      if positions? and !_.isEmpty positions
         positions.map ((position, idx) ->
            positionIcon = position.icon

            # Если разрешено отображение иконок и для позиции задана иконка -
            #  формируем элемент с иконкой.
            iconContent =
               if enableIcons and positionIcon?
                  `(
                     <i style={this._getIconStyle()}
                        className={faIconPrefix + positionIcon}></i>
                   )`

            # Формируем содержимое ячейки позиции - если текущий индекс является
            #  активированным индексом - создаем индикатор активированной позиции
            #  с иконкой внутри. Иначе - присваиваем элементу иконки.
            cellContent =
               if idx is activatedPositionIndex
                  `(
                     <span style={this._getTongueStyle()}>{iconContent}</span>
                   )`
               else
                  iconContent

            # Формируем обработчик клика на ячейку с привязкой к обработчику
            #  индекса позиции.
            clickHandler = @_onClickPosition.bind(this, idx)

            `(
               <td key={idx}
                   style={this.styles.positionCell}
                   title={position.title}
                   onClick={clickHandler}
                   onMouseUp={clickHandler}
                   onDragStart={this._onTerminateDrag}
                  >
                  <div style={this._getFillerCell()}>
                     {cellContent}
                  </div>
               </td>
             )`
         ).bind(this)

   ###*
   * Функция формирования элемента для отображения заголовка текущей активированной
   *  позиции переключателя. Формирует заголовок, если задан флаг разрешения вывода
   *  заголовка и для активированной позиции задан заголовок.
   *
   * @return {React-element}
   ###
   _getActivatedCaption: ->
      return unless @props.enableActivatedCaption

      activatedPosition = @_getActivatedPosition()

      if activatedPosition? and _.has(activatedPosition, @_POSITION_KEYS.caption)
         `(
            <div style={this.styles.activatedPositionCaption}
                 title={activatedPosition.title} >
               {activatedPosition.caption}
            </div>
         )`

   ###*
   * Функция получения параметров текущей активированной позиции.
   *
   * @return {Object}
   ###
   _getActivatedPosition: ->
      positions = @props.positions
      activatedPositionIndex = @state.activatedPositionIndex

      if positions? and !_.isEmpty(positions) and activatedPositionIndex >= 0
         positions[activatedPositionIndex]

   ###*
   * Функция получения стиля для контейнера переключателя.
   *
   * @return {Object} - скомпанованный стиль.
   ###
   _getContainerStyle: ->
      @computeStyles @styles.container,
                     @_isMainActivated() and @styles.containerMainActivated

   ###*
   * Функция получения стиля для заполнителя ячейки позиции переключателя.
   *  Дополнительно создает переопределяющий стиль размеров на основе
   *  параметра @props.size компонента.
   *
   * @return {Object} - скомпанованный стиль.
   ###
   _getFillerCell: ->
      @computeStyles @styles.positionCellFiller,
                     @_getSizeStyle(true)

   ###*
   * Функция получения стиля для индикатора активированной позиции.
   *  Дополнительно создает переопределяющий стиль размеров на основе
   *  параметра @props.size компонента.
   *
   * @return {Object} - скомпанованный стиль.
   ###
   _getTongueStyle: ->
      @computeStyles @styles.tongue,
                     @_getSizeStyle(false)

   ###*
   * Функция получения стиля для иконки позиции.
   *  Дополнительно создает переопределяющий стиль размеров шрифта на основе
   *  параметра @props.size компонента.
   *
   * @return {Object} - скомпанованный стиль.
   ###
   _getIconStyle: ->
      size = @props.size

      @computeStyles @styles.positionIcon,
                     size? and {fontSize: size - @_ICON_FONT_SIZE_DECREMENT}

   ###*
   * Функция параметров размерного стиля элемента на основе
   *   параметра @props.size компонента.
   *
   * @param {Boolean} isFiller - флаг-признак того что стиль создается
   *                             для заполнителя(для заполнителя добавляется
   *                             доп. ширина).
   * @return {Object} - стиль с размерами.
   ###
   _getSizeStyle: (isFiller) ->
      size = @props.size

      if size?
         width =
            if isFiller
               size + @_FILLER_WIDTH_INCREMENT
            else
               size

         width: width
         height: size

   ###*
   * Функция получения начального активированного индекса для установки в состояния
   *  компонента. Если задан параметр индекса принудительно активируемой позиции
   *  (@props.activatedIndex) - возвращает её, иначе - производит поиск среди элементов
   *  @props.positions и возвращает индекс первой для которой задан флаг isActivated.
   *
   * @return {Number}.
   ###
   _getInitActivatedPositionIndex: ->
      positions = @props.positions
      activatedIndex = @props.activatedIndex

      if activatedIndex?
         activatedIndex
      else
         findedActivatedIndex =
            if positions? and !_.isEmpty positions
               _.findIndex(positions, @_POSITION_KEYS.isMain)

         if findedActivatedIndex >= 0
            findedActivatedIndex
         else
            0

   ###*
   * Функция предикат для определения является ли активированная позиция главной.
   *  (по-особому подсвечивается фон компонента).
   *
   * @return {Boolean}
   ###
   _isMainActivated: ->
      activatedPosition = @_getActivatedPosition()

      if activatedPosition?
         activatedPosition.isMain
      else
         false

   ###*
   * Обработчик на клик по таблице-контейнеру позиционного переключателя. Выполняет
   *  изменение текущего активированного индекса - или инкрементно или сбрасывает в 0.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickTrigger: (event) ->
      activatedPositionIndex = @state.activatedPositionIndex
      positions = @props.positions

      if positions? and !_.isEmpty positions
         positionsCount = positions.length

         newActivatedPositionIndex =
            if activatedPositionIndex is -1 or
            (activatedPositionIndex + 1) is positionsCount
               0
            else
               ++activatedPositionIndex

         @setState activatedPositionIndex: newActivatedPositionIndex

   ###*
   * Обработчик на клик по ячейке конкретной позиции. Устанавливает текущий
   *  активированный индекс в состоянии компонента.
   *
   * @param {Number} positionIndex - индекс позиции по которой произошел клик.
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickPosition: (positionIndex, event) ->
      event.stopPropagation()

      if positionIndex?
         @setState activatedPositionIndex: positionIndex

   ###*
   * Обработчик на начало операции Drag-and-Drop в контейнере содержимого позиции.
   *
   * @param {Number} positionIndex - индекс позиции по которой произошел клик.
   * @param {Object} event - объект события.
   * @return
   ###
   _onTerminateDrag: (event) ->
      event.preventDefault()
      return false

module.exports = Switcher
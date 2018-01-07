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

###* Зависимости: компоненты
* AllocationContent        - контейнер с выделением подстроки.
###
AllocationContent = require('components/core/allocation_content')

###* Константы
* _COLORS               - цвета
* _COMMON_PADDING       - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius

###* Компонент - Список.
*
* @props
*     {Array<Object>} items  - коллекция параметров для элементов списка. Вид элемента:
*                              {String} caption   - надпись элемента.
*                              {String} title     - выводимая подсказка на элементе.
*                              {String} icon      - иконка выводимая перед надписью (FontAwesome).
*                              {Boolean} isHidden - флаг скрываемого элемента.
*     {String} title         - всплывающее пояснение к компоненту.
*     {Number} activateIndex - индекс изначально активированного элемента.
*  {String} searchExpression - поисковое выражение. Если параметр задан, то скрывает
*                              все пункты не подходящие под это выражение(по параметру caption).
*     {Object} styleAddition - доп. стили для элемента. Вид:
*                              {Object} common - доп. стили для всего списка.
*                              {Object} item   - доп. стили для элемента списка. Вид:
*                                   {Object} common - доп. стиль непосредственно для элемента.
*                                   {Object} icon   - доп. стиль для иконки.
*{Boolean} enableMarkActivated - флаг разрешения пометки выбранного элемента. По-умолчанию = false
*     {Function} onSelect   - обработчик выбора элемента. Возникает при клике на
*                             элементе или управляющим выбором с клавиатуры (клавиша "Enter").
*                             Аргументы:
*                              {Object} item - параметры элемента.
*     {Function} onActivate - обработчик активации элемента.  Событие возникает при выделении
*                             элемента в списке при помощи клика или выбором управляющим вводом
*                             с клавиатуры (клавиши "вниз"/"вверх"). Аргументы:
*                              {Object} item - параметры элемента.
* @state
*     {Number} activatedIndex - индекс активированного элемента.
###
List = React.createClass

   # @const {Object} - коды нажимаемых клавиш.
   _KEY_CODES:
      enter: 13
      left: 37
      up: 38
      right: 39
      down: 40

   # @const {Object} - наименования используемых ссылок на элементы.
   _REFS: keyMirror(
      item: null
   )

   # @const {Object} - используемые символы.
   _CHARS:
      underscore: '_'

   mixins: [HelpersMixin]

   styles:
      common:
         listStyleType: 'none'
         margin: 0
         padding: 0

   PropTypes:
      items: React.PropTypes.arrayOf(React.PropTypes.object)
      title: React.PropTypes.string
      styleAddition: React.PropTypes.object
      enableMarkActivated: React.PropTypes.bool
      onSelect: React.PropTypes.func

   getDefaultProps: ->
      items: []
      enableMarkActivated: false

   getInitialState: ->
      activatedIndex: @props.activateIndex

   componentWillUpdate: (nextProps, nextState) ->
      nextActivateIndex = nextState.activatedIndex

      # Если индекс активированного элемента изменился - вызовем обработчик на
      #  активацию элемента.
      if nextActivateIndex isnt @state.activatedIndex
         onActivateHandler = nextProps.onActivate

         if onActivateHandler?
            onActivateHandler nextProps.items[nextActivateIndex]

   render: ->
      `(
          <ul style={this._getStyle()}
              title={this.props.title}
              onKeyDown={this._onKeyDown}
              tabIndex={0} >
             {this._getItems()}
          </ul>
       )`

   ###*
   * Функция получения набора компонентов элементов списка.
   *
   * @return {Array<React-elements>}
   ###
   _getItems: ->
      items = @props.items
      styleAddition = @props.styleAddition
      styleAdditionItem = styleAddition.item if styleAddition?
      activatedIndex = @state.activatedIndex
      enableMarkActivated = @props.enableMarkActivated
      itemCollection = []
      searchExpression = @props.searchExpression

      for item, idx in items
         itemCaption = item.caption

         if @isMatchedExpression(itemCaption, searchExpression)
            isActive = idx is activatedIndex

            itemCollection.push(
               `(
                   <ListItem key={idx}
                             index={idx}
                             ref={this._getItemRefName(idx)}
                             item={item}
                             styleAddition={styleAdditionItem}
                             isActive={isActive}
                             enableMarkActivated={enableMarkActivated}
                             searchExpression={this.props.searchExpression}
                             onClick={this._onClick}
                           />
                )`
            )

      itemCollection

   ###*
   * Функция формирования наименования ссылки на элемент списка.
   *
   * @param {Number} itemIndex - индкес элемента в списке.
   * @return {String}
   ###
   _getItemRefName: (itemIndex) ->
      [@_REFS.item, itemIndex].join @_CHARS.underscore

   ###*
   * Функция получения стилей для списка.
   *
   * @return {Object}
   ###
   _getStyle: ->
      styleAddition = @props.styleAddition
      styleAdditionCommon = styleAddition.common if styleAddition?

      @computeStyles @styles.common,
                     styleAdditionCommon

   ###*
   * Обработчик клика на элементе списка.
   *
   * @param {Object} item  - параметры элемента.
   * @param {Object} index - индекс элемента.
   * @return {Object}
   ###
   _onClick: (item, index) ->
      @_selectHandling(item)
      @setState activatedIndex: index

   ###*
   * Обработчик нажатия клавиш клавиатуры.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onKeyDown: (event) ->
      eventKeyCode = event.keyCode
      keyCodes = @_KEY_CODES
      keyUpCode = keyCodes.up
      keyDownCode = keyCodes.down
      keyEnterCode = keyCodes.enter
      activatedIndex = @state.activatedIndex
      items = @props.items
      itemsCount = items.length
      isVerticalDirectKey = _.includes([keyUpCode, keyDownCode], eventKeyCode)
      isEnterKey = eventKeyCode is keyCodes.enter

      if isVerticalDirectKey
         newActivatedIndex =
            if activatedIndex?
               switch eventKeyCode
                  when keyCodes.down
                     if activatedIndex < (itemsCount - 1)
                        activatedIndex + 1
                     else
                        activatedIndex
                  when keyCodes.up
                     if activatedIndex > 0
                        activatedIndex - 1
                     else
                        activatedIndex
            else
               0

         if newActivatedIndex isnt activatedIndex
            @setState activatedIndex: newActivatedIndex

            activatedItemNode =
               ReactDOM.findDOMNode(@refs[@_getItemRefName(newActivatedIndex)])
            listContainerNode = ReactDOM.findDOMNode(this).parentElement
            event.preventDefault()
            listContainerNode.scrollTop = activatedItemNode.offsetTop

      if isEnterKey and activatedIndex?
         @_selectHandling(items[activatedIndex])

   ###*
   * Функция запуска обработчика на выбор элемента из списка(если задан) с
   *  передачей ему выбранного элемента.
   *
   * @param {Object} item  - параметры элемента.
   * @return {Object}
   ###
   _selectHandling: (item, index) ->
      onSelectHandler = @props.onSelect
      onSelectHandler(item) if onSelectHandler?

###* Компонент - элемент списка. Часть компонента List.
*
* @props
*     {Object} item          - параметры элемента списка.
*     {Number} index         - индекс элемента в наборе.
*  {String} searchExpression - поисковое выражение.
*     {Object} styleAddition - доп. стили для элемента. Вид
*                             {Object} common - доп. стиль непосредственно для элемента.
*                             {Object} icon   - доп. стиль для иконки.
*     {Boolean} isActive     - флаг активного элемента (выбран).
* {Boolean} enableMarkActivated - флаг разрешения отметки активированных элементов
*                                 в списке (пометка маркером).
*     {Function} onClick     - обработчик клика на элементе.
###
ListItem = React.createClass

   # @const {String} - префикс класса для иконок FontAwesome.
   _FA_ICONS_PREFIX: 'fa fa-'

   mixins: [HelpersMixin, AnimateMixin, AnimationsMixin.highlightBack]

   styles:
      common:
         backgroundColor: _COLORS.light
         cursor: "pointer"
         color: _COLORS.hierarchy2
         padding: _COMMON_PADDING
         textAlign: 'left'
      activated:
         borderLeftWidth: 2
         borderLeftStyle: 'solid'
         borderLeftColor: _COLORS.main
      hidden:
         display: 'none'
      highlightBack:
         backgroundColor: _COLORS.highlight2
         color: _COLORS.dark
      itemIcon:
         paddingLeft: _COMMON_PADDING
         paddingRight: _COMMON_PADDING

   render: ->
      `(
         <li style={this._getStyle()}
             title={this.props.item.title}
             onMouseLeave={this._onMouseLeave}
             onMouseEnter={this._onMouseEnter}
             onClick={this._onClick}
            >
            {this._getIcon()}
            <AllocationContent content={this.props.item.caption}
                               expression={this.props.searchExpression} />
         </li>
      )`

   _getIcon: ->
      itemIcon = @props.item.icon
      styleAddition = @props.styleAddition

      if itemIcon?
         iconStyle = @computeStyles @styles.itemIcon,
                     styleAddition? and styleAddition.icon

         `(
            <i className={this._FA_ICONS_PREFIX + itemIcon}
               style={iconStyle}
              />
          )`

   ###*
   * Функция получения стилей элемента
   *
   * @return {Object} - скомпанованный стиль компонента.
   ###
   _getStyle: ->
      @computeStyles @_getStaticStyle(),
                     @_getAnimateStyle()

   ###*
   * Функция получения статичныз стилей элемента(без анимации).
   *
   * @return {Object} - скомпанованный стиль компонента.
   ###
   _getStaticStyle: ->
      isHidden = @props.item.isHidden
      styleAddition = @props.styleAddition
      isNeedActivatedStyle = @props.isActive and @props.enableMarkActivated

      @computeStyles @styles.common,
                     isNeedActivatedStyle and @styles.activated,
                     isHidden and @styles.hidden,
                     styleAddition? and styleAddition.common

   ###*
   * Обработчик ухода курсора мыши с элемента. Запускает анимацию выхода.
   *
   * @return
   ###
   _onMouseLeave: ->
      @_highlightBackOut(null, @_getStaticStyle())

   ###*
   * Обработчик на вход курсора мыши на объект. Запускает входную анимацию.
   *
   * @return
   ###
   _onMouseEnter: ->
      @_highlightBackIn(null, @_getStaticStyle())

   ###*
   * Обработчик клика на элементе. Вызывает обработчик клика, заданный через
   *  свойства с возвратом параметров элемента.
   *
   * @return
   ###
   _onClick: ->
      onClickHandler = @props.onClick

      @props.onClick(@props.item, @props.index) if onClickHandler?

module.exports = List
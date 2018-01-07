###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* HelpersMixin     - функции-хэлперы для компонентов.
* keymirror        - модуль для генерации "зеркального" хэша.
* lodash           - модуль служебных операций.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* Button            - кнопка.
###
Button = require('components/core/button')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius

###* Компонент: "хлебный" навигатор.
*
* @props :
*     {String} splitter      - строка-разделитель для элементов (по-умолчанию
*                              используется "\").
*     {Array<String, Object>} items - набор элементов. Элементы набора представляют
*                                     собой либо просто строку, либо объект с
*                                     параметрами в которых содержатся элементы:
*                                      {String} caption - выводимая надпись элемента.
*                                      {String} title   - всплывающее пояснение.
*     {Object} styleAddition - дополнительные стили. Вид:
*          {Object} common      - общий стиль для контейнера.
*          {Object} item        - стиль для элемента навигатора.
*          {Object} splitter    - стиль для разделителя.
*          {Object} clearButton - стиль для кнопки возврата в корень.
*      {Boolean} enableHome  - флаг разрешения добавления кнопки возврата в корень.
*                              По-умолчанию = false.
*     {Function} onClickItem - обработчик клика на элемент.
*    {Function} onClickHome  - обработчик клика на кнопку возврата в корень.
###
BreadNavigator = React.createClass
   # @const {Object} - используемые ключи для элемента представленного в виде хэша.
   _ITEM_KEYS: keyMirror(
      caption: null,
      title: null,
      icon: null
   )

   # @const {Object} - параметры для кнопки возврата в корень всех элементов.
   _HOME_BUTTON_DEFAULT_PARAMS:
      isLink: true
      icon: 'home'
      title: 'Вернуться в корень'
      key: 'home'

   # @const {Object} - параметры разделителя.
   _SPLITTER_PARAMS:
      splitter: '\\'
      keyPrefix: 'splitter'

   styles:
      common:
         display: 'inline-block'
      splitter:
         color: _COLORS.hierarchy3
         paddingLeft: 2
         paddingRight: 3

   propTypes:
      items: React.PropTypes.array
      styleAddition: React.PropTypes.object
      splitter: React.PropTypes.string
      enableHome: React.PropTypes.bool
      onClickItem: React.PropTypes.func
      onClickClear: React.PropTypes.func

   mixins: [HelpersMixin]

   getDefaultProps: ->
      enableHome: false

   render: ->
      `(
         <nav style={this._getStyle()}>
            {this._getNavigatorItems()}
         </nav>
       )`

   ###*
   * Функция получения набора навигационных элементов-кнопок с разделителями.
   *
   * @return {Array<React-DOM-Node>} - навигационные элементы
   ###
   _getNavigatorItems: ->
      items = @props.items
      itemKeys = @_ITEM_KEYS
      captionKey = itemKeys.caption
      titleKey = itemKeys.title
      iconKey = itemKeys.icon
      splitterParams = @_SPLITTER_PARAMS
      splitterExpr = @props.splitter or splitterParams.splitter
      styleAddition = @props.styleAddition
      enableHome = @props.enableHome
      navItems = []

      # Если заданы параметры доп. стилей - считаем доп. стили для элемента и
      #  и разделителем.
      if styleAddition?
         styleAdditionItem = styleAddition.item
         styleAdditionSplitter = styleAddition.splitter
         styleAdditionClearButton = styleAddition.clearButton

      styleSplitter = @computeStyles @styles.splitter,
                                     styleAdditionSplitter

      navItems.push @_getHomeButton(styleAdditionClearButton) if enableHome

      for item, idx in items

         if _.isPlainObject(item)
            itemCaption = item[captionKey] if _.has(item, captionKey)
            itemTitle = item[titleKey] if _.has(item, titleKey)
            itemIcon = item[iconKey] if _.has(item, iconKey)
         else
            itemCaption = item

         navItems.push(
            `(
               <Button key={idx}
                       isLink={true}
                       isWithoutPadding={true}
                       styleAddition={styleAdditionItem}
                       caption={itemCaption}
                       title={itemTitle}
                       icon={itemIcon}
                       value={item}
                       onClick={this.props.onClickItem} />
             )`
         )

         if idx < items.length - 1
            navItems.push(
               `(
                   <span key={splitterParams.keyPrefix + idx}
                         style={styleSplitter}>
                     {splitterExpr}
                   </span>
                )`
            )

      navItems

   ###*
   * Функция получения кнопки возврата в корень. Формирует кнопку с параметрами
   *  по-умолчанию + параметрами, заданными через свойства.
   *
   * @param {Objec} styleAddition - доп. стиль для кнопки.
   * @return {React-Element}
   ###
   _getHomeButton: (styleAddition) ->
      homeButtonDefaultParams = @_HOME_BUTTON_DEFAULT_PARAMS
      homeParams = @props.homeParams
      buttonParams = @mergeObjects(homeButtonDefaultParams, homeParams)

      `(
         <Button {...buttonParams}
                 styleAddition={styleAddition}
                 onClick={this.props.onClickHome}
               />
       )`

   ###*
   * Функция получения стиля контейнера навигатора.
   *
   * @return {Object}
   ###
   _getStyle:  ->
      styleAddition = @props.styleAddition
      commonStyleAddition = if styleAddition?
                               styleAddition.common

      @computeStyles @styles.common,
                     commonStyleAddition

module.exports = BreadNavigator
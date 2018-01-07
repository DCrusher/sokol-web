###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* HelpersMixin     - функции-хэлперы для компонентов.
* AnimationsMixin  - набор анимаций для компонентов.
* AnimateMixin     - библиотека добавляющая компонентам
*                    возможность исользования анимации.
* keyMirror - модуль для генерации "зеркальных хэшей".
* lodash                 - модуль служебных функций.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
AnimationsMixin = require('../mixins/animations')
AnimateMixin = require('react-animate')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* Button            - кнопка.
* ArbitraryArea     - произвольная область.
* Accordion         - контейнер-аккордеон.
* Input             - поле ввода.
* AllocationContent - контент с выделением.
* List              - список.
###
Button = require('components/core/button')
ArbitraryArea = require('components/core/arbitrary_area')
Accordion = require('components/core/accordion')
Input = require('components/core/input')
AllocationContent = require('components/core/allocation_content')
List = require('components/core/list')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
* _COMMON_BORDER_RADIUS - значение скругления углов, alias - _CBR
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius
_CBR = [_COMMON_BORDER_RADIUS, 'px'].join('')
_ICON_CONTAINER_WIDTH = constants.iconContainerWidth

###* Компонент: Выпадающий список
* @props:
*     {Object, Array} list   - коллекция со списком элементов. Коллекция элементов
*                              может быть задана как простой коллекцией строк, коллекцией
*                              объектов с параметрами или хэшем(ассоциативным массивом) с
*                              параметрами. При задании элемента в виде хэша (параметры)
*                              ожидаются следующие параметры элемента:
*                                {String} caption           - выводимая надпись в списке.
*                                {String, Object ...} value - значение элемента.
*                                {String} title             - всплывающее пояснение.
*    {Object} additionalList - хэш дополнительного списка.
* {Object} styleAddition     - объект доп. свойств стилей для элементов компонента.
*                              Вид:
*           {Object} selector - хэш дополнительных стилей для селектора. Вид:
*              {Object} captionContainer - доп. стили контейнера заголовка (при выбранном значении).
*              {Object} common   - доп. стили, применяемые всегда.
*              {Object} selected - доп. стили, применяемые если выбран элемент.
*              {Object} empty    - доп. стили, применяемые при отсутсвующем выбранном элементе.
*           {Object} list     - хэш дополнительных стилей для всего списка.
*           {Object} item     - хэш дополнительных стилей для элемента списка.
*     {String} title         - всплывающее пояснение. Если в компоненте выбран элемент
*                              и для этого элемента определен параметр title -
*                              этот параметр переопределяет текущий (т.е. выводится
*                              подсказка выбранного элемента).
*     {String} name          - имя поля.
*     {Number} tabIndex      - индекс таба для задания последовательности перехода
*                              по клавише "Tab".
*     {Object} initItem      - хэш параметров выбранного значения по-умолчанию. Вид:
*       {String, Number} key - ключ выбранного элемента.
*     {String, Object} value  - выбранное значение.
*     {String} emptyValue    - надпись при пустом(не выбранном) значении.
*     {String} clearTitle    - выводимое пояснение для кнопки очистки.
* {String} searchPlaceholder - заполнитель поля поиска.
*     {Object} clearButtonParams - параметры кнопки очистки.
*     {Boolean} isComplex    - флаг сложного выпадающего списка (список не прилегает к
*                              селектору). Если задан false - список элементов будет простым
*                              (плоский список, плавно переходящий из селектора в список).
*     {Boolean} isReadOnly   - флаг только для считывания - поле заблокировано для изменения.
*                              По-умолчанию = false.
*     {Boolean} isAdaptive   - флаг адаптивности (для произвольных областей компонента).
*                              По-умолчанию = false.
*    {Boolean} isFatSelector - флаг высокого селектора (высота аналогична кнопке).
*                              По-умолчанию = false
*    {Boolean} isLinkSelector- флаг селектора-ссылки.
*                              По-умолчанию = false
*     {Boolean} enableClear  - флаг сброса значения.
*                              По-умолчанию = false.
*     {Boolean} enableSearch - флаг наличия поиска в списке (для сложного
*                              включен по-умолчанию).
*     {Function} onClick     - обработчик события клика на селекторе. Аргументы:
*                              {Object} event - объект события.
*     {Function} onSelect    - обработчик события на выбор значения. Аргументы:
*                              {Object} value - выбранное значение.
*     {Function} onClear     - обработчик на сброс выбранного значения.
* @state
*     {Boolean} isListHide   - флаг скрыт/показан список
*     {Number} dropDownWidth - ширина селектора компонента
*                             (расчитывается на основе ширины списка)
*     {Object, String} selectedItem - выбранный элемент.
* @functions:
*     getSelectedKey   - функция возврата ключа выбранного элемента.
*     getSelectedValue - функция возврата значения выбранного элемента.
*     getSelectedItem  - функция возврата выбранного элемента.
###
DropDown = React.createClass
   # @const {String} - тип скрытого поля.
   _HIDDEN_FIELD_TYPE: 'hidden'

   # @const {Object} - набор ключей параметров выбранного элемента.
   _ITEM_KEYS: keyMirror(
      key: null
      value: null
      caption: null
      addition: null
   )

   # @const {Object} - используемые наименования ссылок
   _REFS: keyMirror(
      selector: null
      list: null
   )

   ###*
   * АХТУНГ: грязный хак, для хранения наибольшей ширины селектора и списка -
   *         через state не получилось сохранять значение наибольшей ширины,
   *         (он там всегда 0) когда срабатывают свойства willMount на дочерних
   *         компонентах (не понял в чем тут дело, может компонент организован
   *         неправильно)
   * @param {Number} - ширина компонента
   ###
   _width: 0

   styles:
      common:
         display: 'inline-block'
         whiteSpace: 'nowrap'

   # требуемые типы свойств
   propTypes:
      list: React.PropTypes.oneOfType([
         React.PropTypes.object
         React.PropTypes.array ])
      styleAddition: React.PropTypes.object
      additionalItems: React.PropTypes.object
      title: React.PropTypes.string
      name: React.PropTypes.string
      clearTitle: React.PropTypes.string
      searchPlaceholder: React.PropTypes.string
      tabIndex: React.PropTypes.number
      onClick: React.PropTypes.func
      onSelect: React.PropTypes.func
      isComplex: React.PropTypes.bool
      isReadOnly: React.PropTypes.bool
      isAdaptive: React.PropTypes.bool
      isFatSelector: React.PropTypes.bool
      isLinkSelector: React.PropTypes.bool
      enableClear: React.PropTypes.bool
      enableSearch: React.PropTypes.bool

   getDefaultProps: ->
      isReadOnly: false
      isAdaptive: false
      isFatSelector: false
      isLinkSelector: false
      enableClear: false
      styleAddition: {}

   getInitialState: ->
      isListHide: true
      dropDownWidth: 0
      selectedItem: @_getInitSelectedItem()

   componentWillReceiveProps: (nextProps) ->
      nextInitItem = nextProps.initItem
      nextList = nextProps.list
      nextAdditionalList = nextProps.additionalList
      isResetCurrent = @props.isReset
      isResetNext = @props.isReset

      # Если следующий выбранный элемент отличается от текущего - получим
      #  значение выбранного элемента и установим в состояние компонента.
      if !@_isItemsSame(@props.initItem, nextInitItem)
         @setState
            selectedItem: @_getInitSelectedItem(nextInitItem,
                                                nextList,
                                                nextAdditionalList)
      # else if isResetNext and !isResetCurrent
      #    @setState selectedItem: @_getInitSelectedItem(nextInitItem,
      #                                                  nextList,
      #                                                  nextAdditionalList)

   render: ->
      styleAddition = @props.styleAddition
      styleAdditionSelector = styleAddition.selector if styleAddition?
      selectedItem = @state.selectedItem

      `(
         <span style={this.styles.common}>
            <DropDownSelector ref={this._REFS.selector}
                              componentWidth={this.state.dropDownWidth}
                              title={this.props.title}
                              selectedItem={selectedItem}
                              styleAddition={styleAdditionSelector}
                              tabIndex={this.props.tabIndex}
                              emptyValue={this.props.emptyValue}
                              clearButtonParams={this.props.clearButtonParams}
                              clearTitle={this.props.clearTitle}
                              isComplex={this.props.isComplex}
                              isListHide={this.state.isListHide}
                              isReadOnly={this.props.isReadOnly}
                              isFat={this.props.isFatSelector}
                              isLinkView={this.props.isLinkSelector}
                              enableClear={this.props.enableClear}
                              onSelectorReceiveWidth={this._onElementReceiveWidth}
                              onDropDown={this._onDropDown}
                              onClear={this._onClear}
                           />
            {this._getList()}
            {this._getSelectedItemHiddenInput()}
         </span>
       )`

   ###*
   * Функция получения списка элементов. Создает список элементов только
   *  если список элементов был задан через свойства компонента.
   *
   * @return {React-element}
   ###
   _getList: ->
      if @_isHasListItems()
         `(
            <DropDownList ref={this._REFS.list}
                          items={this.props.list}
                          additionalItems={this.props.additionalList}
                          styleAddition={this.props.styleAddition}
                          itemKeys={this._ITEM_KEYS}
                          target={this}
                          componentWidth={this.state.dropDownWidth}
                          searchPlaceholder={this.props.searchPlaceholder}
                          isHidden={this.state.isListHide}
                          isComplex={this.props.isComplex}
                          isAdaptive={this.props.isAdaptive}
                          enableSearch={this.props.enableSearch}
                          selectedItem={this.state.selectedItem}
                          onSelect={this._onSelectItem}
                          onListReceiveWidth={this._onElementReceiveWidth}
                          onHideList={this._onHideList} />
         )`

   ###*
   * Функция возврата выбранного ключа.
   *
   * @return {String, Number} - выбранный ключ.
   ###
   getSelectedKey: ->
      @state.selectedItem.key

   ###*
   * Функция возврата выбранного ключа.
   *
   * @return {String, Number} - выбранное значение.
   ###
   getSelectedValue: ->
      @state.selectedItem.value

   ###*
   * Функция возврата выбранного элемента.
   *
   * @return {Object, String, Number} - выбранный ключ.
   ###
   getSelectedItem: ->
      @state.selectedItem

   ###*
   * Функция создания скрытого поля ввода со значением выбранного
   *  элемента.
   *
   * @return {React-element}
   ###
   _getSelectedItemHiddenInput: ->
      selectedItem = @state.selectedItem

      if selectedItem?
         `(
            <input type={this._HIDDEN_FIELD_TYPE}
                   name={this.props.name}
                   value={this.state.selectedItem.key}
                 />
         )`

   ###* TODO: некорректная логика - пересмотреть и переделать.
   * Функция получения начального выбранного элемента. Проверяет если был задан
   *  ключ выбираемого значения и значения - просто возвращает их, иначе произодит
   *  поиск элемента из списка по ключу или значению.
   *
   * @param {Object} initItem     - элемент выбранный по-умолчанию.
   * @param {Array, Object} list  - список элементов (если не берется из @props).
   * @param {Object} additionalList - инициализационный список значений (если не
   *                                берется из @props).
   * @return {Object} - параметры выбранного элемента.
   ###
   _getInitSelectedItem: (initItem, list, additionalList) ->
      initItem ||= @props.initItem

      return unless initItem?

      list ||= @props.list
      additionalList ||= @props.additionalList
      initItemKeys = @_ITEM_KEYS
      keyKey = initItemKeys.key
      valueKey = initItemKeys.value
      captionKey = initItemKeys.caption
      additionKey = initItemKeys.addition
      isInitItemFull = _.has(initItem, keyKey) and _.has(initItem, valueKey)
      isListArray = _.isArray(list)

      ###*
      * Функция поиска ключа из списка по значению. Перебирает
      *  список и ищет совпадание значения.
      *
      * @param {Array, Object} list - список в котором будет происходить поиск.
      * @param {String, Number, Object} itemValue - значение, искомое в списке.
      * @return {String, Number}
      ###
      getKeyByValue = ((list, itemValue) ->
         isListArray = _.isArray(list)
         isListHash = _.isPlainObject(list)

         if isListArray
            for item, idx in list
               if @_isItemsSame(item, itemValue)
                  return idx
         else if isListHash
            for itemName, item of list
               if @_isItemsSame(item, itemValue)
                  return itemName
      ).bind(this)

      ###*
      * Функция-предикат для опредения являются ли родительские элементы секции
      *  одинаковыми.
      *
      * @param {Array} parentsLeft - наименования родительских элементов слева.
      * @param {Array} parentsRight - наименования родительских элементов справа.
      * @return {Boolean}
      ###
      isParentsEqual = ((parentsLeft, parentsRight) ->
         parentsLeftString = parentsLeft.join() if parentsLeft
         parentsRightString = parentsRight.join() if parentsRight

         parentsLeftString is parentsRightString
      ).bind(this)

      if isListArray
         caption: initItem
         value: initItem
      else if isInitItemFull
         initItem
      else
         itemKey = initItem[keyKey]
         itemValue = initItem[valueKey]
         itemCaption = initItem[captionKey]
         itemAddition = initItem[additionKey]

         # Ищем параметры выбранного элемента в основном списке.
         if list?
            if itemKey?
               itemValue = list[itemKey]
            else if itemValue?
               itemKey = getKeyByValue(list, itemValue)

         isAllFound = itemKey? and itemValue?

         # Если не все параметры были найдены и задан дополнительный список - ищем
         #  в нем.
         if !isAllFound and additionalList?

            # Если заданы параметры секции, считаем имя секции и родительские элементы.
            if itemAddition? and itemAddition.sectionParams?
               sectionParams = itemAddition.sectionParams
               sectionName = sectionParams.name
               sectionParents = sectionParams.parents

            for section in additionalList
               items = section.items
               isSectionNameCorrect = section.name is sectionName
               isParentsSame = isParentsEqual(section.parents, sectionParents)

               # Определяем является ли параметры секции доп. элементов корректными:
               #  Если для начального элемента заданы имя секции и родительские
               #  элементы - определяем корректность секции в зависимости от них.
               isRequiredSection =
                  if sectionName?
                     if sectionParents?
                        isSectionNameCorrect and isParentsSame
                     else
                        isSectionNameCorrect
                  else
                     if sectionParents?
                        isParentsSame

               if isRequiredSection

                  if itemKey?
                     itemValue = items[itemKey]
                  else if itemValue?
                     itemKey = getKeyByValue(items, itemValue)

                  break

         key: itemKey
         value: itemValue
         caption: itemCaption
         addition: itemAddition
         # sectionName: sectionName
         # parents: sectionParents

   ###*
   * Функция установки ширины компонента.
   *
   * @param {Number} width - ширина
   * @return
   ###
   _setComponentWidth: (width) ->
      # новая ширина дополняется шириной контейнера с иконкой и отступами
      newWidth = (_COMMON_PADDING + 2) * 2 +
                  width + _ICON_CONTAINER_WIDTH

      return unless @isMounted()

      # если ширина компонента меньше, полученной - установим новую ширину
      if @_width < newWidth
         @_width = newWidth
         @setState dropDownWidth: newWidth

   ###*
   * Функция-предикат для определения различаются ли два элемента списка.
   *
   * @param {Object, String} firstItem - первый элемент.
   * @param {Object, String} secondItem - второй элемент.
   * @return {Boolean}
   ###
   _isItemsSame: (firstItem, secondItem)->
      _.isEqual(firstItem, secondItem)

   ###*
   * Функция-предикат для определения содержит ли параметр списка элементы.
   *
   * @return {Boolean}
   ###
   _isHasListItems: ->
      !_.isEmpty(@props.list)

   ###*
   * Обработчик на скрытие списка элементов.
   *
   * @return
   ###
   _onHideList: ->
      @refs[@_REFS.selector].focus()

      @setState isListHide: true

   ###*
   * Обработчик на отображение списка.
   *
   * @return
   ###
   _onDropDown: (value, event) ->
      onClickHandler= @props.onClick

      onClickHandler(event) if onClickHandler?

      @setState isListHide: !@state.isListHide

   ###*
   * Обработчик на сброс выбранного элемента.
   *
   * @return
   ###
   _onClear: ->
      onClearHandler = @props.onClear
      onClearHandler() if onClearHandler

      @setState selectedItem: {}

   ###*
   * Обработчик на выбор элемента из списка
   *
   * @param {Object} item - хэш с параметрами выбранного пункта
   * @return
   ###
   _onSelectItem: (item) ->
      @setState
         isListHide: true
         selectedItem: @_prepareItemParamsSpecifyForList(item)

      onSelectHandler = @props.onSelect
      # Пробосим данные на обработчик, переданный через параметры.
      onSelectHandler(item) if onSelectHandler?

   ###*
   * Обработчик, вызываемый после монтирования селектора выпадающего списка.
   *  Возвращает ширину селектора
   *
   * @param {Number} width - ширина селектора
   * @return
   ###
   _onElementReceiveWidth: (width) ->
      @_setComponentWidth width

   ###*
   * Метод подготовки параметров элемента для сохранения в состоянии selectedItem
   *  компонента. Если список задан в виде хэша и в выбранном элементе нет параметра
   *  key, но есть параметр value - добавляет параметр key(и наоборот). Метод сделан
   *  для обратной совместимости со старым подходом.
   *
   * @param {Object} itemParams - параметры элемента.
   * @return {Object}
   ###
   _prepareItemParamsSpecifyForList: (itemParams) ->
      itemKeys = @_ITEM_KEYS
      keyKey = itemKeys.key
      valueKey = itemKeys.value

      if _.isPlainObject(@props.list)
         isItemHasKey = _.has(itemParams, itemKeys.key)
         isItemHasValue = _.has(itemParams, itemKeys.value)

         if !isItemHasValue or !isItemHasKey
            if isItemHasValue and !isItemHasKey
               itemParams.key = itemParams.value
            if isItemHasKey and !isItemHasValue
               itemParams.value = itemParams.key


      itemParams


###* Компонент: Селектор выпадающего списка. Часть компонента DropDown.
*               Представляет собой кнопку.
*
* @props:
*     {Object} selectedItem         - параметры вывбранного элемента.
*     {Object} styleAddition        - доп. стили для кнопки-селектора.
*     {Object} clearButtonParams    - параметры кнопки очистки.
*     {Number} componentWidth       - ширина компонента.
*     {String} caption              - надпись на селекторе.
*     {String} title                - всплывающее пояснение.
*     {String} emptyValue           - надпись при пустом(не выбранном) значении.
*     {String} clearTitle           - всплывающее пояснение для кнопки очистки.
*     {Number} tabIndex             - индекс таба для задания последовательности перехода
*                                     по клавише "Tab".
*     {Boolean} isListHide          - флаг скрыт/показан список элементов.
*     {Boolean} isComplex           - флаг сложного выпадающего списка.
*     {Boolean} isReadOnly          - флаг списка только для чтения.
*     {Boolean} isFat               - флаг высокого селектора (аналогичного кнопке).
*     {Boolean} isLinkView          - флаг формирования селектора в виде кнопки-ссылки.
*     {Function} onDropDown         - обработчик на нажатие кнопки показа списка.
*     {Function} onSelectorReceiveWidth - обработчик вызываемый после получения ширины
*                                         ширины.
*     {Function} onClear            - обработчик на сброс значения.
* @state:
*
###
DropDownSelector = React.createClass
   # @const {String} - надпись на селекторе при пустом значении.
   _EMPTY_VALUE_CAPTION: 'выберите...'

   # @const {Object} - параметры кнопки.
   _SELECTOR_BUTTON_PARAMS:
      type: 'button'
      icon: 'sort-down'
      iconPosition: 'right'

   # @const {React-element} - элемент разрыва строки.
   _LINE_BREAK_ELEMENT: `(<br/>)`

   # @const {Object} - используемые наименования ссылок.
   _REFS: keyMirror(
      button: null
   )

   # @const {Object} - коды нажимаемых клавиш.
   _KEY_CODES:
      enter: 13
      up: 38
      down: 40

   mixins: [HelpersMixin]

   styles:
      commonOrdinary:
         padding: _COMMON_PADDING
         paddingLeft: 4
         cursor: 'pointer'
         borderRadius: _COMMON_BORDER_RADIUS
         borderWidth: 1
         borderStyle: 'solid'
         borderColor: _COLORS.hierarchy3
         textAlign: 'left'
         verticalAlign: 'middle'
      resetHeight:
         minHeight: ''
      emptyValueCaption:
         color: _COLORS.hierarchy2
      emptyValueCaptionLink:
         color: _COLORS.hierarchy3
      subCaption:
         fontSize: 11
         color: _COLORS.hierarchy2
      captionContainer:
         display: 'inline-block'
         verticalAlign: 'middle'
      withSectionCaption:
         padding: 2
      clearButton:
         verticalAlign: 'middle'


   componentWillReceiveProps: (nextProps) ->
      @_getSelectorWidthAndFireHandler() unless @props.isComplex

   render: ->
      buttonParams = @_SELECTOR_BUTTON_PARAMS
      selectedItem = @props.selectedItem

      `(
         <span title={this._getTitle()}>
            <Button ref={this._REFS.button}
                    styleAddition={this._getSelectorStyle()}
                    caption={this._getSelectorCaption()}
                    type={buttonParams.type}
                    icon={buttonParams.icon}
                    iconPosition={buttonParams.iconPosition}
                    isContentAtTheCorners={this._isContentAtTheCorners()}
                    isDisabled={this.props.isReadOnly}
                    isLink={this.props.isLinkView}
                    tabIndex={this.props.tabIndex}
                    onClick={this.props.onDropDown}
                    onKeyDown={this._onKeyDown}
                  />
            {this._getClearButton()}
         </span>
       )`

   componentDidMount: ->
      @_getSelectorWidthAndFireHandler() unless @props.isComplex

   ###*
   * Функция фокусировки на кнопке селетора.
   *
   * @return
   ###
   focus: ->
      ReactDOM.findDOMNode(@refs[@_REFS.button]).focus()

   ###*
   * Функция получения кнопки сброса выбранного значения.
   *
   * @return {React-element}
   ###
   _getClearButton: ->
      selectedItem = @props.selectedItem

      if @props.enableClear and (selectedItem? and selectedItem.value?)
         `(
             <Button isClear={true}
                     title={this.props.clearTitle}
                     onClick={this.props.onClear}
                     styleAddition={this.styles.clearButton}
                     {...this.props.clearButtonParams}
                  />
          )`

   ###*
   * Функция получения надписи на селекторе (выбранное значение). Проверяет
   *  если выбранное значение - хэш, пробует взять из него значение, если
   *  не получается возвращает ключ.
   *
   * @return {React-element}
   ###
   _getSelectorCaption: ->
      selectedItem = @props.selectedItem

      if selectedItem?
         selectedItemValue = selectedItem.value
         selectedItemCaption = selectedItem.caption
         selectedItemKey = selectedItem.key
         selectedItemAddition = selectedItem.addition
         sectionParams = selectedItemAddition.sectionParams if selectedItemAddition?

         caption =
            if _.isPlainObject(selectedItemValue)
               selectedItemValue.caption or
               selectedItemValue.value or
               selectedItemValue.name or
               selectedItemKey
            else
               selectedItemCaption or selectedItemValue

         if sectionParams? and !_.isEmpty(sectionParams)
            cap = sectionParams.caption

            subCaption =
               `(
                  <span style={this.styles.subCaption}>
                     {cap}
                  </span>
               )`
            lineBreak = @_LINE_BREAK_ELEMENT

      if caption? or subCaption?
         styleAddition = @props.styleAddition

         containerStyle =
            @computeStyles @styles.captionContainer,
                           styleAddition? and styleAddition.captionContainer

         `(
            <span style={containerStyle}>
               {subCaption}
               {lineBreak}
               {caption}
            </span>
         )`
      else
         `(
            <span style={this.styles.captionContainer}>
               {this.props.emptyValue || this._EMPTY_VALUE_CAPTION}
            </span>
         )`

   ###*
   * Функция получения скомпанованного стиля кнопки.
   *
   * @return {Object}
   ###
   _getSelectorStyle: ->
      selectorWidth = @props.componentWidth
      styleAddition = @props.styleAddition
      isHasSelectedItem = @_isHasSelectedItem()
      isLinkView = @props.isLinkView

      if styleAddition? and !_.isEmpty styleAddition
         commonAdditionStyle = styleAddition.common
         additionAdditionStyle =
            if isHasSelectedItem
               styleAddition.selected
            else
               styleAddition.empty

      emptyStyle =
         unless isHasSelectedItem
            if isLinkView
               @styles.emptyValueCaptionLink
            else
               @styles.emptyValueCaption

      @computeStyles !isLinkView and @styles.commonOrdinary,
                     emptyStyle,
                     commonAdditionStyle,
                     additionAdditionStyle,
                     !@props.isFat and @styles.resetHeight,
                     selectorWidth and { width: selectorWidth },
                     @_isHasSectionCaption() and @styles.withSectionCaption

   ###*
   * Функция получения ширины селектора и оповещения родительского компонента
   *  о получении ширины.
   *
   * @return
   ###
   _getSelectorWidthAndFireHandler: ->
      buttonNode = ReactDOM.findDOMNode(@refs[@_REFS.button])

      if buttonNode?
         width = buttonNode.clientWidth

         if width? and width > @props.componentWidth
            @props.onSelectorReceiveWidth width

   ###*
   * Функция фомрирования всплывающего пояснения на селекторе.
   *
   * @return {String}
   ###
   _getTitle: ->
      itemTitle =
         if @_isHasSelectedItem()
            selectedItemValue = @props.selectedItem.value
            selectedItemValue.title if _.isPlainObject selectedItemValue
      itemTitle or @props.title

   ###*
   * Функция-предикат для определения наличия выбранного элемента.
   *
   * @return {Boolean}
   ###
   _isHasSelectedItem: ->
      selectedItem = @props.selectedItem

      selectedItem? and !_.isEmpty(selectedItem) and selectedItem.value?

   ###*
   * Функция-предикат для определения наличия у выбранного элемента заголовка
   *  секции доп. элементов (отображение подзаголовка в селекторе).
   *
   * @return {Boolean}
   ###
   _isHasSectionCaption: ->
      selectedItem = @props.selectedItem

      if selectedItem?
         additionParams = selectedItem.addition
         sectionParams = selectedItem.sectionParams if additionParams?

         if sectionParams?
            sectionCaption = sectionParams.caption

            return sectionCaption? and sectionCaption isnt ''

      false

   ###*
   * Функция-предикат для определения разнесения содержимого кнопки по разным
   *  сторонам кнопки.
   *
   * @return {Boolean}
   ###
   _isContentAtTheCorners: ->
      !@props.isComplex and !!@props.componentWidth

   ###*
   * Обработчик на нажатие клавиш клавиатуры на кнопке-селекторе.
   *  при нажатии предопределенных клавиш вызывает обработчик на показ списка.
   *
   * @param (Object) event - объект события.
   * @return
   ###
   _onKeyDown: (event) ->
      keyCodes = @_KEY_CODES
      eventKeyCode = event.keyCode
      onDropDownHandler = @props.onDropDown

      if _.includes([keyCodes.down, keyCodes.enter], eventKeyCode)
         event.stopPropagation()
         onDropDownHandler()


###* Компонент: Контейнер списка компонента "Выпадающий список".
*               Часть компонента DropDown.
* @props:
*     {Number} componentWidth       - ширина компонента.
*     {Array, Object} items         - хэш/массив с элементами списка.
*     {Object} additionalItems      - хэш с дополнительными элементами.
*     {Boolean} isHidden            - флаг скрыт/показан.
*     {Boolean} isComplex           - флаг сложного выпадающего списка.
*     {Boolean} enableSearch        - флаг наличия поиска в списке (для
*                                     сложного включен по-умолчанию).
*     {Object} styleAddition        - дополнительные стили.
*     {Object} selectedItem         - выбранное значение.
*     {Object} itemKeys             - ключи элементов списка.
*     {String} searchPlaceholder    - заполнитель поля поиска.
*     {Function} onSelect           - обработчик на выбор элемента из списка.
*     {Function} onListReceiveWidth - обработчик, вызываемый по получении компонентом
*                                     ширины.
*     {Function} onHideList         - обработчик, вызываемый по окончанию скрытия списка
*                                     элементов.
* @state:
*     {Number} listWidth - ширина списка
*     {Boolean} isForcedLeaveShown - флаг принудительного оставления произвольной
*                                    области открытой (для корректного поведения
*                                    при вводе значения в поле поиска).
*     {String} searchExpression - поисковая подстрока.
*
###
DropDownList = React.createClass

   # @const {Object} - параметры для произвольной области.
   _ARBITRARY_AREA_PARAMS:
      anchor: 'parent'
      animation: 'slideDown'
      position:
         horizontal:
            left: 'left'

   # @const {String} - наименование стиля ширины.
   _WIDTH_STYLE_NAME: 'width'

   # @const {String} - наименование статуса полностью развернутого аккордеона.
   _ACCORDION_EXPANDED_STATUS: 'expanded'

   # @const {Object} - имена используемых ссылок на элементы.
   _REFS: keyMirror(
      list: null
   )

   mixins: [HelpersMixin]

   styles:
      common:
         backgroundColor: _COLORS.light
         zIndex: 1
         marginTop: -4
         borderWidth: 1
         borderStyle: 'solid'
         borderColor:_COLORS.hierarchy3
         borderTopStyle: 'none'
         borderRadius: ['0px', '0px', _CBR, _CBR].join(' ')
         boxSizing: 'border-box'
      complexArea:
         borderTopStyle: 'solid'
         marginTop: 2
         borderRadius: 0
      listContainer:
         margin: 0
         maxHeight: 300
         textAlign: 'left'
         overflowY: 'auto'
         listStyleType: 'none'
         listStylePosition: 'inside'
         padding: 0
         position: 'relative'
      listItem:
         padding: _COMMON_PADDING
         paddingRight: 15
         paddingLeft: 10
         minHeight: 10
         fontSize: 14
         cursor: 'pointer'
         backgroundColor: _COLORS.light
         color: _COLORS.dark
      listHidden:
         display: 'none'
      searchInputContainer:
         padding: 2

   getInitialState: ->
      isForcedLeaveShown: false

   componentWillReceiveProps: (nextProps) ->
       @_getListWidth() if !@props.isComplex and @_isHasItems nextProps.items

       # Сбросим флаг принудительного оставления области открытой, если флаг
       #  имеет положительное значение.
       @setState isForcedLeaveShown: false if @state.isForcedLeaveShown

   render: ->
      areaParams = @_ARBITRARY_AREA_PARAMS
      isForcedLeaveShown = @state.isForcedLeaveShown

      #isCatchFocus={!isForcedLeaveShown}

      `(
         <ArbitraryArea content={this._getContent()}
                        target={this._getAreaTarget()}
                        layoutAnchor={areaParams.anchor}
                        animation={areaParams.animation}
                        isResetOffset={true}
                        isAdaptive={this.props.isAdaptive}
                        isForcedLeaveShown={isForcedLeaveShown}
                        styleAddition={this._getAreaStyle()}
                        position={areaParams.position}
                        onHide={this.props.onHideList}
                        onShow={this._onShowArea}
                     />
      )`

   componentDidMount: ->
      @_getListWidth() unless @props.isComplex

   ###*
   * Функция получения содержимого списка элементов.
   *
   * @return {React-element} - список элементов.
   ###
   _getContent: ->
      `(
         <div>
            {this._getSearchInput()}
            <div style={this.styles.listContainer}>
               <List ref={this._REFS.list}
                     items={this._getListItems()}
                     styleAddition={this._getListStylesAddition()}
                     searchExpression={this.state.searchExpression}
                     enableMarkActivated={true}
                     onSelect={this.props.onSelect}
                  />
               {this._getAdditionalItems()}
            </div>
         </div>
       )`

   ###*
   * Функция получения дополнительных стилей для компонента списка.
   *
   * @return {Object} - стили.
   ###
   _getListStylesAddition: ->
      common: @_getListStyle()
      item:
         common: @_getItemStyle()

   ###*
   * Функция получения скомпанованного стиля области со списком элементов.
   *  Устанавливает ширину, если она была задана в свойствах.
   *
   * @return {Object} - скомпанованный стиль.
   ###
   _getAreaStyle: ->
      listWidth = @props.componentWidth

      @computeStyles @styles.common,
                     @props.isComplex and @styles.complexArea,
                     listWidth and { width: listWidth }

   ###*
   * Функция получения скомпанованного стиля для списка.
   *
   * @return {Object} - скомпанованный стиль.
   ###
   _getListStyle: ->
      @computeStyles @styles.list, @props.styleAddition.list

   ###*
   * Функция получения скомпанованного стиля для элемента списка.
   *
   * @return {Object} - скомпанованный стиль.
   ###
   _getItemStyle: ->
      @computeStyles @styles.listItem, @props.styleAddition.item

   ###*
   * Функция формирования элемента с строкой поисковой фильтрации по элементам
   *  коллекции.
   *
   * @return {React-element}
   ###
   _getSearchInput: ->
      enableSearch = @props.enableSearch
      isComplex = @props.isComplex

      # Если выпадающий список комплексный и флаг не задан - установим
      #  положительное значение.
      if isComplex and !enableSearch?
         enableSearch = true

      if enableSearch
         `(
            <div style={this.styles.searchInputContainer}>
               <Input placeholder={this.props.searchPlaceholder}
                      isSearch={true}
                      onChange={this._onChangeSearchInput}
                    />
            </div>
          )`

   ###*
   * Функция получения массива параметров элементов списка.
   *
   * @return {Array<Object>} - массив параметров элементов
   ###
   _getListItems: ->
      items = @props.items
      selectedKey = @props.selectedKey
      searchExpression = @state.searchExpression
      itemKeys = @props.itemKeys
      valueKey = itemKeys.value
      captionKey = itemKeys.caption
      titleKey = itemKeys.title
      listItems = []

      # В зависимости от того каким образом заданы элементы выпадающего списка
      #  (массивом или хэшем) различным образом перебираем коллекцию.
      if _.isArray(items)

         for value, idx in items
            if selectedKey isnt idx
               itemValue = itemCaption = value
               isItemObject = _.isPlainObject(value)

               if isItemObject
                  #itemValue = value[valueKey] if _.has(value, valueKey)
                  itemCaption = value[captionKey] if _.has(value, captionKey)
                  itemTitle = value[titleKey] if _.has(value, titleKey)

               item =
                  value: itemValue
                  caption: itemCaption
                  title: itemTitle

               listItems.push(item) if item?
      else if _.isPlainObject(items)
         for key, item of items
            isCorrectKey = _.has(items, key) and (key isnt selectedKey)

            if isCorrectKey
               itemParam =
                  # Если значение - это хэш с параметрами, то был передан комплексный хэш
                  #  параметров, их нужно перибирать соответствующим образом
                  if _.isPlainObject(item)
                     caption: item.caption
                     title: item.title
                     value: item
                  else
                     caption: item
                     value: key

               listItems.push(itemParam)

      listItems

   ###*
   * Функция получения секций с дополнительными элементами выпадающего списка.
   *
   * @return {React-element, undefined}
   ###
   _getAdditionalItems: ->
      additionalItems = @props.additionalItems

      if @props.isComplex and additionalItems? and !_.isEmpty(additionalItems)
         accordionSections = []
         searchExpression = @state.searchExpression
         onSelectHandler = @props.onSelect

         for additionalSection in additionalItems
            items = additionalSection.items
            itemsCollection = []
            sectionName = additionalSection.name
            sectionParents = additionalSection.parents
            sectionCaption =  additionalSection.caption
            sectionSubCaption = additionalSection.subCaption
            sectionData = additionalSection.sectionData

            if items? and items.length
               suitableItemsCount = 0

               for item, idx in items
                  itemCaption = item.caption

                  if @isMatchedExpression(itemCaption, searchExpression)
                     suitableItemsCount++

                  itemsCollection.push(
                     value: item
                     caption: item.caption
                     addition:
                        sectionParams:
                           name: sectionName
                           parents: sectionParents
                           caption: sectionCaption
                           subCaption: sectionSubCaption
                           sectionData: sectionData
                  )

               if itemsCollection.length and suitableItemsCount > 0
                  itemsList =
                     `(
                        <List items={itemsCollection}
                              styleAddition={this._getListStylesAddition()}
                              onSelect={onSelectHandler}
                              searchExpression={searchExpression}
                            />
                      )`

                  accordionSections.push
                     header: sectionCaption
                     subHeader: sectionSubCaption
                     content: itemsList
                     name: sectionName

         if accordionSections.length
            searchExpression = @state.searchExpression
            status = if searchExpression? and searchExpression isnt ''
                        @_ACCORDION_EXPANDED_STATUS

            `(<Accordion items={accordionSections}
                         status={status} />)`

   ###*
   * Функция получения целевого узла для произвольной области. Получает узел, только
   *  если список не скрыт.
   *
   * @return
   ###
   _getAreaTarget: ->
      @props.target unless @props.isHidden

   ###*
   * Функция получения ширины у списка.
   *
   * @return
   ###
   _getListWidth: ->
      if @isMounted
         $list = $(ReactDOM.findDOMNode(this))
         # АХТУНГ: згрязный хак для определения истинной ширины списка (нужен
         #  для определения ширины списка, когда элементы получены после
         #  монтирования)
         oldWidth = $list.width()
         $list.css(@_WIDTH_STYLE_NAME, '')
         listWidth = $list.width()
         $list.width oldWidth


         @_checkWidthAndSend listWidth

   ###*
   * Функция проверки объекта свойств на наличие элементов в нем.
   *
   * @param {Object} items - коллекция элементов
   * @return {Boolean} - флаг наличия элементов
   ###
   _isHasItems: (items) ->
      !_.isEmpty(items)

   ###*
   * Обработчик события показа области со списком.
   *
   * @return
   ###
   _onShowArea: ->
      ReactDOM.findDOMNode(@refs[@_REFS.list]).focus()

   ###*
   * Обработчик на изменение значение в поисковом поле ввода.
   *
   * @param {String} value - значение в поле ввода.
   * @return
   ###
   _onChangeSearchInput: (value) ->
      @setState
         searchExpression: value
         isForcedLeaveShown: true

   ###
   * Функция проверки необходимости оповещения о превышении ширины списка, над
   *  шириной компонента
   *
   * @param {Number} listWidth - ширина списка
   * @return
   ###
   _checkWidthAndSend: (listWidth)->
      if listWidth > @props.componentWidth
         @props.onListReceiveWidth listWidth


module.exports = DropDown

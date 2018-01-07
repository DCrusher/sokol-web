###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* HelpersMixin     - функции-хэлперы для компонентов.
* HierarchyMixin   - модуль для задания иерархии компонентов.
* AnimationsMixin  - набор анимаций для компонентов.
* AnimateMixin     - библиотека добавляющая компонентам
*                    возможность исользования анимации.
* keyMirror - модуль для генерации "зеркальных хэшей".
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
HierarchyMixin = require('../mixins/hierarchy_components')
AnimationsMixin = require('../mixins/animations')
AnimateMixin = require('react-animate')
PureRenderMixin = React.addons.PureRenderMixin
keyMirror = require('keymirror')

###* Зависимости: компоненты
* Button      - кнопка.
* PopupBaloon - всплывашка.
* List        - список.
###
Button = require('./button')
PopupBaloon = require('./popup_baloon')
List = require('./list')

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


###* Компонент: Accordion - контейнер со сворачиваемыми/разворачиваемыми секциями.
*
* @props:
*     {String} name - имя аккордеона.
*     {String, Number} indentifier - идентификатор аккордеона (для задания уникальности).
*     {Boolean} isIndepended - свойство, характеризующее зависимость работы элементов, по отношению
*                               к состоянию расширенности. Значения:
*                                                           true - при открытии одного элемента
*                                                                  закрываются все остальные
*                                                           false - элементы открываются независимо
*     {Boolean} enableDeactivate - флаг возможности деактивации активной секции
*                                  (закрытие текущей активной секции). По-умолчанию = false
*     {Array} items - массив объектов. Cвойства:
*                                {String} name - имя секции.
*                                {String} header - заголовок секции.
*                                {String} subHeader - подзаголовок секции (второстепенная информация).
*                                {String, Object, React-DOM-Node} content - содержимое секции.
*                                {String} leadIcon - название иконки заголовка из FontAwesome
*                                         (без префксов).
*                                {Boolean} - isOpened - статус по умолчанию:
*                                                           true - открыт
*                                                           false - закрыт
*                                {Object} - counter - число, или объект, выводимые в правой
*                                   части заголовка c указанием типа и подсказки при наведении.
*                                   Атрибуты:
*                                      {Number} count - число
*                                      {String} type - тип
*                                      {String} title - подсказка
*                                {String} question - содержимое подсказки.
*                                {String} info - содержимое информации.
*                                {Array} headerButtons - набор кнопок, выводимых в заголовке.
*                                                        Принимаются любые параметры компонента
*                                                        Button.
*     {String} status - свойство, характеризующее расширенность элементов аккодреона. Значения:
*                                 'expanded'  - раскрывает все элементы (реализовано частично)
*                                 'collapsed' - закрывает все элементы (реализовано частично)
*                                 'default'   - всем элементам вернуться к поведению по-умолчанию.
*     {Object} styleAddition:   - набор доп. стилей для различных частей компонента:
*           {Object} header     - дополнительные стили для заголовка.
*                                 Вид:
*                                   {Object} common - стили в обычном состоянии.
*                                   {Object} highlightBack - стили при наведении.
*           {Object} content    - доп. стили для контейнера содержимого.
*          {Object} contentItem - доп. стили для элемента содержимого.
*     {Object} styleAdditionContent - дополнительные стили для содержимого секций.
*     {Object} styleAdditionContentItem - дополнительные стили для элемента содержимого секций.
*     {Object} navigatorModParams - свойство, характеризующее параметры для аккордиона в режиме
*                                      навигации. Содержит следующие объекты:
*                                         {String} position - Позиция аккодеона относительно окна с
*                                                              контентом. Значения:
*                                                                 'left' - меню аккордеона слева
*                                                                 'right' - меню аккордеона справа
*     {Function} onExpandComplete - функция, вызываемая по завершению принудительного раскрытия
*                                   элемента аккодреона.
*     {Function} onSectionOpened  - обработчик, запускаемый после открытия секции. Возвращает:
*                                   {Object} параметры секции.
*                                   {String} идентификатор аккордеона.
*     {Function} onInit           - обработчик на инициализацию элемента. Вызывается перед монтированием.
*                                   Аргументы:
*                                   {React-Element} accordion - ссылка на экземпляр.
*     {Function} onDestroy        - обработчик на размонтирование компонента. Вызывается перед размонтированием.
*                                   Аргументы:
*                                   {React-Element} accordion - ссылка на экземпляр.
* @state :
*     {Object} activatedItemParams - параметры текущего активного элемента.
*              {Object} items - Ассоциативный массив состояний элемента. Вид:
*                 {Number} index: {Boolean} isExpanded - состояние элемента (true-открыт).
*              {Number} lastInteract
*     {String}  accordionState - состояние, характеризующее статус аккодреона. При изменении
*                                состояния компонента AccordionItem сбрасывается в default.
* @context:
*     {String, Number} parentIdentifier - идентификатор родительского элемента(для построения
*                                         иерархии компонентов).
* @functions:
*     expandedAll - функция разворачивания всех секций.
*        @return
*
*     collapseAll - функция сворачивания всех секций.
*        @return
*
*     expandSection({String, Number}) - функция разворачивания секции по имени или
*                                       индексу.
*        @return
*
*     activateNextSection - функция активации следующей за текущей секцией(при наличии следующих секций)
*        @return
*
*     getActiveSectionIndex - функция индекс активной секции в наборе.
*        @return {Number}
*
*     getActiveSectionParams - функция получения параметров текущей активной секции.
*        @return {Object}
*
*     getName - функция получения имени аккордеона.
*        @return {String}
*
*     getIdentifier - функция получения иддентификатора аккордеона.
*        @return {String, Number}
*
*     getSectionNames - функция получения набора имен секций.
*        @return {Array}
*
*     getSectionParams - функция получения набора параметров секций аккордеона.
*        @return {Array}
###
Accordion = React.createClass

   # @const {String} - строка-идентификатор строкового типа.
   _STRING_TYPE: 'string'

   # @const {String} - ключ для доступа к имени элемента
   _ITEM_NAME_KEY: 'name'

   # @const {Object} - возможные параметры позиционирования заголовков
   #                   аккордеона-навигатора.
   _NAVIGATOR_POSITIONS: keyMirror(
      left: null
      right: null
   )

   # @const {Object} - возможные состояния аккордеона.
   _ACCORDION_STATES: keyMirror(
      expanded: null
      collapsed: null
      default: null
   )

   mixins: [HelpersMixin,
            AnimateMixin,
            AnimationsMixin.collapse,
            HierarchyMixin.hierarchy.child]

   styles:
      navigatorContainer:
         verticalAlign: 'top'
         width: '100%'
      navigatorModeHeadersCell:
         width: '25%'
      navigatorModeCell:
         verticalAlign: 'top'

   propTypes:
      name: React.PropTypes.string
      identifier: React.PropTypes.oneOfType([
         React.PropTypes.string
         React.PropTypes.number
      ])
      items: React.PropTypes.array
      enableDeactivate: React.PropTypes.bool
      isIndependent: React.PropTypes.bool
      status: React.PropTypes.oneOf(['', 'expanded','collapsed', 'default'])
      styleAdditionHeader: React.PropTypes.object
      styleAdditionContent: React.PropTypes.object
      styleAdditionContentItem: React.PropTypes.object
      controlIcons: React.PropTypes.object
      leadIcon: React.PropTypes.string

   getDefaultProps: ->
      identifier: 0
      enableDeactivate: true
      isIndependent: false
      status: ''
      styleAdditionHeader: undefined
      controlIcons: undefined

   getInitialState: ->
      activatedItemParams: @_getInitActivatedItemParams()
      accordionState: @_getAccordionState(@props.status)

   componentWillReceiveProps: (nextProps) ->
      @setState accordionState: @_getAccordionState(nextProps.status)

   render: ->
      `(
         <div>
            {this._getItemsContent()}
         </div>
       )`

   componentWillMount: ->
      onInitHandler = @props.onInit

      onInitHandler this if onInitHandler?

   componentWillUnmount: ->
      onDestroyHandler = @props.onDestroy

      onDestroyHandler this if onDestroyHandler?

   ###*
   * Функция сворачивания всех секций аккордеона.
   *
   * @return
   ###
   expandedAll: ->
      @setState accordionState: @_ACCORDION_STATES.expanded

   ###*
   * Функция разворачивания всех секций аккордеона.
   *
   * @return
   ###
   collapseAll: ->
      @setState accordionState: @_ACCORDION_STATES.collapsed

   ###*
   * Функция разворачивания секции аккордеона. На вход принимается идентификатор
   *  секции (индекс или имя секции). Если
   *
   * @param {String, Number} sectionIdentifier - идентификатор
   ###
   expandSection: (sectionIdentifier) ->
      if sectionIdentifier?
         items = @props.items

         # Если была передана строка в качестве идентификатора, то возможно это имя.
         #  пробуем определить индекс секции по имени.
         sectionIndex =
            if typeof  sectionIdentifier is @_STRING_TYPE
               @_getSectionIndexByName sectionIdentifier
            else
               sectionIdentifier

         # Если в качестве идентификатора передано число - значит это предполагаемый
         #  индекс секции.

         if isFinite sectionIndex

            # Устанавливаем активный индекс, только если элемент с таким индексом
            #  задан в параметрах.
            if sectionIndex < items.length
               activatedItemParams = @state.activatedItemParams
               activatedItemParams.lastInteract = sectionIndex
               activatedItemParams.items[sectionIndex] = true

               @setState activatedItemParams: activatedItemParams

   ###*
   * Функция активации следующей от текущей секции в наборе.
   *
   * @return
   ###
   activateNextSection: ->
      activatedIndex = @state.activatedItemParams.lastInteract
      items = @props.items

      if  activatedIndex < items.length
         nextSectionIdx = ++activatedIndex
         nextSection = items[nextSectionIdx]

         # Развернем следующую секцию.
         @expandSection nextSectionIdx

      nextSection

   ###*
   * Функция получения индекса активной секции аккордеона.
   *
   * @return {Number} - имя активированной вкладки или индекс.
   ###
   getActiveSectionIndex: ->
      activatedItemParams = @state.activatedItemParams

      activatedItemParams.lastInteract

   ###*
   * Функция получения индекса параметров активной секции аккордеона.
   *
   * @return {Object} - параметры активной секции.
   ###
   getActiveSectionParams: ->
      @props.items[@state.activatedItemParams.lastInteract]

   ###*
   * Функция получения имени аккордеона.
   *
   * @return {String} - имя.
   ###
   getName: ->
      @props.name

   ###*
   * Функция получения идентификатора аккордеона.
   *
   * @return {String, Number} - идентификатор.
   ###
   getIdentifier: ->
      @props.identifier

   ###*
   * Функция получения набора имен секций.
   *
   * @return {Array} - набор имен секций.
   ###
   getSectionNames: ->
      items = @props.items

      if items?
         items.map (item) -> item.name

   ###*
   * Функция получения набора параметров секций.
   *
   * @return {Array} - набор секций.
   ###
   getSectionParams: ->
      items = @props.items
      items[..] if items?

   ###*
   * Если активированный элемент существует и компонент зависимый, то открыть только активированный
   *  элемент. Иначе (при несуществовании активного элемента), если компонент независимый -
   *  отправить значение, переданное в компонент, если зависимый - отправить в дочерний компонент
   *  первое положительное значение, переданное в родительский компонент, если таковое имеется. Если
   *  же положительных значений для дочерних компонентов нет, то всем передается значение false.
   *
   * @return {React-Element} содержимое аккордеона.
   ###
   _getItemsContent: ->
      return unless @_isHasItems()

      props = @props
      items = props.items
      isIndependent = props.isIndependent
      navigatorModParams = props.navigatorModParams
      nameKey = @_ITEM_NAME_KEY
      leftPosition = @_NAVIGATOR_POSITIONS.left
      styleAddition = @props.styleAddition
      styleAdditionHeader = styleAddition.header if styleAddition?
      styleAdditionContent = styleAddition.content if styleAddition?
      styleAdditionContentItem = styleAddition.contentItem if styleAddition?

      isHasAlreadyExpanded = false
      contents = []
      headers = []

      for item, index in items
         isExpanded = @_isItemExpanded(index,
                                       item.isOpened,
                                       isHasAlreadyExpanded)

         if !isIndependent and isExpanded
            isHasAlreadyExpanded = isExpanded


         headers.push(
            `(<AccordionHeader index={index}
                               key={index}
                               header={item.header}
                               subHeader={item.subHeader}
                               question={item.question}
                               info={item.info}
                               counter={item.counter}
                               leadIcon={item.leadIcon}
                               buttons={item.headerButtons}
                               controlIcons={props.controlIcons}
                               navigatorModParams={navigatorModParams}
                               navigatorModPositions={this._NAVIGATOR_POSITIONS}
                               styleAddition={styleAdditionHeader}
                               isExpanded={isExpanded}
                               enableDeactivate={this.props.enableDeactivate}
                               onClick={this._onClickHeader} />)`
         )

         contents.push(
            `(<AccordionContent identifier={item.identifier}
                                index={index}
                                onExpandComplete={this.props.onExpandComplete}
                                styleAddition={styleAdditionContent}
                                styleAdditionItem={styleAdditionContentItem}
                                key={"content"+index}
                                content={item.content}
                                isExpanded={isExpanded}
                                parentStatus={this.state.accordionState}/>)`
         )

      # Если аккордеон работает в режиме "навигатора", располагаем однотипные элементы
      #  вместе.
      # Иначе - аккордеон работает в обычном режиме - элементы располагаются вперемешку.
      #  сначала заголовок, затем содержимое
      if navigatorModParams?

         if navigatorModParams.position is leftPosition
            leftElements = headers
            rightElements = contents
            leftCellStyle = @computeStyles @styles.navigatorModeCell,
                                           @styles.navigatorModeHeadersCell
            rightCellStyle = @styles.navigatorModeCell
         else
            leftElements = contents
            rightElements = headers
            rightCellStyle = @computeStyles @styles.navigatorModeCell,
                                            @styles.navigatorModeHeadersCell
            leftCellStyle = @styles.navigatorModeCell

         navigatorElementsStyle = @styles.navigatorModeElements

         #style={this.styles.navigatorContainer}

               # <div style={navigatorElementsStyle}>
               #    {leftElements}
               # </div>
               # <div style={navigatorElementsStyle}>
               #    {rightElements}
               # </div>

         `(
            <table style={this.styles.navigatorContainer}>
               <tbody>
                  <tr>
                     <td style={leftCellStyle}>
                        {leftElements}
                     </td>
                     <td style={rightCellStyle}>
                        {rightElements}
                     </td>
                  </tr>
               </tbody>
            </table>
         )`
      else
         renderBody = []

         for header, idx in headers
            renderBody.push header
            renderBody.push contents[idx]

         `(
            <div>
               {renderBody}
            </div>
         )`

   ###*
   * Функция, проверяющая корректность переданного статуса. В случае, если статус корректен,
   *  возвращает его, иначе возвращает статус по умолчанию.
   *
   * @param {String} propsStatus - статус аккордеона
   * @return {String} - текущий статус, либо статус по-умолчанию
   ###
   _getAccordionState: (propsStatus)->
      accordionStates = @_ACCORDION_STATES

      if accordionStates.hasOwnProperty propsStatus
         propsStatus
      else
         accordionStates.default

   ###*
   * Функция получения индекса параметров секции(порядкового номера) по имени секции
   *  (если имена секций заданы). Если секция не найдена(не заданы имена или ищется
   *  несуществующее имя) возвращается undefined.
   *
   * @param {String} sectionName - имя секции.
   * @return {Number, undefined} - индекс секции или пустой ответ.
   ###
   _getSectionIndexByName: (sectionName) ->
      items = @props.items

      for item, idx in items
         itemName = item.name

         return idx if itemName? and (itemName is sectionName)

   ###*
   * Функция получения состояний секций аккордеона на основе заданных
   *  свойств элемента.
   *
   * @param {Object} - хэш состояний секций. Вид:
   *        {Object} itemStates - ассоциативный массив, ключ - индекс,
   *                              значение - состояние (true - развернут).
   *        {Number} lastInteract - последний индекс с которым было взаимодействие.
   ###
   _getInitActivatedItemParams: ->
      items = @props.items
      isDependent = !@props.isIndependent
      itemStates = {}
      lastInteract = null

      if items?
         for item, idx in items
            isOpened = !!item.isOpened
            itemStates[idx] = isOpened
            lastInteract = idx

            break if isDependent and isOpened

      items: itemStates
      lastInteract: lastInteract

   ###*
   * Функция получения параметров активированности секции по индексу.
   *
   * @param {Number} itemIndex - индекс секции.
   * @return {Object} - параметры. Вид:
   *                    {Boolean} isExpanded - раскрыт/закрыт.
   *                    {Boolean} isLastInteract - является ли секция последней,
   *                                               с которой "взаимодействовали".
   ###
   _getActivatedStateByIndex: (itemIndex)->
      activatedItemParams = @state.activatedItemParams

      if activatedItemParams? and !$.isEmptyObject(activatedItemParams)
         isExpanded: activatedItemParams.items[itemIndex]
         isLastInteract: activatedItemParams.lastInteract is itemIndex

   ###*
   * Функция-предикат, определяющая наличие элементов аккордеона.
   *
   * @retutn {Boolean} - наличие элементов в аккордеоне.
   ###
   _isHasItems: ->
      items = @props.items
      items? and items.length

   ###*
   * Функция, определяющая статус элемента аккордеона (открыт/закрыт).
   *
   * @param {Number} itemIndex - индекс секции.
   * @return {Boolean} - статус секции аккордеона.
   *                     Варианты:
   *                        true      - открыт
   *                        false     - закрыт
   ###
   _isItemExpanded: (itemIndex) ->
      states = @_ACCORDION_STATES
      isIndependent = @props.isIndependent
      accordionState = @state.accordionState

      # Определяем "глобальное" состояние "раскрытости"" для компонента.
      isGlobalExpanded =
         if accordionState is states.expanded
            true
         else if accordionState is states.collapsed
            false

      # Если глобальное состояние "раскрытости" задано - возвращаем его, для всех
      #  элементов оно будет одинаковое.
      # Иначе определяем состояние "раскрытости" секции исходя из того, что задано
      #  в состоянии компонента и является он "независимым"
      if isGlobalExpanded?
         isGlobalExpanded
      else
         itemActivatedParams = @_getActivatedStateByIndex(itemIndex)
         isExpandedByActivate = itemActivatedParams.isExpanded
         isLastInteract = itemActivatedParams.isLastInteract

         if isIndependent
            isExpandedByActivate
         else
            isExpandedByActivate and isLastInteract

   ###*
   * Функция предикат для определения находится ли компонент в "глобальном"
   *  состоянии (все раскрыты или все скрыты).
   ###
   _isInGlobalState: ->
      accordionStates = @_ACCORDION_STATES
      @state.accordionState in [accordionStates.expanded, accordionStates.collapsed]

   ###*
   * Обработчик клика по заголовку секции аккордеона. Устанавливает новое состояние
   *  для секции по которой произошел клик и сбрасывает состояние аккордеона в default.
   *
   * @param {number} index - номер элемента аккордеона
   * @param {boolean} isExpanded - элемент раскрыт?
   * @return
   ###
   _onClickHeader: (index, isExpanded) ->
      onSectionOpenedHandler = @props.onSectionOpened
      activatedIndexParams = @state.activatedItemParams

      if onSectionOpenedHandler?
         selectedItem = @props.items[index]
         resultValue = selectedItem || index

         onSectionOpenedHandler selectedItem, @props.identifier

      activatedItems = activatedIndexParams.items

      # Определим состояние каждой секции аккордеона. Если компонент находится
      #  в одном из глобальных состояний - развернуто или свернуто все, то
      #  следующее состояние зависит от того зависимый ли аккордеон или нет. Если
      #  зависимый, то пункт останется открытым, если независимый - то скроется.
      # Иначе возьмем возвращенное состояние компонента.
      activatedItems[index] = if @_isInGlobalState()
                                 !@props.isIndependent
                              else
                                 isExpanded


      @setState
         activatedItemParams:
            items: activatedItems
            lastInteract: index
         accordionState: @_ACCORDION_STATES.default


###* Компонент: Заголовок элемента аккордеона - часть компонента Accordion
* @props:
*     {Number} index                  - порядковый номер элемента.
*     {Object} controlIcons           - параметры  иконок разворачивания-сворачивания.
*     {String, Object} header         - содержимое компонента (выводимый заголовок).
*     {Array<Object>} buttons   - набор параметров для кнопок заголовка.
*     {String} subHeader              - выводимый подзаголовок (второстепенная инофрмация).
*     {String} question               - справка, выводимая при взаимодействии со
*                                       служебной кнопкой помощи.
*     {String} info                   - информационное сообщение, выводимое при взаимодействии со
*                                       служебной кнопкой информации.
*     {String} leadIcon               - лидирующая иконка (иконка вначале заголовка).
*     {Object} navigatorModParams     - параметры режима "навигатора".
*     {Object} navigatorModPositions  - возможные позиции режима "навигатора".
*     {Boolean} isExpanded            - флаг "раскрытости" секции.
*     {Boolean} enableDeactivate      - флаг возможности деактивации активной секции.
*     {Function} onClick              - обработчик клика по заголовку.
* @state:
*     {Boolean} isInHover -  флаг нахождения в фокусе.
###
AccordionHeader = React.createClass

   # @const {Object} - иконки по-умолчанию.
   _DEFAULT_ICONS:
      caretLeft: 'caret-left'
      caretRight: 'caret-right'
      caretDown: 'caret-down'
      info: 'info-circle'
      question: 'question-circle'
      counterError: 'exclamation-triangle'

   # @const {String} - префикс класса для иконок FontAwesome.
   _FA_ICONS_PREFIX: 'fa fa-'

   # @const {Object} - типы счетчиков.
   _COUNTER_TYPES: keyMirror(
      common: null
      error: null
   )

   # @const {Object} - идентификаторы типов кнопок со всплывашкой.
   _TIP_TYPES: keyMirror(
      question: null
      info: null
      exclamation: null
   )


   mixins: [HelpersMixin]

   styles:
      common:
         backgroundColor: _COLORS.hierarchy4
         # borderStyle: 'solid'
         # borderWidth: 1
         # borderColor: _COLORS.hierarchy4
         color: _COLORS.hierarchy2
         cursor: 'pointer'
         paddingLeft: _COMMON_PADDING
         paddingRight: _COMMON_PADDING
         paddingTop: 3
         paddingBottom: 3
         textAlign: 'left'
         marginTop: 1
         minHeight: 35
         height: 1
         width: '100%'
         whiteSpace: 'normal'
         fontSize: 14
      changeOfBorders:
         borderStyle: 'dashed'
         borderColor: _COLORS.light
         borderWidth: 1
      highlightBack:
         backgroundColor: _COLORS.hierarchy2
         color: _COLORS.light
      iconStyle:
         marginLeft: _COMMON_PADDING
         minWidth: 10
      subHeader:
         fontSize: 11
         color: _COLORS.hierarchy3
      counterStyle:
         fontSize: 'large'
         color: _COLORS.alert
         # padding: 0
      counterCount:
         fontSize: 12
         padding: 2
      accordionItemHeaderTable:
         width: '100%'
      counterTableStyle:
         textAlign: 'right'
         width: 50
      iconCell:
         width: 15
      userButtonsCell:
         width: '1%'
         paddingLeft: _COMMON_PADDING
      counterCell:
         whiteSpace: 'nowrap'
         width: '1%'
      serviceIcon:
         fontSize: 20
         height: 21
         marginTop: -5
         verticalAlign: 'middle'
         overflow: 'visible'
         boxShadow: 'none'
         # top: 2
         # position: 'relative'
      leadIcon:
         paddingRight: 3
      commonServiceIconsColors:
         color: _COLORS.hierarchy2
      highlightBackServiceIconsColors:
         color: _COLORS.light

   getInitialState: ->
      isInHover: false
      controlStyles: @_getInitControlStyles()
      controlIcons: @_getInitControlIcons()

   render: ->
      `(
         <table style={this._getAccordionItemHeaderStyle()}
                onClick={this._onClick}
                onMouseLeave={this._onMouseLeave}
                onMouseEnter={this._onMouseEnter}>
            <tbody>
               <tr>
                  {this._getLeadIconCell()}
                  <td>
                     {this._getHeader()}
                     {this._getSubHeader()}
                  </td>
                  {this._getCounterCell()}
                  {this._getTipIcon(true)}
                  {this._getTipIcon(false)}
                  {this._getButtonsCell()}
                  {this._getControlIconCell()}
               </tr>
            </tbody>
         </table>
      )`

   ###*
   * Функция получения выводимого подзаголовка.
   *
   * @return {React-Element}.
   ###
   _getSubHeader: ->
      subHeader = @props.subHeader

      if subHeader? and (subHeader isnt '')
         `(
            <div style={this.styles.subHeader}>
               {subHeader}
            </div>
         )`

   ###*
   * Функция получения счетчика для заголовка аккодреона.
   *
   * @return {Object} - счетчик.
   ###
   _getCounterCell: ->
      counterParam = @props.counter

      if counterParam? and !$.isEmptyObject counterParam
         counterCount = counterParam.count
         counterIcon =
            if counterParam.type is @_COUNTER_TYPES.error
               @_DEFAULT_ICONS.counterError


         countElement =
            `(
               <span style={this.styles.counterCount}>
                  {counterCount}
               </span>
            )`

         `(
            <td style={this.styles.counterCell}>
               <Button caption={countElement}
                       isWithoutPadding={true}
                       isLink={true}
                       icon={counterIcon}
                       iconPosition='right'
                       title={this.props.counter.title}
                       styleAddition={this.styles.counterStyle}/>
            </td>
         )`

   ###*
   * Функция получения иконки заголовка аккодреона.
   *
   * @return {Object} - иконка заголовка.
   ###
   _getLeadIconCell: ->
      leadIcon = @props.leadIcon

      if leadIcon? and !_.isEmpty(leadIcon)
         `(
            <td style={this.styles.iconCell}>
               <i style={this.styles.leadIcon}
                  className={this._FA_ICONS_PREFIX + leadIcon}></i>
            </td>
          )`

   ###*
   * Функция выводимый заголовок.
   *
   * @return {React-Element}
   ###
   _getHeader: ->
      header = @props.header

      if header?
         `(
            <div>{header}</div>
         )`

   ###*
   * Функция получения иконки для заголовка аккодреона.
   *
   * @param  {Boolean} - isInfo - флаг, показывающий, что необходимо вернуть иконку информации. Если
   *                       флаг установлен в false, значит необходимо вернуть иконку вопроса.
   * @return {Object}  - подсказка с popupBaloon.
   ###
   _getTipIcon: (isInfo)->
      tipTypes = @_TIP_TYPES

      if isInfo and @props.info?
         tipType = tipTypes.info
      else
         if @props.question and !isInfo
            tipType = tipTypes.question

      if tipType?
         `(
            <td style={this.styles.iconCell}
                onBlur={this._onBlurIcon}>
               <Button title={this.props[tipType]}
                       isLink={true}
                       isWithoutPadding={true}
                       styleAddition={this._getServiceIconAdditionStyle()}
                       tipModeParams={
                          {
                             tipType: tipType
                          }
                       }
                       onClick={this._onClickService}/>
            </td>
         )`
   ###*
   * Функция получения иконки для заголовка аккодреона.
   *
   * @param  {Boolean} - isInfo - флаг, показывающий, что необходимо вернуть иконку информации. Если
   *                       флаг установлен в false, значит необходимо вернуть иконку вопроса.
   * @return {Object}  - подсказка с popupBaloon.
   ###
   _getServiceIconCell: (isInfo)->
      if isInfo and @props.info?
         isInfo = true
         iconName = 'info'
      else
         if @props.question and !isInfo
            isQuestion = true
            iconName = 'question'

      if iconName?
         `(
            <td style={this.styles.iconCell}
                onBlur={this._onBlurIcon}>
               <Button caption={this.props[iconName]}
                       icon={this._DEFAULT_ICONS[iconName]}
                       isWithoutPadding={true}
                       isInfo={isInfo}
                       isQuestion={isQuestion}
                       onClick={this._onClickService}
                       styleAddition={this._getServiceIconAdditionStyle()} />
            </td>
         )`

   ###*
   * Функция получения ячейки с пользовательскими кнопками.
   *
   * @return {Array<React-Element>}
   ###
   _getButtonsCell: ->
      buttons = @props.buttons
      accordionHeader = this

      # Подготавливаем набор пользовательских кнопок.
      if buttons? and buttons.length
         buttons.map ((buttonParams, idx) ->
            onClickHandler = buttonParams.onClick
            buttonValue = buttonParams.value

            if buttonValue? and onClickHandler?
               buttonValue.onClickHandler = onClickHandler

            `(
               <td style={this.styles.userButtonsCell}
                   key={idx}>
                  <Button {...buttonParams}
                          value={buttonValue}
                          onClick={accordionHeader._onClickUserButton}
                        />
               </td>
            )`
         ).bind(this)


   ###*
   * Функция получения ячейки контроллирующей иконки (свернуто/развернуто).
   *
   * @return {React-Element}
   ###
   _getControlIconCell: ->

      icon =
         if @props.isExpanded
            @state.controlIcons.expanded
         else
            @state.controlIcons.collapsed

      `(
         <td style={this.styles.iconCell}>
            <i style={this.styles.iconStyle}
               className={this._FA_ICONS_PREFIX + icon}>
            </i>
         </td>
      )`


   ###*
   * Функция, возвращающая стили сервисных иконок.
   *
   * @return {onject} - скомпанованный стиль иконок.
   ###
   _getServiceIconAdditionStyle: ->
      isExpanded = @props.isExpanded
      controlStyles = @state.controlStyles
      additionStyle = if @state.isInHover or @props.isExpanded
                         controlStyles.highlight
                      else
                         controlStyles.common

      @computeStyles {color: additionStyle.color}, @styles.serviceIcon

   ###*
   * Функция, возвращающая стили компонента/
   *
   * @return {onject} - скомпанованный стиль компонента
   ###
   _getAccordionItemHeaderStyle:->
      controlStyles = @state.controlStyles

      @computeStyles controlStyles.common,
                     (@state.isInHover or @props.isExpanded) and controlStyles.highlight

   ###*
   * Функция получения стилей, контролирующих отображение компонента.
   *
   * @return {Object} - стили. Вид:
   *          {Object} common    - основные стили (элемент не раскрыт).
   *          {Object} highlight - стили подсветки (элемент раскрыт или в фокусе).
   ###
   _getInitControlStyles: ->
      styleAddition = @props.styleAddition
      isHasAdditionStyle = styleAddition?

      common: @computeStyles @styles.common,
                             isHasAdditionStyle and styleAddition.common
      highlight: @computeStyles @styles.highlightBack,
                                isHasAdditionStyle and styleAddition.highlightBack

   ###*
   * Функция получения управляющих иконок (иконки отображения скрытости/раскрытости) элемента.
   *
   * @return {Object} - набор иконок. Вид:
   *                 {String} expanded - иконка при раскрытом элементе.
   *                 {String} collapsed  - иконка при закрытом элементе.
   ###
   _getInitControlIcons: ->
      controlIcons = @props.controlIcons

      getDefaultIcon = (isCollapsed) ->
         navigatorModPosition =
            if @_isNavigatorMode()
               @props.navigatorModParams.position
         navigatorModPositions = @props.navigatorModPositions
         defaultIcons = @_DEFAULT_ICONS
         caretRightIcon = defaultIcons.caretRight
         caretLeftIcon = defaultIcons.caretLeft
         caretDownIcon = defaultIcons.caretDown

         # Если аккордеон в режиме навигатора - получим иконки в зависимости
         #  от позиционирования заголовков секций.
         # Иначе получаем иконки для стандартного аккордеона.
         if navigatorModPosition?

            # Если - заголовки слева.
            # Иначе - заголовки справа.
            if navigatorModPosition is navigatorModPositions.left
               if isCollapsed
                  caretLeftIcon
               else
                  caretRightIcon
            else
               if isCollapsed
                  caretRightIcon
               else
                  caretLeftIcon
         else
            if isCollapsed
               caretLeftIcon
            else
               caretDownIcon

      if controlIcons? and !$.isEmptyObject controlIcons
         expandedIcon = controlIcons.expanded
         collapsedIcon = controlIcons.collapsed

      unless expandedIcon?
         expandedIcon = getDefaultIcon.call(this, false)

      unless collapsedIcon?
         collapsedIcon = getDefaultIcon.call(this, true)

      expanded: expandedIcon
      collapsed: collapsedIcon

   ###*
   * Функция-предикат для определения находится ли аккордеон в режиме навигатора.
   *
   * @return {Boolean}
   ###
   _isNavigatorMode: ->
      navigatorModParams = @props.navigatorModParams
      navigatorModParams? and !$.isEmptyObject(navigatorModParams)

   ###*
   * Функция, обрабытывающая клик по служебной иконке.
   *
   * @return
   ###
   _onClickService:(value, event) ->
      event.stopPropagation()

   ###*
   * Функция, вызываемая при удалении курсора с компонента, запускает анимацию изменения границы
   *  компонента
   *
   * @return
   ###
   _onMouseLeave:->
      @setState isInHover: false

   ###*
   * Функция, вызываемая при наведении курсора на компонент, запускает анимацию изменения границы
   *  компонента
   *
   * @return
   ###
   _onMouseEnter:->
      @setState isInHover: true

   ###*
   * Обработчик клика на заголовок. Вызывает обработчик onClick, заданный через свойства.
   *
   * @return
   ###
   _onClick: ->
      enableDeactivate = @props.enableDeactivate
      isExpanded = @props.isExpanded

      # Если не разрешена деактивация и элемент активирован не вызываем обрабтчик.
      if (isExpanded and enableDeactivate) or !isExpanded
         @props.onClick(@props.index, !isExpanded)


   ###*
   * Обработчик клика по пользовательской кнопке. Прерывает проброс события
   *  для того, чтобы не вызывался клик по заголовку.. Получает параметры
   *  кнопки (заранее подготовленные при построении) и если был задан обработчик
   *  клика, то вызывает этот обработчик, предварительно удалив из параметров значения
   *  этот обработчик.
   *
   * @param {Object} value - значения кнопки.
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickUserButton: (value, event)->
      event.stopPropagation()
      onClickHandler = value.onClickHandler

      if onClickHandler?
         delete value.onClickHandler
         onClickHandler value, event


###* Компонент: AccordionContent - контент элемента аккордеона, часть компонента Accordion
*
* @props:
*     {String} identifier         - идентификатор секции.
*     {String} index              - порядковый номер элемента.
*     {React-Elemnt,
*      Array,
*      String} content            - содержимое элемента.
*     {Object} styleAddition      - дополнительные стили.
*     {Object} styleAdditionItem  - дополнительные стили для элемента содержимого
*                                   (AccordionContentItem).
*     {Boolean} isExpanded        - флаг раскрытия.
*     {Function} onExpandComplete - обработчик на окончание раскрытия
* @state:
*     {Boolean} isDefaultHeight - флаг сброса фиксированной высоты.
*     {Boolean} isList          - флаг, свидетельствующий, что контент содержит список
###
AccordionContent = React.createClass
   # @const {String} - наименование ссылки на контейнер содержимого элемента.
   _ACCORDION_ITEM_REF: 'accordionItem'

   # @const {String} - строка для формирования ключа элемента содержимого.
   _LI_PREFIX: 'li'

   mixins: [HelpersMixin, AnimateMixin, AnimationsMixin.collapse]

   styles:
      common:
         backgroundColor: _COLORS.light
         overflow: 'hidden'
         paddingLeft: 1
         paddingRight: 1
      defaultHeight:
         height: ''
      isHidden:
         height: 0
      ulStyle:
         listStyleType: 'none'
         margin: 0
         padding: 0
      contentPadding:
         borderColor: _COLORS.hierarchy4

   contextTypes:
      parentsIdentifier: React.PropTypes.array
      parents: React.PropTypes.array

   childContextTypes:
      parentIdentifier: React.PropTypes.string
      parentsIdentifier: React.PropTypes.array
      parents: React.PropTypes.array

   getChildContext: ->
      parentsIdentifier = @context.parentsIdentifier
      parents = @context.parents
      identifier = @props.identifier

      newParents = if parents?
                      parents.concat(this)
                   else
                      [this]

      newParentsIdentifier = if parentsIdentifier?
                                parentsIdentifier.concat(identifier)
                             else
                                [identifier]

      parentIdentifier: @props.identifier
      parentsIdentifier: newParentsIdentifier
      parents: newParents

   getInitialState: ->
      isList: @props.content instanceof Array
      isDefaultHeight: false

   componentWillReceiveProps: (nextProps) ->
      isExpandedNext = nextProps.isExpanded
      isExpanded = @props.isExpanded

      # Если текущее значение "раскрытости" не совпадает со следующим, то
      #  запустим логику скрытия или закрытия в зависимости от следующего флага.
      # Иначе, если компонент уже развернут - установим флаг сброса высоты.
      if isExpanded isnt isExpandedNext #and !$.isInAnimation
         if isExpandedNext
            @_openTheElement()
         else
            @_closeTheElement()
      else if isExpanded
         @setState isDefaultHeight: isExpanded

   render: ->
      `(
         <div style={this._getItemContentStyle()}>
            <div style={this.styles.contentPadding}
                 ref={this._ACCORDION_ITEM_REF}>
               {this._getItemContent()}
            </div>
         </div>
      )`

   ###*
   * Функция, возвращающая содержимое компонента. В случае, если переданный контент является
   *  массивом, функция возвращает ненумерованый список ссылок.
   *
   * @return {React-DOM-Element} - содержимое компонента.
   ###
   _getItemContent: ->
      content = @props.content

      if @state.isList
         styleAdditionItem = @props.styleAdditionItem
         `(
            <List items={content}
                  styleAddition={{item: styleAdditionItem}}
                  onSelect={this._onSelectItem}
                />
          )`
      else
         `(
            <AccordionContentIsolated content={content} />
         )`

   ###*
   * Функция получения скомпанованного стиля содержимого аккордеона..
   *
   * @return {Object} - скомпанованный стиль.
   ###
   _getItemContentStyle: ->
      isExpanded = @props.isExpanded

      @computeStyles @styles.common,
                     @props.styleAddition,
                     !isExpanded and @styles.isHidden,
                     @getAnimatedStyle('animate-collapse'),
                     isExpanded and @state.isDefaultHeight and @styles.defaultHeight

   ###*
   * Обработчик выбора элемента.
   *
   * @param {Object} item  - параметры элемента.
   * @param {Number} index - индекс элемента.
   * @return
   ###
   _onSelectItem: (item, index) ->
      onActivateHandler = item.onActivate
      item.onActivate(item) if onActivateHandler

   ###*
   * Функция, запускающая анимацию открытия элемента аккордеона. Сбрасывает флаг
   *  сброса фиксированной высоты.
   *
   * @return
   ###
   _openTheElement: ->
      @collapseOut @_collapseOutComplete,
                   @refs[@_ACCORDION_ITEM_REF].scrollHeight

      @setState isDefaultHeight: false

   ###*
   * Функция, запускающая анимацию закрытия элемента аккордеона. Устанавливает флаг
   *  сброса фиксированной высоты.
   *
   * @return
   ###
   _closeTheElement: ->
      @collapseIn @_collapseInComplete,
                  @refs[@_ACCORDION_ITEM_REF].scrollHeight

      @setState isDefaultHeight: false


   ###*
   * Функция, срабатывающая по завершении анимации разворачивания. Запускает
   *  обработчик на окончание разворачивания, если задан и устанавливает флаг
   *  сброса фиксированной высоты.
   *
   * @return
   ###
   _collapseOutComplete: ->
      onExpandCompleteHandler = @props.onExpandComplete

      if onExpandCompleteHandler?
         onExpandCompleteHandler()

      @setState isDefaultHeight: true

   ###*
   * Функция, срабатывающая по завершении анимации сворачивания. Сбрасывает флаг
   *  сброса фиксированной высоты.
   *
   * @return
   ###
   _collapseInComplete: ->
      @setState isDefaultHeight: false

###* Компонент: изолированный контент секции аккордеона - часть компонента AccordionContent.
*    Данный компонент сделан, чтобы отсекать проброс свойств аккордеона в содержимое, т.к.
*    при сложном содержимом и анимации секции идет глубокий проброс свойств и как результат
*    земедленный интерфейс.
*
* @props:
*     {React-Element} content - содержимое.
###
AccordionContentIsolated = React.createClass
   mixins: [PureRenderMixin]

   render: ->
      `(
         <span>{this.props.content}</span>
       )`

module.exports = Accordion
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
DOMOperationsMixin = require('../mixins/dom_operations')
AnimationsMixin = require('../mixins/animations')
AnimateMixin = require('react-animate')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* ArbitraryArea - произвольная область.
* Button        - кнопка.
* List          - список.
###
ArbitraryArea = require('./arbitrary_area')
Button = require('./button')
List = require('./list')

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


# @const - константа для хранения стиля активной вкладки, нельзя хранить в компоненте,
#  т.к. нужен доступ при формировании члена-хэша со стилями компонента styles.
_ACTIVE_STYLE =
   borderStyle: 'solid'
   borderWidth: 3
   borderColor: _COLORS.main
   color: _COLORS.main


###* Компонент: контейнер с вкладками
* @props:
*     {Array} tabCollection    - массив с коллекцией вкладок
*            {Object} item     - член массива должен быть вида:
*                      {
*                          {string} name    - имя
*                          {String} title   - подсказка на заголовке.
*                          {String} caption - заголовок вкладки.
*                    {Object} captionParams - параметры заголовка. Вид:
*                          {Array<Object>} functionalButtons - коллекция параметров для
*                                                              функциональных кнопок, выводимых в заголовке.
*                          {Srting} icon    - наименование иконки из FontAwesome,
*                          {node} content   - содержимое вкладки,
*                                             может быть React-компонент,
*                                             текст, или DOM-объект
*                          {Object} context - контекст в котором будет находится элемент.
*                                             Нужен для рендера содержимого.
*                         {Function} render - функция-рендер, запускаемая для
*                                             формирования содержимого. Если задан
*                                             параметр content - не запускается
*                      }
*     {Number} activeIndex      - индекс активной вкладки(по-умолчанию = 0)
*     {Number} maxTabCountPerLine - максимальное кол-во вкладок для
*                                   раздела "Данные" в одну линию. Если
*                                   общее кол-во вкладок будет выходить за заданный
*                                   максимум - будет добавляться вкладка выбора
*                                   остальных с пометкой '...'
*     {String} navigatorPosition - позиционирование селекторов вкладок.
*                                Варианты:
*                                "top"    - сверху.
*                                "bottom" - снизу.
*                                "right"  - справа.
*                                "left"   - слева.
*   {Boolean} enableTriggerNav - флаг разрешения скрытия/показа навигатора вкладок.
*                                По-умолчанию = false.
*    {Boolean} enableLazyMount - флаг "ленивого" монтирования содержимого вкладок.
*                                Если задан "положительный" флаг, то содержимое
*                                вкладок будут добавлены в компонент, только по
*                                запросу (активация таба). По-умолчанию = false
*   {Boolean} isStretchContent - флаг необходимости растягивать контент. Если
*                                флаг задан то добавляет контейнеру с содержимым
*                                вкладки ширину 100%. Параметр актуален при
*                                вертикальном размещении навигатора.
*                                По-умолчанию = false
*     {Boolean} isClassic      - флаг "классического" вида контейнера таб-вкладок.
*                                По-умолчанию = false.
*     {Object} styleAddition   - хэш с дополнительными стилями компонента. Вид:
*              {Object} common - доп. стили для всего компонента.
*              {Object} navigator - доп. стили для навигатора.
*              {Object} content - доп. стили для контейнера содержимого.
*     {Function} onClickTab    - функция, вызываемая при изменении индекса. Аргументы:
*                              {Number} index     - индекс выбранной вкладки.
*                              {Object} tabParams - параметры выбранной вкладки.
* @state:
*     {Number} activeIndex - индекс активной вкладки.
*     {Boolean} isNavShown - флаг показанности навигатора вкладок. Изначально = true
###
Taber = React.createClass

   # @const {Object} - позиции селектора
   _NAVIGATOR_POSITIONS: keyMirror(
      top: null
      bottom: null
      right: null
      left: null
   )

   mixins: [HelpersMixin]

   styles:
      tabTable:
         padding: 0
         # maxWidth: '100%'
         # maxHeight: '100%'
      horizontalContainer:
         position: 'relative'
      tabNavCell:
         padding: 0
         #width: '1%'
#     contentContainer:
#         borderWidth: 0
#         borderStyle: 'solid'
#         borderColor: _COLORS.hierarchy4
      stretchContent:
         width: '100%'
      tabCell:
         verticalAlign: 'top'
         height: '100%'

   # требуемые типы свойств
   propTypes:
      activeIndex: React.PropTypes.number
      tabCollection: React.PropTypes.arrayOf(React.PropTypes.object).isRequired
      navigatorPosition: React.PropTypes.oneOf(['top', 'right', 'bottom', 'left'])
      styleAddition: React.PropTypes.object
      isStretchContent: React.PropTypes.bool
      isClassic: React.PropTypes.bool
      enableTriggerNav: React.PropTypes.bool
      enableLazyMount: React.PropTypes.bool

   getDefaultProps: ->
      # Активный таб по умолчанию, если не задан.
      activeIndex: 0
      navigatorPosition: 'top'
      enableTriggerNav: false
      enableLazyMount: false
      isStretchContent: false
      isClassic: false

   getInitialState: ->
      activeIndex: @props.activeIndex
      isNavShown: true

   componentWillReceiveProps: (nextProps) ->
      activeIndex = @state.activeIndex
      tabCollection = nextProps.tabCollection

      # Если индекс текущей активной вкладки превышает следующее
      #  кол-во табов - то скинем индекс.
      if activeIndex > (tabCollection.length - 1)
         @setState activeIndex: 0

   render: ->
      @_getTaberLayout()

   ###*
   * Формирования содержимого компонента. В зависимости от заданного позиционирования
   *  селекторов вкладок формирует различную разметку.
   *
   * @return {React-element} - разметка компонента содержимое метода render.
   ###
   _getTaberLayout: ->
      navigatorPosition = @props.navigatorPosition
      positions = @_NAVIGATOR_POSITIONS
      selectorsNode = @_getSelectorNode()
      contentsNode = @_getContentsNode()
      isStretchContent = @props.isStretchContent
      isVerticalPositionSelectors = true
      tabNavCellStyle = @styles.tabNavCell
      contentContainerStyle = @styles.contentContainer
      styleAddition = @props.styleAddition
      componentStyleAddition = styleAddition.common if styleAddition?
      isContentLeft = false

      switch navigatorPosition
         when positions.right
            rightNode = selectorsNode
            leftNode = contentsNode
            isVerticalPositionSelectors = false
            isContentLeft = true
            additionRightStyle = tabNavCellStyle
            additionLeftStyle = contentContainerStyle
         when positions.left
            rightNode = contentsNode
            leftNode = selectorsNode
            isVerticalPositionSelectors = false
            additionLeftStyle = tabNavCellStyle
            additionRightStyle = contentContainerStyle
         when positions.bottom
            topNode = contentsNode
            bottomNode = selectorsNode
            additionTopStyle = contentContainerStyle
         else
            topNode = selectorsNode
            bottomNode = contentsNode
            additionBottomStyle = contentContainerStyle

      # Если было задано вертикальное позиционирование вкладок (сверху, снизу),
      #  то формирует обычную блочную разметку.
      # Иначе формируем таблицу для корректного расположения вкладок слева или
      #  справа.
      if isVerticalPositionSelectors
         `(
            <div style={componentStyleAddition}>
               <div style={additionTopStyle}>
                  {topNode}
               </div>
               <div style={additionBottomStyle}>
                  {bottomNode}
               </div>
            </div>
          )`
      else
         tabCellStyle = @styles.tabCell
         stretchContentStyle = @styles.stretchContent

         computedLeftCellStyle = @computeStyles tabCellStyle,
            additionLeftStyle,
            isStretchContent and isContentLeft and stretchContentStyle
         computedRightCellStyle = @computeStyles tabCellStyle,
            additionRightStyle,
            isStretchContent and !isContentLeft and stretchContentStyle

         computedTabTableStyle = @computeStyles @styles.tabTable,
                                 componentStyleAddition

         `(
            <table style={computedTabTableStyle}
                   cellPadding='0'>
               <tbody>
                  <tr>
                     <td style={computedLeftCellStyle}>
                        {leftNode}
                     </td>
                     <td style={computedRightCellStyle}>
                        {rightNode}
                     </td>
                  </tr>
               </tbody>
            </table>
         )`

   ###*
   * Функция получения узла с набором содержимого вкладок.
   *
   * @rerurn {React-element} - узел с набором содержимого вкладок.
   ###
   _getContentsNode: ->
      styleAddition = @props.styleAddition
      styleAdditionContent = styleAddition.content if styleAddition?

      `(
          <TaberContent tabCollection={this.props.tabCollection}
                        styleAddition={styleAdditionContent}
                        activeIndex={this.state.activeIndex}
                        isClassic={this.props.isClassic}
                        enableLazyMount={this.props.enableLazyMount}
                     />
       )`

   ###*
   * Функция получения узла с набором селекторов вкладок.
   *
   * @rerurn {React-element} - узел с набором селекторов.
   ###
   _getSelectorNode: ->
      styleAddition = @props.styleAddition
      styleAdditionNavigator = styleAddition.navigator if styleAddition?

      `(
         <TaberNavigator tabCollection={this.props.tabCollection}
                         styleAddition={styleAdditionNavigator}
                         activeIndex={this.state.activeIndex}
                         maxTabCountPerLine={this.props.maxTabCountPerLine}
                         position={this.props.navigatorPosition}
                         positions={this._NAVIGATOR_POSITIONS}
                         isClassic={this.props.isClassic}
                         enableTrigger={this.props.enableTriggerNav}
                         onClickTabHeader={this._onClickTabHeader}
                      />
       )`

   ###*
   * Обработчик клика по селектору вкладки.
   *
   * @param {Number} index - индекс выбранной вкладки.
   * @return
   ###
   _onClickTabHeader: (index) ->
      tabCollection = @props.tabCollection
      selectedTab = tabCollection[index]
      onClickTabHandler = @props.onClickTab

      onClickTabHandler(index, selectedTab) if onClickTabHandler?

      @setState activeIndex: index

###* Компонент содержимого вкладок. Часть компонента Taber.
*
* @props
*     {Array<Object>} tabCollection - коллекция содержимого таб-вкладок.
*     {Object} styleAddition        - доп. стили.
*     {Boolean} isClassic           - флаг "классического" контейнера таб-вкладок.
*     {Boolean} enableLazyMount     - флаг "ленивого" монтирования содержимого
*     {Number} activeIndex          - индекс активного таба.
* @state
*     {Array} activatedIndexes - массив "активированных" индексов. Параметр
*                                используется в режиме "ленивого" монтирования.
###
TaberContent = React.createClass
   # @const {String} - префикс для ключа элемента-содержимого в коллекции.
   _KEY_PREFIX: 'content_'

   mixins: [HelpersMixin]

   styles:
      classicContainer:
         borderWidth: 1
         borderStyle: 'solid'
         borderColor: _COLORS.hierarchy3
         height: '100%'

   getInitialState: ->
      activatedIndexes: [@props.activeIndex]

   componentWillReceiveProps: (nextProps) ->

      # Если разрешено "ленивое" монтирование, то пробуем добавить индекс текущей
      #  активной вкладки в набор активированных, если она уже не присутствует
      #  в наборе.
      if nextProps.enableLazyMount
         activatedIndexes = @state.activatedIndexes[..]
         nextActiveIndex = nextProps.activeIndex
         isNextIndexNotConsidered =
            _.indexOf(activatedIndexes, nextActiveIndex) < 0

         # Если индекс не был ранее добавлен, то добавляем в набор.
         if isNextIndexNotConsidered
            activatedIndexes.push nextActiveIndex

            @setState activatedIndexes: activatedIndexes

   render: ->
      `(
         <div style={this._getContentStyle()}>
            {this._getTabContents()}
         </div>
       )`

   ###*
   * Функция формирования наборов элементов содержимого.
   *
   * @return {Array<React-element>} - набора элементов содержимого.
   ###
   _getTabContents: ->
      tabCollection = @props.tabCollection
      isClassic = @props.isClassic
      activeIndex = @props.activeIndex
      enableLazyMount = @props.enableLazyMount
      activatedIndexes = @state.activatedIndexes
      contents = []

      # Переребем набор параметров для вкладок и сформируем массив элементов
      #  содержимого.
      for item, idx in tabCollection
         isActive = idx is activeIndex
         # Определим флаг необходимости добавления в коллекцию в зависимости
         #  от того, задан ли флаг "ленивого" монтирования.
         isNeedAddToCollection = if enableLazyMount
                                    _.indexOf(activatedIndexes, idx) >= 0
                                 else
                                    true

         if isNeedAddToCollection
            contents.push(
               `(
                  <TabContent key={this._KEY_PREFIX + idx}
                              content={item.content}
                              render={item.render}
                              context={item.context}
                              isActive={isActive}
                           />
                )`
            )

      contents

   ###*
   * Функция получения стиля для контейнера содержимого вкладок. Добавляет
   *  особый стиль для "классического" контейнера.
   *
   * @return {Object, null}
   ###
   _getContentStyle: ->
      @computeStyles @props.isClassic and @styles.classicContainer,
                     @props.styleAddition

###* Компонент - навигатор вкладок. Часть компонента Taber.
*
* @props:
*     {Array<Object>} tabCollection - массив элементов табов.
*     {Object} styleAddition        - доп. стили.
*     {String} position             - позиционирование навигатора в элементе.
*     {Number} activeIndex          - индекс текущей активной вкладки.
*     {Number} maxTabCountPerLine   - максимальное кол-во вкладок в линию.
*     {Boolean} isClassic           - флаг "классического" таб-контейнера.
*     {Boolean} enableTrigger       - флаг возможности скрытия/показа навигатора.
*     {Object} positions            - набор возможных позиций.
*     {Function} onClickTabHeader   - обработчик клика на заголовок влкадки. Аргументы:
*                                     {Number} index - индекс владки.
* @state:
*     {Boolean} isShown             - флаг показанности навигатора.
*     {Boolean} isRestTabsShown     - флаг показанности панели других вкладок
*                                     (не уместившихся в линию).
*     {Boolean} isHasScroll         - флаг того что контейнер имеет прокрутку.
*     {Number} selectedRestTabIndex - индекс выбранной вкладки из набора других
*                                     (не уместившихся в линию).
###
TaberNavigator = React.createClass

   mixins: [HelpersMixin, DOMOperationsMixin]

   # @const {Object} - иконки для кнопки-триггера навигации.
   _TRIGGER_ICONS:
      right: 'chevron-right'
      left: 'chevron-left'
      top: 'chevron-up'
      bottom: 'chevron-down'

   # @const {Object} - всплывающие пояснения для кнопки-триггера навигации.
   _TRIGGER_TITLES:
      hide: 'Скрыть навигатор'
      show: 'Показать навигатор'

   # @const {Object} - параметры для области панели остальных вкладок.
   _REST_TABS_PANEL_AREA_PARAMS:
      isHasShadow: true
      isCatchFocus: true
      position:
         vertical:
            top: 'bottom'
         horizontal:
            right: 'right'

   # @const {Object} - наименования ссылок.
   _REFS: keyMirror(
      container: null
      buttonRest: null
   )

   # @const {Object} - параметры для селектора остальных вкладок(не
   #                   уместившихся в линию).
   _REST_TABS_SELECTOR_PARAMS:
      caption: '...'
      title: 'Остальные вкладки'

   styles:
      tabNavigate:
        # overflow: 'auto'
         whiteSpace: 'nowrap'
        # height: '100%'
         lineHeight: 0
      tabNavigateClassic:

         lineHeight: ''
      tabNavigateHide:
         display: 'none'
      tabNavigateContainer:
         position: 'relative'
         backgroundColor: _COLORS.hierarchy4
         #overflow: 'auto'
         height: '100%'
         zIndex: 2
      horizontalWithScroll:
         display: 'flex'
         overflowX: 'auto'
         overflowY: 'hidden'
      tabNavigateContainerClassic:
         backgroundColor: ''
      tabNavigateHorizontal:
         overflowX: 'hidden'
      tabNavigateContainerTop:
         marginBottom: -1
      tabNavigateContainerBottom:
         marginTop: -1
      tabNavigateContainerLeft:
         marginRight: -1
      tabNavigateContainerRight:
         marginLeft: -1
      tabsList:
         padding: 0
         margin: 0
         listStyleType: 'none'
         #overflow: 'auto'
      triggerNavHorizontal:
         backgroundColor: _COLORS.hierarchy3
         textAlign: 'center'
         position: 'absolute'
         opacity: 0.4
         width: '100%'
         borderRadius: 0
         padding: 0
         bottom: 0
      triggerNavVertical:
         backgroundColor: _COLORS.hierarchy3
         opacity: 0.4
         borderRadius: 0
         minHeight: ''
         width: 40
         position: 'absolute'
         top: 0
         right: 0
         bottom: 0
      releaseNavigatorTrigger:
         width: '100%'
         height: '100%'
         fontSize: 8
         padding: 2
         opacity: 0.2
      resetAbsolute:
         position: ''
      restListCommon:
         maxHeight: 400
         overflow: 'auto'
         fontSize: 12

   getInitialState: ->
      isShown: true
      isHasVerticalScroll: null
      isHasHorizontalScroll: null

   componentWillReceiveProps: (nextProps) ->
      @_resetScrollFlags()

   render: ->
      `(
         <div style={this._getTabContainerStyle()}
              ref={this._REFS.container} >
            <nav style={this._getNavStyle()}>
               <ul style={this.styles.tabsList}>
                  {this._getTabHeaders()}
               </ul>
            </nav>
            {this._getRestTabsPanel()}
            {this._getTriggerNav()}
         </div>
      )`

   componentDidUpdate: ->
      @_setScrollFlags()

   componentDidMount: ->
      @_setScrollFlags()

   ###*
   * Функция получения произвольной области для отображения панели выбора
   *  остальных (не показанных в линию вкладок).
   *
   * @return {React-element}
   ###
   _getRestTabsPanel: ->
      restTabsAreaParams = @_REST_TABS_PANEL_AREA_PARAMS
      areaTarget = if @state.isRestTabsShown
                      @refs[@_REFS.buttonRest]

      `(
         <ArbitraryArea target={areaTarget}
                        content={this._getRestTabsContent()}
                        onHide={this._onHideRestTabsPanel}
                        {...restTabsAreaParams}
                     />
       )`

   ###*
   * Функция получения содержимого панели остальных вкладок. Создает элемент
   *  списка с возможностью выбора элементов.
   *
   * @return {React-element} - список остальных вкладок.
   ###
   _getRestTabsContent: ->
      tabCollectionClone = _.clone(@props.tabCollection)
      maxTabCountPerLine = @props.maxTabCountPerLine
      selectedRestTabIndex = @state.selectedRestTabIndex
      # Если задан индекс выбранной вкладки из остальных (неуместившихся),
      #  то определим индекс элемента в списке, который нужно будет скрывать.
      indexHiddenElementInList =
         if selectedRestTabIndex?
            selectedRestTabIndex - maxTabCountPerLine - 1

      restTabs = tabCollectionClone.slice(maxTabCountPerLine + 1)

      # Переберем все элементы в списке остальных и определим флаг скрытости.
      for restTab, idx in restTabs
         restTabs[idx].isHidden = idx is indexHiddenElementInList

      `(
         <List items={restTabs}
               styleAddition={{common: this.styles.restListCommon}}
               onSelect={this._onSelectRestTab}
             />
       )`

   ###*
   * Функция получения набора заголовков вкладок.
   *
   * @return {Array<React-element>}
   ###
   _getTabHeaders: ->
      tabCollection = @props.tabCollection
      maxTabCountPerLine = @props.maxTabCountPerLine
      selectedRestTabIndex = @state.selectedRestTabIndex
      isTabsOverflowing = false
      tabs = []


      # Переберем массив вкладок и для каждого элемента получим элемент заголовка.
      for item, idx in tabCollection

         # Если макс. кол-во в линию задано и индекс превысил это кол-во - больше
         #  не добавляем вкладки, устанавливаем флаг переполнения и выходим из цикла.
         if maxTabCountPerLine? and idx > maxTabCountPerLine
            isTabsOverflowing = true
            break
         else
            tabs.push(
               @_getTabHeader(
                  index: idx
                  tabItem: item
                  onClick: @_onClickTabHeader
               )
            )

      # Если вкладки переполнились (кол-во вышло за максимум), то добавляем
      #  селектор остальных вкладок и, если была выбрана вкладка из остальных
      #  добавляем выбранную в набор
      if isTabsOverflowing
         restSelectoroIndex = ++maxTabCountPerLine
         restSelectorParams = @_REST_TABS_SELECTOR_PARAMS

         if selectedRestTabIndex?
            selectedRestTab = tabCollection[selectedRestTabIndex]

            if selectedRestTab?
               tabs.push(
                  @_getTabHeader(
                     index: selectedRestTabIndex
                     tabItem: selectedRestTab
                     # caption: selectedRestTab.caption
                     # subCaption: selectedRestTab.subCaption
                     # title: selectedRestTab.title
                     # icon: selectedRestTab.icon
                     onClick: @_onClickTabHeader
                  )
               )

               # Селектор остальных вкладок должен иметь индекс отличный от выбранного
               restSelectoroIndex = selectedRestTabIndex + 1

         tabs.push(
            @_getTabHeader(
               ref: @_REFS.buttonRest
               index: restSelectoroIndex
               tabItem: restSelectorParams
               # caption: restSelectorParams.caption
               # title: restSelectorParams.title
               onClick: @_onClickRestTabs
            )
         )

      tabs

   ###*
   * Функция создания заголовка вкладки.
   *
   * @param {Object} params - параметры для заголовка.
   * @return {React-element}
   ###
   _getTabHeader: (params) ->
      isClassic = @props.isClassic
      navPosition = @props.position
      navPositions = @props.positions
      headerIndex = params.index
      isActive = headerIndex is @props.activeIndex

      `(
         <TabHeader key={headerIndex}
                    index={headerIndex}
                    ref={params.ref}
                    tabItem={params.tabItem}
                    onClick={params.onClick}
                    isActive={isActive}
                    isClassic={isClassic}
                    position={navPosition}
                    positions={navPositions}
                  />
      )`

   ###*
   * Функция получения кнопки триггера навигационных элементов.
   *
   * @return {React-element}
   ###
   _getTriggerNav: ->
      if @props.enableTrigger
         navigatorPosition = @props.position
         positions = @props.positions
         rightPosition = positions.right
         leftPosition = positions.left
         bottomPosition = positions.bottom
         topPosition = positions.top
         triggerIcons = @_TRIGGER_ICONS
         triggerTitles = @_TRIGGER_TITLES
         triggerNavVerticalStyle = @styles.triggerNavVertical
         triggerNavHorizontalStyle = @styles.triggerNavHorizontal
         isVerticalPositioning =
            _.includes([bottomPosition, topPosition], navigatorPosition)
         isHorizontalPositioning =
            _.includes([rightPosition, leftPosition], navigatorPosition)
         isHasScroll = @state.isHasVerticalScroll or @state.isHasHorizontalScroll
         isNavigatorHide = !@state.isShown

         positionStyle =
            if isVerticalPositioning
               triggerNavVerticalStyle
            else
               triggerNavHorizontalStyle

         buttonStyle = @computeStyles positionStyle,
            (isHasScroll or isNavigatorHide) and @styles.resetAbsolute
            isNavigatorHide and @styles.releaseNavigatorTrigger

         icon =
            if isNavigatorHide
               oppositePosition = @_getOppositeNavigatorPosition(navigatorPosition)
               triggerIcons[oppositePosition]
            else
               triggerIcons[navigatorPosition]

         title =
            if isNavigatorHide
               triggerTitles.show
            else
               triggerTitles.hide

         `(
            <Button styleAddition={buttonStyle}
                    icon={icon}
                    title={title}
                    isWithoutPadding={true}
                    onClick={this._onClickTriggerNav}
                 />
          )`

   ###*
   * Функция получения стилей для контейнера навигатора. В зависимости от
   *  заданной позиции навигатора добавляет специфичный стиль для смещения
   *  контейнера навигатора.
   *
   * @return {Object} - скомпанованные стили.
   ###
   _getTabContainerStyle: ->
      position = @props.position
      positions = @props.positions
      topPosition = positions.top
      bottomPosition = positions.bottom
      leftPosition = positions.left
      rightPosition = positions.right
      styles = @styles
      isHorizontalPositioning = _.includes([leftPosition, rightPosition], position)

      positionStyle =
         switch position
            when topPosition then styles.tabNavigateContainerTop
            when bottomPosition then styles.tabNavigateContainerBottom
            when leftPosition then styles.tabNavigateContainerLeft
            else styles.tabNavigateContainerRight

      @computeStyles styles.tabNavigateContainer,
                     positionStyle,
                     @props.isClassic and styles.tabNavigateContainerClassic,
                     @state.isHasHorizontalScroll and styles.horizontalWithScroll,
                     isHorizontalPositioning and styles.tabNavigateHorizontal,
                     @props.styleAddition

   ###*
   * Функция получения стилей для навигатора.
   *
   * @return {Object} - скомпанованные стили.
   ###
   _getNavStyle: ->
      @computeStyles @styles.tabNavigate,
                     @props.isClassic and @styles.tabNavigateClassic,
                     !@state.isShown and @styles.tabNavigateHide

   ###*
   * Функция получения наименования оппозиционной(противотоложной) позиции.
   *
   * @param {String} position - наименование позиции.
   * @return {String} - наименование оппозиционной позиции.
   ###
   _getOppositeNavigatorPosition: (position) ->
      positions = @props.positions
      rightPosition = positions.right
      leftPosition = positions.left
      bottomPosition = positions.bottom
      topPosition = positions.top

      switch position
         when rightPosition
            leftPosition
         when leftPosition
            rightPosition
         when topPosition
            bottomPosition
         else
            topPosition

   ###*
   * Функция установки флагов наличия прокрутки. Производит считывание и установки
   *  флагов только если они ещё не были установлены.
   *
   * @return
   ###
   _setScrollFlags: ->
      unless @state.isHasVerticalScroll?
         containerNode = ReactDOM.findDOMNode(@refs[@_REFS.container])

         @setState
            isHasVerticalScroll:
               @_isHasVerticalScroll(containerNode)
            isHasHorizontalScroll:
               @_isHasHorizontalScroll(containerNode, 1)

   ###*
   * Обработчик клика на кнопке показа остальных вкладок. Устанавливает
   *  флаг показа селектора прочих вкладок.
   *
   * @return
   ###
   _onClickRestTabs: (index)->
      @setState isRestTabsShown: true

   ###*
   * Обработчик на скрытие области панели остальных вкладок. Сбрасывает
   *  флаг показанности области панели остальных вкладок.
   *
   * @return
   ###
   _onHideRestTabsPanel: ->
      @setState isRestTabsShown: false

   ###*
   * Обработчик клика на элементе списка остальных вкладок (выбор для отображения
   *  вкладки, не уместившейся в линию с заданным maxTabCountPerLine).
   *
   * @param {Object} tabParams - параметры вкладки.
   * @param {Number} index     - индекс другой вкладки в списке других (начинается с 0).
   * @return
   ###
   _onSelectRestTab: (tabParams, index) ->
      maxTabCountPerLine = @props.maxTabCountPerLine
      selectedRestTabIndex = maxTabCountPerLine + index + 1

      @_processTabHeaderClick(selectedRestTabIndex)

      @setState
         selectedRestTabIndex: selectedRestTabIndex
         isRestTabsShown: false

   ###*
   * Обработчик клика на заголовок вкладки.
   *
   * @param {Number} index - индекс вкладки в наборе.
   * @return
   ###
   _onClickTabHeader: (index) ->
      @_processTabHeaderClick(index)

      @setState selectedRestTabIndex: null

   ###*
   * Обработчик клика на кнопку триггера навигатора (скрыть/показать).
   *
   * @return
   ###
   _onClickTriggerNav: ->
      @_resetScrollFlags()

      @setState isShown: !@state.isShown

   ###*
   * Функция обработки клика по заголовку вкладки. Если задан обработчик выбора
   *  вкладки - выполняет его, передав индекс влкдки в наборе.
   *
   * @param {Number} index - индекс вкладки.
   * @return
   ###
   _processTabHeaderClick: (index) ->
      onClickTabHeaderHandler = @props.onClickTabHeader
      onClickTabHeaderHandler index if onClickTabHeaderHandler?

   ###*
   * Функция сброса флагов наличия прокрутки.
   *
   * @return
   ###
   _resetScrollFlags: ->
      @setState
         isHasVerticalScroll: null
         isHasHorizontalScroll: null

###* Компонент: заголовок вкладки. Часть компонента Taber
*
* @props:
*     {Object} tabItem - параметры вкладки, для которой формируется заголовок. Вид:
*        {String} caption    - текст, выводимый на заголовке вкладки.
*        {Object} captionParams - параметры заголовка.
*        {String} subCaption - текст, выводимый над заголовком вкладки (подзаголовок
*                           для отображения второстепенной информации).
*        {String} title      - подсказка на заголовке вкладки.
*        {String} icon       - выводимая иконка.
*     {Number} index      - порядковый номер вкладки, начинается с 0.
*     {Boolean} isActive  - флаг, того, что вкладка активная.
*     {String} position   - позиционирование селекторов вкладок.
*     {Object} positions  - возможные позиции селекторов вкладок.
*     {Function} onClick  - обработчик клика по заголовку. Аргументы:
*                           {Number} index - индекс вкладки.
* @state
*     {Boolean} isSubCaptionOverflowing - флаг "переполненности" подзаголовка
*                                         (текст) полностью не влезает.
###
TabHeader = React.createClass

   # @const {String} - префикс для иконок FontAwesome.
   _FA_ICON_PREF: 'fa fa-'

   # @const {Object} - испольлзуемые наименования для ссылок на элементы.
   _REFS: keyMirror(
      subCaptionContainer: null
      subCaptionCell: null
   )

   # @const {Object} - заполнитель маркера "переполненности".
   _OVERFLOWING_MARKER_FILLER: '...'

   # @const {Number} - кол-во обязательных строк при построении сложного заголовка
   _MANDOTORY_ROWS_COUNT_FOR_COMPLEX: 2

   mixins: [HelpersMixin, AnimateMixin, AnimationsMixin.highlight]

   styles:
      common:
         color: _COLORS.hierarchy2
         fontSize: 15
         paddingTop: 10
         paddingBottom: 10
         paddingLeft: 10
         paddingRight: 10
         cursor: 'pointer'
      verticalPosition:
         display: 'inline-block'
      classicTab:
         borderBottomWidth: 1
         borderTopWidth: 1
         borderRightWidth: 1
         borderLeftWidth: 1
         borderColor: _COLORS.hierarchy3
         borderStyle: 'solid'
         backgroundColor: _COLORS.hierarchy4
         fontSize: 12
         color: _COLORS.hierarchy2
         paddingTop: 6
         paddingBottom: 6
         paddingLeft: 6
         paddingRight: 6
         #padding: 6
      resetPadding:
         paddingTop: 0
         paddingBottom: 0
         paddingLeft: 0
         paddingRight: 0
         #padding: 0
      classicRight:
         borderRadius: "0px #{_CBR} #{_CBR} 0px"
         marginBottom: -1
         verticalAlign: 'left'
        # borderLeftWidth: 0
      classicLeft:
         borderRadius: "#{_CBR} 0px 0px #{_CBR}"
         marginBottom: -1
         verticalAlign: 'right'
       #  borderRightWidth: 0
      classicBottom:
         borderRadius: "0px 0px #{_CBR} #{_CBR}"
         marginRight: -1
         verticalAlign: 'top'
        # borderTopWidth: 0
      classicTop:
         borderRadius: "#{_CBR} #{_CBR} 0px 0px"
         marginRight: -1 # borderBottomWidth: 0
         verticalAlign: 'bottom'
      activeTab:
         color: _ACTIVE_STYLE.color
      activeTop:
         borderBottomWidth: _ACTIVE_STYLE.borderWidth
         borderBottomStyle: _ACTIVE_STYLE.borderStyle
         borderBottomColor: _ACTIVE_STYLE.borderColor
      activeBottom:
         borderTopWidth: _ACTIVE_STYLE.borderWidth
         borderTopStyle: _ACTIVE_STYLE.borderStyle
         borderTopColor: _ACTIVE_STYLE.borderColor
      activeLeft:
         borderRightWidth: _ACTIVE_STYLE.borderWidth
         borderRightStyle: _ACTIVE_STYLE.borderStyle
         borderRightColor: _ACTIVE_STYLE.borderColor
      activeRight:
         borderLeftWidth: _ACTIVE_STYLE.borderWidth
         borderLeftStyle: _ACTIVE_STYLE.borderStyle
         borderLeftColor: _ACTIVE_STYLE.borderColor
      activeClassic:
         backgroundColor: _COLORS.light
         fontSize: 14
         position: 'relative'
      activeClassicWithSub:
         fontSize: 12
      activeTopClassic:
         paddingTop: 8
         borderBottomWidth: 0
         #bottom: -1
      activeBottomClassic:
         paddingBottom: 8
         borderTopWidth: 0
         #top: -1
      activeLeftClassic:
         paddingLeft: 8
         borderRigthWidth: 0
         right: -1
      activeRightClassic:
         paddingRight: 8
         borderLeftWidth: 0
         left: -1
      activeTopWithSub:
         paddingBottom: 6
      activeTopClassicWithSub:
         paddingTop: 4
      activeBottomClassicWithSub:
         paddingBottom: 4
      headerIcon:
         marginRight: _COMMON_PADDING
      iconCell:
         width: 23
         textAlign: 'center'
      functionalButtonCell:
         width: 1
      additionIconAlign:
         verticalAlign: 'middle'
         paddingLeft: _COMMON_PADDING
      highlight:
         color: _COLORS.highlight1
      simpleCaptionTable:
         width: '100%'
      functionalButton:
         padding: 0
      complexCaptionTable:
         position: 'relative'
         overflow: 'hidden'
         display: 'inline-block'
         paddingLeft: 2
         marginRight: _COMMON_PADDING
         marginLeft: _COMMON_PADDING
         height: 25
         #top: 2
      subCaptionCell:
         height: 12
         padding: 0
      withSubCaptionCaptionCell:
         padding: 0
         fontSize: 12
      subCaptionContainer:
         position: 'absolute'
         top: 2
         fontSize: 10
         color: _COLORS.hierarchy3
      overflowingMarker:
         position: 'absolute'
         backgroundColor: _COLORS.hierarchy4
         color: _COLORS.hierarchy3
         paddingRight: 2
         paddingLeft: 2
         height: 9
         right: 0
         lineHeight:  0.5
      overflowingMarkerActive:
         backgroundColor: _COLORS.light

   getInitialState: ->
      isSubCaptionOverflowing: false

   render: ->
      `(<li style={this._getStyle()}
            title={this.props.title}
            onClick={this._onClick}
            onMouseEnter={this._onMouseEnter}
            onMouseLeave={this._onMouseLeave}>
            {this._getElementContent()}
        </li>)`

   componentDidMount: ->
      @_detectSubCaptionOverflowing()

   ###*
   * Функция получения содержимого надписи на заголовке вкладки. Если задан параметр
   *  подзаголовка - генерирует особую структуру для вывода основного заголовка
   *  и подзаголовка.
   *
   * @return {React-element}
   ###
   _getElementContent: ->
      tabItem = @props.tabItem
      subCaption = tabItem.subCaption
      caption = tabItem.caption
      icon = tabItem.icon
      title = tabItem.title
      refs = @_REFS

      if subCaption? and !_.isEmpty(subCaption)
         overflowingMarker =
            if @state.isSubCaptionOverflowing
               markerStyle =
                  @computeStyles @styles.overflowingMarker,
                                 @props.isActive and @styles.overflowingMarkerActive

               `(
                   <span style={markerStyle}>
                     {this._OVERFLOWING_MARKER_FILLER}
                   </span>
                )`

         `(
            <table style={this.styles.complexCaptionTable}>
               <tbody>
                  <tr>
                     {this._getIconCell(icon, this._MANDOTORY_ROWS_COUNT_FOR_COMPLEX)}
                     <td ref={refs.subCaptionCell}
                         style={this.styles.subCaptionCell}
                         title={subCaption}>
                        <div ref={refs.subCaptionContainer}
                             style={this.styles.subCaptionContainer}>
                           {subCaption}
                        </div>
                        {overflowingMarker}
                     </td>
                  </tr>
                  <tr>
                     <td style={this.styles.withSubCaptionCaptionCell}>
                        {caption}
                     </td>
                  </tr>
               </tbody>
            </table>
          )`
      else
         `(
             <table style={this.styles.simpleCaptionTable}>
               <tbody>
                  <tr>
                     {this._getIconCell(icon)}
                     <td>{caption}</td>
                     {this._getFunctionalButtonCells()}
                  </tr>
               </tbody>
             </table>
          )`

   ###*
   * Функция формирования ячейки с иконкой заголовка.
   *
   * @param {String} icon - наименование иконки.
   * @param {Number} rowSpan - кол-во объединения строк.
   * @return {React-element}
   ###
   _getIconCell: (icon, rowSpan) ->
      if icon?
         `(
            <td rowSpan={rowSpan}
                style={this.styles.iconCell}>
               <i style={this.styles.headerIcon}
                  className={this._FA_ICON_PREF + icon}>
               </i>
            </td>
          )`

   ###*
   * Функция формирования ячеек с функциональными кнопками заголовка.
   *
   * @return {Array<React-element>}
   ###
   _getFunctionalButtonCells: ->
      captionParams = @props.tabItem.captionParams
      functionalButtons = captionParams.functionalButtons if captionParams?

      if functionalButtons?
         functionalButtons.map ((buttonParams,idx) ->
            `(
               <td key={idx}
                   style={this.styles.functionalButtonCell}>
                  <Button {...buttonParams}
                          styleAddition={this.styles.functionalButton}
                        />
               </td>
            )`
         ).bind(this)

   ###*
   * Функция получения стилей для элемента.
   *
   * @return {Object}
   ###
   _getStyle: ->
      @computeStyles @styles.common,
                     @_getClassicStyle(),
                     @_isHasSubCaption() and @styles.resetPadding,
                     @_getAdditionStyle(),
                     @_getAnimateStyle()

   ###*
   * Функция получения дополнительно стиля складки. В зависимости от заданного позиционирования
   *  селекторов возвращает различный стиль, если вкладка активна добавляет стиль
   *  активной вкладки.
   *
   * @return {Object} - дополнительный стиль вкладки.
   ###
   _getAdditionStyle: ->
      positions = @props.positions
      isActive = @props.isActive
      isClassic = @props.isClassic
      position = @props.position
      isVerticalPositioning =
         _.indexOf([positions.bottom, positions.top], position) >= 0
      verticalPositionStyle = @styles.verticalPosition
      isHasSubCaption = @_isHasSubCaption()
      styles = @styles

      if isActive
         switch position
            when positions.right
               activePositioningStyle =
                  if isClassic
                     styles.activeRightClassic
                  else
                     styles.activeRight
            when positions.left
               activePositioningStyle =
                  if isClassic
                     styles.activeLeftClassic
                  else
                     styles.activeLeft
            when positions.bottom
               activePositioningStyle =
                  if isClassic
                     styles.activeBottomClassic
                  else
                     styles.activeBottom

               activePositioningStyleSub =
                  if isHasSubCaption
                     if isClassic
                        styles.activeBottomClassicWithSub
            else
               activePositioningStyle =
                  if isClassic
                     styles.activeTopClassic
                  else
                     styles.activeTop

               activePositioningStyleSub =
                  if isHasSubCaption
                     if isClassic
                        styles.activeTopClassicWithSub
                     else
                        styles.activeTopWithSub


      # acitveStyleClassic =
      #    if isActive and isClassic
      #       @computeStyles styles.activeClassic,
      #                      isHasSubCaption and styles.activeClassicWithSub,
      #                      activePositioningStyleSub



      @computeStyles activePositioningStyle,
                     isActive and styles.activeTab,
                     #acitveStyleClassic,
                     isActive and isClassic and styles.activeClassic,
                     activePositioningStyleSub,
                     isVerticalPositioning and verticalPositionStyle

   ###*
   * Фнукция получения стилей для отображения таб-вкладки в "классическом" виде.
   *
   * @return {Object} - стиль для "классического" вида.
   ###
   _getClassicStyle: ->
      if @props.isClassic
         positions = @props.positions
         styles = @styles
         additionStyle =
            switch @props.position
               when positions.right
                  styles.classicRight
               when positions.left
                  styles.classicLeft
               when positions.bottom
                  styles.classicBottom
               else
                  styles.classicTop

         @computeStyles styles.classicTab,
                        additionStyle

   ###*
   * Функция получения текущего цвета элемента (для корректной анимации).
   *
   * @return {Object} -
   ###
   _getCurrentColor: ->
      isClassic = @props.isClassic
      isActive = @props.isActive
      styles = @styles

      if isActive
         styles.activeTab.color
      else
         if isClassic
            styles.classicTab.color
         else
            styles.common.color

   ###*
   * Функция-предикат для определения задан ли подзаголовок.
   *
   * @return {Boolean}
   ###
   _isHasSubCaption: ->
      tabItem = @props.tabItem
      subCaption = tabItem.subCaption if tabItem? and !_.isEmpty(tabItem)

      return subCaption? and !_.isEmpty(subCaption)

   ###*
   * Обработчик клика по селектору таба. Передает в обработчик индекс таба.
   *
   * @return
   ###
   _onClick: ->
      @props.onClick(@props.index)

   ###*
   * Обработчик на вход курсора мыши на элемент (фокус).
   *
   * @param {Object} event - объкект события.
   * @return
   ###
   _onMouseEnter: ->
      @_animationHighlightIn(@_getCurrentColor())

   ###*
   * Обработчик на уход курсора мыши с элемента (потеря фокуса).
   *
   * @param {Object} event - объкект события.
   * @return
   ###
   _onMouseLeave: ->
      @_animationHighlightOut(null, @_getCurrentColor())

   ###*
   * Функция определения переполнился ли подзаголовок (ячейка подзаголовка).
   *  Функция определяет ситуации когда текст подзаголовка не влезает целиком
   *  в ячейку вывода подзаголовка для возможности задания маркера наличия
   *  скрытого содержимого (...). Через text-overflow: ellipsis сделать не
   *  получается, так как подзаголовок находится в отдельном абсолютно
   *  позиционированном узле. Если подзаголовок переполнен, то в ячейку добавляется
   *  маркер наличия скрытого содержимого.
   *
   * @return
   ###
   _detectSubCaptionOverflowing: ->
      refNames = @_REFS
      subCaptionCell = @refs[refNames.subCaptionCell]
      subCaptionContainer = @refs[refNames.subCaptionContainer]

      if subCaptionContainer? and subCaptionCell?
         subCaptionContainerWidth = subCaptionContainer.clientWidth
         subCaptionCellWidth = subCaptionCell.clientWidth

         @setState
            isSubCaptionOverflowing: subCaptionContainerWidth > subCaptionCellWidth

###* Компонент: содержимое вкладки. Часть компонента Taber
* @props:
*     {React-element, DOM-node, String} content - содержимое вкладки
*     {Function} render                         - функция, запускаемая для формирования
*                                                 содержимого.
*     {Object} context                          - контекст, в котором находится элемент.
*     {Boolean} isActive                        - флаг, того, что вкладка активная.
###
TabContent = React.createClass
   mixins: [HelpersMixin]

   styles:
      common:
         #backgroundColor: _COLORS.hierarchy3
         backgroundColor: _COLORS.light
         padding: _COMMON_PADDING + 5
         # # boxShadow: "1px 2px 11px #{_COLORS.dark}"
      notActive:
         display: 'none'

   render: ->
      content = @props.content or (@_isHasHandler() and @props.render(@props.context))

      `(<div style={this._getComputedStyle()}>
           {content}
        </div>)`

   ###*
   * Функция формирования стиля контейнера.
   *
   * @return {Object}
   ###
   _getComputedStyle: ->
      @computeStyles @styles.common,
                     !@props.isActive and  @styles.notActive

   ###*
   * Функция-предикат для определения был ли задан обработчик рендера
   *  содержимого.
   *
   * @return {Boolean}
   ###
   _isHasHandler: ->
      renderHandler = @props.render
      renderHandler? and _.isFunction renderHandler

module.exports = Taber

###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* HelpersMixin     - функции-хэлперы для компонентов.
* HierarchyMixin        - модуль для задания иерархии компонентов.
* AnimationsMixin  - набор анимаций для компонентов.
* AnimateMixin     - библиотека добавляющая компонентам
*                    возможность исользования анимации.
* BehaviorsMixin   - модуль поведений.
* keymirror        - модуль для генерации "зеркального" хэша.
* lodash           - модуль служебных операций.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
AnimationsMixin = require('../mixins/animations')
HierarchyMixin = require('../mixins/hierarchy_components')
BehaviorsMixin = require('../mixins/behaviors')
AnimateMixin = require('react-animate')
keyMirror = require('keymirror')
HierarchyMixin = require('../mixins/hierarchy_components')
DOMOperationsMixin = require('../mixins/dom_operations')
_ = require('lodash')
PureRenderMixin = React.addons.PureRenderMixin

###* Зависимости: компоненты
* Button      - кнопка.
* ButtonGroup - группа кнопок.
###
Button = require('components/core/button')
ButtonGroup = require('components/core/button_group')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius

###* Компонент: всплывающая произвольная область.
*
* @props :
*     {React-Element, Boolean} target - целевой узел, относительно которого будет выведена
*                                       произвольная область. Может быть передан флаг показа.
*     {String} name               - имя произвольной области.
*     {Number} closeTimout        - таймаут скрытия области (в мсек).
*     {Object} offsetFromTarget   - смещение относительно позиционирования на целевом узле. Вид:
*                                   {Number} top  - смещение по вертикали (в пикс.)
*                                   {Number} left - смещение по горизонтали (в пикс.)
*     {Object} position           - хэш с параметрами позиционирования произвольной области
*                                   относительно целевого узла. Вид:
*                                   {
*                                      vertical: {Object} - хэш с параметрами вертикального
*                                                           выравнивания. Вид:
*                                   {String} "areaVertical": {String} "targetVertical", где
*                                            "areaVetical"    - вертикаль выравнивания области.
*                                            "targetVertical" - вертикаль выравнивания целевого узла.
*                                               Вертикали могут принимать значения:
*                                               "top", "bottom", "middle"
*                                      horizontal: {Object} - хэш с параметрами горизонтального
*                                                             выравнивания. Вид:
*                                   {String} "areaHorizontal": {String} "targetHorizontal", где
*                                            "areaHorizontal"   - горизонталь выравнивания области.
*                                            "targetHorizontal" - горизонталь выравнивания целевого узла.
*                                               Горизонтали могут принимать значения:
*                                               "right", "left", "middle"
*                                   }.
*            Например position = {vertical:{"top": "middle"}, horizontal:{"middle": "right"}} -
*            спозиционировать верхний край произвольной области на середине по вертикали у целевого узла
*            и спозиционировать центр по горизонтали у области по правому краю целевого узла.
*     {Object} dockModeParams      - параметры размещения в режиме дока.
*                                   Если данный параметр задан, то произвольная область выводится по
*                                   краю окна( в случае, когда layoutAnchor = 'window') или целевого
*                                   элемента (в случае, когда layoutAnchor = 'parent').
*                                   Вид:
*                                      {String} position - позиция элемента.
*     {String} animation          - тип анимации. Варианты:
*                                   "slideDown"  - "выезд" вниз.
*                                   "slideUp"    - "выезд" вверх.
*                                   "slideRight" - "выезд" вправо.
*                                   "slideLeft"  - "выезд" влево.
*                                   "fade"       - плавное появление.
*     {Object} styleAddition      - дополнительный стиль.
*     {React-Element} content     - компонент-содержимое произвольной области.
*     {String} title              - выводимая подсказка на области.
*     {Object} captionParams      - параметры выводимый заголовок. Если не задан - заголовок не выводится.
*                                   Вид:
*                                      {String} text  - выводимый текст
*                                      {String} icon  - выводимая имя иконки (из font-awesome).
*                       {Array<Object>} customActions - набор параметр для произвольных действий.
*                                                       Если данный параметр задан в заголовке
*                                                       формируется группа кнопок с заданнымми параметрами.
*                                                       Вид элемента:
*                                                       {String} icon    - иконка на кнопке.
*                                                       {String} caption - надпись на кнопке.
*                                                       {Object} value   - значение кнопки.
*                                                       {String} title   - всплывающая подсказка на кнопке.
*                                                     {Function} onClick - обработчик клика на кнопке.
*                                                       {...}            - прочие параметры, которые можно
*                                                                          задать элементу Button.
*                       {Array<Object>} customFunctionalButtons - набор произвольный функциональных действий.
*                                                                 Данный параметр нужен для вывода кнопок
*                                                                 пользовательских действий, располагаемых
*                                                                 справа в заголовке (рядом с кнопкой закрыть).
*
*                              {Object} styleAddition - параметры доп. стилей шапки области. Вид:
*                                   {Object} common - доп. стиль для заголовка, дополняющий
*                                                     стиль по-умолчанию.
*                                   {Object} closeButton - доп. стиль для кнопки закрытия.
*     {Boolean} isHasCloseButton  - флаг наличия кнопки закрытия области. По-умолчанию = false.
* {Boolean} isHasFullWindowButton - флаг наличия кнопки разворачивания окна на весь экран. По-умолчанию = false.
*   {Boolean} isCloseButtonOnArea - флаг кнопки закрытия, находящегося на области. Флаг актуален
*                                   для случая, когда не заданы параметры шапки области и при этом
*                                   задан флаг наличия кнопки @props.isHasCloseButton. Если данный
*                                   флаг не установлен, то кнопка закрытия выносится за пределы области,
*                                   чтобы не закрытвать содержимое. Если данный флаг установлен, то
*                                   кнопка закрытия будет отображена в правом верхнем углу области,
*                                   поверх содержимого. По-умолчанию = false.
*     {Boolean} isCloseOnBlur     - флаг скрытия при потере фокуса(кликнули вне области). По-умолчанию = true
*     {Boolean} isHasShadow       - флаг показа тени у области. По-умолчанию = false
*     {Boolean} isHasBorder       - флаг показа рамки вокруг области. По-умолчанию = true
*     {Boolean} isMovable         - флаг возможности перемещать область (по захвату заголовка).
*                                   соответствено, если нет заголовка, то этот флаг не поможет таскать
*                                   область. По-умолчанию = false.
*     {Boolean} isCatchFocus      - флаг необходимости установки фокуса на области на обновление. По-умолчанию = false
*     {Boolean} isResetOffset     - флаг сброса смещения относительно родительского узла. Опция
*                                   может быть полезна для абсолютно позиционируемых областей,
*                                   которые нужно позиционировать под целевыми узлами. По-умолчаню = false.
* {Boolean} isTriggerOnSameTarget - флаг скрытия области(если) открыта при пробросе того же целевого
*                                   узла. По-умолчанию = true.
*     {Boolean} isAdaptive        - флаг адаптивно подстраиваемой области. Если данный флаг установлен, то
*                                   перед применением стилей проверяет родительские элементы, есть ли среди них
*                                   элементы с прокруткой и элемент фиксированно позиционированный.
*                                   Если есть, то сбрасывает некоторые настройки позиционирования(layoutAnchor, isResetOffset)
*                                   и позиционирует область фиксированно с определенными
*                                   значениями верхнего и нижнего отступов. По-умолчанию = false.
*    {Boolean} isForcedLeaveShown - флаг принудительного оставления области показанной.
*                                   Флаг нужен для отключения на некоторое время поведения
*                                   срабатывания на тот же самый целевой элемент.
*                                   По-умолчанию = false.
*    {Boolean} isFitToTargetParent - флаг редактирвоания позиционирования области, в случае, если она выходит за область
*                                      видимости окна.
*                                   По-умолчанию = true.
* {Boolean} isAddPaddingToVisableArea - включает в себя isFitToTargetParent с отступом от края окна в 5px в случае
*                                       необходимости. По-умолчанию = true.
*    {Boolean} isWithoutSubstrate - флаг создания области без подложки(без фона).
*                                   По-умолчанию = false. (белый фон).
*     {Boolean} isKeyControlled   - флаг возможности управления областью вводом с клавиатуры
*                                   (пока закрытие через Esc, в дальнейшем возможно будут другие
*                                   операции). По-умолчанию = false.
*     {Boolean} enableResize      - флаг разрешения изменения размеров области.
*                                   По-умолчанию = false.
*     {String} layoutAnchor       - идентификатор позиционирования области в DOM. Варианты:
*                                   'window' (по-умолчанию). position='fixed'
*                                   'parent'                 position='absolute'
*                                   'stream'                 position='static'
*     {Function} onReady          - обработчик, запускаемый по готовности области к показу
*                                   (запускается при устанавлении расположения и размеров области).
*                                   Аргументы:
*                                      {React-element} area    - ссылка на текущую область.
*                                      {Object} areaClientRect - параметры ограничений позиционирования
*                                                                области (размеры и позиционирование).
*                                      {Object} areaBorderSize - размеры рамок области (вертикальная и
*                                                                горизонтальные границы). Вид:
*                                               {Number} vertical    - размеры вертикальной рамки.
*                                               {Number} horizonatal - размеры горизонтальной рамки.
*     {Function} onShow           - обработчик, запускаемый по показу области (по
*                                   окончанию анимации).
*     {Function} onHide           - обработчик, запускаемый по скрытию области (по
*                                   окончанию анимации).
*     {Function} onFocus          - обработчик на фокусировку на произвольной области. Аргументы:
*                                   {React-element} target - целевой узел на который перешел фокус.
*                                   {Event-object} event - объект события.
*     {Function} onBlur           - обработчик на потерю фокуса областью. Аргументы:
*                                   {React-element} relatedTarget - целевой узел на который перешел фокус.
*                                   {Event-object} event     - объект события.
*     {Function} onClick          - обработчик клика по области (в любом месте). Аргументы:
*                                   {React-component} area   - ссылка на текущий экземпляр компонента.
*                                   {Event-object} event     - объект события.
*     {Function} onKeyDown        - обработчик нажатия на клавишу с привязкой к клавиатуре.
*                                   Аргументы:
*                                   {Object} event - объект события.
*     {Function} onKeyPress       - обарботчик нажатия на клавишу с привязкой к напечатанному
*                                   символу. Аргументы:
*                                   {Object} event - объект события.
*     {Function} onKeyUp          - обработчик на отпускания клавишу с привязкой к клавиатуре.
*                                   Аргументы:
*                                   {Object} event - объект события.
*{Function} onFullWindowedTrigger - обработчик на переключения полноэкранного режима.
*                                   Аргументы:
*                                   {Boolean} isFullWindowed - флаг развернутости на полный экран.
* @state :
*     {React-element} targetNode - целевой узел. Сохраняется в состояние, чтобы его можно
*                                   было сбросить по окончанию анимации.
*     {Object} offset     - хэш с параметрами смещения относительно целевого узла. Вид
*                           {Number} left - по горизонтали.
*                           {Number} top  - по вертикали.
*     {Object} size       - хэш с параметрами размеров области (для анимации). Вид
*                           {Number} width - ширина.
*                           {Number} height - высота.
*     {String} areaState  - текущее состояние компонента. Варианты:
*                           'init'     - инициализован,
*                           'ready'    - готов к показу,
*                           'animated' - в анимации,
*                           'shown'    - показан,
*                           'moved'    - в движении.
*  {Object} targetRect    - параметры ограничений позиционирования
*                           целевого узла (размеры и позиционирование).
* {Object} areaClientRect - параметры ограничений позиционирования
*                           области (размеры и позиционирование).
* {Object} areaBorderSize - размеры рамок области (вертикальная и
*                           горизонтальные границы). Вид:
*                           {Number} vertical    - размеры вертикальной рамки.
*                           {Number} horizonatal - размеры горизонтальной рамки.
*     {Object} dockSize - объект, хранящий высоту и ширину области, необходимый
*                                для фиксации габаритов. Вид:
*                           {Number} width - ширина.
*                           {Number} height - высота.
*     {String} positionParams - хэш-словарь для хранения параметров позиционирования
*                               (вертикалей, горизонталей) области и целевого узла.
*                               Формируется на основе параметра @props.position. Вид:
*                               {String} areaHorizontal:   ('right', 'left', 'middle')
*                               {String} areaVertical:     ('top', 'bottom', 'middle')
*                               {String} targetHorizontal: ('right', 'left', 'middle')
*                               {String} targetVertical:   ('top', 'bottom', 'middle')
* {Boolean} isNeedAdaptiveRule - флаг необходимости задействования правила "адаптивности".
*                                Состояние используется только если задан параметр @props.isAdaptive.
*{Boolean} isFullWindowed- флаг развернутости области на все окно браузера.
*   {Boolean} isInitFocused    - флаг начальной установки фокуса. Параметр используется для
*                                того чтобы фокус устанавливался только один раз
*                                (если задана опция @props.isCatchFocus) и
*                                по-новой не устанавливался после обновелния.
###
ArbitraryArea = React.createClass
   # @const {Object} - хэш возможных сосояний компонента.
   _AREA_STATES: keyMirror(
      init: null
      ready: null
      animated: null
      shown: null
      moved: null
   )

   # @const {Object} - хэш параметров для dock режима.
   _DOCK_MODE_PARAMS:
      positions: keyMirror(
         top: null
         bottom: null
         right: null
         left: null)
      defaultPosition:
         'right'

   # @const {Object} - хэш значений позиционирования области относительно целевого узла.
   _POSITIONS:
      vertical: keyMirror(
         top: null
         bottom: null
         middle: null
      )
      horizontal: keyMirror(
         right: null
         left: null
         middle: null
      )
   # @const {Object} - хэш значений позиционирования области в DOM.
   _LAYOUT_ANCHORS: keyMirror(
      window: null
      parent: null
      stream: null
   )
   # @const {Object} - хэш возможных анимаций.
   _ANIMATIONS: keyMirror(
         slideDown: null
         slideUp: null
         slideRight: null
         slideLeft: null
         fade: null
      )
   # @const {Object} - хэш возможных имен анимаций.
   _ANIMATION_NAMES:
      slide: 'animate-slide'
      fade: 'animate-fade'

   # @const {String} - наименование css-класса для области.
   _AREA_CLASS: 'arbitrary-area'

   # @const {String} Значения фиксированного стиля позиционирования.
   _STYLE_FIXED_POSITION: 'fixed'

   # @const {Object} - наименования ссылок.
   _REFS:
      header: 'areaHeader'
      container: 'areaContainer'
      content: 'areaContent'

   # @const {Object} - используемые символы.
   _CHARS:
      empty: ''
      point: '.'

   # @const {String} - наименование тэга body
   _BODY_TAG_NAME: 'BODY'

   # @param {Number} - идентификатор таймаута по которому запускается функция скрытия
   #                   области. Данные параметр нужен для возможности сброса таймера.
   _closeTimeoutIdentifier: null

   mixins: [
      HelpersMixin
      HierarchyMixin.hierarchy.child
      HierarchyMixin.container.parent
      DOMOperationsMixin
      AnimateMixin
      AnimationsMixin.slide
      AnimationsMixin.fade
      BehaviorsMixin.move
      BehaviorsMixin.resize.width
      BehaviorsMixin.resize.height
      BehaviorsMixin.resize.all
   ]

   styles:
      common:
         position: 'fixed'
         backgroundColor: _COLORS.light
         display: 'none'
         boxSizing: 'border-box'
         overflow: 'hidden'
         outline: 'none'
         #fontSize: 15
         zIndex: 100
      commonDock:
         position: 'fixed'
      withoutSubstrate:
         backgroundColor: ''
      content:
         overflow: 'auto'
      contentFitWidth:
         width: '100%'
      streamLayout:
         position: 'static'
         zIndex: 0
      parentLayout:
         position: 'absolute'
      areaBorder:
         border: "1px solid #{_COLORS.hierarchy4}"
      areaShadow:
         boxShadow: "1px 2px 11px #{_COLORS.dark}"
      visible:
         display: ''
      shown:
         overflow: ''
      resetSize:
         height: ''
         width: ''
      resetMaxWidth:
         maxWidth: ''
      resetMaxHeight:
         maxHeight: ''
      invisible:
         display: 'none'
      resetPositionAndDimension:
         top: 0
         left:0
         display: ''
         visibility: 'hidden'
         # width: ''
         # height: ''
      fullWindowed:
         top: 0
         left:0
         maxWidth: null
         maxHeight: null
         width: '100%'
         height: '100%'
      widthResizer:
         position: 'absolute'
         right: -2
         top: 0
         bottom: 0
         width: 3
         cursor: 'w-resize'
      heightResizer:
         position: 'absolute'
         bottom: -2
         left: 0
         right: 0
         height: 3
         cursor: 'n-resize'
      allResizer:
         position: 'absolute'
         bottom: -4
         right: -4
         zIndex: 2
         width: 10
         height: 10
         cursor: 'se-resize'

   propTypes:
      name: React.PropTypes.string
      closeTimeout: React.PropTypes.number
      layoutAnchor: React.PropTypes.oneOf(
         ['window', 'parent', 'stream']
      )
      animation: React.PropTypes.oneOf(
         ['slideDown','slideUp', 'slideRight', 'slideLeft', 'fade']
      )
      position: React.PropTypes.objectOf(React.PropTypes.object)
      target: React.PropTypes.oneOfType([
         React.PropTypes.object
         React.PropTypes.bool
      ])
      offsetFromTarget: React.PropTypes.objectOf(React.PropTypes.number)
      сontent: React.PropTypes.object
      title: React.PropTypes.string
      styleAddition: React.PropTypes.object
      captionParams: React.PropTypes.object
      isHasCloseButton: React.PropTypes.bool
      isHasFullWindowButton: React.PropTypes.bool
      isCloseButtonOnArea: React.PropTypes.bool
      isCloseOnBlur: React.PropTypes.bool
      isHasShadow: React.PropTypes.bool
      isHasBorder: React.PropTypes.bool
      isMovable: React.PropTypes.bool
      isCatchFocus: React.PropTypes.bool
      isResetOffset: React.PropTypes.bool
      isTriggerOnSameTarget: React.PropTypes.bool
      isAdaptive: React.PropTypes.bool
      isForcedLeaveShown: React.PropTypes.bool
      isWithoutSubstrate: React.PropTypes.bool
      isKeyControlled: React.PropTypes.bool
      onShow: React.PropTypes.func
      onHide: React.PropTypes.func
      onClick: React.PropTypes.func
      onBlur: React.PropTypes.func
      onKeyDown: React.PropTypes.func
      onKeyUp: React.PropTypes.func
      onKeyPress: React.PropTypes.func

   getDefaultProps: ->
      animation: 'slideDown'
      layoutAnchor: 'window'
      position:
         vertical:
            'top': 'bottom'
         horizontal:
            'right': 'right'
      offsetFromTarget:
         top: 0
         left: 0
      isHasCloseButton: false
      isHasFullWindowButton: false
      isCloseButtonOnArea: false
      isHasShadow: false
      isHasBorder: true
      isMovable: false
      isCloseOnBlur: true
      isCatchFocus: false
      isResetOffset: false
      isTriggerOnSameTarget: true
      isAdaptive: false
      isForcedLeaveShown: false
      isFullWindowed: false
      captionParams: {}
      isFitToTargetParent: true
      isAddPaddingToVisableArea: true
      isWithoutSubstrate: false
      isKeyControlled: false
      enableResize: false

   getInitialState: ->
      targetNode: @props.target
      offset: {}
      size:
         width: 0
         height: 0
      areaClientRect: {}
      targetClientRect: {}
      areaState: @_AREA_STATES.init
      positionParams: null
      isNeedAdaptiveRule: false
      isInitFocused: false
      isFullWindowed: false

   componentWillReceiveProps: (nextProps) ->
      nextTarget = nextProps.target
      currentTarget = @props.target
      isExistNextTarget = @_isExistTarget nextTarget
      isDifferentTarget =  @_isDifferentTarget nextTarget
      isShownState = @state.areaState is @_AREA_STATES.shown
      isStreamLayout = @props.layoutAnchor is @_LAYOUT_ANCHORS.stream

      # Если область показана и не задан таймаут закрытия.
      if isShownState and !@props.closeTimeout?
         # Если существует следующий целевой узел и это область располагаемая вне
         #  общего потока.
         if isExistNextTarget and !isStreamLayout

            # Если следующий целевой узел отличен от текущего и задан таймаут закрытия
            #  - сбросим таймаут на скрытие.
            # Иначе если задан флаг скрытия на тот же целевой узел и флаг
            #  удерживания в открытом состоянии имеет отрицательное значение
            #  - скроем область.
            if isDifferentTarget and  @props.isCloseOnBlur
               clearTimeout(@_closeTimeoutIdentifier)
            else if @props.isTriggerOnSameTarget and !nextProps.isForcedLeaveShown
               @_animationOut()
         # Если следующего узла не существует (или задан false) - нужно скрыть область
         else unless isExistNextTarget
            @_animationOut()


      # Запомним целевой узел, чтобы его можно было сбрасывать по оканчанию анимации.
      @setState
         isNeedAdaptiveRule: @_isNeedAdaptiveRule()
         # offset:
         #    left: @state.offset.left
         #    top: @state.offset.top
         targetNode: nextTarget


   componentWillUpdate: (nextProps, nextState) ->
      nextAreaState = nextState.areaState

      # Если область готова к показу - запустим анимацию показа
      if nextAreaState is @_AREA_STATES.ready and @_isExistTarget(nextState.targetNode)
         @_animationIn nextState


   render: ->
      refs = @_REFS

      `(
         <div style={this._getAreaStyle()}
              ref={refs.container}
              tabIndex={-1}
              title={this.props.title}
              onFocus={this._onFocusArea}
              onBlur={this._onBlurArea}
              onClick={this._onClick}
              onKeyDown={this._onKeyDown}
              onKeyUp={this.props.onKeyUp}
              onKeyPress={this.props.onKeyPress}
              className={this._AREA_CLASS}>
            {this._getAreaHeader()}
            <ArbitraryAreaIsolatedContent ref={refs.content}
                                          style={this._getContentContainerStyle()}
                                          content={this.props.content}
                                          isInAnimaiton={this._isInAnimaiton()}
                                       />
            {this._getResizerElements()}
         </div>
       )`

   componentDidUpdate: (prevProps, prevState) ->
      areaState = @state.areaState
      states = @_AREA_STATES
      initState = states.init
      shownState = states.shown
      readyState = states.ready
      isDifferentTarget = @_isDifferentTarget(prevState.targetNode)
      isInStream = @_isStreamLayout()
      isInInit = areaState is initState

      if areaState in [initState, shownState]
         isTargetChangeForDetachedArea =
            !isInStream and
            isDifferentTarget and
            @_isExistTarget(@state.targetNode)
         isInitStream = isInStream and isInInit
         isTriggerDockMode = !_.eq(@props.dockModeParams, prevProps.dockModeParams)

         # Запускаем считывание размеров и позиционирования если был изменен
         #  целевой узел для "оторванной" области (не в потоке) или для
         #  потоковой области, если она была только инициирована или
         #  для случая когда режим работы "в доке" изменен.
         if isTargetChangeForDetachedArea or isInitStream or isTriggerDockMode
            @_setAreaLocation()

         # Если задан флаг адаптивной области и при этом ещё не установлено
         #  правило необходимости применения правила адаптивности - выполним
         #  проверку на необходимость применения этого правила и применим, если
         #  необходимо.
         if @props.isAdaptive and !@state.isNeedAdaptiveRule
            isNeedAdaptiveRule = @_isNeedAdaptiveRule()

            if isNeedAdaptiveRule
               @setState isNeedAdaptiveRule: isNeedAdaptiveRule

      #  Запустим функцию определения необходимости фокусировки и установки фокуса.
      @_focusOnArea()


   componentDidMount: ->
      if @state.areaState is @_AREA_STATES.init

         # Если задан целевой узел - считаем параметры позиционирования.
         if @_isExistTarget(@state.targetNode)
            @_setAreaLocation()

      closeTimeout = @props.closeTimeout
      if closeTimeout?
         @_closeTimeoutIdentifier = @delay closeTimeout, @_animationOut


   componentWillUnmount: ->
      clearTimeout(@_closeTimeoutIdentifier)

   ###*
   * Функция получения элемента содержимого.
   *
   * @return {React-Element}
   ###
   getContentElement: ->
      refsSet = @_REFS
      @refs[refsSet.content]

   ###*
   * Функция возврата размеров области.
   *
   * @return {Object}
   ###
   getSize: ->
      @state.size

   ###*
   * Функция возврата параметров пространственных ограничителей области.
   *
   * @return {Object}
   ###
   getBoundingClientRect: ->
      @state.areaClientRect

   ###*
   * Функция установки смещения для области(для возможности управления позиционированием
   *  из вне).
   *
   * @param {Object} newOffset - параметры нового смещения.
   * @return
   ###
   setOffset: (newOffset) ->
      if @props.dockModeParams? and @props.layoutAnchor is @_LAYOUT_ANCHORS.window
         offsetTop = 0
         offsetLeft = 0
      else
         offsetTop = newOffset.top or @state.offset.top
         offsetLeft = newOffset.left or @state.offset.left

      @setState
         offset:
            top: offsetTop
            left: offsetLeft

   ###*
   * Функция-предикат для определения показана ли область.
   *
   * @return {Boolean}
   ###
   isShown: ->
      @state.areaState is @_AREA_STATES.shown

   ###*
   * Функция закрытия области.
   *
   * @return
   ###
   close: ->
      @_animationOut()

   ###*
   * Функция получения заголовка области. Проверяет заданы ли какие-либо параметры
   *  для создания заголовка (параметры заголовка или флаг наличия кнопки закрытия).
   *
   * @return {React-Element}
   ###
   _getAreaHeader: ->
      if @_isNeedCaption()
         isMoved = @state.areaState is @_AREA_STATES.moved

         `(
            <ArbitraryAreaHeader ref={this._REFS.header}
                                 captionParams={this.props.captionParams}
                                 isMoved={isMoved}
                                 isMovable={this.props.isMovable}
                                 isHasCloseButton={this.props.isHasCloseButton}
                                 isHasFullWindowButton={this.props.isHasFullWindowButton}
                                 isCloseButtonOnArea={this.props.isCloseButtonOnArea}
                                 isFullWindowed={this.state.isFullWindowed}
                                 onClickClose={this._onClickClose}
                                 onClickFullWindow={this._onClickFullWindow}
                                 onMouseDown={this._onMouseDownHeader}
                                 onMouseUp={this._onMouseUpHeader}
                              />
          )`

   ###*
   * Функция получения элементов управления размерами окна.
   *
   * @return {React-Element}
   ###
   _getResizerElements: ->
      if @props.enableResize
         `(
            <span>
               <div style={this.styles.widthResizer}
                    onMouseDown={this._onMouseDownWidthResizer}
                    onClick={this._onEventTerminateResizer} >
               </div>
               <div style={this.styles.heightResizer}
                    onMouseDown={this._onMouseDownHeightResizer}
                    onClick={this._onEventTerminateResizer}>
               </div>
               <div style={this.styles.allResizer}
                    onMouseDown={this._onMouseDownAllResizer}
                    onClick={this._onEventTerminateResizer}>
               </div>
            </span>
         )`

   ###*
   * Функция получение скопманованного стиля для произвольной области.
   *
   * @return {Object} - скомпанованный стиль.
   ###
   _getAreaStyle: ->
      states = @_AREA_STATES
      layoutAnchors = @_LAYOUT_ANCHORS
      layoutAnchor = @props.layoutAnchor
      areaState = @state.areaState
      initState = states.init
      readyState = states.ready
      shownState = states.shown
      movedState = states.moved
      animatedState = states.animated
      enableResize = @props.enableResize
      isWithoutSubstrate = @props.isWithoutSubstrate
      isReady = areaState is readyState
      isInit = areaState is initState
      isShown = areaState is shownState
      isMoved = areaState is movedState
      isAnimated = areaState is animatedState
      isVisible = areaState in [
                                 #readyState
                                 animatedState
                                 shownState
                                 movedState
                              ]
      isStreamLayout = layoutAnchor is layoutAnchors.stream
      isParentLayout = layoutAnchor is layoutAnchors.parent
      isDockMode = @_isDockMode()
      isFullWindowed = @state.isFullWindowed
      resizeParams = @state.resizeParams


      if isDockMode
         dockStyle = @styles.commonDock

         if @_isVerticalDockMode()
            dockStyle.height = if @state.size.height? then @state.size.height
            dockStyle.width = null
         else
            dockStyle.width = if @state.size.width? then @state.size.width
            dockStyle.height = null

      isNeedAdaptiveRule = @state.isNeedAdaptiveRule

      if isNeedAdaptiveRule
         isStreamLayout = false
         isParentLayout = false

      areaOffset = unless isStreamLayout
                      if isMoved
                         @_getMoveOffset()
                      else
                         @_getAreaOffset(isNeedAdaptiveRule)

      substituteOffsetFormTarget = @_getSubstituteOffset()

      @computeStyles @styles.common,
                     isWithoutSubstrate and @styles.withoutSubstrate,
                     isParentLayout and @styles.parentLayout,
                     isStreamLayout and @styles.streamLayout,
                     isVisible and @styles.visible,
                     isShown and @styles.shown,
                     @props.isHasShadow and @styles.areaShadow,
                     @props.isHasBorder and @styles.areaBorder,
                     areaOffset,
                     substituteOffsetFormTarget,
                     isDockMode and dockStyle,
                     #isDockMode and !isAnimated and @state.dockSize,
                     isAnimated and @_getAnimatedStyle(),
                     (isInit or isShown or isMoved) and !isDockMode and @styles.resetSize,
                     @props.styleAddition,
                     isReady and @props.deadStyles,
                     resizeParams? and enableResize and @_getResizeSize(),
                     resizeParams? and enableResize and @_getMaxSizeReset(resizeParams),
                     isFullWindowed and @styles.fullWindowed
                     #@state.resizeWidth? and @state.resizeWidth

   ###*
   * Функция получения стиля для контейнра контента. Если для компонента были
   *  установлены параметры размеров (было изменение размеров) - подстраивает контейнар
   *  контента для корректного отображения содержимого.
   *
   * @return {Object} - стили контейнера.
   ###
   _getContentContainerStyle: ->
      resizeParams = @state.resizeParams
      resizeSize = resizeParams.size if resizeParams? and !_.isEmpty(resizeParams)
      additionStyle =
         if resizeSize?
            resizeHeight = resizeSize.height
            height = if @_isHasCaptionParams()
                        resizeHeight - @state.size.header.height
                     else
                        resizeHeight

            @computeStyles @styles.contentFitWidth, height: height

      @computeStyles @styles.content, additionStyle

   ###*
   * Функция получения суррогатных параметров смещения относительно целевого узла
   *  если задан параметр игнорирования смещения относительно целевого узла.
   *
   * @return {Object} - суррогатные стили смещения относительно целевого узла.
   ###
   _getSubstituteOffset: ->
      if @props.isResetOffset
            offsetFromTarget = @props.offsetFromTarget
            if offsetFromTarget? and !$.isEmptyObject(offsetFromTarget)
               topOffset = offsetFromTarget.top
               leftOffset = offsetFromTarget.left
               substituteOffset = {}

               if topOffset?
                  substituteOffset.marginTop = topOffset

               if leftOffset?
                  substituteOffset.marginLeft = leftOffset

               substituteOffset

   ###*
   * Функция получения стилей анимации в зависимости от заданной анимации.
   *
   * @return {Object} - объект со стилем анимации.
   ###
   _getAnimatedStyle: ->
      animationName = if @props.animation is @_ANIMATIONS.fade
                         @_ANIMATION_NAMES.fade
                      else
                         @_ANIMATION_NAMES.slide
      @getAnimatedStyle animationName

   ###*
   * Функция получения стилей сброса максимальных значений высоты и ширины при
   *  наличии параметров ресайза области.
   *
   * @param {Object} resizeParams - параметры для ресайза.
   * @return {Object} - стили сброса.
   ###
   _getMaxSizeReset: (resizeParams) ->

      if resizeParams?
         resizeSize = resizeParams.size
         resizeWidth = resizeSize.width
         resizeHeight = resizeSize.height

         resetMaxWidthStyle =
            if resizeWidth?
               @styles.resetMaxWidth

         resetMaxHeightStyle =
            if resizeHeight?
               @styles.resetMaxHeight

         if resetMaxWidthStyle? or resetMaxHeightStyle?
            @computeStyles resetMaxWidthStyle, resetMaxHeightStyle


   ###*
   * Функция получение необходимых параметров смещения. В зависимости от типа анимации
   *  заданной для области возврщает какой-то один параметр смещения(другим рулит анимация),
   *  либо полностью параметр смещения.
   *
   * @return {Object} - хэш с параметрами смещения.
   ###
   _getAreaOffset: (isNeedAdaptiveRule) ->
      isInAnimation = @state.areaState is @_AREA_STATES.animation
      animations = @_ANIMATIONS
      propAnimation = @props.animation
      stateOffset = @state.offset
      propsOffset = @props.offsetFromTarget
      propsOffsetLeft = propsOffset.left
      propsOffsetTop = propsOffset.top

      # Если задан флаг сброса смещения и не задано состояние необходимости
      #  адаптивного поведения - вернем объект с пустым смещением.
      if @props.isResetOffset and !isNeedAdaptiveRule
         return { left: null, top: null }

      if @state.areaState is @_AREA_STATES.ready
         stateOffset.left += propsOffsetLeft if propsOffsetLeft?
         stateOffset.top += propsOffsetTop if propsOffsetTop?

      if propAnimation is animations.slideUp and isInAnimation
         left: stateOffset.left
      else if propAnimation is animations.slideLeft and isInAnimation
         top: stateOffset.top
      else
         stateOffset

   ###*
   * Функция получения позиции top для смещения произвольной области относительно целевого узла.
   *
   * @return {Number} - вертикальное значение смещения.
   ###
   _getTopPosition: (positionParams, targetRect, areaHeight) ->
      targetHalfHeight = targetRect.height / 2
      veticalPositions = @_POSITIONS.vertical
      areaVertical = positionParams.areaVertical
      targetVertical = positionParams.targetVertical
      topPosition = veticalPositions.top
      bottomPosition = veticalPositions.bottom
      middlePosition = veticalPositions.middle

      switch areaVertical
         when topPosition
            switch targetVertical
               when topPosition
                  targetRect.top
               when bottomPosition
                  targetRect.bottom
               when middlePosition
                  targetRect.top + targetHalfHeight
         when bottomPosition
            switch targetVertical
               when topPosition
                  targetRect.top - areaHeight
               when bottomPosition
                  targetRect.bottom - areaHeight
               when middlePosition
                  targetRect.top + targetHalfHeight - areaHeight
         when middlePosition
            areaHalfHeight = areaHeight / 2
            switch targetVertical
               when topPosition
                  targetRect.top - areaHalfHeight
               when bottomPosition
                  targetRect.bottom - areaHalfHeight
               when middlePosition
                  targetRect.top + targetHalfHeight - areaHalfHeight
   ###*
   * Функция получения позиции left для смещения произвольной области относительно целевого узла.
   *
   * @return {Number} - горизонтальное значение смещения.
   ###
   _getLeftPosition: (positionParams, targetRect, areaWidth) ->
      targetHalfWidth = targetRect.width / 2
      horizontalPositions = @_POSITIONS.horizontal
      areaHorizontal = positionParams.areaHorizontal
      targetHorizontal = positionParams.targetHorizontal
      rightPosition = horizontalPositions.right
      leftPosition = horizontalPositions.left
      middlePosition = horizontalPositions.middle

      switch areaHorizontal
         when rightPosition
            switch targetHorizontal
               when rightPosition
                  targetRect.right - areaWidth
               when leftPosition
                  targetRect.left - areaWidth
               when middlePosition
                  targetRect.left + targetHalfWidth - areaWidth
         when leftPosition
            switch targetHorizontal
               when rightPosition
                  targetRect.right
               when leftPosition
                  targetRect.left
               when middlePosition
                  targetRect.left + targetHalfWidth
         when middlePosition
            areaHalfWidth = areaWidth / 2
            switch targetHorizontal
               when rightPosition
                  targetRect.right - areaHalfWidth
               when leftPosition
                  targetRect.left - areaHalfWidth
               when middlePosition
                  targetRect.left + targetHalfWidth - areaHalfWidth

   ###*
   * Функция получения параметров позиционирования.
   *
   * @return {Object} {
                        areaVertical:     - вертикаль области.
                        areaHorizontal:   - горизонталь области.
                        targetVertical:   - вертикаль целевого узла.
                        targetHorizontal: - горизонталь целевого узла.
                      }
   ###
   _getPositionParams: ->
      position = @props.position
      layoutAnchors = @_LAYOUT_ANCHORS
      layoutAnchor = @props.layoutAnchor
      isParentLayout = layoutAnchor is layoutAnchors.parent
      isWindowLayout = layoutAnchor is layoutAnchors.window

      if @_isDockMode() and (isParentLayout or isWindowLayout)
         dockParams = @_DOCK_MODE_PARAMS
         dockPositions = dockParams.positions
         dockModePosition = @props.dockModeParams.position || dockParams.defaultPosition
         dockMiddlePosition = dockPositions
         switch dockModePosition
            when dockPositions.top
               horizontalPosition = {left: dockPositions.left}
               verticalPosition = {top: dockPositions.top}
            when dockPositions.bottom
               horizontalPosition = {left: dockPositions.left}
               verticalPosition = {bottom: dockPositions.bottom}
            when dockPositions.left
               horizontalPosition = {left: dockPositions.left}
               verticalPosition = {top: dockPositions.top}
            when dockPositions.right
               horizontalPosition = {right: dockPositions.right}
               verticalPosition = {top: dockPositions.top}
      else
         horizontalPosition = position.horizontal || @_getDefaultHorizontal()
         verticalPosition = position.vertical || @_getDefaultVertical()

      areaVertical = Object.keys(verticalPosition)[0]
      targetVertical = verticalPosition[areaVertical]
      areaHorizontal = Object.keys(horizontalPosition)[0]
      targetHorizontal = horizontalPosition[areaHorizontal]

      areaVertical: areaVertical
      areaHorizontal: areaHorizontal
      targetVertical: targetVertical
      targetHorizontal: targetHorizontal

   ###*
   * Функция получения значений вертикального позиционирования по-умолчанию.
   *
   * @return {Object} - значение позиционирования.
   ###
   _getDefaultVertical: ->
      vertical = @_POSITIONS.vertical
      top = vertical.top
      bottom = vertical.bottom
      res = {}

      res[top] = bottom
      res

   ###*
   * Функция получения значений горизонтального позиционирования по-умолчанию.
   *
   * @return {Object} - значение позиционирования.
   ###
   _getDefaultHorizontal: ->
      right = @_POSITIONS.right
      keyMirror(
         right: null
      )

   ###*
   * Функция получения координат видимой области целевого узла.
   *  Вычисленные значения для фиксированного позиционирования и для абсолютного
   *  позиционирования отличаются. Фиксированное позиционирование предполагает, что возвращаемые
   *  координаты видимой области будут считаться относительно видимой верхней границы.
   *  При абсолютном позиционировании к координатам добавляется скролл.
   *
   * @param {Object} target - цель, у которой необходимо определить видимую часть.
   * @return {Object} - значения координат произольной области. Вид:
   *  {Number} bottom
   *  {Number} height
   *  {Number} left
   *  {Number} right
   *  {Number} top
   *  {Number} width
   ###
   _getVisiblePartOfTarget: (target) ->
      layoutAnchors = @_LAYOUT_ANCHORS
      layoutAnchor = @props.layoutAnchor
      isParentLayout = layoutAnchor is layoutAnchors.parent
      isWindowLayout = layoutAnchor is layoutAnchors.window
      isDockMode = @_isDockMode()
      isNeedAdaptiveRule = @state.isNeedAdaptiveRule
      target = ReactDOM.findDOMNode target
      body = document.body

      # Если область не в док режиме или в док режиме и привязка к родителю, то
      #  вычисляем параметры видимой области целевого узла.
      # Иначе возвращаем параметры тела документа.
      if !isDockMode or (isDockMode and isParentLayout)

         # Если цель существует, то будем ориентироваться на её координаты,
         #  иначе (обычно в случае анимации скрытия при потере цели) вернем
         #  прежние ширину и высоту.
         if target?
            targetCoordinates = target.getBoundingClientRect()
            targetTop = targetCoordinates.top
            targetBottom = targetCoordinates.bottom
            targetLeft = targetCoordinates.left
            targetRight = targetCoordinates.right

            # Определяем родителя.
            parent = @_getScrollParent(target)[0]

            # Определяем, проскролено ли окно.
            isDocumentScroll = body.scrollHeight > body.clientHeight or
                  body.scrollWidth > body.clientWidth

            # Определяем, является ли возможно проскроленный родитель документом?
            isParentDocument = parent is document
            isParentScroll = !isParentDocument or (isDocumentScroll and isParentDocument)

            # Если мы имеем дело с прокручиваемым родителем, то запускаем логику вычисления
            #  координат, иначе мы не имеем прокручиваемых элементов и можем
            #  вернуть координаты цели (самый простой вариант).
            if isParentScroll
               # Если родитель является прокручиваемым документом, то верхние координаты будут по нулям.
               if isParentDocument
                  parent = body
                  parentCoordinates = parent.getBoundingClientRect()
                  parentTop = 0
                  parentBottom = parentCoordinates.height
                  parentLeft = 0
                  parentRight = parentCoordinates.width
               # Иначе считаем координаты прокручиваемого родителя.
               else
                  parentCoordinates = parent.getBoundingClientRect()
                  parentTop = parentCoordinates.top
                  parentBottom = parentCoordinates.bottom
                  parentLeft = parentCoordinates.left
                  parentRight = parentCoordinates.right

               top = if parentTop > targetTop then parentTop else targetTop
               bottom = if parentBottom > targetBottom then targetBottom else parentBottom
               left = if parentLeft > targetLeft then parentLeft else targetLeft
               right = if parentRight > targetRight then targetRight else parentRight
               height = bottom - top
               width = right - left

               # Теперь, после определения координат, их нужно сдвинуть
               # относительно документа, если мы абсолютно позиционируемся.
               if isParentLayout and !isDockMode and !isNeedAdaptiveRule
                  top += body.scrollTop
                  bottom += body.scrollTop
                  left += body.scrollLeft
                  right += body.scrollLeft

            else return targetCoordinates

         else
            width = @state.size.width
            height = @state.size.height

      else
         if isDockMode and isWindowLayout
            return {
               bottom: body.offsetHeight
               height: body.offsetHeight
               left: 0
               right: body.offsetWidth
               top: 0
               width: body.offsetWidth
            }

      bottom: bottom
      height: height
      left: left
      right: right
      top: top
      width: width

   ###*
   * Функция установки жестких габаритов в док режиме. Устанавливает габариты
   *  в случае, если компонент показан.
   *
   * @return
   ###
   _getDockSize: ->
      component = ReactDOM.findDOMNode(@)
      coordinates = component.getBoundingClientRect()
      height: coordinates.height
      width: coordinates.width

   ###*
   * Функция получения размеров заголовка области. Находит элемент заголовка
   *  и получает его размеры.
   *
   * @return {Object}
   ###
   _getHeaderSize: ->
      headerElement = ReactDOM.findDOMNode(@refs[@_REFS.header])
      headerRect = headerElement.getBoundingClientRect()

      width: headerRect.width
      height: headerRect.height

   ###*
   * Функция получения позиционирования произвольной области относительно
   *  целевого узла на основе заданных параметров позиционарования.
   *
   * @return
   ###
   _setAreaLocation: ->
      areaNode = ReactDOM.findDOMNode(this)
      $area = $(areaNode)

      # АХТУНГ! применен хак для определения размеров скрытой области.
      $clonedArea = $area.clone().appendTo($area.parent())
      $clonedArea.css(@styles.resetPositionAndDimension)
      areaClientRect = $clonedArea[0].getBoundingClientRect()
      areaWidth = $clonedArea.outerWidth()
      areaHeight = $clonedArea.outerHeight()
      areaInnerWidth = $clonedArea.innerWidth()
      areaInnerHeight = $clonedArea.innerHeight()

      areaBorderSize =
         vertical: areaWidth - areaInnerWidth
         horizontal: areaHeight - areaInnerHeight

      $clonedArea.remove()
      #$area.css("left", areaOffset.left)

      isWindowLayout = @props.layoutAnchor is @_LAYOUT_ANCHORS.window
      isCanBeShift = @props.isFitToTargetParent or @props.isTriggerOnSameTarget
      isDockMode = @_isDockMode()
      size = @state.size

      # Если не задано позиционирование в потоке, то будем вычислять параметры
      #  смещения относительно целевого узла.
      unless @_isStreamLayout()
         targetNode = ReactDOM.findDOMNode(@state.targetNode)
         positionParams = @_getPositionParams()

         targetRect = @_getVisiblePartOfTarget(@props.target)

         # Если область в док режиме, то при вертикальном позиционировании
         #  установить её ширину в ширину целевого элемента.
         # Иначе установить длину области равной длине целевого элемента.
         if isDockMode
            if @_isVerticalDockMode()
               areaHeight = targetRect.height
            else
               areaWidth = targetRect.width

         top = @_getTopPosition positionParams,
                                targetRect,
                                areaHeight
         left = @_getLeftPosition positionParams,
                                  targetRect,
                                  areaWidth

         offset = if isWindowLayout and !isDockMode and isCanBeShift
            @_fitLocationToWindow left, top, areaWidth, areaHeight, targetRect
         else
            top: top
            left: left

         @setState
            offset: offset
            positionParams: positionParams

      size.width = areaWidth
      size.height = areaHeight

      @_fireReadyCallback(areaClientRect, areaBorderSize)

      @setState
         areaState: @_AREA_STATES.ready
         targetClientRect: targetRect
         areaClientRect: areaClientRect
         areaBorderSize: areaBorderSize
         size: size

   ###*
   * Функция-предикат для определения готова ли область к манипуляциям (для рендера
   *  содержимого).
   *
   * @return {Boolean}
   ###
   _isReady: ->
      areaStates = @_AREA_STATES
      @state.areaState in areaStates.ready

   ###*
   * Функция-предикат для определения находится ли область в анимации.
   *
   * @return {Boolean}
   ###
   _isInAnimaiton: ->
      areaStates = @_AREA_STATES
      @state.areaState is areaStates.animated

   ###*
   * Функция-предикат для определения необходим ли заголовок произвольной области.
   *
   * @return {Boolean}
   ###
   _isNeedCaption: ->
      isHasCloseButton = @props.isHasCloseButton
      isHasCaptionParams = @_isHasCaptionParams()

      isHasCloseButton or isHasCaptionParams

   ###*
   * Функция-предикат для определения заданы ли параметры заголовка.
   *
   * @return {Boolean}
   ###
   _isHasCaptionParams: ->
      captionParams = @props.captionParams
      captionParams? and !_.isEmpty(captionParams)

   ###*
   * Функция-предикат для проверки необходимости примения правила "адаптивности".
   *  Адаптивность нужна для абсолютно позиционированных областей, находящихся на
   *  фиксированно позиционированных узлах. Правило "адаптивности" необходимо применять
   *  к области если она находится на фиксированно позиционированном узле и в этом
   *  узле есть области с прокруткой(скроллингом).
   *
   * @return {Boolean}
   ###
   _isNeedAdaptiveRule: ->
      isNeed = false

      if @props.isAdaptive
         areaNode = ReactDOM.findDOMNode this

         if areaNode?
            nextParent = areaNode.parentNode
            isHasOverflow = false
            isHasFixedParent = false

            while(nextParent?)
               parentHeight = @_heightWithChildrenMargin(nextParent)
               parentScrollHeight = nextParent.scrollHeight

               unless isHasOverflow
                  isHasOverflow = parentScrollHeight > parentHeight + 5

               parentStyle = nextParent.style
               parentPosition =
                  if parentStyle?
                     nextParent.style.position

               if parentPosition is @_STYLE_FIXED_POSITION
                  isHasFixedParent = true

                  break

               nextParent = nextParent.parentNode

            isNeed = isHasOverflow and isHasFixedParent

      isNeed

   ###*
   * Функция-предикат для сравнения текущего запомненного в состояние целевого узла
   *  и другого сравниваемого узла. Если это react-компоненты(предполагаем что если
   *  передан не пустой объект - это компонент React.isValidElement - не работает здесь),
   *  то сравнивает внутререактовские ИД компонентов (Костыль, конечно, но не нашел способа лучше),
   *  иначе просто сравнивает два целевых узла.
   *
   * @param {Object, Boolean} comparedTarget - проверяемый целевой узел.
   * @return {Boolean}
   ###
   _isDifferentTarget: (comparedTarget) ->
      currentTarget = @state.targetNode
      isSetCurrentTarget = comparedTarget? and !$.isEmptyObject(comparedTarget)
      isSetComparedTarget = currentTarget? and !$.isEmptyObject(currentTarget)

      isDifferent =
         if isSetCurrentTarget and isSetComparedTarget #and
        # currentTarget.isMounted() and comparedTarget.isMounted()

            currentTargetReactID = ReactDOM.findDOMNode(@props.target).dataset.reactid
            comparedTargetReactID = ReactDOM.findDOMNode(comparedTarget).dataset.reactid

            currentTargetReactID isnt comparedTargetReactID
         else
            currentTarget isnt comparedTarget

      isDifferent

   ###*
   * Функция-предикат для определения находится ли произвольная область в "общем
   *  потоке" (задан ли якорь позиционирования - общий поток).
   *
   * @return {Boolean}
   ###
   _isStreamLayout: ->
      @props.layoutAnchor is @_LAYOUT_ANCHORS.stream

   ###*
   * Функция-предикат наличия позиционирования и готовности для показа области.
   *  Проверяет наличие параметра смещения при фиксированном позиционировании области.
   *  При позиционировании "в потоке" проверяет наличие положительного значения в
   *  параметре @props.target
   *
   * @return {Boolean}
   ###
   _isHasAreaPosition: ->
      if @_isStreamLayout()
         @state.targetNode
      else
         !$.isEmptyObject(@state.offset)
   ###*
   * Функция проверки существования целевого узла. В случае, если задано
   *  позиционирование в потоке, проверяет булевый тип целевого узла, иначе
   *  проверяет объект.
   *
   * @param {React-React-element, boolean} target - целевой узел
   * @return {Boolean}
   ###
   _isExistTarget: (target) ->
      if @_isStreamLayout()
         target
      else
         !_.isEmpty(target) and @_isTargetVisible(target)

   ###*
   * Функция проверки на то что переданный узел является
   *  данным экземляром произвольной области.
   *
   * @param {JQuery-obj} $node - проверяемый узел.
   * @return {Boolean} - флаг того, что родительский элемент - эта область.
   ###
   _isThisArea: ($node) ->
      ReactDOM.findDOMNode($node) is ReactDOM.findDOMNode(this)

   ###*
   * Функция-предикат для проверки находится ли текущая произовальная область
   *  в переданном массиве родительских элементов.
   *
   * @param {Array<JQuery-obj>} - набор объектов jquery.
   ###
   _isAreaInParents: ($parents) ->
      isInParents = false

      for $parent in $parents
         if @_isThisArea($parent)
            isInParents = true
            break

      isInParents

   ###*
   * Функция проверки видимости целевого узла. Если целевой узел имеет
   *  положительную ширину и высоту, не имеет display: none и не скрыт в скроле,
   *  то вернем true.
   *
   * @return {Boolean} - флаг того, что целевой элемент виден.
   ###
   _isTargetVisible: (target) ->
      target = ReactDOM.findDOMNode target
      visibleArea = @_getVisiblePartOfTarget(target)

      !(target.style.display is @styles.invisible.display) and
      !(target.offsetHeight < 0 or target.offsetWidth < 0) and
      !(visibleArea.height < 0 or visibleArea.width < 0)

   ###*
   * Функция, проверяющая позиционирование в Dock режиме. Если параметр
   *  isOpposite == true, то проверяет, является ли область горизонтально
   *  позиционированной. Иначе проверяет, является ли область вертикально
   *  позиционированной.
   *
   * @param {Boolean} isOpposite - параметр, указывающий на тип проверки.
   *                                true - горизонтальная
   *                                false -вертикальная.
   * @return {Boolean} - флаг вертикального (горизонтального) позиционирования.
   ###
   _isVerticalDockMode: (isOpposite) ->
      dockParams = @_DOCK_MODE_PARAMS
      positions = dockParams.positions
      dockPosition = @props.dockModeParams.position || dockParams.defaultPosition

      if isOpposite
         return dockPosition in [positions.top, positions.bottom]
      else
         return dockPosition in [positions.right, positions.left]

   ###*
   * Функция, проверяющая область на dock режим.
   *
   * @return {Boolean} - флаг dock режима.
   ###
   _isDockMode: ->
      @props.dockModeParams? and !$.isEmptyObject(@props.dockModeParams)

   ###*
   * Функция на нажатие клавиши мыши на объекте изменения размеров (ширины). Запускает
   *  изменение размеров (модуль BehaviorsMixin).
   *
   * @param {Object} event - объект события
   * @return
   ###
   _onMouseDownWidthResizer: (event) ->
      event.stopPropagation()

      positionParams = ReactDOM.findDOMNode(this).getBoundingClientRect()
      cellElementLeft = positionParams.left
      cellElementWidth = positionParams.width

      @_initResizeWidth(cellElementWidth, cellElementLeft)

   _onEventTerminateResizer: (event) ->
      event.stopPropagation()

   ###*
   * Функция на нажатие клавиши мыши на объекте изменения размеров (высоты). Запускает
   *  изменение размеров (модуль BehaviorsMixin).
   *
   * @param {Object} event - объект события
   * @return
   ###
   _onMouseDownHeightResizer: (event) ->
      event.stopPropagation()

      positionParams = ReactDOM.findDOMNode(this).getBoundingClientRect()
      cellElementTop = positionParams.top
      cellElementHeight = positionParams.height

      @_initResizeHeight(cellElementHeight, cellElementTop)

   ###*
   * Функция на нажатие клавиши мыши на объекте изменения размеров. Запускает
   *  изменение размеров (модуль BehaviorsMixin).
   *
   * @param {Object} event - объект события
   * @return
   ###
   _onMouseDownAllResizer: (event) ->
      event.stopPropagation()

      clientRect = ReactDOM.findDOMNode(this).getBoundingClientRect()
      positionParams =
         initTop: clientRect.top
         initLeft: clientRect.left
      sizeParams =
         height: clientRect.height
         width: clientRect.width

      @_initResize(positionParams, sizeParams)


   ###*
   * Обработчик на нажатие клавиши мыши на заголовке области. Устанавливает состоянии
   *  области на "в движении" (для стилей курсоров). И запускает обработчик инициализации
   *  движения (примесь BehaviorsMixin).
   *
   * @param (Event-object) event - объект события.
   ###
   _onMouseDownHeader: (event) ->
      moved = @_AREA_STATES.moved

      if @state.areaState is moved
         event.stopPropagation()
      else
         @_moveInit event, @state.offset

         @setState
            areaState: moved

   ###*
   * Обработчик на отпуск клавиши мыши на заголовке области. Устанавливает состоянии
   *  области на "показан" (для стилей курсоров). И запускает обработчик окончания
   *  движения (примесь BehaviorsMixin)..
   *
   * @param (Event-object) event - объект события.
   ###
   _onMouseUpHeader: (event) ->
      @_moveTerminate event

      @setState
         areaState: @_AREA_STATES.shown
         offset: @_getMoveOffset()

   ###*
   * Функция клика по кнопке закрытия произвольной области.
   *
   * @return
   ###
   _onClickClose: ->
      @_animationOut() if @state.areaState is @_AREA_STATES.shown

   ###*
   * Функция обработки клика по кнопке разворачивания области на все
   *  окно браузера.
   *
   * @return
   ###
   _onClickFullWindow: ->
      onFullWindowedTriggerHandler = @props.onFullWindowedTrigger
      isFullWindowedNew = !@state.isFullWindowed

      if onFullWindowedTriggerHandler?
         onFullWindowedTriggerHandler isFullWindowedNew

      @setState isFullWindowed: isFullWindowedNew

   ###*
   * Обработчик клика по произвольной области.
   *
   * @param {Event-obj} event - объект события.
   * @return
   ###
   _onClick: (event) ->
      onClickHandler = @props.onClick

      onClickHandler(this, event) if onClickHandler?

   ###*
   * Обработчик на получение фокуса областью.
   *
   * @param {Event-object} event - объект события.
   * @return
   ###
   _onFocusArea: (event) ->
      area = this

      ###*
      * Функция обработки получения фокуса областью.
      *
      * @param {DOM-Object} target - целевой узел фокуса.
      * @param {Event-object} event - объект события.
      * @return
      ###
      focusProcess = (target, event) ->
         chars = @_CHARS
         areaClassSelector = [
            chars.point
            @_AREA_CLASS
         ].join chars.empty

         $target = $(target)
         $parentsForRelatedTarget = $target.parents(areaClassSelector)
         isTargetInThisArea = @_isAreaInParents($parentsForRelatedTarget)
         isTargetIsThisArea = @_isThisArea(target)
         isNotProcessedFocus = isTargetInThisArea or isTargetInThisArea
         onFocusAreaHandler = @props.onFocus

         if !isNotProcessedFocus and onFocusAreaHandler?
            onFocusAreaHandler(target, event)

      # ??? Непроверенно: Костыль для Firefox - он некорректно возвращает event.target Поэтому
      #  для него нужно через таймаут взять активный элемент в документе и уже
      #  на его основе запустить обработку потери фокуса.
      if event.target?
         focusProcess.call(area, event.target, event)
      else
         @delay 4, ->
            focusProcess.call(area, document.activeElement, event)

   # @const {Object} - используемые коды клавиш клавиатуры.
   _KEY_CODES:
      esc: 27

   ###*
   * Обработчик на нажатие клавиши на клавиатуры на области.
   *
   * @param {Event-object} event - объект события.
   * @return
   ###
   _onKeyDown: (event) ->
      isKeyControlled = @props.isKeyControlled
      onKeyDownHandler = @props.onKeyDown

      onKeyDownHandler(event) if onKeyDownHandler?

      if isKeyControlled
         keyCodes = @_KEY_CODES
         keyCode = event.keyCode

         switch keyCode
            when keyCodes.esc
               @close()



   ###*
   * Обработчик на потерю фокуса произвольной области. После того как она показана
   *  на нее устанавливается фокус. После потери фокуса нужно скрыть область.
   *
   * @param {Event-object} event - объект события.
   * @return
   ###
   _onBlurArea: (event) ->
      area = this

      ###*
      * Функция обработки потери фокуса областью. Проверяет целевой узел -
      *  если он находится в этой области или это та же область область или
      *  область находится в анимации - не запускаем процесс скрытия области
      *  если задана опция скрытия на потерю фокуса.
      *
      * @param {DOM-Object} relatedTarget - целевой узел фокуса.
      * @param {Event-object} event - объект события.
      * @return
      ###
      blurProcess = (relatedTarget, event) ->
         chars = @_CHARS
         target = event.target
         $relatedTarget = $(relatedTarget)
         $target = $(target)

         areaClassSelector = [
            chars.point
            @_AREA_CLASS
         ].join chars.empty

         $parentsForTarget = $target.parents(areaClassSelector)
         $parentsForRelatedTarget = $relatedTarget.parents(areaClassSelector)

         isRelatedTargetInThisArea = @_isAreaInParents($parentsForRelatedTarget)
         isRelatedTargetIsThisArea = @_isThisArea(relatedTarget)
         isTargetInThisArea = @_isAreaInParents($parentsForTarget)
         isTargetVisible = @_isNodeVisible(target)

         areaState = @state.areaState
         isInAnimation = areaState is @_AREA_STATES.animated

         isRelatedTargetBody = relatedTarget.tagName is @_BODY_TAG_NAME
         isCloseOnBlurProp = @props.isCloseOnBlur
         isForcedLeaveShown = @props.isForcedLeaveShown

         # Логика определения флага необрабатываемого события потери фокуса.
         #  не обрабатываем если:
         #  1. ( исходный узел (на котором находился фокус) невидим
         #       и
         #       целевой узел - узел <body>
         #     (отсекание срабатываний от дочерних скрывамых произвольных областей).
         #     или
         #  2. ( целевой узел (куда перешел фокус) - не узел <body>.
         #       и
         #     2.1. ( целевой узел (куда перешел фокус) - данная область
         #            или
         #            целевой узел (куда перешел фокус) находится в данной области
         #          )
         #     )
         #  )
         isNotProcessedBlur = (!isTargetVisible and isRelatedTargetBody) or
                              (!isRelatedTargetBody and
                              (isRelatedTargetIsThisArea or
                               isRelatedTargetInThisArea ))

         onBlurHandler = @props.onBlur
         area = this

         # Не будем обрабатывать потерю фокуса области, если:
         #  - не задан флаг скрытия области на потерю фокуса.
         #  - задан флаг принудительного удержания области от закрытия.
         #  - область находится в анимации.
         #  - это "необрабатываемая" потеря фокуса
         if !isCloseOnBlurProp or
         isForcedLeaveShown or
         isInAnimation or
         isNotProcessedBlur
            return

         # TODO: перенесено после обработки флагов - не уверен что так правильно.
         # Запустим обработчик на потерю фокуса, если он был задан и целевой узел
         #  вне области.
         if !isNotProcessedBlur and onBlurHandler?
            onBlurHandler(relatedTarget, event)

         # Запустим функцию скрытия на потерю фокуса только по таймауту и запомним
         #  идентификатор таймаута, чтобы была возможность его сброса.

         @_closeTimeoutIdentifier = @delay 150, ->
            area._animationOut() if area.state.areaState is area._AREA_STATES.shown

      # Костыль для Firefox - он некорректно возвращает event.relatedTarget. Поэтому
      #  для него нужно через таймаут взять активный элемент в документе и уже
      #  на его основе запустить обработку потери фокуса.
      if event.relatedTarget?
         blurProcess.call(area, event.relatedTarget, event)
      else
         @delay 4, ->
            blurProcess.call(area, document.activeElement, event)

   ###*
   * Функция фокусировки на области. Проверяет задан ли флаг необходимости установки
   *  фокуса, затем не находится ли область уже в фокусе.
   *  показана ли область и не было ли уже начальной установки фокуса.
   *  Если все условия выполняются - выполняет фокусировку на области.
   *
   * @return
   ###
   _focusOnArea: ->
      # Если задана опция установки фокуса на области - продожим.
      if @props.isCatchFocus
         area = ReactDOM.findDOMNode(this)
         areaState = @state.areaState
         states = @_AREA_STATES
         isAreaShow = areaState is states.shown

         # Если область показана и ещё не в фокусе - сфокусируемся и установим состояние
         #  "начальная фокусировка выполнена"
         if !@state.isInitFocused and isAreaShow and !@_isNodeFocused(area)
            area.focus()
            @setState isInitFocused: true

   ###*
   * Функция запуска анимации показа. В зависимости от заданных параметров.
   *  запускает различную анимацию и устанавливает сосояние компонента в
   *  "в анимации".
   *
   * @param {Object} nextState - новое состояния компонента. Если параметр не
   *                             задан берется текущее состояние компонента.
   * @return
   ###
   _animationIn: (nextState) ->
      actualState = nextState or @state
      deadStyles = @props.deadStyles
      animations = @_ANIMATIONS
      areaSize = actualState.size
      areaOffset = actualState.offset
      areaHeight = areaSize.height
      areaWidth = areaSize.width

      switch @props.animation
         when animations.fade
            @_fadeOut @_animationInComplete
         when animations.slideUp

            @_slideUpIn @_animationInComplete,
                        areaHeight,
                        areaOffset.top + @props.offsetFromTarget.top
         when animations.slideRight
            @_slideRightIn @_animationInComplete,
                           areaWidth
         when animations.slideLeft
            @_slideLeftIn @_animationInComplete,
                           areaWidth,
                           areaOffset.left + @props.offsetFromTarget.left
         else
            startHeight =
               if deadStyles? and !_.isEmpty deadStyles
                  transitionHeight = deadStyles.height or deadStyles.maxHeight

                  if transitionHeight > areaHeight
                     areaHeight
                  else
                     transitionHeight

            @_slideDownIn @_animationInComplete,
                          areaHeight,
                          startHeight

      @setState
         areaState: @_AREA_STATES.animated

   ###*
   * Функция запуска анимации скрытия. В зависимости от заданных параметров.
   *  запускает различную анимацию. И устанавливает сосояние компонента в
   *  "в анимации"
   *
   * @param {Object} nextState - новое состояния компонента. Если параметр не
   *                             задан берется текущее состояние компонента.
   * @return
   ###
   _animationOut: (nextState) ->

      # Заглушка на случай, чтобы если мы уже в анимации и повторно не запускалась анимация.
      return if @state.areaState is @_AREA_STATES.animated

      actualState = nextState or @state
      animations = @_ANIMATIONS
      deadStyles = @props.deadStyles
      areaSize = actualState.size
      areaOffset = actualState.offset
      areaHeight = areaSize.height

      switch @props.animation
         when animations.fade
            @_fadeIn @_animationOutComplete
         when animations.slideUp
            @_slideUpOut @_animationOutComplete
         when animations.slideRight
            @_slideRightOut @_animationOutComplete
         when animations.slideLeft
            @_slideLeftOut @_animationOutComplete
         else
            finishHeight =
               if deadStyles? and !_.isEmpty deadStyles
                  transitionHeight = deadStyles.height or deadStyles.maxHeight

                  if transitionHeight > areaHeight
                     areaHeight
                  else
                     transitionHeight

            @_slideDownOut @_animationOutComplete,
                           areaHeight,
                           finishHeight


      @setState areaState: @_AREA_STATES.animated

   ###*
   * Обработчик запускаемый по окончанию анимации разворачивания.
   *  Устанавливает состояние области в "показано".
   *
   * @return
   ###
   _animationInComplete: ->
      preparedState =
         areaState: @_AREA_STATES.shown
         dockSize: if @_isDockMode() then @_getDockSize()

      # Если для области нужен заголовок - получим его размеры.
      if @_isNeedCaption()
         size = @state.size
         size.header = @_getHeaderSize()
         preparedState.size = size

      @_fireShowCallback()

      @setState preparedState


   ###*
   * Обработчик запускаемый по окончанию анимации сворачивания.
   *  Устанавливает состояние области в "инициализирован". Запускает облаботчик
   *  на скрытые области.
   *
   * @return
   ###
   _animationOutComplete: ->
      @_fireHideCallback()


   ###*
   * Функция подгонки значений смещения произвольной области в границах окна
   *  браузера для фиксированного позиционирования.
   *
   * @param {Number} left       - смещение слева.
   * @param {Number} top        - смещение сверху.
   * @param {Number} areaWidth  - ширина произвольной области.
   * @param {Number} areaHeight - высота произвольной области.
   * @return {Object} - параметры смещения {left, top}
   ###
   _fitLocationToWindow: (left, top, areaWidth, areaHeight) ->
      $window = $(window)
      windowHeight = $window.height()
      windowWidth = $window.width()

      right = left + areaWidth
      bottom = top + areaHeight

      padding = if @props.isAddPaddingToVisableArea then _COMMON_PADDING else 0

      if areaWidth > windowWidth or areaHeight > windowHeight
         finalLeft = left
         finalTop = top
      else
         finalLeft = if left < 0
                        padding * 2
                     else if right > windowWidth
                        windowWidth - areaWidth - padding * 2
                     else
                        left

         finalTop = if top < 0
                       padding * 2
                    else if bottom > windowHeight
                       windowHeight - areaHeight - padding * 2
                    else
                       top

      left: finalLeft
      top: finalTop


   ###*
   * Функция запуска обработчика на готовность области (определены размеры и
   *  расположение области).
   *
   * @param {Object} areaClientRect - параметры ограничений области области
   *                                  (размеры, позиционирование).
   * @param {Object} areaBorderSize - размеры рамки области (вертикальные и горизонтальыне границы).
   * @return
   ###
   _fireReadyCallback: (areaClientRect, areaBorderSize) ->
      onReadyHandler = @props.onReady

      onReadyHandler(this, areaClientRect, areaBorderSize) if onReadyHandler?

   ###*
   * Функция запуска обработчика на скрытие области. Запускает обработчик, если
   *  он был задан.
   *
   * @return
   ###
   _fireHideCallback: ->
      onHideHandler = @props.onHide
      preparedState =
         areaState: @_AREA_STATES.init #@_AREA_STATES.ready
         targetNode: null

      if @props.isCatchFocus
         preparedState.isInitFocused = false

      onHideHandler(this) if onHideHandler?

      @setState preparedState

   ###*
   * Функция запуска обработчика после показа области. Запускает обработчик, если
   *  он был задан.
   *
   * @return
   ###
   _fireShowCallback: ->
      onShowHandler = @props.onShow
      onShowHandler() if onShowHandler?


###* Компонент - шапка произольной области. Часть компонента ArbitraryArea.
*  включает в себя заголовок с тексом и иконкой, кнопку закрытия.
*
* @props
*-
*     {Object} captionParams     - параметры заголовка.
*     {Boolean} isMoved          - флаг того, что область находится в движении.
*     {Boolean} isMovable        - флаг того, что область можно передвигать.
*     {Boolean} isHasCloseButton - флаг наличия кнопки закрытия.
*{Boolean} isHasFullWindowButton - флаг наличия кнопки разворачивания области на все окно.
*  {Boolean} isCloseButtonOnArea - флаг располажения кнопки закрытия на области
*                                  поверх содержимого.
* {Boolean} isFullWindowed - флаг раскрытия области на все окно браузера.
*     {Function} onClickClose    - обработчик нажатия на кнопку закрытия области.
*   {Function} onClickFullWindow - обработчик нажатия на кнопку разворачивания области
*                                  на все окно браузера.
*     {Function} onMouseDown     - обработчик нажатия на клавишу мыши на шапке.
*     {Function} onMouseUp       - обработчик на отпуск кнопки мыши на шапке.
###
ArbitraryAreaHeader = React.createClass

   # @const {String} - префикс класса иконок FontAwesome
   _FA_ICON_PREFIX: 'fa fa-'

   # @const {String} - всплывающее пояснение на кнопке закрытия окна.
   _CLOSE_DIALOG_TITLE: 'закрыть'

   # @const {Object} - символы для кнопки разворачивания/сворачивания
   #                   области на все окно браузера.
   _FULL_WINDOW_BUTTON_PARAMS:
      expand:
         #caption: '□'
         icon: 'expand'
         title: 'развернуть на все окно'
      collapse:
         #caption: '▭'
         icon: 'compress'
         title: 'вернуться к исходному размеру'

   mixins: [HelpersMixin]

   styles:
      captionTable:
         backgroundColor: _COLORS.secondary
         padding: _COMMON_PADDING
         color: _COLORS.light
         fontWeight: 'bold'
         width: '100%'
      captionIcon:
         paddingLeft: 15
         paddingRight: 15
      captionGrab:
         cursor: 'grab'
         cursor: '-webkit-grab'
      captionMove:
         cursor: 'move'
      # content:
      #    position: 'absolute'
      closeAreaButton:
         fontSize: 28
      fullWindowAreaButton:
         fontSize: 17
         padding: 0
         color: _COLORS.hierarchy2
      customFunctionalButton:
         fontSize: 19
         color: _COLORS.hierarchy2
         padding: 0
         # marginTop: 3
      floatCloseButtonOut:
         position: 'absolute'
         top: -25
         right: -4
      floatCloseButtonIn:
         position: 'absolute'
         top: 0
         right: 0
      iconHeaderCell:
         width: 1
         verticalAlign: 'middle'
         paddingLeft: _COMMON_PADDING
         paddingRight: _COMMON_PADDING
      customActionButton:
         color: _COLORS.hierarchy2

   render: ->
      propCaption = @props.captionParams
      styleAddition = propCaption.styleAddition
      styleAdditionCloseButton = styleAddition.closeButton if styleAddition?
      styleAdditionFullWindowButton = styleAddition.fullWindonButton if styleAddition?


      # Если заданы параметры заголовка - сформируем объект с надписью и иконкой
      if propCaption? and !_.isEmpty(propCaption)
         captionText = propCaption.text
         captionIcon = propCaption.icon
         captionStyleAddition = styleAddition.common if styleAddition?
         isMovable = @props.isMovable
         isMoved = @props.isMoved

         icon = if captionIcon?
                   `(
                      <i className={this._FA_ICON_PREFIX + captionIcon}
                         style={this.styles.captionIcon}></i>
                     )`
         computedStyleHeader = @computeStyles @styles.captionTable,
                                              captionStyleAddition,
                                              isMovable and @styles.captionGrab,
                                              isMoved and @styles.captionMove


         `(
            <table style={computedStyleHeader}
                   onMouseDown={isMovable ? this.props.onMouseDown : null}
                   onMouseUp={isMovable ? this.props.onMouseUp : null}
                   onDoubleClick={this._onDoubleClick}>
               <tbody>
                  <tr>
                     {this._getCustomActionsCell()}
                     <td style={this.styles.iconHeaderCell}>{icon}</td>
                     <td>{captionText}</td>
                     {this._getCustomFunctionalButtonsCell()}
                     {this._getFullWindowButtonCell(styleAdditionFullWindowButton)}
                     {this._getCloseButtonCell(styleAdditionCloseButton)}
                  </tr>
               </tbody>
            </table>
          )`
      else if @props.isHasCloseButton
         isCloseButtonOnArea = @props.isCloseButtonOnArea
         floatStyle = if isCloseButtonOnArea
                         @styles.floatCloseButtonIn
                      else
                         @styles.floatCloseButtonOut

         buttonStyle = @computeStyles floatStyle,
                                      styleAdditionCloseButton
         @_getCloseButton(buttonStyle)

   ###*
   * Функция получения ячейки пользовательских операций. Создает ячейку с группой
   *  кнопок, если был задан параметр @props.captionParams.customActions.
   *
   * @return {React-Elements}
   ###
   _getCustomActionsCell: ->
      captionParams = @props.captionParams
      customActions = if captionParams? and !_.isEmpty captionParams
                         captionParams.customActions
      objectCard = this

      if customActions? and !_.isEmpty customActions
         buttons =
            customActions.map (action) ->
               customStyleAddition = action.styleAddition
               action.styleAddition =
                  objectCard.computeStyles objectCard.styles.customActionButton,
                                           customStyleAddition
               action

         `(
            <td>
               <ButtonGroup buttons={buttons}
                            isIndependent={true}
                          />
            </td>
          )`

   ###*
   * Функция получения ячеек пользовательских функциональынх действий.
   *  Создает ячейки с кнопоками, если был задан параметр
   *  @props.captionParams.customFunctionalButtons.
   *
   * @return {Array<React-Elements>}
   ###
   _getCustomFunctionalButtonsCell: ->
      customFunctionalButtons = @props.captionParams.customFunctionalButtons

      ###*
      * Функция формирования ячейка заголовка таблицы.
      *
      * @param {React-element} - доп. функциональная кнопка.
      * @param {Number} key - индекс кнопки.
      ###
      getCellWithButton = ((buttonParams, key) ->
         `(
            <td key={key}
                style={this.styles.iconHeaderCell}>
               <Button {...buttonParams}
                       isWithoutPadding={true}
                       styleAddition={this.styles.customFunctionalButton}
                  />
            </td>
          )`
      ).bind(this)

      if customFunctionalButtons? and !_.isEmpty customFunctionalButtons
         customFunctionalButtons.map(getCellWithButton)

   ###*
   * Функция получения ячейки с кнопкой переключения режима полного экрана.
   *
   * @param {Object} styleAddition - доп. стили для кнопки.
   * @return {React-Element}
   ###
   _getFullWindowButtonCell: (styleAddition)->
      fullWindowButton = @_getFullWindowButton(styleAddition)

      if fullWindowButton?
         `(
            <td style={this.styles.iconHeaderCell}>
               {fullWindowButton}
            </td>
         )`

   ###*
   * Функция получения ячейки с кнопкой закрытия области.
   *
   * @param {Object} styleAddition - доп. стили для кнопки.
   * @return {React-Element}
   ###
   _getCloseButtonCell: (styleAddition) ->
      closeButton = @_getCloseButton(styleAddition)

      if closeButton?
         `(
            <td style={this.styles.iconHeaderCell}>
               {this._getCloseButton(styleAddition)}
            </td>
          )`

   ###*
   * Функция получения кнопки закрытия области.
   *
   * @param {Object} styleAddition - доп. стили для кнопки.
   * @return {React-Element}
   ###
   _getCloseButton: (styleAddition) ->

      if @props.isHasCloseButton
         style = @computeStyles @styles.closeAreaButton, styleAddition

         `(
            <Button title={this._CLOSE_DIALOG_TITLE}
                    isClear={true}
                    isLink={true}
                    isWithoutPadding={true}
                    styleAddition={style}
                    onClick={this.props.onClickClose}
                  />
          )`


   ###*
   * Функция получпения кнопки разворачивания области на все окно.
   *
   * @param {Object} styleAddition - доп. стили для кнопки.
   * @return {React-Element}
   ###
   _getFullWindowButton: (styleAddition) ->

      if @props.isHasFullWindowButton
         style = @computeStyles @styles.fullWindowAreaButton, styleAddition
         fullWindowButtonParams = @_FULL_WINDOW_BUTTON_PARAMS
         buttonParams =
            if @props.isFullWindowed
               fullWindowButtonParams.collapse
            else
               fullWindowButtonParams.expand

         `(
            <Button icon={buttonParams.icon}
                    title={buttonParams.title}
                    isLink={true}
                    isWithoutPadding={true}
                    styleAddition={style}
                    onClick={this.props.onClickFullWindow}
                  />
          )`

   ###*
   * Обработчик двойного клика на заголовке. И в случае наличия функциональности
   *  разворачивания области на весь области экран вызывает обработчик разворачивания
   *  весь экран
   *
   * @param {Object} styleAddition - доп. стили для кнопки.
   * @return {React-Element}
   ###
   _onDoubleClick: (event)->
      event.stopPropagation()

      if @props.isHasFullWindowButton
         @props.onClickFullWindow()

###* Компонент - изолированный контейнер контента произвольной области. Часть
*                компонента ArbitraryArea
*     {Boolean} isInAnimaiton - флаг нахождения области в анимации.
*     {Object} style          - стиль для контейнера.
*     {React-Element, String} - содержимое области.
* @props:
*     {React-Element, String} content - содержимое.
###
ArbitraryAreaIsolatedContent = React.createClass
   #mixin: [PureRenderMixin]

   shouldComponentUpdate: (nextProps, nextState) ->
      !nextProps.isInAnimaiton and !_.isEqual(@props, nextProps)

   render: ->
      `(
         <div style={this.props.style}>
            {this.props.content}
         </div>
       )`

module.exports = ArbitraryArea
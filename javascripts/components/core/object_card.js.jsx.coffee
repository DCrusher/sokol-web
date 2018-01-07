###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* HelpersMixin     - функции-хэлперы для компонентов.
* AnimationsMixin  - набор анимаций для компонентов.
* AnimateMixin     - библиотека добавляющая компонентам
*                    возможность исользования анимации.
* string-template  - модуль для формирования строк из шаблонов.
* keymirror        - модуль для генерации "зеркального" хэша.
* loglevel         - модуль для вывода формитированных логов в отладчик.
* lodash           - модуль служебных операций.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
AnimationsMixin = require('../mixins/animations')
AnimateMixin = require('react-animate')
format = require('string-template')
keyMirror = require('keymirror')
log = require('loglevel')
_ = require('lodash')

###* Зависимости: компоненты
* ArbitraryArea - произвольная область.
* Taber         - контейнер с вкладками.
* Button        - кнопка.
* DynamicForm   - динамическая форма.
###
ArbitraryArea = require('components/core/arbitrary_area')
Taber = require('components/core/taber')
Button = require('components/core/button')
DynamicForm = require('components/core/dynamic_form')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius

###* Компонент: всплывающая произвольная область с данными по объекту.
*
* @props:
*     {Object} areaParams   - хэш с параметрами позиционирования карточки и правил показа
*                             карточки (прокидываются в компонент ArbitraryArea).
*     {Object} record       - хэш с параметрами записи по которой создается карточка.
*     {Number} maxDataTabCountPerLine - максимальное кол-во вкладок для
*                                       раздела "Данные" в одну линию(вкладки добавляются,
*                                       если задан флаг isDisplayReflections и для
*                                       объекта есть связанные сущности). Если
*                                       общее кол-во вкладок будет выходить за заданный
*                                       максимум - будет добавляться вкладка выбора
*                                       остальных с пометкой '...'
*     {Object} dataManipulationParams - хэш параметров манипуляции данными. Параметры аналогичны
*                                       параметрам dataManipulationParams компонента DataTable.
*     {Object} parentModelParams - хэш параметров модели родительского элемента(таблицы данных).
*                                  Данный нужен для получения наименования модели родительского
*                                  компонента (таблицы) для запроса через него данных связки, если
*                                  в параметрах связки задан параметр isUseParentResource.
*     {Object} formatRules  - хэш параметров форматирования карточки. Вид:
*                        {Object} caption: - хэш параметров форматирования заголовка карточки. Вид:
*                                {String} template - шаблон для форматировия. Пример: "{0} ({1}-{2})"
*                                {Array} fields    - массив полей выводимых из записи в шаблон
*                                {String} icon     - иконка в заголовке
*                        {Object} content - параметры ренедра основного содержимого карточки. Вид:
*                                {Function} render - функция рендера содержимого карточки (основного вида).
*                                {Boolean} isHideFieldCaptions - флаг скрытия заголовков для полей при
*                                                                 стандартном рендере полей записи.
*                        {Object} reflections - параметры формирования для связок. Вид элемента:
*                                [collectionName] {Object} - параметры для коллекции collectionName. Вид:
*                                      {String} icon          - иконка, выводимая в заголовке вкладки для данной коллекции.
*                                      {Boolean} isHidden     - флаг скрытия связки (не выводится во вкладке).
*                                      {Boolean} isProhibited - флаг запрещения работы со связкой (не выводится
*                                                               во отдельной вкладке раздела "данные" и
*                                                               при формировании печатной формы карточки).
*                                      {Boolean} isDamned     - флаг "проклятости" связки. Если данный флаг задан,
*                                                               то для данной связки не создаются отображения
*                                                               для всех дочерних элементов(на всех уровнях вложенности
*                                                               начиная с текущей).
*                               {Boolean} isUseParentResource - флаг использования родительского ресурса.
*                                                               Если данный флаг задан, то при формировании
*                                                               таблицы данных для отображения экземпляров
*                                                               связки имя модели для таблицы будет задано
*                                                               такое же как и для родительской модели (для
*                                                               работы через сервисное хранилище flux).
*                                   {Array<Object>} relations - параметр аналогичен параметру
*                                                               @props.modelParams.relations
*                                                               для возможности формирования
*                                                               корректных параметров для таблиц данных
*                                                               связок.
*                        {Array<Object>} relationAlternatives - альтернативы связок. Если задан данный
*                                                               параметр, то связки, применяемые для
*                                                               построения таблицы определяются по
*                                                               первой(упорядочивание по индексам
*                                                               массива) подходящей
*                                                               альтернативе. Подходящая альтернатива
*                                                               определяется по имени альтернативы -
*                                                               если она присутствует в связках серилизованной
*                                                               записи, применяются параметры для нее,
*                                                               остальные игнорируются. Если
*                                                               задан параметр relations, то данный параметр
*                                                               игнорируется. Вид элемента:
*                                                               {String} name - имя альтернативы (совпадает с
*                                                                               именем связки серилизованной
*                                                                               записи).
*                                                               {Array<Object>} - relations - параметры
*                                                                                             связок.
*                                   {String} redefinedCaption - переопределяемый заголовок связки.
*                                                               (выводимый в закладке для связки).
*                                                               Если параметр не задан, то выводимый
*                                                               заголовок определяется непосредственно
*                                                               из параметров связей записи.
*                                   {Object} dataTableParams  - любые специфичные параметры для таблицы,
*                                                               используемой для вывода записей связки.
*     {Array<Object>} customActions - массив пользовательских действий над карточкой.
*                                     Каждый элемент представляет собой хэш с параметрами:
*                       {String} name    - имя действия
*                       {String} caption - заголовок, выводимый на селекторе вкладке с действием.
*                       {String} icon    - наименование иконки.
*        {String, React-element} content - содержимое вкладки.
*                       {String} keyProp - наименование свойства-ключа экземпляра, передаваемого в
*                                          элемент-содержимое вкладки.
*                      {Function} render - функция-рендер содержимого вкладки.
*     {Object} operationParams - параметры операций над объектом. Данный параметр
*                                нужен для управления стандартными и пользовательскими операцями
*                                над объектом выполняемые прямым запросом (через кнопку) или
*                                делегируемых внешнему элементу(диалоговому окну, области и т.д.)
*                                по нажатию на кнопку. Данный парметр усправляет созданием
*                                кнопок-операций в заголовке карточки (соответственно заголовок
*                                должен быть включен). Вид:
*                                {Boolean} isUseStandard - флаг использования стандартных операций
*                                                          (переход к редактированию, удаление,
*                                                          формирование паспорта объекта в виде файла).
*                                {Array<Object>} custom - массив параметров произвольных действий
*                                                                над объектом. Вид:
*                                               {String} name - наименование операции (для идентификации).
*                                               {String} icon - иконка на кнопке.
*                                              {String} title - выводимая подсказка на кнопке.
*
*                                          {Function} handler - обработчик нажатия на кнопку. Аргумент:
*                                                               {Object} record - запись объекта.
*                                          {Function} render  - обработчик формирования содержимого для
*                                                               операции. Аргументы:
*                                                               {Object} record - запись объекта.
*                                         {Object} formParams - параметры для построения формы.
*                                                               Корректно работает для внешних связок модели.
*                                                               Вид:
*                                                               {Object} caption - заголовок, выводимый
*                                                                                  в области-контейнере формы.
*                                                                                  Если параметр не задан -
*                                                                                  заголовок у области не формируется.
*                                               {Array<String>} reflectionsChain - массив наименований связок,
*                                                                                  по которым будут выбраны параметры
*                                                                                  сущности для которой будет формироваться
*                                                                                  динамическая форма.
*                                                                                  Например:
*                                                                                    ['Treasusy', 'PropertyMilestone'] -
*                                                                                  для реестра имущества (Property) будут
*                                                                                  выбраны параметры для создания сущности по цепи:
*                                                                                  Property -> Treasury -> PropertyMilestone
*                                                                                  (Имущество -> Казна -> Ввод/вывод имущетсва).
*
*     {Object} implementationStore   - хранилище реализаций.
*     {Boolean} isUseImplementation  - флаг использования хранилища реализаций. (по-умолчанию = false)
*     {Boolean} isMergeImplementation - флаг "слияния" свойств компонента со свойствами, заданными в
*                                       хранилище реализаций. (по-умолчанию = false)
*    {Boolean} isFreezeAtInteraction - флаг "удержания" карточки от скрытия при потере фокуса
*                                      если пользователь производит на ней взаимодействие
*                                      (активирована вкладка произвольного действия @props.customAction).
*     {Boolean} isDisplayReflections - флаг отображения связок на отдельных вкладках
*                                      контейнера с таб вкладками.
*                                      По-умолчанию = false. Параметр актуален для записей,
*                                      в которых есть связанные сущности.
*     {Boolean} enableEdit:         - флаг разрешения обновления записей (по-умолчанию = true).
*                                     Флаг актуален, если задан флаг @props.operationParams.isUseStandard
*     {Boolean} enableDelete:       - флаг разрешения удаления записей (по-умолчанию = true).
*                                     Флаг актуален, если задан флаг @props.operationParams.isUseStandard
*     {Boolean} enableExport        - флаг разрешения экспорта объекта (по-умолчанию = true).
*                                     Флаг актуален, если задан флаг @props.operationParams.isUseStandard
*     {Boolean} enableManual        - флаг разрешения работы с руководствами.
*                                     (по-умолчанию = false).
*     {Function} onShow             - обработчик на показ карточки объекта.
*     {Function} onHide             - обработчик на скрытие карточки объекта.
*     {Function} onClickOpenManual  - обработчик клика на открытие руководства.
* @state:
*     {Object} processedValues    - хэш с параметрами выводимых значений записи. Данный
*                                   параметр нужен для хранения значений записи без
*                                   уже обработанных ранее значений (например заголовка карточки).
*     {String} activatedOperation - наименование задействованной операции. Если данное состояние
*                                   задано выводит панель операций с контентом операции.
*   {Number} activatedActionIndex - индекс активированной вкладки действий.
*{Boolean} isMainAreaFullWindowed - флаг того, что главная область карточки развернута на все
*                                   окно браузера.
* {Array<Object>} objectReflections - массив параметров связок записи. Данный массив формируется
*                                     рекурсивным проходом по связкам записи и используется в нескольких
*                                     местах, поэтому он считывается один раз или перечитывается при
*                                     пробросе новых свойств. Вид элемента:
*                                     {Object} value          - значение связки.
*                                     {String} name           - имя связки.
*                                     {String} caption        - заголовок связки.
*                                     {Array<String>} parents - массив имен родительских связок.
*                                     {Boolean} isHidden      - флаг скрытия связки.
*                                     {Boolean} isProhibited  - флаг запрещения работы со связкой.
*                                     {Boolean} isDamned      - флаг "проклятости" связки. Если флаг
*                                                               задан, то все рекурсивно считанные
*                                                               связи-потомки будут запрещены для работы
*                                                               (isProhibited).
*                                     {Boolean} isChecked     - флаг выбранности данной связки для
*                                                               включение в паспорт объекта при сохранении.
*                                     {Object} reflectionRule - параметры правил для связки.
###
ObjectCard = React.createClass
   # @const {Object} - хэш возможных интересуемых для предварительно обработки типов данных.
   _DATA_TYPES: keyMirror(
      date: null,
      datetime: null,
      collection: null
   )

   # @const {Object} - параметры для произвольной области-контейнера карточки
   #                   по-умолчанию.
   _DEFAULT_MAIN_AREA_PARAMS:
      position:
         vertical:
            top: 'bottom'
         horizontal:
            left: 'left'
      isHasShadow: true
      isHasBorder: false
      isHasCloseButton: true
      isHasFullWindowButton: true
      isMovable: true
      isCatchFocus: false
      isKeyControlled: true
      enableResize: true
      animation: 'slideDown'

   # @const {Object} - иконки для вкладок при разбиении на коллекции
   _COLLECTION_ICONS:
      list: 'list'
      main: 'tag'
      many: 'bars'
      one: 'diamond'

   # @const {Object} - параметры для основного таб-контейнера.
   _MAIN_TABER_PARAMS:
      enableTriggerNav: true
      enableLazyMount: true
      navigatorPosition: 'left'

   # @const {Object} - параметры для компонента таблица данных для вывода связок.
   _DATA_TABLE_PARAMS:
      enableToolbar: false
      enableCreate: false
      enableEdit: false
      enableDelete: false
      isFitToContainer: true
      isHasStripFarming: false
      isPageSelectorInLinkMode: true
      fluxParams:
         isUseServiceInfrastructure: true
      dimension:
         dataContainer:
            height:
               max: 600

   # @const {Object} - ключи для параметров организации коллекций.
   _REFLECTION_RULE_KEYS: keyMirror(
      icon: null
      isHidden: null
      isProhibited: null
      isUseParentResource: null
      relations: null
      relationAlternatives: null
      dataTableParams: null
      redefinedCaption: null
   )

   # @const {Object} - предварительные параметры для стандартных операций над объектом.
   _STANDARD_OPERATIONS_SCAFFOLD:
      passport:
         icon: 'file-text-o'
         title: 'Сохранить печатную форму объекта'
      edit:
         icon: 'pencil'
         title: 'Редактировать'
      delete:
         icon: 'trash'
         title: 'Удалить'

   # @const {Object} - используемые сообщения.
   _MESSAGES:
      errors:
         target:
            notContainEditHandler: 'В целевом узле не задан обработчик редактирования'
            notContainDeleteHandler: 'В целевом узле не задан обработчик удаления'
            notContainGetInstanceHandler: 'В целевом узле не задан обработчик получения экземпляра'
            notContainGetEntityParamsHandler: 'В целевом узле не задан обработчик получения параметров сущности'
            notContainGetModelParamsHandler: 'В целевом узле не задан обработчик получения параметров модели'

   # @const {Object} - возможные обработчики задаваемых в целевом узле.
   _TARGET_HANDLERS:
      getValue: 'getFieldValue'          # Функция получение значение поля (с различными обработчиками).
      getInstanceFile: 'getInstanceFile' # Функция получения из API файла экземпляра (в различных форматах).
      getEntityParams: 'getEntityParams' # Функция получения параметров для создания экземпляра сущности (для формирования динамической формы).
      getModelParams: 'getModelParams'   # Функция получения параметров модели для связки (для формирования динамической формы).
      editRecord: 'editRecord'           # Функция запуска операции редактирования объекта.
      deleteRecord: 'deleteRecord'       # Функция запуска операции удаления объекта.
      isHidden: 'isFieldHidden'          # Функция-предикат для определения является ли поле скрываемым.

   # @const {Object} - параметры для области панели формирования печатной формы объекта.
   _OPERATION_AREA_PARAMS:
      position:
         vertical:
            top: 'top'
         horizontal:
            left: 'left'
      offsetFromTarget:
         left: 20
         top: 40
      animation: 'fade'
      isKeyControlled: true
      isHasShadow: true
      isCatchFocus: false
      isHasBorder: false

   # @const {Object} - стандартные операции, отображаемые в панели.
   _STANDARD_PANEL_OPERATIONS: keyMirror(
      passport: null
      none: null
   )

   # @const {Object} - параметры для контейнера со вкладками параметров записи
   #                   карточки объекта.
   _DATA_TABER_PARAMS:
      navigatorPosition: 'top'
      isClassic: true
      enableTriggerNav: true
      enableLazyMount: true
      activeIndex: 0

   # @const {Object} - используемые ссылки на элементы.
   _REFS:
      dataTaber: 'objectCardContainer'

    # @const {Object} - параметры для панели сохранения печатной формы карточки
    #                   объекта.
   _PASSPORT_ELEMENT_PARAMS:
      caption: 'Параметры печатной формы'
      reflections:
         legend: 'Включаемые связки'
      allSelectorParams:
         name: 'selectAll'
         caption: 'выбрать все'
      buttonCreate:
         icon: 'floppy-o'
         title: 'Сформировать печатную форму карточки'
         caption: 'Сформировать'

   # @const {Object} - ключи, используемые для элементов связок объекта.
   _OBJECT_REFLECTION_KEYS: keyMirror(
      value: null
      name: null
      caption: null
      parents: null
      isHidden: null
      isProhibited: null
      isDamned: null
      isChecked: null
      reflectionRule: null
   )

   # @const {Object} - парамеры для динамической формы.
   _DYNAMIC_FORM_PARAMS:
      mode: 'update'
      fluxParams:
         isUseServiceInfrastructure: true
      enableManageReflections: false

   # @const {Object} - доп. параметры для области операции для пользовательсих
   #                   операций.
   _CUSTOM_OPERATION_ADDITION_AREA_PARAMS:
      enableResize: true
      isMovable: true
      isHasCloseButton: true

   # @const {Object} - используемые символы.
   _CHARS:
      empty: ''
      space: ' '
      arrowForward: '→'

   # @const {Array<Object>} - шаблонный макет для конструирования параметров
   #                          связки по-умолчанию.
   _DEFAULT_REFLECTION_SCAFFOLD:
      [
         reflection: null
         primaryKey:
            name: 'id'
         isCollection: true
         isReverseMultiple: true
         polymorphicReverse: null
         index: 1
      ]

   # @const {Object} - шаблонный макет для конструирования фильтра для выбора
   #                   объекта самосвязи.
   _SELF_RELATION_FILTER_SCAFFOLD:
      filter:
         terms: [
            field:
               name: 'id'
               type: 'integer'
            expr: null
            match: 'eq'
         ]

   # @const {Object} - начальные параметры для доп. функциональынх кнопок заголовка
   #                   произвольной области.
   _FUNCTIONAL_BUTTON_SCAFFOLDS:
      manual:
         key: 'manual'
         icon: 'book'
         title: 'Открыть руководство'
         isLink: true
         isWithouPadding: true
         value:
            action: 'show'

   # @const {String} - наименование класса, присваиваемого кнопкам операции над
   #                   объектом для идентификации.
   _OPERATION_BUTTON_CLASS_NAME: 'operationButton'

   # @const {String} - маркер отмеченности поля-селектора.
   _CHECKED_MARKER: 'checked'

   # @const {String} - заголовок вкладки с общей информацией по объекту.
   _COMMON_CONTENT_TAB_TITLE: 'Данные'

   # @const {String} - заголовок вкладки с общей информацией при разбиении на коллекции.
   _COMMON_SCATTED_TAB_TITLE: 'Параметры'

   # @const {String} - тип поля ввода для флагов.
   _CHECKBOX_INPUT_TYPE: 'checkbox'

   mixins: [HelpersMixin]

   styles:
      mainArea:
         maxWidth: 1200
         textAlign: 'left'
      cardContent:
         maxHeight: 500
         display: 'inline-block'
         overflow: 'auto'
         fontSize: 14
      captionCell:
         textAlign: 'right'
         paddingRight: _COMMON_PADDING
         color: _COLORS.hierarchy2
         #borderRight: "1px solid #{_COLORS.hierarchy4}"
      valueCell:
         fontStyle: 'italic'
      commonContentTableCellPadding: '3em'
      scattedCollectionTable:
         borderCollapse: 'collapse'
         color: _COLORS.hierarchy2
         fontSize: 14
         whiteSpace: 'nowrap'
         tableLayout: 'fixed'
         width: '100%'
      scattedCollectionRow:
         borderBottomStyle: 'solid'
         borderBottomWidth: 1
         borderBottomColor: _COLORS.hierarchy4
      scattedCollectionCell:
         padding: _COMMON_PADDING
         textOverflow: 'ellipsis'
         overflow: 'hidden'
      taberStyle:
        # maxWidth: 1000
         height: '100%'
      taberAdditionMargin:
         margin: _COMMON_PADDING
      taberContent:
         overflow: 'auto'
         maxHeight: 800
      deleteButton:
         color: _COLORS.alert
      passportContainer:
         padding: _COMMON_PADDING
         color: _COLORS.hierarchy2
         fontSize: 14
      passportCaption:
         marginTop: 0
         marginBottom: 8
      passportReflectionsSet:
         marginBottom: _COMMON_PADDING
         borderRadius: _COMMON_BORDER_RADIUS
         borderColor: _COLORS.hierarchy4
      passportReflectionsList:
         listStyle: 'none'
         padding: 0
         margin: 0
      passprotReflectionsListItem:
         verticalAlign: 'middle'
      passportReflectionItemElement:
         verticalAlign: 'inherit'
      passportAllReflectionsSelectorLabel:
         fontSize: 13
         color: _COLORS.hierarchy3
         borderBottomStyle: 'solid'
         borderBottomWidth: 1
      resetAreaSizeStyles:
         maxWidth: ''
         maxHeight: ''
         width: ''
         height: ''
      customOperationAreaAddition:
         maxWidth: 1000
         #maxHeight: 800
      customOperationAreaHeaderAddition:
         color: _COLORS.light
         backgroundColor: _COLORS.hierarchy3
         fontWeight: 'normal'
      operationDynamicFormContainer:
         padding: 2
      mainTaberStretchOnParent:
         position: 'absolute'
         height: '96%'
         # top: 0

   propTypes:
      areaParams: React.PropTypes.object
      record: React.PropTypes.object
      dataManipulationParams: React.PropTypes.object
      formatRules: React.PropTypes.object
      maxDataTabCountPerLine: React.PropTypes.number
      operationParams: React.PropTypes.object
      customActions: React.PropTypes.arrayOf(React.PropTypes.object)
      isDisplayReflections: React.PropTypes.bool
      isUseImplementation: React.PropTypes.bool
      isMergeImplementation: React.PropTypes.bool
      enableEdit: React.PropTypes.bool
      enableDelete: React.PropTypes.bool
      enableExport: React.PropTypes.bool
      enableManual: React.PropTypes.bool
      implementationStore: React.PropTypes.object
      onClickOpenManual: React.PropTypes.func
      onShow: React.PropTypes.func
      onHide: React.PropTypes.func

   getDefaultProps: ->
      isDisplayReflections: false
      isUseImplementation: false
      isMergeImplementation: false
      enableEdit: true
      enableDelete: true
      enableExport: true
      implementationStore: {}
      areaParams: {}

   getInitialState: ->
      activatedOperation: @_STANDARD_PANEL_OPERATIONS.none
      activatedActionIndex: 0
      objectReflections: @_readObjectReflections(@props.record.reflections, [])
      isMainAreaFullWindowed: false

   componentWillReceiveProps: (nextProps) ->
      record = @props.record
      nextRecord = nextProps.record
      currentRecordKey = record.key
      nextRecordKey = nextRecord.key

      # Если ключи записей отличаются - перечитываем параметры связок.
      if currentRecordKey isnt nextRecordKey

         @setState
            objectReflections: @_readObjectReflections(nextRecord.reflections, [])

   render: ->
      `(
         <ArbitraryArea {...this._getAreaParams()}
                        styleAddition={this.styles.mainArea}
                        captionParams={this._getCaptionParams()}
                        isTriggerOnSameTarget={false}
                        isForcedLeaveShown={this._isMainAreaHeld()}
                        content={this._getCardContent()}
                        onFullWindowedTrigger={this._onFullWindowedTriggerMainArea}
                        onFocus={this._onFocusMainArea}
                        onBlur={this._onBlurMainArea}
                        onShow={this.props.onShow}
                        onHide={this.props.onHide}
                     />
       )`

   ###*
   * Функция формирования содержимого карточки объекта.
   *
   * @return {React-element} - узел с содержимым.
   ###
   _getCardContent: ->
      commonContent = @_getCardCommonContent()
      customActions = @props.customActions

      cardContent =
         # Проверим содержатся ли в массиве пользовательских операций над объектом
         #  записи - будем формировать контейнер с вкладками.
         # Иначе вермен целевой узел с общей информацией.
         if customActions? and customActions.length
            @_getTaberWithCustomAndCommonContent(customActions, commonContent)
         else
            commonContent

      `(
         <div>
            {cardContent}
            {this._getOperationPanel()}
         </div>
       )`

   ###*
   * Функция формирования контейнера с таб-вкладками с основным содержимым карточки
   *  и содержимым пользовательских операций.
   *
   * @return {React-element} - узел с содержимым.
   ###
   _getTaberWithCustomAndCommonContent: (customActions, commonContent) ->
      instanceRecord = @props.record

      # Добавим первую вкладку с узлом, содержащюю общую информацию.
      tabCollection = [
         caption: @_COMMON_CONTENT_TAB_TITLE
         icon: @_COLLECTION_ICONS.list
         content: commonContent
      ]

      for _key, actionParams of customActions
         isHasManual = actionParams.isHasManual

         customComponentProps = {
            isUseImplementation: @props.isUseImplementation
            isMergeImplementation: @props.isMergeImplementation
            implementationStore: @props.implementationStore
         }
         customComponentProps[actionParams.keyProp] = @props.record.key

         customContentRender = actionParams.render

         customContent =
            if actionParams.content?
               React.cloneElement actionParams.content, customComponentProps
            else if customContentRender?
               customContentRender(instanceRecord, customComponentProps)

         tabCollection.push
            caption: actionParams.caption
            captionParams: @_getCaptionParamsForCustomAction(actionParams)
            icon: actionParams.icon
            content: customContent
            render: actionParams.render
            context: instanceRecord

      taberStyle = @computeStyles(
         @styles.taberStyle,
         @state.isMainAreaFullWindowed and @styles.mainTaberStretchOnParent
      )

      `(
         <Taber {...this._MAIN_TABER_PARAMS}
                isStretchContent={this.state.isMainAreaFullWindowed}
                tabCollection={tabCollection}
                styleAddition={{common: taberStyle}}
                onClickTab={this._onClickTabAction}
                activeIndex={0}
             />
       )`

   ###*
   * Функция получения параметров заголовка для вкладки пользовательских действий
   *  для контейнера со вкладками.
   *
   * @param {Object} actionParams - параметры пользовательского дейтсвия.
   * @return {Object}
   ###
   _getCaptionParamsForCustomAction: (actionParams) ->
      enableManual = @props.enableManual
      isActionHasManual = actionParams.isHasManual
      buttonScaffolds = @_FUNCTIONAL_BUTTON_SCAFFOLDS
      functionalButtons = []
      captionParams = {}

      if enableManual and isActionHasManual
         manualButtonParams = _.cloneDeep(buttonScaffolds.manual)
         manualButtonValue = manualButtonParams.value
         manualButtonValue.relatives = [actionParams.name]

         manualButtonParams.value = manualButtonValue
         manualButtonParams.onClick = @props.onClickOpenManual

         functionalButtons.push(manualButtonParams)

      unless _.isEmpty(functionalButtons)
         captionParams.functionalButtons = functionalButtons

      captionParams unless _.isEmpty(captionParams)

   ###*
   * Функция формирования произвольной области панели параметров формирования
   *  паспорта объекта.
   *
   * @return {React-element}
   ###
   _getOperationPanel: ->
      activatedOperation = @state.activatedOperation
      standardOperations = @_STANDARD_PANEL_OPERATIONS

      #return if activatedOperation is standardOperations.none

      switch activatedOperation
         when standardOperations.passport
            operationContent = @_getPassportConstructContent()
         else
            operationParams = @_getCustomOperationContent(activatedOperation)

            if operationParams?
               operationContent = operationParams.content
               operationCaption = operationParams.caption
               additionAreaParams = @_CUSTOM_OPERATION_ADDITION_AREA_PARAMS

               if operationCaption
                  additionAreaParams.captionParams =
                     text: operationCaption
                     styleAddition:
                        common: @styles.customOperationAreaHeaderAddition

               additionAreaParams.styleAddition = @styles.customOperationAreaAddition

      if operationContent?
         `(
             <ArbitraryArea target={this}
                            content={operationContent}
                            isForcedLeaveShown={this._isPanelAreaHeld()}
                            onBlur={this._onHideOperationPanel}
                            onHide={this._onHideOperationPanel}
                            {...this._OPERATION_AREA_PARAMS}
                            {...additionAreaParams}
                          />
          )`


   ###*
   * Функция формирования содержимого для пользовательской операцией над объектом.
   *
   * @param {String} operationName - наименование произвольной операции.
   * @return {Object} - параметры для операции. Вид:
   *         {React-element, undefined} content - содержимое операции.
   *         {String} caption                   - заголовок операции.
   ###
   _getCustomOperationContent: (operationName) ->
      customOperation = @_getCustomOperationByName operationName

      if customOperation?
         record = @props.record
         formParams = customOperation.formParams
         render = customOperation.render
         operationContent = null

         if render?
            operationContent = render(record)
         else if formParams?
            operationCaption = formParams.caption
            reflectionsChain = formParams.reflectionsChain
            operationContent =
               @_getDynamicFormForCustomOperation(reflectionsChain, operationCaption)

         if operationContent?
            content: operationContent
            caption: operationCaption

   ###*
   * Функция получения параметров произвольной операции по имени.
   *
   * @param {String} operationName - наименование произвольной операции.
   * @return {Object, undefined}
   ###
   _getCustomOperationByName: (operationName) ->
      objectReflectionKeys = @_OBJECT_REFLECTION_KEYS
      operationParams = @props.operationParams
      customOperations = operationParams.custom if operationParams?

      if customOperations?
         _.find(customOperations, [objectReflectionKeys.name, operationName])

   ###*
   * Функция формирования динамической формы для пользовательской операции над
   *  объектом.
   *
   * @param {Array} reflectionsChain - цепь связок по которой будут получены
   *                                   параметры для формирования формы.
   * @return {React-element}
   ###
   _getDynamicFormForCustomOperation: (reflectionsChain) ->
      target = @props.areaParams.target
      targetHandlers = @_TARGET_HANDLERS
      dynamicFormParams = @_DYNAMIC_FORM_PARAMS
      targetErrors = @_MESSAGES.errors.target
      getEntityParamsHandler = targetHandlers.getEntityParams
      getModelParamsHandler = targetHandlers.getModelParams

      if target? and _.has(target, getEntityParamsHandler)
         entityParams = target[getEntityParamsHandler](reflectionsChain)
      else
         log.warn(targetErrors.notContainGetEntityParamsHandler)

      if target? and _.has(target, getModelParamsHandler)
         modelParams = target[getModelParamsHandler](reflectionsChain)
      else
         log.warn(targetErrors.notContainGetModelParamsHandler)

      isHasEntityParams = entityParams? and !_.isEmpty entityParams
      isHasModelParams = modelParams? and !_.isEmpty modelParams

      if isHasEntityParams and isHasModelParams
         `(
            <div style={this.styles.operationDynamicFormContainer}>
               <DynamicForm presetParams={entityParams}
                            modelParams={modelParams}
                            rootIdentifier={this.props.record.key}
                            {...this.props.dataManipulationParams}
                            isUseImplementation={this.props.isUseImplementation}
                            isMergeImplementation={this.props.isMergeImplementation}
                            implementationStore={this.props.implementationStore}
                            {...dynamicFormParams}
                         />
            </div>
          )`

   ###*
   * Функция формирования параметров содержимого панели формирования паспорта
   *  объекта.
   *
   * @return {React-element}
   ###
   _getPassportConstructContent: ->
      objectReflections = @state.objectReflections
      passportElementParams = @_PASSPORT_ELEMENT_PARAMS
      objectCard = this
      styles = @styles
      passportReflectionItemElementStyle = styles.passportReflectionItemElement
      passportReflectionListItemStyle = styles.passprotReflectionsListItem

      ###*
      * Функция фомирования элемента списка селекторов связок, включаемых в
      *  паспорт объекта.
      *
      * @param {Object} params - параметры для формирования элемента списка. Вид:
      *     {String} name       - наименование селектора.
      *     {String} caption    - лейбл селектора (заголовок).
      *     {String} key        - ключ элемента (при формировании коллекции).
      *     {String} handler    - обработчик на изменение селектора
      *     {String} labelStyle - доп. стиль для лейбла селектора.
      *     {Boolean} isService - флаг сервисного селектора (не селектора связок).
      *     {Boolean} isChecked - флаг выбранности селектора.
      * @return {React-element}
      ###
      getListItemForList = ((params) ->
         name = params.name
         caption = params.caption
         key = params.key
         handler = params.handler
         labelStyle = params.labelStyle
         isService = params.isService
         isChecked = params.isChecked

         checkboxType = @_CHECKBOX_INPUT_TYPE
         checkedMarker = @_CHECKED_MARKER
         styles = @styles
         passportReflectionItemElementStyle = styles.passportReflectionItemElement
         passportReflectionListItemStyle = styles.passprotReflectionsListItem

         labelComputedStyle =
            objectCard.computeStyles passportReflectionItemElementStyle,
                                     labelStyle

         checkedValue = isChecked and checkedMarker

         `(
            <li key={key}
                style={passportReflectionListItemStyle} >
               <input type={checkboxType}
                      name={name}
                      style={passportReflectionItemElementStyle}
                      onChange={handler}
                      checked={checkedValue}
                    />
               <label htmlFor={name}
                      style={labelComputedStyle}>
                  {caption}
               </label>
            </li>
         )`
      ).bind(objectCard)

      reflectionFlags =
         objectReflections.map (reflection, idx) ->
            reflectionName = reflection.name
            isProhibited = reflection.isProhibited

            # Если со связкой не запрещена работа - обрабатываем её.
            unless isProhibited
               getListItemForList
                  name: reflectionName
                  caption: reflection.caption
                  isChecked: reflection.isChecked
                  handler: objectCard._onReflectionSelect
                  key: idx

      # Сформируем селектор всех связок, включаемых в паспорт, только если
      #  связок у объекта больше 1-й.
      selectAllFlag =
         if objectReflections.length > 1
            allSelectorParams = passportElementParams.allSelectorParams
            allSelectorParams =
               _.merge(
                  allSelectorParams,
                  handler: @_onAllReflectionsSelect
                  labelStyle: styles.passportAllReflectionsSelectorLabel
               )

            getListItemForList(allSelectorParams)

      `(
         <div style={styles.passportContainer}>
            <h3 style={styles.passportCaption}>
               {passportElementParams.caption}
            </h3>
            <fieldset style={styles.passportReflectionsSet}>
               <legend>{passportElementParams.reflections.legend}</legend>
               <ul style={styles.passportReflectionsList}>
                  {selectAllFlag}
                  {reflectionFlags}
               </ul>
            </fieldset>
            <Button {...passportElementParams.buttonCreate}
                    onClick={this._onClickPassportFileGet}
                  />
         </div>
      )`

   ###*
   * Функция получения вкладки общей информации карточки (основные данные + данные
   *  связок).
   *
   * @return {React-element} - содержимое контейнера с общей информацией по объекту.
   ###
   _getCardCommonContent: ->
      objectData = @_getObjectDataElements()
      collections = objectData.collections
      isDisplayReflections = @props.isDisplayReflections
      commonContent = objectData.mainOutput
      taberParams = @_DATA_TABER_PARAMS

      if isDisplayReflections and collections?
         collections.unshift
            caption: @_COMMON_SCATTED_TAB_TITLE
            icon: @_COLLECTION_ICONS.main
            content: commonContent

         taberStyle =
            @computeStyles @styles.taberStyle,
                           !@_isHasCustomActions() and @styles.taberAdditionMargin

         `(
            <Taber ref={this._REFS.dataTaber}
                   tabCollection={collections}
                   maxTabCountPerLine={this.props.maxDataTabCountPerLine}
                   styleAddition={
                     {
                        common: taberStyle,
                        content: this.styles.taberContent
                     }
                   }
                   {...taberParams} />
          )`
      else
         commonContent

   ###*
   * Функция получения простого отображения главных данных карточки.
   *
   * @param {Boolean} isHideFieldCaptions - флаг скрытия заголовков полей.
   * @return {React-element}
   ###
   _getSimpleMainOutput: (isHideFieldCaptions) ->
      trueFields = @props.record.fields
      processedFields = @props.processedFields
      iterateFields = processedFields || trueFields
      i = 0
      output = []

      for fieldName, fieldParams of iterateFields
         fieldCaption = fieldParams.caption
         trueFieldParams = trueFields[fieldName]

         params =
            key: i
            name: fieldName
            caption: fieldCaption
            value: trueFieldParams.value if trueFieldParams?
            fieldParams: trueFieldParams
            isHideCaption: isHideFieldCaptions

         output.push @_getSimpleFieldRow params
         i++

      `(
         <table style={this.styles.cardContent}
                cellPadding={this.styles.commonContentTableCellPadding}>
            <tbody>
               {output}
            </tbody>
         </table>
       )`

   ###*
   * Функция генерации строки с данными пол полю записи - заголовок - значение
   *
   * @param {Object} params - параметры для формирования простой строки по полю. Вид:
   *        {Number} key            - ключ строки.
   *        {String} name           - наименование поля
   *        {String} caption        - заголовок поля.
   *        {Boolean} isHideCaption - флаг скрытия заголовка.
   *        {String} value          - значение.
   *        {Object} fieldParams    - параметры поля.
   * @return {React-element}
   ###
   _getSimpleFieldRow: (params) ->
      key = params.key
      name = params.name
      caption = params.caption
      isHideCaption = params.isHideCaption
      value = params.value
      fieldParams = params.fieldParams
      target = @props.areaParams.target
      targetHandlers = @_TARGET_HANDLERS
      getValueHandler = targetHandlers.getValue
      isHiddenHandler = targetHandlers.isHidden

      # Если целевой узел имеет обработчик-предикат для определения является
      #  ли поле скрываемым - вызовем для получения флага скрыто ли поле.
      if _.has(target, isHiddenHandler)
         isFieldHidden = target[isHiddenHandler](name)

      return if isFieldHidden

      # Получаем выводимое значение:
      #  1. Если у целевого узла есть функция получения значения - из неё.
      #  2. Иначе - это массив или объект - переводим в строку через обработчик JSON.
      #  3. Иначе если заданы параметры поля - обрабатываем внутренним обработчиком
      #  4. Иначе просто выводим значение.
      valueContent =
         if _.has(target, getValueHandler)
            target[getValueHandler](name, fieldParams)
         else if _.isPlainObject(value) or _.isArray(value)
            JSON.stringify value
         else if fieldParams?
            @_getFieldValue(fieldParams)
         else
            value

      captionCell =
         unless isHideCaption
            `(<td style={this.styles.captionCell}>{caption}</td>)`

      `(
         <tr key={key}>
            {captionCell}
            <td style={this.styles.valueCell}>{valueContent}</td>
         </tr>
       )`

   ###*
   * Функция генерации содержимого для отображения полей записи.
   *
   * @return {Object} - хэш со строками по основным полям
   *                    и вкладками с коллекциями, если был задан
   *                    параметр разбиения по вкладкам. Вид:
   *        {Array} collections - коллекция элементов для отображения связанных
   *                              сущностей.
   *        {Object, Array} mainOutput - страница основного содержания объекта.
   ###
   _getObjectDataElements: ->
      formatRules = @props.formatRules
      contentRules = formatRules.content if formatRules?
      reflections = @props.record.reflections
      isDisplayReflections = @props.isDisplayReflections

      if contentRules?
         contentRender = contentRules.render
         isHideFieldCaptions = contentRules.isHideFieldCaptions

      # Если задана пользовательская функция рендера содержимого карточки -
      #  вызываем эту функцию с передачей ей записи по карточке и получаем
      #  главное содержимое данные карточки.
      # Иначе, строим обычный вывод в виде
      mainOutput =
         if contentRender?
            contentRender @props.record
         else
            @_getSimpleMainOutput(!!isHideFieldCaptions)

      if isDisplayReflections
         collections = @_fillReflectionCollections()

      collections: collections
      mainOutput: mainOutput

   ###*
   * Функция получения параметров для произвольной области. Смешивает параметры
   *  для области по-умолчанию с переданными через свойства карточки.
   *
   * @return {Object}
   ###
   _getAreaParams: ->
      _.merge @_DEFAULT_MAIN_AREA_PARAMS, @props.areaParams

   ###*
   * Функция получения заголовка карточки. Правила формирования заголовка берет
   *  из свойства formatRules, набор параметров для действий формирует на основе
   *  operationParams.
   *
   * @return {Object, undefined} - хэш с параметрами заголовка заголовок карточки.
   ###
   _getCaptionParams: ->
      formatRules = @props.formatRules
      operationParams = @props.operationParams
      caption = formatRules.caption if formatRules?
      customFunctionalButtons = @_customFunctionalButtonsForCaption()
      paramsForCaption = {}

      if caption?
         captionFields = caption.fields
         captionTemplate = caption.template
         captionIcon = caption.icon

         recordFields = @props.record.fields
         recordCaptionValues = []

         # Перебираем все поля, переданные для заголовка, получаем значения из записи
         #  и удаляем это поле из обрабатываемого набора значений.
         captionFields.map (value) ->
            recordValue = recordFields[value]
            recordCaptionValues.push recordValue.value
           # delete processedValues[value]

         # @setState processedValue: processedValues

         paramsForCaption.text = format captionTemplate, recordCaptionValues
         paramsForCaption.icon = captionIcon

      if customFunctionalButtons?
         paramsForCaption.customFunctionalButtons = customFunctionalButtons

      if operationParams?
         isUseStandard = operationParams.isUseStandard
         customActions = operationParams.custom
         customActionsForCaption = []

         if isUseStandard
            customActionsForCaption = @_getStandardObjectOperations()

         if customActions? and !_.isEmpty customActions
            for customAction in customActions

               customActionsForCaption.push
                  value: customAction.name
                  title: customAction.title
                  icon: customAction.icon
                  onClick: @_onClickCustomOperation
            # customActionsForCaption =
            #    _.concat customActionsForCaption, customActions

         unless _.isEmpty customActionsForCaption
            customActions =
               customActionsForCaption.map ((operationParams) ->
                  operationParams.className = @_OPERATION_BUTTON_CLASS_NAME
                  operationParams
               ).bind(this)

            paramsForCaption.customActions = customActions

      paramsForCaption

   ###*
   * Функция формирования набора кнопок пользовательских функциональных действий
   *  для произвольной области (выводимых в заголовке).
   *
   * @return {Array<Object>}
   ###
   _customFunctionalButtonsForCaption: ->
      enableManual = @props.enableManual
      onClickOpenManualHandler = @props.onClickOpenManual
      functionalButtonScaffolds = @_FUNCTIONAL_BUTTON_SCAFFOLDS
      functionalButtons = []

      # Добавляем кнопку открытия мануалов, если разрешена работа с руководствами и
      #  задан обработчик клика на открытие руководства.
      if enableManual and onClickOpenManualHandler?
         manualButtonParams = functionalButtonScaffolds.manual
         manualButtonParams.onClick = onClickOpenManualHandler

         functionalButtons.push manualButtonParams

      functionalButtons unless _.isEmpty(functionalButtons)

   ###*
   * Функция формирования стадартных параметров для операций над объектом.
   *
   * @return {Array<Object>}
   ###
   _getStandardObjectOperations: ->
      standardOperationsScaffold = @_STANDARD_OPERATIONS_SCAFFOLD
      record = @props.record
      standardOperations = []

      if @props.enableDelete
         standardDelete = standardOperationsScaffold.delete
         standardDelete.styleAddition = @styles.deleteButton
         standardDelete.onClick = @_onClickObjectDelete
         standardOperations.push standardDelete

      if @props.enableEdit
         standardEdit = standardOperationsScaffold.edit
         standardEdit.onClick = @_onClickObjectEdit
         standardOperations.push standardEdit

      if @props.enableExport
         standardPassport = standardOperationsScaffold.passport
         standardPassport.value = record
         standardPassport.onClick = @_onClickPassportConstruct
         standardOperations.push standardPassport

      standardOperations

   ###*
   * Функция получения значения поля записи. В зависимости от типа поля форматирует
   *  значение (для даты). Если нет значения - возвращает "-"
   *
   * @param {Object} fieldParam - параметры поля
   * @return {String} - значение поля.
   ###
   _getFieldValue: (fieldParam)->
      value = fieldParam.value
      type = fieldParam.type
      dataTypes = @_DATA_TYPES
      dateType = dataTypes.date
      dateTimeType = dataTypes.datetime

      if value? and type in [dateType, dateTimeType]
         dateValue = new Date(value)

         if type is dateType
            dateValue.toLocaleDateString()
         else
            dateValue.toLocaleString()
      else unless value
         '-'
      else
         value

   ###*
   * Функция установки активированной операции. Если устанавливаемая операция
   *  уже установлена, то функция устанавливает текущую активированную операцию
   *  в none.
   *
   * @param {String} operationName - наименование операции.
   * @return
   ###
   _setActivatedOperation: (operationName) ->
      standardOperations = @_STANDARD_PANEL_OPERATIONS
      activatedOperation = @state.activatedOperation
      preparedState = {}

      if activatedOperation isnt operationName
         preparedState.activatedOperation = operationName
      else
         preparedState.activatedOperation = standardOperations.none

      @setState preparedState unless _.isEmpty preparedState

   ###*
   * Функция-предикат для определения необходимо ли принудительно "удерживать"
   *  область карточки от скрытия на потерю фокуса.
   *
   * @return {Boolean}
   ###
   _isMainAreaHeld: ->
      @props.isFreezeAtInteraction and (@state.activatedActionIndex isnt 0)

   ###*
   * Функция-предикат для определения необходимо ли принудительно "удерживать"
   *  панель операций от скрытия на потерю фокуса.
   *
   * @return {Boolean}
   ###
   _isPanelAreaHeld: ->
      @state.activatedOperation isnt @_STANDARD_PANEL_OPERATIONS.none

   ###*
   * Функция-предикат для проверки наличия в карточке параметров
   *  произвольных действий над объектом.
   *
   * @return {Boolean}
   ###
   _isHasCustomActions: ->
      customActions = @props.customActions

      customActions? and !_.isEmpty customActions

   ###*
   * Обработчик переключения полноэкренного режима главной области.
   *
   * @param {Boolean} isFullWindowed - флаг развернутости на все окно.
   * @return
   ###
   _onFullWindowedTriggerMainArea: (isFullWindowed) ->
      @setState isMainAreaFullWindowed: isFullWindowed

   ###*
   * Обработчик события на получение фокуса главной областью карточки. Проверяет
   *  текущую операцию и если она не пустая (none), то сбрасывает операцию, для
   *  того чтобы область операции скрылась.
   *
   * @param {DOM-node} target - целевой узел, на который перешел фокус.
   * @param {Event-object} event - объект события.
   * @return
   ###
   _onFocusMainArea: (target, event) ->
      noneStandardOperation =  @_STANDARD_PANEL_OPERATIONS.none

      if @state.activatedOperation isnt noneStandardOperation
         @setState activatedOperation: noneStandardOperation

   ###*
   * Обработчик события на потерю фокуса главной областью карточки. Сбрасывает
   *  все флаги.
   *
   * @param {React-element} relatedTarget - целевой узел, на который перешел фокус.
   * @param {Event-object} event - объект события.
   * @return
   ###
   _onBlurMainArea: (relatedTarget, event) ->
     # @setState flags: @_getInitFlags()

   ###*
   * Обработчик клика .
   *
   * @param {Number} tabIndex  - индекс влакди по которой был произведен клик.
   * @param {Object} tabParams - параметры вкладки.
   * @return
   ###
   _onClickTabAction: (tabIndex, tabParams) ->
      @setState activatedActionIndex: tabIndex

   ###*
   * Обработчик клика на кнопку операции редактирования объекта. Если задан
   *  обработчик редактирования записи у целевого узла, то вызываем его, иначе
   *  выдаем предупреждение в консоль.
   *
   * @return
   ###
   _onClickObjectEdit:  ->
      targetHandlers = @_TARGET_HANDLERS
      editRecordHandler = targetHandlers.editRecord
      target = @props.areaParams.target

      if target? and _.has target, editRecordHandler
         target[editRecordHandler]()
      else
         log.warn(@_MESSAGES.errors.target.notContainEditHandler)

   ###*
   * Обработчик клика на кнопку операции удаления объекта. Если задан
   *  обработчик редактирования записи у целевого узла, то вызываем его, иначе
   *  выдаем предупреждение в консоль.
   *
   * @return
   ###
   _onClickObjectDelete: ->
      targetHandlers = @_TARGET_HANDLERS
      deleteRecordHandler = targetHandlers.deleteRecord
      target = @props.areaParams.target

      if target? and _.has target, deleteRecordHandler
         target[deleteRecordHandler]()
      else
         log.warn(@_MESSAGES.errors.target.notContainDeleteHandler)


   ###*
   * Обработчик клика на кнопку операции формирования паспорта. Устанавливает
   *  флаг показанности панели формирования паспорта объекта, устанавливает
   *  флаг принудительного удержания основной области карточки объекта.
   *
   * @param {Object} value       - значение.
   * @param (Event-object) event - объект события.
   * @return
   ###
   _onClickPassportConstruct: (value, event) ->
      @_setActivatedOperation(@_STANDARD_PANEL_OPERATIONS.passport)

   ###*
   * Обработчик клика на кнопке пользовательской операции над объектом.
   *  Устанавливает в состояние текущую операцию над записью.
   *
   * @param {String} operationName - наименование пользовательской операции.
   * @return
   ###
   _onClickCustomOperation: (operationName) ->
      customOperation = @_getCustomOperationByName operationName

      # Если для произвольной операции задан обработчик - вызовем его, передав
      #  запись карточки
      if customOperation?
         handler = customOperation.handler

         if handler?
            handler(@props.record)

      @_setActivatedOperation(operationName)

   ###*
   * Обработчик клика на кнопку сохранения паспорта объекта.
   *
   * @return
   ###
   _onClickPassportFileGet: ->
      targetHandlers = @_TARGET_HANDLERS
      getInstanceFileHandler = targetHandlers.getInstanceFile
      target = @props.areaParams.target

      if target? and _.has target, getInstanceFileHandler
         objectReflections = @state.objectReflections
         objectReflectionKeys = @_OBJECT_REFLECTION_KEYS
         checkedReflections = []

         for reflection in objectReflections
            if reflection.isChecked
               checkedReflections.push(
                  name: reflection.name
                  parents: reflection.parents
               )

         target[getInstanceFileHandler](checkedReflections)
      else
         log.warn(@_MESSAGES.errors.target.notContainGetInstanceHandler)

   ###*
   * Обработчик изменения флага выбранности связки в панели формирования паспорта.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onReflectionSelect: (event) ->
      target = event.target
      targetName = target.name
      targetChecked = target.checked
      objectReflections = @state.objectReflections
      objectReflectionKeys = @_OBJECT_REFLECTION_KEYS
      findexIndex = _.findIndex(
         objectReflections,
         [objectReflectionKeys.name, targetName]
      )
      isReflectionSelect = objectReflections[findexIndex].isChecked
      objectReflections[findexIndex].isChecked = targetChecked

      @setState
         objectReflections: objectReflections
         #isAreaForcedShown: true

   ###*
   * Обработчик на скрытие панели формирования паспорта. Сбрасывает флаг
   *  показанности панели, устанавливает флаг принудительного удержания
   *  основной области карточки объекта.
   *
   * @return
   ###
   _onHideOperationPanel: ->
      @setState
         activatedOperation: @_STANDARD_PANEL_OPERATIONS.none
        # isAreaForcedShown: true

   ###*
   * Обработчик на изменения селектора всех связок в панели формирования паспорта
   *  объекта.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onAllReflectionsSelect: (event) ->
      target = event.target
      targetChecked = target.checked
      objectReflections = @state.objectReflections[..]
      processedReflections =
         objectReflections.map (reflection) ->
            reflection.isChecked = targetChecked
            reflection

      @setState
         objectReflections: processedReflections
         #isAreaForcedShown: true

   ###*
   * Функция заполнения массива связок записи. Вызывается рекурсивно для связок
   *  связок.
   *
   * @param {Object} reflections      - параметры связок.
   * @param {Array} objectReflections - выходной массив коллекций элементов.
   * @param {Array} parents           - коллекция родительских связок.
   * @param {String} parentName       - имя родительской связки
   * @return {Array}
   ###
   _readObjectReflections: (reflections, objectReflections, parents, parentName) ->
      if reflections? and !_.isEmpty reflections
         objectReflectionKeys = @_OBJECT_REFLECTION_KEYS
         nameKey = objectReflectionKeys.name
         isDamnedKey = objectReflectionKeys.isDamned
         formatRules = @props.formatRules
         reflectionRules = formatRules.reflections if formatRules?
         orderedReflections = @_orderReflections(reflections, formatRules)

         for reflectionParams in orderedReflections
            reflName = reflectionParams.name
            reflection = reflectionParams.reflection
            reflectionValue = reflection.value
            reflectionRule = reflectionRules[reflName] if reflectionRules?
            currentParentIdx = _.findIndex(parents, [nameKey, parentName])
            isHidden = false
            isProhibited = false
            isDamned = false
            isUseParentResource = false

            # Считываем параметры скрытости, запрещенности и "проклятости"
            #  cвязки, заданных через параметры.
            if reflectionRule?
               isHidden = reflectionRule.isHidden
               isProhibited = reflectionRule.isProhibited
               isDamned = reflectionRule.isDamned
               isUseParentResource = reflectionRule.isUseParentResource

            # Если задана родительская связка и она присутсвует в наборе
            #  продительских - сократим массив родительских связок до этой связки.
            if parentName? and ~currentParentIdx
               parents = parents[0..currentParentIdx]
            else
               parents = []

            # Если для связки не был задан флаг запрещенности, проверим не был ли
            #  задан флаг "проклятости" в какой либо родительской связке. Если
            #  такой флаг был задан - установим флаг запрещенности для текущей связки.
            unless isProhibited
               isProhibited = _.find(parents, isDamnedKey)

            # Если значение связки - простой объект (не массив) - считываем связки
            #  текущей связки.
            reflectionReflections =
               if _.isPlainObject reflectionValue
                  reflectionValue.reflections

            # Определим выводимый заголовок - если переопределяемый заголовок
            #  задан через правила формирования связки - выводим его,
            #  иначе - заголовок определенный в параметрах самой связки.
            reflectionCaption =
               if reflectionRule? and reflectionRule.redefinedCaption?
                  reflectionRule.redefinedCaption
               else
                  reflection.caption

            # Сформируем параметры связки и сохраним в набор связок.
            reflectionParams =
               value: reflectionValue
               name: reflName
               caption: reflectionCaption
               parents: _.cloneDeep(parents) unless _.isEmpty(parents)
               isSelf: reflection.isSelf
               isHidden: isHidden
               isProhibited: isProhibited
               isUseParentResource: isUseParentResource
               isChecked: !isHidden
               reflectionRule: reflectionRule
            objectReflections.push reflectionParams

            # Если для текущей связки заданы ещё дополнительные связки - запустим
            #  функцию рекурсивно.
            if reflectionReflections?
               # Если набор родительских связок ещё не был определен - зададим
               #  пустой массив.
               if !parents? or _.isEmpty parents
                  parents = []

               # Добавим текущую связку в набор родительских.
               parents.push
                  name: reflName
                  caption: reflectionCaption
                  isSelf: reflection.isSelf
                  isDamned: isDamned
                  key: reflectionValue.key

               @_readObjectReflections(reflectionReflections,
                                       objectReflections,
                                       parents,
                                       reflName)
      objectReflections

   ###*
   * Функция упорядочивания коллекции связок для вывода в необходимом порядке в
   *  навигаторе с табами. Если заданы параметры упорядочивания в параметрах форматирования
   *  выбирает по нужному порядку(заданные), а затем в порядке, определяемым клиентом
   *  добавляет в коллекцию остальные.
   *
   * @param {Object} reflections - коллекция связок.
   * @param {Object} formatRules - правила форматирования.
   * @return {Array}
   ###
   _orderReflections: (reflections, formatRules) ->
      clonedReflections = _.cloneDeep(reflections)
      reflectionsOrder = formatRules.reflectionsOrder if formatRules?
      orderedReflections = []

      if reflectionsOrder? and !_.isEmpty reflectionsOrder
         for reflName in reflectionsOrder
            reflection = clonedReflections[reflName]

            if reflection?
               orderedReflections.push(
                  name: reflName
                  reflection: reflection
               )

               delete clonedReflections[reflName]

      if !_.isEmpty clonedReflections
         for reflName, reflection of clonedReflections
            orderedReflections.push(
               name: reflName,
               reflection: reflection
            )

      orderedReflections

   ###*
   * Функция заполнения массива элементов для отображения коллекций
   *  для связанных сущностей.
   *
   * @return
   ###
   _fillReflectionCollections: ->
      reflections = @state.objectReflections
      charArrowForward = @_CHARS.arrowForward
      collections = []

      for reflection in reflections
         reflectionParents = reflection.parents
         tabSubCaption = null
         redefinedInstanceKey = null

         if reflectionParents and !_.isEmpty reflectionParents
            tabSubCaption =
               reflectionParents.map((parent) ->
                  parent.caption
               ).join charArrowForward

            lastSelfRelation = _.findLast(reflectionParents, 'isSelf')

            if lastSelfRelation? and !_.isEmpty lastSelfRelation
               redefinedInstanceKey = lastSelfRelation.key


         @_putCollectionInTabCollection(
            reflection:
               params: reflection.value
               redefinedInstanceKey: redefinedInstanceKey
               isSelf: reflection.isSelf
               name: reflection.name
               reflectionRule: reflection.reflectionRule
               isHidden: reflection.isHidden
               isProhibited: reflection.isProhibited
               isUseParentResource: reflection.isUseParentResource
            caption: reflection.caption
            subCaption: tabSubCaption
            collections: collections
         )

      collections

   ###*
   * Функция помещения записи или записей коллекции в массив вкладок для контейнера со
   *  вкладками. Не выполняет обработку, если для связки задан флаг скрытия (isHidden)
   *  или запрещения работы (isProhibited).
   *
   * @param {Object} params - параметры для функции. Вид:
   *        {Object} reflection    - параметры связки.
   *        {String} caption    - заголовок вкладки.
   *        {String} subCaption - подзаголовок вкладки.
   *        {Array} collections    - массив с вкладками для контейнера со вкладками
   *                                 (функция работает с этим массивом).
   * @return
   ###
   _putCollectionInTabCollection: (params)->
      reflection = params.reflection
      tabCaption = params.caption
      tabSubCaption = params.subCaption
      collections = params.collections

      #isCollectionHasManyInstances = reflection.length > 1
      # Не обрабатываем данную связку, если она запрещена.
      return if reflection.isHidden or reflection.isProhibited

      collectionIcons = @_COLLECTION_ICONS
      dataTableParams = @_DATA_TABLE_PARAMS
      reflectionRuleKeys = @_REFLECTION_RULE_KEYS
      iconKey = reflectionRuleKeys.icon
      relationsKey = reflectionRuleKeys.relations
      relationAlternativesKey = reflectionRuleKeys.relationAlternatives
      reflectionName = reflection.name
      reflectionRule = reflection.reflectionRule
      isSelfRelation = reflection.isSelf
      record = @props.record
      instanceKey = reflection.redefinedInstanceKey or record.key
      reflections = record.reflections
      isUseImplementation = @props.isUseImplementation

      collectionIcon = if reflectionRule? and _.has(reflectionRule, iconKey)
                          reflectionRule[iconKey]
                       else
                          collectionIcons.many

      reflectionDataTableSpecific = reflectionRule.dataTableParams

      # Если это самосвязывание, то создадим параметры фильтра для таблицы для
      #  выбора только объекта самосвязи.
      # Иначе определим набор связок для получения целевых данных.
      if isSelfRelation
         reflectionKey = reflection.params.key
         filterParams = _.cloneDeep(@_SELF_RELATION_FILTER_SCAFFOLD)
         filterParams.filter.terms[0].expr = reflectionKey
      else
         collectionRelations =
            # Если параметры заданы в правилах формирования - возьмем
            #  их оттуда, иначе - формируем стандратные (которые много где не заработают).
            if reflectionRule?
               if _.has(reflectionRule, relationsKey)
                  reflectionRule[relationsKey]
               else if _.has(reflectionRule, relationAlternativesKey)
                  relationAlternatives = reflectionRule[relationAlternativesKey]
                  findedAlt = null

                  for relAlt in relationAlternatives
                     altName = relAlt.name

                     if _.has(reflections, altName)
                        findedAlt = relAlt.relations
                        break

                  findedAlt

      resourceModelName =
         if reflectionRule? and reflectionRule.isUseParentResource
            @props.parentModelParams.name
         else
            _.snakeCase(_.lowerCase(record.model))

      unless collectionRelations?
         defReflParams = _.cloneDeep(@_DEFAULT_REFLECTION_SCAFFOLD)
         defReflParams[0].reflection = reflectionName
         collectionRelations = defReflParams

      DataTable = require('components/core/data_table')

      modelParams =
         name: resourceModelName
         relations: collectionRelations

      collectionContent =
         `(
            <DataTable modelParams={modelParams}
                       {...dataTableParams}
                       filterParams={filterParams}
                       instanceID={instanceKey}
                       isUseImplementation={isUseImplementation}
                       isImplementationHigherPriority={isUseImplementation}
                       implementationStore={this.props.implementationStore}
                       {...reflectionDataTableSpecific}
                     />
         )`

      if collectionContent?

         collections.push(
            caption: tabCaption
            subCaption: tabSubCaption
            content: collectionContent
            icon: collectionIcon
         )




module.exports = ObjectCard
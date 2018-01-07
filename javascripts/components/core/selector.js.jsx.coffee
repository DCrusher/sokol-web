###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin           - общие стили для компонентов.
* HelpersMixin          - функции-хэлперы для компонентов.
* AnimationsMixin       - набор анимаций для компонентов.
* AnimateMixin          - библиотека добавляющая компонентам
*                         возможность исользования анимации.
* ImplementedPropReader - модуль добавляющий функционал корректного считывания
*                         реализуемых свойств (через хранилище реализаций).
* ServiceStore          - flux-хранилище состояний сервисной части.
* ServiceActionCreators - модуль создания клиентских административных действий.
* ServiceFluxConstants  - flux-константы административной части.
* string-template       - модуль для формирования строк из шаблонов.
* keymirror             - модуль для генерации "зеркального" хэша.
* loglevel              - модуль для вывода формитированных логов в отладчик.
* lodash                - модуль служебных операций.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
AnimationsMixin = require('../mixins/animations')
AnimateMixin = require('react-animate')
ImplementedPropReader = require('../mixins/implemented_prop_reader')
ServiceStore = require('stores/service_store')
ServiceActionCreators = require('actions/service_action_creators')
ServiceFluxConstants = require('constants/service_flux_constants')
format = require('string-template')
keyMirror = require('keymirror')
log = require('loglevel')
_ = require('lodash')

# {Object} - типы событий в сервисном хранилище
ActionTypes = ServiceFluxConstants.ActionTypes

###* Зависимости: компоненты
* Input         - поле ввода.
* Button        - кнопка.
* ArbitraryArea - произвольная область.
* DataTable     - таблица данных. (Загрузка модуля идет по месту, т.к.
*                 вызывает ошибку цикличной загрузки компонентов)
###
Input = require('components/core/input')
Button = require('components/core/button')
ArbitraryArea = require('components/core/arbitrary_area')
#DataTable = require('components/core/data_table')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COMMON_PADDING = constants.commonPadding
_COLORS = constants.color

###* Компонент: компонент выбора значений.
*
* @props:
*     {String} name                  - имя поля (для форм).
*     {String} identifyingName       - идентифицирующее поле (для определения
*                                      стандартных реализаций).
*     {String} caption               - заголовок поля (для отображения в заголовке
*                                      справочника, всплывающем пояснении).
*     {String} placeholder           - строка-заполнитель для приглашения ввода.
*     {Boolean} enableMultipleSelect - флаг множественного выбора. (по-умолчанию = false).
*     {Boolean} enableAddingSelectedItemsToFilter - флаг добавления идентификаторов выбранных
*                                                   записей в фильтр. (по-умолчанию = false).
*    {Boolean} enableConsistentClear - флаг включения режима последовательного удаления.
*                                      Если флаг активен удалять выбранные элементы можно либо все сразу,
*                                      либо всего только последний.
*                                      (по-умолчанию = false).
*     {Boolean} enableTotalClear     - флаг включения кнопки общей очистки поля (удаляет все выбранные
*                                      элементы). (по-умолчанию = true)
*     {Boolean} isReinit             - флаг возврата к изначально выбранной записи. (по-умолчанию = false)
*     {Boolean} isReadOnly           - флаг поля только для чтения (редактирование не доступно).
*                                      (по-умолчанию = false).
*     {Boolean} isAdaptive           - флаг адаптивности (для произвольных областей компонента).
*                                      (по-умолчанию = false).
*     {Boolean} isUseImplementation  - флаг использования стандартных параметров селектора из
*                                      внешнего общего модуля, представляющего из себя объект,
*                                      разделенный на разделы по идентифицирующему имени
*                                      (@props.identifyingName). Для работы с данным
*                                      флагом компоненту также должен быть задан параметр
*                                      @props.implementationStore - задающий объект в котором
*                                      находятся стандарнтные параметры представления.
*                                      (по-умолчанию = false).
*     {Boolean} isImplementationHigherPriority - флаг более приоритетных свойств из хранилища реализаций.
*                                               Нужен для переопределения свойств, заданных по-умолчанию.
*                                               (по-умолчанию = false).
*     {Boolean} isMergeImplementation - флаг "слияния" свойств компонента со свойствами, заданными в
*                                       хранилище реализаций. (по-умолчанию = false)
*     {Number} tabIndex              - индекс таба для задания последовательности перехода
*                                      по клавише "Tab"
*     {Array<Object>} presetRecords  - массив изначально выбранных записей. Ожидаются
*                                      записи в формате компонента DataTable.
*     {Object} implementationStore  - объект источников стандартной реализации для компонента.
*                                     Если данный параметр задан и установлен флаг @props.isUseImplementation,
*                                     то для компонента будут применены стандартные параметры представления,
*                                     если они будут найдены в заданном источнике. Если вместе с данным
*                                     параметром были заданы пользовательские параметры, определенные в источнике
*                                     стандартной реализации, то стандартные будут переопределены
*                                     пользовательскими.
*     {Object} recordsDosage         - параметры "дозировки" записей на одну страницу
*                                      словаря. Вид:
*           {Number} dictionary      - кол-во записей на страницу для обычного
*                                      словаря-автодополнения.
*           {Number} browser         - кол-во записей на страницу для словаря в
*                                      режиме "обозревателя".
*     {Object} dictionaryBrowserParams - параметры работы словаря в режиме "обозревателя"
*                                        (работа со словарем в боковой панели окна).
*                                        При задании данного параметра появляется возможность
*                                        работы со словарем в режиме "обозревателя".
*                                        Вид:
*           {Object} openButton  - параметры кнопки открытия словаря в режиме "обозревателя".
*                                  Вид:
*                 {String, Object} caption - надпись на кнопке открытия справочника или
*                                  параметры заголовка кнопки открытия в различных режимах.
*                                  Вид:
*                          {String} empty    - заголовок при отсутствии выбранных записей.
*                          {String} selected - заголовок при наличии выбранных записей.
*                 {String} position - позиция кнопки открытия справочника. Варианты:
*                          'top' - сверху.
*                          'leftIn' - слева в поле ввода.
*     {Object} dataSource            - хэш параметров для запроса данных. Вид:
*              {Object} dictionary - хэш параметров запроса справочника. Вид:
*                       {String} url       - адрес для запроса справочника.
*                       {Object} filter    - хэш параметров фильтрации. Вид:
*                             {Object} filter - параметры фильтрации для выборки значений словаря
*                                               (задаются, аналогично параметрам таблицы).
*                             {Object} search - парметры поисвокой фильтрации. Если не заданы, задаются
*                                               по-умолчанию ({all: exp: '...', match: 'like'}). Вид:
*                                      {String} field - имя поля по которому отправляется поисковый запрос
*                                                       (по всем полям ключ - 'all').
*                                      {String} condition - тип соответсвия (поиск подстроки - 'like').
*                       {String, Array<Object>} resultKey - ключ для считывания ответа (т.е. ключ хэша который нужно
*                                            взять от ответа).
*                                                      Ключ можно задать в "составном" виде, если предполагается
*                                                      считывание "разнородных" данных в виде массива (для задания
*                                                      порядка вывода разных справочников данных). Вид элемента:
*                                                      {String} key - ключ считывания результата.
*                                                      {String} caption - заголовок, выводимый в селекторе выбора данных.
*                                                      {String} alternativeFieldName - альтернативное имя поля для
*                                                                                      определенного набора.
*              {Object} instances  - хэш параметров запроса экземпляров. Вид:
*                       {String} url                 - адрес для запроса выбранных параметров
*                                                      выбранных экземпляров(экземпляра).
*                       {String, Number, Array} keys - идентификаторы выбранных экземпляров.
*                       {String} resultKey - ключ для считывания ответа (т.е. ключ хэша который нужно
*                                                      взять от ответа).
*              {Object} additional - хэш дополнительных параметров источников данных. Вид:
*                       {Object} directRequest - хэш параметров "прямого" запроса (без
*                                                использования справочника). Вид:
*                             {String} url     - адрес для прямого запроса.
*                             {Object} filter  - хэш параметров запроса(аналогично справочнику).
*                       {Object} firstChoiceRequest - хэш параметров "запроса после выбора первого"
*                                                (Запрос отправляется после выбора первого элемента). Вид:
*                             {String} url     - адрес для запроса.
*                             {Object} filter  - хэш параметров запроса(аналогично справочнику).
*     {Object} renderParams - хэш параметров рендера селектора. Вид:
*              {Object} input: - хэш параметров размеров для поля ввода:
*                      {Object} dimension: - параметры размеров:
*                              {Object} width - ширина. Вид:
*                                        {Number} min - минимальная ширина. Если не задана, берется по-умолчанию.
*                                        {Number} max - максимальная ширина. Если не задана не ограничивается.
*              {Object} itemsContainer - хэш параметров для контейнера элементов. Вид:
*                      {Boolean} isInSingleLine - флаг расположения выбранных элементов в одну линию.
*                      {Object} dimension: - параметры размеров:
*                              {Object} width - ширина. Вид:
*                                        {Number} max - максимальная ширина. Если не задана не ограничивается.
*              {Object} instance: - хэш параметров рендера выбранного значения в поле селектора. Вид:
*                       {Function} onRender - функция для рендера выбранного значения. Агрумент функции
*                                             - выбранная запись.
*                       {String} template - строка шаблон для формирования вывода выбранного элемента.
*                                           Например, "{0} ({1})".
*                       {Array} fields - массив полей, значения которых подставляются в строку-
*                                        шаблон для вывода. Например, ['name', 'key'] (где
*                                        строка 'key'- означает ключ записи).
*                        Данный параметр может быть задан в виде вложенного хэша для обработки выбора
*                        значений при "составных" данных в справочнике. Вид:
*                          [fieldName] (имя совпадает с параметром "key" из параметров считывания данных
*                                       источника данных словаря по ключу - "resultKey")
*                                {String} template - аналогично обычному рендеру.
*                                {Array} fields - аналогично обычному рендеру.
*                        {Array<Object>} arbitrary - массив цепей произвольного выбора членов
*                                                    из параметров записи. Данный параметр будет использоваться
*                                                    если не задан параметр fields. Формат аналогичен
*                                                    параметры columnRenderParams.cells.format.arbitrary
*                                                    компонента DataTable.
*               {Object} dimension - хэш параметров размера.
*               {Object} dictionary - хэш параметров рендера словаря поля выборки. Вид:
*                        {String} tableViewType - тип таблицы (плоская таблица или иерархия).
*                        {Object} dimension - хэш параметров размера таблицы справочника. Вид:
*                                {Object} width - ширина. Вид:
*                                         {Number} max - максимальная ширина. Если не задана -
*                                                        берется по-умолчанию.
*                                         {Number} min - минимальная ширина.
*                                {Object} height - высота. Вид:
*                                         {Number} max - максимальная высота. Если не задана -
*                                                        берется по-умолчанию.
*                                         {Number} min - минимальная высота.
*                        {Object} columnRenderParams - хэш параметров рендера колонок. Параметр
*                                                      аналогичен параметру компонента DataTable.
*              {Object} browserSpecific - хэш параметров для словаря, специфичных в режиме "браузера".
*                                        Могут быть заданы любые переопределяющие параметры,
*                                        аналогичные renderParams.dictionary. Т.е. для таблицы-словаря,
*                                        открытой в режиме "браузера", применяются обычные параметры
*                                        renderParams.dictionary с дополнениями/переопределениями через
*                                        данный параметр.
*     {Object} additionFilterParams - дополнительные параметры фильтрации. Члены:
*                   {Boolean} isAddingSelectedItems  - флаг добавления ключей выбранных элементов в фильтр.
*                                                     (по умолчанию не задан, значит =false).
*                   {Boolean} isAddingSelectedItemsOnlyRoot - флаг добавления ключа только корневого узла.
*                                                            параметр работает только в связке с параметром
*                                                            isAddingSelectedItems (по умолчанию не задан, значит =false).
*     {Object} dataTableParams      - дополнительные параметры для таблицы данных - справочника. Вид:
*                   {Object} modelParams - параметры модели.
*                   {Object} hierarchyViewParams - параметры иерархического отображения.
*     {Function} onChange           - обработчик на изменение значений в комопненте. Аргументы:
*                                      {Array} selectedRecords - выбранные записи.
*                                      {Boolean} isInitSet     - флаг инициализационной установки
*                                                                значения.
*
* @state
*     {React-Element} collectionTarget - целевой узел для произвольной области со справочником.
*     {React-Element} allSelectedElementsTarget - целевой узел для области отображения всех выбранных
*                                                  элементов.
*     {Array} selectedRecords           - массив выбранных записей.
*     {String} selectorInput            - значение в поле ввода.
*     {Object} initRecords              - изначально выбранная запись(записи).
*     {String, Number} dictionaryActivatedRowKey - ключ записи текущей активированной строки в словаре.
*                                                  Параметр нужен для остлеживания по выбираемым строкам
*                                                  словаря.
*     {Boolean} isInInput               - флаг нахождения в поле ввода.
*     {Boolean} isDictionaryShown       - флаг показанного словаря(автодополнения).
*   {Boolean} isDictionaryInBrowserMode - флаг показа словаря в режиме браузера (отдельное
*                                         окно с полноценной фильтрацией). Изначально = false
*     {Boolean} isContainerScrolled     - флаг того что контейнер выбранных элементов (с полем)
*                                         ввода был прокручен. Параметр используется для однострочных
*                                         селекторов для определения необходимости создания элементов
*                                         для отображения выбранных записей (параметр актуален, если задано
*                                         ограничение по ширине контейнера выбранных записей)
*                                         Изначально = false.
*     {Boolean} isInstancesRequesting   - флаг "запрошены экземпляры" (для показа загрузчика в поле)
*                                         Изначально = false.
*     {Boolean} isParentInstancesRequest- флаг "запрошены родительские экземпляры" (для добавления вновь
*                                         полученных экземпляров в начало набора выбранных записей).
*                                         Изначально = false.
###
Selector = React.createClass
   # @const {Object} - хэш параметров размерности поля по-умолчанию.
   _DEFAULT_DIMENSION:
      input:
         width:
            min: 150
            max: 250
      autoComplete:
         width:
            max: 550
         height:
            max: 250

   # @const {Object} - наименования элементов компонента.
   _SELECTOR_ELEMENTS: keyMirror(
      input: null
      dictionary: null
      instances: null
      itemsContainer: null
   )

   # @const {Object} - параметры фильтрации по-умолчанию.
   _DEFAULT_FILTER_SEARCH_FIELDS:
      fields:
         [
            names: 'all'
         ]

   # @const {Object} - набор сообщений.
   _MESSAGES:
      errors:
         dataSourceNotSet: [
               'Для компонента селектора не заданы параметры источника данных. '
               'Компонент не будет работать корректно.'
            ].join ''

   # @const {Number} - наименование анимации подсветки рамок.
   _GLOW_BORDER_ANIMATION_NAME: 'animate-glow-border'

   # @const {Number} - таймаут открытия автодополения.
   _AUTO_COMPLETE_TIMEOUT: 1000

   # @const {Number} - минимальный таймаут для передвижения запуска в конец стека выполнения.
   _FICTITIOUS_TIMEOUT: 4

   # @const {Object} - параметры произвольной области для автодополнения.
   _AUTO_COMPLETE_AREA_PARAMS:
      attached:
         layoutAnchor: 'parent'
         animation: 'slideDown'
         position:
            horizontal:
               left: 'left'
         offsetFromTarget:
            top: 5
         isAdaptive: true
         isHasShadow: true
         isHasBorder: false
         isResetOffset: true
         isCatchFocus: false
         isCloseOnBlur: false
         isTriggerOnSameTarget: false
      browserMode:
         layoutAnchor: 'window'
         animation: 'slideRight'
         dockModeParams:
            position: 'left'
         position: undefined
         offsetFromTarget: {}
         enableResize: true
         isCatchFocus: true
         isHasShadow: true
         isHasBorder: false
         isTriggerOnSameTarget: false
         isForcedLeaveShown: true
         isCloseOnBlur: false
         isHasCloseButton: true

   # @const {Object} - заголовок для диалога справочника в режиме "обозревателя".
   _BROWSER_MODE_CAPTION_DEFAULT: 'Выберите запись'

   # @const {Object} - станадартные параметры для таблицы данных словаря.
   _DICTIONARY_DATA_TABLE_PARAMS:
      common:
         enableRowOptions: false
         enableRowSelect: false
         enableObjectCard: false
         enableColumnsHeader: false
         enableStatusBar: false
         enableToolbar: false
         enableLazyLoad: true
         isFitToContainer: true
         isHasStripFarming: false
         isFitToContainer: false
         isUseImplementation: true
      browserMode:
         enableLazyLoad: false
         enableStatusBar: true
         enableToolbar: true
         enableCreate: false
         enablePerPageSelector: false
         isUseImplementation: true

   # @const {Object} - набор свойств, имеющих реализацию в хранилище реализаций.
   _IMPLEMENTED_PROPS: keyMirror(
      renderParams: null
      recordsDosage: null
      dataTableParams: null
      dataSource: null
      isReadOnly: null
      enableConsistentClear: null
   )

   # @const {Object} - набор строк для ссылко на узлы.
   _REFS: keyMirror(
      selector: null
      selectorInput: null
      itemsContainer: null
      dictionaryContainer: null
      dictionaryTable: null
      input: null
   )

   # @const {Object} - параметры для кнопки показа скрытых элементов.
   _HIDDEN_ELEMENTS_BUTTON_PARAMS:
      caption: '...'
      title: 'Показать все выбранные элементы'

   # @const {String} - маркер ключевого значения записи (для шаблонов рендера)
   _KEY_FIELD: 'key'

# TODO: произвести рефакторинг констант - собрать ключи в одну коллекцию.
   # @const {String} - ключ для доп.фильтра по начальным записям иерархии.
   _START_KEYS_KEY: 'start_keys'

   # @const {String} - ключ считывания набора записей.
   _RECORDS_KEY: 'records'

   # @const {String} - ключ считывания полей записи.
   _FIELDS_KEY: 'fields'

   # @const {String} - ключ считывания ключа записи.
   _KEY_KEY: 'key'

   # @const {String} - ключ внешних связок.
   _EXT_ENTITIES_KEY: 'externalEntities'

   # @const {String} - имя css класса для компонента
   _SELECTOR_CLASS_NAME: 'selector'

   # @const {String} - тип скрытого поля формы.
   _HIDDEN_INPUT_TYPE: 'hidden'

   # @const {String} - ключ доступа к параметрам считывания альтернативного
   #                   имени поля из пармаетров ключа считывания результата источника данных.
   _ALTERNATIVE_FIELD_KEY: 'alternativeFieldName'

   # @const {String} - строка - тип текстового поля ввода.
   _TEXT_INPUT_TYPE: 'text'

   # @const {Object} - набор ключей для считывания параметров контсруирования параметров выбранных
   #                   значений.
   _INSTANCE_RENDER_KEYS: keyMirror(
      template: null
      fields: null
      arbitrary: null
   )

   # @const {Object} - набор используемых строковых литералов.
   _CHARS:
      empty: ''
      space: ' '
      sqBracketStart: '['
      sqBracketEnd: ']'
      collectionMark: 's'
      comma: ','
      point: '.'
      slash: '/'
      underscore: '_'

   # @const {Object} - параметры кнопки прямого запроса.
   _DIRECT_REQUEST_BUTTON_PARAMS:
      title: 'Прямой запрос'
      icon: 'external-link-square'

   # @const {Object} - параметры для произовальной области отображения всех
   #                   выбранных элементов.
   _ALL_SELECTED_AREA_PARAMS:
      animation: 'fade'
      layoutAnchor: 'parent'

   # @const {Object} - Параметры для кнопки открытия обозревателя справочника.
   _BROWSER_OPEN_BUTTON_PARAMS:
      isLink: true
      isWithoutPadding: true

   # @const {Object} - Параметры для кнопки открытия справочника.
   _DICTIONARY_OPEN_BUTTON_PARAMS:
      icon: 'sort-down'
      isLink: true
      isWithoutPadding: true

   # @const {Object} - коды нажимаемых клавиш.
   _KEY_CODES:
      enter: 13
      left: 37
      up: 38
      right: 39
      down: 40

   # @const {Object} - возможные позиции для кнопки открытия справочника в режиме
   #                   браузера.
   _BROWSER_OPENER_POSITIONS: keyMirror(
      top: null
      leftIn: null
   )

   # @const {String} - всплывающее пояснение на кнопке открытия справочника в режиме
   #                   браузера.
   _BROWSER_OPENER_TITLE: 'Открыть справочник'

   # @const {String} - наименование DOM-узла поля ввода (для проверки типа
   #                   текущего активного узла).
   _INPUT_NODE_NAME: 'INPUT'

   # @const {Number} - идентификатор таймаута на показ автодополнения.
   _autoCompleteTimeoutIdentifier: null

   # @const {String} - временная метка селектора (для раздельной работы экземпляров компонента
   #  с flux инфраструктуры).
   _componentIdentifier: null

   mixins: [
      HelpersMixin,
      AnimateMixin,
      AnimationsMixin.glowBorder,
      ImplementedPropReader
   ]

   styles:
      common:
         borderStyle: 'solid'
         padding: 0
         display: 'block'
         fontSize: 13
         color: _COLORS.hierarchy2
         backgroundColor: _COLORS.light
         boxShadow: ''
         glowColor: _COLORS.light
         textAlign: 'left'
      glowBorder:
         boxShadow: ['0 0 ', _COMMON_PADDING, 'px '].join('')
         glowColor: _COLORS.main
      selectorContainer:
         minHeight: 27
         width: '100%'
      allSelectedElementsContainer:
         maxWidth: 500
         padding: _COMMON_PADDING
         whiteSpace: 'normal'
      itemsContainerCell:
         width: '100%'
         whiteSpace: 'normal'
      itemsContainerCellSingleLine:
         overflow: 'hidden'
         whiteSpace: 'nowrap'
      input:
         borderWidth: 1
         width: '100%'
      selectorInput:
         margin: 2
      functionalCell:
         paddingLeft: 4
         paddingRight: 4
      itemButton:
         padding: 0
         whiteSpace: 'nowrap'
      dictionaryContainer:
         paddingRight: 20
      selectedItemsContainer:
         display: 'inline-flex'
         marginRight: 2
         paddingLeft: _COMMON_PADDING
      browserOpenerButton:
         verticalAlign: 'sub'
      browserModeCaption:
         backgroundColor: _COLORS.hierarchy3
         padding: 2

   propTypes:
      name: React.PropTypes.string
      identifyingName: React.PropTypes.string
      caption: React.PropTypes.string
      placeholder: React.PropTypes.string
      tabIndex: React.PropTypes.number
      enableMultipleSelect: React.PropTypes.bool
      enableAddingSelectedItemsToFilter: React.PropTypes.bool
      enableConsistentClear: React.PropTypes.bool
      enableTotalClear: React.PropTypes.bool
      isReinit: React.PropTypes.bool
      isReadOnly: React.PropTypes.bool
      isAdaptive: React.PropTypes.bool
      isUseImplementation: React.PropTypes.bool
      isImplementationHigherPriority: React.PropTypes.bool
      isMergeImplementation: React.PropTypes.bool
      maxWidth: React.PropTypes.number
      implementationStore: React.PropTypes.object
      additionFilterParams: React.PropTypes.object
      presetRecords: React.PropTypes.arrayOf(React.PropTypes.object)
      recordsDosage:  React.PropTypes.objectOf(React.PropTypes.number)
      dictionaryBrowserParams:  React.PropTypes.objectOf(React.PropTypes.object)
      dataSource:  React.PropTypes.objectOf(React.PropTypes.object)
      renderParams:  React.PropTypes.objectOf(React.PropTypes.object)
      dataTableParams:  React.PropTypes.objectOf(React.PropTypes.object)
      onChange: React.PropTypes.func

   getDefaultProps: ->
      tabIndex: 1
      enableMultipleSelect: false
      enableAddingSelectedItemsToFilter: false
      enableConsistentClear: false
      enableTotalClear: true
      isReinit: false
      isReadOnly: false
      isAdaptive: false
      isUseImplementation: false
      isImplementationHigherPriority: false
      isMergeImplementation: false

   getInitialState: ->
      presetRecords = @props.presetRecords
      isHasPresetRecords = presetRecords? and presetRecords.length
      initRecords = if isHasPresetRecords then presetRecords else []

      implementationProps: @_getImplementationProps()
      selectedRecords: initRecords
      initRecords: initRecords
      selectorInput: ''
      collectionTarget: null
      allSelectedElementsTarget: null
      dictionaryActivatedRowKey: null
      isInInput: false
      isDictionaryShown: false
      isDictionaryInBrowserMode: false
      isContainerScrolled: false
      isInstancesRequesting: false
      isParentInstancesRequest: false

   componentWillReceiveProps: (nextProps) ->
      selectedRecords = @state.selectedRecords
      initRecords = @state.initRecords
      currentIdentifyingName = @props.identifyingName
      nextIdentifyingName = nextProps.identifyingName

      if @_isSelectedRecordsDifferent(selectedRecords, initRecords)

         # Если был сброшен флаг переинициализации поля - установим выбранной начальную запись.
         if nextProps.isReinit
            @_addSelectedRecord(@state.initRecords, true)

      # Если идентификационные имена различаются - перечитываем свойства хранилища
      #  реализаций.
      if currentIdentifyingName isnt nextIdentifyingName
         @setState implementationProps: @_getImplementationProps(nextProps)

   render: ->
      autoCompleteAreaParams = @_AUTO_COMPLETE_AREA_PARAMS
      textInputType = @_TEXT_INPUT_TYPE
      refs = @_REFS
      selectorCaption = @props.caption
      selectorDimension = @_getSelectorDimension()
      isReadOnly = @props.isReadOnly
      inputPlaceholder = if @_isHasSelectedRecords()
                            @_CHARS.empty
                         else
                            @props.placeholder

      # В зависимости от того установлен ли флаг открытия словаря в режиме браузера
      #  выбираем разные параметры для произвольной области (или присоединенные
      #  параметры или параметры браузера).
      dictionaryAreaParams =
         if @state.isDictionaryInBrowserMode
            autoCompleteAreaParams.browserMode
         else
            autoCompleteAreaParams.attached

      browserOpener = @_getBrowserButtonOpener()

      `(
         <span className={this._SELECTOR_CLASS_NAME}>
            {browserOpener.top}
            <span style={this._getSelectorStyle()}
                  onClick={this._onClickSelector} >
               <table ref={refs.selector}
                      style={this.styles.selectorContainer}>
                  <tbody>
                     <tr>
                        {browserOpener.leftIn}
                        {this._getAllSelectedElementsCell()}
                        <td style={this._getItemsContainerStyle(selectorDimension.itemsContainer)}
                            ref={refs.itemsContainer} >
                           {this._getSelectedItems()}
                           <Input type={textInputType}
                                  ref={refs.selectorInput}
                                  placeholder={inputPlaceholder}
                                  isEmbedded={true}
                                  isStretchable={true}
                                  isReadOnly={isReadOnly}
                                  isAjaxRequest={this.state.isInstancesRequesting}
                                  tabIndex={this.props.tabIndex}
                                  minWidth={selectorDimension.input.width.min}
                                  maxWidth={selectorDimension.input.width.max}
                                  styleAddition={
                                     { container: this.styles.selectorInput }
                                  }
                                  value={this.state.selectorInput}
                                  onChange={this._onChangeInputSelector}
                                  onFocus={this._onFocusInput}
                                  onBlur={this._onBlurInput}
                                  onKeyDown={this._onKeyDownInput} />
                           {this._getValuesContent()}
                        </td>
                        {this._getDirectRequestCell()}
                        {this._getClearCell(isReadOnly)}
                        {this._getDictionaryOpenCell(isReadOnly)}
                     </tr>
                  </tbody>
               </table>
            </span>
            <ArbitraryArea content={this._getAutoCompleteContent(selectorDimension.autoComplete)}
                           ref={refs.dictionaryContainer}
                           target={this.state.collectionTarget}
                           captionParams={this._getDictionaryBrowserModeCaptionParams()}
                           onHide={this._onHideArea}
                           onBlur={this._onBlurArea}
                           onShow={this._onShowArea}
                           onClick={this._onTerminateAreaClick}
                           {...dictionaryAreaParams}
            />
         </span>
       )`

   componentDidMount: ->
      dataSource = @_getComponentProp(@_IMPLEMENTED_PROPS.dataSource)
      messages = @_MESSAGES

      if dataSource? and !_.isEmpty(dataSource)
         instancesParams = dataSource.instances
         dictionaryParams = dataSource.dictionary
         dictionaryUrl = dictionaryParams.url
         selectedRecords = @state.selectedRecords
         ServiceStore.addChangeListener @_onChange
         selectorIdentifier =
            @crc32FromString(Date.now().toString() + @props.name)
         isSendInstancesRequest = false
         isHasSelectedRecords = selectedRecords? and !_.isEmpty(selectedRecords)

         # Если не заданы выбранные записи и заданы параметры получения - отправим
         #   запрос на получения изначально выбранных записей.
         if !isHasSelectedRecords and instancesParams? and !_.isEmpty(instancesParams)
            instanceUrl = instancesParams.url
            instanceFilter = instancesParams.filter
            instanceKeys = instancesParams.keys
            instanceKey = _.head(instanceKeys) if instanceKeys?
            selector = this

            instanceRequestUrl =
               instanceUrl or @_getInstanceUrlFromDictionaryUrl(dictionaryUrl,
                                                                instanceKey)

            # Если задан адрес считывания экземпляра/экземпляров, подпишемся наUrl изменения
            #  сервисного хранилища и отправим запрос на получения данных по экземпляру.
            if instanceRequestUrl?
               isSendInstancesRequest = true

               # Отправляем запрос по таймауту, т.к. данный компонент в составе сложного(форма)
               #  может находится в середине запроса работы с диспетчером flux (выдаст исключение).
               @delay 4, ->
                  ServiceActionCreators.getSelectorInstances instanceRequestUrl,
                                                             selectorIdentifier,
                                                             instanceFilter

                  selector.setState isInstancesRequesting: true
         # Если были заданы выбранные записи и при этом не был отправлен запрос
         #  на получение экземпляров, то вызовем обработчик изменения значения
         #  в компоненте.
         if isHasSelectedRecords and !isSendInstancesRequest
            @_handleOnChangeProcess(selectedRecords, true)
      else
         log.warn(messages.errors.dataSourceNotSet)

      # Запоминаем идентификатор текущего экземпляра.
      @_componentIdentifier = selectorIdentifier

   componentDidUpdate: (prevProps, prevState) ->
      currentSelectedRecords = @state.selectedRecords
      prevSelectedRecords = prevState.selectedRecords
      isExistCurrentRecords = currentSelectedRecords? and currentSelectedRecords.length
      isExistPrevRecords = prevSelectedRecords? and prevSelectedRecords.length
      isItemsContainerNeedScroll =  @_isItemsContainerNeedScroll()

      # Если были выбраны записи и установлен флаг рендера контейнера
      #  выбранных записей в одну строку - продолжим
      if isExistCurrentRecords and @_isItemsContainerInSingleLine()

         # Если ранее были выбраны записи и они отличаются от текущих - нужна
         #  прокрутка конейнера вправо.
         # Иначе - если контейнеру нужна прокрутка(ещё не прокручен) - прокручиваем.
         if isExistPrevRecords and @_isSelectedRecordsDifferent(currentSelectedRecords,
                                                                prevSelectedRecords)
            @_scrollContainerToRight()
         else if isItemsContainerNeedScroll
            @_scrollContainerToRight()

      # Если флаг прокрутки контейнера отличается от текущего
      #  вычисленного - сохраним флаг в свойствах.
      if @state.isContainerScrolled isnt isItemsContainerNeedScroll
         @setState isContainerScrolled: isItemsContainerNeedScroll

   componentWillUnmount: ->
      ServiceStore.removeChangeListener @_onChange

   ###*
   * Функция создания кнопки-запускающего обозреватель справочника. Если
   *  заданы параметры для кнопки - создаем кнопку, иначе ничего не создаем.
   *
   * @return {Object<React-element, undefined>}
   ###
   _getBrowserButtonOpener: ->
      if @_isHasDictionaryBrowserParams()
         openButtonParams = @props.dictionaryBrowserParams.openButton

         if openButtonParams?
            captionParams = openButtonParams.caption
            openButtonPosition = openButtonParams.position
            browserOpenerPositions = @_BROWSER_OPENER_POSITIONS

            buttonCaption =
               if captionParams?
                  if _.isString(captionParams)
                     captionParams
                  else if @_isHasSelectedRecords()
                     captionParams.selected
                  else
                     captionParams.empty

            buttonTitle = openButtonParams.title or @_BROWSER_OPENER_TITLE

            button =
               `(
                   <Button caption={buttonCaption}
                           icon={openButtonParams.icon}
                           title={buttonTitle}
                           styleAddition={this.styles.browserOpenerButton}
                           onClick={this._onClickBrowserOpen}
                           {...this._BROWSER_OPEN_BUTTON_PARAMS}
                         />
                )`

            switch openButtonPosition
               when browserOpenerPositions.top
                  topOpener = button
               when browserOpenerPositions.leftIn
                  leftInOpener =
                     @_getFunctionalCell(button)

      top: topOpener
      leftIn: leftInOpener

   ###*
   * Функция получения ячейки с кнопкой разворачивания справочника возможных
   *  значений под полем.
   *
   * @param {Boolean} isDisabled - флаг недоступности.
   * @return {React-element}
   ###
   _getDictionaryOpenCell: (isDisabled) ->
      @_getFunctionalCell(
         `(
            <Button isDisabled={isDisabled}
                    onClick={this._onClickShowCollection}
                    {...this._DICTIONARY_OPEN_BUTTON_PARAMS}
                 />
          )`
      )

   ###*
   * Функция-декоратор для содержимого. Оборачивает передаваемое содержимое в
   *  ячейку для "функционального содержимого" с определенными стилями.
   *
   * @param {React-element} cellContent - содержимое ячейки.
   * @return {React-element}
   ###
   _getFunctionalCell: (cellContent) ->
      `(<td style={this.styles.functionalCell}>{cellContent}</td>)`

   ###*
   * Функция получения ячейки с кнопкой показа скрытых элементов (для однострочных
   *  селекторов с ограничение по ширине) и произвольной областью - конейнером всех элементов.
   *
   * @return {React-element, undefined} - ячейка с кнопкой показа скрытых элементов.
   ###
   _getAllSelectedElementsCell: ->

      return unless @state.isContainerScrolled

      buttonParams = @_HIDDEN_ELEMENTS_BUTTON_PARAMS
      areaParams = @_ALL_SELECTED_AREA_PARAMS

      selectedItems =
        `(
            <div style={this.styles.allSelectedElementsContainer}>
               {this._getSelectedItems()}
            </div>
         )`

      @_getFunctionalCell(
         `(
            <span>
               <Button isLink={true}
                       isWithoutPadding={true}
                       caption={buttonParams.caption}
                       title={buttonParams.title}
                       onClick={this._onClickShowAllSelectedElements} />
               <ArbitraryArea content={selectedItems}
                              target={this.state.allSelectedElementsTarget}
                              layoutAnchor={areaParams.layoutAnchor}
                              animation={areaParams.animation}
                              isHasShadow={true}
                              isHasBorder={false}
                              isResetOffset={true}
                              isCatchFocus={false}
                              isCloseOnBlur={false}
                              isAdaptive={this.props.isAdaptive}
                              onHide={this._onHideAllSelectedElementsArea}
                           />
            </span>
          )`
      )

   ###*
   * Функция получения содержимого автодополнения. Запускает функцию создания таблицы
   *  данных с передачей параметров получения данных.
   *
   * @param {Object} autoCompleteDimension   - размерность компонента автодополнения.
   * @return {React-element, undefined} - таблица данных для словаря.
   ###
   _getAutoCompleteContent: (autoCompleteDimension) ->
      if @state.collectionTarget?
         @_getDataTableForAutoComplete(
            @_getElementProps(@_SELECTOR_ELEMENTS.dictionary))

   ###*
   * Функция получения содержимого автодополнения. Подгружает компонент таблицы
   *  данных, составляет flux параметры для считывания данных и возвращает таблицу,
   *  если задан целевой узел для произвольной области (т.е. она показана).
   *
   * @param {Object} params - параметры для словаря. Вид:
   *        {Object} renderParams   - параметры рендера словаря поля выбора.
   *        {Object} tableParams - параметры управления данными в таблице.
   *        {Object} dataSource - параметры источников данных.
   *        {Number} recordsPerPage - кол-во записей на одну страницу.
   *        {String, Array} resultKey - ключ(ключи) считывания результатов.
   * @return {React-element, undefined} - таблица данных для словаря.
   ###
   _getDataTableForAutoComplete: (params) ->
      renderParams = params.renderParams
      dataTableParams = params.tableParams
      dictionaryDataSource = params.dataSource
      recordsPerPage = params.recordsPerPage
      resultKey = params.resultKey

      # АХТУНГ: костыль из-за циклической зависимости компонентов.
      DataTable = require('components/core/data_table')
      dictionaryDataTableParams = @_DICTIONARY_DATA_TABLE_PARAMS

      if renderParams?
         dataTableColumnRenderParams = renderParams.columnRenderParams
         dataTableDimension = renderParams.dimension
         dataTableViewType = renderParams.viewType

      if dataTableParams?
         hierarchyViewParams = dataTableParams.hierarchyViewParams
         modelParams = dataTableParams.modelParams

      fluxParams =
         store: ServiceStore
         init:
            requestUrl: dictionaryDataSource.url
            requestIdentifier: @_componentIdentifier
            sendRequest: ServiceActionCreators.getSelectorDictionary
            responseType: ActionTypes.SELECTOR_DICTIONARY_RESPONSE
            responseResultKey: resultKey
            getResponseIdentifier: ServiceStore.getLastInteractionSelectorIdentifier
            getResponse: ServiceStore.getSelectorDictionaries

      if @state.isDictionaryInBrowserMode
         browserModeParams = dictionaryDataTableParams.browserMode

      `(
         <DataTable {...dictionaryDataTableParams.common}
                    dimension={dataTableDimension}
                    ref={this._REFS.dictionaryTable}
                    recordsPerPage={recordsPerPage}
                    modelParams={modelParams}
                    hierarchyViewParams={hierarchyViewParams}
                    viewType={dataTableViewType}
                    fluxParams={fluxParams}
                    filterParams={this.state.filterParams}
                    columnRenderParams={dataTableColumnRenderParams}
                    implementationStore={this.props.implementationStore}
                    styleAddition={
                       {
                          dataContainer: this.styles.dictionaryContainer
                       }
                    }
                    {...browserModeParams}
                    onRowClick={this._onSelectValue}
                    onKeyDown={this._onKeyDownDictionary}
                  />
      )`

   ###*
   * Функция получения узлов для выбранных элементов. Перебирает массив выбранных записей
   *  и создает массив узлов с кнопкой-идентификаторов выбранной записи и кнопкой удаления
   *  данной записи из набора выбранных.
   *
   * @return {Array<React-element>, undefined} - набор узлов.
   ###
   _getSelectedItems: ->
      selectedRecords = @state.selectedRecords
      # renderParams = @props.renderParams
      # instanceRenderParams = renderParams.instance if renderParams?
      # isReadOnly = @props.isReadOnly
      # isConsistentClear = @props.enableConsistentClear
      itemsParams = @_getElementProps(@_SELECTOR_ELEMENTS.instances)
      instanceRenderParams = itemsParams.renderParams
      isReadOnly = itemsParams.isReadOnly
      isConsistentClear = itemsParams.isConsistentClear
      selectedItems = []

      if instanceRenderParams?
         instanceRenderDimension = instanceRenderParams.dimension
         onRenderInstanceHandler = instanceRenderParams.onRender

      ###*
      * Функция построения узла для отображения выбранного элемента.
      *
      * @param {Function} captionHandler - обработчик построения заголовка.
      * @param {Object} record           - параметры выбранной записи.
      * @param {Number} idx              - индекс элемента.
      * @return {React-Element}
      ###
      instanceRender = (captionHandler, record, idx) ->

         if record?
            itemKey = [idx, record.key].join @_CHARS.underscore

            captionHandler

            itemCaption =
               if captionHandler?
                  captionHandler(record)
               else
                  @_constructItemCaption record, instanceRenderParams

            clearOrCommaElement =
               if !isConsistentClear or idx is selectedRecords.length - 1
                  `(
                     <Button isClear={true}
                             isWithoutPadding={true}
                             isDisabled={isReadOnly}
                             onClick={this._onClickRemoveRecord}
                             value={record} />
                  )`
               else
                  @_CHARS.comma


            `(
                <div key={itemKey}
                     style={this.styles.selectedItemsContainer} >
                  <Button caption={itemCaption}
                          dimension={instanceRenderDimension}
                          title={itemCaption}
                          isLink={true}
                          isWithoutPadding={true}
                          styleAddition={this.styles.itemButton}/>
                  {clearOrCommaElement}
                </div>
            )`

      if selectedRecords? and !_.isEmpty(selectedRecords)

         selectedInstanceRender = instanceRender.bind(this, onRenderInstanceHandler)

         selectedRecords.map selectedInstanceRender


   ###*
   * Функция получения ячейки с кнопкой отправки прямого запроса поля-селектора.
   *
   * @return {React-Element}
   ###
   _getDirectRequestCell: ->
      selectedRecords = @state.selectedRecords
      isNeedDirectRequestCell = @_isHasDirectRequestParams() and
                                @_isHasValueInInput() #and
                                #!@_isHasSelectedRecords()

      if isNeedDirectRequestCell
         directRequestButtonParams = @_DIRECT_REQUEST_BUTTON_PARAMS

         @_getFunctionalCell(
            `(
               <Button title={directRequestButtonParams.title}
                       icon={directRequestButtonParams.icon}
                       isLink={true}
                       isWithoutPadding={true}
                       onClick={this._sendDirectRequest} />
             )`
         )

   ###*
   * Функция получения ячейки для очистки селектора. Если есть выбранные значения
   *  или что-то введено в поле ввода - вернем ячейки с кнопкой очистки, ичане
   *  ничего не возвращаем.
   *
   * @param {Boolean} isDisabled - флаг недоступной кнопки.
   * @return {React-element, undefined} - узел с ячейкой очистки.
   ###
   _getClearCell: (isDisabled) ->
      return unless @props.enableTotalClear

      if @_isHasSelectedRecords() or @_isHasValueInInput()

         @_getFunctionalCell(
            `(
               <Button isClear={true}
                       isWithoutPadding={true}
                       isDisabled={isDisabled}
                       onClick={this._onClickClearSelector} />
            )`
         )

   ###*
   * Функция получения набора скрытых полей(скрытого поля) для хранения выбранных значений.
   *
   * @return {React-element, undefined} - узел с ячейкой очистки.
   ###
   _getValuesContent: ->
      selectedRecords = @state.selectedRecords
      isHasSelectedRecords = selectedRecords? and selectedRecords.length
      selectorFieldName = @props.name
      chars = @_CHARS
      selector = this

      ###*
      * Функция генерации скрытого поля формы для хранения значения.
      *
      * @param {String} name - имя поля.
      * @param {String} value - значение в поле.
      * @param {Number} key - ключ экземпляра поля в наборе.
      * @return {React-element}
      ###
      getHiddenInput = ((name, value, key) ->
         `(<input key={key}
                  type={this._HIDDEN_INPUT_TYPE}
                  name={name}
                  value={value} />)`
      ).bind(this)


      ###*
      * Функция генерации имени скрытого поля для коллекции(при разрешенном
      *  множественном выборе).
      *
      * @param {Object} record - запись по которой генерируется наименование поля.
      * @return {String}
      ###
      getFieldNameForInstanceInCollection = ((record) ->
         alternativeFieldKey = @_ALTERNATIVE_FIELD_KEY
         chars = @_CHARS
         sqBracketStart = chars.sqBracketStart
         sqBracketEnd = chars.sqBracketEnd
         emptyChar = chars.empty
         collectionAttribute = [sqBracketStart, sqBracketEnd].join chars.empty

         # Если задано альтернативное имя поля - составляем имя поля на основе
         #  заданного в параметрах с добавлением альтернативного. Также проверяется
         #  последний символ имени, если он оканчивается на "s" - добавляется символ
         #  массива в имя, т.к. это признак множественного значения (может и нет, но пока так).
         if _.has(record, alternativeFieldKey)
            alternativeFieldName = record[alternativeFieldKey]
            lastNameChar = alternativeFieldName[alternativeFieldName.length - 1]
            isCollection = lastNameChar is chars.collectionMark

            [
               selectorFieldName
               sqBracketStart
               alternativeFieldName
               sqBracketEnd
               collectionAttribute if isCollection
            ].join emptyChar
         else
            lastTwoChar = selectorFieldName.slice(-2)
            isLastCharsIsntCollectionAttribute = lastTwoChar isnt collectionAttribute

            if isLastCharsIsntCollectionAttribute
               [selectorFieldName, collectionAttribute].join emptyChar
            else
               selectorFieldName

      ).bind(this)

      # Если заданы выбранные записи - создаем скрытые поля, хранящие выбранные
      #  значения для этих записей.
      # Иначе создаем пустое скрытое поле, хранящее пустое значение (поле
      #  необходимо при обновлении данных).
      if isHasSelectedRecords

         # Если задан флаг возможности множественного выбора - перебираем
         #  весь набор выбранных записей и для каждого создаем скрытое поле
         #  со значением.
         if @props.enableMultipleSelect

            selectedRecords.map (record, idx) ->
               getHiddenInput(
                  getFieldNameForInstanceInCollection(record),
                  record.key,
                  idx
               )
         else
            getHiddenInput selectorFieldName, selectedRecords[0].key
      else
         getHiddenInput selectorFieldName, null

   # ###*
   # * Функция получения параметров источников данных. Считывает параметры по
   # *  приоритету:
   # *  1. @props.dataSource
   # *  2. @state.implementationProps.dataSource
   # *
   # * @return
   # ###
   # _getDataSource: ->
   #    implementationProps = @state.implementationProps

   #    @props.dataSource or (implementationProps? and implementationProps.dataSource)

   ###*
   * Функция получения стиля для селектора.
   *
   * @return {Object} - скомпанованный стиль.
   ###
   _getSelectorStyle: ->
      @computeStyles @styles.common,
                     StylesMixin.mixins.inputBorder,
                     !@props.isReadOnly and @_getGlowStyle()

   ###*
   * Функция получения стиля для контейнера выбранных элементов.
   *
   * @param {Object} - параметры размерности
   * @return {Object} - скомпанованный стиль.
   ###
   _getItemsContainerStyle: (containerDimension) ->
      isInSingleLine = @_isItemsContainerInSingleLine()

      @computeStyles @styles.itemsContainerCell,
                     isInSingleLine and @styles.itemsContainerCellSingleLine,
                     {maxWidth: containerDimension.width.max}

   ###*
   * Функция формирования параметров заголовка для диалога справочника в режиме
   *  "обозревателя".
   *
   * @return {Object}
   ###
   _getDictionaryBrowserModeCaptionParams: ->

      if @state.isDictionaryInBrowserMode
         captionText = @props.caption or @_BROWSER_MODE_CAPTION_DEFAULT

         text: captionText
         styleAddition:
            common: @styles.browserModeCaption

   ###*
   * Функция получения стиля для анимации подсветки рамки. Получает нужный стиль,
   *  только для компонента, на котором находится фокус (@state.isInInput)
   *
   * @return {Object. undefined} - стиль для анмации
   ###
   _getGlowStyle: ->
      if @state.isInInput
         chars = @_CHARS

         boxShadow: [
            @styles.glowBorder.boxShadow
            chars.space
            @getAnimatedStyle(@_GLOW_BORDER_ANIMATION_NAME).glowColor
         ].join chars.empty

   ###*
   * Функция получения свойств стандартной реализации для селектора. Получает свойства
   *  заданные в стандартных реализациях для конкретного компонента. Пробует получить
   *  параметры, если задан флаг @props.isUseImplementation и хранилище реализаций
   *  @props.implementationStore.
   *
   * @param {Object} props - свойства на базе которых считываются параметры реализации.
   *                         если свойства на переданы, берутся текущие @props.
   * @return {Object}
   ###
   _getImplementationProps: (props) ->
      props ||= @props
      isUseImplementation = props.isUseImplementation
      implementationStore = props.implementationStore

      if isUseImplementation and (implementationStore? and !_.isEmpty implementationStore)
         identifyingName = props.identifyingName or props.name

         implementationStore.getProps(identifyingName,
                                      @constructor.displayName)

   ###*
   * Функция получения параметров для различных составляющих элементов компонента.
   *  получает параметры по приоритету из @props, затем из @state.implementationProps.
   *
   * @param {String} elementName - имя элемента компонента.
   * @return {Object}
   ###
   _getElementProps: (elementName) ->
      selectorElementNames = @_SELECTOR_ELEMENTS
      implementedProps = @_IMPLEMENTED_PROPS
      renderParams = @_getComponentProp(implementedProps.renderParams)
      recordsDosage = @_getComponentProp(implementedProps.recordsDosage)
      dataTableParams = @_getComponentProp(implementedProps.dataTableParams)
      dataSource = @_getComponentProp(implementedProps.dataSource)

      switch elementName
         when selectorElementNames.input
            inputRenderParams =
               if renderParams? and renderParams.input?
                  renderParams.input

            renderParams: inputRenderParams
         when selectorElementNames.dictionary
            isDictionaryInBrowserMode = @state.isDictionaryInBrowserMode

            recordsPerPage =
               if recordsDosage?
                  if isDictionaryInBrowserMode
                     recordsDosage.browser or recordsDosage.dictionary
                  else
                     recordsDosage.dictionary

            dictionaryRenderParams =
               if renderParams? and renderParams.dictionary?
                  renderParams.dictionary

            browserSpecificRenderParams =
               if isDictionaryInBrowserMode and renderParams? and renderParams.browserSpecific?
                  renderParams.browserSpecific

            dataSourceParams =
               if dataSource? and dataSource.dictionary?
                  dataSource.dictionary

            dataTableParams =
               if dataTableParams? and !_.isEmpty(dataTableParams)
                  dataTableParams

            recordsPerPage: recordsPerPage
            renderParams: _.merge({}, dictionaryRenderParams, browserSpecificRenderParams)
            tableParams: dataTableParams
            dataSource: dataSourceParams
            resultKey: dataSourceParams.resultKey if dataSourceParams?
         when selectorElementNames.instances
            instancesRenderParams =
               if renderParams? and renderParams.instance?
                  renderParams.instance

            isReadOnly = @_getComponentProp(implementedProps.isReadOnly)
            isConsistentClear =
               @_getComponentProp(implementedProps.enableConsistentClear)

            renderParams: instancesRenderParams
            isReadOnly: isReadOnly
            isConsistentClear: isConsistentClear
         when selectorElementNames.itemsContainer
            containerRenderParams =
               if renderParams? and renderParams.itemsContainer?
                  renderParams.itemsContainer

            renderParams: containerRenderParams

   ###*
   * Функция получения размеров компонентов селектора. Полученет размеры поля ввода
   *  и автодополнения, если заданы. Если параметры не заданы - задает критичные
   *  параметры размеров по-умолчанию.
   *
   * @return {Object} - хэш параметров размеров.
   ###
   _getSelectorDimension: ->
      #renderParams = @props.renderParams
      selectorElementNames = @_SELECTOR_ELEMENTS
      inputRenderParam =
         @_getElementProps(selectorElementNames.input).renderParams
      dictionaryRenderParam =
         @_getElementProps(selectorElementNames.dictionary).renderParams
      itemsContainerRenderParam =
         @_getElementProps(selectorElementNames.itemsContainer).renderParams
      defaultDimension = @_DEFAULT_DIMENSION
      defaultInputWidth = defaultDimension.input.width
      defaultAutoCompleteHeight = defaultDimension.autoComplete.height
      defaultAutoCompleteWidth = defaultDimension.autoComplete.width

      # if renderParams? and !$.isEmptyObject(renderParams)
      inputDimension = if inputRenderParam?
                          inputRenderParam.dimension
      dictionaryDimension = if dictionaryRenderParam?
                               dictionaryRenderParam.dimension
      autoCompleteDimension = if dictionaryDimension?
                                 dictionaryDimension.dataContainer

      if itemsContainerRenderParam?
         itemsContainerDimension = itemsContainerRenderParam.dimension

      # Оперделим размеры поля ввода.
      if inputDimension? and !_.isEmpty(inputDimension)
         inputWidthProp = inputDimension.width

         inputMinWidth = inputWidthProp.min
         inputMaxWidth = inputWidthProp.max

      # Определим размеры контейнера для выбранных элементов(с полем ввода).
      if itemsContainerDimension? and !_.isEmpty(itemsContainerDimension)
         itemsContainerWidth = itemsContainerDimension.width
         itemsContainerMaxWidth = itemsContainerWidth.max


      # Опредилим размеры автодополения.
      if autoCompleteDimension? and !_.isEmpty(autoCompleteDimension)
         autoCompleteMaxWidth = autoCompleteDimension.width.max
         autoCompleteMaxHeight = autoCompleteDimension.height.max

      # Если размеры не были заданы через параметры - возьмем значения по-умолчанию.
      unless inputMaxWidth?
         inputMaxWidth = defaultInputWidth.max
      unless inputMinWidth?
         inputMinWidth = defaultInputWidth.min
      unless autoCompleteMaxWidth?
         autoCompleteMaxWidth = defaultAutoCompleteWidth.max
      unless autoCompleteMaxHeight?
         autoCompleteMaxHeight = defaultAutoCompleteHeight.max

      input:
         width:
            min: inputMinWidth
            max: inputMaxWidth
      itemsContainer:
         width:
            max: itemsContainerMaxWidth
      autoComplete:
         width:
            max: autoCompleteMaxWidth
         height:
            max: autoCompleteMaxHeight

   ###*
   * Функция получения целевого узла для произвольного поля автодополенния.
   *
   * @return
   ###
   _getAreaTarget: ->
      @refs.selector if @isMounted()

   ###*
   * Функция получения параметров прямого запроса.
   *
   * @return {Object, undefined}
   ###
   _getDirectRequestParams: ->
      if @_isHasAdditionalDataSource()
         dataSource = @_getComponentProp(@_IMPLEMENTED_PROPS.dataSource)

         dataSource.additional.directRequest

   ###*
   * Функция считывания ответа. Если для считывания экземпляров задан составной
   *  ключ - перебирает параметры этого ключа и для каждого пытается считать
   *  значения из ответа, при этом добавляя дополнительные параметры в записи.
   *
   * @param {Array, Object} records - набор выбранных записей или запись.
   * @param {Object, String} resutltKey - ключ считывания или параметры составного
   *                                      ключа считывания.
   * @return {Array, Object} - набор полученных записей или одиночная запись.
   ###
   _getComplexResponse: (records, resultKey) ->
      recordsKey = @_RECORDS_KEY
      fieldsKey = @_FIELDS_KEY
      extEntitiesKey = @_EXT_ENTITIES_KEY
      keyKey = @_KEY_KEY

      ###*
      * Функция добавления дополнительных параметров в хэш параметров записи.
      *
      * @param {Object} record - запись. (выходной параметр)
      * @param {String, undefined} complexDataName - наименование имени поля по составному ключу.
      * @param {String, undefined} alternativeFieldName - наименование альтернативного имени поля.
      * @return
      ###
      setAdditionRecordParams = (record, complexDataName, alternativeFieldName) ->

         if complexDataName?
            record.complexDataName = complexDataName

         if alternativeFieldName?
            record.alternativeFieldName = alternativeFieldName

      # Если ключ считывания составной - перебираем все ключи и добавляем в параметр
      #  записи/записей дополнительные параметры.
      if _.isArray resultKey
         result = []

         for keyParam in resultKey
            key = keyParam.key
            alternativeFieldName = keyParam.alternativeFieldName
            instances = records[key]

            if instances?
               instancesRecords = instances.records

               # Если был получени набор записей, то переберем каждую для добавления
               #  доп. параметров.
               # Если одиночный экземпляр, то добавляем доп. параметры в него.
               if _.isArray instancesRecords
                  for instance, idx in instancesRecords
                     setAdditionRecordParams(instance, key, alternativeFieldName)

                     result.push instance
               else if instancesRecords?
                  setAdditionRecordParams(instancesRecords, key, alternativeFieldName)

                  result.push instancesRecords
      else if resultKey?
         result = records[resultKey]
      else if _.has(records, recordsKey)
         result = records[recordsKey]
      else if _.has(records, keyKey)
         result = records
      else if _.has(records, fieldsKey)
         result =
            fields: records[fieldsKey]
            externalEntities: records[extEntitiesKey]

      result

   ###*
   * Функция формирования адреса получения из адреса справочника и заданного
   *  ключа экземпляра.
   *
   * @param {String} dictionaryUrl - адрес считывания словаря.
   * @param {Number} instanceKey   - ключ экземпляра.
   * @return {String}
   ###
   _getInstanceUrlFromDictionaryUrl: (dictionaryUrl, instanceKey) ->
      if dictionaryUrl? and instanceKey?
         chars = @_CHARS
         pointChar = chars.point
         dictUrlElements = dictionaryUrl.split(pointChar)

         [
            _.head(dictUrlElements)
            chars.slash
            instanceKey
            pointChar
            _.last(dictUrlElements)
         ].join chars.empty

   ###*
   * Функция установки параметров фильтра.
   *
   * @param {Array} selectedRecords - массив выбранных записей. Если на задан
   *                                  берется из состояния компонента.
   * @return
   ###
   _setFilter: (selectedRecords) ->
      dataSource = @_getComponentProp(@_IMPLEMENTED_PROPS.dataSource)
      filterParamsProp = _.cloneDeep(dataSource.dictionary.filter)
      filterParams = filterParamsProp.filter or {}
      selectorInput = @state.selectorInput
      chars = @_CHARS

      # Строим поисковый фильтр, если задано не пустое значение в поле ввода.
      if selectorInput? and selectorInput isnt chars.empty
         filterParams.search = @_constructSearchFilter()

      if @_isNeedAddSelectedItems()
         filterParams[@_START_KEYS_KEY] = @_constructStartKeysFilter(selectedRecords)

      @setState filterParams: filterParams

   ###*
   * Функция-предикат для определения были ли заданы параметры для обозревателя
   *  справочника.
   *
   * @return {Boolean}
   ###
   _isHasDictionaryBrowserParams: ->
      dictionaryBrowserParams = @props.dictionaryBrowserParams

      dictionaryBrowserParams? and !_.isEmpty(dictionaryBrowserParams)

   ###*
   * Функция-предикат для определения наличия в компоненте дополнительных параметров
   *  источника данных.
   *
   * @return {Boolean}
   ###
   _isHasAdditionalDataSource: ->
      dataSource = @_getComponentProp(@_IMPLEMENTED_PROPS.dataSource)

      if dataSource?
         additionalDataSource = dataSource.additional

         return additionalDataSource? and !_.isEmpty additionalDataSource

      false

   ###*
   * Функция-предикат для определения наличия в компоненте параметров прямого запроса.
   *
   * @return {Boolean}
   ###
   _isHasDirectRequestParams: ->
      if @_isHasAdditionalDataSource()
         dataSource = @_getComponentProp(@_IMPLEMENTED_PROPS.dataSource)
         additionalDataSource = dataSource.additional
         directRequestParams = additionalDataSource.directRequest

         return directRequestParams? and !_.isEmpty directRequestParams

      false

   ###*
   * Функция-предикат для определения наличия значения введенного в поле ввода.
   *
   * @return {Boolean}
   ###
   _isHasValueInInput: ->
      selectorInput = @state.selectorInput

      selectorInput? and selectorInput isnt @_CHARS.empty

   ###*
   * Функция-предикат для определения наличия выбранные записей.
   *
   * @return {Boolean}
   ###
   _isHasSelectedRecords: ->
      selectedRecords = @state.selectedRecords

      selectedRecords? and !_.isEmpty selectedRecords

   ###*
   * Функция-предикат для определения необходимости сделать скролл в контейнере
   *  элементов. Проверяет ширину контенера на необходимость скролла.
   *
   * @return {Boolean}
   ###
   _isItemsContainerNeedScroll: ->
      itemsContainer = @refs[@_REFS.itemsContainer]
      containerClientRect = itemsContainer.getBoundingClientRect()
      scrollWidth = itemsContainer.scrollWidth
      scrollLeft = itemsContainer.scrollLeft

      if scrollWidth > Math.ceil(containerClientRect.width)
         return scrollWidth > scrollLeft

      false

   ###*
   * Функция-предикат для определения совпадания/различия двух наборов выбранных
   *  записей (например текущих и предыдущих). Получает ключи записей обоих наборов
   *  склеивает их в строку и сравнивает.
   *
   * @param {Array} selectedRecords - набор выбранных записей.
   * @param {Array} comparedSelectedRecords - сравниваемый набор записей.
   * @return {Boolean}
   ###
   _isSelectedRecordsDifferent: (selectedRecords, comparedSelectedRecords) ->
      # currentSelectedKeys =
      #    if currentSelectedKeys? and _.isArray(selectedRecords)
      #       selectedRecords.map (record)->
      #          record.key

      # comparedSelectedKeys =
      #    if comparedSelectedKeys? and _.isArray(comparedSelectedRecords)
      #       comparedSelectedRecords.map (comparedRecord) ->
      #          comparedRecord.key

      # currentSelectedKeys.join() isnt comparedSelectedKeys.join()

      !_.isEqual(selectedRecords, comparedSelectedRecords)


   ###*
   * Функция-предикат для определения задана ли в параметрах рендера контейнера
   *  опция расположения контейнера в одну строку.
   *
   * @return {Boolean}
   ###
   _isItemsContainerInSingleLine: ->
      renderParams =
         @_getElementProps(@_SELECTOR_ELEMENTS.itemsContainer).renderParams

      if renderParams? and !_.isEmpty(renderParams)
         return !!renderParams.isInSingleLine

      false

   ###*
   * Функция-предикат для определения заданы ли дополнительные параметры фильтрации.
   *
   * @return {Boolean}
   ###
   _isExistAdditionFilterParams: ->
      additionFilterParams = @props.additionFilterParams
      additionFilterParams? and !_.isEmpty additionFilterParams

   ###*
   * Функция-предикат для определения задан ли флаг добавления выбранных записей
   *  в фильтр.
   *
   * @return {Boolean}
   ###
   _isNeedAddSelectedItems: ->
      if @_isExistAdditionFilterParams()
         return !!@props.additionFilterParams.isAddingSelectedItems

      false

   ###*
   * Функция-предикат для опредения задана ли возможность выбирать корневую
   *  запись иерархии при выборе дочерней записи.
   *
   * @return {Boolean}
   ###
   _isEnableSelectRootNodeInHierarchy: ->
      dataTableParams = @props.dataTableParams

      if dataTableParams? and !$.isEmptyObject dataTableParams
         hierarchyViewParams = dataTableParams.hierarchyViewParams

         if hierarchyViewParams? and !$.isEmptyObject hierarchyViewParams
            return !!hierarchyViewParams.enableSelectRootOnActivateChild

      false

   ###*
   * Функция-предикат для проверки нахождения целевого узла на этом селекторе.
   *
   * @param {DOM-Node} record - целевой узел DOM.
   * @return
   ###
   _isInThisSelector: (relatedTarget) ->
      $relatedTarget = $(relatedTarget).parents(".#{this._SELECTOR_CLASS_NAME}")
      targetReactId = if $relatedTarget.length
                         ReactDOM.findDOMNode($relatedTarget[0]).dataset.reactid
      currentReactId = ReactDOM.findDOMNode(this).dataset.reactid


      isTargetElement = targetReactId is currentReactId

      unless isTargetElement
         dictionaryContainer = @refs[@_REFS.dictionaryContainer]
         dictionaryContainerReactId =
            ReactDOM.findDOMNode(dictionaryContainer).dataset.reactid
         targetReactId = ReactDOM.findDOMNode(relatedTarget).dataset.reactid
         isTargetDictionary = targetReactId is dictionaryContainerReactId

      isTargetElement or isTargetDictionary

   ###*
   * Функция-предикат для определения добавлена ли запись по ключу.
   *
   * @param {String, Number} checkedKey - проверяемый ключ записи.
   * @return {Boolean}
   ###
   _isRecordAlreadyAdded: (checkedKey) ->
      selectedRecords = @state.selectedRecords

      if selectedRecords? and !_.isEmpty(selectedRecords)
         for record in selectedRecords
            return true if record.key is checkedKey

      false

   ###*
   * Функция-предикат для определения является ли текущий активный узел
   *  на документе полем ввода.
   *
   * @return {Boolean}
   ###
   _isCurrentActiveNodeInput: ->
      document.activeElement.nodeName is @_INPUT_NODE_NAME

   ###*
   * Обработчик на клик по произвольной области словаря. Останавивает проброс события.
   *
   * @param {React-element} area - ссылка на область.
   * @param {Object} event - объект события.
   * @return
   ###
   _onTerminateAreaClick: (area, event) ->
      event.stopPropagation()

   ###*
   * Обработчик на изменения значений в хранилище. Реагирует на получение ответа
   *  запроса значений выбранных записей.
   *
   * @return
   ###
   _onChange: ->
      lastInteraction = ServiceStore.getLastInteraction()

      if lastInteraction is ActionTypes.SELECTOR_INSTANCES_RESPONSE
         interactionSelectorIdentifier =
            ServiceStore.getLastInteractionSelectorIdentifier()

         # Если изменение в хранилище было по данному селектору - считываем данные
         #  и добавляем в коллекцию.
         if @_componentIdentifier is interactionSelectorIdentifier
            dataSource = @_getComponentProp(@_IMPLEMENTED_PROPS.dataSource)
            dataSourceInstances = dataSource.instances
            resultKey = dataSourceInstances.resultKey
            selectedInstances = ServiceStore.getSelectorInstances()

            result = @_getComplexResponse(selectedInstances, resultKey)

            initRecords = if _.isArray(result)
                             result
                          else if _.has(result, @_KEY_KEY)
                             [result]
                          else
                             [
                                fields: result.fields
                                externalEntities: result.externalEntities
                                key: dataSourceInstances.keys
                             ]

            @_addSelectedRecord(initRecords, false, true)

            # Сохраним в состоянии начальную запись, для возможности сброса значения.
            # Сбросим состояния "запрошены экземпляры" и "запрошены родительские экземпляры".
            @setState
               initRecords: initRecords
               isInstancesRequesting: false
               isParentInstancesRequest: false

   ###*
   * Обработчик клика на кнопку открытия
   *
   * @return
   ###
   _onClickBrowserOpen: ->
      @_showAutoComplete(false, true)

   ###*
   * Обработчик нажатия на клавишу клавиатуре на контейнере данных словаря.
   *  Выполняется отлов событий на перемещения по активируемым записям и при
   *  определенных условиях выполняется перевод фокуса в поле ввода.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onKeyDownDictionary: (event) ->
      if @state.isDictionaryShown
         eventKeyCode = event.keyCode
         keyCodes = @_KEY_CODES
         keyUpCode = keyCodes.up
         keyDownCode = keyCodes.down
         isUpKey = eventKeyCode is keyUpCode
         isCtrlKeyPressed = event.ctrlKey
         isVerticalControlKey = _.includes([keyUpCode, keyDownCode], eventKeyCode)

         # Выполним обработку перемещения по активируемым записям таблицы (
         #  клавишы вверх/вниз). Реагируем на клавишу "вверх" - если клавиша
         #  нажимается в подходящем состоянии словаря выполняется фокусировка
         #  на поле ввода.
         if isVerticalControlKey
            @delay 4, (->
                  dictionaryComponent = @refs[@_REFS.dictionaryTable]
                  currentActivatedRowKey =
                     dictionaryComponent.getActivatedRowKey()
                  isActivatedRowUnchange =
                     currentActivatedRowKey is @state.dictionaryActivatedRowKey

                  # Реагируем на клавишу "вверх". Если активируемая строка неизменялась
                  #  или клавиша вверх нажата с модификатором Ctrl (соглашение) -
                  #  то фокусируемся на поле ввода.
                  if isUpKey and (isActivatedRowUnchange or isCtrlKeyPressed)
                     @_focusOnInput()

                  @setState
                     dictionaryActivatedRowKey: currentActivatedRowKey
               ).bind(this)

   ###*
   * Клика на селектор - переводит фокус на поле ввода, если ещё фокус ещё не поле ввода.
   *
   * @return
   ###
   _onClickSelector: (event) ->
      event.stopPropagation()
      event.preventDefault()

      @_focusOnInput()

   ###*
   * Обработчик фокуса на поле ввода
   *
   * @return
   ###
   _onFocusInput: ->
      unless @state.isInInput
         # запустим анимацию
         @_glowIn()

         @setState isInInput: true

   ###*
   * Обработчик на потерю фокуса на поле ввода
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onBlurInput: (event) ->
      selector = this
      # Костыль для Firefox - он некорректно возвращает event.relatedTarget. Поэтому
      #  для него нужно через таймаут взять активный элемент в документе и уже
      #  на его основе запустить обработку потери фокуса.
      if event.relatedTarget?
         selector._blurProcess(event.relatedTarget)
      else
         @delay 4, ->
            selector._blurProcess(document.activeElement)

      @setState isInInput: false

   ###*
   * Обработчик на нажатие клавиши клавиатуры в поле ввода.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onKeyDownInput: (event) ->
      keyCodes = @_KEY_CODES
      eventKeyCode = event.keyCode
      downKeyCode = keyCodes.down
      enterKeyCode = keyCodes.enter

      # Если нажали "Enter" - отправим прямой запрос.
      # Если кнопку "вниз" - откроем справочник (если не был открыт).
      #                      или сфокусируемся на справочнике
      #                      (если был открыт) (для передачи управления).
      switch eventKeyCode
         when keyCodes.enter
            @_sendDirectRequest()
         when keyCodes.down
            event.stopPropagation()
            event.preventDefault()

            if @state.isDictionaryShown
               @_activateDictionary()
            else
               @_showAutoComplete(false, false)

   ###*
   * Обработчик клика по кнопке показа скрытых элементов. Устанавливает целевой
   *  узел, если он ранее не был установлен.
   *
   * @return
   ###
   _onClickShowAllSelectedElements: ->
      unless @state.allSelectedElementsTarget?
         @setState allSelectedElementsTarget: @refs[@_REFS.selector]

   ###*
   * Обработчик на скрытие области со всеми выбранными элементами. Сбрасывает целевой
   *  узел для области.
   *
   * @return
   ###
   _onHideAllSelectedElementsArea: ->
       @setState allSelectedElementsTarget: null

   ###*
   * Обработчик на скрытие области автодополнения. Устанавливает
   *  флаг показанного словаря.
   *
   * @return
   ###
   _onShowArea: ->
      @_focusOnInput()
      @setState isDictionaryShown: true

   ###*
   * Обработчик на скрытие области автодополнения. Сбрасывает целевой узел и флаг
   *  показанной области.
   *
   * @return
   ###
   _onHideArea: ->
      # Сфокусируемся на поле ввода, если текущий активный узел на документе
      #  не поле ввода.
      @_focusOnInput() unless @_isCurrentActiveNodeInput()

      @setState
         collectionTarget: null
         isDictionaryShown: false

   ###*
   * Обработчик на потерю фокуса области со справочником.
   *
   * @param {DOM-Object} - целевой узел потери фокуса.
   * @return
   ###
   _onBlurArea: (relatedTarget) ->
      @_blurProcess relatedTarget

   ###*
   * Обработчик на клик по кнокпе очистки селектора. Очищает все значения -
   *  выбранные записи, введенное в поле ввода значение.
   *
   * @return
   ###
   _onClickClearSelector: ->
      emptySelectedRecords = []

      @_setFilter emptySelectedRecords

      @_handleOnChangeProcess emptySelectedRecords

      @setState
         selectedRecords: emptySelectedRecords
         selectorInput: ''
         isInstancesRequesting: false
         isParentInstancesRequest: false

   ###*
   * Обработчик на клик по кнопке показа справочника автодополнения.
   *
   * @param {String} value    - значение в поле ввода.
   * @param {Event-obj} event - объект события.
   * @return
   ###
   _onClickShowCollection: (value, event) ->
      event.stopPropagation()
      @_showAutoComplete()

   ###*
   * Обработчик на изменение значения в поле ввода.
   *
   * @param {String} value - значение в поле ввода.
   * @return
   ###
   _onChangeInputSelector: (value)->
      clearTimeout @_autoCompleteTimeoutIdentifier
      actionTimeout = @_AUTO_COMPLETE_TIMEOUT
      selector = this
      chars = @_CHARS

      if !@state.isDictionaryShown and (value? and value isnt chars.empty)
         @_autoCompleteTimeoutIdentifier =
            @delay actionTimeout, ->
               selector._showAutoComplete(true)
      else
         @_autoCompleteTimeoutIdentifier =
            @delay actionTimeout, ->
               selector._setFilter()

      @setState selectorInput: value

   ###*
   * Обработчик на клик по кнопке удаления выбранного элемента.
   *
   * @param {Object} removedRecord - удаляемая запись.
   * @return
   ###
   _onClickRemoveRecord: (removedRecord) ->
      selectedRecords = @state.selectedRecords[..]
      removedKey = removedRecord.key

      for record, idx in selectedRecords
         if record.key is removedKey
            selectedRecords.splice idx, 1
            break

      @_setFilter selectedRecords

      @_handleOnChangeProcess selectedRecords

      @_focusOnInput()

      @setState selectedRecords: selectedRecords

   ###*
   * Обработчик на выбор значения из справочника.
   *
   * @param {Object} recordData - параметры добавляемой записи(ей).
   * @param {String} complexDataName - имя ключа доступа к составным данным.
   * @return
   ###
   _onSelectValue: (recordData, complexDataName) ->
      if complexDataName?
         dataSource = @_getComponentProp(@_IMPLEMENTED_PROPS.dataSource)
         dictionaryDataSource = dataSource.dictionary

         recordData.complexDataName = complexDataName if complexDataName?

         # Проверим не задано ли для активного выбранного источника данных в параметрах
         #  альтренативного имени поля формы. Если задано - сохраняем в параметрах
         #  выбранной записи.
         if dictionaryDataSource?
            resultKey = dictionaryDataSource.resultKey

            if resultKey? and _.isArray resultKey
               for resKeyParam in resultKey
                  if resKeyParam.key is complexDataName
                     alternativeFieldName = resKeyParam.alternativeFieldName

                     if alternativeFieldName?
                        recordData.alternativeFieldName = alternativeFieldName

                     break

      @_sendFirstChoiseRequest(recordData)

      if @_isEnableSelectRootNodeInHierarchy()
         rootRecord = recordData.rootRecord
         record = recordData.record
         selectedRecords = @_addSelectedRecord [rootRecord, record]
      else
         selectedRecords = @_addSelectedRecord recordData

      if @props.enableMultipleSelect
         selector = this

         @delay @_FICTITIOUS_TIMEOUT, ->
            selector._setFilter(selectedRecords)
      else
         @setState collectionTarget: null

   ###*
   * Функция проверки необходимости отправки запроса по первичному выбору. Если
   *  таковые параметры были заданы - отправляет запрос и устанавливает состояния
   *  "запрошены экземпляры" и "запрошены родительские экземпляры" (для добавления
   *  записей в начало набора).
   *
   * @param {Object} recordData - выбранная запись.
   * @return
   ###
   _sendFirstChoiseRequest: (recordData) ->
      if @_isHasAdditionalDataSource()
         dataSource = @_getComponentProp(@_IMPLEMENTED_PROPS.dataSource)
         additionalDataSource = dataSource.additional
         firstChoiceRequest = additionalDataSource.firstChoiceRequest
         selectedRecords = @state.selectedRecords
         isNoSelectedRecords = !selectedRecords or !selectedRecords.length
         recordKey = recordData.key

         # Если заданы параметры для запроса первичного выбора и пока не было
         #  ни одной записи и задан ключ выбранной записи.
         if firstChoiceRequest? and isNoSelectedRecords and recordKey?
            firstChoiceRequestUrl = firstChoiceRequest.url
            firstChoiceRequestFilter = firstChoiceRequest.filter or {}
            firstChoiceRequestFilter.start_keys = [recordKey]

            # Если задан адрес запроса.
            if firstChoiceRequestUrl?
               # Отправим запрос на получение родительских записей от текущей.
               ServiceActionCreators.getSelectorInstances firstChoiceRequestUrl,
                                                          @_componentIdentifier,
                                                          firstChoiceRequestFilter

               # Установим состояние "экземпляры зарошены" и состояния запроса родительских
               #  записей (они должны быть добавлены в начало набора).
               @setState
                  isInstancesRequesting: true
                  isParentInstancesRequest: true

   ###*
   * Функция отправки прямого запроса в БЛ, без выбора из словаря.
   *
   * @return
   ###
   _sendDirectRequest: ->
      directRequestParams = @_getDirectRequestParams()

      # И заданы параметры "прямого запроса".
      if directRequestParams? and !_.isEmpty directRequestParams
         directRequestUrl = directRequestParams.url
         directFilterParams = directRequestParams.filter or {}
         directFilterParams.search = @_constructSearchFilter()

         if directRequestUrl?
            # Отправим запрос на распознавание адресной строки.
            ServiceActionCreators.getSelectorInstances directRequestUrl,
                                                       @_componentIdentifier,
                                                       directFilterParams

            # Удалим таймаут показа автодополнения.
            clearTimeout @_autoCompleteTimeoutIdentifier

            # Установим состояние "экземпляры зарошены".
            @setState isInstancesRequesting: true

   ###*
   * Функция прокрутки контейнера выбранных элеметнов до конца вправо (все выбранные
   *  элементы сдвигаются влево, частично скрываясь).
   *
   * @return
   ###
   _scrollContainerToRight: ->
      itemsContainer = @refs[@_REFS.itemsContainer]
      itemsContainer.scrollLeft = itemsContainer.scrollWidth

   ###*
   * Функция обработки потери фокуса областью. Проверяет целевой узел на нахождение
   *  в той же компоненте.
   *
   * @param {DOM-Object} relatedTarget - целевой узел фокуса.
   * @return
   ###
   _blurProcess: (relatedTarget) ->
      return if @_isInThisSelector(relatedTarget)

      # Запустим выход из анимации.
      @_glowOut()
      @setState collectionTarget: null

   ###*
   * Функция фокусировки на селекторе.
   *
   * @return
   ###
   _focusOnInput: ->
      unless @state.isInInput
         refs = @_REFS
         @refs[refs.selectorInput].refs[refs.input].focus()

   ###*
   * Функция фокусировки на компоненте таблицы.
   *
   * @return
   ###
   _activateDictionary: ->
      if @state.isDictionaryShown
         refs = @_REFS
         @refs[refs.dictionaryTable].initKeyManipulation()

   ###*
   * Функция показа автодополнения. Подгатавливает параметры фильтрации для автодополнения,
   *  если что-то введено в поле ввода и задает целевой узел для поля.
   *
   * @param {Boolean} isKeepOpenedDictionary - флаг оставления открытым справочника.
   *                                           Параметр нужен для того чтобы при открытом
   *                                           справочнике-автодополнении применять новые поисковые
   *                                           фильтры.
   * @param {Boolean} isBrowserMode          - флаг открытия справочника в режиме браузера
   *                                           (в отдельном окне в режиме дока) с полноценной
   *                                           таблицей, в возможностью фильтрации.
   * @return
   ###
   _showAutoComplete: (isKeepOpenedDictionary, isBrowserMode) ->
      selectorComponent = @refs.selector
      target = selectorComponent

      # Если не задан флаг сохранения открытого справочника-автодополения, то
      #  переключим целевой узел.
      unless isKeepOpenedDictionary
         target = if @state.collectionTarget?
                     null
                  else
                     selectorComponent

      @_setFilter()

      @setState
         collectionTarget: target
         isDictionaryInBrowserMode: isBrowserMode

   ###*
   * Функция конструирования строки наименования выбранного элемента. Если заданы
   *  параметра рендера элемента - применяет правила форматирования,
   *  иначе пытается вывести имя (если она задано) или просто выводит ключ.
   *
   * @param {Object} record       - параметры записи.
   * @param {Object} renderParams - параметры рендера выбранного экземпляра.
   * @return {String}
   ###
   _constructItemCaption: (record, renderParams) ->
      isRenderParamsAssigned = renderParams? and _.isPlainObject renderParams
      caption = null
      ###*
      * Функция-предикат для определения является ли параметры рендера выбранного
      *  экземпляра простыми (заданы параметры шаблона и полей).
      *
      * @param {Object} params - пармаетры рендера.
      * @return {Boolean}
      ###
      isSimpleParams = ((params) ->
         instanceRenderKeys = @_INSTANCE_RENDER_KEYS
         templateKey = instanceRenderKeys.template
         fieldsKey = instanceRenderKeys.fields
         arbitraryKey = instanceRenderKeys.arbitrary

         _.has(params, templateKey) and
            (_.has(params, fieldsKey) or _.has(params, arbitraryKey))
      ).bind(this)

      ###*
      * Функция получения массива значений по заданным полям из выбранной записи.
      *
      * @param {Array} - массив имен полей, которые нужно выбрать из полей записи.
      * @param {Object} record - параметры записи.
      * @return {Array} - массив значений.
      ###
      getRenderedFieldsValue = (fields, record) ->
         keyField = @_KEY_FIELD
         recordFields = record.fields

         if recordFields?
            fields.map (fieldName) ->
               recordField = recordFields[fieldName]

               if fieldName is keyField
                  record.key
               else if recordField?
                  recordField.value

      ###*
      * Функция получения значение произвольного доступа к элементам записи.
      *
      * @param {Array<Object>} arbitrary - параметры произвольного доступа.
      * @param {Object} record - запись.
      * @return {Array}
      ###
      getRenderedArbitraryValue = (arbitrary, record) ->

         ###* Функция для обработки параметра произвольного доступа.
         *  Вызывается для каждого элемента в наборе произвольных
         *  параметров выбора, а также рекурсивно для каждой из альтернатив, если
         *  не было найдено значение.
         *
         * @param {Object} atbitraryParams - параметры произвольног выбора.
         * @return {String, undefined}     - выбранное значение.
         ###
         processArbitrary = (arbitraryParams) ->
            arbitraryChain = arbitraryParams.chain
            arbitraryTemplate = arbitraryParams.template
            arbitraryValue = _.get(record, arbitraryChain)
            arbitraryAlternatives = arbitraryParams.alternatives

            if arbitraryValue?
               if arbitraryTemplate?
                  format(arbitraryTemplate, arbitraryValue)
               else
                  arbitraryValue
            else if arbitraryAlternatives? and !_.isEmpty(arbitraryAlternatives)
               for alternative in arbitraryAlternatives
                  altValue = processArbitrary(alternative)

                  break if altValue?
               altValue

         arbitrary.map processArbitrary

      # Если параметры рендера экземпляров заданы
      if isRenderParamsAssigned

         # Если это простые параметры (поля и шаблон) - продолжаем работу с ними.
         # Иначе - пробуем получить параметры рендера по имени составлых данных,
         #  к которым принадлежит выбранная запись(если задано).
         if isSimpleParams(renderParams)
            renderTemplate = renderParams.template
            renderFields = renderParams.fields
            renderArbitrary = renderParams.arbitrary

            recordValues =
               if renderFields?
                  getRenderedFieldsValue(renderFields, record)
               else
                  getRenderedArbitraryValue(renderArbitrary, record)

            caption = format renderTemplate, recordValues
         else
            complexDataName = record.complexDataName

            if complexDataName?
               captionRenderParams = renderParams[complexDataName]

               # Если параметры рендера выбранного значения удалось получить и это
               #  простые данные рендера (шаблон и значения) - формируем выбранное значение.
               if captionRenderParams? and isSimpleParams.call(this, captionRenderParams)
                  renderTemplate = captionRenderParams.template
                  recordValues =
                     getRenderedFieldsValue(captionRenderParams.fields, record)

                  caption = format renderTemplate, recordValues

      # Если не удалось сформировать заголовок по заданным правилам (или они не были заданы),
      #  то формируем стандартным образом - пробуем взять имя в наборе записей или ключ записи.
      unless caption?
         recordFields = record.fields

         caption =
            if recordFields? and recordFields.name?
               recordFields.name.value or record.key
            else
               record.key
      caption

   ###*
   * Функция конструирования параметров фильтра по начальным записям иерархии.
   *
   * @param {Array} selectedRecords - массив выбранных записей.
   ###
   _constructStartKeysFilter: (selectedRecords) ->

      selectedRecords ||= @state.selectedRecords
      isAddingOnlyRoot = @props.additionFilterParams.isAddingSelectedItemsOnlyRoot

      if selectedRecords? and selectedRecords.length
         if isAddingOnlyRoot
            [selectedRecords[0].key]
         else
            selectedRecords.map (rec)->
               rec.key

   ###*
   * Функция конструирования параметров поисковой фильтрации. Если поисковые параметры
   *  филтрации не заданы через свойства компонента - берет значения по-умолчанию.
   *
   * @return {Object, undefined} - параметры поисковой фильтрации.
   ###
   _constructSearchFilter: ->
      selectorInput = @state.selectorInput
      dataSource = @_getComponentProp(@_IMPLEMENTED_PROPS.dataSource)
      # if selectorInput isnt ''
      propFilterParams = dataSource.dictionary.filter
      searchFields = @_DEFAULT_FILTER_SEARCH_FIELDS
      searchFilter = {}

      # Если заданы пользовательские параметры поискового фильтра
      if propFilterParams? and !_.isEmpty propFilterParams
         searchParams = propFilterParams.search

         # Если заданы параметры поискового запроса - считываем переданные параметры.
         if searchParams? and !_.isEmpty searchParams
            searchFields = searchParams
            # searchParamsField = searchParams.field
            # searchParamsCondition = searchParams.condition

            # if searchParamsField
            #    searchField = searchParamsField

            # if searchParamsCondition
            #    searchCondition = searchParamsCondition

      searchFilter = searchFields
      searchFilter.expr = selectorInput

      searchFilter

   ###*
   * Функция добавления новой записи(ей) в коллекцию выбранных.
   *
   * @param {Object, Array} recordData - добавляемая запись/массив добавляемых записей.
   * @param {Boolean} isReset          - флаг сброса значений к переданному.
   * @param {Boolean} isInitSet        - флаг начальной установки.
   * @return {Array} - массив выбранных записей.
   ###
   _addSelectedRecord: (recordData, isReset, isInitSet) ->
      isRecordDataArray = _.isArray(recordData)

      if isReset
         newSelectedRecords = if isRecordDataArray
                                 recordData
                              else
                                 [recordData]


      else if @props.enableMultipleSelect
         newSelectedRecords = @state.selectedRecords[..]
         isParentInstancesRequest = @state.isParentInstancesRequest
         isRecordAdded = false

         if recordData?
            # Если записи были переданы массивом - перебираем каждую запись
            #  проверяем не была ли она уже добавлена.
            if _.isArray recordData

               if isParentInstancesRequest
                  for idx in [recordData.length-1..0]
                     record = recordData[idx]

                     if record? and !@_isRecordAlreadyAdded record.key
                        newSelectedRecords.unshift record

                        isRecordAdded = true
               else
                  for record in recordData
                     if record? and !@_isRecordAlreadyAdded record.key
                        newSelectedRecords.push record

                        isRecordAdded = true
            else if !@_isRecordAlreadyAdded(recordData.key)
               if isParentInstancesRequest
                  newSelectedRecords.unshift recordData
               else
                  newSelectedRecords.push recordData

               isRecordAdded = true

         # Не обрабатываем, если ни одной записи не было добавлено.
         return unless isRecordAdded
      else
         record = if isRecordDataArray
                     recordData[0]
                  else
                     recordData

         # Не обрабатываем, если значение выбранных записей не сбрасывается
         #  или запись уже добавлена.
         return if @_isRecordAlreadyAdded(record.key)

         newSelectedRecords = [record]

      @_handleOnChangeProcess(newSelectedRecords, isInitSet)

      @setState
         selectedRecords: newSelectedRecords
         selectorInput: ''

      newSelectedRecords

   ###*
   * Обработчик события на изменение значение в поле селектора. Оповещает
   *  подписанный обработчик (если он задан) о произошедшем событии и отправляет
   *  выбранные значения.
   *
   * @param {Array} selectedRecords - выбранные значения.
   * @param {Boolean} isInitSet     - флаг начальной установки.
   * @return
   ###
   _handleOnChangeProcess: (selectedRecords, isInitSet) ->
      # Если есть обработчик на изменение выбранных записей - отправим новые
      #  выбранные записи и флаг начальной установки.
      onChangeHandler = @props.onChange
      onChangeHandler(selectedRecords, !!isInitSet) if onChangeHandler

module.exports = Selector
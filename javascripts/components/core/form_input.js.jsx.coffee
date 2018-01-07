###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* HelpersMixin     - функции-хэлперы для компонентов.
* ValidatorsMixin  - модуль валидаторов.
* MoneyFormatterMixin - модуль для форматирования денежного значения.
* HierarchyMixin   - модуль для задания иерархии компонентов.
* AnimationsMixin  - модуль анимаций.
* AnimateMixin     - модуль добавляющий поведение анимации.
* PureRenderMixin  - модуль для "чистого" рендера компонента.
* keymirror        - модуль для генерации "зеркального" хэша.
* lodash           - модуль служебных операций.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
ValidatorsMixin = require('../mixins/validators')
MoneyFormatterMixin = require('../mixins/money_formatter')
HierarchyMixin = require('../mixins/hierarchy_components')
AnimationsMixin = require('../mixins/animations')
AnimateMixin = require('react-animate')
PureRenderMixin = React.addons.PureRenderMixin
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты.
* Button       - кнопка.
* DropDown     - выпадающий список.
* Input        - поле ввода.
* Selector     - поле выбора.
* FileUploader - поле загрузки файла.
###
Button = require('components/core/button')
DropDown = require('components/core/dropdown')
Input = require('components/core/input')
Selector = require('components/core/selector')
FileUploader = require('components/core/file_uploader')

###* Константы
* _COLORS               - цвета
* _COMMON_PADDING       - значение отступа
* _COMMON_BORDER_RADIUS - значение скругления углов, alias - _CBR
* _ICON_CONTAINER_WIDTH - общая ширина ячеек с иконками
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius
_CBR = [_COMMON_BORDER_RADIUS, 'px'].join('')
_ICON_CONTAINER_WIDTH = constants.iconContainerWidth

###* Компонент: Поле ввода для форм. Представляет собой поле ввода,
*  заданного типа, с валидацией вводимых данных.
*
* @props:
*     {Object} field         - хэш параметров поля. Вид:
*           {String} type          - тип поля.
*           {String} name          - имя поля (в БД).
*         {String} identifyingName - идентифицирующее имя - для получения реализаций
*                                    из хранилища реализаций.
*           {String} value         - значение в поле.
*           {String} caption       - локализованное имя поля.
*           {String} defaultValue  - значение по-умолчанию.
*           {Array} validators     - массив валидаторов поля.
*           {Array} enumValues     - массив значений поля (список).
*           {Boolean} isPrimaryKey - флаг поля по первичному ключу.
*           {Boolean} isHidden     - флаг принудительно скрываемого поля.
*           {Boolean} isReadOnly   - флаг поля только для чтения.
*     {Object} reflectionRenderParams - хэш параметров рендера поля выборки.
*     {Object} uploadParams    - параметры загрузки файла(если это поле для загрузки файла).
*     {Object} leadIcon        - параметры лидирующей иконки.
* {Number, String, Object}
*                   selectedKey- выбранный ключ(ключи). Параметр актуален, если в качестве
*                                значения в поле задан хэш значений вида:
*                                {key1: value1, key2: value2}.
*     {String, Number} updateIdentifier - идентификатор обновляемого экземпляра в форме, в которой
*                                         находится данное поле (для проведения валидации).
*    {Object} implementationStore - хранилище стандартных реализаций.
*   {Object} dictionaryParam - параметры словаря для поля выбора. (параметры для таблицы +
*                              некоторые параметры для поля выбора).
*     {Object} modelParams   - параметры модели по которому создаётся поле.
*                              (для корректного формирования значений формы). Вид:
*                     {String} name - имя экземпляра модели, по которому заполняется поле.
*                     {Array<Object>} chain - массив параметров свзки. Вид элемента:
*                          {String} reflection - имя связки.
*                          {String} caption    - заголовок связки (локализованное название).
*                          {Number} index - индекс экземпляра в наборе.
*                          {Number, String} recordKey - ключ существующего экземпляра.
*                          {Boolean} isCollection - флаг коллекции.
*                    {Boolean} isInstancesSelector - флаг того, что поле является полем
*                              выбора существующих экземпляров (влияет на формирование имени).
*     {String} title         - всплывающая подсказка на поле.
*     {Number} tabIndex      - индекс таба для задания последовательности перехода
*                              по клавише "Tab".
*     {String} placeholder   - значение в поле ввода при пустом значении.
*     {Boolean} isAddAttributesSuffixForChain - флаг добавления суффикса '_attributes' к именам
*                                               родительских сущностей в цепи родителей при формировании
*                                               имен полей. По-умолчанию = true.
*     {Boolean} isUseImplementation - флаг использования хранилищ реализаций.
*     {Boolean} isImplementationHigherPriority - флаг более приоритетных свойств из хранилища реализаций.
*                                               Нужен для переопределения свойств, заданных по-умолчанию.
*                                               (по-умолчанию = false).
*     {Boolean} isMergeImplementation - флаг "слияния" свойств компонента со свойствами, заданными в
*                                       хранилище реализаций. (по-умолчанию = false)
*     {Boolean} isReset      - флаг того, что поле должно быть сброшено (очищено
*                              значение и сброшены признаки валидации).
*     {Boolean} isNeedValidation - флаг необходимости валидации. По-умолчанию = true.
*     {Boolean} isResetSelectedValue - флаг необходимости очистки значения в поле. Актуально
*                                      для полей в параметрх у которых задано значение.
*     {Boolean} isKeyHidden  - флаг создания только скрытого поля, если в параметре поля
*                              задан флаг isPrimaryKey. По умполчанию = false.
*     {Boolean} isUploader   - флаг-идентификатор поля загрузки файла.
*                              По-умолчанию = false.
*     {Function} onChange    - обработчик на изменеие значения в поле. Аргументы:
*                              {Array, Object, String, Number} selectedValue - выбранное значение.
*                              {Object} field                                - парметры поля.
*                              {String} name                                 - имя поля.
*                              {Boolean} isInitSet                           - флаг начальной установки
*                                                                              значения в поле.
*     {Function} onClear     - обработчик на очистку поля. Аргументы:
*                              {Object} field                                - парметры поля.
*                              {String} name                                 - имя поля.
*     {Function} onInit      - обработчик после монтирования компонента. Аргументы:
*                              {React-Element} field - ссылка на экземпляр.
*     {Function} onDestroy   - обработчик на размонтирование компонента.
*                              Вызывается перед размонтированием.
*                              Аргументы:
*                              {React-Element} field - ссылка на экземпляр.
* @state:
*     {String} selectedValue      - значение в поле.
*     {Number} caretPosition      - позиция каретки в поле ввода.
*     {Boolean} isValidateRequest - флаг того что идет запрос валидации в API.
*     {Boolean} isSelector        - флаг поля-селектора.
*     {Array} validateErrors      - масси ошибок валидации.
* @context:
*     {String, Number} parentIdentifier - идентификатор родительского элемента(для построения
*                                         иерархии компонентов).
* @functions:
*      getValue - Функция получения значения поля.
*         @return {Number, String}
*
*      setValue - Функция установку значение в поле.
*        Аргументы:
*           {String, Number} inputValue - новое входное значение.
*      getFieldParams - Функция получения параметров поля.
*         @return {Object}
*
*      getModelParams -  Функция получения параметров модели поля.
*         @return {Object}
*
*      validate -  Функция запуска валидации поля.
*         @return
###
FormInput = React.createClass
   # @const {String} - выводимая подсказка на иконке запроса (при отправке запроса валидации).
   _VALIDATION_REQUEST_TITLE: 'выполняется валидация'

   # @const {String} - префикс для строк с аттрибутами связанных сущностей.
   _ATTRIBUTES_SUFFIX: 'attributes'

   # @const {String} - префикс для строк для обознач
   _COLLECTION_INSTANCES_SUFFIX: 'ids'

   # @const {Object} - возможные типы полей ввода формы.
   _INPUT_TYPES: keyMirror(
      text: null
      file: null
      number: null
   )

   # @const {Object} - возможные типы полей.
   _FIELD_TYPES: keyMirror(
      string: null
      integer: null
      float: null
      decimal: null
   )

   # @const {Object} - параметры размеров поля выбора
   _SELECTOR_DIMENSION:
      input:
         width:
            min: 150
            max: 300

   # @const {Object} - набор используемых строковых литералов.
   _CHARS:
      empty: ''
      space: ' '
      comma: ','
      point: '.'
      sqBracketStart: '['
      sqBracketEnd: ']'
      underscore: '_'

   # @const {Object} - ключи считывания параметров запроса выбранных экземпляров.
   _INSTANCE_REQUEST_KEYS: keyMirror(
      url: null
      result_key: null
      filter: null
   )

   # @const {Object} - ключи считывания параметров связки для .
   _REFLECTION_KEYS: keyMirror(
      requestingParams: null
      result_key: null
      alternativeFieldName: null
   )

   # @const {Object} - ключ для доступа к параметрам записи
   #                   (для распознания записи).
   _DATA_RECORD_KEYS: keyMirror(
      key: null,
      fields: null
   )

   # @const {Object} - иконки специфичных полей.
   _LEAD_ICON_PARAMS:
      error:
         name: 'exclamation-circle'
         title: 'в поле присутсвуют ошибки'
         type: 'alertLight'
      money:
         name: 'rub'
         type: 'ordinary'
         title: 'рубли'

   # @const {Object} - значения по умолчанию для селектора.
   _SELECTOR_DEFAULTS:
      dictionaryBrowserParams:
         openButton:
            icon: 'external-link'
            position: 'leftIn'
      renderParams:
         browserSpecific:
            dimension:
               common:
                  width:
                     max: 800
               dataContainer:
                  width:
                     max: 800
                  height:
                     min: 400
                     max: 750

   # @const {Number} - костыльный отступ для индексов записей для отделения
   #                   полей новых экземпляров от полей существующих экземпляров.
   # TODO: может позже придумаю способ лучше.
   _CRUTCH_RECORD_INDEX_INDENT: 100

   mixins: [HelpersMixin,
            ValidatorsMixin,
            MoneyFormatterMixin,
            HierarchyMixin.hierarchy.child,
            PureRenderMixin]

   styles:
      tableWrapper:
         width: '100%'
         marginTop: _COMMON_PADDING - 1
         marginBottom: StylesMixin.constants.commonPadding - 3
         # color: StylesMixin.constants.color.hierarchy3
      formInput:
         width: '100%'
         borderWidth: 0
      clearIcon:
         display: 'none'
      clearIconShown:
         cursor: 'pointer'
         display: 'inline'
         paddingRight: _COMMON_PADDING - 2
      exclamationIcon:
         display: 'none'
         paddingLeft: _COMMON_PADDING - 2
         cursor: 'pointer'
         color: _COLORS.alert
      exlamationIconShown:
         display: 'inline'
      loaderIcon:
         display: 'none'
      loaderIconShown:
         display: 'inline-block'


   propTypes:
      field: React.PropTypes.object.isRequired
      reflectionRenderParams: React.PropTypes.object
      leadIcon: React.PropTypes.object
      uploadParams: React.PropTypes.object
      selectedKey: React.PropTypes.oneOfType([
         React.PropTypes.string,
         React.PropTypes.number,
         React.PropTypes.object
      ])
      updateIdentifier: React.PropTypes.oneOfType([
         React.PropTypes.string,
         React.PropTypes.number
      ])
      # value: React.PropTypes.string
      # defaultValue: React.PropTypes.string
      # caption: React.PropTypes.string
      modelParams: React.PropTypes.object
      title: React.PropTypes.string
      tabIndex: React.PropTypes.number
      placeholder: React.PropTypes.string
      isAddAttributesSuffixForChain: React.PropTypes.bool
      isUseImplementation: React.PropTypes.bool
      isImplementationHigherPriority: React.PropTypes.bool
      isMergeImplementation: React.PropTypes.bool
      isReset: React.PropTypes.bool
      isNeedValidation: React.PropTypes.bool
      isResetSelectedValue: React.PropTypes.bool
      isKeyHidden: React.PropTypes.bool
      isHidden: React.PropTypes.bool
      isReadOnly: React.PropTypes.bool
      isUploader: React.PropTypes.bool
      onChange: React.PropTypes.func
      onClear: React.PropTypes.func
      onInit: React.PropTypes.func

   getDefaultProps: ->
      defaultValue: ''
      tabIndex: 1
      isAddAttributesSuffixForChain: true
      isUseImplementation: false
      isImplementationHigherPriority: false
      isMergeImplementation: false
      isNeedValidation: true
      isResetSelectedValue: false
      isReadOnly: false
      isUploader: false

   getInitialState: ->
      isUploader = @props.isUploader
      field = @props.field
      isAddAttributesSuffixForChain = @props.isAddAttributesSuffixForChain
      isSelector = @_isSelector(field)

      fieldName: @_getFieldName(field,
                                isUploader,
                                isSelector,
                                isAddAttributesSuffixForChain)
      selectedValue: @_getInitValue()
      isValidateRequest: false
      validateErrors: []
      isReseted: false
      isSelector: isSelector
      isMoney: field.isMoney
      isTextArea: field.isText

   componentWillReceiveProps: (nextProps) ->
      selectedValue = @state.selectedValue
      newSelectedValue = @_getInitValue(nextProps.field)
      nextPropField = nextProps.field
      isMoneyNext = nextPropField.isMoney
      isSelectorNext = @_isSelector(nextPropField)
      isUploaderNext = nextProps.isUploader
      isAddAttributesSuffixForChainNext =
         nextProps.isAddAttributesSuffixForChain

      # Если поле пока не сброшено и пришел флаг сброса - сбросим
      if nextProps.isReset or !_.isEqual(nextPropField, @props.field)
         @_resetField()

      # Перечитаем флаги.
      @setState
         isSelector: isSelectorNext
         isMoney: isMoneyNext
         fieldName: @_getFieldName(nextPropField,
                                   isUploaderNext,
                                   isSelectorNext,
                                   isAddAttributesSuffixForChainNext)

      # # Если новое значение в поле отличается от предыдущего, то
      # #  устанавливаем в состояние новое значение.
      # if newSelectedValue isnt selectedValue
      #    @setState selectedValue: newSelectedValue

   render: ->
      field = @props.field
      isHiddenField = @_isHiddenField()
      isReadOnly = field.isReadOnly
      isResetSelectedValue = @props.isResetSelectedValue
      isUploader = @props.isUploader
      isSelector = @state.isSelector
      isListField = field.enumValues?
      fieldName = @state.fieldName
      selectedValue = @state.selectedValue unless isResetSelectedValue

      # Различные поля в зависимости от флагов:
      # 1. Поле с выпадающим списком;
      # 2. Поле загрузки файла;
      # 3. Поле выбора;
      # 4. Скрытое поле;
      # 5. Обычное поле формы.
      if isListField
         @_getDropDown(field,
                       fieldName,
                       selectedValue,
                       isReadOnly,
                       isResetSelectedValue)
      else if isUploader
         @_getUploader(field, fieldName)
      else if isSelector
         @_getSelector(field, fieldName, isReadOnly, isResetSelectedValue)
      else if isHiddenField
         @_getHiddenInput(fieldName, selectedValue)
      else
         @_getSimpleInput(field, fieldName, selectedValue, isReadOnly)

   componentDidUpdate: (prevProps, prevState) ->
      if @state.isReseted
         @setState isReseted: false

   componentWillMount: ->
      onInitHandler = @props.onInit
      onInitHandler this if onInitHandler?

   componentWillUnmount: ->
      onDestroyHandler = @props.onDestroy
      onDestroyHandler this if onDestroyHandler?

   ###*
   * Функция получения значения поля.
   *
   * @return {Number, String}
   ###
   getValue: ->
      isMoney = @state.isMoney
      selectedValue = @state.selectedValue

      # Производим доп. обработку для денежного формата - удаляем наполнители
      #  из строки суммы.
      if isMoney and selectedValue?
         @unformatMoney(selectedValue, @props.field.type)
      else
         selectedValue

   ###*
   * Функция установки значения поля.ы
   *
   * @return {Number, String}
   ###
   setValue: (newValue) ->
      @setState selectedValue: @_getInitValue(null, newValue)

   ###*
   * Функция получения имени поля (построенного на основании заданных параметров
   *  самого поля и параметров модели).
   *
   * @return {String}
   ###
   getName: ->
      @state.fieldName

   ###*
   * Функция получения параметров поля.
   *
   * @return {Object}
   ###
   getFieldParams: ->
      @props.field

   ###*
   * Функция получения параметров модели поля.
   *
   * @return {Object}
   ###
   getModelParams: ->
      @props.modelParams

   ###*
   * Функция запуска валидации поля.
   *  Запускает валидацию, из примести validators, передав текущее значение
   *  поля. По завершению валидации должен быть вызван колбэк
   *
   * @param {Function} callback - функция обратного вызова по завершению валидации
   * @return
   ###
   validate: (callback) ->
      @_validate(@state.selectedValue,
                 @props.selectedKey or @props.updateIdentifier
                 callback)

   ###*
   * Функция создания экземпляра поля с выпадающим списком.
   *
   * @param {Object} field - пареметры поля.
   * @param {String} fieldName - имя поля.
   * @param {String, Number, Object} selectedValue - выбранное значение.
   * @param {Boolean} isReadOnly - флаг поля только для чтения.
   * @param {Boolean} isResetSelectedValue - флаг сброса поля.
   * @return {React-DOM-Node} - поле с выпадающим списком.
   ###
   _getDropDown: (field, fieldName, selectedValue, isReadOnly, isResetSelectedValue) ->
      fieldValue = field.value unless isResetSelectedValue

      selectedItem = if _.isPlainObject(selectedValue) and selectedValue.hasOwnProperty('key')
                        selectedValue
                     else
                        key: selectedValue

      `(
         <DropDown title={field.caption}
                   list={field.enumValues}
                   name={fieldName}
                   tabIndex={this.props.tabIndex}
                   initItem={selectedItem}
                   isReset={this.props.isReset}
                   isReadOnly={isReadOnly}
                   isAdaptive={true}
                   enableClear={!isReadOnly}
                   onSelect={this._onChangeInput}
                   onClear={this._onChangeInput}
                />
      )`

   ###*
   * Функция создания экземпляра поля выбора.
   *
   * @param {Object} field                 - пареметры поля.
   * @param {String} fieldName             - сгенерированное имя поля.
   * @param {Boolean} isReadOnly           - флаг поля только для чтения.
   * @param {Boolean} isResetSelectedValue - флаг сброса выбранного значения.
   * @return {React-Element} - поле селектора.
   ###
   _getSelector: (field, fieldName, isReadOnly, isResetSelectedValue) ->
      selectorDefaults = @_SELECTOR_DEFAULTS
      requestingParams = @_getSelectorRequestingParams(field)
      selectedKey = @props.selectedKey
      fieldReflection = field.reflection
      fieldCaption = field.caption
      reflectionSelectorParams = fieldReflection.selectorParams

      if reflectionSelectorParams?
         reflectionIdentifyingName = reflectionSelectorParams.identifyingName
         reflectionDictionaryParams =
            reflectionSelectorParams.dictionaryParams

      identifyingName = field.identifyingName or
                     reflectionIdentifyingName or
                     field.name or field.reflectionName
      dictionaryRequestingParams = requestingParams.dictionary
      instanceRequestingParams = requestingParams.instance
      additionRequestingParams = requestingParams.addition
      dictionaryParams = _.cloneDeep(
         @props.dictionaryParams or reflectionDictionaryParams
      )
      selectorRenderParams = @props.reflectionRenderParams
      instanceRequestKeys = @_INSTANCE_REQUEST_KEYS
      instanceUrlKey = instanceRequestKeys.url
      instanceResultKeyKey = instanceRequestKeys.result_key
      instanceFilterKey = instanceRequestKeys.filter
      fieldValue = field.value
      selectorPresetRecords = @_getSelectorPresetParams(field)
      browserSpecificRenderParams = selectorDefaults.renderParams.browserSpecific

      # Считываем параметры рендера компонентов поля выбора.
      if selectorRenderParams?
         instanceRenderParams = selectorRenderParams.instance
         itemsContainerRenderParams = selectorRenderParams.itemsContainer
         dictionaryRenderParams = selectorRenderParams.dictionary
         browserSpecificRenderParams = _.merge(
            browserSpecificRenderParams,
            selectorRenderParams.browserSpecific
         )

      # Считываем параметры словаря поля выбора.
      if dictionaryParams?
         enableMultipleSelect = !!dictionaryParams.enableMultipleSelect
         enableConsistentClear = dictionaryParams.enableConsistentClear
         additionFilterParams = dictionaryParams.additionFilterParams
         dataTableParams = dictionaryParams.dataTableParams

      # Если заданы параметры считывания экземпляра(ов) поля выбора.
      if instanceRequestingParams? and !_.isEmpty instanceRequestingParams
         instanceUrl = null

         # Считываем URL получения выбранного экземпляра.
         if _.has(instanceRequestingParams, instanceUrlKey)
            requestingUrl = instanceRequestingParams[instanceUrlKey]
            requestingFilter = instanceRequestingParams[instanceFilterKey]

            # Если был задан ключ выбранной записи и при этом
            #  URL считывания - это хэш - получаем адрес по заданному ключу.
            unless isResetSelectedValue
               instanceUrl = requestingUrl
               instanceFilter = requestingFilter
               instanceKey = fieldValue

               # Если заданы выбранный ключ(ключи) экземпляров - формируем параметры
               #  считывания параметров экземпляра.
               if selectedKey?
                  if _.isPlainObject requestingUrl
                     instanceUrl = requestingUrl[selectedKey]

                  if _.isPlainObject fieldValue
                     instanceKey = fieldValue[selectedKey]

         # Если задан ключ считывания результата - получим значение.
         instanceResultKey =
            if _.has(instanceRequestingParams, instanceResultKeyKey)
               instanceRequestingParams[instanceResultKeyKey]
      else if fieldValue?
         instanceKey =
            if _.isArray(fieldValue) and !_.isEmpty(fieldValue)
               fieldValue
            else
               [fieldValue]

      if !_.isPlainObject dataTableParams
         dataTableParams = {}

      # Зададим наименование модели если задано для поля.
      if fieldReflection? and fieldReflection.name?
         dataTableParams.modelParams =
            name: fieldReflection.name

      `(
         <Selector name={fieldName}
                   identifyingName={identifyingName}
                   caption={fieldCaption}
                   placeholder={this.props.placeholder}
                   presetRecords={selectorPresetRecords}
                   implementationStore={this.props.implementationStore}
                   dictionaryBrowserParams={selectorDefaults.dictionaryBrowserParams}
                   dataSource={
                     {
                        dictionary: {
                           url:       dictionaryRequestingParams.url,
                           filter:    {
                              filter: dictionaryRequestingParams.filter
                           },
                           resultKey: dictionaryRequestingParams.result_key
                        },
                        instances: {
                           url:       instanceUrl,
                           filter:    instanceFilter,
                           resultKey: instanceResultKey,
                           keys:      instanceKey,
                        },
                        additional: additionRequestingParams
                     }
                   }
                   renderParams={
                     {
                        input: {
                           dimension:  this._SELECTOR_DIMENSION.input
                        },
                        itemsContainer: itemsContainerRenderParams,
                        instance: instanceRenderParams,
                        dictionary: dictionaryRenderParams,
                        browserSpecific: browserSpecificRenderParams
                     }
                   }
                   isUseImplementation={this.props.isUseImplementation}
                   isImplementationHigherPriority={this.props.isImplementationHigherPriority}
                   isMergeImplementation={this.props.isMergeImplementation}
                   isReinit={this.state.isReseted}
                   isReadOnly={isReadOnly}
                   isAdaptive={true}
                   tabIndex={this.props.tabIndex}
                   dataTableParams={dataTableParams}
                   additionFilterParams={additionFilterParams}
                   enableMultipleSelect={enableMultipleSelect}
                   enableConsistentClear={enableConsistentClear}
                   onChange={this._onChangeInput}
               />
       )`

   ###*
   * Функция создания экземпляра поля загрузки файла.
   *
   * @param {Object} field - пареметры поля.
   * @param {String} fieldName - имя поля.
   * @return {React-DOM-Node} - поле загрузки файла.
   ###
   _getUploader: (field, fieldName) ->
      uploadParams = @props.uploadParams

      if uploadParams? and !_.isEmpty uploadParams
         uploadFieldName = uploadParams.upload_field_name
         uploadUrl = uploadParams.upload_url
         instanceUrl = uploadParams.instance_url

      `( <FileUploader name={fieldName}
                       attachment={field.value}
                       uploadFieldName={uploadFieldName}
                       uploadEndpoint={uploadUrl}
                       instanceEndpoint={instanceUrl} /> )`

   ###*
   * Функция создания экземпляра поля скрытого поля формы.
   *
   * @param {String} fieldName - имя поля.
   * @param {string, Number, Object} - значение в поле.
   * @return {React-DOM-Node} - скрытое поле формы.
   ###
   _getHiddenInput: (fieldName, selectedValue) ->
      `(<input type='hidden'
               name={fieldName}
               value={selectedValue} />)`

   ###*
   * Функция создания экземпляра простого поля ввода.
   *
   * @param {String} field - параметры поля.
   * @param {String} fieldName - имя поля.
   * @param {String, Number, Object} selectedValue - заданное значение в поле.
   * @param {Boolean} isReadOnly - флаг поля только для чтения.
   * @return {React-DOM-Node} - простое поле ввода.
   ###
   _getSimpleInput: (field, fieldName, selectedValue, isReadOnly) ->
      fieldTypes = @_FIELD_TYPES
      inputTypes = @_INPUT_TYPES
      fieldType = field.type
      decimalDimension = field.decimalDimension
      isMoney = @state.isMoney
      isReadOnly ||= field.isReadOnly

      # Если тип поля не задан или это String - зададим тип text.
      if !fieldType or (fieldType is fieldTypes.string) or isMoney
         fieldType = inputTypes.text
      else if fieldType is fieldTypes.integer
         fieldType = inputTypes.number
      else if fieldType in [fieldTypes.float, fieldTypes.decimal]
         fieldType = inputTypes.number

      `(
         <Input type={fieldType}
                name={fieldName}
                placeholder={this.props.placeholder}
                title={this.props.title}
                tabIndex={this.props.tabIndex}
                decimalDimension={decimalDimension}
                enableCaretControl={isMoney}
                caretPosition={this.state.caretPosition}
                onChange={this._onChangeInput}
                onBlur={this._onBlurInput}
                onClear={this._onClearInput}
                value={selectedValue}
                loaderIconTitle={this._VALIDATION_REQUEST_TITLE}
                isAjaxRequest={this.state.isValidateRequest}
                isReadOnly={isReadOnly}
                isTextArea={this.state.isTextArea}
                leadIcon={this._getLeadIconParams()} />
      )`

   ###*
   * Функция получения предучтановленных параметров (выбранные записи) для поля
   *  селектора.
   *
   * @param {Object} field - параметры поля.
   * @return {Object}
   ###
   _getSelectorPresetParams: (field) ->
      fieldValue = field.specific || field.value || field.records

      ###*
      * Функция-предикат для определия является ли значение записью.
      *
      * @param {Object} potentialRecord - потенциальная запись.
      * @return {Boolean}
      ###
      isRecord = ((potentialRecord) ->
         recordKeys = @_DATA_RECORD_KEYS
         keyKey = recordKeys.key
         fieldsKey = recordKeys.fields

         _.has(potentialRecord, keyKey) and _.has(potentialRecord, fieldsKey)
      ).bind(this)

      isValueArray = _.isArray(fieldValue)
      isValueObject = _.isPlainObject(fieldValue)

      isRecordValue =
         if isValueArray
            firstElement = fieldValue[0]
            isRecord(firstElement)
         else if isValueObject
            isRecord(fieldValue)
         else
            false

      if isRecordValue
         if isValueArray
            fieldValue
         else
            [fieldValue]

   ###*
   * Функция построения имени поля формы. В зависимости от типа поля применяет разные
   *  правила формирования имени.
   *
   * @param {Object} field - параметры поля.
   * @param {Boolean} isUploader - это поле загрузки файла.
   * @param {Boolean} isSelector - это поле выбора.
   * @param {Boolean} isAddAttributesSuffix - флаг добавления суффикса для элемента
   *                                          цепи родителей.
   * @retrun {String} - имя поля.
   ###
   _getFieldName: (field, isUploader, isSelector, isAddAttributesSuffix) ->
      reflectionChain = @_getFieldReflectionChain(isAddAttributesSuffix)
      fieldName = field.name
      chars = @_CHARS
      sqBracketEnd = chars.sqBracketEnd
      sqBracketStart = chars.sqBracketStart

      # Если задана модель сконструируем имя поля, чтобы оно входило в хэш модели
      if reflectionChain?

         # Если это загрузчик файлов - из него удалим аттрибуты его модели(немного
         #  костыльный подход, но самый простой)
         if isUploader
            reflectionChain = @_prepareUploaderModelName(reflectionChain)

         # Если задано имя поля и это не селектор для которого заданы альтернативные
         #  имена полей для составных ключей считывания результатов -
         #  cоставим имя поля, так чтобы оно являлось составной частью хэша
         #  параметров модели.
         # Иначе - просто возвращаем имя модели.
         if fieldName? and !(isSelector and @_isSelectorHasAlternativeFieldName(field))
            [
               reflectionChain
               sqBracketStart
               fieldName
               sqBracketEnd
            ].join @_CHARS.empty
         else
            reflectionChain
      else
         fieldName

   ###*
   * Метод получения строки иерархии связок по заданным параметрам модели.
   *
   * @param {Boolean} isAddAttributesSuffix - флаг добавления суффикса для элемента
   *                                          цепи родителей.
   * @return {String}
   ###
   _getFieldReflectionChain: (isAddAttributesSuffix) ->
      modelParams = @props.modelParams

      if modelParams? and !_.isEmpty modelParams
         modelName = modelParams.name
         reflectionChain = modelParams.chain
         isInstancesSelector = modelParams.isInstancesSelector

         chars = @_CHARS
         collectionInstancesString = @_COLLECTION_INSTANCES_SUFFIX
         attributesSuffix = @_ATTRIBUTES_SUFFIX
         sqBracketEnd = chars.sqBracketEnd
         sqBracketStart = chars.sqBracketStart
         underscore = chars.underscore

         reflectionElements = []

         if reflectionChain? and reflectionChain.length

            for chainElement in reflectionChain
               isCollection = chainElement.isCollection
               elementReflection = chainElement.reflection
               elementIndex = chainElement.index
               elementRecordKey = chainElement.recordKey

               reflectionNameString =
                  if isInstancesSelector
                     # TODO: костыль для внешних полей-связок - обрезаем последнюю букву
                     #  добавляем строку идентификаторов (этот способ может подойти не везде,
                     #  если потребуется нужно продумать корректный подход с обработкой таких полей).
                     cuttedReflectionName =
                        elementReflection.substring(0, elementReflection.length - 1)

                     [
                        cuttedReflectionName
                        collectionInstancesString
                     ].join underscore
                  else if isAddAttributesSuffix
                     [
                        elementReflection
                        attributesSuffix
                     ].join underscore
                  else
                     elementReflection

               reflectionElements =
                  reflectionElements.concat(
                     [
                        sqBracketStart
                        reflectionNameString
                        sqBracketEnd
                     ]
                  )

               if isCollection

                  idx = unless isInstancesSelector
                           if elementRecordKey?
                              elementRecordKey + @_CRUTCH_RECORD_INDEX_INDENT
                           else
                              elementIndex or 1

                  reflectionElements =
                     reflectionElements.concat(
                        [
                           sqBracketStart
                           idx
                           sqBracketEnd
                        ]
                     )

         if modelName?
            [
               modelName
               reflectionElements.join ''
            ].join ''

   ###*
   * Функция получения параметров запроса данных для поля выбора.
   *
   * @param {Object} field - параметры поля.
   * @return {Object} - парметры запроса данных для поля выбора.
   ###
   _getSelectorRequestingParams: (field) ->
      reflection = field.reflection

      if reflection?
         reflDictionary = reflection.dictionary
         reflInstance = reflection.instance
         reflAddition = reflection.addition
         reflKeys = @_REFLECTION_KEYS
         requestingParamsKey = reflKeys.requestingParams

         reflDictionaryRequestingParams =
            if reflDictionary? and reflDictionary.hasOwnProperty(requestingParamsKey)
               reflDictionary[requestingParamsKey]

         reflInstanceRequestingParams =
            if reflInstance? and reflInstance.hasOwnProperty(requestingParamsKey)
               reflInstance[requestingParamsKey]

      dictionary: reflDictionaryRequestingParams
      instance: reflInstanceRequestingParams
      addition: reflAddition

   ###*
   * Функция получения параметров иконки в начале строки. Проверяет наличие ошибок.
   *  Если они есть формирует объект с параметрами иконки ошибки.
   *
   * @return {Object, Undefined} - параметры иконки.
   ###
   _getLeadIconParams: ->
      leadIconParams = @_LEAD_ICON_PARAMS
      porpLeadIconParams = @props.leadIcon
      errorsArr = @state.validateErrors
      isHasErrors = if errorsArr.length then true else false
      isMoney = @state.isMoney

      if isHasErrors
         errorIconParams = leadIconParams.error
         errorIconParams.title = errorsArr.join('\n')

         errorIconParams
      else if isMoney
         leadIconParams.money
      else if porpLeadIconParams?
         porpLeadIconParams
   ###*
   * Флаг получения инициализационного значения поля. Получает значение из @props.value,
   *  если данное свойcтво не задано возвращает значение @props.defaultValue
   *
   * @param {Object} field              - параметры поля.
   * @param {String, Number, undefined} inputValue - входное значение(для обработки).
   * @return {String, undefined} - инициализационное значение поля.
   ###
   _getInitValue: (field, inputValue) ->
      field ||= @props.field
      selectedValue =
         if inputValue
            inputValue
         else if field?
            if field.value?
               field.value
            else if field.defaultValue?
               field.defaultValue

      selectedKey = @props.selectedKey
      fieldEnumValues = field.enumValues
      isMoney = field.isMoney

      # Если задано значение поля и это - объект и также задан ключ считывания поля
      #  в качестве значения поля возьмем элемент хэша по ключу.
      if selectedValue and _.isPlainObject(selectedValue) and selectedKey?
         selectedValue = selectedValue[selectedKey]

      # Если поле содержим перечислимые значения - выполним поиск выбранного значения
      #  из перечисления.
      if fieldEnumValues?
         enumKeys = Object.keys(fieldEnumValues)

         for key, value of fieldEnumValues
            if value is selectedValue
               selectedValue = key
               break

      # Для поля денежного формата проверим необходимость преобразования в рубли
      #  (если тип поля - целочисленный) и выполним преобразование в строку
      #  естественного отображения сумм.
      if isMoney and selectedValue
         selectedValue = @formatMoney(selectedValue, field.type)

      selectedValue

   ###*
   * Обработчик изменения значения в поле поиска. Обрабатывает различный возврат
   *  значений от различных компонентов.
   *
   * @param {String} value      - значение в поле ввода.
   * @param {Boolean} isInitSet - флаг начальной утстановки значение (для полей-селекторов).
   * @param {Object} event      - объект события.
   * @return
   ###
   _onChangeInput: (value, isInitSet, event) ->
      onChangeHandler = @props.onChange
      isMoney = @state.isMoney
      chars = @_CHARS

      selectedValue = if _.isPlainObject value
                         value.value || value.key || value
                      else if isMoney
                         @_processMoney(value)
                      else if _.isArray value
                         if value.length
                            if value.length is 1
                               firstItem = value[0]

                               if firstItem?
                                  firstItem.key || firstItem.value || firstItem
                            else
                               value.map (item) ->
                                  item.key || item.value || item
                      else
                         value

      # Передадим обработчику значение из поля ввода.
      if onChangeHandler
         onChangeHandler selectedValue, @props.field, @state.fieldName, isInitSet

      # Подготавливаем устанавливаемые состояния:
      # Значения в поле ввода,
      # Массив ошибок валидации поля сбросим,
      # Установим флаг того, что поле не сброшено.
      newState =
         selectedValue: selectedValue
         validateErrors: []
         isReseted: false

      # Для поля для обработки денежного формата дополнительно определим
      #  новое состояние каретки (так как при переопределении выводимого
      #  значение каректка перескакивает, так как в строку добавляются
      #  символы-заполнители).
      if isMoney and event?
         currentCaretPosition = event.target.selectionEnd

         newState.caretPosition =
         # Для начального значения в поле ввода не определяем новую позицию каретки,
         # Для всех остальных - определяем.
         if value.length > 1
            @getMoneyInputCaretPosition(value,
                                        selectedValue,
                                        @state.selectedValue
                                        currentCaretPosition)
         else if value.length is 1
            1

      @setState newState

   ###*
   * Обработчик на потерю фокуса поля ввода.
   *  Запускает валидацию поля.
   *
   * @return
   ###
   _onBlurInput: (event) ->
      @validate() if @props.isNeedValidation

   ###*
   * Обработчик клика по кнопке очистке поля поиска.
   *
   * @return
   ###
   _onClearInput: ->
      onClearHandler = @props.onClear

      if onClearHandler
         onClearHandler(@props.field, @state.fieldName)

      # Очистим поле.
      @_resetField(true)

   ###*
   * Функция-предикат для определения является ли поле скрытым. Проверяет
   *  два флага - скрывать первичный ключ (для этого параметра нужен второй флаг
   *  в параметрах поля - признак поля по первичному ключу).
   *            и флаг явного скрытия поля.
   *
   * @return {Boolean}
   ###
   _isHiddenField: ->
      field = @props.field
      isPrimaryKey = field.isPrimaryKey
      isHiddenByKey = isPrimaryKey if @props.isKeyHidden
      isHidden = field.isHidden

      isHiddenByKey or isHidden

   ###*
   * Функция-предикат для проверки является ли поле формы - полем выбора (Selector).
   *  Делает предположение, что если это поле связки (_isReflection) и параметры
   *  связки содержат параметры словаря (dictionary) и в параметрах словаря
   *  заданы параметры запроса данных (requestingParams), то это поле выбора.
   *
   * @return {Boolean}
   ###
   _isSelector: (field) ->
      isSelector = false
      if @_isReflection(field)
         fieldReflection = field.reflection

         if fieldReflection.hasOwnProperty('dictionary')
            reflDictionaryParams = fieldReflection.dictionary
            reflDictionaryRequestingParams = reflDictionaryParams.requestingParams

            isSelector =
               reflDictionaryParams? and
               !_.isEmpty(reflDictionaryParams) and
               reflDictionaryRequestingParams? and
               !_.isEmpty(reflDictionaryRequestingParams)

      isSelector


   ###*
   * Функция-предикат для проверки является ли поле формы - полем связки.
   *
   * @return {Boolean}
   ###
   _isReflection: (field) ->
      fieldReflection = field.reflection

      fieldReflection? and !_.isEmpty(fieldReflection)

   ###*
   * Метод-предикат для проверки наличия у поля альтернативного имени(для селекторов).
   *
   * @param {field} - параметры поля.
   * @return {Boolean}
   ###
   _isSelectorHasAlternativeFieldName: (field) ->
      selectorRequestingParams = @_getSelectorRequestingParams(field)
      selectorDictionaryParams = selectorRequestingParams.dictionary

      if selectorDictionaryParams?
         reflKeys = @_REFLECTION_KEYS
         resultKeyKey = reflKeys.result_key
         alternativeFieldNameKey = reflKeys.alternativeFieldName

         if selectorDictionaryParams.hasOwnProperty resultKeyKey
            resultKey = selectorDictionaryParams[resultKeyKey]

            # Если ключ считывания результата задан и он составной(задан в виде
            #   массива) - проверим заданы ли альтернативные имена для полей.
            if resultKey? and _.isArray(resultKey)
               for keyParams in resultKey
                  if keyParams.hasOwnProperty alternativeFieldNameKey
                     return true
      false

   ###*
   * Функция предварительной обработки ввода денежных сумм. Функция производит
   *  подготовку значения в поле ввода денежных сумм, затем производит
   *  форматирование в денежный формат для вывода.
   *
   * @param {String} moneyInput - значение в поле ввода.
   * @return {String} - форматированное значение денежной суммы.
   ###
   _processMoney: (moneyInput) ->
      currentMoney = @state.selectedValue
      isDeleteInput = currentMoney? and moneyInput? and
                      moneyInput.length < currentMoney.length
      chars = @_CHARS

      # Обработаем особым образом ввод управления на удаление символа в поле
      #  ввода - если был удален символ разделителя - вернем текущее значение поля.
      if isDeleteInput
         isMoneyInputWithoutDelimeter = moneyInput.split(chars.point).length is 1

         if isMoneyInputWithoutDelimeter
            return currentMoney

      @formattedMoney(moneyInput)

   ###*
   * Функция удаления из строки наименование модели и оставления вместо имени
   *  пустого-идентификатора принадлежности к аттрибутам родительской модели. Нужна
   *  для формирования правильного имени для полей загрузки файлов.
   *
   * @param {String} model - строка-идентификатор цепи моделей.
   * @return {String}
   ###
   _prepareUploaderModelName: (model) ->
      chars = @_CHARS
      sqBracketStart = chars.sqBracketStart

      modelElements = model.split sqBracketStart
      modelElements.splice([modelElements.length - 1])
      modelElements.join sqBracketStart

   ###*
   * Функция cбраса значения поля. Сбрасывает значение к инициализационному,
   *  сбрасывает ошибки валидации и устанавливает флаг сброса
   *
   * @param {Boolean} isForceEmpty - флаг того, что нужно принудительно
   *  очистить поле. Если данный флаг не задан возвращает поле к первоначальному
   *  значению (к значению @props.value или @props.defaultValue), если задан
   *  сбрасывает значение к пустой строке.
   *
   * @return
   ###
   _resetField: (isForceEmpty) ->
      # зададим состояние значения в поле ввода - пустая строка
      # массив ошибок валидации поля сбросим
      @setState
         selectedValue: if isForceEmpty then '' else @_getInitValue()
         validateErrors: []
         isReseted: true


module.exports = FormInput
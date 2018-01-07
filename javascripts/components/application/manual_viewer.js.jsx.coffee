###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin         - общие стили для компонентов.
* HelpersMixin        - функции-хэлперы для компонентов.
* RequestBuilderMixin - модуль взаимодействия с API.
* ImplementationStore - модуль-хранилище стандартных реализаций.
* keymirror           - модуль для генерации "зеркального" хэша.
* lodash              - модуль служебных операций.
* ImplementationStore - модуль-хранилище стандартных реализаций.
###
StylesMixin = require('components/mixins/styles')
HelpersMixin = require('components/mixins/helpers')
RequestBuilderMixin = require('components/application/mixins/request_builder')
keyMirror = require('keymirror')
_ = require('lodash')
ImplementationStore = require('components/content/implementations/implementation_store')

###* Зависимости: компоненты
* Button         - кнопка.
* Dialog         - диалог.
* ArbitraryArea  - произвольная область.
* DataTable      - таблица данных.
* Accordion      - аккордеон.
* BreadNavigator - "хлебный" навигатор.
* AjaxLoader     - индикатор загрузки.
* DynamicForm    - компонент динамической формы ввода.
###
Button = require('components/core/button')
Dialog = require('components/core/dialog')
ArbitraryArea = require('components/core/arbitrary_area')
DataTable = require('components/core/data_table')
Accordion = require('components/core/accordion')
BreadNavigator = require('components/core/bread_navigator')
AjaxLoader = require('components/core/ajax_loader')
DynamicForm = require('components/core/dynamic_form')

###* Константы
* _COLORS               - цвета
* _COMMON_PADDING       - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding

###* Прикладной компонент - просмотрщик руководств.
*
* @props
*     {Object} manualPathParams - параметры пути до руководства.
*               {String} action      - наименование метода.
*        {Array<String>} relatives - цепь связок для ресурса.
*     {Boolean} isShown - флаг показа диалога.
*     {Function} onHide - обработчик на скрытие диалога просмотра.
* @state
*     {Object} fullManualPathParams - параметры полного пути до руководства
*                                     (входные параметры пути + пути текущего ресурса). Вид:
*                 {Array<String>} namespace   - путь пространства имен.
*                        {String} resource    - наименование текущего ресурса.
*                        {String} action      - наименование метода.
*                 {Array<String>} relatives - цепь связок для ресурса.
*     {React-element} loaderTarget - целевой элемент для загрузчика.
*     {Array<Object>} manuals      - параметры загруженных руководств.
*     {Object} userAccessParams    - параметры доступа пользователя.
*     {String} viewerState         - состояние просмотрщика (init/requested/responded).
*     {String} contentsListState   - состояние содержания (init/requested/responded).
*   {Boolean} isDialogFullWindowed - флаг развернутости диалога на весь экран.
*   {Boolean} isContentsListShown  - флаг показанности содержания руководств.
*     {Boolean} isHasManualArticle - флаг того загружено ли сейчас какое-то руководство
*                                    с содержанием(есть ли статья).
*     {Boolean} isInManageMode       - флаг того, что включен режим управления содержимым.
###
ManualViewer = React.createClass
   # @const {String} - наименование ресурса с которым взаимодействуют компонент
   #                   (корень ресурса).
   _RESOURCE_ROOT: 'manuals'

   # @const {Object} - наименование административного ресурса для манипуляции
   #                   руководствами.
   _ADMIN_RESOURCE_ROOT: 'admin/manuals'

   # @const {Object} - параметры ресурса считывания данных по пользователю
   _PERSONAL_RESOURCE_PARAMS:
      root: 'personal'
      accessParamsMethod: 'access_params'

   # @const {Object} - наименования возможных состояний компонента.
   _CONTENT_STATES: keyMirror(
      init: null
      ready: null
      requested: null
      responded: null
   )

   # @const {Object} - наименования элементов полного пути до руководства
   _FULL_PATH_ELEMENTS: keyMirror(
      namespace: null
      resource: null
      action: null
      relative: null
   )

   # @const {Object} - параметры индикатора загрузки.
   _LOADER_PARAMS:
      text: 'Подождите, загружается руководство...'

   # @const {Object} - параметры индикатора загрузки для содержания.
   _LOADER_CONTENTS_LIST_PARAMS:
      text: 'Загружается содержание'

   # @const {Object} - используемые ссылки.
   _REFS: keyMirror(
      contentContainer: null
      contentsList: null
   )

   # @const {Object} - используемые символы.
   _CHARS:
      empty: ''
      slash: '/'
      space: ' '
      colon: ':'

   # @const {Object} - стандартные заголовки диалога.
   _STANDARD_CAPTIONS:
      requested: 'Загрузка руководства'
      manual: 'Руководство'

   # @const {Object} - доп. действия для диалога(параметры кнопок в заголовке
   #                          диалога).
   _DIALOG_CUSTOM_ACTIONS_SCAFFOLD:
      contentsList:
         name: 'contentsList'
         icon: 'bars'
         title: 'Содержание'

   # @const {Object} - параметры произвольной области-контейнера для содержания
   #                   руководств.
   _CONTENTS_LIST_AREA_PARAMS:
      isCloseOnBlur: false
      layoutAnchor: 'stream'
      animation: 'slideRight'

   # @const {Object} - параметры кнопки для управления статьей руководства.
   _MANAGE_BUTTON_PARAMS:
      isLink: true

   # @const {Object} - параметры для кнопки управления в
   #                   зависимости от контекста использования.
   _MANAGE_BUTTON_CONTEXT_PARAMS:
      create:
         caption: 'Создать руководство'
         icon: 'plus-square-o'
         styleName: 'manageButtonCreate'
      update:
         caption: 'Редактировать руководство'
         icon: 'pencil'
         styleName: 'manageButton'

   # @const {Object} - параметры для формы управления содержимым руководства.
   _MANAGE_DYNAMIC_FORM_PARAMS:
      modelParams:
         name: 'manual'
      fluxParams:
         isUseServiceInfrastructure: true
      isUseImplementation: true
      isMergeImplementation: true
      externalEntitiesParams:
         isDenyExistInstances: true
      fieldConstraints:
         constraints: [
            {
               name: 'parent_id'
               identifyingName: 'manual_id'
            }
            {
               name: 'source_id'
               identifyingName: 'manual_id'
            }
            {
               name: 'author_id'
               identifyingName: 'users'
            }
            {
               name: 'last_updated_user_id'
               identifyingName: 'users'
            }
         ]

   # @const {Object} - режимы работы формы управления содержимым.
   _MANAGE_FORM_MODES: keyMirror(
      create: null
      update: null
   )

   # @const {Object} - параметры кнопки скрытия формы управления.
   _MANAGE_MODE_OFF_BUTTON_PARAMS:
      isLink: true
      caption: 'Скрыть форму'

   # @const {Object} - параметры таблицы данных для содержания
   _CONTENTS_LIST_TABLE:
      viewType: 'tree'
      enableCreate: false
      enableEdit: false
      enableDelete: false
      enableRowSelect: false
      enableObjectCard: false
      enablePerPageSelector: false
      enableStatusBar: false
      enableFilter: false
      dimension:
         common:
            width:
               min: 300
            height:
               max: 800
      modelParams:
         name: 'manual_view'
      fluxParams:
         isUseServiceInfrastructure: true
      hierarchyViewParams:
         mainDataParams:
            template: "{0}"
            fields: ["caption"]

   # @const {Object} - стандартные тексты-заглушки.
   _STANDARD_STUB_TEXTS:
      noManual: 'Руководства по данному разделу не найдено'
      noArticle: 'Статей руководства нет'

   mixins: [HelpersMixin, RequestBuilderMixin]

   styles:
      contentContainer:
         color: _COLORS.dark
         minWidth: 500
         maxWidth: 1200
         minHeight: 200
         maxHeight: 800
         overflow: 'auto'
         textAlign: 'left'
      contentOrganizerTable:
         width: '100%'
      contentsListCell:
         verticalAlign: 'top'
         width: 1
         padding: 2
      contentCell:
         verticalAlign: 'top'
         padding: 10
      manualArticle:
         minWidth: 400
      contentContainerFullWindowed:
         maxHeight: null
         maxWidth: null
      stubArticleText:
         color: _COLORS.hierarchy3
         marginTop: 81
         textAlign: 'center'
      accordionContainerActivateHeader:
         backgroundColor: _COLORS.third
      accordionContainerHeader:
         minHeight: 25
      breadNavigatorContainer:
         borderBottomWidth: 1
         borderBottomStyle: 'solid'
         borderBottomColor: _COLORS.hierarchy4
         padding: 2
         margin: 2
      breadNavigatorItem:
         color: _COLORS.hierarchy2
         padding: 0
      manageButtonContainer:
         textAlign: 'right'
      manageButton:
         color: _COLORS.hierarchy3
      manageButtonCreate:
         color: _COLORS.main


   getInitialState: ->
      viewerState: 'init'
      contentsListState: 'init'
      fullManualPathParams: @_getFullManualPathParams()
      loaderTarget: null
      loaderTargetForList: null
      manuals: []
      userAccessParams: {}
      isDialogFullWindowed: false
      isContentsListShown: false
      isHasManualArticle: false
      isInManageMode: false

   componentWillReceiveProps: (nextProps) ->
      if !@props.isShown and nextProps.isShown
         @setState viewerState: @_CONTENT_STATES.requested

         @_sendRequestForContent()

   render: ->
      `(
         <Dialog content={this._getDialogContent()}
                 caption={this._getDialogCaption()}
                 isShown={this.props.isShown}
                 isHasFullWindowButton={true}
                 customActions={this._getDialogCustomActions()}
                 onHide={this.props.onHide}
                 onFullWindowedTrigger={this._onFullWindowedTriggerDialog}
              />
       )`

   componentWillMount: ->
      @_sendRequestForContent()
      @_sendRequestForUserAccess()

   componentDidMount: ->
      refNames = @_REFS

      @setState
         loaderTarget: @refs[refNames.contentContainer]

   componentDidUpdate: (prevProps, prevState) ->
      currentFullPathParams = @state.fullManualPathParams
      prevFullPathParams = prevState.fullManualPathParams
      isHasManualArticleNew = @_isHasManualArticle()

      unless _.isEqual(currentFullPathParams, prevFullPathParams)
         @_sendRequestForContent()

      if isHasManualArticleNew isnt @state.isHasManualArticle
         @setState isHasManualArticle: isHasManualArticleNew

   ###*
   * Функция формирования содержимого диалога. Если компонент находится в состоянии
   *  "запрошено" - выводим загрузчик. Также пробуем построить содержимое руководства
   *
   * @return {React-element}
   ###
   _getDialogContent: ->

      `(
         <div style={this._getContentContainerStyle()}
              ref={this._REFS.contentContainer}>
            <table style={this.styles.contentOrganizerTable}>
               <tbody>
                  <tr>
                     <td style={this.styles.contentsListCell}>
                        <ArbitraryArea content={this._getContentsList()}
                                       target={this.state.isContentsListShown}
                                       onHide={this._onHideContentsListArea}
                                       {...this._CONTENTS_LIST_AREA_PARAMS}
                                    />
                     </td>
                     <td style={this.styles.contentCell}>
                        {this._getManualContent()}
                        {this._getManualManageForm()}
                        <AjaxLoader isShown={this._isViewerRequested()}
                                    target={this.state.loaderTarget}
                                    {...this._LOADER_PARAMS}
                                 />
                     </td>
                  </tr>
               </tbody>
            </table>
         </div>
       )`

   ###*
   * Функция формирования содержимого содержания руководств.
   *
   * @return {React-element}
   ###
   _getContentsList: ->
      if @_isContentsListReady() or @_isContentsListResponded()
         `(
            <DataTable ref={this._REFS.contentsList}
                       onReady={this._onReadyContentsList}
                       onRowClick={this._onRowClickContentsList}
                       {...this._CONTENTS_LIST_TABLE}
                     />
          )`
      else
         `(<div style={this.styles.manualArticle}> </div>)`


   ###*
   * Функция формирования формы для манипуляции содержимым руководства.
   *
   * @return {React-element}
   ###
   _getManualManageForm: ->

      if @_isInManageMode()
         formModes = @_MANAGE_FORM_MODES
         managedManualKey = @state.managedManualKey

         formMode =
            if managedManualKey?
               formModes.update
            else
               formModes.create

         `(
            <div>
               <Button onClick={this._onClickManageModeOff}
                       {...this._MANAGE_MODE_OFF_BUTTON_PARAMS}
                      />
               <DynamicForm updateIdentifier={managedManualKey}
                            mode={formMode}
                            implementationStore={ImplementationStore}
                            accompanyingRequestData={
                               {
                                  action:{
                                     pathParams: this.state.fullManualPathParams
                                  }
                               }
                            }
                            {...this._MANAGE_DYNAMIC_FORM_PARAMS}
                          />
            </div>
          )`

   ###*
   * Функция формирования элемента с содержимым статьи - если загружено несколько
   *  статей формируется контейнер-аккордеон с содержимым всех статей, упорядоченных
   *  по секциям, если загружена одна статья - формируется содержимое для отображения
   *  только её, если статей нет - формируется надпись-заглушка.
   *
   * @return {React-element}
   ###
   _getManualContent: ->
      if !@_isInManageMode() and @_isViewerResponded()
         manuals = @state.manuals

         if @_isHasManualArticle()
            manualsCount = _.size(manuals)

            if manualsCount is 1
               @_getManualArticle(_.head(manuals), true)
            else
               @_getManualsContainer(manuals)
         else
            @_getStandardArticleStub()

   ###*
   * Функция формирования элемента с содержимым-заглушкой, при отсутствующем
   *  содержимом руководства.
   *
   * @return {React-element}
   ###
   _getStandardArticleStub: ->
      isHasManual = @_isHasManual()
      stubTexts = @_STANDARD_STUB_TEXTS

      stubText =
         if isHasManual
            manualKey = _.head(@state.manuals).key
            stubTexts.noArticle
         else
            stubTexts.noManual

      `(
         <div style={this.styles.stubArticleText}>
            <div>{this._getArticleManageButton(manualKey)}</div>
            {stubText}
         </div>
       )`

   ###*
   * Функция формирования элемента с содержимым статьи руководства, текст которого
   *  формируется на основе текста статьи в формате md. Формат md переводится в
   *  формат html при помощи библиотеки showdown.
   *
   * @param {Object} manual - параметры руководства.
   * @param {Boolean} isNeedNavigator - флаг необходимости навигатора.
   * @return {React-element}
   ###
   _getManualArticle: (manual, isNeedNavigator)->

      if manual? and !_.isEmpty manual
         content = @_getManualArticleContent(manual)

         if isNeedNavigator
            `(
               <div>
                  <div style={this.styles.breadNavigatorContainer}>
                     {this._getArticleBreadNavigator(manual.chain)}
                  </div>
                  {content}
               </div>
             )`
         else
            content

   ###*
   * Функция формирования элемента со статьей руководства. Добавляет элементы
   *  управления, если у пользователя есть доступ.
   *
   * @param {Object} manual - параметры руководства.
   * @return {React-element}
   ###
   _getManualArticleContent: (manual) ->
      article =
         `(
            <div style={this.styles.manualArticle}
                 dangerouslySetInnerHTML={{__html: manual.content}}>
            </div>
          )`
      manageButton = @_getArticleManageButton(manual.key)

      if manageButton?
         `(
            <div>
               <div style={this.styles.manageButtonContainer}>
                  {manageButton}
               </div>
               {article}
            </div>
          )`
       else
         article

   ###*
   * Функция формирования кнопки управления статьей руководства.
   *
   * @param {String} manualKey - ключ руководства.
   * @return {React-element}
   ###
   _getArticleManageButton: (manualKey) ->

      if @_isUserHasManagementAccess()
         buttonContextParams = @_MANAGE_BUTTON_CONTEXT_PARAMS

         contextParams =
            if manualKey?
               buttonContextParams.update
            else
               buttonContextParams.create

         `(
            <Button caption={contextParams.caption}
                    icon={contextParams.icon}
                    styleAddition={this.styles[contextParams.styleName]}
                    value={manualKey}
                    onClick={this._onClickManageManual}
                    {...this._MANAGE_BUTTON_PARAMS}
                  />
          )`

   ###*
   * Функция формирования элемента с контейнером-аккордеоном упорядочивающий
   *  несколько статей.
   *
   * @param {Array<Object>} manuals - набор параметров руководств.
   * @return {React-element}
   ###
   _getManualsContainer: (manuals)->
      slashChar = @_CHARS.slash

      accordionItems =
         manuals.map ((manualParams, idx) ->
            header: @_getArticleBreadNavigator(manualParams.chain)
            name: _.last(manualParams.names)
            content: @_getManualArticle(manualParams)
            isOpened: idx is 0
         ).bind(this)

      `(
         <Accordion items={accordionItems}
                    styleAddition={
                        {
                           header: {
                              common: this.styles.accordionContainerHeader,
                              highlightBack: this.styles.accordionContainerActivateHeader
                           }
                        }
                    }
                  />
       )`

   ###*
   * Функция формирования заголовка-хлебного навигатора для статьи
   *
   * @param {Array<Object>} manualPath - путь до руководства.
   * @return {Object}
   ###
   _getArticleBreadNavigator: (manualPath) ->

      return unless manualPath?

      pathToNode = []
      navigatorItems =
         manualPath.map (pathNode) ->
            pathToNode.push pathNode
            nodeCaption = pathNode.caption

            caption: nodeCaption
            title: nodeCaption
            path: _.clone(pathToNode)

      `(
         <BreadNavigator items={navigatorItems}
                         styleAddition={
                           {
                              item: this.styles.breadNavigatorItem
                           }
                         }
                         onClickItem={this._onClickItemArticlePathNavigator}
                     />
       )`

   ###*
   * Функция формирования параметров кнопок действия для диалога:
   *  - кнопка открытия содержания.
   *
   * @return {Array}
   ###
   _getDialogCustomActions: ->
      dialogCustomActions = @_DIALOG_CUSTOM_ACTIONS_SCAFFOLD
      contentsListAction = dialogCustomActions.contentsList

      contentsListAction.onClick = @_onClickContentsListTrigger
      contentsListAction.onDoubleClick = @_onDoubleClickContentsListTrigger

      [contentsListAction]

   ###*
   * Функция формирования стилей для контейнера содержимого руководств.
   *
   * @return {Object}
   ###
   _getContentContainerStyle: ->
      @computeStyles(
         @styles.contentContainer,
         @state.isDialogFullWindowed and @styles.contentContainerFullWindowed
      )

   ###*
   * Функция получения заголовка диалога просмотрщика. В зависимости от состояния
   *  компонента выводит различные заголовки.
   *
   * @return {String}
   ###
   _getDialogCaption: ->
      standardCaptions = @_STANDARD_CAPTIONS
      chars = @_CHARS
      manuals = @state.manuals

      if @_isViewerRequested()
         standardCaptions.requested
      else if @_isViewerResponded()
         standardCaption = standardCaptions.manual

         manualCaption =
            unless _.isEmpty manuals
               headChain = _.head(manuals).chain

               _.last(headChain).caption if headChain?

         if manualCaption?
            [
               standardCaption
               chars.colon
               chars.space
               manualCaption
            ].join chars.empty
         else
            standardCaption

   ###*
   * Функция формирования параметров элементов полного пути до руководства.
   *  Считывает текущий путь в браузере и из этого пути получает имя ресурса
   *  и пространства имен, соединяет с входными параметрами параметров пути
   *  руководства. Затем выполняет слияние "считанных" параметров с входными.
   *  Входные параметры являются приоритетными.
   *
   * @return {Object}
   ###
   _getFullManualPathParams: ->
      inputManualPathParams = _.cloneDeep(@props.manualPathParams)

      currentLocationPathElements =
         _.compact(location.pathname.split(@_CHARS.slash))
      pathElementsCount = currentLocationPathElements.length
      resourceName = _.last(currentLocationPathElements)
      readManualPathParams = {}

      namespace =
         if pathElementsCount > 1
            _.slice(currentLocationPathElements, 0, pathElementsCount - 1)

      readManualPathParams.resource = resourceName if resourceName?
      readManualPathParams.namespace = namespace if namespace?

      isHasInputParams =
         inputManualPathParams? and !_.isEmpty(inputManualPathParams)
      isHasReadParams =
         readManualPathParams? and !_.isEmpty(readManualPathParams)

      if isHasInputParams and isHasReadParams
         _.merge(readManualPathParams, inputManualPathParams)
      else if isHasInputParams
         inputManualPathParams
      else if isHasReadParams
         readManualPathParams
      else
         {resource: null}

   ###*
   * Функция считывания данных руководства из ответа бизнес-логики.
   *
   * @param {Object} error            - параметры ошибки.
   * @param {Object} reposponseParams - параметры ответа.
   * @return
   ###
   _getManualContentResponse: (error, responseParams) ->
      response = @_getResponseData(error, responseParams)

      @setState
         responseError: response.errors
         manuals: response.data
         viewerState: @_CONTENT_STATES.responded

   ###*
   * Функция считывания данных по уровням доступа пользователя
   *  из ответа бизнес-логики.
   *
   * @param {Object} error            - параметры ошибки.
   * @param {Object} reposponseParams - параметры ответа.
   * @return
   ###
   _getUserAccessResponse: (error, responseParams)->
      response = @_getResponseData(error, responseParams)

      @setState userAccessParams: response.data

   ###*
   * Функция получения узла пути до руководства из параметров записи таблицы
   *  данных(содержания).
   *
   * @param {Object} record - параметры записи.
   * @return {Object}
   ###
   _getPathNodeFromRecord: (record) ->
      fields = record.fields

      name: fields.name.value
      type: fields.manual_type.value_original
      caption: fields.caption.value

   ###*
   * Функция установки текущих параметров пути до руководства по параметрам пути
   *
   *
   * @param {Array<Object>} path - параметры узлов.
   * @param {Object} event - объект события.
   * @return
   ###
   _setFullManualPathParamsFromPath: (path) ->
      fullPathElements = @_FULL_PATH_ELEMENTS
      arrayElementsCollection = [
         fullPathElements.namespace
         fullPathElements.relative
      ]
      newFullManualPathParams = {}

      for pathElement in path
         elementName = pathElement.name
         elementType = pathElement.type
         isArrayElement = _.includes(arrayElementsCollection, elementType)

         elementValue =
            if isArrayElement
               if _.isEmpty(newFullManualPathParams[elementType])
                  [elementName]
               else
                  newFullManualPathParams[elementType].push(elementName)
                  null
            else
               elementName

         newFullManualPathParams[elementType] = elementValue if elementValue?

      # Для элемента - связок меняем ключ в единственном числе на ключ во множественном.
      if newFullManualPathParams.relative?
         newFullManualPathParams.relatives =
            _.clone(newFullManualPathParams.relative)
         delete newFullManualPathParams.relative

      @setState
         fullManualPathParams: newFullManualPathParams

   ###*
   * Функция-предикат для определения есть ли у пользователя права на
   *  управление содержимым руководства (создание/редактирование).
   *
   * @return {Boolean}
   ###
   _isUserHasManagementAccess: ->
      userAccessParams = @state.userAccessParams

      if userAccessParams? and !_.isEmpty(userAccessParams)
         userAccessParams.is_god
      else
         false

   ###*
   * Функция-предикат для определения содержит ли компонент активное руководство.
   *
   * @return {Boolean}
   ###
   _isHasManual: ->
      manuals = @state.manuals

      manuals? and !_.isEmpty(manuals)

   ###*
   * Функция-предикат для определения содержит ли компонент хотя бы одну статью
   *  руководства. Перебирает все руководства и ищет те, в которых есть содержимое.
   *
   * @return {Boolean}
   ###
   _isHasManualArticle: ->
      isHasArticle = false

      if @_isHasManual()
         manuals = @state.manuals

         for manual in manuals
            if manual.content?
               isHasArticle = true
               break

      isHasArticle

   ###*
   * Функция-предикат для определения находится ли просмотрщик
   * в состоянии "запрошено".
   *
   * @return {Boolean}
   ###
   _isViewerRequested: ->
      @state.viewerState is @_CONTENT_STATES.requested

   ###*
   * Функция-предикат для определения того, что компонент находится в режиме
   *  управления.
   *
   * @return {Boolean}
   ###
   _isInManageMode: ->
      @state.isInManageMode

   ###*
   * Функция-предикат для определения находится ли просмотрщик
   *  в состоянии "ответ получени".
   *
   * @return {Boolean}
   ###
   _isViewerResponded: ->
      @state.viewerState is @_CONTENT_STATES.responded

   ###*
   * Функция-предикат для определения находится ли компонент содержания
   *  в инициализационном состоянии.
   *
   * @return {Boolean}
   ###
   _isContentsListInit: ->
      @state.contentsListState is @_CONTENT_STATES.init

   ###*
   * Функция-предикат для определения находится ли компонент содержания
   *  в состоянии "готов к отображению".
   *
   * @return {Boolean}
   ###
   _isContentsListReady: ->
      @state.contentsListState is @_CONTENT_STATES.ready

   ###*
   * Функция-предикат для определения находится ли компонент содержания
   *  в состоянии "запрошено".
   *
   * @return {Boolean}
   ###
   _isContentsListResponded: ->
      @state.contentsListState is @_CONTENT_STATES.responded

   ###*
   * Обработчик на переключение полноэкранного режима диалога.
   *
   * @param {Boolean} isFullWindowed - флаг развернутости.
   ###
   _onFullWindowedTriggerDialog: (isFullWindowed) ->
      @setState isDialogFullWindowed: isFullWindowed

   ###*
   * Обработчик клика по кнопке открытия/закрытия содержания руководств.
   *
   * @param {Object} value - значение кнопки.
   * @param {Object} event - объект событпя.
   * @return
   ###
   _onClickContentsListTrigger: (value, event) ->
      event.stopPropagation()
      newState =
         isContentsListShown: !@state.isContentsListShown

      if @_isContentsListInit()
         newState.contentsListState = @_CONTENT_STATES.ready

      @setState newState

   ###*
   * Обработчик клика по кнопке управления руководством. Если ключ руководства не
   *  задан, значит производится создание руководства
   *
   * @param {Object, undefined} manualKey - ключ руководства.
   * @param {Object} event - объект событпя.
   * @return
   ###
   _onClickManageManual: (manualKey, event) ->
      # if manualKey?
      #    @_sendRequestForManualInstance(manualKey)
      # else
      #    @_sendRequestForManualNew()

      @setState
         isInManageMode: true
         managedManualKey: manualKey

   ###*
   * Обработчик клика на кнопку скрытия формы управления содержимым руководства.
   *
   * @return {React-element}
   ###
   _onClickManageModeOff:  ->
      @setState isInManageMode: false

   ###*
   * Обработчик двойного клика по кнопке открытия/закрытия содержания руководств.
   *  Останавливает всплытие события.
   *
   * @param {Object} event - объект событпя.
   * @return
   ###
   _onDoubleClickContentsListTrigger: (event) ->
      event.stopPropagation()

   ###*
   * Обработчик на скрытие области с содержанием руководств.
   *
   * @return
   ###
   _onHideContentsListArea: ->
      @setState isContentsListShown: false

   ###*
   * Обработчик готовности таблицы данных с содержанием к работе (данные загружены).
   *  Устанавливает состояние для элемента содержания "данные получены".
   *
   * @return
   ###
   _onReadyContentsList: ->
      unless @_isContentsListResponded()
         @setState contentsListState: @_CONTENT_STATES.responded

   ###*
   * Обработчик клика по строка таблицы содержания руководств.
   *
   * @param {Object} _record - запись по кликнутой строке.
   * @param {String} _dataName - наименование коллекции данных.
   * @param {Array<Number>} hierarchyKeyPath - путь ключей до текущего узла.
   * @return
   ###
   _onRowClickContentsList: (_record, _dataName, hierarchyKeyPath) ->
      contentsListTable = @refs[@_REFS.contentsList]
      hierarchicalRecordsChain =
         contentsListTable.getHierarchicalRecordsChain(hierarchyKeyPath)

      if hierarchicalRecordsChain? and !_.isEmpty(hierarchicalRecordsChain)
         pathToNode =
            hierarchicalRecordsChain.map @_getPathNodeFromRecord

         @_setFullManualPathParamsFromPath(pathToNode)

         @setState isInManageMode: false

   ###*
   * Обработчик клика на кнопку-элемент цепи пути в навигаторе. Устанавливает
   *  новые параметры пути до руководства для повторного запроса содержимого.
   *
   * @param {Object} nodeParams - параметры узла по которому кликнули.
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickItemArticlePathNavigator: (nodeParams, event) ->
      event.stopPropagation()
      @_setFullManualPathParamsFromPath(nodeParams.path)

   ###*
   * Функция отправки запроса на получения содержимого руководства.
   *
   * @return
   ###
   _sendRequestForContent: ->
      @_sendRequest(
         endpoint: @_constructEndpoint(@_ENDPOINT_METHODS.new, @_RESOURCE_ROOT)
         requestType: @_REQUEST_TYPES.get
         queryParams:
            path_params: JSON.stringify(@state.fullManualPathParams)
         callback: @_getManualContentResponse
      )

      @setState viewerState: @_CONTENT_STATES.requested

   ###*
   * Функция отправки запроса на получения параметров
   *  доступа для текущего пользователя.
   *
   * @return
   ###
   _sendRequestForUserAccess: ->
      personalResourceParams = @_PERSONAL_RESOURCE_PARAMS
      endpoint =
         @_constructEndpoint(personalResourceParams.accessParamsMethod,
                             personalResourceParams.root)
      @_sendRequest(
         endpoint: endpoint
         requestType: @_REQUEST_TYPES.get
         callback: @_getUserAccessResponse
      )

module.exports = ManualViewer
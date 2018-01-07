###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* HelpersMixin     - функции-хэлперы для компонентов.
* keymirror        - модуль для генерации "зеркального" хэша.
* ImplementationStore        - модуль-хранилище стандартных реализаций.
* lodash           - модуль служебных операций.
###
StylesMixin = require('components/mixins/styles')
HelpersMixin = require('components/mixins/helpers')
RequestBuilderMixin = require('components/application/mixins/request_builder')
keyMirror = require('keymirror')
_ = require('lodash')
request = require('superagent')

###* Зависимости: компоненты
* Clerk       - мастер пошаговых операций.
* DataTable   - таблица данных.
* DynamicForm - динамическая форма.
* Button      - кнопка.
* DropDown    - выпадающий список.
* List        - список.
###
Clerk = require('components/core/clerk')
DataTable = require('components/core/data_table')
DynamicForm = require('components/core/dynamic_form')
Button = require('components/core/button')
DropDown = require('components/core/dropdown')
List = require('components/core/list')
Input = require('components/core/input')


###* Константы
* _COLORS               - цвета
* _COMMON_PADDING       - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius

###* Прикладной компонент - подготовитель печатных форм.
*
* @props
*     {Object} instance      - запись экземпляра для которого подготавливается
*                              печатная форма.
*     {Array} dataCollection - доп. набор данных.
*     {Boolean} isUseImplementation - флаг использования стандартных параметров таблицы из
*                                     внешнего общего модуля, представляющего из себя объект,
*                                     разделенный на разделы по названиям модели. Для работы с данным
*                                     флагом компоненту также должен быть задан параметр
*                                     @props.implementationStore - задающий объект в котором
*                                     находятся стандарнтные параметры представления.
*                                     (по-умолчанию = false).
*     {Boolean} isMergeImplementation - флаг "слияния" свойств компонента со свойствами, заданными в
*                                       хранилище реализаций. (по-умолчанию = false)
*     {Object} implementationStore  - объект источников стандартной реализации для таблицы.
*                                     Если данный параметр задан и установлен флаг @props.isUseImplementation,
*                                     то для таблицы будут применены стандартные параметры представления,
*                                     если они будут найдены в заданном источнике. Если вместе с данным
*                                     параметром были заданы пользовательские параметры, определенные в источнике
*                                     стандартной реализации, то стандартные будут переопределены
*                                     пользовательскими.
* @state
*     {Array} reportsList               - набор доступных печатных форм.
*     {Object} reportParams             - параметры выбранной печатной формы.
*     {String} selectedFormat           - выбранный формат.
*     {Object} dynamicFormParams        - параметры для составления формы.
*     {String} serializedFormData       - серилизованные данные, введенные в динамической форме.
*     {Object} reportFileParams         - параметры подготовленного файла печатной формы (для
*                                         возможности скачивания).
*     {Boolean} isFileDownloaded        - флаг, хранящий отметку о том, что файл еще не был скачан.
###
ReportPreparer = React.createClass

   # @const {Object} - адреса взаимодействия с API подготовки печатных форм.
   _ENDPOINTS:
      root: 'reports'
      new: 'new'
      create: 'create'

   # @const {String} - наименование аттрибута для получения дочерних записей от
   #                   родительской записи.
   _CHILDS_RECORD_ATTRIBUTE: 'childs'

   # @const {Object} - предварительные параметры для формирования содержимого
   #                   шагов мастера.
   _CLERK_STEPS_SCAFFOLD:
      list:
         name: 'list'
         caption: 'Список форм'
         title: 'Выбор из списка доступных печатных форм'
      form:
         name: 'form'
         caption: 'Заполнение данных'
         title: 'Заполнение данных для составления печатной формы'
      download:
         name: 'download'
         caption: 'Готово!'

   # @const {Array<Object>} - доступные форматы для документов.
   _AVAILABLE_FORMATS: [
      {
         name: 'pdf'
         caption: 'pdf'
      }
      {
         name: 'docx'
         caption: 'docx'
      }
      {
         name: 'rtf'
         caption: 'rtf'
      }
      {
         name: 'odt'
         caption: 'odt'
      }
      {
         name: 'ods'
         caption: 'ods'
      }
      {
         name: 'xls'
         caption: 'xls'
      }
   ]

   # @const {Object} - сообщения валидаторов.
   _VALIDATOR_MESSAGES:
      reportNotSelect: 'Не выбрана печатная форма'

   # @const {Object} - параметры для таблицы-списка доступных печатных форм.
   _LIST_DATA_TABLE_PARAMS:
      recordsNotFoundText: 'Нет доступных печатных форм'
      isFullyClientMode: true
      enableEdit: false
      enableDelete: false
      enableToolbar: false
      enableRowSelect: true
      enableStatusBar: true
      enableRowSelectByClick: true
      enableObjectCard: false
      viewType: 'tree'
      recordsPerPage: 20
      hierarchyViewParams:
         enableViewChildsCounter: true
         enableSelectParents: true
         enableCompetitiveRootSelectMode: true
         enableSelectChildsOnSelectParent: true
         #enableSelectParentOnSelectChild: true
         mainDataParams:
            template: "{0}"
            fields: ['caption']

   # @const {Object} - параметры по-умолчанию для динамической формы.
   _DYNAMIC_FORM_PARAMS:
      modelParams:
         name: 'dynamic'
      actionButtonParams:
         submit:
            isAbsent: true
         reset:
            caption: 'Восстановить',
            title: 'Вернуть значения, загруженные по-умолчанию'
      isAddAttributesSuffixForChain: true

   # @const {Object} - параметры для списка доступных форматов.
   _FORMAT_SELECTOR_LIST_PARAMS:
      enableMarkActivated: true
      activateIndex: 0
      title: 'Доступные форматы'

   # @const {Object} - параметры для выпадающего списка версий печатных форм.
   _VERSION_SELECTOR_DROPDOWN_PARAMS:
      isLinkSelector: true
      title: 'Версия печатной формы'

   # @const {Object} - используемые наименования ссылок на элементы.
   _REFS: keyMirror(
      clerk: null
      reportListTable: null
      versionSelector: null
      dynamicForm: null
   )

   # @const {Object} - цепи считывания вложенных параметров.
   _GET_CHAINS:
      versions: [
         'fields'
         'versions'
         'value'
      ]

   # @const {String} - маркер открытия ссылки в новом окне(вкладке) браузере.
   _NEW_WINDOW_MARKER: '_blank'

   # @const {Object} - параметры для кнопки повторной загрузки файла.
   _BUTTON_DOWNLOAD_AGAIN_PARAMS:
      isLink: true
      icon: 'download'
      caption: 'Скачать файл повторно'

   # @const {Object} - параметры для чекбокса "файлов раздельно"
   _CHECKBOX_SPLIT_FILES_PARAMS:
      caption: 'Формировать файлы раздельно'
      captionPosition: 'right'
      type: 'boolean'
      isNeedClearButton: false

   mixins: [RequestBuilderMixin]

   styles:
      reportSelectorContainer:
         display: 'flex'
      splitFilesFlag:
         fontSize: 14
         color: _COLORS.hierarchy3
      splitChecker:
         display: 'inline-block'
      reportSelectorDataTable:
         marginRight: 10
      formatSelectorList:
         display: 'inline-block'
         borderStyle: 'solid'
         borderWidth: 1
         borderColor: _COLORS.hierarchy3
         padding: _COMMON_PADDING
         verticalAlign: 'top'
      reportVersionCell:
         width: '18%'
         textAlign: 'right'
      clerkContent:
         maxHeight: 700
         overflow: 'auto'
      finishTitle:
         color: _COLORS.hierarchy3
      errorMessage:
         color: _COLORS.alert
         padding: _COMMON_PADDING
         margin: 'auto'
         maxWidth: 600
         fontSize: 14

   propTypes:
      instance: React.PropTypes.object.isRequired
      dataCollection: React.PropTypes.array
      implementationStore: React.PropTypes.object
      isUseImplementation: React.PropTypes.bool
      isMergeImplementation: React.PropTypes.bool

   getDefaultProps: ->
      implementationStore: null
      isUseImplementation: false
      isMergeImplementation: false

   getInitialState: ->
      reportsList: null
      reportParams: null
      selectedFormat: 'pdf'
      dynamicFormParams: null
      serializedFormData: null
      reportFileParams: null
      isFileDownloaded: false
      isSplitFiles: false

   render: ->
      `(
         <Clerk ref={this._REFS.clerk}
                steps={this._prepareClerkSteps()}
                styleAddition={
                   {
                      content: this.styles.clerkContent
                   }
                }
                enableBreadNavigator={false}
                enableCaption={true}
                onClickForward={this._onClickForwardClerk}
                onClickBackward={this._onClickBackwardClerk}
                onScrollContent={this._onScrollClerkContent}
             />
       )`

   componentDidUpdate: (prevProps, prevState) ->
      if @state.reportFileParams? and !@state.isFileDownloaded

         @_downloadFile()

   ###*
   * Функция формировани списка доступных печатных форм с добавленной ячейкой
   *  выбора версии печатной формы, а также списком доступных форматов.
   *
   * @return {React-element}
   ###
   _getList: ->
      reportsList = @state.reportsList
      isWithError = reportsList.error?
      checkedMarker = @_CHECKED_MARKER
      isChecked = @props.isChecked
      checkedValue = isChecked and checkedMarker

      if isWithError
         @_getErrorMessageContainer(reportsList.error)
      else
         dataTableParams = @_LIST_DATA_TABLE_PARAMS
         hierarchyViewParams = dataTableParams.hierarchyViewParams
         _.assign(hierarchyViewParams,
            onRenderNodeAddition: @_onRenderReportVersionSelector
            styleForAdditionCell: @styles.reportVersionCell
         )

         `(
            <div>
               <div style={this.styles.reportSelectorContainer}>
                  <DataTable ref={this._REFS.reportListTable}
                             initData={
                                {
                                   records: reportsList
                                }
                             }
                             styleAddition={
                                {
                                    dataTable: this.styles.reportSelectorDataTable
                                }
                             }
                             onSelectRow={this._onSelectRow}
                             {...dataTableParams}
                           />
                  <List items={this._AVAILABLE_FORMATS}
                        styleAddition={{common: this.styles.formatSelectorList}}
                        onSelect={this._onSelectFormat}
                        {...this._FORMAT_SELECTOR_LIST_PARAMS}
                      />
               </div>
               <Input onChange={this._onClickSplitCheckBox}
                      value={this.state.isSplitFiles}
                      styleAddition={
                         {
                            caption: this.styles.splitFilesFlag
                         }
                      }
                      {...this._CHECKBOX_SPLIT_FILES_PARAMS}
                    />
            </div>
          )`

   ###*
   * Обработчик рендера содержимого доп. ячейки для узлов иерархической таблицы
   *  данных для создания селектора версий печатной формы.
   *
   * @param {Object} reportRecord - запись узла.
   * @return {React-element}
   ###
   _onRenderReportVersionSelector: (reportRecord) ->
      reportVersions = _.get(reportRecord, @_GET_CHAINS.versions)

      if reportVersions?
         `(
            <DropDown ref={this._REFS.versionSelector}
                      list={reportVersions}
                      initItem={_.first(reportVersions)}
                      onClick={this._onClickVersionSelector}
                      {...this._VERSION_SELECTOR_DROPDOWN_PARAMS}
                    />
          )`

   ###*
   * Функция формирования динамической формы на основе полученных данных из API.
   *
   * @return {React-element}
   ###
   _getDynamicForm: ->
      paramsForDynamicForm = @state.paramsForDynamicForm


      if paramsForDynamicForm?
         isError = paramsForDynamicForm.error?

         if isError
            @_getErrorMessageContainer(paramsForDynamicForm.error)
         else
            `(
               <DynamicForm ref={this._REFS.dynamicForm}
                            presetParams={
                               {
                                  fields: paramsForDynamicForm.fields
                               }
                            }
                            sectionConstraints={paramsForDynamicForm.constraints}
                            isUseImplementation={this.props.isUseImplementation}
                             isMergeImplementation={this.props.isMergeImplementation}
                            implementationStore={this.props.implementationStore}
                            {...this._DYNAMIC_FORM_PARAMS}
                         />
             )`

   ###*
   * Функция рендера содержимого последнего шага мастера, выводящая надпись о
   *  завершинии формирования файла и ссылкой на повторное скачивание.
   *
   * @return {React-element}
   ###
   _getDownloadContent: ->
      reportFileParams = @state.reportFileParams

      content =
         if reportFileParams?
            if reportFileParams.url?
               `(
                  <Button onClick={this._downloadFile}
                                      {...this._BUTTON_DOWNLOAD_AGAIN_PARAMS}
                                    />
                )`
            else if reportFileParams.error?
               @_getErrorMessageContainer(reportFileParams.error)

      `(
         <div>{content}</div>
      )`

   ###*
   * Функция создания контейнера для вывода переданного сообщения об ошибке.
   *
   * @param {String} errorMessage - сообщение об ошибке.
   * @return {React-element}
   ###
   _getErrorMessageContainer: (errorMessage) ->
      `(<div style={this.styles.errorMessage}>{errorMessage}</div>)`

   ###*
   * Функция выбора записей по только отмеченным строкам. По переданным маркерам
   *  выбранности запрашивает запись в компоненте таблицы и сохраняет каждую запись
   *  в массиве.
   *
   * @param {Object} markedNodes - маркеры выбранности для узлов.
   * @return {Object}
   ###
   _getReportsListTableSelectedFormsWithVersions: (markedNodes) ->
      refNames = @_REFS
      reportListTable = @refs[refNames.clerk].refs[refNames.reportListTable]
      selectedRecords = reportListTable.getSelectedRecords(markedNodes, true)
      formVersions = {}

      for nodePath, isMarked of markedNodes
         if isMarked
            nodeElement = reportListTable.getRowElement(nodePath)

            formVersions[nodePath] =
               if nodeElement?
                  nodeElement.refs[@_REFS.versionSelector].getSelectedValue()

      if !_.isEmpty(selectedRecords) and !_.isEmpty(formVersions)
         records: selectedRecords
         versions: formVersions

   ###*
   * Функция подготовки данных для формировани динамической формы. На основе
   *  выбранной печатной формы и ассоциаций делает запрос в API для подготовки
   *  данных для формирования компонента динамической формы.
   *
   * @return
   ###
   _getParamsForDynamicForm: ->
      endpoints = @_ENDPOINTS

      @_sendRequest(
         endpoint: @_constructEndpoint(endpoints.new, endpoints.root)
         requestType: @_REQUEST_TYPES.get
         queryParams:
            report_params: JSON.stringify(@state.reportParams)
            instance_key: @props.instance.key
         callback: @_getDataForDynamicFormResponse
      )

   ###*
   * Функция подготовки данных для скачивания готового файла(ов) печатной формы
   *  данные для которой были подготовлены на предыдущих шагах.
   *
   * @return
   ###
   _getReportFileParams: ->
      endpoints = @_ENDPOINTS

      @_sendRequest(
         endpoint: @_constructEndpoint(endpoints.create, endpoints.root)
         requestType: @_REQUEST_TYPES.post
         requestParams: @state.serializedFormData
         queryParams:
            report_params: JSON.stringify(@state.reportParams)
            instance_key: @props.instance.key
            report_format: @state.selectedFormat
            is_split_files: @state.isSplitFiles
         callback: @_getReportFileParamsResponse
      )

   ###*
   * Функция отправки запроса на формирование печатной формы. Отправляет
   *  выбранные печатные формы, формат и данные динамической формы,
   *  введенные пользователем.
   *
   * @return
   ###
   _getSerializedFormData: ->
      refNames = @_REFS
      dynamicForm = @refs[refNames.clerk].refs[refNames.dynamicForm]

      @setState serializedFormData: dynamicForm.getSerializedData()

   ###*
   * Функция обработки ответа на запрос списка доступных печатных форм. Устанавливает
   *  список доступных форм в состояние компонента.
   *
   * @param {Object}  error   - ошибки.
   * @param {Object} response - результат запроса(ответ).
   * @return
   ###
   _getReportsList: (error, response) ->
      reportsList = @_getResponseData(error, response).data

      @setState reportsList: reportsList

   ###*
   * Функция получения данных для создания динамической формы заполнения
   *  динамических правил при формировании печатной формы.
   *
   * @param {Object}  error  - ошибки.
   * @param {Object} response - результат запроса(ответ).
   * @return
   ###
   _getDataForDynamicFormResponse: (error, response) ->
      paramsForDynamicForm = @_getResponseData(error, response).data

      if paramsForDynamicForm?
         @setState paramsForDynamicForm: paramsForDynamicForm

   ###*
   * Функция получения данных для создания динамической формы заполнения
   *  динамических правил при формировании печатной формы.
   *
   * @param {Object}  error  - ошибки.
   * @param {Object} response - результат запроса(ответ).
   * @return
   ###
   _getReportFileParamsResponse: (error, response) ->
      reportFileParams = @_getResponseData(error, response).data

      if reportFileParams?
         @setState reportFileParams: reportFileParams

   ###*
   * Обработчик скролла контента шага мастера. Останавливает проброс события выше,
   *  для избежания скролла основного контента (не работает).
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onScrollClerkContent: (event) ->
      event.stopPropagation()
      event.preventDefault()

   ###*
   * Обработчик клика по селектору выбора версии печатной формы. Останавливает
   *  проброс события, чтобы не происходило событие клика по узлу таблицы.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickVersionSelector: (event) ->
      event.stopPropagation()

   ###*
   * Обработчик на отметку/снятие отметки со строки таблицы-списка. Выбирает
   *  все выбранные галочкой записи, и подготавливает хэш параметров для
   *  дальнейшего запроса в API интерфейса динамических параметров.
   *
   * @param {Array} nodePath - путь до текущего выбранного узла.
   * @param {Object} markedRows  - маркеры выбранности для узлов.
   * @return
   ###
   _onSelectRow: (nodePath, markedNodes) ->
      selectedFormParams =
         @_getReportsListTableSelectedFormsWithVersions(markedNodes)

      @setState
         reportParams: @_compileReportWithAssociationParams(selectedFormParams)

   ###*
   * Обработчик выбор формата из списка доступных.
   *
   * @param {Object} selectedFormatParams - параметры выборанного формата.
   * @return
   ###
   _onSelectFormat: (selectedFormat) ->
      @setState selectedFormat: selectedFormat.name

   ###*
   * Обработчик выбора пункта Формировать файлы отдельно.
   *
   * @return
   ###
   _onClickSplitCheckBox: ->
      @setState
         isSplitFiles: !@state.isSplitFiles

   ###*
   * Обработчик клика по кнопке перехода вперед по шагам мастера.
   *
   * @param {Object} step - параметры шага на который перешли.
   * @return
   ###
   _onClickForwardClerk: (step) ->
      clerkSteps = @_CLERK_STEPS_SCAFFOLD

      switch step.name
         when clerkSteps.download.name
            @_getSerializedFormData()

   ###*
   * Обработчик клика по кнопке перехода назад по шагам мастера. В зависимости
   *  от имени флага сбрасывает те или иные параметры
   *
   * @param {Object} step - параметры шага на который перешли.
   * @return
   ###
   _onClickBackwardClerk: (step) ->
      clerkSteps = @_CLERK_STEPS_SCAFFOLD

      switch step.name
         when clerkSteps.list.name
            @setState
               reportParams: null
               paramsForDynamicForm: null
         when clerkSteps.form.name
            @setState
               reportFileParams: null
               isFileDownloaded: false

   ###*
   * Функция скачивания файле печатной формы. Осуществляет скачивание, если
   *  заданы параметры файла.
   *
   * @return
   ###
   _downloadFile: ->
      reportFileParams = @state.reportFileParams

      if reportFileParams? and reportFileParams.url?
         window.open(reportFileParams.url, @_NEW_WINDOW_MARKER)

         @setState isFileDownloaded: true

   ###*
   * Функция отправки начального запроса на получения списка доступных
   *  печатных форм.
   *
   * @return
   ###
   _sendInitRequest: ->
      rootEndpoint = @_ENDPOINTS.root

      @_sendRequest(
         endpoint: @_constructEndpoint(@_API_ACTIONS.index, rootEndpoint)
         requestType: @_REQUEST_TYPES.get
         queryParams:
            current_action: location.pathname
         callback: @_getReportsList
      )

   ###*
   * Функция подготовки параметров шагов для компонента-мастера
   *
   * @return {Array<Object>} - массив параметров шагов мастера.
   ###
   _prepareClerkSteps: ->
      scaffold = _.cloneDeep(@_CLERK_STEPS_SCAFFOLD)
      listStep = scaffold.list
      formStep = scaffold.form
      downloadStep = scaffold.download
      reportsList = @state.reportsList
      paramsForDynamicForm = @state.paramsForDynamicForm
      serializedFormData = @state.serializedFormData
      reportFileParams = @state.reportFileParams
      reportPreparer = this
      validatorMessages = @_VALIDATOR_MESSAGES

      if reportsList?
         listStep.render = @_getList
      else
         listStep.initRequest = @_sendInitRequest

      listStep.validations =
         after:
            handler: @_validateReportSelect
            message: validatorMessages.reportNotSelect

      if paramsForDynamicForm?
         formStep.render = @_getDynamicForm
      else
         formStep.initRequest = @_getParamsForDynamicForm

      if reportFileParams?
         downloadStep.render = @_getDownloadContent
      else
         downloadStep.initRequest = @_getReportFileParams

      [listStep, formStep, downloadStep]

   ###*
   * Валидатор после шага выбора формы. Проверяет была ли выбранна
   *  печатная форма, если не была выбрана валидацию не проходит.
   *
   * @return {Boolean}
   ###
   _validateReportSelect: ->
      reportParams = @state.reportParams

      reportParams? and (reportParams.key? or !_.isEmpty(reportParams.associations))

   ###*
   * Функция сброки параметров по выбранной печатной форме с ассоциациями
   *  (приложениями). По переданным выбранным записям составляет параметры для
   *  основной печатной формы и выбранных ассоциаций. Алгоритм будет корректно
   *  работать при одном уровне вложенности иерархии печатных форм. Если выбранно
   *  одновременно несколько форм-ассоциаций - выбирает только ассоциации для
   *  одного родителя (первого).
   *
   * @param {Object} selectedFormParams - параметры выбранных форм.
   * @return {Object} - параметры выбранных печатных форм. Вид:
   *     {String, Number} key  - ключ выбранной печатной формы(корневой)
   *     {String} version      - версия выбранной печатной формы.
   *     {Object} associations - набор выбранных ассоциаций. Вид:
   *           {String} key: {String} version.
   ###
   _compileReportWithAssociationParams: (selectedFormParams) ->
      return unless selectedFormParams?

      selectedRecords = selectedFormParams.records
      selectedVersions = selectedFormParams.versions
      childsAttribute = @_CHILDS_RECORD_ATTRIBUTE
      associations = {}
      selectedRecordKeys = []

      # Перебираем все записи и ищем родительскую запись. Если она найдена -
      #  берем её и получаем у нее дочерние записи.
      for selectedRecordParams in selectedRecords
         continue unless selectedRecordParams?

         record = selectedRecordParams.record
         childRecords = record[childsAttribute]
         selectedRecordKeys.push record.key

         unless selectedRecordParams.parent?
            parentRecord = record

      # Если среди выбранных есть родительская запись(она же корневая) -
      #  выполняем полноценный алгоритм выбора печатной формы с версией + ассоциации.
      # Иначе - перебираем все выбранные записи и берем все записи с одинаковой
      #  родительской записью, остальные отбрасываем.
      if parentRecord? and !_.isEmpty(parentRecord)
         childRecords = parentRecord[childsAttribute]
         parentKey = parentRecord.key
         parentVersion = selectedVersions[parentKey.toString()]

         if childRecords?
            selectedChildRecords = []

            for childRecord in childRecords
               if _.includes(selectedRecordKeys, childRecord.key)
                  selectedChildRecords.push childRecord

            if _.isEmpty selectedChildRecords
               selectedChildRecords = childRecords

            for selectedRecord in selectedChildRecords
               selectedChildKey = selectedRecord.key
               childNodePath = [parentKey, selectedChildKey].join()
               associations[selectedChildKey] =
                  selectedVersions[childNodePath] or null
      else
         firstRecordParent = _.head(selectedRecords).parent
         selectedParentKey = firstRecordParent.key

         for selectedRecordParams in selectedRecords
            record = selectedRecordParams.record
            recordKey = record.key
            recordParentKey = selectedRecordParams.parent.key

            if recordParentKey is selectedParentKey
               recordNodePath = [selectedParentKey, recordKey].join()
               associations[recordKey] = selectedVersions[recordNodePath]

      key: parentKey
      version: parentVersion
      associations: associations




module.exports = ReportPreparer
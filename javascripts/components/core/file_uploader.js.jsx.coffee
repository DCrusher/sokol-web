###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin            - общие стили для компонентов.
* HelpersMixin           - функции-хэлперы для компонентов.
* ByteSizeConverterMixin - модуль конвертации размеров файлов.
* string-template        - модуль для формирования строк из шаблонов.
* keymirror              - модуль для генерации "зеркального" хэша.
* superagent             - модуль запросов к бизнес-логике.
* lodash                 - модуль служебных операций.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
ByteSizeConverterMixin = require('../mixins/byte_size_converter')
format = require('string-template')
keyMirror = require('keymirror')
request = require('superagent')
_ = require('lodash')


###* Зависимости: компоненты
* Button        - кнопка.
* AjaxLoader    - компонент загрузчика.
###
Button = require('components/core/button')
AjaxLoader = require('components/core/ajax_loader')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COMMON_PADDING = constants.commonPadding
_COLORS = constants.color

###* Компонент: компонент загрузки файлов в файловое хранилище.
*
* @props:
*  {Object, Number} attachment  - параметры прикрепленного вложения. Параметр
*                                 может быть задан в 2-х видах:
*                                 {Object} - в виде хэша параметров. Вид:
*                                    {String} file  - путь до файла.
*                                    {String} thumb - путь до миниатюры.
*                                    {String} size  - размер файла.
*                                    {String} name  - имя файла.
*                                    {String} id    - идентификатор файла.
*                                 {Number} - в виде ключа экземпляра файла.
*                                 Если параметр задан в виде хэша с корректными
*                                 параметрами - создается вложение в шатном виде с
*                                 заданными параметрами.
*                                 Если параметр задан в виде ключа вложения -
*                                 при монтировании компонента посылается запрос
*                                 на получение параметров вложения - и при успешном
*                                 ответе создается вложения в шатном виде.
*     {String} name             - имя поля для хранения идентификатора вложения.
*     {String} uploadFieldName  - имя поля для формирования запроса на загрузку файла.
*     {String} uploadEndpoint   - адрес загрузки файла.
*     {String} instanceEndpoint - шаблон адреса доступа к экземпляру вложения
*                                 (для удаления или получения параметров вложения).
* @state
*     {Object} file - загружаемый файл.
*     {Object} progressParams - параметры прогресса загрузки.
*     {Object} requestObject - запрос на загрузку файла.
*     {Object} attachmentResult - ответные параметры загрузки файла.
*     {Boolean} isMouseOnSelector - флаг того, что над селектором находится курсор
*                                   (для подсветки).
*###
FileUploader = React.createClass
   # @const {Object} - параметры селектора выбора файла для загруки.
   _SELECTOR_PARAMS:
      title: 'Выбрать файл'
      icon: 'paperclip'

   # @const {Object} - используемые типы полей ввода.
   _INPUT_TYPES: keyMirror(
      file: null
      hidden: null
   )

   # @const {Object} - строковые литералы используемые для форматирования текста
   #                   ошибок.
   _CHARS:
      empty: ''
      newLine: '\n'
      colon: ':'
      tab: '\t'

   # @const {Object} - ключи хэша для доступа к параметрам вложения.
   _ATTACHMENT_KEYS: keyMirror(
      file: null
      thumb: null
      id: null
      name: null
   )

   # @const {Object} - ключи хэша для доступа к параметрам файла.
   _FILE_PARAM_KEYS: keyMirror(
      name: null,
      size: null,
      id: null
   )

   # @const {Object} - параметры стандартной ошибки загрузки файла.
   _STANDARD_ERROR_PARAMS:
      title: 'Файл не был загружен'
      text: 'Возможно заданы некорректные параметры адреса загрузки. Код ответа: '

   # @const {Object} - используемые ссылки на элементы.
   _REFS: keyMirror(
      fileInput: null
   )

   # @const {Array} - набор успешных кодов ответа загрузки файла.
   _SUCCESS_STATUS_CODES: [200, 201]

   # @const {String} - всплывающая подсказка на прогресс-баре.
   _PROGRESS_TITLE: 'Подождите, идет загрузка'

   # @const {String} - высплывающая подсказка на кнопке отмены загрузки файла.
   _BUTTON_ABORT_TITLE: 'Отменить'

   # @const {String} - всплывающая подсказка на кнопке удаления вложения.
   _BUTTON_DELETE_TITLE: 'Удалить вложение'

   # @const {String} - наименование события на которое подписываемся от объекта
   #                   отправки запроса для получения параметров прогресса.
   _PROGRESS_EVENT_NAME: 'progress'

   # @const {String} - ключ хэша для считывания ошибок из параметров ответа.
   _ERRORS_KEY: 'errors'

   # @const {String} - наименование иконки для кнопки-маркера ошибок.
   _ERRORS_ICON: 'times-circle'

   # @const {String} - префикс для иконок Font Awesome.
   _FA_CLASS_PREFIX: 'fa fa-'

   # @const {String} - наименование поля, в котором на БЛ передается идентификатор
   #                   уже загруженного файла.
   _ATTACHMENT_FIELD: 'attachment'

   # @const {String} - всплывающая подсказка выводимая на наименовании файла, когда
   #                   он не был загружен из-за ошибок.
   _ATTACHMENT_FAILED_TITLE: 'Файл не был загружен'

   # @const {String} - префикс текста ошибок выводимых при наведении на кнопку-маркер
   #                   ошибок.
   _ATTACHMENT_ERRORS_PREFIX: 'При загрузке файла возникли ошибки'

   mixins: [HelpersMixin, ByteSizeConverterMixin]

   propTypes:
      attachment: React.PropTypes.oneOfType([
          React.PropTypes.number,
          React.PropTypes.object
      ])
      name: React.PropTypes.string
      uploadFieldName: React.PropTypes.string
      uploadEndpoint: React.PropTypes.string
      instanceEndpoint: React.PropTypes.string

   styles:
      fileInput:
         opacity: 0
         position: 'relative'
         left: -140
         cursor: 'pointer'
      buttonSelect:
         fontSize: 20
         padding: 0
      selectorContainer:
         width: 21
         height: 22
         overflow: 'hidden'
         display: 'inline-block'
         whiteSpace: 'nowrap'
         cursor: 'pointer'
         fontSize: 21
         color: _COLORS.link1
      selectorContainerWithHover:
         color: _COLORS.highlight1
      uploadContent:
         height: 20
         display: 'inline-block'
      selectorCell:
         cursor: 'pointer'
      progressCell:
         paddingBottom: _COMMON_PADDING
      selectedFileNameCell:
         overflow: 'hidden'
         textOverflow: 'ellipsis'
         maxWidth: 300
         whiteSpace: 'nowrap'
         color: _COLORS.hierarchy2
         fontSize: 12
      selectedFileNameWithErrorCell:
         color: _COLORS.alert
      selectedFileSizeCell:
         fontSize: 12
      attachmentErrorsMarker:
         color: _COLORS.alert

   getInitialState: ->
      file: @_getInitFileParams()
      attachmentResult: @_getInitAttachmentResult()
      requestObject: null
      progressParams: {}
      isMouseOnSelector: false
      isAttachmentDelete: false

   render: ->
      selectorParams = @_SELECTOR_PARAMS

      `(
         <table>
            <tbody>
               <tr>
                  <td title={selectorParams.title}>
                     <div style={this._getSelectorContainerStyle()}
                          onMouseEnter={this._onMouseEnterSelectorContainer}
                          onMouseLeave={this._onMouseLeaveSelectorContainer}>
                        <i className={this._FA_CLASS_PREFIX + selectorParams.icon} />
                        <input style={this.styles.fileInput}
                               ref={this._REFS.fileInput}
                               type={this._INPUT_TYPES.file}
                               onChange={this._onChangeFileInput}
                               fileName={this.state.file}
                             />
                        {this._getContentAsFormField()}
                     </div>
                     <AjaxLoader target={this}
                                 isShown={this._isWaitingForInitAttachment()}
                                 isAdaptive={true}
                              />
                  </td>
                  {this._getProcessContent()}
               </tr>
            </tbody>
         </table>
       )`

   componentWillMount: ->
      attachment = @props.attachment
      instanceEndpoint = @props.instanceEndpoint

      # Если задано вложение в виде числа-ключа и при этом задан адрес
      #  получения экземпляра вложения - отправляем запрос на получение
      #  параметров вложения и при успешном ответе - устанавливаем параметры
      #  вложения в состояние компонента.
      if attachment? and _.isNumber(attachment) and instanceEndpoint?
         attachmentEndpoint = format(instanceEndpoint, attachment)

         request.get(attachmentEndpoint)
                .end ((res) ->
                   attachment = JSON.parse(res.text)

                   if attachment.errors?
                     @setState
                        attachmentResult:
                           errors: attachment.errors
                   else
                      @setState
                         file: @_getFileParams(attachment)
                         attachmentResult: @_getAttachmentParams(attachment)

               ).bind(this)

   ###*
   * Функция получения содержимого загрузки файла - либо прогрессбара загрузки.
   *  либо результат загрузки файла.
   *
   * @return {React-element} - содержимое загрузки.
   ###
   _getProcessContent: ->
      progressParams = @state.progressParams

      if progressParams? and !_.isEmpty progressParams
         progressMax = progressParams.max
         progressValue = progressParams.value
         isInProgress = progressValue < progressMax

         #processContent =
         if isInProgress
            @_getProgressContent(progressMax, progressValue)
         else
            @_getAttachedContent()
      else if @_isHasAttachment()
         @_getAttachedContent()

   ###*
   * Функция получения содержимого процесса загрузки файла - прогрессбара и
   *  кнопки отмены загрузки.
   *
   * @param {Number} progressMax - мак. значение прогресса.
   * @param {Number} progressValue - текущее значение прогресса.
   * @return {Array<React-element>} - набор ячеек таблицы с содержимым.
   ###
   _getProgressContent: (progressMax, progressValue)->

      [
         `(
            <td key={1}
                style={this.styles.progressCell}  >
               <progress title={this._PROGRESS_TITLE}
                         max={progressMax}
                         value={progressValue}>
                  <span>{progressValue} / {progressMax}</span>
               </progress>
            </td>)`
           `(<td key={2}
                 style={this.styles.progressCell} >
               <Button isClear={true}
                       title={this._BUTTON_ABORT_TITLE}
                       onClick={this._onClickAbortRequest} />
            </td>
         )`
      ]

   ###*
   * Функция получения содержимого загруженного файла - имя, размер, ошибки,
   *   кнопку удаления вложения.
   *
   * @return {Array<React-element>} - набор ячеек таблицы с содержимым.
   ###
   _getAttachedContent: ->
      file = @state.file
      fileParamKeys = @_FILE_PARAM_KEYS
      fileNameKey = fileParamKeys.name
      fileSizeKey = fileParamKeys.size
      cells = []

      if file? and file[fileNameKey]?
         fileName = file[fileNameKey]
         fileSize = file[fileSizeKey]
         attachmentResult = @state.attachmentResult
         isWithErrors = @_isAttachmentWithErrors()

         if isWithErrors
            cells.push(
               `(<td key={0}>
                     <Button isLink={true}
                             isWithoutPadding={true}
                             icon={this._ERRORS_ICON}
                             title={this._getAttachemntErrorsTitle(attachmentResult)}
                             styleAddition={this.styles.attachmentErrorsMarker} />
                 </td>)`
            )

         cells = cells.concat(
            [
               `(<td key={1}
                     style={this._getFileNameCellStyle(isWithErrors)}
                     title={this._getFileTitle(fileName, isWithErrors)}>
                     {fileName}
                 </td>)`
               `(<td style={this.styles.selectedFileSizeCell}
                     key={2}>
                     ({this._convertSize(fileSize)})
                 </td>)`
               `(<td key={3}>
                     <img src={attachmentResult.thumb}/>
                 </td>)`
               `(<td key={4}>
                     <Button isClear={true}
                             title={this._BUTTON_DELETE_TITLE}
                             onClick={this._onClickDeleteAttachment} />
                 </td>)`
            ]
         )

      cells

   ###*
   * Функция получения поля со ссылкой на загруженный объект-файл в БД для
   *  встраивания компонента как поля формы в качестве имя поля формы применяет
   *  параметр @props.name.
   *
   * @return {React-element, undefined}
   ###
   _getContentAsFormField: ->
      unless @_isAttachmentWithErrors()
         attachmentResult = @state.attachmentResult
         attachmentId = attachmentResult.id

         if attachmentId?
            `(
               <input type={this._INPUT_TYPES.hidden}
                      name={this.props.name}
                      value={attachmentId} />
             )`

   ###*
   * Функция получения начального значения параметров вложения. Считывается
   *  на основе параметров @props.attachment.
   *
   * @return {Object}
   ###
   _getInitAttachmentResult: ->

      if @_isHasFullyParamsInitAttachment()
         @_getAttachmentParams(@props.attachment)
      else
         {}

   ###*
   * Функция получения начального значения параметров файла. Считывается
   *  на основе параметров @props.attachment
   *
   * @return {Object}
   ###
   _getInitFileParams: ->
      if @_isHasFullyParamsInitAttachment()
         @_getFileParams(@props.attachment)

   ###*
   * Функция получения параметров вложения из экземпляра вложения. Получает
   *  пути до файла и миниатюры, а также ключ вложения.
   *
   * @return {Object}
   ###
   _getAttachmentParams: (attachmentInstance) ->
      attachmentKeys = @_ATTACHMENT_KEYS
      idKey = attachmentKeys.id
      thumbKey = attachmentKeys.thumb
      fileKey = attachmentKeys.file
      result = {}

      result[idKey] = attachmentInstance[idKey]
      result[thumbKey] = attachmentInstance[thumbKey]
      result[fileKey] = attachmentInstance[fileKey]

      result

   ###*
   * Функция получения параметров файла экземпляра вложения. Получает
   *  имя и размер файла.
   *
   * @return {Object}
   ###
   _getFileParams: (attachmentInstance)->
      fileKeys = @_FILE_PARAM_KEYS
      nameKey = fileKeys.name
      sizekey = fileKeys.size
      attachmentName = attachmentInstance[nameKey]
      attachmentSize = attachmentInstance[sizekey]

      if attachmentName? and attachmentSize
         result = {}
         result[nameKey] = attachmentName
         result[sizekey] = attachmentSize
         result

   ###*
   * Функция получения стиля контейнера селектора файла(скрепки).
   *
   * @return {Object} - скомпанованный стиль.
   ###
   _getSelectorContainerStyle: ->
      @computeStyles @styles.selectorContainer,
                     @state.isMouseOnSelector and @styles.selectorContainerWithHover

   ###*
   * Функция получения стиля ячейки отображения имени загруженного файла.
   *
   * @param {Boolean} isWithErrors - флаг наличия ошибок.
   * @return {Object} - скомпанованный стиль.
   ###
   _getFileNameCellStyle: (isWithErrors)->
      @computeStyles @styles.selectedFileNameCell,
                     isWithErrors and @styles.selectedFileNameWithErrorCell

   ###*
   * Функция получения всплывающей подсказки для кнопки-отображения ошибок.
   *
   * @param {Object} attachmentResult - хэш с параметрами результата загрузки файла.
   * @return {String} - строка с ошибками, содержащей форматирование.
   ###
   _getAttachemntErrorsTitle: (attachmentResult) ->
      errorsPrefix = @_ATTACHMENT_ERRORS_PREFIX
      chars = @_CHARS
      emptyChar = chars.empty
      newLineChar = chars.newLine
      colonChar = chars.colon
      tabChar = chars.tab

      errorsByFields = attachmentResult[@_ERRORS_KEY]
      errorsElements = []

      for uploadFieldName, errors of errorsByFields

         errorsString = if _.isArray errors
                           errors.join(
                                [
                                   newLineChar
                                   tabChar
                                   tabChar
                                ].join emptyChar
                             )
                        else
                           JSON.stringify errors

         errorsElements.push [
                                uploadFieldName
                                colonChar
                                newLineChar
                                tabChar
                                tabChar
                                errorsString
                             ].join emptyChar

      [
         errorsPrefix
         colonChar
         newLineChar
         errorsElements.join(newLineChar)
      ].join emptyChar

   ###*
   * Функция получения всплывающей подсказки на имени загруженного файла. В зависимости
   *  от того были ли ошибки при загрузке или нет - создает различную подсказку.
   *
   * @param {String} fileName      - имя файла.
   * @param {Boolean} isWithErrors - флаг наличия ошибок.
   * @return {String} - строка для подсказки.
   ###
   _getFileTitle: (fileName, isWithErrors) ->
      if isWithErrors
         @_ATTACHMENT_FAILED_TITLE
      else
         fileName

   ###*
   * Функция получения идентификатора успешно(без ошибок) загруженного файла.
   *  Если при загрузке возникли какие-либо ошибки или файл ещё не был загружен -
   *  возвращает 0.
   *
   * @return {Number} - идентификатор.
   ###
   _getAttachedIdentifier: ->
      attachmentResult = @state.attachmentResult

      if attachmentResult? and !_.isEmpty(attachmentResult)
         return attachmentResult[@_FILE_PARAM_KEYS.id] unless @_isAttachmentWithErrors()

      0

   ###*
   * Функция для получения сконвертированного объекта ответа(при возможности конвертации).
   *  Если конвертация не возможна, возвращает false.
   *
   * @param {String} responseText - строка ответа.
   * @return {Object, Boolean} - сконвертированный ответ или false.
   ###
   _getJsonFromResponseText: (responseText) ->
      try
         JSON.parse responseText
      catch
         false

   ###*
   * Функция-предикат для определения были ли запрощены данные для начальной
   *  установки параметров вложения.
   *
   * @return {Boolean}
   ###
   _isWaitingForInitAttachment: ->
      attachmentResult = @state.attachmentResult
      attachment = @props.attachment

      !!(attachment? and _.isEmpty(attachmentResult)) and !@state.isAttachmentDelete

   ###*
   * Функция-предикат для определения заданы ли параметры изначального вложения.
   *  (уже существующего). Параметры вложения ожидаются в виде хэша параметров
   *  с заданным ключом и ссылкой на миниатюру.
   *
   * @return {Boolean}
   ###
   _isHasFullyParamsInitAttachment: ->
      @_isCorrectAttachment(@props.attachment)

   ###*
   * Функция-предикат для определения являются ли параметры вложения корректными.
   *
   * @param {Object} attachment - параметры вложения.
   * @return {Boolean}
   ###
   _isCorrectAttachment: (attachment) ->
      attachmentKeys = @_ATTACHMENT_KEYS

      attachment? and !_.isEmpty(attachment) and _.isPlainObject(attachment) and
          _.has(attachment, attachmentKeys.id) and
          _.has(attachment, attachmentKeys.thumb)

   ###*
   * Функция-предикат для определения являются ли параметры вложения корректными.
   *
   * @param {Object} fileParams - параметры файла.
   * @return {Boolean}
   ###
   _isCorrectFile: (fileParams) ->
      fileKeys = @_FILE_PARAM_KEYS

      fileParams? and !_.isEmpty(fileParams) and _.isPlainObject(fileParams) and
          _.has(fileParams, fileKeys.name) and
          _.has(fileParams, fileKeys.size)

   ###*
   * Функция-предикат для определения задано ли вложение для компонента.
   *
   * @return {Boolean}
   ###
   _isHasAttachment: ->
      @_isCorrectAttachment(@state.attachmentResult) and
      @_isCorrectFile(@state.file)


   ###*
   * Функция-предикат на определение наличия в результатах вложения ошибок.
   *
   * @return {Boolean} - флаг наличия ошибок.
   ###
   _isAttachmentWithErrors: ->
      attachmentResult = @state.attachmentResult
      errorsKey = @_ERRORS_KEY

      attachmentResult.hasOwnProperty errorsKey

   ###*
   * Функция-предикат для определения содержит ли ответ ошибки.
   *
   * @param {Object} response - параметры ответа.
   * @return {Boolean} - флаг наличия ошибок.
   ###
   _isResponseWithErrors: (response) ->
      !response.ok or !(response.status in @_SUCCESS_STATUS_CODES)

   ###*
   * Обработчик на наведение курсора мыши на контейнер селектора файла(со скрепкой).
   *  Устанавливает состояние подсветки селектора.
   *
   * @return
   ###
   _onMouseEnterSelectorContainer: ->
      @setState isMouseOnSelector: true

   ###*
   * Обработчик на уход курсора мыши с контейнера селектора файла(со скрепкой).
   *  Убирает состояние подсветки селектора.
   *
   * @return
   ###
   _onMouseLeaveSelectorContainer: ->
      @setState isMouseOnSelector: false

   ###*
   * Обработчик клика на кнопку отмены загрузки файла. Проверяет возможность отмены
   *  запроса и отменяет его и сбрасывает состояния прогресса и параметров загружаемого файла.
   *
   * @return
   ###
   _onClickAbortRequest: ->
      @_checkAndAbortRequest()

      @setState
         file: null
         progressParams: {}

   ###*
   * Обработчик клика на кнопку удаления вложения. Если файл был успешно прикреплен
   *  (без ошибок) то отправляет запрос на БЛ для удаления вложения, иначе просто
   *  сбрасывает параметры загруженного файла.
   *
   * @return
   ###
   _onClickDeleteAttachment: ->

      # Если были ошибки при загрузке файла, то просто очистим
      #  состояние компонента.
      # Иначе, отправляем запроса удаления файла на БЛ.
      if @_isAttachmentWithErrors()
         @setState
            attachmentResult: {}
            file: {}
      else
         uploadEndpoint = @props.uploadEndpoint
         deleteEndpoint = format(@props.instanceEndpoint, @_getAttachedIdentifier())

         request.del(deleteEndpoint)
            .end ((res) ->
               @refs[@_REFS.fileInput].value = @_CHARS.empty

               @setState
                  isAttachmentDelete: true
                  attachmentResult: {}
                  file: null
            ).bind(this)
   ###*
   * Обработчик изменения значения в поле загрузки файла. Считывает параметры
   *  выбранного файла и отправляет запрос в БЛ на загрузку файла. На обработчик
   *  процесса загрузки сохраняет параметры прогресса (для отображения на прогрессбаре).
   *  По результатам запроса запускает функцию обработки ответа загрузки.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onChangeFileInput: (event) ->
      file = event.target.files[0]
      uploader = this
      fieldName = @props.uploadFieldName

      @_checkAndAbortRequest()

      requestObject =
         request
            .post(@props.uploadEndpoint)
            .field(@_ATTACHMENT_FIELD, @_getAttachedIdentifier())
            .attach(fieldName, file, file.name)
            .end (response) ->
               uploader._handleUploadResponse(response)
            .on(uploader._PROGRESS_EVENT_NAME, (event)->
               uploader.setState
                  progressParams:
                     max: event.total
                     value: event.loaded
            )

      @setState
         file: file
         isAttachmentDelete: false
         attachmentResult: {}
         requestObject: requestObject

   ###*
   * Функция обработки ответа загрузки файла.
   *
   * @param {Object} response - параметры ответа.
   * @return
   ###
   _handleUploadResponse: (response) ->
      responseResult = @_getJsonFromResponseText(response.text)

      if @_isResponseWithErrors(response)
         errorParams = @_STANDARD_ERROR_PARAMS

         unless responseResult
            responseResult = errors: {}
            responseResult.errors[errorParams.title] = errorParams.text + response.status

      @setState
         attachmentResult: responseResult
         requestObject: null

   ###*
   * Функция проверки возможности отмены запроса на загрузку файла(есть объект запроса).
   *  и отмены запроса.
   *
   * @return
   ###
   _checkAndAbortRequest: ->
      requestObject = @state.requestObject

      if requestObject? and !_.isEmpty requestObject
         requestObject.abort()

module.exports = FileUploader
###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin       - общие стили для компонентов.
* keymirror         - модуль для генерации "зеркального" хэша.
* MoneyFormatter    - модуль для форматирования денежного значения.
* lodash            - модуль служебных операций.
###
StylesMixin = require('components/mixins/styles')
keyMirror = require('keymirror')
MoneyFormatter = require('components/mixins/money_formatter')
_ = require('lodash')

###* Зависимости: компоненты
* Button            - кнопка.
* Label   - лейбл
###
Button = require('components/core/button')
Label = require('components/core/label')

###* Константы.
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

###*
* Модуль рендеров для реестра консолидированных документальынх оснований.
*  Содержит функции произвольного отображения данных по различных документальынх
*  оснований.
###
DocumentRegistryRenders =

   # @const {String} - строка-перфикс классов для иконок FontAwesome.
   _D_FA_ICON_PREFIX: 'fa fa-'

   # @const {Object} - используемые символы.
   _D_CHARS:
      empty: ''
      colon: ':'
      space: ' '
      dash: '-'
      brStart: '('
      brEnd: ')'
      newLine: '/n'
      number: '№'

   # @const {Object} - стандартные параметры для различных лейблов.
   _D_LABEL_DEFAULT_PARAMS:
      marker:
         isWithoutPadding: true
         isLink: true
         isInlineBlock: true
         type: 'ordinaryLight'
      number:
         isInlineBlock: true
         isRounded: true
         isOutlined: true
      name:
         isLink: true
         fontSize: 16
      type:
         isWithoutPadding: true
         isLink: true
      subject:
         type: 'ordinaryLight'
         isLink: true
         iconPosition: 'top'
      date:
         isBlock: true
         isLink: true

   # @const {Object} - параметры для субъектов документального основания.
   _DOC_BASIS_SUBJECT_PARAMS:
      payment:
         icon: 'rub'
         markerType: 'alertLight'
         inscription: 'платежные документы'
      ownership:
         icon: 'book'
      ownershipStatus:
         icon: 'anchor'
         markerType: 'exclamationLight'
         inscription: 'документы статуса правообладания'
      paymentPlan:
         icon: 'money'
         markerType: 'exclamationLight'
         inscription: 'документы платежного графика правообладания'
      legalEntityEmployee:
         icon: 'street-view'
         markerType: 'infoLight'
         inscription: 'распорядительные документы сотрудника'
      property:
         icon: 'building-o'
      propertyChange:
         icon: 'exchange'
         markerType: 'successLight'
         inscription: 'документы на внесение изменений по имуществу'
      propertyMilestone:
         icon: 'briefcase'
         markerType: 'successLight'
         inscription: 'документы-основания ввода имущества'
      default:
         icon: 'clipboard'
         markerType: 'ordinaryLight'
         inscription: 'документы-основания'


   # @const {Object} - хэш с иконками для кнопок отображения служебных дат записи.
   _D_RECORD_DATE_ICONS:
      updated: 'refresh'
      created: 'file-o'

   # @const {Object} - используемые значения группировок для ячеек таблицы.
   _D_ROWSPANS:
      registry: 2
      subject: 2
      card: 3

   # @const {Object} - параметры для маркеров.
   _D_MARKER_PARAMS:
      count:
         icon: 'file-text-o'
         title: 'Количество документов'
      docType:
         icon: 'file-text'

   # @const {String} - типы лейблов (для компонента Label)
   _D_LABEL_TYPES: keyMirror(
      ordinary: null
      ordinaryLight: null
      info: null
      success: null
      exclamation: null
      alert: null
   )

   # @const {String} - наименование документального основания по-умолчанию.
   _DEFAULT_DOC_BASIS_NAME: 'документальное основание'

   # @const {String} - наименование поля суммы платежа.
   _PAYMENT_TOTAL_AMOUNT_CAPTION: 'Сумма платежа'

   # @const {String} - тип целочисленного поля (используется при формировании
   #                   денежного значения).
   _D_INT_FIELD_TYPE: 'integer'

   # @const {Number} - максимальное кол-во документов отображемых в реестре в
   #                   составе одного документального основания.
   _MAX_DOCUMENTS_COUNT_IN_REGISTRY: 3

   # @const {String} - строка-индикатор наличия документов не отрисованных
   #                   в реестре, входящих в состав документального основания.
   _DOCUMENT_OVERFLOWED_INDICATOR: '...'

   documentStyles:
      documentTable:
         width: '100%'
      documentNumberCell:
         paddingRight: 10
         verticalAlign: 'top'
      markersCell:
         verticalAlign: 'top'
      documentDataCell:
         width: '30%'
         whiteSpace: 'normal'
         color: _COLORS.dark
         padding: _COMMON_PADDING
         verticalAlign: 'top'
      documentSubjectCell:
         width: '60%'
         whiteSpace: 'normal'
         verticalAlign: 'top'
         textAlign: 'left'
      documentParamSecondary:
         color: _COLORS.hierarchy3
         fontSize: 12
         padding: _COMMON_PADDING
      documentElementName:
         maxWidth: 80
         textDecoration: 'underline'
         overflow: 'hidden'
         textOverflow: 'ellipsis'
         paddingRight: _COMMON_PADDING
         display: 'inline-block'
         whiteSpace: 'nowrap'
         verticalAlign: 'middle'
      numberLabel:
         minWidth: 50
         verticalAlign: 'top'
         textAlign: 'left'
      orderedList:
         padding: 0
         margin: 0
      numberLabelIcon:
         fontSize: 25
      documentIcon:
         fontSize: 30
      documentIconCard:
         fontSize: 50
         color: _COLORS.hierarchy3
      subjectLabelIcon:
         fontSize: 30
      serviceDateCell:
         color: _COLORS.hierarchy3
         minWidth: 100
      docTypeIcon:
         paddingRight: 3
         fontSize: 14
      valueContainer:
         padding: _COMMON_PADDING
      altenaviteCaption:
         color: _COLORS.hierarchy3
      indivisibleContentPart:
         display: 'inline-block'
      subjectElementTableContainer:
         maxWidth: 260
         verticalAlign: 'top'
         display: 'inline-block'
      objectCardDocumentTable:
         maxWidth: 700
      objectCardServiceDateCell:
         minWidth: 120
         paddingRight: 20
      objectCardDocumentNumberCell:
         height: 60
      objectCardDocumentDataCell:
         width: '40%'
         verticalAlign: 'top'
         textAlign: 'left'
      objectCardDocumentSubjectCell:
         width: '50%'
         verticalAlign: 'top'
         textAlign: 'left'
      objectCardMarkersCell:
         height: '100%'
         verticalAlign: 'top'

   ###*
   * Функция рендера ячейки отображения правообладания основного реестра.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object} record            - запись.
   * @return {React-element} - содержимое ячейки для отображения документа.
   ###
   _onRenderDocumentCell: (rowRef, record) ->
      rowspans = @_D_ROWSPANS
      regRowSpan = rowspans.registry
      styles = @documentStyles
      secondaryContentContainerStyle = styles.documentParamSecondary
      documentElements = @_getDocumentElements(record)
      mainElements = documentElements.main
      documentsElements = documentElements.documents
      subjectElements = documentElements.subjects
      markerElements = documentElements.markers
      datesElements = documentElements.dates

      `(
         <table style={styles.documentTable}>
            <tbody>
               <tr>
                  <td style={styles.documentNumberCell}>
                     {documentElements.number}
                  </td>
                  <td style={styles.documentDataCell}
                      rowSpan={regRowSpan}>
                     {mainElements.name}
                     {this._getDocumentsForRegistry(documentsElements,
                                                    secondaryContentContainerStyle)}
                  </td>
                  <td rowSpan={regRowSpan}
                      style={styles.documentSubjectCell}>
                     {subjectElements.ownership}
                     {subjectElements.ownershipStatus}
                     {subjectElements.paymentPlan}

                     {subjectElements.payment}
                     {subjectElements.paymentCorrection}

                     {subjectElements.legalEntityEmployee}

                     {subjectElements.property}
                     {subjectElements.propertyMilestone}
                     {subjectElements.propertyChange}
                  </td>
                  <td style={styles.serviceDateCell}
                      rowSpan={regRowSpan}>
                     {datesElements.created}
                     {datesElements.updated}
                  </td>
               </tr>
               <tr>
                  <td style={styles.markersCell}>
                     {markerElements.count}
                  </td>
               </tr>
            </tbody>
         </table>
       )`

   ###*
   * Функция рендера основного содержимого карточки объекта.
   *
   * @param {Object} record - запись.
   * @return {React-element} - содержимое карточки для отображения докум. основания.
   ###
   _onRenderDocumentObjectCardContent: (record) ->
      rowspans = @_D_ROWSPANS
      cardRowSpan = rowspans.card
      styles = @documentStyles
      secondaryContentContainerStyle = styles.documentParamSecondary
      serviceDateAdditionParams =
         styleAddition:
            common: styles.objectCardServiceDateLabel
         type: @_D_LABEL_TYPES.ordinaryLight
         isWithoutPadding: true
         fontSize: 10

      additionParams =
         created_at: serviceDateAdditionParams
         updated_at: serviceDateAdditionParams
         isIconForCard: true
         isAnotherCaption: true

      documentElements = @_getDocumentElements(record, additionParams)
      mainElements = documentElements.main
      documentsElements = documentElements.documents
      subjectElements = documentElements.subjects
      markerElements = documentElements.markers
      datesElements = documentElements.dates

      `(
         <table style={styles.objectCardDocumentTable}>
            <tbody>
               <tr>
                  <td style={styles.objectCardDocumentNumberCell}>
                     {documentElements.number}
                  </td>
                  <td style={styles.objectCardDocumentDataCell}
                      rowSpan={cardRowSpan}>
                     {mainElements.name}
                     {this._getDocumentsForRegistry(documentsElements,
                                                    secondaryContentContainerStyle)}
                  </td>
                  <td rowSpan={cardRowSpan}
                      style={styles.objectCardDocumentSubjectCell}>
                     {subjectElements.ownership}
                     {subjectElements.ownershipStatus}
                     {subjectElements.paymentPlan}

                     {subjectElements.payment}

                     {subjectElements.legalEntityEmployee}

                     {subjectElements.property}
                     {subjectElements.propertyMilestone}
                     {subjectElements.propertyChange}
                  </td>
               </tr>
               <tr>
                  <td style={styles.objectCardMarkersCell}>
                     {markerElements.count}
                  </td>
               </tr>
               <tr>
                  <td style={styles.objectCardServiceDateCell}>
                     {datesElements.created}
                     {datesElements.updated}
                  </td>
               </tr>
            </tbody>
         </table>
       )`

   ###*
   * Функция получения контейнера с отображеннымми элементами документов
   *  (маркер типа, наименование, номер, дата). Формирует до 3-х элементов
   *  документов. Если документов больше 3-х - формирует маркер наличия не
   *  отрисованных документов.
   *
   * @param {Array} documentsElements - набор элементов для отображения документов
   *                                    в составе документального основания.
   * @param {Object} containerStyle   - стиль контейнера.
   * @return {React-element}
   ###
   _getDocumentsForRegistry: (documentsElements, containerStyle) ->
      maxDocCount = @_MAX_DOCUMENTS_COUNT_IN_REGISTRY
      return if _.isEmpty(documentsElements)

      isDocumentOverflowed = documentsElements.length > maxDocCount

      docListElements =
         for element, idx in documentsElements
            if idx < maxDocCount
               `(
                   <li key={idx}>{element}</li>
                )`

      if isDocumentOverflowed
         docListElements.push(
            `(
                <li key={maxDocCount + 1}>
                  {this._DOCUMENT_OVERFLOWED_INDICATOR}
                </li>
             )`
         )

      containerComputedStyle = _.merge(@documentStyles.orderedList, containerStyle)

      `(
          <ol style={containerComputedStyle}>
             {docListElements}
          </ol>
      )`

   ###*
   * Функция получения лейбла сервисной даты (создание, обновление)
   *
   * @param {Date} date        - выводимая дата.
   * @param {String} title     - выводимая подсказка.
   * @param {Boolean} isUpdate - флаг того, что лейбл для даты обновления.
   * @param {Object} additsionParams - дополнительные параметры.
   * @return {React-element}
   ###
   _getDServiceDateLabel: (date, title, isUpdate, additionParams) ->
      labelDefaults = @_D_LABEL_DEFAULT_PARAMS
      recordDateIcons = @_D_RECORD_DATE_ICONS

      icon =
         if isUpdate
            recordDateIcons.updated
         else
            recordDateIcons.created

      `(
          <Label content={date}
                 title={title}
                 icon={icon}
                 {...labelDefaults.date}
                 {...additionParams}
          />
      )`

   ###*
   * Функция получения лейбла наименования документального основания с
   *  отображением описания во всплывающей подсказке.
   *
   * @param {String} name            - наименование документального основания.
   * @param {String} description     - описание документального основания.
   * @param {Object} additsionParams - дополнительные параметры.
   * @return {React-element}
   ###
   _getDNameLabel: (name, description, additionParams) ->
      labelDefaults = @_D_LABEL_DEFAULT_PARAMS

      `(
          <Label content={name}
                 title={description}
                 {...labelDefaults.name}
                 {...additionParams}
          />
      )`

   ###*
   * Функция получения лейбла номера документа.
   *
   * @param {Object} idField      - параметры поля 'id'.
   * @param {String} docBasisName - наименование документального основания.
   * @param {Object} subjectFlags - набор флагов субъектов документального основания.
   * @return {React-element}
   ###
   _getDNumberLabel: (idField, docBasisName, subjectFlags) ->
      labelDefaults = @_D_LABEL_DEFAULT_PARAMS
      docBasisSubjectParams = @_DOC_BASIS_SUBJECT_PARAMS
      chars = @_D_CHARS
      numberChar = chars.number
      spaceChar = chars.space
      idValue = idField.value
      styles = @documentStyles

      styleAddition =
         common: styles.numberLabel
         icon: styles.numberLabelIcon

      docBasisLabelParams =
         if subjectFlags.isHasPayment
            docBasisSubjectParams.payment
         else if subjectFlags.isHasOwnershipStatus
            docBasisSubjectParams.ownershipStatus
         else if subjectFlags.isHasPaymentPlan
            docBasisSubjectParams.paymentPlan
         else if subjectFlags.isHasLegalEntityEmployee
            docBasisSubjectParams.legalEntityEmployee
         else if subjectFlags.isHasPropertyChange
            docBasisSubjectParams.propertyChange
         else if subjectFlags.isHasPropertyMilestone
            docBasisSubjectParams.propertyMilestone
         else
            docBasisSubjectParams.default

      lableTitle =
         [
            docBasisLabelParams.inscription
            spaceChar
            chars.number
            idField.value
         ].join chars.empty

      `(
          <Label content={chars.number + idValue}
                 title={lableTitle}
                 icon={docBasisLabelParams.icon}
                 type={docBasisLabelParams.markerType}
                 styleAddition={styleAddition}
                 {...labelDefaults.number}
               />
       )`

   ###*
   * Функция получения неделимого элемента содержимого: Лейбл наименование : значение.
   *  Не создает элемент, если было передано пустое значение (caption).
   *
   * @param {Object} params - параметры. Вид:
   *        {Object, String} caption     - заголовок (надпись-пояснение).
   *        {Object, String} title       - всплывающая подсказка при наведении на элемент.
   *        {Object, String} value       - значение.
   *        {Boolean} isAnotherCaption   - флаг использования заголовка с отличающимся стилем.
   *        {Boolean} isWithoutContainer - флаг необходимости отказа от
   *                                       помещения значения в контейнер.
   * @return {React-element, undefined}
   ###
   _getDNameValueElement: (params) ->
      caption = params.caption
      value = params.value
      title = params.title
      isAnotherCaption = params.isAnotherCaption
      isWithoutContainer = params.isWithoutContainer

      # Не формируем элемент, если задано пустое значение.
      isEmptyObject = (_.isPlainObject(value) or _.isArray(value)) and _.isEmpty(value)
      isEmptyString = _.isString(value) and _.isEmpty(_.trim(value))
      if !value? or isEmptyObject or isEmptyString
         return

      styles = @documentStyles
      chars = @_D_CHARS

      captionValue =
         if caption?
            [
               caption
               chars.colon
            ].join chars.empty

      valueElement = if isWithoutContainer
         value
      else
         `(
             <span style={styles.valueContainer}>
               {value}
             </span>
         )`

      `(
          <span style={styles.indivisibleContentPart}
                title={title}>
            <span style={isAnotherCaption ? styles.altenaviteCaption : null}>
               {captionValue}
            </span>
             {valueElement}
         </span>
      )`

   ###*
   * Функция получения элемента для отображения документа.
   *
   * @param {Object} document          - параметры документа (поля, связки).
   * @param {Boolean} isAnotherCaption - флаг отличающегося заголовка для значения поля.
   * @return {React-element}
   ###
   _getDocumentElement: (document, isAnotherCaption) ->
      markerParams = @_D_MARKER_PARAMS
      rowspans = @_D_ROWSPANS
      labelDefaults = @_D_LABEL_DEFAULT_PARAMS
      chars = @_D_CHARS
      styles = @documentStyles
      documentFields = document.fields
      documentReflections = document.reflections
      docRowSpan = rowspans.documentElement

      if documentFields? and !_.isEmpty documentFields
         nameField = documentFields.name
         dateField = documentFields.document_date
         numberField = documentFields.number

      if documentReflections? and !_.isEmpty documentReflections
         documentType = documentReflections.document_type

         if documentType? and !_.isEmpty(documentType)
            documentTypeFields = documentType.value.fields

            documentTypeName = documentTypeFields.name.value
      nameElement = nameField.value
      dateFieldCaption = dateField.caption
      dateViewableCaption = _.toLower(_.words(dateFieldCaption)[0])
      dateElement =
         @_getDNameValueElement(
            caption: dateViewableCaption
            title: dateFieldCaption
            value: dateField.value
            isAnotherCaption: isAnotherCaption
         )
      numberElement =
         @_getDNameValueElement(
            caption: chars.number
            title: numberField.caption
            value: numberField.value
            isAnotherCaption: isAnotherCaption
         )

      documentTypeMarker =
         if documentTypeName?
            `(
                <Label title={documentTypeName}
                       icon={markerParams.docType.icon}
                       styleAddition={{common: styles.docTypeIcon}}
                    {...labelDefaults.marker}
                />
            )`

      `(
          <div>
             {documentTypeMarker}
             <span style={styles.documentElementName}
                   title={nameElement} >
                {nameElement}
             </span>
             {dateElement}
             {numberElement}
          </div>
      )`

   ###*
   * Функция получения элемента для отображения субъекта документального
   *  основания - платежа.
   *
   * @param {Object} paymentRefl - параметры связки с платежом.
   * @param {Boolean} isAnotherCaption - флаг отличающегося заголовка для значения поля.
   * @return {React-element}
   ###
   _getPaymentElement: (paymentRefl, isAnotherCaption) ->
      paymentValue = paymentRefl.value

      if paymentValue and !_.isEmpty paymentValue
         docBasisSubjectParams = @_DOC_BASIS_SUBJECT_PARAMS
         paymentCaption = paymentRefl.caption
         paymentFields = paymentValue.fields
         paymentContent = paymentValue.payment_content
         paymentKey = paymentValue.key

         if paymentFields? and !_.isEmpty paymentFields
            statusNameField = paymentFields.status_name

            statusElement = @_getDNameValueElement(
               caption: statusNameField.caption
               value: statusNameField.value
               isAnotherCaption: isAnotherCaption
            )

         if paymentContent? and !_.isEmpty paymentContent
            sumAmount =
               MoneyFormatter.formatMoney(paymentContent.total_amount,
                                          @_D_INT_FIELD_TYPE,
                                          true)

            sumElement = @_getDNameValueElement(
               caption: @_PAYMENT_TOTAL_AMOUNT_CAPTION
               value: sumAmount
               isAnotherCaption: isAnotherCaption
            )

         labelParams =
            icon: docBasisSubjectParams.payment.icon
            title: paymentCaption
            content: paymentKey

         secondary =
            `(
                <span>
                   {sumElement}
                   {statusElement}
                </span>
             )`

         @_constructSubjectElement(labelParams, paymentCaption, secondary)

   ###*
   * Функция получения элемента для отображения субъекта документального
   *  основания - правообладание.
   *
   * @param {Object} ownershipRefl - параметры связки с правообладанием.
   * @param {Boolean} isAnotherCaption - флаг отличающегося заголовка для значения поля.
   * @return {React-element}
   ###
   _getOwnershipElement: (ownershipRefl, isAnotherCaption) ->
      ownershipValue = ownershipRefl.value

      if ownershipValue and !_.isEmpty ownershipValue
         docBasisSubjectParams = @_DOC_BASIS_SUBJECT_PARAMS
         ownershipCaption = ownershipRefl.caption
         ownershipFields = ownershipValue.fields
         ownershipKey = ownershipValue.key

         if ownershipFields? and !_.isEmpty ownershipFields
            propertyId = ownershipFields.property_id
            rightholderId = ownershipFields.rightholder_id
            dateStart = ownershipFields.date_start
            dateEnd = ownershipFields.date_end

            propertyIdElement = @_getDNameValueElement(
               caption: propertyId.caption
               value: propertyId.value
               isAnotherCaption: isAnotherCaption
            )

            rightholderIdElement = @_getDNameValueElement(
               caption: rightholderId.caption
               value: rightholderId.value
               isAnotherCaption: isAnotherCaption
            )

            dateStartElement = @_getDNameValueElement(
               caption: dateStart.caption
               value: dateStart.value
               isAnotherCaption: isAnotherCaption
            )

            dateEndElement = @_getDNameValueElement(
               caption: dateEnd.caption
               value: dateEnd.value
               isAnotherCaption: isAnotherCaption
            )

         labelParams =
            icon: docBasisSubjectParams.ownership.icon
            title: ownershipCaption
            content: ownershipKey

         secondary =
            `(
                <span>
                   {propertyIdElement}
                   {rightholderIdElement}
                   {dateStartElement}
                   {dateEndElement}
                </span>
            )`

         @_constructSubjectElement(labelParams, ownershipCaption, secondary)

   ###*
   * Функция получения элемента для отображения субъекта документального
   *  основания - статуса правообладания.
   *
   * @param {Object} ownershipStatusRefl - параметры связки со статусом правообладания.
   * @param {Boolean} isAnotherCaption - флаг отличающегося заголовка для значения поля.
   * @return {React-element}
   ###
   _getOwnershipStatusElement:  (ownershipStatusRefl, isAnotherCaption) ->
      ownershipStatusValue = ownershipStatusRefl.value

      if ownershipStatusValue and !_.isEmpty ownershipStatusValue
         docBasisSubjectParams = @_DOC_BASIS_SUBJECT_PARAMS
         ownershipStatusCaption = ownershipStatusRefl.caption
         ownershipStatusFields = ownershipStatusValue.fields
         ownershipStatusKey = ownershipStatusValue.key

         if ownershipStatusFields? and !_.isEmpty ownershipStatusFields
            statusName = ownershipStatusFields.status_name
            date = ownershipStatusFields.date_set_status

            statusNameElement = @_getDNameValueElement(
               caption: statusName.caption
               value: statusName.value
               isAnotherCaption: isAnotherCaption
            )

            dateElement = @_getDNameValueElement(
               caption: date.caption
               value: date.value
               isAnotherCaption: isAnotherCaption
            )

         labelParams =
            icon: docBasisSubjectParams.ownershipStatus.icon
            title: ownershipStatusCaption
            content: ownershipStatusKey

         secondary =
            `(
                <span>
                   {statusNameElement}
                   {dateElement}
                </span>
            )`

         @_constructSubjectElement(labelParams, ownershipStatusCaption, secondary)

   ###*
   * Функция получения элемента для отображения субъекта документального
   *  основания - платежного графика.
   *
   * @param {Object} paymentPlanRefl - параметры связки с платежным графиком правообладания.
   * @param {Boolean} isAnotherCaption - флаг отличающегося заголовка для значения поля.
   * @return {React-element}
   ###
   _getPaymentPlanElement: (paymentPlanRefl, isAnotherCaption) ->
      paymentPlanValue = paymentPlanRefl.value

      if paymentPlanValue and !_.isEmpty paymentPlanValue
         docBasisSubjectParams = @_DOC_BASIS_SUBJECT_PARAMS
         paymentPlanCaption = paymentPlanRefl.caption
         paymentPlanFields = paymentPlanValue.fields
         paymentPlanKey = paymentPlanValue.key

         if paymentPlanFields? and !_.isEmpty paymentPlanFields
            dateStart = paymentPlanFields.date_start
            dateEnd = paymentPlanFields.date_end
            period = paymentPlanFields.period

            dateStartElement = @_getDNameValueElement(
               caption: dateStart.caption
               value: dateStart.value
               isAnotherCaption: isAnotherCaption
            )

            dateEndElement = @_getDNameValueElement(
               caption: dateEnd.caption
               value: dateEnd.value
               isAnotherCaption: isAnotherCaption
            )

            periodElement = @_getDNameValueElement(
               caption: period.caption
               value: period.value
               isAnotherCaption: isAnotherCaption
            )

         labelParams =
            icon: docBasisSubjectParams.paymentPlan.icon
            title: paymentPlanCaption
            content: paymentPlanKey

         secondary =
            `(
                <span>
                   {periodElement}
                   {dateStartElement}
                   {dateEndElement}
                </span>
            )`
         @_constructSubjectElement(labelParams, paymentPlanCaption, secondary)

   ###*
   * Функция получения элемента для отображения субъекта документального
   *  основания - сотрудника юрлица.
   *
   * @param {Object} legalEntityEmployeeRefl - параметры связки с сотрудником юрлица.
   * @param {Boolean} isAnotherCaption - флаг отличающегося заголовка для значения поля.
   * @return {React-element}
   ###
   _getLegalEntityEmployeeElement: (legalEntityEmployeeRefl, isAnotherCaption) ->
      legalEntityEmployeeValue = legalEntityEmployeeRefl.value

      if legalEntityEmployeeValue and !_.isEmpty legalEntityEmployeeValue
         docBasisSubjectParams = @_DOC_BASIS_SUBJECT_PARAMS
         chars = @_D_CHARS
         legalEntityCaption = legalEntityEmployeeRefl.caption
         employeeFields = legalEntityEmployeeValue.fields
         employeeReflections = legalEntityEmployeeValue.reflections
         employeeKey = legalEntityEmployeeValue.key

         if employeeFields? and !_.isEmpty employeeFields
            gender = employeeFields.gender
            employeeName =
               [
                  employeeFields.last_name.value
                  employeeFields.first_name.value
                  employeeFields.middle_name.value
               ].join chars.space

            genderElement =
               if gender? and !_.isEmpty gender
                  @_getDNameValueElement(
                     caption: gender.caption
                     value: gender.value
                     isAnotherCaption: isAnotherCaption
                  )

         if employeeReflections? and !_.isEmpty employeeReflections
            employeePost = employeeReflections.legal_entity_post

            if employeePost? and !_.isEmpty employeePost
               postName = employeePost.value.fields.name.value

         labelParams =
            icon: docBasisSubjectParams.legalEntityEmployee.icon
            title: legalEntityCaption
            content: employeeKey

         secondary =
            `(
                <span>
                   {postName}
                   {genderElement}
                </span>
             )`


         @_constructSubjectElement(labelParams, employeeName, secondary)

   ###*
   * Функция получения элемента для отображения субъекта документального
   *  основания - имуществом.
   *
   * @param {Object} propertyRefl - параметры связки с имуществом.
   * @param {Boolean} isAnotherCaption - флаг отличающегося заголовка для значения поля.
   * @return {React-element}
   ###
   _getPropertyElement: (propertyRefl, isAnotherCaption) ->
      propertyValue = propertyRefl.value

      if propertyValue and !_.isEmpty propertyValue
         docBasisSubjectParams = @_DOC_BASIS_SUBJECT_PARAMS
         propertyCaption = propertyRefl.caption
         propertyFields = propertyValue.fields
         propertyKey = propertyValue.key

         if propertyFields? and !_.isEmpty propertyFields
            propertyName = propertyFields.name.value
            cadastreNumber = propertyFields.real_cadastre_number
            cadastreCost = propertyFields.real_cadastre_cost
            objectStatus = propertyFields.object_status

            cadastreNumberElement = @_getDNameValueElement(
               caption: cadastreNumber.caption
               value: cadastreNumber.value
               isAnotherCaption: isAnotherCaption
            )

            cadastreCostElement = @_getDNameValueElement(
               caption: cadastreCost.caption
               value: cadastreCost.value
               isAnotherCaption: isAnotherCaption
            )

            objectStatusElement = @_getDNameValueElement(
               caption: objectStatus.caption
               value: objectStatus.value
               isAnotherCaption: isAnotherCaption
            )

         labelParams =
            icon: docBasisSubjectParams.property.icon
            title: propertyCaption
            content: propertyKey

         secondary =
            `(
                <span>
                   {cadastreNumberElement}
                   {cadastreCostElement}
                   {objectStatusElement}
                </span>
            )`
         @_constructSubjectElement(labelParams, propertyName, secondary)
   ###*
   * Функция получения элемента для отображения субъекта документального
   *  основания - с вехой жизненного цикла имущества.
   *
   * @param {Object} propertyMilestoneRefl - параметры связки с вехой жизненного цикла имущества.
   * @param {Boolean} isAnotherCaption - флаг отличающегося заголовка для значения поля.
   * @return {React-element}
   ###
   _getPropertyMilestoneElement: (propertyMilestoneRefl, isAnotherCaption) ->
      propertyMilestoneValue = propertyMilestoneRefl.value

      if propertyMilestoneValue and !_.isEmpty propertyMilestoneValue
         docBasisSubjectParams = @_DOC_BASIS_SUBJECT_PARAMS
         propertyMilestoneCaption = propertyMilestoneRefl.caption
         propertyMilestoneFields = propertyMilestoneValue.fields
         propertyMilestoneKey = propertyMilestoneValue.key

         if propertyMilestoneFields? and !_.isEmpty propertyMilestoneFields
            eventDate = propertyMilestoneFields.event_date
            eventType = propertyMilestoneFields.event_type

            dateElement = @_getDNameValueElement(
               caption: eventDate.caption
               value: eventDate.value
               isAnotherCaption: isAnotherCaption
            )

            eventTypeElement = @_getDNameValueElement(
               caption: eventType.caption
               value: eventType.value
               isAnotherCaption: isAnotherCaption
            )

         labelParams =
            icon: docBasisSubjectParams.propertyMilestone.icon
            title: propertyMilestoneCaption
            content: propertyMilestoneKey

         secondary =
            `(
                <span>
                   {dateElement}
                   {eventTypeElement}
                </span>
            )`

         @_constructSubjectElement(labelParams, propertyMilestoneCaption, secondary)


   ###*
   * Функция получения элемента для отображения субъекта документального
   *  основания - изменением по имуществу.
   *
   * @param {Object} propertyChangeRefl - параметры связки с изменением по имуществу.
   * @param {Boolean} isAnotherCaption - флаг отличающегося заголовка для значения поля.
   * @return {React-element}
   ###
   _getPropertyChangeElement: (propertyChangeRefl, isAnotherCaption) ->
      propertyChangeValue = propertyChangeRefl.value

      if propertyChangeValue and !_.isEmpty propertyChangeValue
         docBasisSubjectParams = @_DOC_BASIS_SUBJECT_PARAMS
         propertyChangeCaption = propertyChangeRefl.caption
         propertyChangeFields = propertyChangeValue.fields
         propertyChangeKey = propertyChangeValue.key

         if propertyChangeFields? and !_.isEmpty propertyChangeFields
            createdAt = propertyChangeFields.created_at
            updatedAt = propertyChangeFields.updated_at

            createdAtElement = @_getDNameValueElement(
               caption: createdAt.caption
               value: createdAt.value
               isAnotherCaption: isAnotherCaption
            )

            updatedAtElement = @_getDNameValueElement(
               caption: updatedAt.caption
               value: updatedAt.value
               isAnotherCaption: isAnotherCaption
            )

         labelParams =
            icon: docBasisSubjectParams.propertyChange.icon
            title: propertyChangeCaption
            content: propertyChangeKey

         secondary =
            `(
                <span>
                   {createdAtElement}
                   {updatedAtElement}
                </span>
            )`

         @_constructSubjectElement(labelParams, propertyChangeCaption, secondary)

   ###*
   * Функция получения элементов для отображения документа.
   *
   * @param {Object} record         - запись.
   * @param {Object} additionParams - доп. параметры для элементов.
   * @return {Object} - элементы
   ###
   _getDocumentElements: (record, additionParams) ->
      docBasisName = @_DEFAULT_DOC_BASIS_NAME
      labelDefaults = @_D_LABEL_DEFAULT_PARAMS
      chars = @_D_CHARS
      markerParams = @_D_MARKER_PARAMS
      markerCountParams = markerParams.count
      fields = record.fields
      reflections = record.reflections
      idField = fields.id
      documentsCount = 0

      # Считаем доп. параметры для формирования элементов, если они были заданы.
      if additionParams?
         createdDateAddition = additionParams.created_at
         updatedDateAddition = additionParams.updated_at
         isIconForCard = additionParams.isIconForCard
         isAnotherCaption = additionParams.isAnotherCaption

      if reflections?
         docBasis = reflections.documental_basis
         documents = reflections.documents
         ownership = reflections.ownership
         ownershipStatus = reflections.ownership_status
         paymentPlan = reflections.payment_plan
         payment = reflections.payment
         property = reflections.property
         propertyChange = reflections.property_change
         propertyMilestone = reflections.property_milestone
         legalEntityEmployee = reflections.legal_entity_employee
         isHasDocBasis = docBasis? and !_.isEmpty docBasis
         isHasDocuments = documents? and !_.isEmpty documents
         isHasPayment = payment? and !_.isEmpty payment
         isHasPaymentPlan = paymentPlan? and !_.isEmpty paymentPlan
         isHasOwnershipStatus = ownershipStatus? and !_.isEmpty ownershipStatus
         isHasOwnership = ownership? and !_.isEmpty ownership
         isHasProperty = property? and !_.isEmpty property
         isHasPropertyChange = propertyChange? and !_.isEmpty propertyChange
         isHasPropertyMilestone = propertyMilestone and !_.isEmpty propertyMilestone
         isHasLegalEntityEmployee = legalEntityEmployee? and
                                    !_.isEmpty legalEntityEmployee

         # Документальное основание.
         if isHasDocBasis
            docBasisFields = docBasis.value.fields

            if docBasisFields?
               createdDateParam = docBasisFields.created_at
               updatedDateParam = docBasisFields.updated_at
               createdDate = new Date(createdDateParam.value).toLocaleString()
               updatedDate = new Date(updatedDateParam.value).toLocaleString()
               docBasisNameValue = docBasisFields.name.value

               if docBasisNameValue? and docBasisNameValue isnt chars.empty
                  docBasisName = docBasisNameValue

               docBasisDescription = docBasisFields.description.value

         # Набор документов в основании.
         if isHasDocuments
            documentsValue = documents.value

            if documentsValue? and !_.isEmpty documentsValue
               documentsCount = documentsValue.length
               documentElements = []

               for document in documentsValue
                  documentElements.push @_getDocumentElement(document,
                                                             isAnotherCaption)
         # Платеж.
         if isHasPayment
            paymentElement = @_getPaymentElement(payment, isAnotherCaption)

         # Правообладание.
         if isHasOwnership
            ownershipElement =
               @_getOwnershipElement(ownership, isAnotherCaption)

         # Статус правообладания.
         if isHasOwnershipStatus
            ownershipStatusElement =
               @_getOwnershipStatusElement(ownershipStatus, isAnotherCaption)

         # Платежный график.
         if isHasPaymentPlan
            paymentPlanElement =
               @_getPaymentPlanElement(paymentPlan, isAnotherCaption)

         # Сотрудник правообладателя.
         if isHasLegalEntityEmployee
            legalEntityEmployeeElement =
               @_getLegalEntityEmployeeElement(legalEntityEmployee, isAnotherCaption)

         # Имущество.
         if isHasProperty
            propertyElement =
               @_getPropertyElement(property, isAnotherCaption)

         # Изменения по имуществу.
         if isHasPropertyChange
            propertyChangeElement =
               @_getPropertyChangeElement(propertyChange, isAnotherCaption)

         # Жизненные вехи по имуществу.
         if isHasPropertyMilestone
            propertyMilestoneElement =
               @_getPropertyMilestoneElement(propertyMilestone, isAnotherCaption)


      # Маркер кол-ва документов.
      docCountMarker =
         `(
            <Label content={documentsCount}
                   icon={markerCountParams.icon}
                   title={markerCountParams.title}
                   {...labelDefaults.marker}
                  />
          )`

      subjectFlags =
         isHasPayment: isHasPayment
         isHasPaymentPlan: isHasPaymentPlan
         isHasOwnershipStatus: isHasOwnershipStatus
         isHasOwnership: isHasOwnership
         isHasProperty: isHasProperty
         isHasPropertyChange: isHasPropertyChange
         isHasPropertyMilestone: isHasPropertyMilestone
         isHasLegalEntityEmployee: isHasLegalEntityEmployee

      main:
         name: @_getDNameLabel(docBasisName,
                               docBasisDescription)
      number: @_getDNumberLabel(idField, docBasisName, subjectFlags)
      documents: documentElements
      subjects:
         payment: paymentElement
         ownership: ownershipElement
         ownershipStatus: ownershipStatusElement
         paymentPlan: paymentPlanElement
         legalEntityEmployee: legalEntityEmployeeElement
         property: propertyElement
         propertyChange: propertyChangeElement
         propertyMilestone: propertyMilestoneElement
      markers:
         count: docCountMarker
      dates:
         created: @_getDServiceDateLabel(createdDate,
                                         createdDateParam.caption,
                                         false,
                                         createdDateAddition)
         updated: @_getDServiceDateLabel(updatedDate,
                                          updatedDateParam.caption,
                                          true,
                                          updatedDateAddition)

   ###*
   * Функция создания структуры узла для отображения субъекта документального
   *  основнания.
   *
   * @param {Object} labelParams - параметры для лейбла (иконка, подсказка, содержимое).
   * @param {String} caption     - заголовок субъекта.
   * @param {React-element} secondaryElements - построеннные второстепенные элементы.
   * @return {React-element}
   ###
   _constructSubjectElement: (labelParams, caption, secondaryElements) ->
      rowSpans = @_D_ROWSPANS
      labelDefaults = @_D_LABEL_DEFAULT_PARAMS
      styles = @documentStyles

      `(
          <table style={styles.subjectElementTableContainer}>
             <tbody>
             <tr>
                <td rowSpan={rowSpans.subject}>
                   <Label icon={labelParams.icon}
                          content={labelParams.content}
                          title={labelParams.title}
                          styleAddition={{icon: styles.subjectLabelIcon}}
                       {...labelDefaults.subject}
                   />
                </td>
                <td>
                   {caption}
                </td>
             </tr>
             <tr>
                <td style={styles.documentParamSecondary}>
                   {secondaryElements}
                </td>
             </tr>
             </tbody>
          </table>
      )`

module.exports = DocumentRegistryRenders
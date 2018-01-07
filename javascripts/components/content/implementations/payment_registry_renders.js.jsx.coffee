###* @jsx React.DOM ###

###* Зависимости: модули
* RightholderRegistryRenders - модуль произвольных рендеров ячеек таблицы данных
*                              для реестра правообладателей.
* PaymentPlanRenders         - модуль рендеров платежных графиков.
* PaymentRegistryHandlers    - модуль обработчиков АРМа приема платежей
* ImplementationStore        - модуль-хранилище стандартных реализаций.
* StylesMixin                - общие стили для компонентов.
* MoneyFormatter             - модуль для форматирования денежного значения.
* keymirror                  - модуль для генерации "зеркального" хэша.
* lodash                     - модуль служебных операций.
###
RightholderRegistryRenders = require('components/content/implementations/rightholder_registry_renders')
PaymentPlanRenders = require('components/content/implementations/payment_plan_renders')
PaymentRegistryHandlers = require('components/content/implementations/payment_registry_handlers')
StylesMixin = require('components/mixins/styles')
MoneyFormatter = require('components/mixins/money_formatter')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* Button          - кнопка.
* Label           - лейбл.
* Selector        - селектор.
* StreamContainer - контейнер в потоке.
###
Button = require('components/core/button')
Label = require('components/core/label')
Selector = require('components/core/selector')
StreamContainer = require('components/core/stream_container')

###* Константы.
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding
_COMMON_BORDER_RADUIS = StylesMixin.constants.commonBorderRadius

###*
* Модуль рендеров для реестра платежей. Содержит функции
*  отображения данных по платежам.
###
PaymentRegistryRenders =

   # @const {String} - строка-перфикс классов для иконок FontAwesome.
   _P_FA_ICON_PREFIX: 'fa fa-'

   # @const {Object} - используемые символы.
   _P_CHARS:
      empty: ''
      colon: ':'
      space: ' '
      dash: '-'
      brStart: '('
      brEnd: ')'
      newLine: '/n'

   # @const {Object} - хэш с иконками для кнопок отображения служебных дат записи.
   _P_RECORD_DATE_ICONS:
      updated: 'refresh'
      created: 'file-o'

   # @const {String} - типы лейблов (для компонента Label)
   _P_LABEL_TYPES: keyMirror(
      ordinary: null
      ordinaryLight: null
      info: null
      infoLight: null
      success: null
      successLight: null
      exclamation: null
      exclamationLight: null
      alert: null
      alertLight: null
   )

   # @const {Object} - стандартные параметры для различных лейблов.
   _P_LABEL_DEFAULT_PARAMS:
      number:
         isBlock: true
         isRounded: true
         isOutlined: true
         type: 'ordinaryLight'
      date:
         isBlock: true
         isLink: true
         isWithoutPadding: true
         fontSize: 10
         type: 'ordinaryLight'

   # @const {Object} - параметры для селектора платежного графика.
   _PAYMENT_PLAN_SELECTOR_PARAMS:
      name: 'payment_plan_id'
      isUseImplementation: true
      enableTotalClear: false
      dictionaryBrowserParams:
         openButton:
            caption:
               empty: 'Выбрать платежный график'
               selected: 'Изменить'
            position: 'top'
      dataTableParams:
         modelParams:
            name: 'payment_plan'

   # @const {Object} - заголовки для сервисных элементов платежа.
   _PAYMENT_CONTENT_ELEMENT_CAPTIONS:
      docGroup: 'Группа документа'
      docType: 'Тип документа'
      payerInn: 'ИНН плательщика'
      payerName: 'Плательщик'
      paymentKbk: 'КБК платежа'
      paymentOktmo: 'ОКТМО'
      purposeText: 'Назначение платежа'
      totalAmount: 'Сумма платежа'
      paymentKbkType: 'Тип КБК'
      receiverInn: 'ИНН получателя'
      receiverKpp: 'КПП получателя'
      lsNumber: 'Лицевой счет получателя'
      targetCode: 'Код цели'
      purpose: 'Назначение'

   # @const {Object} - параметры контейнера для отображения назначения платежа.
   _PURPOSE_STREAM_CONTAINER_PARAMS:
      ajarHeight: 48
      isTriggerTerminal: true
      areaParams:
         isWithoutSubstrate: true

   # @const {Object} - цепи для извлечения значений из вложенных хэшей
   _P_DIG_CHAINS:
      payerFromOwnership: [
         'payment_plan'
         'value'
         'reflections'
         'ownership'
         'value'
         'reflections'
         'rightholder'
      ]

   # @const {Object} - используемые значение группировок строк в таблице.
   _P_ROWSPANS:
      rightholder: 3

   # @const {Object} - используемые заголовки или пояснения.
   _P_TITLES:
      noPayer: 'Плательщик не задан'
      noPaymentPlan: 'Платежный график не задан'
      payer: 'Плательщик'

   # @const {String} - наименование целочисленного типа поля модели.
   _P_INT_FIELD_TYPE: 'integer'

   # @const {String} - заголовок для уточненных реквизитов.
   _CLARIFIED_ATTR_CAPTION: 'Уточненные аттрибуты:'

   # @const {Object} - иконки лейблов
   _P_ICONS:
      clarifiedAttributes: 'navicon'

   paymentStyles:
      id:
         verticalAlign: 'top'
         width: '10%'
      document:
         verticalAlign: 'top'
         width: '30%'
         maxWidth: 200
      paymentPlan:
         verticalAlign: 'top'
         width: '35%'
         padding: _COMMON_PADDING
      rightholder:
         verticalAlign: 'top'
         width: '25%'
         padding: _COMMON_PADDING
      secondaryData:
         fontSize: 12
         color: _COLORS.hierarchy3
      indivisibleContentPart:
         display: 'inline-block'
      captionContainer:
         color: _COLORS.hierarchy3
      valueContainer:
         padding: 3
      contentList:
         listStyle: 'none'
         padding: 0
         margin: 0
         fontSize: 12
      documentPurposeElement:
         whiteSpace: 'normal'
      documentPurposeContainer:
         padding: 3
         borderRadius: _COMMON_BORDER_RADUIS
         color: _COLORS.successDark
      iconCell:
         verticalAlign: 'middle'
         textAlign: 'center'
      rightholderAttributes:
         padding: _COMMON_PADDING
      paymentAttributesContainer:
         position: 'relative'
      clarifiedAttributesLabel:
         position: 'absolute'
         top: 0
         right: 0
      clarifiedAttributesTitleContainer:
         textAlign: 'left'


   ###*
   * Функция рендера ячейки идентификатор для реестра примема платежей.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object} record - параметры записи.
   * @return {React-element}
   ###
   _onRenderPaymentKeyCell: (rowRef, record) ->
      paymentKey = record.key
      paymentFields = record.fields
      labelDefaults = @_P_LABEL_DEFAULT_PARAMS
      styles = @paymentStyles

      if paymentFields?
         createdAt = paymentFields.created_at
         updatedAt = paymentFields.updated_at
         idField = paymentFields.id
         createdDate = new Date(createdAt.value).toLocaleString()
         updatedDate = new Date(updatedAt.value).toLocaleString()

         numberLabel =
            `(
               <Label content={idField.value}
                      title={idField.caption}
                      {...labelDefaults.number}
                  />
             )`

         createdLabel = @_getPServiceDateLabel(createdDate, createdAt.caption)
         updatedLabel = @_getPServiceDateLabel(updatedDate,
                                               updatedAt.caption,
                                               true)

      `(
         <span>
            {numberLabel}
            {createdLabel}
            {updatedLabel}
         </span>
       )`

   ###*
   * Функция рендера содержимого ячейки документа. Формирует данные платежа
   *  и данные платежного документа.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object} record - параметры записи.
   * @return {React-element}
   ###
   _onRenderPaymentDocumentCell: (rowRef, record) ->
      paymentFields = record.fields
      paymentContent = record.payment_content
      paymentReflections = record.reflections
      streamContainerParams = _.cloneDeep(@_PURPOSE_STREAM_CONTAINER_PARAMS)
      styles = @paymentStyles
      paymentCaptions = @_PAYMENT_CONTENT_ELEMENT_CAPTIONS

      ###*
      * Функция формирования элемента списка на основе переданного массива элементов.
      *
      * @param {Array<React-element>} elements - массив элементов.
      * @return {React-element}
      ###
      getElementsList = ((elements) ->
         liElements = elements.map (item, idx) ->
            `(
               <li key={idx}
                   style={item.style}>
                   {item.element}
               </li>
             )`

         `(<ul style={this.paymentStyles.contentList}>{liElements}</ul>)`
      ).bind(this)

      if paymentContent? and !_.isEmpty paymentContent
         oktmoCaption = paymentCaptions.paymentOktmo
         kbkCaption = paymentCaptions.paymentKbk

         docGroup = paymentContent.doc_group
         docType = paymentContent.doc_type
         docTypeName = docType.name if docType? and !_.isEmpty(docType)
         payerInn = paymentContent.payer_inn
         payerName = paymentContent.payer_name
         paymentOktmo = paymentContent.payment_oktmo
         paymentKbk = paymentContent.payment_kbk
         purposeText = paymentContent.purpose_text
         payedSumAmount = MoneyFormatter.formatMoney(paymentContent.total_amount,
                                                     @_P_INT_FIELD_TYPE,
                                                     true)
         paymentClarifiedAttributes = paymentContent.clarified_attributes
         mainPaymentElements = [
            { element: @_getPNameValueElement(paymentCaptions.docGroup, docGroup) }
            { element: @_getPNameValueElement(paymentCaptions.docType, docTypeName) }
            { element: @_getPNameValueElement(paymentCaptions.payerInn, payerInn) }
            { element: @_getPNameValueElement(paymentCaptions.payerName, payerName) }
            { element: @_getPNameValueElement(kbkCaption, paymentKbk) }
            { element: @_getPNameValueElement(oktmoCaption, paymentOktmo) }
            { element: @_getPNameValueElement(paymentCaptions.totalAmount, payedSumAmount) }
         ]

         if paymentClarifiedAttributes? and !_.isEmpty(paymentClarifiedAttributes)
            clarifiedOktmo = paymentClarifiedAttributes.payment_oktmo
            clarifiedKbk = paymentClarifiedAttributes.payment_kbk
            clarifiedKbkType = paymentClarifiedAttributes.payment_kbk_type
            clarifiedReceiverInn = paymentClarifiedAttributes.receiver_inn
            clarifiedReceiverKpp = paymentClarifiedAttributes.receiver_kpp
            clarifiedLsNumber = paymentClarifiedAttributes.ls_number
            clarifiedTargetCode = paymentClarifiedAttributes.target_code
            clarifiedPurpose = paymentClarifiedAttributes.purpose


            clarifiedElements = [
               { element: @_getPNameValueElement(oktmoCaption, clarifiedOktmo) }
               { element: @_getPNameValueElement(kbkCaption, clarifiedKbk) }
               { element: @_getPNameValueElement(paymentCaptions.paymentKbkType, clarifiedKbkType) }
               { element: @_getPNameValueElement(paymentCaptions.receiverInn, clarifiedReceiverInn) }
               { element: @_getPNameValueElement(paymentCaptions.receiverKpp, clarifiedReceiverKpp) }
               { element: @_getPNameValueElement(paymentCaptions.lsNumber, clarifiedLsNumber) }
               { element: @_getPNameValueElement(paymentCaptions.targetCode, clarifiedTargetCode) }
               { element: @_getPNameValueElement(paymentCaptions.purpose, clarifiedPurpose) }
            ]

            clarifiedList = getElementsList(clarifiedElements)
            labelTitle =
               `(
                   <div style={styles.clarifiedAttributesTitleContainer}>
                     <div>{this._CLARIFIED_ATTR_CAPTION}</div>
                     {clarifiedList}
                   </div>
                )`

            clarifiedButton =
               `(
                  <Label title={labelTitle}
                         icon={this._P_ICONS.clarifiedAttributes}
                         styleAddition={
                           {
                              common:styles.clarifiedAttributesLabel
                           }
                         }
                        />
               )`

      # Если назначение платежа считано - зададим доп. параметры для области
      #  потокового контейнера для лучшего выделения.
      if purposeText? and (purposeText isnt @_P_CHARS.empty)
         areaParams = streamContainerParams.areaParams
         areaParams.title = purposeText
         areaParams.isHasBorder = true
         areaParams.styleAddition = styles.documentPurposeContainer

         mainPaymentElements.push(
            element:
               `(<StreamContainer content={purposeText}
                                  onClickTrigger={this._onClickTriggerPaymentPurpose}
                                  {...streamContainerParams}
                                />)`
            style: styles.documentPurposeElement
         )

      paymentOutput =
         if _.isEmpty(mainPaymentElements)
            paymentPartsParams = paymentReflections.payment_parts

            if paymentPartsParams? and !_.isEmpty(paymentPartsParams)
               paymentParts = paymentPartsParams.value

               totalAmount = paymentParts.reduce( ((total, partParams) ->
                  total + +partParams.fields.sum.value
               ), 0)

               payedSumAmount =
                  MoneyFormatter.formatMoney(totalAmount,
                                             @_P_INT_FIELD_TYPE,
                                             true)

               @_getPNameValueElement(paymentCaptions.totalAmount, payedSumAmount)
         else
            getElementsList(mainPaymentElements)


      `(
         <div style={styles.paymentAttributesContainer}>
            {paymentOutput}
            {clarifiedButton}
         </div>
       )`

   ###*
   * Функция рендера содержимого ячейки выбора платежного графика. Формирует
   *  селектор для платежного графика.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object} record - параметры записи.
   * @return {React-element}
   ###
   _onRenderPaymentPlanSelectorCell: (rowRef, record) ->
      paymentPlanParams = @_PAYMENT_PLAN_SELECTOR_PARAMS
      ImplementationStore = require('components/content/implementations/implementation_store')
      reflections = record.reflections

      if reflections? and !_.isEmpty reflections
         paymentPlan = reflections.payment_plan

         presetRecords =
            if paymentPlan? and !_.isEmpty paymentPlan
               [paymentPlan.value]

      onSelectPaymentPlanHandler =
         PaymentRegistryHandlers.onSelectPaymentPlan.bind(rowRef, record)

      `(
         <Selector implementationStore={ImplementationStore}
                   presetRecords={presetRecords}
                   onChange={onSelectPaymentPlanHandler}
                   {...paymentPlanParams}
                 />
       )`

   ###*
   * Функция рендера содержимого ячейки выбора платежного графика.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object} record - параметры записи.
   * @return {React-element}
   ###
   _onRenderPaymentPlanCell: (rowRef, record) ->
      paymentPlanParams = @_PAYMENT_PLAN_SELECTOR_PARAMS
      ImplementationStore = require('components/content/implementations/implementation_store')
      reflections = record.reflections

      if reflections? and !_.isEmpty reflections
         paymentPlan = reflections.payment_plan

      if paymentPlan? and paymentPlan.value?
         PaymentPlanRenders._onRenderPaymentPlanInstance(paymentPlan.value)
      else
        `(
            <span style={this.paymentStyles.secondaryData}>
               {this._P_TITLES.noPaymentPlan}
            </span>
         )`

   ###*
   * Функция рендера содержимого ячейки плетельщика/получателя.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object} record - параметры записи.
   * @return {React-element}
   ###
   _onRenderRightholderCell: (rowRef, record) ->
      recordReflections = record.reflections
      digChains = @_P_DIG_CHAINS

      if recordReflections? and !_.isEmpty recordReflections
         rightholderReceiver = recordReflections.rightholder_receiver
         rightholderPayer =
            if recordReflections.rightholder_payer?
               recordReflections.rightholder_payer
            else
               _.get(recordReflections, digChains.payerFromOwnership)


         # Элементы правообладателя.
         rightholderPayerElements =
            if rightholderPayer? and !_.isEmpty(rightholderPayer)
               rightholderRecord = rightholderPayer.value

               if rightholderRecord? and !_.isEmpty(rightholderRecord)
                  RightholderRegistryRenders._getRightholderElements(rightholderRecord)

      @_getRightholderContent(rightholderPayerElements)

   ###*
   * Обработчик клика на кнопке скрытия/разворачивания потокового контейнера, в
   *  котором располагается текст назначения платежа. Останавливает проброс события.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickTriggerPaymentPurpose: (event) ->
      event.stopPropagation()

   ###*
   * Функция получения неделимого элемента содержимого: Лейбл наименование : значение.
   *  Не создает элемент, если было передано пустое значение (value).
   *
   * @param {Object, String} caption     - заголовок (надпись-пояснение).
   * @param {Object, String} value       - значение.
   * @return {React-element, undefined}
   ###
   _getPNameValueElement: (caption, value) ->

      # Не формируем элемент, если задано пустое значение.
      isEmptyObject = (_.isPlainObject(value) or _.isArray(value)) and _.isEmpty(value)
      isEmptyString = _.isString(value) and _.isEmpty(_.trim(value))

      if !value? or isEmptyObject or isEmptyString
         return

      styles = @paymentStyles
      chars = @_P_CHARS

      captionValue =
         if caption?
            [
               caption
               chars.colon
            ].join chars.empty

      # valueElement = if isWithoutContainer
      #    value
      # else
      #    `(
      #        <span style={styles.ownershipValueContainer}>
      #          {value}
      #        </span>
      #     )`

      `(
          <span style={styles.indivisibleContentPart}>
            <span style={styles.captionContainer}>
               {captionValue}
            </span>
            <span style={styles.valueContainer}>
               {value}
            </span>
         </span>
      )`

   ###*
   * Функция фомрирования отображения данных по правообладателю (плательщику).
   *
   * @param {Object} propertyElements - элементы для отображения имущества.
   * @return {React-element}
   ###
   _getRightholderContent: (rightholderElements) ->
      styles = @paymentStyles

      unless rightholderElements?
         return `(
                    <span style={styles.secondaryData}>
                       {this._P_TITLES.noPayer}
                    </span>
                 )`

      mainElements = rightholderElements.main
      numberElements = rightholderElements.numbers
      datesElements = rightholderElements.dates
      secondaryElements = rightholderElements.secondary
      markerElements = rightholderElements.markers

      #contentRowSpan = @_ROWSPANS.composition

      secondaryContentContainerStyle = styles.secondaryData
      rightholderName = mainElements.nameAddition or mainElements.name


      rightholderCaption =
         # if isCaptionLabel
         #    `(
         #       <Label content={rightholderName}
         #              {...captionAddition}
         #            />
         #     )`
         # else
            rightholderName

      rightholderAttributesStyle =
         _.merge {},
                 styles.contentList,
                 styles.secondaryData,
                 styles.rightholderAttributes

      `(
         <table style={styles.rightholderTable}
                title={this._P_TITLES.payer} >
            <tbody>
               <tr>
                  <td style={styles.iconCell}>
                     {rightholderElements.icon}
                  </td>
                  <td rowSpan={this._P_ROWSPANS.rightholder}>
                     {rightholderName}

                     <ul style={rightholderAttributesStyle}>
                        <li>{secondaryElements.type}</li>
                        <li>{secondaryElements.oktmo}</li>
                        <li>{secondaryElements.inn}</li>
                        <li>{secondaryElements.regDate}</li>
                        <li>{secondaryElements.kpp}</li>
                        <li>{secondaryElements.ogrn}</li>
                        <li>{secondaryElements.okved}</li>

                        <li>{secondaryElements.snils}</li>
                        <li>{secondaryElements.birthDate}</li>
                        <li>{secondaryElements.passport}</li>
                        <li>{secondaryElements.gender}</li>
                     </ul>
                  </td>
               </tr>
               <tr>
                  <td>
                     {markerElements.manager}
                     {markerElements.hasParent}
                     {markerElements.businessman}
                  </td>
               </tr>
               <tr>
                  <td style={styles.entityNumberCell}>
                     {numberElements.registry}
                     {numberElements.oldRegistry}
                  </td>
               </tr>
            </tbody>
         </table>
      )`


   ###*
   * Функция формирования лейбла сервисной даты (создание, обновление).
   *
   * @param {DateTime} date - параметры дата.
   * @param {String} title  - выводимая подсказка.
   * @param {Boolean} isUpdate - флаг того, что лейбл для даты обновления.
   * @return {React-element}
   ###
   _getPServiceDateLabel: (date, title, isUpdate) ->
      labelDefaults = @_P_LABEL_DEFAULT_PARAMS
      recordDateIcons = @_P_RECORD_DATE_ICONS

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
              />
      )`



module.exports = PaymentRegistryRenders

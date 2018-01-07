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
* Label   - лейбл
* StreamContainer - контейнер в потоке.
###
Label = require('components/core/label')
StreamContainer = require('components/core/stream_container')

###* Константы.
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

###*
* Модуль рендеров для платежных графиков. Содержит функции произвольного
*  отображения данных по платежному графику.
*
###
PaymentPlanRegistryRenders =

   # @const {Object} - используемые символы.
   _PP_CHARS:
      empty: ''
      colon: ':'
      equal: '='
      space: ' '
      space: ' '
      dash: '-'
      brStart: '('
      brEnd: ')'
      newLine: '/n'

   # @const {Object} - стандартные параметры для различных лейблов.
   _PP_LABEL_DEFAULT_PARAMS:
      number:
         isBlock: true
         isRounded: true
         isOutlined: true
         type: 'ordinaryLight'
      numberMember:
         isInlineBlock: true
         isRounded: true
         isOutlined: true
      info:
         isLink: true
         type: 'info'

   # @const {Object} - используемые заголовки-пояснения.
   _PP_TITLES:
      calculationProcedure: 'Формула расчета'

   # @const {Object} - типы правообладателей.
   _RIGHTHOLDER_TYPES: keyMirror(
      LegalEntity: null
      PhysicalEntity: null
   )

   # @const {Object} - параметры, специфичные для номеров конкретных членов
   #                   платежного плана.
   _PAYMENT_PLAN_MEMBERS:
      ownership:
         caption: 'Правообладание'
         labelType: 'exclamationLight'
      rightholder:
         caption: 'Правообладатель'
         labelType: 'infoLight'
      property:
         caption: 'Имущество'
         labelType: 'successLight'

   # @const {Object} - параметры для потокового контейнера параметров операндов
   #                   методики расчета.
   _CALCULATION_OPERANDS_CONTAINER_PARAMS:
      areaParams:
         isWithoutSubstrate: true
      triggerParams:
         hidden:
            caption: 'Операнды формулы'
      isMirrorClarification: true

   paymentPlanStyles:
      paymentPlanTable:
         width:'100%'
      numberCell:
         verticalAlign: 'top'
         padding: _COMMON_PADDING
      paymentPlanDataCell:
         textAlign: 'left'
         verticalAlign: 'top'
      ownershipCell:
         verticalAlign: 'top'
      paymentPlanOwnershipTable:
         textAlign: 'left'
      paymentPlanOwnershipSecondaryCell:
         maxWidth: 250
         whiteSpace: 'normal'
      paymentPlanOwnershipNumberCell:
         paddingRight: _COMMON_PADDING
      paymentPlanElementsList:
         listStyle: 'none'
         margin: 0
         padding: 0
         fontSize: 12
      formulaElementsList:
         listStyle: 'none'
         margin: 0
         padding: 0
         textAlign: 'center'
      calculationProcedureContainer:
         paddingLeft: 10
      paymentPlanSecondary:
         fontSize: 11
         color: _COLORS.hierarchy3
      indivisibleContentPart:
         display: 'inline-block'
      captionContainer:
         color: _COLORS.hierarchy3
      valueContainer:
         padding: 3

   ###*
   * Функция формирования содержимого для отображения выбранного платежного графика.
   *
   * @param {Object} record - параметры записи, по которой идет отрисовка.
   * @return {React-element}
   ###
   _onRenderPaymentPlanInstance: (record) ->
      paymentPlanElements = @_getPaymentPlanElements(record)
      rightholderElements = paymentPlanElements.rightholder
      propertyElements = paymentPlanElements.property
      ownershipElements = paymentPlanElements.ownership

      @_getOwnershipElement(rightholderElements,
                            propertyElements,
                            ownershipElements)

   ###*
   * Функция формирования содержимого для отображения ячейки для отображения
   *  параметров платежного графика.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object} record - параметры записи, по которой идет отрисовка.
   * @return {React-element}
   ###
   _onRenderPaymentPlanCell: (rowRef, record) ->
      styles = @paymentPlanStyles
      paymentPlanElements = @_getPaymentPlanElements(record)
      mainElements = paymentPlanElements.main
      rightholderElements = paymentPlanElements.rightholder
      propertyElements = paymentPlanElements.property
      ownershipElements = paymentPlanElements.ownership


      `(
         <table style={styles.paymentPlanTable}>
            <tbody>
               <tr>
                  <td style={styles.numberCell}>
                     {paymentPlanElements.number}
                  </td>
                  <td style={styles.paymentPlanDataCell}>
                     <ul style={styles.paymentPlanElementsList}>
                        <li>{mainElements.totalCost}</li>
                        <li>{mainElements.kbk}</li>
                        <li>{mainElements.dateStart}</li>
                        <li>{mainElements.dateEnd}</li>
                        <li>{mainElements.period}</li>
                        <li>{mainElements.calculation}</li>
                     </ul>
                  </td>
                  <td style={styles.ownershipCell}>
                     {this._getOwnershipElement(rightholderElements,
                                                propertyElements,
                                                ownershipElements)}
                  </td>
               </tr>
            </tbody>
         </table>
       )`

   ###*
   * Функция формирования содержимого для отображения содержимого правообладания.
   *
   * @param {Object} rightholderElements - элементы правообладателя.
   * @param {Object} propertyElements    - элементы имущества.
   * @param {Object} ownershipElements   - элементы правообладания.
   * @return {React-element}
   ###
   _getOwnershipElement: (rightholderElements, propertyElements, ownershipElements)->
      styles = @paymentPlanStyles

      `(
         <table style={styles.paymentPlanOwnershipTable}>
            <tbody>
               <tr>
                  <td style={styles.paymentPlanOwnershipNumberCell}>
                     {ownershipElements.number}
                  </td>
                  <td>
                     {ownershipElements.type}
                     <div style={styles.paymentPlanSecondary}>
                        {ownershipElements.period}
                     </div>
                  </td>
               </tr>
               <tr>
                  <td style={styles.paymentPlanOwnershipNumberCell}>
                     {rightholderElements.number}
                  </td>
                  <td style={styles.paymentPlanOwnershipSecondaryCell}>
                     {rightholderElements.name}
                     <div style={styles.paymentPlanSecondary}>
                        {rightholderElements.fullName}
                     </div>
                  </td>
               </tr>
               <tr>
                  <td style={styles.paymentPlanOwnershipNumberCell}>
                     {propertyElements.number}
                  </td>
                  <td>
                     {propertyElements.name}
                     <div style={styles.paymentPlanSecondary}>
                        {propertyElements.cadastreNumber}
                     </div>
                  </td>
               </tr>
            </tbody>
         </table>
       )`


   ###*
   * Функция получения неделимого элемента содержимого: Лейбл наименование : значение.
   *  Не создает элемент, если было передано пустое значение (value).
   *
   * @param {Object, String} caption     - заголовок (надпись-пояснение).
   * @param {Object, String} value       - значение.
   * @return {React-element, undefined}
   ###
   _getPPNameValueElement: (caption, value) ->

      # Не формируем элемент, если задано пустое значение.
      isEmptyObject = (_.isPlainObject(value) or _.isArray(value)) and _.isEmpty(value)
      isEmptyString = _.isString(value) and _.isEmpty(_.trim(value))

      if !value? or isEmptyObject or isEmptyString
         return

      styles = @paymentPlanStyles
      chars = @_PP_CHARS

      captionValue =
         if caption?
            [
               caption
               chars.colon
            ].join chars.empty

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
   * Функция формирования лейбла для отображения номера объекта (ключа).
   *
   * @param {String, Number} number - номер.
   * @param {String} title          - всплывающее пояснение.
   * @param {String} memberCaption  - заголовок элемента.
   * @return {React-element}
   ###
   _getPPNumberLabel: (number, title, memberCaption) ->
      paymentPlanMembers = @_PAYMENT_PLAN_MEMBERS

      chars = @_PP_CHARS
      labelParams = _.clone(@_PP_LABEL_DEFAULT_PARAMS.number)

      if memberCaption?
         for memberName, memberParams of paymentPlanMembers
            if memberParams.caption is memberCaption

               title = [
                  memberCaption
                  chars.colon
                  chars.space
                  title
               ].join chars.empty

               labelParams.type = memberParams.labelType
               break

      `(
         <Label {...labelParams}
                content={number}
                title={title}
              />
       )`

   ###*
   * Функция формирования элементов для платежного графика.
   *
   * @param {Object} record - запись
   * @return {Object}
   ###
   _getPaymentPlanElements: (record) ->
      labelDefaults = @_PP_LABEL_DEFAULT_PARAMS
      chars = @_PP_CHARS
      titles = @_PP_TITLES
      emptyChar = chars.empty
      spaceChar = chars.space
      equalChar = chars.equal
      spaceChar = chars.space
      brStartChar = chars.brStart
      brEndChar = chars.brEnd
      styles = @paymentPlanStyles
      fields = record.fields
      reflections = record.reflections
      serviceContent = record.service_content
      idField = fields.id
      dateStartField = fields.date_start
      dateEndField = fields.date_end
      period = fields.period
      totalCost = fields.total_cost

      if reflections? and !_.isEmpty reflections
         kbk = reflections.kbk
         ownership = reflections.ownership

         # КБК
         if kbk? and !_.isEmpty kbk
            kbkValue = kbk.value

            if kbkValue? and !_.isEmpty kbkValue
               kbkFields = kbkValue.fields
               kbkNumber = kbkFields.number
               kbkLevel = kbkFields.level
               kbkDescription = kbkFields.description
               kbkCaption = kbk.caption

               kbkTitle =
                 `(
                     <span>
                        {this._getPPNameValueElement(kbkLevel.caption,
                                                     kbkLevel.value)}
                        {this._getPPNameValueElement(kbkDescription.caption,
                                                     kbkDescription.value)}
                     </span>
                  )`

               kbkElement =
                  `(
                      <Label title={kbkTitle}
                             content={kbkNumber.value}
                             {...labelDefaults.info}
                           />

                   )`

         # ПРАВООБЛАДАНИЕ.
         if ownership? and !_.isEmpty ownership
            ownershipValue = ownership.value

            if ownershipValue? and !_.isEmpty(ownershipValue)
               ownershipFields = ownershipValue.fields
               ownershipReflections = ownershipValue.reflections

               if ownershipFields? and !_.isEmpty(ownershipFields)
                  ownershipId = ownershipFields.id
                  ownershipDateStartField = ownershipFields.date_start
                  ownershipDateEndField = ownershipFields.date_end
                  ownershipDateStart =
                    new Date(ownershipDateStartField.value).toLocaleDateString()
                  ownershipDateEnd =
                    new Date(ownershipDateEndField.value).toLocaleDateString()

                  ownershipPeriod =
                     `(
                        <div>
                           <span title={ownershipDateStartField.caption}>
                              {ownershipDateStart}
                           </span>
                           {chars.dash}
                           <span title={ownershipDateEndField.caption}>
                              {ownershipDateEnd}
                           </span>
                        </div>
                     )`

                  ownershipNumber =
                     @_getPPNumberLabel(ownershipId.value,
                                        ownershipId.caption,
                                        ownership.caption)

               if ownershipReflections? and !_.isEmpty(ownershipReflections)
                  property = ownershipReflections.property
                  rightholder = ownershipReflections.rightholder
                  ownershipType = ownershipReflections.ownership_type

                  # ИМУЩЕСТВО.
                  if property? and !_.isEmpty property
                     propertyValue = property.value

                     if propertyValue? and !_.isEmpty propertyValue
                        propertyFields = propertyValue.fields
                        propertyId = propertyFields.id
                        propertyName = propertyFields.name.value
                        propertyCadastreNumber = propertyFields.real_cadastre_number

                        propertyCadastreElement =
                           @_getPPNameValueElement(propertyCadastreNumber.caption,
                                                   propertyCadastreNumber.value)

                        propertyNumber = @_getPPNumberLabel(propertyId.value,
                                                            propertyId.caption,
                                                            property.caption)

                  # ПРАВООБЛАДАТЕЛЬ.
                  if rightholder? and !_.isEmpty rightholder
                     rightholderValue = rightholder.value

                     if rightholderValue? and !_.isEmpty rightholderValue
                        rightholderFields = rightholderValue.fields
                        rightholderReflections = rightholderValue.reflections
                        rightholderId = rightholderFields.id
                        rightholderType = rightholderFields.entity_type.value

                        rightholderNumber =
                           @_getPPNumberLabel(rightholderId.value,
                                              rightholderId.caption,
                                              rightholder.caption)

                        if rightholderReflections? and !_.isEmpty rightholderReflections
                           entity = rightholderReflections.entity
                           users = rightholderReflections.users

                           if entity? and (rightholderType is @_RIGHTHOLDER_TYPES.LegalEntity)
                              entityValue = entity.value

                              if entityValue? and !_.isEmpty entityValue
                                 entityFields = entityValue.fields

                                 if entityFields?
                                    rightholderName = entityFields.short_name.value
                                    rightholderFullName = entityFields.full_name.value

                                    rightholderNameElement =
                                       `(
                                          <span title={rightholderFullName}>
                                             {rightholderName}
                                          </span>
                                        )`
                           else if users?
                              firstUser = users.value[0]

                              if firstUser? and !_.isEmpty firstUser
                                 userFields = firstUser.fields
                                 userFirstName = userFields.first_name
                                 userMiddleName = userFields.middle_name
                                 userLastName = userFields.last_name

                                 rightholderNameElement =
                                    [
                                       userLastName.value
                                       userMiddleName.value
                                       userFirstName.value
                                    ].join chars.space

                  # ТИП ПРАВООБЛАДАНИЯ.
                  if ownershipType? and !_.isEmpty ownershipType
                     ownershipTypeValue = ownershipType.value

                     if ownershipTypeValue? and !_.isEmpty ownershipTypeValue
                        ownershipTypeFields = ownershipTypeValue.fields

                        ownershipType = ownershipTypeFields.name.value

      if serviceContent? and !_.isEmpty serviceContent
         formulaParams = serviceContent.formula
         operandParams = serviceContent.operands
         isFormulaPresent = formulaParams? and !_.isEmpty(formulaParams)
         isOperandsPresent = operandParams? and !_.isEmpty(operandParams)

         # Содержимое формулы расчета - сама формула и формула с заполненными
         #  значениями.
         formulaContent =
            if isFormulaPresent
               canonicityFormula = formulaParams.canonicity
               filledFormula = formulaParams.filled

               if canonicityFormula?
                  `(
                      <ul style={styles.formulaElementsList}>
                        <li>{canonicityFormula}</li>
                        <li>{filledFormula}</li>
                      </ul>
                   )`

         # Содержимое операндов формулы - формируем потоковый контейнер с
         #  возможностью показа/скрытия операндов.
         operandsContent =
            if isOperandsPresent
               operandElements = operandParams.map (operand, idx) ->
                  operandValue = [
                     operand.caption
                     brStartChar
                     operand.alias
                     brEndChar
                     spaceChar
                     equalChar
                     spaceChar
                     operand.value
                  ].join emptyChar

                  `(<li key={idx}>{operandValue}</li>)`

               operandList =
                  `(
                     <ul style={styles.paymentPlanElementsList}>
                        {operandElements}
                     </ul>
                   )`

               `(
                  <StreamContainer content={operandList}
                                   onClickTrigger={this._onClickTriggerCalculationOperands}
                                   {...this._CALCULATION_OPERANDS_CONTAINER_PARAMS}
                                 />
                )`

         # Если в сервисном содержимом задана формула или(и) операнды - формируем
         #  содержимое методики расчета - формулу + операнды в контейнере.
         if isFormulaPresent or isOperandsPresent
            calculationContent =
               `(
                  <div style={styles.calculationProcedureContainer}>
                     {formulaContent}
                     {operandsContent}
                  </div>
                )`


      totalCostAmount =
         if totalCost? and totalCost.value?
            MoneyFormatter.formatMoney(totalCost.value,
                                       totalCost.type,
                                       true)

      main:
         dateEnd: @_getPPNameValueElement(dateStartField.caption,
                                          dateStartField.value)
         dateStart: @_getPPNameValueElement(dateEndField.caption,
                                                 dateEndField.value)
         period: @_getPPNameValueElement(period.caption,
                                         period.value)
         kbk: @_getPPNameValueElement(kbkCaption, kbkElement)
         totalCost: @_getPPNameValueElement(totalCost.caption, totalCostAmount)
         calculation:  @_getPPNameValueElement(titles.calculationProcedure,
                                               calculationContent)
      number: @_getPPNumberLabel(idField.value, idField.caption)
      property:
         number: propertyNumber
         name: propertyName
         cadastreNumber: propertyCadastreElement
      rightholder:
         number: rightholderNumber
         name: rightholderNameElement
         fullName: rightholderFullName
      ownership:
         number: ownershipNumber
         type: ownershipType
         period: ownershipPeriod

   ###*
   * Обработчик клика на кнопке скрытия/разворачивания потокового контейнера, в
   *  котором располагается содержимое операндов формулы расчета.
   *  Останавливает проброс события.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickTriggerCalculationOperands: (event) ->
      event.stopPropagation()

module.exports = PaymentPlanRegistryRenders
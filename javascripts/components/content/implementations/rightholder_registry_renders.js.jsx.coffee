###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* keymirror        - модуль для генерации "зеркального" хэша.
* lodash           - модуль служебных операций.
###
StylesMixin = require('components/mixins/styles')
ContentRightholderMapYandex = require('components/content/insider/content_registry_map_yandex')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* Button            - кнопка.
* Label             - лейбл.
###
Button = require('components/core/button')
Label = require('components/core/label')

###* Зависимости: прикладные компоненты
* AnalysePreparer - подготовитель анализов.
###
AnalysePreparer = require('components/application/analyse_preparer')

###* Константы.
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

###*
* Модуль рендеров для реестра правообладателей. Содержит функции произвольного
*  отображения данных по правообладателям для таблицы данных реестра.
###
RightholderRegistryRenders =

   # @const {Object} - хэш с иконками для кнопок отображения дат запси.
   _RT_RECORD_DATE_ICONS:
      updated: 'refresh'
      created: 'file-o'

   # @const {Object} - используемые символы.
   _RT_CHARS:
      empty: ''
      comma: ','
      colon: ':'
      space: ' '
      brStart: '('
      brEnd: ')'

   # @const {Object} - поля правообладателя.
   _RIGHTHOLDER_FIELDS:
      id: 'реестр. №'

   # @const {Object} - параметры отображаемых полей физлица (для отображения доп. данных).
   _PHYSICAL_ENTITY_FIELDS:
      inn: 'ИНН'
      birthDate: 'Дата рождения'
      snils: 'СНИЛС'
      passport: 'паспорт'

   # @const {Object} - параметры отображаемых полей юрлица (для отображения доп. данных).
   _LEGAL_ENTITY_FIELDS:
      type: 'Тип'
      oktmo: 'ОКТМО'
      inn: 'ИНН'
      kpp: 'КПП'
      ogrn: 'ОГРН'

   # @const {Object} - параметры, используемые для формирования контента правообладателей по типам.
   _ENTITY_TYPES:
      phisycal:
         value: 'PhysicalEntity'
         localValue: 'физическое лицо'
         icon: 'male'
      legal:
         value: 'LegalEntity'
         localValue: 'юридическое лицо'
         icon: 'university'

   # @const {String} - типы лейблов (для компонента Label)
   _RT_LABEL_TYPES: keyMirror(
      ordinary: null
      ordinaryLight: null
      info: null
      success: null
      exclamation: null
      alert: null
   )

   # @const {Object} - стандартные параметры для различных лейблов.
   _RT_LABEL_DEFAULT_PARAMS:
      marker:
         isWithoutPadding: true
         isLink: true
         isBlock: true
         type: 'ordinaryLight'
      type:
         isWithoutPadding: true
         isLink: true
      info:
         type: 'info'
         isLink: true
      date:
         isBlock: true
         isLink: true
      number:
         isBlock: true
      caption:
         isAccented: false
         isBlock: true

   # @const {Object} - наименования иконок для маркеров правообладателя.
   _RT_MARKER_ICONS:
      manager: 'gavel'
      autonomy: 'home'
      hasParent: 'link'
      businessman: 'briefcase'

   # @const [Object] - цепи для считывания значений требуемых значений из параметров записи.
   _RT_INSTANCE_ATTRIBUTE_CHAINS:
      legalEntityName: [
         'fields'
         'entity_id'
         'reflection'
         'instance'
         'readingParams'
         'relation'
         'LegalEntity'
         'fields'
         'full_name'
         'value'
      ]
      user: ['externalEntities', 'User']
      okved: [
         'reflections'
         'okved'
         'value'
         'fields'
         'code'
         'value'
      ]


   # @const {String} - заполнитель пустых полей.
   _RT_MISSED_PARAM_TITLE: '-'

   # @const {String} - строка-перфикс классов для иконок FontAwesome.
   _RT_FA_ICON_PREFIX: 'fa fa-'

   # @const {String} - заполнитель имени физлица при отсутствии назначенного пользователя.
   _NO_USER_TITLE: 'Данные пользователя не заданы'

   # @const {Stirng} - заголовок
   _HAS_PARENT_MARKER_CAPTION: 'Cубъект относится к правообладателю:'

   # @const {Number} -
   _RT_CARD_MAIN_ROWSPAN: 3

   rightholderStyles:
      rightholderTable:
         width: '100%'
        # tableLayout: 'fixed'
      entityIcon:
         fontSize: 30
      entityIconCard:
         fontSize: 50
         color: _COLORS.hierarchy3
      entityIconCell:
         minWidth: 40
         textAlign: 'center'
      entityMarkersCell:
         width: 15
         verticalAlign: 'top'
      entityDataCell:
         width: '100%'
         whiteSpace: 'normal'
         color: _COLORS.dark
      entityNumberCell:
         minWidth: 80
      entityDateCell:
         minWidth: 150
      entityNameAddition:
         padding: _COMMON_PADDING
      entityNameAdditionBlock:
         textAlign: 'center'
         color: _COLORS.hierarchy3
         fontSize: 12
      entityRegistryNumberLabel:
         # borderStyle: 'solid'
         # borderWidth: 1
         # borderColor: _COLORS.main
         # borderRadius: 3
         textAlign: 'center'
         padding: _COMMON_PADDING
         fontSize: 11
         marginBottom: 1
         backgroundColor: _COLORS.secondary
         color: _COLORS.main
      entityOldRegistryNumberLabel:
         # borderStyle: 'solid'
         # borderWidth: 1
         # borderColor: _COLORS.hierarchy3
         # borderRadius: 3
         textAlign: 'center'
         padding: _COMMON_PADDING
         backgroundColor: _COLORS.hierarchy4
         color: _COLORS.hierarchy2
         fontSize: 11
      entityLegalTypeLabel:
         whiteSpace: 'nowrap'
         maxWidth: 200
         overflow: 'hidden'
         textOverflow: 'ellipsis'
         verticalAlign: 'bottom'
      entityDateButtonWrapper:
         paddingBottom: _COMMON_PADDING
      entityParamCaption:
         color: _COLORS.hierarchy3
      entityParamMain:
         paddingBottom: 0
         # fontWeight: 'bold'
         whiteSpace: 'normal'
         wordBreak: 'normal'
         color: _COLORS.dark
      entityParamSecondary:
         color: _COLORS.hierarchy3
         fontSize: 12
         paddingTop: _COMMON_PADDING
         whiteSpace: 'normal'
      entityNameAddition:
         padding: _COMMON_PADDING
      indivisibleContentPart:
         display: 'inline-block'
      entityValueContainer:
         #textDecoration: 'underline'
         paddingRight: _COMMON_PADDING * 2
         paddingLeft: _COMMON_PADDING
      entityAltenaviteCaption:
         color: _COLORS.hierarchy3
         #textDecoration: 'underline'
      entityParamSubCaption:
         color: _COLORS.hierarchy3
         fontSize: 12
         paddingBottom: _COMMON_PADDING + 2
      objectCardMainTable:
         width: '100%'
         tableLayout: 'fixed'
      objectCardMainIconCell:
         width: '15%'
         height: '30%'
         verticalAlign: 'middle'
         textAlign: 'center'
         padding: 10
      objectCardInlineContainer:
         display: 'inline-block'
      objectCardMainSpecificCell:
         verticalAlign: 'top'
      objectCardNumbersCell:
         verticalAlign: 'top'
      objectCardServiceDateCell:
         verticalAlign: 'top'
         height: '10%'
      objectCardEntityCaption:
         padding: _COMMON_PADDING
         fontSize: 16
      objectCardEntitySubCaption:
         textAlign: 'center'
      objectCardServiceDateLabel:
         fontSize: 10
      objectCardEntityContentList:
         fontSize: 14
         color: _COLORS.hierarchy2
         listStyle: 'none'

   ###*
   * Функция рендера заголовка выбранного экземпляра правообладателя.
   *  (для селекторов).
   *
   * @param {Object} record - запись
   * @return {String} - сформированная строка выбранного правообладателя.
   ###
   _onRightholderInstanceRender: (record) ->
      fields = record.fields
      reflections = record.reflections
      rightholderKey = record.key
      chars = @_RT_CHARS
      instanceChains = @_RT_INSTANCE_ATTRIBUTE_CHAINS
      spaceChar = chars.space

      rightholderName =
         if @_isLegalEntity(record)
            if reflections? and reflections.entity?
               entityFields = reflections.entity.value.fields
               entityFields.full_name.value
            else
               _.get(record, instanceChains.legalEntityName)
         else
            user =
               if reflections? and reflections.users?
                  _.first(reflections.users.value)
               else
                  _.get(record, instanceChains.user)

            if user? and !_.isEmpty(user)
               userFields = user.fields

               firstName = userFields.first_name.value
               lastName = userFields.last_name.value

               firstNameValue =
                  if _.isPlainObject(firstName)
                     _.first(_.values(firstName))
                  else
                     firstName

               lastNameValue =
                  if _.isPlainObject(lastName)
                     _.first(_.values(lastName))
                  else
                     lastName
               [
                  lastNameValue
                  firstNameValue
               ].join spaceChar

      [
         chars.brStart
         rightholderKey
         chars.brEnd
         spaceChar
         rightholderName
      ].join ''

   ###*
   * Функция рендера содержимого вкладки отображения расположения.
   *  Возвращает отображения компонента карты.
   *
   * @return {React-element}
   ###
   _getRightholderMap: ->
      `(<ContentRightholderMapYandex />)`

   ###*
   * Функция рендера содержимого вкладки отображения проведения анализа
   *  правообладателя. Возвращает отображения компонента проведения анализа.
   *
   * @param {Object} instanceRecord - экземпляр правообладателя.
   * @return {React-element}
   ###
   _getRightholderAnalyse: (instanceRecord) ->

      `(
         <AnalysePreparer instance={instanceRecord}/>
       )`

   ###*
   * Функция рендера ячейки отображения правообладателя. В зависимости от типа
   *  правообладателя формирует различное содержимое ячейки.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object} record - запись.
   * @return {React-element} - содержимое ячейки для отображения правообладателя.
   ###
   _onRenderRightholderCell: (rowRef, record) ->
      styles = @rightholderStyles
      rightholderElements = @_getRightholderElements(record)
      mainElements = rightholderElements.main
      numberElements = rightholderElements.numbers
      datesElements = rightholderElements.dates
      secondaryElements = rightholderElements.secondary
      additionElements = rightholderElements.addition
      markerElements = rightholderElements.markers

      `(
         <table style={styles.rightholderTable}>
            <tbody>
               <tr>
                  <td>
                     {markerElements.manager}
                     {markerElements.autonomy}
                     {markerElements.hasParent}
                     {markerElements.businessman}
                  </td>
                  <td style={styles.entityIconCell}>
                     {rightholderElements.icon}
                  </td>
                  <td style={styles.entityDataCell}>
                      {mainElements.name}
                      {this._getNameAdditionElement(mainElements.nameAddition)}
                      <div style={styles.entityParamSecondary}>
                        {secondaryElements.type}
                        {secondaryElements.oktmo}
                        {secondaryElements.inn}
                        {secondaryElements.regDate}
                        {secondaryElements.kpp}
                        {secondaryElements.ogrn}
                        {secondaryElements.okveds}

                        {secondaryElements.snils}
                        {secondaryElements.birthDate}
                        {secondaryElements.passport}
                        {secondaryElements.gender}
                      </div>
                  </td>
                  <td style={styles.entityNumberCell}>
                     {numberElements.registry}
                     {numberElements.oldRegistry}
                  </td>
                  <td style={styles.entityDateCell}>
                     {datesElements.created}
                     {datesElements.updated}
                  </td>
               </tr>
            </tbody>
         </table>
      )`

   ###*
   * Функция получения элемента для вывода доп. имени правообладателя.
   *
   * @param {String} nameAddition - доп. наименование.
   * @param {Boolean} isBlock     - флаг вывод в блочном элементе с позиционированием
   *                                по центру
   * @return {React-elements}
   ###
   _getNameAdditionElement: (nameAddition, isBlock) ->
      chars = @_RT_CHARS
      styles = @rightholderStyles

      if nameAddition?
         nameAdditionStyle = _.merge styles.entityParamSecondary,
                                     styles.entityNameAddition

         processedString =
            [
               chars.brStart
               nameAddition
               chars.brEnd
            ].join chars.empty

         if isBlock
            `(
                <div style={styles.entityNameAdditionBlock}>
                   {processedString}
                </div>
             )`
         else
            `(
                <span style={nameAdditionStyle}>
                   {processedString}
                </span>
             )`


   ###*
   * Функция получения элеменов для отображения правообладателя.
   *
   * @param {Object} record         - запись по правообладателю.
   * @param {Object} additionParams - доп. параметры для элементов.
   * @return {Object}
   ###
   _getRightholderElements: (record, additionParams) ->
      fields = record.fields
      reflections = record.reflections
      entityType = fields.entity_type.value
      registryNumber = fields.id
      oldRegistryNumber = fields.old_registry_number
      ornValue = oldRegistryNumber.value
      missedTitle = @_RT_MISSED_PARAM_TITLE
      styles = @rightholderStyles
      oldRegistryNumberValue = if ornValue? and ornValue isnt ''
                                  ornValue
                               else
                                  missedTitle

      entityParams = reflections.entity.value if reflections? and reflections.entity?
      isLegalEntity = @_isLegalEntity(record)
      createdDateParam = fields.created_at
      updatedDateParam = fields.updated_at
      rightholderMain = {}
      rightholderMarkers = {}
      rightholderSecondary = {}
      rightholderAddition = {}

      createdDate = new Date(createdDateParam.value).toLocaleString()
      updatedDate = new Date(updatedDateParam.value).toLocaleString()

      # Считаем доп. параметры для формирования элементов, если они были заданы.
      if additionParams?
         createdDateAddition = additionParams.created_at
         updatedDateAddition = additionParams.updated_at
         numberMarkerAddition = additionParams.numberMarker
         mainIconAddition = additionParams.mainIcon
         isAnotherCaption = additionParams.isAnotherCaption
         isIconForCard = additionParams.isIconForCard
         labelResets = additionParams.labelResets

      if entityParams?
         if isLegalEntity
            #legalEntityContent = @_getLegalEntityRowContent entityParams
            legalEntityElements = @_getLegalEntityElements(reflections
                                                           entityParams,
                                                           labelResets,
                                                           isAnotherCaption)

            rightholderMain = legalEntityElements.main
            rightholderMarkers = legalEntityElements.markers
            rightholderSecondary = legalEntityElements.secondary
            rightholderAddition = legalEntityElements.addition
         else
            # physicalEntityContent = @_getPhysicalEntityRowContent(reflections,
            #                                                       entityParams)

            physicalEntityElements = @_getPhysicalEntityElements(reflections,
                                                                 entityParams,
                                                                 isAnotherCaption)

            rightholderMain = physicalEntityElements.main
            rightholderMarkers = physicalEntityElements.markers
            rightholderSecondary = physicalEntityElements.secondary
      else unless isLegalEntity
         userParams = @_getUserParams(reflections)

         if userParams? and !_.isEmpty userParams
            rightholderMain =
               name: userParams.name

      @_addOkvedsToSecondary(reflections, rightholderSecondary, isAnotherCaption)

      icon: @_getEntityIcon(isLegalEntity, isIconForCard, mainIconAddition)
      main: rightholderMain
      secondary: rightholderSecondary
      addition: rightholderAddition
      markers: rightholderMarkers
      numbers:
         registry:    @_getRTIdentifierNumberLabel(registryNumber,
                                                   false,
                                                   numberMarkerAddition)
         oldRegistry: @_getRTIdentifierNumberLabel(oldRegistryNumber,
                                                   true,
                                                   numberMarkerAddition)
      dates:
         created: @_getRTServiceDateLabel(createdDate,
                                          createdDateParam.caption,
                                          false,
                                          updatedDateAddition)
         updated: @_getRTServiceDateLabel(updatedDate,
                                          updatedDateParam.caption,
                                          true,
                                          updatedDateAddition)

   _addOkvedsToSecondary: (reflections, secondaryParams, isAnotherCaption) ->
      rightholderOkveds =
         if reflections? and reflections.rightholder_okveds?
            reflections.rightholder_okveds

      if rightholderOkveds? and !_.isEmpty rightholderOkveds
         okveds = rightholderOkveds.value
         chars = @_RT_CHARS
         okvedChain = @_RT_INSTANCE_ATTRIBUTE_CHAINS.okved
         firstOkveds = okveds[0..2]

         firstOkvedCodes =
            firstOkveds.map((okved) ->
               _.get(okved, okvedChain)
            ).join(chars.comma + chars.space)

         if firstOkvedCodes? and !_.isEmpty(firstOkvedCodes)
            secondaryParams.okveds = @_getRTNameValueElement(rightholderOkveds.caption,
                                                             firstOkvedCodes,
                                                             false,
                                                             isAnotherCaption)

   ###*
   * Функция получения лейбла сервисной даты (создание, обновление)
   *
   * @param {Date} date        - выводимая дата.
   * @param {String} title     - выводимая подсказка.
   * @param {Boolean} isUpdate - флаг того, что лейбл для даты обновления.
   * @param {Object} additionParams - дополнительные параметры.
   * @return {React-Element}
   ###
   _getRTServiceDateLabel: (date, title, isUpdate, additionParams) ->
      labelDefaults = @_RT_LABEL_DEFAULT_PARAMS
      recordDateIcons = @_RT_RECORD_DATE_ICONS

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
   * Функция подготовки основных элементов для отображения данных правообладателя.
   *
   * @param {Object} reflections  - параметры связок првообладателя.
   * @param {Object} entityParams - параметры правообладателя.
   * @param {Object} labelResets  - параметры сброса формирования лейблов.
   *                                Например, если нужно не формировать лейбл для
   *                                поля type - пробрасывается хэш {type: true}.
   * @param {Boolean} isAnotherCaption - флаг отличающегося заголовка.
   * @return {Object} - составные элементы для отображения правообладателя.
   ###
   _getLegalEntityElements: (reflections, entityParams, labelResets, isAnotherCaption) ->
      legalEntityFields = @_LEGAL_ENTITY_FIELDS
      rightholderFields = @_RIGHTHOLDER_FIELDS
      labelTypes = @_RT_LABEL_TYPES
      labelDefaults = @_RT_LABEL_DEFAULT_PARAMS
      markerIcons = @_RT_MARKER_ICONS
      chars = @_RT_CHARS
      styles = @rightholderStyles
      entityFields = entityParams.fields
      entityReflections = entityParams.reflections
      entityShortName = entityFields.short_name.value
      entityManager = entityFields.manager
      entityAutonomy = entityFields.autonomy
      entityParent = entityFields.parent_id
      isTypeLabelReseted = false
      isOktmoLabelReseted = false

      if reflections? and !_.isEmpty reflections
         contacts = reflections.contacts

         # Определим выводимые контакты (первые два).
         if contacts?
            contactsValue = contacts.value
            processedContacts = contactsValue[0..1]
            firstContact = processedContacts[0].fields
            secondContact = if processedContacts.length > 1
                               processedContacts[1].fields
            isContactTypesSame = secondContact? and (firstContact.contact_type.value is
                                                     secondContact.contact_type.value)

            firstContactValue = if isContactTypesSame
                                   [
                                      firstContact.contact.value
                                      secondContact.contact.value
                                   ].join()
                                else
                                   firstContact.contact.value

            firstContactElement =
               @_getRTNameValueElement(firstContact.contact_type.value,
                                       firstContactValue,
                                       false, true)
            secondContactElement =
               if (secondContact? and !isContactTypesSame)
                  @_getRTNameValueElement(secondContact.contact_type.value,
                                          secondContact.contact.value,
                                          false, true)

      legalEntityShortName =
         if entityShortName? and entityShortName isnt chars.empty
            entityShortName


      if entityReflections?
         entityOktmo = entityReflections.oktmo
         entityLegalType = entityReflections.legal_entity_type
         entityEmployees = entityReflections.legal_entity_employees

         legalEntityOktmo =
            if entityOktmo? and !_.isEmpty entityOktmo
               fieldsOktmo = entityOktmo.value.fields
               oktmoNumber = fieldsOktmo.section.value
               oktmoName = fieldsOktmo.name.value
               isOktmoLabelReseted = lableResets? and labelResets.oktmo

               if isOktmoLabelReseted
                  oktmoNumber
               else
                  `(<Label content={oktmoNumber}
                           title={oktmoName}
                           {...labelDefaults.info}
                         />)`

         legalEntityType =
            if entityLegalType? and !_.isEmpty entityLegalType
               isTypeLabelReseted = labelResets? and labelResets.type
               typeName = entityLegalType.value.fields.name.value

               if isTypeLabelReseted
                  typeName
               else
                  `(<Label content={typeName}
                           title={typeName}
                           styleAddition={{common: styles.entityLegalTypeLabel}}
                           isInlineBlock={true}
                           {...labelDefaults.info}
                         />)`

         if entityEmployees? and !_.isEmpty entityEmployees
            employeesValue = entityEmployees.value
            processedEmployees = employeesValue[0..1]
            firstEmployee = processedEmployees[0]
            secondEmployee =
               if processedEmployees.length > 1
                  processedEmployees[1]

            ###*
            * Функция получения элемента вывода для сотрудника юрлица.
            *
            * @param {Object} employeeRecord - парамктры записи по сотруднику.
            * @return {React-Element}
            ###
            getEmployeeElement = ((employeeRecord) ->
               employeeFields = employeeRecord.fields
               employeeReflection = employeeRecord.reflections

               employeePost =
                  if employeeReflection?
                     legalEntityPost = employeeReflection.legal_entity_post

                     if legalEntityPost?
                        legalEntityPost.value.fields.name.value
               employeeName =
                  [
                     employeeFields.last_name.value
                     employeeFields.first_name.value
                     employeeFields.middle_name.value
                  ].join chars.space

               @_getRTNameValueElement(employeePost,
                                     employeeName,
                                     false,
                                     true)
            ).bind(this)


            firstEmployeeElement = getEmployeeElement(firstEmployee)
            secondEmployeeElement =
               if secondEmployee?
                  getEmployeeElement(secondEmployee)


      managerMarker =
         if entityManager? and entityManager.value

            `(
               <Label icon={markerIcons.manager}
                      title={entityManager.caption}
                      {...labelDefaults.marker}
                    />
             )`

      autonomyMarker =
         if entityAutonomy? and entityAutonomy.value
            `(
               <Label icon={markerIcons.autonomy}
                      title={entityAutonomy.caption}
                      {...labelDefaults.marker}
                    />
             )`

      hasParentMarker =
         if entityParent? and entityParent.value? and entityReflections?
            parentReflection = entityReflections.parent

            hasParentMarkerTitle =
               if parentReflection? and !_.isEmpty parentReflection
                  parentReflectionRecord = parentReflection.value
                  parentFields = parentReflectionRecord.fields

                  [
                     chars.brStart
                     rightholderFields.id
                     chars.space
                     parentReflectionRecord.key
                     chars.brEnd
                     chars.space
                     parentFields.full_name.value
                  ].join chars.empty
               else
                  entityParent.value

            hasParentMarkerElement =
               `(
                   <div>
                     <div style={styles.entityParamCaption}>
                        {this._HAS_PARENT_MARKER_CAPTION}
                     </div>
                     <div>{hasParentMarkerTitle}</div>
                   </div>
                )`

            `(
               <Label icon={markerIcons.hasParent}
                      title={hasParentMarkerElement}
                      {...labelDefaults.marker}
                    />
             )`

      markers:
         manager: managerMarker
         autonomy: autonomyMarker
         hasParent: hasParentMarker
      main:
         name: entityFields.full_name.value
         nameAddition: legalEntityShortName
      secondary:
         type: @._getRTNameValueElement(legalEntityFields.type,
                                        legalEntityType,
                                        !isTypeLabelReseted,
                                        isAnotherCaption)
         oktmo: @._getRTNameValueElement(legalEntityFields.oktmo,
                                         legalEntityOktmo,
                                         !isOktmoLabelReseted,
                                         isAnotherCaption)
         inn: @._getRTNameValueElement(entityFields.inn.caption,
                                       entityFields.inn.value,
                                       false,
                                       isAnotherCaption)
         regDate: @._getRTNameValueElement(entityFields.registration_date.caption,
                                           entityFields.registration_date.value,
                                           false,
                                           isAnotherCaption)
         kpp: @._getRTNameValueElement(entityFields.kpp.caption,
                                       entityFields.kpp.value,
                                       false,
                                       isAnotherCaption)
         ogrn: @._getRTNameValueElement(entityFields.ogrn.caption,
                                        entityFields.ogrn.value,
                                        false,
                                        isAnotherCaption)
      addition:
         contacts:
            first: firstContactElement
            second: secondContactElement
         employees:
            first: firstEmployeeElement
            second: secondEmployeeElement

   ###*
   * Функция подготовки основных элементов для отображения данных правообладателя.
   *
   * @param {Object} reflections  - параметры связанных сущностей.
   * @param {Object} entityParams - параметры правообладателя.
   * @param {Boolean} isAnotherCaption - флаг отличающегося заголовка.
   * @return {Object} - составные элементы для отображения правообладателя.
   ###
   _getPhysicalEntityElements: (reflections, entityParams, isAnotherCaption) ->
      physicalEntityFields = @_PHYSICAL_ENTITY_FIELDS
      faIconPrefix = @_RT_FA_ICON_PREFIX
      chars = @_RT_CHARS
      labelDefaults = @_RT_LABEL_DEFAULT_PARAMS
      markerIcons = @_RT_MARKER_ICONS
      spaceChar = chars.space
      entityFields = entityParams.fields
      entityBusinessman = entityFields.businessman
      styles = @rightholderStyles
      userParams = @_getUserParams(reflections)
      physicalEntityName = userParams.name
      physicalEntityBirthDate = userParams.birthDate
      physicalEntityGender = userParams.gender

      passportValue =
         [
            entityFields.passport_series.value
            entityFields.passport_num.value
            entityFields.passport_date.value
         ].join spaceChar


      businessmanMarker =
         if entityBusinessman? and entityBusinessman.value
            `(
               <Label icon={markerIcons.businessman}
                      title={entityBusinessman.caption}
                      {...labelDefaults.marker}
                    />
             )`

      markers:
         businessman: businessmanMarker
      main:
         name: physicalEntityName
      secondary:
         inn: @_getRTNameValueElement(entityFields.inn.caption,
                                      entityFields.inn.value,
                                      false,
                                      isAnotherCaption)
         snils: @_getRTNameValueElement(entityFields.snils.caption,
                                        entityFields.snils.value,
                                        false,
                                        isAnotherCaption)
         birthDate: @_getRTNameValueElement(physicalEntityBirthDate.caption
                                            physicalEntityBirthDate.value,
                                            false,
                                            isAnotherCaption)
         passport: @_getRTNameValueElement(physicalEntityFields.passport,
                                           passportValue,
                                           false,
                                           isAnotherCaption)
         gender: @_getRTNameValueElement(physicalEntityGender.caption,
                                         physicalEntityGender.value,
                                         false,
                                         isAnotherCaption)
   ###*
   * Функция получения параметров первого пользователя правообладателя.
   *
   * @param {Object} refelctions - параметры связок.
   * @return {Object} - параметры пользователя. Вид:
   *                    {String} name - ФИО пользователя.
   *                    {Object} birthDate - параметры поля даты рождения.
   *                    {Object} gender    - параметры поля пола.
   ###
   _getUserParams: (reflections) ->
      users = reflections.users
      user = users.value[0].fields if users?
      birthDate = {}
      gender = {}

      if user? and !_.isEmpty(user)
         userName =
         [
            user.first_name.value
            user.middle_name.value
            user.last_name.value
         ].join @_RT_CHARS.space

         userBirthDate = user.birth_date

         if userBirthDate.value?
            birthDate = userBirthDate.value

         gender = user.gender
      else
         userName = @_NO_USER_TITLE

      name: userName
      birthDate: birthDate
      gender: gender

   ###*
   * Функция получения неделимого элемента содержимого: Лейбл наименование : значение.
   *  Не создает элемент, если было передано пустое значение.
   *
   * @param {Object, String} caption - заголовок (надпись-пояснение).
   * @param {Object, String} value - значение.
   * @param {Boolean} isWithoutContainer - флаг необходимости отказа от
   *                                       помещения значения в контейнер.
   * @param {Boolean} isAnotherCaption   - флаг отличного стиля от значения
   *                                       (выделяемый цветом и подчеркиванием).
   * @return {React-Element, undefined}
   ###
   _getRTNameValueElement: (caption, value, isWithoutContainer, isAnotherCaption) ->

      # Не формируем элемент, если задано пустое значение.
      isEmptyObject = (_.isPlainObject(value) or _.isArray(value)) and _.isEmpty(value)
      isEmptyString = _.isString(value) and _.isEmpty(_.trim(value))
      if !value? or isEmptyObject or isEmptyString
         return

      styles = @rightholderStyles
      chars = @_RT_CHARS

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
                           <span style={styles.entityValueContainer}>
                              {value}
                           </span>
                         )`

      `(
         <span style={styles.indivisibleContentPart}>
            <span style={isAnotherCaption ? styles.entityAltenaviteCaption : null}>
               {captionValue}
            </span>
            {valueElement}
         </span>
       )`
   ###*
   * Функция получения лейбла с реестровым номером правообладаетеля.
   *
   * @param {Object} identifierNumber - параметры реестрового номера.
   * @param {Boolean} isDepressed     - флаг "подавленного" стиля лейбла - для вывода
   *                                    не основного номера (старого реестрового номера).
   * @param {Object} additionParams   - доп. параметры для лейбла.
   * @return {React-element}
   ###
   _getRTIdentifierNumberLabel: (identifierNumber, isDepressed, additionParams) ->
      styles = @rightholderStyles
      labelDefaults = @_RT_LABEL_DEFAULT_PARAMS
      labelTypes = @_RT_LABEL_TYPES
      type = if isDepressed
                labelTypes.common #styles.entityOldRegistryNumberLabel
             else
                labelTypes.success #styles.entityRegistryNumberLabel

      `(
         <Label content={identifierNumber.value}
                title={identifierNumber.caption}
                type={type}
                {...labelDefaults.number}
                {...additionParams}
            />
       )`

   ###*
   * Функция получения иконки правообладателя. Создает различные иконки в зависимости
   *  от типа правообладателя.
   *
   * @param {Boolean} isLegal       - флаг правообладателя-юрлица.
   * @param {Boolean} isForCard     - флаг иконки для карточки объекта.
   * @param {Object} additionParams - доп. параметры для лейбла.
   * @return {React-element}
   ###
   _getEntityIcon: (isLegal, isForCard, additionParams) ->
      faIconPrefix = @_RT_FA_ICON_PREFIX
      entityTypes = @_ENTITY_TYPES
      labelDefaults = @_RT_LABEL_DEFAULT_PARAMS
      styles = @rightholderStyles

      entityParams =
         if isLegal
            entityTypes.legal
         else
            entityTypes.phisycal

      localEntityType = entityParams.localValue
      entityIconName = entityParams.icon
      iconStyle =
         if isForCard
            styles.entityIconCard
         else
            color: _COLORS.hierarchy4
            styles.entityIcon

      `(
         <Label icon={entityIconName}
                styleAddition={{common: iconStyle}}
                title={localEntityType}
                {...labelDefaults.type}
                {...additionParams}
              />
      )`

   ###*
   * Функция рендера главного содержимого карточки объекта.
   *
   * @param {Object} record - параметры записи, по которой формируется карточка.
   * @return {React-Element}
   ###
   _onRenderRightholderObjectCardContent: (record) ->
      chars = @_RT_CHARS
      labelDefaults = @_RT_LABEL_DEFAULT_PARAMS
      styles = @rightholderStyles
      serviceDateAdditionParams =
         styleAddition: styles.objectCardServiceDateLabel
         type: @_RT_LABEL_TYPES.ordinaryLight
         isWithoutPadding: true

      additionParams =
         created_at: serviceDateAdditionParams
         updated_at: serviceDateAdditionParams
         isIconForCard: true
         isAnotherCaption: true


      rightholderElements = @_getRightholderElements(record, additionParams)
      mainElements = rightholderElements.main
      numberElements = rightholderElements.numbers
      datesElements = rightholderElements.dates
      secondaryElements = rightholderElements.secondary
      additionElements = rightholderElements.addition
      markerElements = rightholderElements.markers

      if additionElements?
         contacts = additionElements.contacts
         employees = additionElements.employees

      `(
         <table style={styles.objectCardMainTable}>
            <tbody>
               <tr>
                  <td style={styles.objectCardMainIconCell}>
                     <span style={styles.objectCardInlineContainer}>
                        {rightholderElements.icon}
                     </span>
                     <span style={styles.objectCardInlineContainer}>
                        {markerElements.manager}
                        {markerElements.autonomy}
                        {markerElements.hasParent}
                        {markerElements.businessman}
                     </span>
                  </td>
                  <td rowSpan='3'
                      style={styles.objectCardMainSpecificCell} >
                     <Label styleAddition={{common: styles.objectCardEntityCaption}}
                            content={mainElements.name}
                            {...labelDefaults.caption}
                         />

                     {this._getNameAdditionElement(mainElements.nameAddition, true)}

                     <ul style={styles.objectCardEntityContentList}>
                        <li>{secondaryElements.type}</li>
                        <li>{secondaryElements.oktmo}</li>
                        <li>{secondaryElements.inn}</li>
                        <li>{secondaryElements.regDate}</li>
                        <li>{secondaryElements.kpp}</li>
                        <li>{secondaryElements.ogrn}</li>
                        <li>{secondaryElements.okveds}</li>
                        <li>{contacts ? contacts.first : null}</li>
                        <li>{contacts ? contacts.second : null}</li>
                        <li>{employees ? employees.first : null}</li>
                        <li>{employees ? employees.second : null}</li>

                        <li>{secondaryElements.snils}</li>
                        <li>{secondaryElements.birthDate}</li>
                        <li>{secondaryElements.passport}</li>
                        <li>{secondaryElements.gender}</li>
                     </ul>
                  </td>
               </tr>
               <tr>
                  <td style={styles.objectCardNumbersCell}>
                     {numberElements.registry}
                     {numberElements.oldRegistry}
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
   * Функция предикат для определения является ли правообладатель юридическим
   *  лицом.
   *
   * @param {Object} record - запись.
   * @return {Boolean}
   ###
   _isLegalEntity: (record) ->
      fields = record.fields
      entityType = fields.entity_type.value
      entityTypes = @_ENTITY_TYPES

      entityType is entityTypes.legal.value


module.exports = RightholderRegistryRenders
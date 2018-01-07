###* @jsx React.DOM ###

###* Зависимости: модули
* RightholderRegistryRenders - модуль произвольных рендеров ячеек таблицы данных
*                              для реестра правообладателей.
* PropertyRegistryRenders    - модуль произвольных рендеров ячеек таблицы данных
*                              для реестра имущества.
* PaymentPlanRenders         - модуль произвольных рендеров ячеек таблицы данных
*                              для платежных графиков.
* OwnershipRegistryHandlers  - модуль обработчиков реестра правообладаний.
* StylesMixin                - общие стили для компонентов.
* keymirror                  - модуль для генерации "зеркального" хэша.
* lodash                     - модуль служебных операций.
###
RightholderRegistryRenders = require('components/content/implementations/rightholder_registry_renders')
PropertyRegistryRenders = require('components/content/implementations/property_registry_renders')
PaymentPlanRenders = require('components/content/implementations/payment_plan_renders')
OwnershipRegistryHandlers = require('components/content/implementations/ownership_registry_handlers')
StylesMixin = require('components/mixins/styles')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* Button          - кнопка.
* Label           - лейбл.
* List            - список.
* StreamContainer - контейнер в потоке.
###
Button = require('components/core/button')
Label = require('components/core/label')
List = require('components/core/list')
StreamContainer = require('components/core/stream_container')

###* Зависимости: прикладные компоненты
* ReportPreparer - подготовитель печатных форм.
###
ReportPreparer = require('components/application/report_preparer')

###* Константы.
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

###*
* Модуль рендеров для реестра правообладаний. Содержит функции произвольного
*  отображения данных по правообладаниям.
###
OwnershipRegistryRenders =

   # @const {String} - строка-перфикс классов для иконок FontAwesome.
   _OW_FA_ICON_PREFIX: 'fa fa-'

   # @const {Object} - используемые символы.
   _OW_CHARS:
      empty: ''
      colon: ':'
      space: ' '
      dash: '-'
      brStart: '('
      brEnd: ')'
      newLine: '/n'

   # @const {Object} - хэш с иконками для кнопок отображения служебных дат записи.
   _OW_RECORD_DATE_ICONS:
      updated: 'refresh'
      created: 'file-o'

   # @const {String} - типы лейблов (для компонента Label)
   _OW_LABEL_TYPES: keyMirror(
      ordinary: null
      ordinaryLight: null
      info: null
      success: null
      exclamation: null
      alert: null
   )

   # @const {Object} - стандартные параметры для различных лейблов.
   _OW_LABEL_DEFAULT_PARAMS:
      marker:
         isWithoutPadding: true
         isLink: true
         isInlineBlock: true
         type: 'ordinaryLight'
      number:
         isBlock: true
         isRounded: true
      important:
         type: 'success'
         isLink: true
      type:
         isWithoutPadding: true
         isLink: true
      info:
         type: 'info'
         isLink: true
      date:
         isBlock: true
         isLink: true
      caption:
         isAccented: false
         isBlock: true
         fontSize: 16

   # @const {Object} - наименования иконок для маркеров.
   _OW_MARKER_ICONS:
      egrp: 'check-square-o'
      paymentPlan: 'rub'

   # @const {Object} - параметры, используемые для формирования контента
   #                   правообладания по типам.
   _OWNERSHIP_TYPE_PARAMS:
      own:
         key: 2
         icon: 'certificate'
      management:
         key: 5
         icon: 'hand-stop-o'
      control:
         key: 6
         icon: 'eye'
      use:
         key: 8
         icon: 'home'
      lease:
         key: 13
         icon: 'money'
      easement:
         key: 9
         icon: 'blind'
      other:
         icon: 'file-text-o'
      unknown:
         icon: 'question-circle'
         title: 'Тип правообладания не задан'

   # @const {Object} - параметры статусов правообладания.
   _OWNERSHIP_STATUSES_PARAMS: [
      {
         name: 'issued'
         icon: 'pencil-square-o'
      }
      {
         name: 'stopped'
         icon: 'stop-circle-o'
      }
      {
         name: 'termination'
         icon: 'times-circle-o'
      }
      {
         name: 'terminated'
         icon: 'times'
      }
      {
         name: 'archival'
         icon: 'archive'
      }
   ]


   # @const {Object} - используемые заголовки для вывода в сложных лейблах.
   _OW_TITLES:
      paymentPlan: 'Последний платежный график'
      noProperty: 'Имущество не задано'
      noRightholder: 'Правообладатель не задан'
      additionForLastPlan: '(по графику)'

   # @const {Object} - типы правообладателей.
   _OW_RIGHTHOLDER_TYPES:
      legal: 'LegalEntity'
      physical: 'PhysicalEntity'

   # @const {Object} - параметры для потокового контейнера параметров платежного
   #                   графика.
   _PAYMENT_PLAN_CONTAINER_PARAMS:
      ajarHeight: 30
      areaParams:
         isWithoutSubstrate: true
      triggerParams:
         hidden:
            caption: 'Последний платежный график'
      isMirrorClarification: true

   # @const {Object} - используемые заголовки для всплывающих подсказок.
   _ELEMENT_TITLES:
      property: 'Имущество'
      rightholder: 'Правообладатель'

   # @const {Object} - используемые значения группировок ячеек таблицы
   _OW_ROWSPANS:
      main: 4         # для содержимого правобладания.
      composition: 3  # для остальных составных элементов (имущество и правообладание).

   # @const {Array<Object>} - набор доступных для формирования документов (временный).
   _AVAILABLE_DOCUMENTS: [
      {
         name: 'contract_rent_land'
         caption: 'Договор'
         title: 'Сформировать договор правообладания'
      }
      {
         name: 'order_granting_land'
         caption: 'Приказ на выдачу'
         title: 'Сформировать приказ по правообладанию'
      }
      {
         name: 'decree_gratuitous_municipality'
         caption: 'Постановление'
         title: 'Сформировать постановление'
      }
      {
         name: 'act_reconciliation'
         caption: 'Акт сверки'
         title: 'Сформировать акт сверки'
      }
   ]

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

   # @const {Object} - параметры по-умолчанию для кнопки запроса документа.
   _CREATE_DOC_BUTTON_PARAMS:
      caption: 'Сформировать'
      title: 'Отправить запрос на формирование документа'
      icon: 'arrow-right'
      iconPosition: 'right'

   _selectedDocParams:
      document: 'contract_rent_land'
      format: 'pdf'

   ownershipStyles:
      ownershipTable:
         width: '100%'
      ownershipIconCell:
         minWidth: 40
         textAlign: 'center'
         verticalAlign: 'top'
         height: 40
      ownershipDataCell:
         width: '25%'
         whiteSpace: 'normal'
         color: _COLORS.dark
         padding: _COMMON_PADDING
         verticalAlign: 'top'
      ownershipPropertyCell:
         width: '30%'
         verticalAlign: 'top'
      ownershipRightholderCell:
         width: '30%'
         verticalAlign: 'top'
      ownershipMarkersCell:
         textAlign: 'center'
         verticalAlign: 'top'
      ownershipImportanceCell:
         textAlign: 'center'
      serviceDateCell:
         color: _COLORS.hierarchy3
         minWidth: 100
      ownershipParamSecondary:
         color: _COLORS.hierarchy3
         fontSize: 12
         padding: _COMMON_PADDING
         whiteSpace: 'normal'
      elementsSplitter:
         margin: _COMMON_PADDING
         display: 'block'
         border: 0
         borderTopStyle: 'solid'
         borderTopColor: _COLORS.hierarchy4
         borderTopWidth: 1
         padding: 0
      propertyList:
         listStyle: 'none'
         textAlign: 'left'
         padding: 0
         margin: 0
      ownershipPropertyList:
         listStyle: 'none'
         textAlign: 'left'
         padding: 0
         marginRight: 10
         marginLeft: 10
         paddingTop: _COMMON_PADDING
         color: _COLORS.hierarchy2
         fontSize: 12
      ownershipValueContainer:
         padding: _COMMON_PADDING
      ownershipAltenaviteCaption:
         color: _COLORS.hierarchy3
      ownershipEgrpMarker:
         fontSize: 18
      paymentPlanContent:
         marginBottom: 4
      markerParamCaption:
         color: _COLORS.hierarchy3
      indivisibleContentPart:
         display: 'inline-block'
      ownershipIcon:
         fontSize: 30
      ownershipIconCard:
         fontSize: 50
         color: _COLORS.hierarchy3
      objectCardServiceDateLabel:
         fontSize: 10
      objectCardOwnershipDataCell:
         width: '40%'
         whiteSpace: 'normal'
         color: _COLORS.dark
         padding: _COMMON_PADDING
         verticalAlign: 'top'
      objectCardOwnershipContentCell:
         verticalAlign: 'top'
      objectCardServiceDateCell:
         minWidth: 100
      objectCardCompositeContent:
         padding: 10
         color: _COLORS.hierarchy3
         fontSize: 12
      documentCreateContainer:
         verticalAlign: 'top'
      elementList:
         display: 'inline-block'
         borderStyle: 'solid'
         borderWidth: 1
         borderColor: _COLORS.hierarchy3
         marginRight: _COMMON_PADDING
         verticalAlign: 'top'

   propertyStyles:
      propertyTable:
         width: '100%'
      propertyIconCell:
         minWidth: 40
         textAlign: 'center'
      propertyDataCell:
         width: '100%'
         whiteSpace: 'normal'
         color: _COLORS.dark
         padding: _COMMON_PADDING
      propertyParamSecondary:
         color: _COLORS.hierarchy3
         fontSize: 12
         padding: _COMMON_PADDING
      propertyMarkersCell:
         textAlign: 'center'
      propertyNumberCell:
         minWidth: 60

   rightholderStyles:
      rightholderTable:
         width: '100%'
      entityIconCell:
         minWidth: 40
         textAlign: 'center'
      entityDataCell:
         width: '100%'
         whiteSpace: 'normal'
         color: _COLORS.dark
         padding: _COMMON_PADDING
         verticalAlign: 'top'
      entityParamSecondary:
         color: _COLORS.hierarchy3
         fontSize: 12
         padding: _COMMON_PADDING
         whiteSpace: 'normal'
      entityNumberCell:
         minWidth: 60

   ###*
   * Функция рендера ячейки отображения b правообладателя. В зависимости от типа
   *  правообладателя формирует различное содержимое ячейки.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object} record - запись.
   * @return {React-element} - содержимое ячейки для отображения правообладателя.
   ###
   _onRenderAdditionRightholderNameCell: (rowRef, record) ->
      reflections = record.reflections
      rightholder = reflections.rightholder.value if reflections?

      if rightholder?
         name = @_getSimpleRightholderName(rightholder)
         key = rightholder.key
         chars = @_OW_CHARS

         [
            chars.brStart
            key
            chars.brEnd
            chars.space
            name
         ].join chars.empty

   ###*
   * Функция получения наименования правообладателя. Для разных сущностей
   *  (юрлицо/физлицо) получает наименования по-разному - либо наименование юрлица
   *  либо имя пользователя.
   *
   * @param {Object} righthodler - правообладатель.
   * @return {String}
   ###
   _getSimpleRightholderName: (rightholder) ->
      rightholderTypes = @_OW_RIGHTHOLDER_TYPES
      entityType = rightholder.fields.entity_type.value
      rightholderReflections = rightholder.reflections

      if rightholderReflections?
         entity = rightholderReflections.entity
         users = rightholderReflections.users

      if entityType is rightholderTypes.legal
         if entity?
            entityFields = entity.value.fields

            entityFields.full_name.value or entityFields.short_name.value
      else if users?
         usersCollection = users.value
         firstUser = _.first(usersCollection)

         if firstUser?
            firstUserFields = firstUser.fields

            [
               firstUserFields.last_name.value
               firstUserFields.middle_name.value
               firstUserFields.first_name.value
            ].join @_OW_CHARS.space

   ###*
   * Функция формирования набора кнопок для запроса на формирование документов.
   *
   * @param {Object} ownershipRecord      - экземпляр правообладания.
   * @param {Object} componentCommonProps - свойства, передаваемые для всех
   *                                        дочерних компонентов пользовательских
   *                                        действий карточки объекта.
   * @return
   ###
   _onRenderDocumentsContent: (ownershipRecord, componentCommonProps) ->
      availableDocuments = @_AVAILABLE_DOCUMENTS
      availableFormats = @_AVAILABLE_FORMATS
      docButtonParams = @_CREATE_DOC_BUTTON_PARAMS
      styles = @ownershipStyles
      elementListStyle = styles.elementList

      # `(
      #     <span style={styles.documentCreateContainer}>
      #       <List items={availableDocuments}
      #             styleAddition={ { common: elementListStyle } }
      #             enableMarkActivated={true}
      #             onActivate={this._onActivateDocType.bind(this)}
      #             activateIndex={this._getListActivatedIndex(false)}
      #           />
      #       <List items={availableFormats}
      #             styleAddition={ { common: elementListStyle } }
      #             enableMarkActivated={true}
      #             onActivate={this._onActivateDocFormat.bind(this)}
      #             activateIndex={this._getListActivatedIndex(true)}
      #           />
      #       <Button {...docButtonParams}
      #               value={this._selectedDocParams}
      #               onClick={this._onClickButtonCreateDoc.bind(ownershipRecord)}
      #             />
      #     </span>
      #  )`
      `(<ReportPreparer instance={ownershipRecord}
                        {...componentCommonProps}
                      />)`

   ###*
   * Метод получения инициализационного индекса для списка(начального) по текущим
   *  выбранным параметрам
   *
   * @param {Boolean} isFormat - флаг выбора индекса для списка форматов.
   ###
   _getListActivatedIndex:(isFormat) ->
      availableDocuments = @_AVAILABLE_DOCUMENTS
      availableFormats = @_AVAILABLE_FORMATS

      if isFormat
         _.findIndex(availableFormats, name: @_selectedDocParams.format)
      else
         _.findIndex(availableDocuments, name: @_selectedDocParams.document)

   ###*
   * Обработчик выбора элемента в списке типов документов. Устанавливает
   *  текущий выбранный тип в параметры.
   *
   * @param {Object} docTypeParams - параметры выбранного типа.
   * @return
   ###
   _onActivateDocType: (docTypeParams) ->
      @_selectedDocParams.document = docTypeParams.name

   ###*
   * Обработчик выбора элемента в списке типов документов. Устанавливает
   *  текущий выбранный формат в параметры.
   *
   * @param {Object} docFormatParams - параметры выбранного формата.
   * @return
   ###
   _onActivateDocFormat: (docFormatParams) ->
      @_selectedDocParams.format = docFormatParams.name

   ###*
   * Обработчик клика на кнопку отправки запроса на формирование выбранного документа.
   *  Исполняется в контексте параметров записи по правообладанию.
   *
   * @param {Object} value - параметры выбранного документа (тип, формат).
   * @return
   ###
   _onClickButtonCreateDoc: (value) ->
      OwnershipRegistryHandlers.getDocument(this.key, value)

   ###*
   * Функция рендера ячейки отображения правообладания основного реестра.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object} record - запись.
   * @return {React-element} - содержимое ячейки для отображения имущества.
   ###
   _onRenderOwnershipCell: (rowRef, record) ->
      contentRowSpan = @_OW_ROWSPANS.main
      styles = @ownershipStyles
      elementAdditionParams =
         egrpMarker:
            styleAddition:
               common: styles.ownershipEgrpMarker

      ownershipElements = @_getOwnershipElements(record, elementAdditionParams)
      mainElements = ownershipElements.main
      additionElements = ownershipElements.addition
      paymentPlanElement = ownershipElements.paymentPlan
      markerElements = ownershipElements.markers
      datesElements = ownershipElements.dates

      `(
         <table style={styles.ownershipTable}>
            <tbody>
               <tr>
                  <td style={styles.ownershipIconCell}>
                     {ownershipElements.icon}
                  </td>
                  <td style={styles.ownershipDataCell} rowSpan={contentRowSpan}>
                     {mainElements.type}
                     <div style={styles.ownershipParamSecondary}>
                        {additionElements.dateStart}
                        {additionElements.dateEnd}
                        {additionElements.dateKeep}
                        {additionElements.dateEgrp}
                        {paymentPlanElement}
                     </div>
                  </td>
                  <td style={styles.ownershipPropertyCell} rowSpan={contentRowSpan}>
                     {this._getPropertyCellContent(mainElements.property)}
                  </td>
                  <td style={styles.ownershipRightholderCell} rowSpan={contentRowSpan}>
                     {this._getRightholderCellContent(mainElements.rightholder)}
                  </td>
                  <td style={styles.serviceDateCell} rowSpan={contentRowSpan}>
                     {datesElements.created}
                     {datesElements.updated}
                  </td>
               </tr>
               <tr>
                  <td style={styles.ownershipMarkersCell}>
                     {markerElements.status}
                  </td>
               </tr>
               <tr>
                  <td>
                     {ownershipElements.number}
                  </td>
               </tr>
               <tr>
                  <td style={styles.ownershipImportanceCell}>
                     {markerElements.egrp}
                  </td>
               </tr>
            </tbody>
         </table>
       )`


   ###*
   * Функция фомрирования отображения данных по имуществу.
   *
   * @param {Object} propertyElements - элементы для отображения имущества.
   * @param {Object} additionParams   - доп. параметры для формирования представления.
   * @return {React-element}
   ###
   _getPropertyCellContent: (propertyElements, additionParams) ->

      unless propertyElements?
         return `(<span>{this._OW_TITLES.noProperty}</span>)`

      styles = @propertyStyles
      mainElements = propertyElements.main
      numberElements = propertyElements.numbers
      datesElements = propertyElements.dates
      secondaryElements = propertyElements.secondary
      additionElements = propertyElements.addition
      markerElements = propertyElements.markers
      propertyName = mainElements.name
      secondaryContentContainerStyle = styles.propertyParamSecondary
      contentRowSpan = @_OW_ROWSPANS.composition

      if additionParams? and !_.isEmpty additionParams
         captionParams = additionParams.caption
         secondaryParams = additionParams.secondary

         if captionParams?
            isCaptionLabel = captionParams.isLabel
            captionAddition = captionParams.addition

         if secondaryParams? and secondaryParams.style?
            secondaryContentContainerStyle = secondaryParams.style


      propertyCaption =
         if isCaptionLabel
            `(
               <Label content={propertyName}
                      {...captionAddition}
                    />
             )`
         else
            propertyName

      `(
          <table style={styles.propertyTable}
                 title={this._ELEMENT_TITLES.property}
               >
             <tbody>
             <tr>
                <td style={styles.propertyIconCell}>
                   {propertyElements.icon}
                </td>
                <td style={styles.propertyDataCell} rowSpan={contentRowSpan}>
                   {propertyCaption}
                   <div style={secondaryContentContainerStyle}>
                      {additionElements.oktmo}
                      {secondaryElements.costBalance}
                      {secondaryElements.costInventory}
                      {secondaryElements.costRest}
                      {secondaryElements.inventoryNumber}
                      {secondaryElements.manufacturedDate}
                      {secondaryElements.registrationDate}

                      {secondaryElements.moveAutoBodyNumber}
                      {secondaryElements.moveAutoEngineNumber}
                      {secondaryElements.moveAutoPtsNumber}
                      {secondaryElements.moveAutoRegistrationNumber}
                      {secondaryElements.moveAutoVinNumber}

                      {secondaryElements.realCadastreCost}
                      {secondaryElements.realCadastreDateRegistration}
                      {secondaryElements.realCadastreNumber}
                      {secondaryElements.realOldCadastreNumber}
                      {secondaryElements.realFullFootage}
                      {secondaryElements.realOldConditionNumber}
                      {secondaryElements.realtyApartamentType}
                      {secondaryElements.realtyLevelNumber}
                      {secondaryElements.realtyLevelsCount}
                      {secondaryElements.realtyNumberOnLevel}
                      {secondaryElements.realtyUndergroundLevelsCount}
                   </div>
                </td>
             </tr>
             <tr>
                <td style={styles.propertyMarkersCell}>
                   {markerElements.status}
                </td>
             </tr>
             <tr>
                <td style={styles.propertyNumberCell} rowSpan={contentRowSpan}>
                   {numberElements.account}
                   {numberElements.oldAccount}
                </td>
             </tr>
             </tbody>
          </table>
      )`

   ###*
   * Функция фомрирования отображения данных по правообладателю.
   *
   * @param {Object} propertyElements - элементы для отображения имущества.
   * @param {Object} additionParams   - доп. параметры для формирования представления.
   * @return {React-element}
   ###
   _getRightholderCellContent: (rightholderElements, additionParams) ->

      unless rightholderElements?
         return `(<span>{this._OW_TITLES.noRightholder}</span>)`


      styles = @rightholderStyles
      mainElements = rightholderElements.main
      numberElements = rightholderElements.numbers
      datesElements = rightholderElements.dates
      secondaryElements = rightholderElements.secondary
      markerElements = rightholderElements.markers
      contentRowSpan = @_OW_ROWSPANS.composition
      secondaryContentContainerStyle = styles.entityParamSecondary
      rightholderName = mainElements.nameAddition or mainElements.name


      if additionParams? and !_.isEmpty additionParams
         captionParams = additionParams.caption
         secondaryParams = additionParams.secondary

         if captionParams?
            isCaptionLabel = captionParams.isLabel
            captionAddition = captionParams.addition

         if secondaryParams? and secondaryParams.style?
            secondaryContentContainerStyle = secondaryParams.style



      rightholderCaption =
         if isCaptionLabel
            `(
               <Label content={rightholderName}
                      {...captionAddition}
                    />
             )`
         else
            rightholderName

      `(
          <table style={styles.rightholderTable}
                 title={this._ELEMENT_TITLES.rightholder}
               >
             <tbody>
             <tr>
                <td style={styles.entityIconCell}>
                   {rightholderElements.icon}
                </td>
                <td style={styles.entityDataCell} rowSpan={contentRowSpan}>
                   {rightholderCaption}
                   <div style={secondaryContentContainerStyle}>
                      {secondaryElements.type}
                      {secondaryElements.oktmo}
                      {secondaryElements.inn}
                      {secondaryElements.regDate}
                      {secondaryElements.kpp}
                      {secondaryElements.ogrn}
                      {secondaryElements.okved}

                      {secondaryElements.snils}
                      {secondaryElements.birthDate}
                      {secondaryElements.passport}
                      {secondaryElements.gender}
                   </div>
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
   * Функция получения лейбла сервисной даты (создание, обновление)
   *
   * @param {Date} date        - выводимая дата.
   * @param {String} title     - выводимая подсказка.
   * @param {Boolean} isUpdate - флаг того, что лейбл для даты обновления.
   * @param {Object} additionParams - дополнительные параметры.
   * @return {React-Element}
   ###
   _getOWServiceDateLabel: (date, title, isUpdate, additionParams) ->
      labelDefaults = @_OW_LABEL_DEFAULT_PARAMS
      recordDateIcons = @_OW_RECORD_DATE_ICONS

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
   * Функция получения иконки правообладания.
   *
   * @param {Object} ownershipTypeParams - параметры типа имущества.
   * @param {Boolean} isForCard         - флаг получения иконки для карточки (другой стиль).
   * @return {React-element}
   ###
   _getOwnershipIcon: (ownershipTypeParams, isForCard) ->
      faIconPrefix = @_OW_FA_ICON_PREFIX
      labelDefaults = @_OW_LABEL_DEFAULT_PARAMS
      styles = @ownershipStyles

      if ownershipTypeParams?
         icon = ownershipTypeParams.icon
         title = ownershipTypeParams.title
      else
         typeParams = @_OWNERSHIP_TYPE_PARAMS.unknown
         icon = typeParams.icon
         title = typeParams.title


      iconStyle =
         if isForCard
            styles.ownershipIconCard
         else
            styles.ownershipIcon

      `(
          <Label icon={icon}
                 title={title}
                 styleAddition={{common: iconStyle}}
                 {...labelDefaults.type}
          />
      )`

   ###*
   * Функция получения элементов для отображения правообладания.
   *
   * @param {Object} record         - запись.
   * @param {Object} additionParams - доп. параметры для элементов.
   * @return {Object} - элементы
   ###
   _getOwnershipElements: (record, additionParams) ->
      labelTypes = @_OW_LABEL_TYPES
      labelDefaults = @_OW_LABEL_DEFAULT_PARAMS
      chars = @_OW_CHARS
      markerIcons = @_OW_MARKER_ICONS
      owTitles = @_OW_TITLES
      additionForLastPlanTitle = owTitles.additionForLastPlan
      charColon = chars.colon
      charEmpty = chars.empty
      charSpace = chars.space
      charNewLine = chars.newLine
      styles = @ownershipStyles

      fields = record.fields
      reflections = record.reflections
      actualStatus = record.actual_status
      createdDateParam = fields.created_at
      updatedDateParam = fields.updated_at
      dateStart = fields.date_start
      dateEnd = fields.date_end
      dateKeep = fields.date_keep
      dateEgrp = fields.date_egrp
      idField = fields.id
      createdDate = new Date(createdDateParam.value).toLocaleString()
      updatedDate = new Date(updatedDateParam.value).toLocaleString()

      # Считаем доп. параметры для формирования элементов, если они были заданы.
      if additionParams?
         createdDateAddition = additionParams.created_at
         updatedDateAddition = additionParams.updated_at
         egrpMarkerAddition = additionParams.egrpMarker
         isIconForCard = additionParams.isIconForCard
         isAnotherCaption = additionParams.isAnotherCaption

      numberLabel =
         `(
             <Label content={idField.value}
                    title={idField.caption}
                    {...labelDefaults.number}
                 />

          )`

      # Если у записи есть связки - считываем пармаетры для формирования элеметов.
      if reflections
         property = reflections.property
         rightholder = reflections.rightholder
         owhershipStatuses = reflections.ownership_statuses
         paymentPlans = reflections.payment_plans
         ownershipTypeParams = @_getOwnershipTypeParams(reflections)

         commonAdditionParams =
            numberMarker:
               isRounded: true
            mainIcon:
               type: labelTypes.ordinaryLight


         # Элементы имущества.
         propertyElements =
            if property? and !_.isEmpty(property)
               propertyRecord = property.value

               if propertyRecord? and !_.isEmpty(propertyRecord)
                  PropertyRegistryRenders._getPropertyElements(propertyRecord,
                                                               commonAdditionParams)
         # Элементы правообладателя.
         rightholderElements =
            if rightholder? and !_.isEmpty(rightholder)
               rightholderRecord = rightholder.value

               if rightholderRecord? and !_.isEmpty(rightholderRecord)
                  RightholderRegistryRenders._getRightholderElements(rightholderRecord,
                                                                     commonAdditionParams)

         # Получаем параметры последнего платежного графика.
         lastPaymentPlan =
            if paymentPlans? and !_.isEmpty(paymentPlans)
               lastPlan = _.last(paymentPlans.value)
               lastPaymentPlanElements =
                  PaymentPlanRenders._getPaymentPlanElements(lastPlan)

               if lastPaymentPlanElements?
                  paymentPlanMainElements = lastPaymentPlanElements.main
                  lastPaymentPlanContent =
                     `(
                        <div style={styles.paymentPlanContent}>
                           {paymentPlanMainElements.totalCost}
                           {paymentPlanMainElements.kbk}
                           {paymentPlanMainElements.dateEnd}
                           {paymentPlanMainElements.dateStart}
                           {paymentPlanMainElements.period}
                           {paymentPlanMainElements.calculation}
                        </div>
                      )`
                  `(
                     <span>
                        <hr style={styles.elementsSplitter}/>
                        <StreamContainer content={lastPaymentPlanContent}
                                        onClickTrigger={this._onClickTriggerPaymentPlan}
                                        {...this._PAYMENT_PLAN_CONTAINER_PARAMS}
                                    />
                     </span>
                  )`

      # Статус правообладания.
      if actualStatus? and !_.isEmpty(actualStatus)
         ownershipStatusParams = @_OWNERSHIP_STATUSES_PARAMS
         statusName = actualStatus.status_name
         statusCaption = actualStatus.status_name_localized
         dateStatus = actualStatus.date_set_status

         findedParams = null

         for statusParams in ownershipStatusParams
            if statusParams.name is statusName
               findedParams = statusParams
               break

         if findedParams?
            markerTile =
               if dateStatus?
                  [
                     statusCaption
                     charSpace
                     charColon
                     charSpace
                     dateStatus
                  ].join charEmpty
               else
                  statusCaption

            # Маркер статуса
            statusMarker =
               `(
                  <Label title={markerTile}
                         icon={findedParams.icon}
                         {...labelDefaults.marker}
                      />
                )`


      # Маркер регистрации в ЕГРП
      egrpMarker =
         if dateEgrp? and dateEgrp.value?
            dateEgrpValue =
               [
                  dateEgrp.caption
                  charSpace
                  charColon
                  charSpace
                  dateEgrp.value
               ].join charEmpty

            `(
                <Label title={dateEgrpValue}
                       icon={markerIcons.egrp}
                       {...labelDefaults.important}
                       {...egrpMarkerAddition}
                    />
             )`

      main:
         type: if ownershipTypeParams?
                  ownershipTypeParams.title
         property: propertyElements
         rightholder: rightholderElements
      markers:
         egrp: egrpMarker
         status: statusMarker
      number: numberLabel
      addition:
         dateStart: @_getOWNameValueElement(dateStart.caption,
                                             dateStart.value,
                                             isAnotherCaption)
         dateEnd: @_getOWNameValueElement(dateEnd.caption,
                                           dateEnd.value,
                                           isAnotherCaption)
         dateKeep: @_getOWNameValueElement(dateKeep.caption,
                                            dateKeep.value,
                                            isAnotherCaption)
         dateEgrp: @_getOWNameValueElement(dateEgrp.caption,
                                           dateEgrp.value,
                                           isAnotherCaption)
      paymentPlan: lastPaymentPlan
      dates:
         created: @_getOWServiceDateLabel(createdDate,
                                          createdDateParam.caption,
                                          false,
                                          createdDateAddition)
         updated: @_getOWServiceDateLabel(updatedDate,
                                          updatedDateParam.caption,
                                          true,
                                          updatedDateAddition)
      icon: @_getOwnershipIcon(ownershipTypeParams, isIconForCard)

   ###*
   * Функция получения неделимого элемента содержимого: Лейбл наименование : значение.
   *  Не создает элемент, если было передано пустое значение (caption).
   *
   * @param {Object, String} caption     - заголовок (надпись-пояснение).
   * @param {Object, String} value       - значение.
   * @param {Boolean} isAnotherCaption   - флаг использования заголовка с отличающимся стилем.
   * @param {Boolean} isWithoutContainer - флаг необходимости отказа от
   *                                       помещения значения в контейнер.
   * @return {React-element, undefined}
   ###
   _getOWNameValueElement: (caption, value, isAnotherCaption, isWithoutContainer) ->

      # Не формируем элемент, если задано пустое значение.
      isEmptyObject = (_.isPlainObject(value) or _.isArray(value)) and _.isEmpty(value)
      isEmptyString = _.isString(value) and _.isEmpty(_.trim(value))
      if !value? or isEmptyObject or isEmptyString
         return

      styles = @ownershipStyles
      chars = @_OW_CHARS

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
             <span style={styles.ownershipValueContainer}>
               {value}
             </span>
          )`

      `(
          <span style={styles.indivisibleContentPart}>
            <span style={isAnotherCaption ? styles.ownershipAltenaviteCaption : null}>
               {captionValue}
            </span>
             {valueElement}
         </span>
      )`

   ###*
   * Функция рендера главного содержимого карточки объекта.
   *
   * @param {Object} record - параметры записи, по которой формируется карточка.
   * @return {React-element}
   ###
   _onRenderOwnershipObjectCardContent: (record) ->
      styles = @ownershipStyles
      labelDefaults = @_OW_LABEL_DEFAULT_PARAMS
      labelDefaultsCaption = labelDefaults.caption
      serviceDateAdditionParams =
         styleAddition:
            common: styles.objectCardServiceDateLabel
         type: @_OW_LABEL_TYPES.ordinaryLight
         isWithoutPadding: true
      contentRowSpan = @_OW_ROWSPANS.main

      additionParams =
         created_at: serviceDateAdditionParams
         updated_at: serviceDateAdditionParams
         isIconForCard: true
         isAnotherCaption: true

      compositeAdditionParams =
         caption:
            isLabel: true
            addition: labelDefaultsCaption
         secondary:
            style: styles.objectCardCompositeContent


      ownershipElements = @_getOwnershipElements(record, additionParams)
      mainElements = ownershipElements.main
      numberElements = ownershipElements.numbers
      datesElements = ownershipElements.dates
      additionElements = ownershipElements.addition
      paymentPlanElement = ownershipElements.paymentPlan
      markerElements = ownershipElements.markers

      `(
         <table style={styles.ownershipTable}>
            <tbody>
               <tr>
                  <td style={styles.objectCardOwnershipDataCell} rowSpan={2}>
                     <table style={styles.ownershipTable}>
                        <tbody>
                           <tr>
                              <td style={styles.ownershipIconCell}>
                                 {ownershipElements.icon}
                              </td>
                              <td style={styles.objectCardOwnershipContentCell}
                                  rowSpan={5}>
                                  <Label content={mainElements.type}
                                         {...labelDefaultsCaption}
                                       />
                                 <ul style={styles.ownershipPropertyList}>
                                    <li>{additionElements.dateStart}</li>
                                    <li>{additionElements.dateEnd}</li>
                                    <li>{additionElements.dateKeep}</li>
                                    <li>{additionElements.dateEgrp}</li>
                                    <li>{paymentPlanElement}</li>
                                 </ul>
                              </td>
                           </tr>
                           <tr>
                              <td style={styles.ownershipMarkersCell}>
                                 {markerElements.status}
                                 {markerElements.paymentPlan}
                              </td>
                           </tr>
                           <tr>
                              <td>
                                 {ownershipElements.number}
                              </td>
                           </tr>
                           <tr>
                              <td style={styles.ownershipImportanceCell}>
                                 {markerElements.egrp}
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
                  </td>
                  <td>
                     {this._getPropertyCellContent(mainElements.property,
                                                   compositeAdditionParams)}
                  </td>
               </tr>
               <tr>
                  <td>
                     {this._getRightholderCellContent(mainElements.rightholder,
                                                      compositeAdditionParams)}
                  </td>
               </tr>
            </tbody>
         </table>
       )`

   ###*
   * Функция определения типа правообладания.
   *
   * @param {Object} reflections - хэш со связками.
   * @return {Object} - параметры типа. Вид:
   *         {String} icon  - иконка.
   *         {String} title - заголовок.
   ###
   _getOwnershipTypeParams: (reflections) ->
      ownershipTypeParams = @_OWNERSHIP_TYPE_PARAMS

      # Если заданы параметры связок - определим параметры, исходя из заданного
      #  типа.
      if reflections? and reflections.ownership_type?
         owTypeParams = _.clone(ownershipTypeParams.other)
         ownershipType = reflections.ownership_type
         otValue = ownershipType.value

         if otValue?
            otFields = otValue.fields
            otKey = otValue.key
            otName = otFields.name.value if otFields?

            for _otParamName, otParam of ownershipTypeParams
               if otParam.key is otKey
                  owTypeParams = otParam
                  break

            owTypeParams.title = otName
         owTypeParams
      else
         ownershipTypeParams.unknown

   ###*
   * Обработчик клика на кнопке скрытия/разворачивания потокового контейнера, в
   *  котором располагается содержимое платежного графика. Останавливает проброс события.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickTriggerPaymentPlan: (event) ->
      event.stopPropagation()

module.exports = OwnershipRegistryRenders

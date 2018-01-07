###* @jsx React.DOM ###

###* Зависимости: модули
* HelpersMixin             - модуль хэлперов.
* StylesMixin              - общие стили для компонентов.
* MoneyFormatter           - модуль для форматирования денежного значения.
* keymirror                - модуль для генерации "зеркального" хэша.
* lodash                   - модуль служебных операций.
* ContentPropertyMapYandex - прикладной модуль карты Яндекс.
* numeral                  - модуль для числовых операций.
###
HelpersMixin = require('components/mixins/helpers')
StylesMixin = require('components/mixins/styles')
MoneyFormatter = require('components/mixins/money_formatter')
ContentPropertyMapYandex = require('components/content/insider/content_registry_map_yandex')
keyMirror = require('keymirror')
_ = require('lodash')
numeral = require('numeral')

###* Зависимости: компоненты
* Button          - кнопка.
* Label           - лейбл.
* StreamContainer - контейнер в потоке.
###
Button = require('components/core/button')
Label = require('components/core/label')
StreamContainer = require('components/core/stream_container')

PropertyExternalInfoViewer = require('components/content/implementations/property_external_info_viewer')

###* Константы.
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

###*
* Модуль рендеров для реестра имущества. Содержит функции произвольного
*  отображения данных по имуществу.
###
PropertyRegistryRenders =

   # @const {Object} - хэш с иконками для кнопок отображения служебных дат записи.
   _PT_RECORD_DATE_ICONS:
      updated: 'refresh'
      created: 'file-o'

   # @const {Object} - используемые символы.
   _PT_CHARS:
      empty: ''
      colon: ':'
      space: ' '
      brStart: '('
      brEnd: ')'
      newLine: '\n'
      question: '?'
      arrowForward: '→'
      amp: '&'
      sharp: '#'
      slash: '/'
      eq: '='

   # @const {Object} - возможные типы имущества.
   _PROPERTY_TYPES: keyMirror(
      unknown: null
      land: null
      realty: null
      movable: null
      unreal: null
      complex: null
   )

   # @const {String} - типы лейблов (для компонента Label)
   _PT_LABEL_TYPES: keyMirror(
      ordinary: null
      ordinaryLight: null
      info: null
      success: null
      exclamation: null
      alert: null
   )

   # @const {Object} - стандартные параметры для различных лейблов.
   _PT_LABEL_DEFAULT_PARAMS:
      marker:
         isWithoutPadding: true
         isLink: true
         isInlineBlock: true
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

   # @const {Object} - параметры для иконок маркеров.
   _PT_MARKER_ICONS:
      legacy: 'star'
      treasury: 'briefcase'
      complex: 'object-group'
      relation: 'upload'
      ownership: 'handshake-o'

   # @const {Object} - заголовоки используемые в маркерах.
   _PT_MARKER_CAPTIONS:
      treasury: "с <%= date %> объект находится в казне:"
      complex: 'Объект входит в комплексы:'
      relation: 'Объект относится к:'
      ownership: 'Установлено правообладание'

   # @const {String} - типы лейблов (для компонента Label)
   _PT_LABEL_TYPES: keyMirror(
      ordinary: null
      ordinaryLight: null
      info: null
      success: null
      exclamation: null
      alert: null
   )

   # @const {Object} - параметры статуса объекта.
   _OBJECT_STATUSES:
      unknown:
         value: 'Неизвестный'
         icon: 'question-circle'
      drawn:
         value: 'Оформляется'
         icon: 'pencil-square'
      actual:
         value: 'Актуальный'
      archival:
         value: 'Архивный'
         icon: 'archive'

   # @const {Object} - параметры, используемые для формирования контента имущества по типам.
   _PROPERTY_TYPE_PARAMS:
      unknown:
         type: 'unknown'
         title: 'Неклассифицированное'
         icon: 'question-circle'
      land:
         type: 'land'
         propertyType: 1
         icon: 'globe'
      realty:
         type: 'realty'
         propertyType: 2
         icon: 'building-o'
      movable:
         type: 'movable'
         propertyType: 3
         icon: 'car'
      unreal:
         type: 'unreal'
         propertyType: 4
         icon: 'cloud'
      complex:
         type: 'complex'
         propertyType: 5
         icon: 'object-group'

   # # @const {Object} - специфичные параметры для полей.
   # _PT_SPECIFIC_FIELD_PARAMS:
   #    cost_balance:
   #       isMoney: true
   #    cost_inventory:
   #       isMoney: true
   #    cost_rest:
   #       isMoney: true
   #    real_cadastre_cost:
   #       isMoney: true

   # @const {String} - заполнитель пустых полей.
   _PT_MISSED_PARAM_TITLE: '-'

   # @const {String} - строка-перфикс классов для иконок FontAwesome.
   _PT_FA_ICON_PREFIX: 'fa fa-'

   # @const {Object} - объект с кол-вом объединений для объектов таблиц
   _TABLE_SPANS:
      mainRowSpan: 2
      cardRowSpan: 5

   # @const {String} - строка для формирования имени характеристики имущества.
   _PROPERTY_FEATURE_NAME: 'feature'

   # @const {String} - наименование кадастрового номера
   _CADASTRE_NUMBER_FIELD: 'real_cadastre_number'

   # @const {Object} - параметры кадастровой карты.
   _CADASTRE_EXTERNAL_SERVICES_PARAMS:
      cadastreMap:
         title: 'Найти объект на публичной кадастровой карте'
         url: 'http://pkk5.rosreestr.ru'
         reqParams:
            text: 'text'
            type: 'type'
            rest: '&z=12&app=search&opened=1'
         types:
            land: 1
            realty: 5
            address: -1
      registry:
         title: 'Справочная информация по объектам Росреестра'
         url: 'http://rosreestr.ru/wps/portal/cc_information_online'
         icon: 'external-link'
         reqParams:
            number: 'KN'


   propertyStyles:
      propertyTable:
         width: '100%'
      propertyIconCard:
         fontSize: 50
         color: _COLORS.hierarchy3
      propertyIcon:
         fontSize: 30
      propertyStatusMarker:
         fontSize: 22
      propertyIconCell:
         minWidth: 40
         textAlign: 'center'
      propertyMarkersCell:
         whiteSpace: 'normal'
         width: '7%'
      propertyDataCell:
         width: '100%'
         whiteSpace: 'normal'
         color: _COLORS.dark
      propertyStatusMarkersCell:
         maxWidth: 30
         whiteSpace: 'normal'
         paddingRight: _COMMON_PADDING
         textAlign: 'center'
      propertyNumberCell:
         minWidth: 80
      propertyDateCell:
         color: _COLORS.hierarchy3
         minWidth: 100
      propertyNumberLabel:
         paddingTop: _COMMON_PADDING
         paddingBottom: _COMMON_PADDING
      markerParamCaption:
         color: _COLORS.hierarchy3
      indivisibleContentPart:
         display: 'inline-block'
      propertyValueContainer:
         paddingRight: _COMMON_PADDING * 2
         paddingLeft: _COMMON_PADDING
      propertyAltenaviteCaption:
         color: _COLORS.hierarchy3
      propertyDateButton:
         color: _COLORS.hierarchy2
      propertyAccountNumberLabel:
         textAlign: 'center'
         padding: _COMMON_PADDING
         fontSize: 11
         marginBottom: 1
         backgroundColor: _COLORS.highlight2
         color: _COLORS.highlight1
         borderStyle: 'solid'
         borderWidth: 1
         borderColor: _COLORS.hierarchy4
      propertyOldAccountNumberLabel:
         textAlign: 'center'
         padding: _COMMON_PADDING
         backgroundColor: _COLORS.hierarchy4
         color: _COLORS.hierarchy2
         fontSize: 11
      propertyParamSecondary:
         color: _COLORS.hierarchy3
         fontSize: 12
         paddingTop: _COMMON_PADDING
      propertyParamSecondaryValue:
         paddingRight: _COMMON_PADDING * 2
         paddingLeft: _COMMON_PADDING
         textDecoration: 'underline'
      mutedLink:
         color: _COLORS.hierarchy2
      objectCardMainTable:
         width: '100%'
         tableLayout: 'fixed'
      objectCardMainIconCell:
         width: '15%'
         height: '30%'
         verticalAlign: 'middle'
         textAlign: 'center'
         padding: 10
      objectCardIconContainer:
         verticalAlign: 'middle'
      objectCardMarkersContainer:
         verticalAlign: 'middle'
         maxWidth: 120
      objectCardMainSpecificCell:
         verticalAlign: 'top'
      objectCardNumbersCell:
         verticalAlign: 'top'
      objectCardStatusMarkersCell:
         textAlign: 'left'
         padding: _COMMON_PADDING
      objectCardServiceDateCell:
         verticalAlign: 'top'
         height: '10%'
      objectCardFillerRow:
         height: '100%'
      objectStatusMarkersRow:
         maxHeight: 40
      objectCardEntityCaption:
         padding: _COMMON_PADDING
         fontSize: 16
      objectCardEntitySubCaption:
         textAlign: 'center'
      objectCardServiceDateLabel:
         fontSize: 10
      objectCardContentList:
         fontSize: 14
         color: _COLORS.hierarchy2
         listStyle: 'none'
         overflow: 'auto'
      objectCardTypeListItem:
         color: _COLORS.hierarchy3
      objectCardTypeItem:
         fontSize: 12
         color: _COLORS.hierarchy3
      objectCardTypeLastItem:
         fontSize: 13
         color: _COLORS.hierarchy2
         whiteSpace: 'nowrap'
      cadastreRegistryLinkButton:
         paddingLeft: 3
         fontSize: 13

   _getPropertyMap: ->
      `(<ContentPropertyMapYandex />)`

   ###*
   * Функция рендера ячейки отображения имущества основного реестра.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object} record - запись.
   * @return {Object} - содержимое ячейки для отображения имущества.
   ###
   _onRenderPropertyCell: (rowRef, record) ->
      missedTitle = @_PT_MISSED_PARAM_TITLE
      styles = @propertyStyles
      elementAdditionParams =
         statusMarker:
            styleAddition:
               common: styles.propertyStatusMarker
         ownershipMarker:
            styleAddition:
               common: styles.propertyStatusMarker
         isMutedLinks: true

      propertyElements = @_getPropertyElements(record, elementAdditionParams)
      mainElements = propertyElements.main
      numberElements = propertyElements.numbers
      datesElements = propertyElements.dates
      secondaryElements = propertyElements.secondary
      additionElements = propertyElements.addition
      markerElements = propertyElements.markers
      contentRowSpan = @_TABLE_SPANS.mainRowSpan

      `(
         <table style={styles.propertyTable}>
            <tbody>
               <tr>
                  <td style={styles.propertyIconCell}>
                     {propertyElements.icon}
                  </td>
                  <td style={styles.propertyDataCell} rowSpan={contentRowSpan}>
                     {mainElements.name}
                     <div style={styles.propertyParamSecondary}>
                        {additionElements.oktmo}
                        {secondaryElements.inventoryNumber}
                        {secondaryElements.manufacturedDate}
                        {secondaryElements.registrationDate}

                        {secondaryElements.moveAutoBodyNumber}
                        {secondaryElements.moveAutoEngineNumber}
                        {secondaryElements.moveAutoPtsNumber}
                        {secondaryElements.moveAutoRegistrationNumber}
                        {secondaryElements.moveAutoVinNumber}

                        {secondaryElements.realGenericCadastreNumbers}
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
                        {additionElements.external}
                     </div>
                  </td>
                  <td style={styles.propertyStatusMarkersCell} rowSpan={contentRowSpan}>
                     {markerElements.status}
                     {markerElements.ownership}
                  </td>
                  <td style={styles.propertyNumberCell} rowSpan={contentRowSpan}>
                     {numberElements.account}
                     {numberElements.oldAccount}
                  </td>
                  <td style={styles.propertyDateCell} rowSpan={contentRowSpan}>
                     {datesElements.created}
                     {datesElements.updated}
                  </td>
               </tr>
               <tr>
                  <td style={styles.propertyMarkersCell}>
                     {markerElements.legacy}
                     {markerElements.treasury}
                     {markerElements.complex}
                     {markerElements.relation}
                  </td>
               </tr>
            </tbody>
         </table>
      )`

   ###*
   * Функция получения элементов для отображения имущества.
   *
   * @param {Object} record - запись карточки объекта.
   * @param {Object} additionParams - доп. параметры для элементов.
   * @return {Object} - элементы
   ###
   _getPropertyElements: (record, additionParams) ->
      propertyTypes = @_PROPERTY_TYPES
      labelDefaults = @_PT_LABEL_DEFAULT_PARAMS
      markerIcons = @_PT_MARKER_ICONS
      chars = @_PT_CHARS
      markerCaptions = @_PT_MARKER_CAPTIONS
      objectStatuses = @_OBJECT_STATUSES
      newLineChar = chars.newLine
      colonChar = chars.colon
      brStartChar = chars.brStart
      brEndChar = chars.brEnd
      spaceChar = chars.space
      emptyChar = chars.empty
      styles = @propertyStyles
      fields = record.fields
      actualTreasury = record.actual_treasury
      reflections = record.reflections
      propertyTypeParams = @_getPropertyTypeParams(reflections)
      accountNumber = fields.id
      oldAccountNumber = fields.old_account_number
      createdDateParam = fields.created_at
      updatedDateParam = fields.updated_at
      legacyParam = fields.legacy
      objectStatus = fields.object_status
      createdDate = new Date(createdDateParam.value).toLocaleString()
      updatedDate = new Date(updatedDateParam.value).toLocaleString()

      # Считаем доп. параметры для формирования элементов, если они были заданы.
      if additionParams?
         createdDateAddition = additionParams.created_at
         updatedDateAddition = additionParams.updated_at
         mainIconAddition = additionParams.mainIcon
         statusMarkerAddition = additionParams.statusMarker
         ownershipMarkerAddition = additionParams.ownershipMarker
         numberMarkerAddition = additionParams.numberMarker
         typeHierarchyAddition = additionParams.typeHierarchy
         isIconForCard = additionParams.isIconForCard
         isAnotherCaption = additionParams.isAnotherCaption
         isMutedLinks = additionParams.isMutedLinks

      # Если у записи есть связки - считываем пармаетры для формирования элеметов.
      if reflections
         oktmo = reflections.oktmo
         treasuries = reflections.treasuries
         propertyTypes = reflections.property_types
         propertyComplexes = reflections.property_complexes
         propertyFeatures = reflections.property_features
         propertyRelations = reflections.property_relations
         ownerships = reflections.ownerships

         # Доп. папраметр - лейбл ОКТМО
         if oktmo? and !_.isEmpty oktmo
            oktmoValue = oktmo.value
            fieldsOktmo = oktmoValue.fields
            oktmoNumber = fieldsOktmo.section.value
            oktmoName = fieldsOktmo.name.value

            oktmoLabel =
               `(<Label content={oktmoNumber}
                        title={oktmoName}
                        {...labelDefaults.info}
                      />)`
            oktmoElement = @_getPTNameValueElement(oktmo.caption,
                                                   oktmoLabel,
                                                   true,
                                                   isAnotherCaption)

         # Обрабатываем типы имущества(доп. классификацию), обрабатываем её, только
         #  если заданных типов больше 1
         if propertyTypes? and propertyTypes.value.length > 1
            types = propertyTypes.value

            # Формируем иерархии типов имущества. Будут сформированы иерархии типов
            #  для всех заданных типов имущества для вывода в виде:
            # подтип1→→значение типа.
            propertyTypeHierarchy =
               @_getPropertyTypeHierarchy(types, typeHierarchyAddition)


         # Доп. параметры - характеристики.
         if propertyFeatures? and !_.isEmpty propertyFeatures
            features = propertyFeatures.value
            featureNameDummy = @_PROPERTY_FEATURE_NAME
            threeFeatures = features[0..2]
            featuresElements = {}

            for feature, idx in threeFeatures
               featureFields = feature.fields
               featureReflections = feature.reflections
               featureParameter = if featureReflections
                                     featureReflections.property_parameter

               caption = if featureParameter?
                         parameterFields = featureParameter.value.fields


                         if parameterFields?
                            parameterMeasure = parameterFields.measure.value
                            parameterName = parameterFields.name.value

                            if parameterMeasure?
                               [
                                  parameterName
                                  spaceChar
                                  brStartChar
                                  parameterMeasure
                                  brEndChar
                               ].join emptyChar
                            else
                              parameterName


               featuresElements[featureNameDummy + (idx + 1)] =
                  @_getPTNameValueElement(caption,
                                          featureFields.value.value,
                                          false,
                                          isAnotherCaption)

         # Маркер отношения в казну.
         treasuryMarker =
            if actualTreasury? and !_.isEmpty actualTreasury
               trRightholder = actualTreasury.rightholder
               inputDate = HelpersMixin.convertToHumanDate(
                  actualTreasury.event_date
               )

               if trRightholder? and !_.isEmpty trRightholder
                  rightholderEntity = trRightholder.entity

                  if rightholderEntity? and !_.isEmpty rightholderEntity

                     entityName =
                        [
                           brStartChar
                           rightholderEntity.id
                           brEndChar
                           spaceChar
                           rightholderEntity.full_name
                        ].join emptyChar

                     markerCaption =
                        _.template(markerCaptions.treasury)(date: inputDate)

                     entityMarkerTitle =
                        `(
                           <div>
                              <div style={styles.markerParamCaption}>
                                 {markerCaption}
                              </div>
                              <div>{entityName}</div>
                           </div>
                         )`

                     `(
                        <Label icon={markerIcons.treasury}
                               title={entityMarkerTitle}
                               {...labelDefaults.marker}
                             />
                      )`

         # Маркер включения в состав комплекса.
         complexMarker =
            if propertyComplexes and !_.isEmpty propertyComplexes
               complexes = propertyComplexes.value

               if complexes? and !_.isEmpty complexes
                  complexNames =
                     complexes.map((complexParams) ->
                        complexReflections = complexParams.reflections
                        complexProperty = complexReflections.property if complexReflections?

                        if complexProperty? and !_.isEmpty complexProperty
                           complexValue = complexProperty.value

                           [
                              brStartChar
                              complexValue.key
                              brEndChar
                              spaceChar
                              complexValue.fields.name.value
                           ].join emptyChar
                     ).join newLineChar


                  entityMarkerTitle =
                     `(
                        <div>
                           <div style={styles.markerParamCaption}>
                              {markerCaptions.complex}
                           </div>
                           <div>{complexNames}</div>
                        </div>
                      )`

                  `(
                     <Label icon={markerIcons.complex}
                            title={entityMarkerTitle}
                            {...labelDefaults.marker}
                          />
                   )`

         # Маркер принадлежности.
         relationMarker =
            if propertyRelations and !_.isEmpty propertyRelations
               relations = propertyRelations.value

               if relations? and !_.isEmpty relations
                  relationProperties =
                     relations.map((relationParams) ->
                        relationReflections = relationParams.reflections
                        relationProperty =
                           if relationReflections? and !_.isEmpty(relationReflections)
                              relationReflections.property_relation

                        if relationProperty? and !_.isEmpty relationProperty
                           relationValue = relationProperty.value

                           [
                              brStartChar
                              relationValue.key
                              brEndChar
                              spaceChar
                              relationValue.fields.name.value
                           ].join emptyChar
                     ).join chars.newLine

                  relationMarkerTitle =
                     `(
                        <div>
                           <div style={styles.markerParamCaption}>
                              {markerCaptions.relation}
                           </div>
                           <div>{relationProperties}</div>
                        </div>
                      )`

                  `(
                     <Label icon={markerIcons.relation}
                            title={relationMarkerTitle}
                            {...labelDefaults.marker}
                          />
                   )`

         # Маркер правообладания.
         ownershipMarker =
            if ownerships? and !_.isEmpty(ownerships)
               ownershipsValue =  ownerships.value

               if ownershipsValue
                  lastOwnership = _.last(ownershipsValue)
                  lastOwnershipReflections = lastOwnership.reflections

                  ownershipType =
                     if lastOwnershipReflections? and lastOwnershipReflections.ownership_type?
                        lastOwnershipReflections.ownership_type.value.fields.name.value

                  ownershipTitle =
                     if ownershipType?
                        `(
                           <div>
                              <div style={styles.markerParamCaption}>
                                 {markerCaptions.ownership}
                              </div>
                              <div>{ownershipType}</div>
                           </div>
                         )`
                     else
                        markerCaptions.ownership

                  `(
                     <Label icon={markerIcons.ownership}
                            title={ownershipTitle}
                            {...labelDefaults.marker}
                            {...ownershipMarkerAddition}
                          />
                   )`

      # Маркер объекта культурного наследия.
      legacyMarker =
         if legacyParam? and legacyParam.value
            `(
               <Label icon={markerIcons.legacy}
                      title={legacyParam.caption}
                      {...labelDefaults.marker}
                    />
             )`
      # Маркер статуса.
      statusMarker =
         if objectStatus and objectStatus.value
            status = objectStatus.value
            unknownStatusParams = objectStatuses.unknown
            StatusParams = objectStatuses.unknown
            unknownStatusParams = objectStatuses.unknown
            drawnStatusParams = objectStatuses.drawn
            archivalStatusParams = objectStatuses.archival

            markerIcon =
               switch status
                  when unknownStatusParams.value
                     unknownStatusParams.icon
                  when drawnStatusParams.value
                     drawnStatusParams.icon
                  when archivalStatusParams.value
                     archivalStatusParams.icon

            if markerIcon
               statusTitle =
                  [
                     objectStatus.caption
                     colonChar
                     spaceChar
                     status
                  ].join emptyChar

               `(
                  <Label icon={markerIcon}
                         title={statusTitle}
                         {...labelDefaults.marker}
                         {...statusMarkerAddition}
                       />
                )`

      main:
         name: fields.name.value
      markers:
         legacy: legacyMarker
         treasury: treasuryMarker
         complex: complexMarker
         relation: relationMarker
         ownership: ownershipMarker
         status: statusMarker
      addition:
         oktmo: oktmoElement
         features: featuresElements
         typeHierarchy: propertyTypeHierarchy
         external: @_getExternalSystemInformationView(record)
      secondary: @_getPropertySecondaryData(fields,
                                            {
                                               name: {
                                                  isProhibited: true
                                               },
                                               isMutedLinks: isMutedLinks
                                            },
                                            isAnotherCaption,
                                            propertyTypeParams)
      numbers:
         account: @_getPTIdentifierNumberLabel(accountNumber,
                                               false,
                                               numberMarkerAddition)
         oldAccount: @_getPTIdentifierNumberLabel(oldAccountNumber,
                                                  true,
                                                  numberMarkerAddition)
      dates:
         created: @_getPTServiceDateLabel(createdDate,
                                          createdDateParam.caption,
                                          false,
                                          createdDateAddition)
         updated: @_getPTServiceDateLabel(updatedDate,
                                          updatedDateParam.caption,
                                          true,
                                          updatedDateAddition)
      icon: @_getPropertyIcon(propertyTypeParams, isIconForCard, mainIconAddition)

   ###*
   * Функция получения отображения данных загруженных по имуществу из внешних систем.
   *
   * @param {Object} record - запись.
   * @return {React-Element}
   ###
   _getExternalSystemInformationView: (record) ->
      `(<PropertyExternalInfoViewer propertyKey={record.key}/>)`

   ###*
   * Обработчик клика на кнопке скрытия/разворачивания потокового контейнера, в
   *  котором располагается содержимое информации из внешних систем.
   *  Останавливает проброс события.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickTriggerExternalSystemInfo: (event) ->
      event.stopPropagation()

   ###*
   * Функция получения иконки имущества.
   *
   * @param {Object} propertyTypeParams - параметры типа имущества.
   * @param {Boolean} isForCard         - флаг получения иконки для карточки (другой стиль).
   * @param {Object} additionParams     - доп. параметры для иконки.
   * @return {React-Element}
   ###
   _getPropertyIcon: (propertyTypeParams, isForCard, additionParams) ->
      faIconPrefix = @_PT_FA_ICON_PREFIX
      labelDefaults = @_PT_LABEL_DEFAULT_PARAMS
      styles = @propertyStyles

      iconStyle = if isForCard
                     styles.propertyIconCard
                  else
                     styles.propertyIcon

      `(
         <Label icon={propertyTypeParams.icon}
                title={propertyTypeParams.title}
                styleAddition={{common: iconStyle}}
                {...labelDefaults.type}
                {...additionParams}
              />
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
   _getPTServiceDateLabel: (date, title, isUpdate, additionParams) ->
      labelDefaults = @_PT_LABEL_DEFAULT_PARAMS
      recordDateIcons = @_PT_RECORD_DATE_ICONS

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
   * Функция получения лейбла с реестровым номером правообладаетеля.
   *
   * @param {Object} identifierNumber - параметры реестрового номера.
   * @param {Boolean} isDepressed     - флаг "подавленного" стиля лейбла - для вывода
   *                                    не основного номера (старого реестрового номера).
   * @param {Object} additionParams   - доп. параметры для лейбла.
   * @return {React-element}
   ###
   _getPTIdentifierNumberLabel: (identifierNumber, isDepressed, additionParams) ->
      styles = @propertyStyles
      labelDefaults = @_PT_LABEL_DEFAULT_PARAMS
      labelTypes = @_PT_LABEL_TYPES
      type = if isDepressed
                labelTypes.common
             else
                labelTypes.exclamation

      `(
         <Label content={identifierNumber.value}
                title={identifierNumber.caption}
                type={type}
                styleAddition={{common: styles.propertyNumberLabel}}
                {...labelDefaults.number}
                {...additionParams}
            />
       )`

   ###*
   * Функция перебора полей записи и получения для каждого поля - элемента для
   *  отображения.
   *
   * @param {Object} fields             - параметры полей.
   * @param {Object} specificSettings   - специфичные настройки.
   * @param {Boolean} isAnotherCaption  - флаг иного заголовка.
   * @param {Object} propertyTypeParams - параметры основного типа имущества.
   * @return {Object} - набор элементов для отображения значений в полях. Вид:
   *                    [fieldName]: [fieldValueElement]
   ###
   _getPropertySecondaryData: (fields, specificSettings, isAnotherCaption, propertyTypeParams) ->
      # specificParams = @_PT_SPECIFIC_FIELD_PARAMS
      isMutedLinks = specificSettings.isMutedLinks if specificSettings?
      dataElements = {}

      for fieldName, field of fields
         specificFieldSetting = specificSettings[fieldName]
         # specificFieldParam = specificParams[fieldName]
         isProhibited = false
         fieldValue = field.value
         fieldCaption = field.caption
         fieldType = field.type
         isCadastreNumber = fieldName is @_CADASTRE_NUMBER_FIELD

         # if specificFieldParam? and !_.isEmpty specificFieldParam
         #    if specificFieldParam.isMoney
         #       fieldValue =
         #          MoneyFormatter.formatMoney(fieldValue, fieldType, true)

         if isCadastreNumber
            fieldValue = @_getCadastreNumberWithLinks(fieldValue,
                                                      isMutedLinks,
                                                      propertyTypeParams.type)

         if specificFieldSetting?
            isProhibited = specificFieldSetting.isProhibited
            isWithoutContainer = specificFieldSetting.isWithoutContainer

         unless isProhibited
            dataElements[_.camelCase(fieldName)] =
               @_getPTNameValueElement(fieldCaption,
                                       fieldValue,
                                       isWithoutContainer,
                                       isAnotherCaption)

      dataElements

   ###*
   * Функция получения отображения по одноуровневой иерархии типов.
   *  Создает отображение, если в типах присутствуют типы в которых есть родительские
   *  типы.
   *
   * @param {Array} types                  - типы имущества.
   * @param {Objecе} typeHierarchyAddition - доп. параметры отображения.
   * @return {React-element}
   ###
   _getPropertyTypeHierarchy: (types, typeHierarchyAddition) ->
      chars = @_PT_CHARS
      arrowForwardChar = chars.arrowForward
      subordinateTypes = []

      # Определим доп. параметры для элемента.
      if typeHierarchyAddition?
         listStyle = typeHierarchyAddition.style
         listItemStyle = typeHierarchyAddition.listItemStyle
         labelStyle = typeHierarchyAddition.labelStyle
         lastLabelStyle = typeHierarchyAddition.lastLabelStyle

      getTypeLabel = ((key, typeName, typeDescription, typeStyle)->
         labelDefaults = @_PT_LABEL_DEFAULT_PARAMS

         `(
              <Label key={key}
                     styleAddition={{common: typeStyle}}
                     content={typeName}
                     title={typeDescription}
                     {...labelDefaults.type}
                  />
         )`
      ).bind(this)

      for type, idx in types
         parentType = type.parent
         typeFields = type.fields

         if parentType?
            subordinateTypes.push(
               [
                  getTypeLabel(
                     arrowForwardChar + idx,
                     parentType.name,
                     parentType.description,
                     labelStyle,
                  ),
                  arrowForwardChar,
                  getTypeLabel(
                     idx,
                     typeFields.name.value,
                     typeFields.description.value
                     lastLabelStyle
                  )
               ]
            )

      subTypesElements =
         subordinateTypes.map (hierarchyChain, idx) ->
            `(
               <li key={idx}
                   style={listItemStyle}>
                  {hierarchyChain}
               </li>
             )`

      `(
         <ul style={listStyle} >
            {subTypesElements}
         </ul>
       )`


      # if subTypes? and subTypes.length
      #    hierarchy = []

      #    for subType in subTypes
      #       subTypeHierarchy = subType.hierarchy
      #       hierarchyChain = []

      #       if subTypeHierarchy?
      #          subTypeHierarchyCount = subTypeHierarchy.length

      #          for hierarchyType, idx in subTypeHierarchy

      #             # Первый тип (основной тип Земля, недвижимость и т.д.)
      #             #  не добавляем, т.к. он и так отображается иконкой-маркером.
      #             if idx > 0
      #                typeName = hierarchyType.name
      #                typeDescription = hierarchyType.description
      #                typeStyle = null
      #                joiner = null


      #                if idx is (subTypeHierarchyCount - 1)
      #                   typeStyle = lastLabelStyle
      #                else
      #                   typeStyle = labelStyle
      #                   joiner = arrowForwardChar

      #                hierarchyChain.push(
      #                   `(
      #                      <Label key={idx}
      #                             styleAddition={{common: typeStyle}}
      #                             content={typeName}
      #                             title={typeDescription}
      #                             {...labelDefaults.type}
      #                          />
      #                    )`
      #                )

      #                hierarchyChain.push(joiner) if joiner?

      #       unless _.isEmpty hierarchyChain
      #          hierarchy.push(hierarchyChain)

   ###*
   * Функция получения кадастрового номера со ссылкой на кадастровую карту.
   *
   * @param {String} cadastreNumber - кадастровый номер.
   * @param {Boolean} isMutedLinks  - флаг создания "приглушенной" ссылки(для того,
   *                                  чтобы она не сильно выделялась среди остальных полей).
   * @param {String} propertyType   - наименование типа имущества.
   * @return {React-element}
   ###
   _getCadastreNumberWithLinks: (cadastreNumber, isMutedLinks, propertyType) ->
      cadastreExternalServicesParams = @_CADASTRE_EXTERNAL_SERVICES_PARAMS
      cadastreMapParams = cadastreExternalServicesParams.cadastreMap
      cadastreRegistryParams = cadastreExternalServicesParams.registry
      chars = @_PT_CHARS
      eqChar = chars.eq
      ampChar = chars.amp
      emptyChar = chars.empty
      mapReqParams = cadastreMapParams.reqParams
      mapTypes = cadastreMapParams.types
      mapLinkType = mapTypes[propertyType] or mapTypes.address
      regReqParams = cadastreRegistryParams.reqParams
      escapedCadastreNumber = encodeURIComponent(cadastreNumber)

      # registry:
      #    title: 'Справочная информация по объектам в Росреестре'
      #    url: 'http://rosreestr.ru/wps/portal/cc_information_online'
      #    icon: 'external-link'
      #    mapReqParams:
      #       number: 'KN'

      cadastreMapLink =
         [
            cadastreMapParams.url
            chars.slash
            chars.sharp
            mapReqParams.text
            eqChar
            escapedCadastreNumber
            ampChar
            mapReqParams.type
            eqChar
            mapLinkType
            mapReqParams.rest
         ].join emptyChar

      cadastreRegistryLink =
         [
            cadastreRegistryParams.url
            chars.question
            regReqParams.number
            eqChar
            escapedCadastreNumber
         ].join emptyChar

      styleAddition =
         if isMutedLinks
            @propertyStyles.mutedLink

      cadastreRegistryLinkButton = @propertyStyles.cadastreRegistryLinkButton

      registryLinkButtonStyle =
         if styleAddition?
            _.merge(styleAddition, cadastreRegistryLinkButton)
         else
            cadastreRegistryLinkButton


      `(
         <span>
            <Button title={cadastreMapParams.title}
                    caption={cadastreNumber}
                    value={cadastreMapLink}
                    styleAddition={styleAddition}
                    isLink={true}
                    isWithoutPadding={true}
                    onClick={this._onClickOpenCadastreMap}
                 />
            <Button title={cadastreRegistryParams.title}
                    icon={cadastreRegistryParams.icon}
                    value={cadastreRegistryLink}
                    styleAddition={registryLinkButtonStyle}
                    isWithoutPadding={true}
                    isLink={true}
                    onClick={this._onClickOpenCadastreMap}
                  />
         </span>
       )`

   ###*
   * Функция обработчик на клик по кнопке перехода на кадастровую карты.
   *  Останавливает проброс события клика и открывает ссылку на карту в новом окне.
   *
   * @param {String} url - подготовленная ссылка с поиском объекта по кад. номеру.
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickOpenCadastreMap: (url, event) ->
      event.stopPropagation()
      window.open(url)


   ###*
   * Функция получения неделимого элемента содержимого: Лейбл наименование : значение.
   *  Не создает элемент, если было передано пустое значение.
   *
   * @param {Object, String} caption - заголовок (надпись-пояснение).
   * @param {Object, String} value - значение.
   * @param {Boolean} isWithoutContainer - флаг необходимости отказа от
   *                                       помещения значения в контейнер.
   * @return {React-Element, undefined}
   ###
   _getPTNameValueElement: (caption, value, isWithoutContainer, isAnotherCaption) ->

      # Не формируем элемент, если задано пустое значение.
      isEmptyObject = (_.isPlainObject(value) or _.isArray(value)) and _.isEmpty(value)
      isEmptyString = _.isString(value) and _.isEmpty(_.trim(value))
      if !value? or isEmptyObject or isEmptyString
         return

      styles = @propertyStyles
      chars = @_PT_CHARS

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
                           <span style={styles.propertyValueContainer}>
                              {value}
                           </span>
                         )`

      `(
         <span style={styles.indivisibleContentPart}>
            <span style={isAnotherCaption ? styles.propertyAltenaviteCaption : null}>
               {captionValue}
            </span>
            {valueElement}
         </span>
       )`

   ###*
   * Функция рендера главного содержимого карточки объекта имущества.
   *
   * @param {Object} record - параметры записи, по которой формируется карточка.
   * @return {React-element}
   ###
   _onRenderPropertyObjectCardContent: (record) ->
      cardRowSpan = @_TABLE_SPANS.cardRowSpan
      labelDefaults = @_PT_LABEL_DEFAULT_PARAMS
      styles = @propertyStyles
      serviceDateAdditionParams =
         styleAddition:
            common: styles.objectCardServiceDateLabel
         type: @_PT_LABEL_TYPES.ordinaryLight
         isWithoutPadding: true

      additionParams =
         created_at: serviceDateAdditionParams
         updated_at: serviceDateAdditionParams
         typeHierarchy:
            style: styles.objectCardContentList
            listItemStyle: styles.objectCardTypeListItem
            labelStyle: styles.objectCardTypeItem
            lastLabelStyle: styles.objectCardTypeLastItem
         isIconForCard: true
         isAnotherCaption: true
         statusMarker:
            styleAddition:
               common: styles.propertyStatusMarker
         ownershipMarker:
            styleAddition:
               common: styles.propertyStatusMarker

      propertyElements = @_getPropertyElements(record, additionParams)
      mainElements = propertyElements.main
      numberElements = propertyElements.numbers
      datesElements = propertyElements.dates
      secondaryElements = propertyElements.secondary
      additionElements = propertyElements.addition
      markerElements = propertyElements.markers

      `(
         <table style={styles.objectCardMainTable}>
            <tbody>
               <tr>
                  <td style={styles.objectCardMainIconCell}>
                     {propertyElements.icon}
                     <div style={styles.objectCardMarkersContainer}>
                        {markerElements.legacy}
                        {markerElements.treasury}
                        {markerElements.complex}
                        {markerElements.relation}
                     </div>
                  </td>
                  <td rowSpan={cardRowSpan}
                      style={styles.objectCardMainSpecificCell} >
                     <Label styleAddition={{common: styles.objectCardEntityCaption}}
                            content={mainElements.name}
                            {...labelDefaults.caption}
                         />
                     {additionElements.typeHierarchy}
                     <ul style={styles.objectCardContentList}>
                        <li>{additionElements.oktmo}</li>
                        <li>{secondaryElements.inventoryNumber}</li>
                        <li>{secondaryElements.manufacturedDate}</li>
                        <li>{secondaryElements.registrationDate}</li>

                        <li>{secondaryElements.moveAutoBodyNumber}</li>
                        <li>{secondaryElements.moveAutoEngineNumber}</li>
                        <li>{secondaryElements.moveAutoPtsNumber}</li>
                        <li>{secondaryElements.moveAutoRegistrationNumber}</li>
                        <li>{secondaryElements.moveAutoVinNumber}</li>

                        <li>{secondaryElements.realGenericCadastreNumbers}</li>
                        <li>{secondaryElements.realCadastreDateRegistration}</li>
                        <li>{secondaryElements.realCadastreNumber}</li>
                        <li>{secondaryElements.realOldCadastreNumber}</li>
                        <li>{secondaryElements.realFullFootage}</li>
                        <li>{secondaryElements.realOldConditionNumber}</li>
                        <li>{secondaryElements.realtyApartamentType}</li>
                        <li>{secondaryElements.realtyLevelNumber}</li>
                        <li>{secondaryElements.realtyLevelsCount}</li>
                        <li>{secondaryElements.realtyNumberOnLevel}</li>
                        <li>{secondaryElements.realtyUndergroundLevelsCount}</li>

                        <li>{additionElements.features ? additionElements.features.feature1 : null}</li>
                        <li>{additionElements.features ? additionElements.features.feature2 : null}</li>
                        <li>{additionElements.features ? additionElements.features.feature3 : null}</li>
                     </ul>
                     {additionElements.external}
                  </td>
               </tr>
               <tr>
                  <td style={styles.objectCardNumbersCell}>
                     {numberElements.account}
                     {numberElements.oldAccount}
                  </td>
               </tr>
               <tr style={styles.objectStatusMarkersRow}>
                  <td style={styles.objectCardStatusMarkersCell}>
                     {markerElements.status}
                     {markerElements.ownership}
                  </td>
               </tr>
               <tr style={styles.objectCardFillerRow}><td></td></tr>
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
   * Функция определения типа имущества.  Возвращает хэш с параметрами типа имущества
   *  иконкой, заголовком и именем типа.
   *
   * @param {Object} reflections - хэш со связками.
   * @return {Object}
   ###
   _getPropertyTypeParams: (reflections) ->
      propertyTypeParams = @_PROPERTY_TYPE_PARAMS
      propTypeParams = propertyTypeParams.unknown

      # Если есть параметры связок с типами - получим тип исходя из назначенного типа.
      if reflections? and reflections.property_types?
         propertyTypes = reflections.property_types.value

         if propertyTypes? and propertyTypes.length
            findedType = null

            for propType in propertyTypes

               findedType  = switch propType.fields.id.value
                             when 1 then propertyTypeParams.land
                             when 2 then propertyTypeParams.realty
                             when 3 then propertyTypeParams.movable
                             when 4 then propertyTypeParams.unreal
                             when 5 then propertyTypeParams.complex

               break if findedType?

            if findedType?
               propTypeParams = findedType
               propTypeParams.title = propType.fields.name.value

         propTypeParams
      else
         propTypeParams


module.exports = PropertyRegistryRenders
###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin           - общие стили для компонентов
* HelpersMixin          - функции-хэлперы для компонентов
* InsiderStore          - flux-хранилище инсайдерских действий
* InsiderActionCreators - модуль создания клиентских инсайдерских действий
* InsiderFluxConstants  - flux-константы инсайдерских части
* StandardFluxParams         - модуль стандартных параметров flux-инфраструктуры.
* ImplementationStore        - модуль-хранилище стандартных реализаций.
* keymirror        - модуль для генерации "зеркального" хэша.
###
StylesMixin = require('components/mixins/styles')
HelpersMixin = require('components/mixins/helpers')
InsiderStore = require('stores/insider_store')
InsiderActionCreators = require('actions/insider_action_creators')
InsiderFluxConstants = require('constants/insider_flux_constants')
# ContentAdminPropertyMap = require('./content_registry_property_map')
StandardFluxParams = require('components/content/implementations/standard_flux_params')
ImplementationStore = require('components/content/implementations/implementation_store')
keyMirror = require('keymirror')

###* Зависимости: компоненты
* Button            - кнопка.
* DataTable         - таблица данных.
* AllocationContent - контент с выделением по переданному выражению.
###
Selector = require('components/core/selector')
Button = require('components/core/button')
DataTable = require('components/core/data_table')
AllocationContent = require('components/core/allocation_content')


###* Зависимости: прикладные компоненты.
* ManualViewer - просмотрщик руководств.
###
ManualViewer = require('components/application/manual_viewer')
#LandLease = require('components/content/report/land_lease')
RightsReaderForTable = require('components/content/mixins/rights_reader_for_table')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

# Типы событий
ActionTypes = InsiderFluxConstants.ActionTypes

###* Компонент: контент администрирования правообладаний.
*
* @props:
*     {Boolean} isManagerUpdated - флаг обновленного менеджера (выбран другой менеджер
*                                  имущества).
*     {Boolean} isModeChanged    - флаг измененного режима работы (режим по релевантности
*                                  или по иерархии).
* @state:
###
ContentRegistryOwnership = React.createClass

   # @const {String} - заголовок
   _CAPTION: 'Реестр правообладаний'

   # @const {Object} - параметры модели.
   _MODEL_PARAMS:
      name: 'ownership'
      caption: 'Имущество'

   # @const {Number} - кол-во записей на странице.
   _PER_PAGE_COUNT: 10

   # @const {String} - заполнитель пустых полей.
   _MISSED_PARAM_TITLE: '-'


   # @const {Object} - хэш с иконками для кнопок отображения служебных дат записи.
   _RECORD_DATE_ICONS:
      updated: 'refresh'
      created: 'file-o'

# @const {Object} - параметры рендера
   _OBJECT_CARD_PARAMS:
      formatRules:
         caption:
            template: "Карточка правообладания [ № {0}]"
            fields: ['id']
            icon: 'list-alt'

   # @const {Object} - параметры упорядочивания полей по секциями в форме
   #                   манипуляции данными.
   _FIELDS_ORDER_BY_SECTIONS:
      root: [
         'property_id'
         'rightholder_id'
         'ownership_type_id'
         'parent_ownership_id'
         'master_ownership_id'
         'balancekeeper_ownership_id'
      ]
      payment_plans: [
         'date_start'
         'date_end'
         'period'
         'kbk_id'
         'total_cost'
         'calculation_procedure_id'
      ]

   # @const {Object} - параметры для внешних связок.
   _EXTERNAL_ENTITIES_PARAMS:
      allowExternalToExternal:
         PaymentPlan: ['Payment']

   # @const {String} - параметры ограничений для полей.
   _FIELD_CONSTRAINTS:
      constraints: [
         {
            name: 'parent_ownership_id'
            identifyingName: 'ownership_id'
         }
         {
            name: 'master_ownership_id'
            identifyingName: 'ownership_id'
         }
         {
            name: 'balancekeeper_ownership_id'
            identifyingName: 'ownership_id'
         }
         {
            nameRegExp: /(?:^f_.*)/gi
            identifyingName: 'factor'
            parents: ["payment_plans", "calculation_procedure"]
         }
      ]

   _CUSTOM_ROW_OPTION_PARAMS:
      download:
         name: 'downloadDoc'
         title: 'Скачать форму договора'
         icon: 'file'
         responseBehavior:
            successInscription: 'Документ сформирован'
            responseObject: 'url'

   _MASS_OPERATIONS:
      isInPanel: true
      panelOpenButtonCaption: this._MASS_OPERATIONS_CAPTION
      operations: [
         {
            delete:
               caption: this._MASS_OPERATION_DELETE

         }
      ]

   mixins: [RightsReaderForTable]

   styles:
      caption:
         color: _COLORS.hierarchy2
         marginTop: 5
      idColumn:
         width: 30
      ownershipIcon:
         fontSize: 30
      ownershipIconCell:
         minWidth: 50
         textAlign: 'center'
      ownershipDataCell:
         width: '100%'
         whiteSpace: 'normal'
         color: _COLORS.dark
      ownershipDateCell:
         color: _COLORS.hierarchy3
         minWidth: 100
      ownershipDateButton:
         color: _COLORS.hierarchy2
      ownershipAccountNumberLabel:
         textAlign: 'center'
         padding: _COMMON_PADDING
         fontSize: 11
         marginBottom: 1
         backgroundColor: _COLORS.highlight2
         color: _COLORS.highlight1
         borderStyle: 'solid'
         borderWidth: 1
         borderColor: _COLORS.hierarchy4
      ownershipParamSecondary:
         color: _COLORS.hierarchy3
         fontSize: 12
         paddingTop: _COMMON_PADDING
      ownershipParamSecondaryValue:
         paddingRight: _COMMON_PADDING * 2
         paddingLeft: _COMMON_PADDING
         textDecoration: 'underline'
      dictionaryIdColumn:
         width: 'auto'
      dictionaryColumn:
         width: 'auto'
         minWidth: 50
         padding: 0
      emailColumn:
         width: 140
      entityDateButtonWrapper:
         paddingBottom: _COMMON_PADDING
      hideColumn:
         display: 'none'

   render: ->
      reflectionRenderParams = @_REFLECTION_RENDER_PARAMS
      objectCardParams = @_OBJECT_CARD_PARAMS
      customRowOptionParams = @_CUSTOM_ROW_OPTION_PARAMS
      downloadOptions = customRowOptionParams.download

      # store: InsiderStore,
      # init: {
      #    sendRequest: InsiderActionCreators.getOwnerships,
      #    responseType: ActionTypes.Ownership.OWNERSHIPS_RESPONSE,
      #    getResponse: InsiderStore.getOwnerships
      # },
      # create: {
      #    sendInitRequest: InsiderActionCreators.getOwnershipFields,
      #    responseTypeInit: ActionTypes.Ownership.OWNERSHIP_NEW_RESPONSE,
      #    getResponseInit: InsiderStore.getOwnershipFields,
      #    sendRequest: InsiderActionCreators.createOwnership,
      #    getResponse: InsiderStore.getOwnershipCreationResult,

      #    responseType: ActionTypes.Ownership.OWNERSHIP_CREATE_RESPONSE
      # },
      # update: {
      #    sendInitRequest:InsiderActionCreators.getOwnership,
      #    responseTypeInit: ActionTypes.Ownership.OWNERSHIP_GET_RESPONSE,
      #    getResponseInit: InsiderStore.getOwnershipData,
      #    sendRequest: InsiderActionCreators.editOwnership,
      #    getResponse: InsiderStore.getOwnershipEditResult,
      #    responseType: ActionTypes.Ownership.OWNERSHIP_EDIT_RESPONSE
      # },
      # delete: {
      #    sendRequest: InsiderActionCreators.deleteOwnership,
      #    getResponse: InsiderStore.getOwnershipDeleteResult,
      #    responseType: ActionTypes.Ownership.OWNERSHIP_DELETE_RESPONSE
      # }

            # <h3 style={this.styles.caption}>{this._CAPTION}</h3>
      #<LandLease />
      `(
         <DataTable recordsPerPage={this._PER_PAGE_COUNT}
                    modelParams={ this._MODEL_PARAMS }
                    isFitToContainer={true}
                    enableRowSelect={true}
                    enableRowOptions={true}
                    enableObjectCard={true}
                    enableColumnsHeader={false}
                    enableUserFilters={true}
                    enableSettings={true}
                    isRereadData={this.props.isManagerUpdated || this.props.isModeChanged}
                    isHasStripFarming={false}
                    isUseImplementation={true}
                    isMergeImplementation={true}
                    isSuppressLargeTotalRecordsOutput={true}
                    implementationStore={ImplementationStore}
                    ManualViewer={ManualViewer}
                    enableManuals={true}
                    fluxParams={
                        {
                           isUseServiceInfrastructure: true,
                           userFilters: StandardFluxParams.USER_FILTERS
                        }
                     }
                    dataManipulationParams={
                        {
                           enableClientConstruct: true,
                           enableReflectionManuals: true,
                           fieldsOrder: this._FIELDS_ORDER_BY_SECTIONS,
                           externalEntitiesParams: this._EXTERNAL_ENTITIES_PARAMS,
                           fieldConstraints: this._FIELD_CONSTRAINTS
                        }
                    }
                    customRowOptions={
                        [
                           {  name: downloadOptions.name,
                              title: downloadOptions.title,
                              icon: downloadOptions.icon,
                              responseBehavior: downloadOptions.responseBehavior,
                              fluxParams: {
                                 store: InsiderStore,
                                 sendRequest: InsiderActionCreators.getRentContract,
                                 getResponse: InsiderStore.getOwnershipDowloadResult,
                                 responseType: ActionTypes.Ownership.OWNERSHIP_DOWNLOAD_DOCUMENT_RESPONSE
                              }
                           }
                        ]
                    }
                    massOperations={this._MASS_OPERATIONS}
                    {...this._getDataTableRightProps()}
               />
      )`

   ###*
   * Функция рендера ячейки отображения имущества.
   *
   * @param {Object} record - запись.
   * @return {Object} - содержимое ячейки для отображения имущества.
   ###
   # _onRenderOwnershipCell: (record) ->
   #    fields = record.fields
   #    recordDateIcons = @_RECORD_DATE_ICONS
   #    missedTitle = @_MISSED_PARAM_TITLE
   #    accountNumber = fields.id

   #    createdDateParam = fields.created_at
   #    updatedDateParam = fields.updated_at

   #    createdDate = new Date(createdDateParam.value).toLocaleString()
   #    updatedDate = new Date(updatedDateParam.value).toLocaleString()

   #    `(
   #       <table>
   #          <tbody>
   #             <tr>
   #                <td style={this.styles.ownershipDataCell}>
   #                   {fields.name.value}
   #                </td>
   #             </tr>
   #          </tbody>
   #       </table>
   #    )`





module.exports = ContentRegistryOwnership

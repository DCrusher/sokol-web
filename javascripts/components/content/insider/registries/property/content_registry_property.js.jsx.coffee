###* @jsx React.DOM ###

###* Зависимости: модули.
* StylesMixin                - общие стили для компонентов.
* HelpersMixin               - функции-хэлперы для компонентов.
* InsiderStore            - flux-хранилище инсайдерских действий.
* InsiderActionCreators   - модуль создания клиентских инсайдерских действий.
* InsiderFluxConstants    - flux-константы инсайдерских части.
* StandardFluxParams         - модуль стандартных параметров flux-инфраструктуры.
* ImplementationStore        - модуль-хранилище стандартных реализаций.
###
StylesMixin = require('components/mixins/styles')
HelpersMixin = require('components/mixins/helpers')
InsiderStore = require('stores/insider_store')
InsiderActionCreators = require('actions/insider_action_creators')
InsiderFluxConstants = require('constants/insider_flux_constants')
StandardFluxParams = require('components/content/implementations/standard_flux_params')
ImplementationStore = require('components/content/implementations/implementation_store')

###* Зависимости: компоненты.
* Button            - кнопка.
* DataTable         - таблица данных.
* AllocationContent - контент с выделением по переданному выражению.
###
Button = require('components/core/button')
DataTable = require('components/core/data_table')
AllocationContent = require('components/core/allocation_content')

###* Зависимости: прикладные компоненты.
* ManualViewer - просмотрщик руководств.
###
ManualViewer = require('components/application/manual_viewer')

RightsReaderForTable = require('components/content/mixins/rights_reader_for_table')

###* Константы.
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

###* Компонент: реестр имущества.
*
* @props:
*     {Boolean} isManagerUpdated - флаг обновленного менеджера (выбран другой менеджер
*                                  имущества).
*     {Boolean} isModeChanged    - флаг измененного режима работы (режим по релевантности
*                                  или по иерархии).
* @state:
###
ContentRegistryProperty = React.createClass
   # @const {String} - заголовок
   _CAPTION: 'Реестр имущества'

   # @const {Object} - параметры модели.
   _MODEL_PARAMS:
      name: 'property'
      caption: 'Имущество'

   # @const {Number} - кол-во записей на странице.
   _PER_PAGE_COUNT: 10

   _FIELD_CONSTRAINTS:
      prefixAnchors:
         real:
            property_types: [1, 2]
         realty:
            property_types: 2
         move:
            property_types: 3
      constraints: [
         {
            name: 'id'
            identifyingName: 'property_types'
            parents: ['property', 'property_types']
         }
         {
            name: 'property_relation_id'
            identifyingName: 'property_id'
            parents: ["property_relations"]
         }
         {
            name: 'property_complex_id'
            identifyingName: 'property_id'
            parents: ["property_complexes"]
         }
         {
            name: 'parent_ownership_id'
            identifyingName: 'ownership_id'
            parents: ["ownerships"]
         }
         {
            name: 'master_ownership_id'
            identifyingName: 'ownership_id'
            parents: ["ownerships"]
         }
         {
            name: 'balancekeeper_ownership_id'
            identifyingName: 'ownership_id'
            parents: ["ownerships"]
         }
         {
            nameRegExp: /(?:^f_.*)/gi
            identifyingName: 'factor'
            parents: ["ownerships", "payment_plans", "calculation_procedure"]
         },
         {
            nameRegExp: /(?:^f_.*)/gi
            identifyingName: 'factor'
            parents: ["payment_plans", "calculation_procedure"]
         }
      ]

   _MASS_OPERATIONS:
      isInPanel: true
      panelOpenButtonCaption: this._MASS_OPERATIONS_CAPTION
      operations: [
         {
            name: 'massDelete'
            icon: 'trash'
            caption: 'Удалить выбранные'
            isUnsetMarkedOnCallback: true
            confirmText: 'Удалить выбранные объекты имущества?'
            responseText: 'Выбранные объекты имущества удалены'
            fluxParams:
               store: InsiderStore
               sendRequest: InsiderActionCreators.deleteProperties
               getResponse: InsiderStore.getPropertiesDeleteResult
               responseType: InsiderFluxConstants.ActionTypes.Property.PROPERTY_GROUP_DELETE_RESPONSE
         }
         {
            name: 'treasuryChange'
            caption: 'Передать в другую казну'
            title: 'Выполнить перемещение выбранного имущества в другую казну'
            icon: 'external-link'
            isUnsetMarkedOnCallback: true
            responseBehavior:
               successInscription: ['Операция перемещения в другую казну выполнена. \n'
                  'Данные в реестре будут актуализированы в течении нескольких минут.'].join('')
               responseObject: 'change_treasuruies_for'
            contentParams:
               clarificationParams:
                  template: 'Передача выбранного имущества в другую казну'
               fields: null
               dynamicParams:
                  reflectionToMain: null
                  isUseImplementation: true
                  additionFormParams:
                     mode: 'create'
                     actionButtonParams:
                        submit:
                           caption: 'Передать'
                           title: 'Отправить запрос на передачу выбранного имущества в казну правообладателя'
                           isComplete: true
                  customServiceFluxParams:
                     endpoint: 'group_treasury_change'
                     method: 'post'
                  reflectionsChain: [ 'Treasury' ]
                  constraints: null
                  onClearField: null
                  onChangeField: null
                  onInitField: null
                  onDestroyField: null
                  eagerlyLoadedReflections: null
            fluxParams: null
         }
      ]

   mixins: [RightsReaderForTable]

   styles:
      caption:
         color: _COLORS.hierarchy2
         marginTop: 5
      idColumn:
         width: 30
      dictionaryIdColumn:
         width: 'auto'
      dictionaryNameColumn:
         width: 'auto'
         minWidth: 100
         padding: 0
      emailColumn:
         width: 140
      hideColumn:
         display: 'none'
      contentName:
         padding: _COMMON_PADDING

   render: ->

      `(
         <DataTable recordsPerPage={this._PER_PAGE_COUNT}
                    modelParams={this._MODEL_PARAMS}
                    enableUserFilters={true}
                    enableSettings={true}
                    enableRowSelect={true}
                    enableRowOptions={true}
                    enableColumnsHeader={false}
                    isHasStripFarming={false}
                    isFitToContainer={true}
                    isUseImplementation={true}
                    isMergeImplementation={true}
                    isSuppressLargeTotalRecordsOutput={true}
                    isRereadData={this.props.isManagerUpdated || this.props.isModeChanged}
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
                          enableReflectionManuals: true,
                          fieldConstraints: this._FIELD_CONSTRAINTS,
                          enableClientConstruct: true,
                          sectionsOrder: {
                             root: ['PropertyType','main', 'PropertyCost', 'PropertyFeature'],
                             property_birth: ['main', 'PropertyHistory'],
                             ownerships: ['main', 'PaymentPlan', 'OwnershipStatus']
                          },
                          fieldsOrder: {
                             payment_plans: [
                                'date_start',
                                'date_end',
                                'period',
                                'kbk_id',
                                'auction',
                                'total_cost',
                                'calculation_procedure_id'
                             ],
                             property_costs: [
                                'cost_type',
                                'value',
                                'date_start',
                                'date_end'
                             ]
                          },
                          hierarchyBreakParams: {
                             oktmo: 'legal_entities',
                             addresses: 'addresser',
                             ownerships: 'rightholder',
                             property_types: 'property_parameters'
                          },
                          externalEntitiesParams: {
                             allowExternalToExternal: {
                                PropertyMilestone: 'PropertyAncestor',
                                Ownership: [
                                   'OwnershipStatus',
                                   'PaymentPlan',
                                   'OwnershipAdditionProperty',
                                   'OwnershipAdditionRightholder'
                                ],
                                Treasury: 'PropertyMilestone'
                             }
                          },
                          reflectionParams: {
                             PropertyType: {
                                reflectionName: 'property_types',
                                type: 'dictionary',
                                dictionaryParams: {
                                   enableMultipleSelect: true,
                                   enableConsistentClear: true,
                                   additionFilterParams: {
                                      isAddingSelectedItems: true,
                                      isAddingSelectedItemsOnlyRoot: true
                                   },
                                   dataTableParams: {
                                      hierarchyViewParams: {
                                         enableSelectRootOnActivateChild: true
                                      }
                                   }
                                }
                             },
                             AddressChain: {
                                reflectionName: 'address_chain_id',
                                dictionaryParams: {
                                   enableMultipleSelect: true,
                                   enableConsistentClear: true,
                                   additionFilterParams: {
                                      isAddingSelectedItems: true
                                   }
                                },
                                eagerlyLoadedReflections: {
                                   address_landpoint: {
                                      isReadOnlyRecords: true
                                   }
                                }
                             }
                          },
                          edit: {
                             eagerlyLoadedReflections: {
                                property_types: {
                                   isReadOnlyRecords: true
                                }
                             },
                             denyToEditReflections: {
                                property_types: {
                                   chain: undefined,
                                   isAnywhere: false
                                }
                             }
                          },
                          create: {
                             denyReflections: {
                                property_changes: {
                                   isAnywhere: true
                                }
                             }
                          }
                       }
                    }
                    massOperations={this._MASS_OPERATIONS}
                    {...this._getDataTableRightProps()}
                 />
      )`

module.exports = ContentRegistryProperty

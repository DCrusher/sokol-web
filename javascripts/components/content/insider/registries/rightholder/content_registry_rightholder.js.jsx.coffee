###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin                - общие стили для компонентов.
* HelpersMixin               - функции-хэлперы для компонентов.
* InsiderStore               - flux-хранилище инсайдерских действий.
* InsiderActionCreators      - модуль создания клиентских инсайдерских действий.
* InsiderFluxConstants       - flux-константы инсайдерских части.
* RightholderRegistryRenders - модуль произвольных рендеров ячеек таблицы данных
*                              для реестра правообладателей.
* PropertyRegistryRenders    - модуль произвольных рендеров ячеек таблицы данных
*                              для реестра имущества.
* SelectorRenderParams       - модуль стандартных параметров рендера полей-селекторов.
* StandardFluxParams         - модуль стандартных параметров flux-инфраструктуры.
* ImplementationStore        - модуль-хранилище стандартных реализаций.
###
StylesMixin = require('components/mixins/styles')
HelpersMixin = require('components/mixins/helpers')
InsiderStore = require('stores/insider_store')
InsiderActionCreators = require('actions/insider_action_creators')
InsiderFluxConstants = require('constants/insider_flux_constants')
RightholderRegistryRenders = require('components/content/implementations/rightholder_registry_renders')
PropertyRegistryRenders = require('components/content/implementations/property_registry_renders')
StandardFluxParams = require('components/content/implementations/standard_flux_params')
ImplementationStore = require('components/content/implementations/implementation_store')

###* Зависимости: компоненты
* DataTable         - таблица данных.
* AllocationContent - контент с выделением по переданному выражению.
###
DataTable = require('components/core/data_table')
AllocationContent = require('components/core/allocation_content')

###* Зависимости: прикладные компоненты.
* ManualViewer - просмотрщик руководств.
###
ManualViewer = require('components/application/manual_viewer')

RightsReaderForTable = require('components/content/mixins/rights_reader_for_table')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

# Типы событий
ActionTypes = InsiderFluxConstants.ActionTypes

###* Компонент: реестр правообладателей.
*
* @props:
* @state:
###
ContentRegistryRightholder = React.createClass
   _CAPTION: 'Реестр правообладателей'
   _BTN_ADD_CAPTION: 'Новый правообладатель'
   _ADD_USER_TITLE: 'Новый правообладатель'
   _EDIT_USER_TITLE: 'Редактирование правообладателя'

   # @const {Object} - параметры модели.
   _MODEL_PARAMS:
      name: 'rightholder'
      caption: 'Правообладатели'

   # @const {Number} - кол-во записей на странице.
   _PER_PAGE_COUNT: 10

   # @const {String} - параметры ограничений для полей.
   _FIELD_CONSTRAINTS:
      constraints: [
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
         }
      ]

   _MASS_OPERATIONS:
      isInPanel: true,
      panelOpenButtonCaption: this._MASS_OPERATIONS_CAPTION
      operations: [
         {
            name: 'massDelete'
            icon: 'trash'
            caption: 'Удалить выбранные'
            isUnsetMarkedOnCallback: true
            confirmText: 'Удалить выбранных правообладателей?'
            responseText: 'Выбранные правообладатели удалены'
            fluxParams:
               store: InsiderStore
               sendRequest: InsiderActionCreators.deleteRightholders
               getResponse: InsiderStore.getRightholdersDeleteResult
               responseType: InsiderFluxConstants.ActionTypes.Rightholder.RIGHTHOLDER_GROUP_DELETE_RESPONSE

         }
      ]

   mixins: [
      RightholderRegistryRenders
      PropertyRegistryRenders
      RightsReaderForTable
   ]

   _REFLECTION_RENDER_PARAMS:
      parentId:
         dictionary:
            dimension:
               dataContainer:
                  width:
                     max: 900
                     min: 200
                  height:
                     max: 200
         instance:
            template: "({0}) {1}"
            fields: ['id', 'short_name']
            dimension:
               width:
                  max: 200

   styles:
      caption:
         color: _COLORS.hierarchy2
         marginTop: 5
      idColumn:
         width: 30
      emailColumn:
         width: 140
      hideColumn:
         display: 'none'
      dictionaryIdColumn:
         width: 'auto'
      dictionaryNameColumn:
         width: 'auto'
         minWidth: 100
         padding: 0
      oktmoDictionarySectionColumn:
         width: 100

   render: ->
      # massOperationParams = @_MASS_OPERATIONS_PARAMS
      # customRowOptionParams = @_CUSTOM_ROW_OPTION_PARAMS
      # objectCardParams = @_OBJECT_CARD_PARAMS
      # massOperations = massOperationParams.operations
      # changePasswordOption = customRowOptionParams.changePassword
      # blockOption = customRowOptionParams.block
      # appointmentWorkplaces = objectCardParams.customActions.appointmentWorkplaces

      reflectionRenderParams = @_REFLECTION_RENDER_PARAMS
      objectCardParams = @_OBJECT_CARD_PARAMS

      `(
          <DataTable recordsPerPage={this._PER_PAGE_COUNT}
                     modelParams={this._MODEL_PARAMS}
                     isFitToContainer={true}
                     isUseImplementation={true}
                     isMergeImplementation={true}
                     isHasStripFarming={false}
                     isSuppressLargeTotalRecordsOutput={true}
                     enableUserFilters={true}
                     enableRowSelect={true}
                     enableRowOptions={true}
                     enableColumnsHeader={false}
                     enableSettings={true}
                     enableDataExport={true}
                     implementationStore={ImplementationStore}
                     ManualViewer={ManualViewer}
                     enableManuals={true}
                     reflectionRenderParams={
                        {
                           parent_id: {
                              instance: reflectionRenderParams.parentId.instance,
                              dictionary: {
                                 dimension: reflectionRenderParams.parentId.dictionary.dimension,
                                 columnRenderParams: {
                                    isStrongRenderRule: true,
                                    columns:
                                       {
                                          id: {
                                             style: this.styles.parentIdDictionaryIdColumn
                                          },
                                          full_name: {
                                             style: null
                                          },
                                          inn: null
                                       }
                                 }
                              }
                           }
                        }
                     }
                     dataManipulationParams={
                        {
                            enableReflectionManuals: true,
                            enableClientConstruct: true,
                            fieldsOrder: {
                              root: ['entity_type', 'old_registry_number'],
                              entity: [
                                 'full_name',
                                 'short_name',
                                 'legal_entity_type_id',
                                 'parent_id',
                                 'manager',
                                 'autonomy',
                                 'registration_date',
                                 'oktmo_id'
                              ],
                              legal_entity_employees: ['legal_entity_post_id'],
                              payment_plans: [
                                 'date_start',
                                 'date_end',
                                 'period',
                                 'kbk_id',
                                 'total_cost',
                                 'calculation_procedure_id'
                              ],
                              rightholder_ratings: [
                                 'rating_type',
                                 'group',
                                 'rating',
                                 'course',
                                 'date',
                                 'description'
                              ]
                            },
                            sectionsOrder: {
                              root: ['main', 'User', 'Contact', 'BillingDetail'],
                              entity: ['main', 'LegalEntityEmployee']
                            },
                            externalEntitiesParams: {
                               allowExternalToExternal: {
                                  Ownership: [
                                     'OwnershipStatus',
                                     'PaymentPlan',
                                     'OwnershipAdditionProperty',
                                     'OwnershipAdditionRightholder'
                                  ],
                                  RightholderRating: ['RightholderRatingElement']
                               }
                            },
                            hierarchyBreakParams: {
                              oktmo: 'properties',
                              users: 'user_duties',
                              documents: ['document_type', 'document_file'],
                              legal_entity_employees: 'legal_entity_post',
                              ownerships: 'property'
                            },
                            reflectionParams: {
                               User: {
                                  reflectionName: 'users',
                                  type: 'combine',
                                  dictionaryParams: {
                                     enableMultipleSelect: true
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
                                  }
                               }
                            },
                            additionalValidationParams: {
                              allowedPresenceForExternal: {
                                 entity: null
                              }
                            },
                            fieldConstraints: this._FIELD_CONSTRAINTS,
                            edit: {
                              denyToEditReflections: {

                              },
                              fieldConstraints: {
                                 constraints: [
                                   {
                                      name: 'entity_type',
                                      isReadOnly: true
                                   }
                                 ]
                              }
                           }
                        }
                     }
                     fluxParams={
                         {
                            isUseServiceInfrastructure: true,
                            userFilters: StandardFluxParams.USER_FILTERS
                         }
                     }
                     massOperations={this._MASS_OPERATIONS}
                     {...this._getDataTableRightProps()}
                   />
       )`


module.exports = ContentRegistryRightholder
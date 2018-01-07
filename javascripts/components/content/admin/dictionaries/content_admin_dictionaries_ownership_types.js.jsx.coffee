###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin         - общие стили для компонентов
* HelpersMixin        - функции-хэлперы для компонентов
* AdminStore          - flux-хранилище административных действий
* AdminActionCreators - модуль создания клиентских административных действий
* AdminFluxConstants  - flux-константы административной части
###
StylesMixin = require('components/mixins/styles')
HelpersMixin = require('components/mixins/helpers')
AdminStore = require('stores/admin_store')
AdminActionCreators = require('actions/admin_action_creators')
AdminFluxConstants = require('constants/admin_flux_constants')

###* Зависимости: компоненты
* Button    - кнопка
* DataTable - таблица данных
###
Button = require('components/core/button')
DataTable = require('components/core/data_table')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

# Типы событий
ActionTypes = AdminFluxConstants.ActionTypes

###* Компонент: контент администрирования справочника тип правоотношений
*
* @props:
* @state:
###
ContentAdminDictionariesOwnershipTypes = React.createClass
   _CAPTION: 'Управление справочником типов правоотношений'
   _BTN_ADD_CAPTION: 'Новый тип правоотношений'
   _ADD_WORKPLACE_TITLE: 'Новый тип правоотношений'
   _EDIT_WORKPLACE_TITLE: 'Редактирование типа правоотношений'
   _MASS_OPERATION_DELETE: 'Удалить тип правоотношений'
   _MASS_OPERATIONS_CAPTION: 'Операции над типами правоотношений'

   # @const {String} - наименование модели, по которой строится таблица данных.
   _MODEL_NAME: 'ownership_type'

   # @const {Object} - параметры рендера значений в полях выборки (Selector).
   _REFLECTION_RENDER_PARAMS:
      parentId:
         dictionary:
            viewType: 'hierarchy'
            dimension:
               dataContainer:
                  width:
                     max: 500
                     min: 200
                  height:
                     max: 200
         instance:
            dimension:
               width:
                  max: 200

   # @const {Object} - параметры иерархического представления таблицы.
   _HIERARCHY_VIEW_PARAMS:
      viewType: 'tree'
      viewParams:
         titleDataParams:
            template: "{0}"
            fields: ['description']

   styles:
      caption:
         color: _COLORS.hierarchy2
         marginTop: 5
      idColumn:
         width: 30
      hideColumn:
         display: 'none'
      parentIdDictionaryIdColumn:
         whiteSpace: 'nowrap'
         width: 'auto'
      # idColumn:
      #    width: 30

                             #    mainDataParams: {
                             #    template: "{0}",
                             #    fields: ['name']
                             # },

   render: ->
      reflectionRenderParams = @_REFLECTION_RENDER_PARAMS
      hierarchyViewParams = @_HIERARCHY_VIEW_PARAMS

            # <h3 style={this.styles.caption}>
            #    {this._CAPTION}
            # </h3>
      `(
         <div>

            <DataTable modelParams={ { name: this._MODEL_NAME} }
                       enableColumnsHeader={true}
                       isFitToContainer={true}
                       hierarchyViewParams={
                          {
                             enableViewChildsCounter: true,
                             enableViewKey: true,
                             enableViewServiceDate: true,
                             enableSelectParents: true,
                             titleDataParams: hierarchyViewParams.viewParams.titleDataParams
                          }
                       }
                       reflectionRenderParams={
                           {
                              parent_id: {
                                 instance: reflectionRenderParams.parentId.instance,
                                 dictionary: {
                                    viewType: reflectionRenderParams.parentId.dictionary.viewType,
                                    dimension: reflectionRenderParams.parentId.dictionary.dimension,
                                    columnRenderParams: {
                                       isStrongRenderRule: true,
                                       columns:
                                          {
                                             id: {
                                                style: this.styles.parentIdDictionaryIdColumn
                                             },
                                             name: {
                                                style: null
                                             }
                                          }
                                    }
                                 }
                              }
                           }
                       }
                       columnRenderParams={
                           {
                              isStrongRenderRule: false,
                              columns:
                                 {
                                    id: {
                                       style: this.styles.idColumn
                                    },
                                    parent_id: {
                                       style: this.styles.idColumn
                                    }
                                 }
                           }
                        }
                        fluxParams={
                          {
                              store: AdminStore,
                              init: {
                                 sendRequest: AdminActionCreators.getOwnershipTypes,
                                 responseType: ActionTypes.OwnershipType.OWNERSHIP_TYPES_RESPONSE,
                                 getResponse: AdminStore.getOwnershipTypes
                              },
                              create: {
                                 sendInitRequest: AdminActionCreators.getOwnershipTypeFields,
                                 responseInitType: ActionTypes.OwnershipType.OWNERSHIP_TYPE_NEW_RESPONSE,
                                 getInitResponse: AdminStore.getOwnershipType,
                                 sendRequest: AdminActionCreators.createOwnershipType,
                                 getResponse: AdminStore.getOwnershipTypeCreationResult,
                                 responseType: ActionTypes.OwnershipType.OWNERSHIP_TYPE_CREATE_RESPONSE
                              },
                              update: {
                                 sendInitRequest:AdminActionCreators.getOwnershipType,
                                 responseInitType: ActionTypes.OwnershipType.OWNERSHIP_TYPE_GET_RESPONSE,
                                 getInitResponse: AdminStore.getOwnershipType,
                                 sendRequest: AdminActionCreators.editOwnershipType,
                                 getResponse: AdminStore.getOwnershipTypeEditResult,
                                 responseType: ActionTypes.OwnershipType.OWNERSHIP_TYPE_EDIT_RESPONSE
                              },
                              delete: {
                                 sendRequest: AdminActionCreators.deleteOwnershipType,
                                 getResponse: AdminStore.getOwnershipTypeDeleteResult,
                                 responseType: ActionTypes.OwnershipType.OWNERSHIP_TYPE_DELETE_RESPONSE
                              }
                          }
                       }
                       massOperations={
                           {
                              isInPanel: true,
                              panelOpenButtonCaption: this._MASS_OPERATIONS_CAPTION,
                              operations: [
                                 {
                                    delete: {
                                       caption: this._MASS_OPERATION_DELETE
                                    }
                                 }
                              ]
                           }
                       }
                       enableRowSelect={true}
                       enableRowOptions={true}
                       customRowOptions={[]}
                       enableObjectCard={true}
                       objectCardCustomActions={
                           [
                              {
                                 name: 'appointmentWorkplaces',
                                 caption: this._APPOINTMENT_ACTIONS_CAPTION,
                                 icon: 'briefcase'
                              }
                           ]
                        }
            />
         </div>
      )`


module.exports = ContentAdminDictionariesOwnershipTypes

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

###* Компонент: контент администрирования справочника параметры имущества
*
* @props:
* @state:
###
ContentAdminDictionariesPropertyParameters = React.createClass
   _CAPTION: 'Управление справочником параметров имущества'
   _BTN_ADD_CAPTION: 'Новый параметр имущества'
   _ADD_WORKPLACE_TITLE: 'Новый параметр имущества'
   _EDIT_WORKPLACE_TITLE: 'Редактирование параметра имущества'
   _MASS_OPERATION_DELETE: 'Удалить параметр имущества'
   _MASS_OPERATIONS_CAPTION: 'Операции над параметрами имущества'

   # @const {String} - наименование модели, по которой строится таблица данных.
   _MODEL_NAME: 'property_parameter'

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
      propertyType:
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
                       viewType={hierarchyViewParams.viewType}
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
                              },
                              property_type_id: {
                                 instance: reflectionRenderParams.propertyType.instance,
                                 dictionary: {
                                    viewType: reflectionRenderParams.propertyType.dictionary.viewType,
                                    dimension: reflectionRenderParams.propertyType.dictionary.dimension
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
                                 sendRequest: AdminActionCreators.getPropertyParameters,
                                 responseType: ActionTypes.PropertyParameter.PROPERTY_PARAMETERS_RESPONSE,
                                 getResponse: AdminStore.getPropertyParameters
                              },
                              create: {
                                 sendInitRequest: AdminActionCreators.getPropertyParameterFields,
                                 responseInitType: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_NEW_RESPONSE,
                                 getInitResponse: AdminStore.getPropertyParameter,
                                 sendRequest: AdminActionCreators.createPropertyParameter,
                                 getResponse: AdminStore.getPropertyParameterCreationResult,
                                 responseType: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_CREATE_RESPONSE
                              },
                              update: {
                                 sendInitRequest:AdminActionCreators.getPropertyParameter,
                                 responseInitType: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_GET_RESPONSE,
                                 getInitResponse: AdminStore.getPropertyParameter,
                                 sendRequest: AdminActionCreators.editPropertyParameter,
                                 getResponse: AdminStore.getPropertyParameterEditResult,
                                 responseType: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_EDIT_RESPONSE
                              },
                              delete: {
                                 sendRequest: AdminActionCreators.deletePropertyParameter,
                                 getResponse: AdminStore.getPropertyParameterDeleteResult,
                                 responseType: ActionTypes.PropertyParameter.PROPERTY_PARAMETER_DELETE_RESPONSE
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


module.exports = ContentAdminDictionariesPropertyParameters

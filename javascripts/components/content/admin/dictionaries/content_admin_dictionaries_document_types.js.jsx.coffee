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

###* Компонент: контент администрирования справочника тип документов
*
* @props:
* @state:
###
ContentAdminDictionariesDocumentTypes = React.createClass
   _CAPTION: 'Управление справочником типов документов'
   _BTN_ADD_CAPTION: 'Новый тип документа'
   _ADD_WORKPLACE_TITLE: 'Новый тип документа'
   _EDIT_WORKPLACE_TITLE: 'Редактирование типа документа'
   _MASS_OPERATION_DELETE: 'Удалить тип документа'
   _MASS_OPERATIONS_CAPTION: 'Операции над типами документов'

   # @const {String} - наименование модели, по которой строится таблица данных.
   _MODEL_NAME: 'document_type'

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
      dataTimeColumn:
         width: 100
      nameColumn:
         width: 350
      categoryColumn:
         width: 250
      hideColumn:
         display: 'none'
      parentIdDictionaryIdColumn:
         whiteSpace: 'nowrap'
         width: 'auto'
      idColumn:
         width: 30

   render: ->
      reflectionRenderParams = @_REFLECTION_RENDER_PARAMS
      hierarchyViewParams = @_HIERARCHY_VIEW_PARAMS

            # <h3 style={this.styles.caption}>
            #    {this._CAPTION}
            # </h3>
      `(
         <div>

            <DataTable modelParams={ { name: this._MODEL_NAME } }
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
                                    created_at: {
                                       style: this.styles.dataTimeColumn
                                    },
                                    updated_at: {
                                       style: this.styles.dataTimeColumn
                                    },
                                    name: {
                                       style: this.styles.nameColumn
                                    },
                                    document_category: {
                                       style: this.styles.categoryColumn
                                    },
                                 }
                           }
                        }
                        fluxParams={
                          {
                              store: AdminStore,
                              init: {
                                 sendRequest: AdminActionCreators.getDocumentTypes,
                                 responseType: ActionTypes.DocumentType.DOCUMENT_TYPES_RESPONSE,
                                 getResponse: AdminStore.getDocumentTypes
                              },
                              create: {
                                 sendInitRequest: AdminActionCreators.getDocumentTypeFields,
                                 responseInitType: ActionTypes.DocumentType.DOCUMENT_TYPE_NEW_RESPONSE,
                                 getInitResponse: AdminStore.getDocumentType,
                                 sendRequest: AdminActionCreators.createDocumentType,
                                 getResponse: AdminStore.getDocumentTypeCreationResult,
                                 responseType: ActionTypes.DocumentType.DOCUMENT_TYPE_CREATE_RESPONSE
                              },
                              update: {
                                 sendInitRequest:AdminActionCreators.getDocumentType,
                                 responseInitType: ActionTypes.DocumentType.DOCUMENT_TYPE_GET_RESPONSE,
                                 getInitResponse: AdminStore.getDocumentType,
                                 sendRequest: AdminActionCreators.editDocumentType,
                                 getResponse: AdminStore.getDocumentTypeEditResult,
                                 responseType: ActionTypes.DocumentType.DOCUMENT_TYPE_EDIT_RESPONSE
                              },
                              delete: {
                                 sendRequest: AdminActionCreators.deleteDocumentType,
                                 getResponse: AdminStore.getDocumentTypeDeleteResult,
                                 responseType: ActionTypes.DocumentType.DOCUMENT_TYPE_DELETE_RESPONSE
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


module.exports = ContentAdminDictionariesDocumentTypes

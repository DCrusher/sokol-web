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

###* Компонент: контент администрирования пользователей (добавление, редактирование, удаление)
*
* @props:
* @state:
###
ContentAdminActionMain = React.createClass
   _CAPTION: 'Администрирование пользовательских действий'
   _BTN_ADD_CAPTION: 'Новое пользовательское действие'
   _ADD_USER_TITLE: 'Новое пользовательское действие'
   _EDIT_USER_TITLE: 'Редактирование действия'

   _MODEL_NAME: 'user_action'
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
         width: '5%'
      hideColumn:
         display: 'none'
      parentIdDictionaryIdColumn:
         whiteSpace: 'nowrap'
         width: 'auto'
      parentIdDictionaryNameColumn:
         whiteSpace: 'nowrap'
         width: 'auto'
         minWidth: 100
         padding: 0

   render: ->
      reflectionRenderParams = @_REFLECTION_RENDER_PARAMS
      hierarchyViewParams = @_HIERARCHY_VIEW_PARAMS

      `(
         <DataTable modelParams={ {name: this._MODEL_NAME} }
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
                           }
                        }
                    }
                    fluxParams={
                       {
                           store: AdminStore,
                           init: {
                              sendRequest: AdminActionCreators.getActions,
                              responseType: ActionTypes.Action.ACTIONS_RESPONSE,
                              getResponse: AdminStore.getActions
                           },
                           create: {
                              sendInitRequest: AdminActionCreators.getActionFields,
                              responseInitType: ActionTypes.Action.ACTIONS_NEW_RESPONSE,
                              getInitResponse: AdminStore.getAction,
                              sendRequest: AdminActionCreators.createAction,
                              getResponse: AdminStore.getActionCreationResult,
                              responseType: ActionTypes.Action.ACTIONS_CREATE_RESPONSE
                           },
                           update: {
                              sendInitRequest:AdminActionCreators.getAction,
                              responseInitType: ActionTypes.Action.ACTIONS_GET_RESPONSE,
                              getInitResponse: AdminStore.getAction,
                              sendRequest: AdminActionCreators.editAction,
                              getResponse: AdminStore.getActionEditResult,
                              responseType: ActionTypes.Action.ACTIONS_EDIT_RESPONSE
                           },
                           delete: {
                              sendRequest: AdminActionCreators.deleteAction,
                              getResponse: AdminStore.getActionDeleteResult,
                              responseType: ActionTypes.Action.ACTIONS_DELETE_RESPONSE
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
                    columnRenderParams={
                        {
                           id: {
                              style: this.styles.idColumn
                           }
                        }
                    }
                    enableRowSelect={true}
                    enableRowOptions={true}
                    customRowOptions={[]}
                    enableObjectCard={false}
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
      )`





module.exports = ContentAdminActionMain
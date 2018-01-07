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
* AllocationContent - контент с выделением по переданному выражению.
###
Button = require('components/core/button')
DataTable = require('components/core/data_table')
AllocationContent = require('components/core/allocation_content')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

# Типы событий
ActionTypes = AdminFluxConstants.ActionTypes

###* Компонент: контент администрирования АРМов (добавление, редактирование)
*
* @props:
* @state:
*     {Array} allWorkplaces  - массив всех АРМов
*     {Object} touchedRecord - данные по последней записи с которой было взаимодействие
*     {String} adminAction   - тип админского действия. Возможные значения:
*                              ''     - действие отсутствует
*                              'add'  - добавление нового АРМа
*                              'edit' - редактирование АРМа
###
ContentAdminUserWorkplacesMain = React.createClass
   _CAPTION: 'Управление АРМами'
   _MODEL_NAME: 'user_workplace'
   _BTN_ADD_CAPTION: 'Новый АРМ'
   _ADD_WORKPLACE_TITLE: 'Новый АРМ'
   _EDIT_WORKPLACE_TITLE: 'Редактирование АРМа'
   _MASS_OPERATIONS_CAPTION: 'Операции над АРМами'
   # @const - параметры для карточки объекта.
   _OBJECT_CARD_PARAMS:
      formatRules:
         caption:
            template: "{0}"
            fields: ['name']
            icon: 'briefcase'
      customActions:
         appointmentActions:
            name: 'appointmentActions'
            caption: 'Назначение действий'
            icon: 'briefcase'
            keyProp: 'actionID'

   styles:
      caption:
         color: _COLORS.hierarchy2
         marginTop: 5
      idColumn:
         width: 30
      hideColumn:
         display: 'none'

   render: ->
      objectCardParams = @_OBJECT_CARD_PARAMS
      appointmentActions = objectCardParams.customActions.appointmentActions

      `(
         <DataTable  recordsPerPage={15}
                     modelParams={ { name: this._MODEL_NAME } }
                     enableColumnsHeader={true}
                     isFitToContainer={true}
                     fluxParams={
                        {
                           store: AdminStore,
                           init: {
                              sendRequest: AdminActionCreators.getWorkplaces,
                              responseType: ActionTypes.Workplace.WP_RESPONSE,
                              getResponse: AdminStore.getWorkplaces,
                              getFieldParams: AdminStore.getWorkplacesFieldParams,
                              getPageCount: AdminStore.getWorkplacesPageCount,
                              getEntriesStatistic: AdminStore.getWorkplacesEntriesStatistic
                           },
                           create: {
                              sendInitRequest: AdminActionCreators.getWorkplaceFields,
                              responseInitType: ActionTypes.Workplace.WP_NEW_RESPONSE,
                              getInitResponse: AdminStore.getWorkplace,
                              sendRequest: AdminActionCreators.createWorkplace,
                              getResponse: AdminStore.getWorkplaceCreationResult,
                              responseType: ActionTypes.Workplace.WP_CREATE_RESPONSE
                           },
                           update: {
                              sendInitRequest:AdminActionCreators.getWorkplace,
                              responseInitType: ActionTypes.Workplace.WP_GET_RESPONSE,
                              getInitResponse: AdminStore.getWorkplace,
                              sendRequest: AdminActionCreators.editWorkplace,
                              getResponse: AdminStore.getWorkplaceEditResult,
                              responseType: ActionTypes.Workplace.WP_EDIT_RESPONSE
                           },
                           delete: {
                              sendRequest: AdminActionCreators.deleteWorkplace,
                              getResponse: AdminStore.getWorkplaceDeleteResult,
                              responseType: ActionTypes.Workplace.WP_DELETE_RESPONSE
                           }
                        }
                     }
                     massOperations={
                        {
                           isInPanel: true,
                           panelOpenButtonCaption: this._MASS_OPERATIONS_CAPTION,
                           operations: [
                              {

                              }
                           ]
                        }
                     }
                     columnRenderParams={
                        {
                           isStrongRenderRule: false,
                           columns:
                              {
                                 id: {
                                    style: this.styles.idColumn
                                 }
                              }
                        }
                     }
                     enableRowSelect={true}
                     enableRowOptions={true}
                     customRowOptions={[]}
                     enableObjectCard={true}
                     objectCardParams={
                        {
                           formatRules: objectCardParams.formatRules,
                           customActions: [
                              {
                                 name: appointmentActions.name,
                                 caption: appointmentActions.caption,
                                 icon: appointmentActions.icon,
                                 keyProp: appointmentActions.keyProp,
                                 content:  <AppointmentActions />
                              }
                           ]
                        }
                     }
         />
      )`

###* Компонент: Назначение действий пользователю. Часть компонента ContentAdminUserWorkplacesMain
*
* @props:
* @state:
*     {Number} actionID - идентификатор записи.
###
AppointmentActions = React.createClass
   # @const - параметры для массовых операций.
   _MASS_OPERATIONS_PARAMS:
      operations:
         assign:
            name: 'group_appointment'
            caption: 'Применить назначение'
            icon: 'child'
            responseText: 'Назначение выполнено'
   _ACTION_ID_TITLE:
      'номер: '
   # # @const - набор имен отображаемых полей
   # _COLUMN_RENDER_PARAMS:
   #    name:
   #       caption: 'АРМ пользователя'
   #       onRender: 'sdf'

   styles:
      assignActionsTable:
         maxHeight: 400
      actionCell:
         whiteSpace: 'normal'
      actionSecondary:
         color: _COLORS.hierarchy3
         fontSize: 12
      actionID:
         padding: _COMMON_PADDING
         float: 'right'

   getInitialState: ->
      actionID: null

   render: ->

      assignOperation = @_MASS_OPERATIONS_PARAMS.operations.assign

      `(
         <DataTable  enableRowOptions={false}
                     enableRowSelect={true}
                     enableObjectCard={false}
                     enableColumnsHeader={false}
                     enableCreate={false}
                     enableFilter={false}
                     enableSearch={true}
                     enablePerPageSelector={false}
                     enableStatusBar={false}
                     enableRowDragAndDrop={true}
                     isSearchDoOnClient={true}
                     isFitToContainer={true}
                     isHasStripFarming={false}
                     dimension={
                        {
                           dataContainer: {
                              height: {
                                 max: this.styles.assignActionsTable.maxHeight
                              }
                           }
                        }
                     }
                     columnRenderParams={
                        {
                           isStrongRenderRule: true,
                           columns: {
                              name: {
                                 onRenderCell: this._onRenderActionNameCell
                              }
                           }
                        }
                     }
                     instanceID={this.props.actionID}
                     fluxParams={
                        {
                           store: AdminStore,
                           init: {
                              sendRequest: AdminActionCreators.getAssignedActions,
                              responseType: ActionTypes.Workplace.ASSIGNED_ACTIONS_RESPONSE,
                              getResponse: AdminStore.getAssignedActions,
                              getPageCount: AdminStore.getAssignedActionsPageCount,
                              getEntriesStatistic: AdminStore.getAssignedActionsEntriesStatistic
                           }
                        }
                     }
                     massOperations={
                        {
                           isInPanel: false,
                           operations: [
                              {
                                 name: assignOperation.name,
                                 caption: assignOperation.caption,
                                 icon: assignOperation.icon,
                                 responseText: assignOperation.responseText,
                                 fluxParams: {
                                    store: AdminStore,
                                    sendRequest: AdminActionCreators.assignActions,
                                    getResponse: AdminStore.getAssignWorkplacesResult,
                                    responseType: ActionTypes.Workplace.ASSIGN_ACTIONS_RESPONSE
                                 }
                              }
                           ]
                        }
                     }
                  />
      )`

   ###*
   * Обработчик рендера ячейки имени действия. Задает произвольный вид для ячейки.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object}                 - хэш с параметрами записи.
   * @param {String} matchExpression - поисковая подстрока.
   * @return {React-DOM-Node} - содержимое ячейки.
   ###
   _onRenderActionNameCell: (rowRef, record, matchExpression)->
      recordFields = record.fields

      `(
         <div style={this.styles.actionCell}>
            <div style={this.styles.actionID}>
               <span style={this.styles.actionSecondary}>
                  {this._WORKPLACE_ID_TITLE}
               </span>
               <AllocationContent content={recordFields.id.value}
                                  expression={matchExpression} />
            </div>
            <div>
               <div>
                  <AllocationContent content={recordFields.name.value}
                                     expression={matchExpression} />
               </div>
               <div style={this.styles.actionSecondary}>
                  <AllocationContent content={recordFields.description.value}
                                     expression={matchExpression} />
               </div>
            </div>
         </div>
      )`

module.exports = ContentAdminUserWorkplacesMain

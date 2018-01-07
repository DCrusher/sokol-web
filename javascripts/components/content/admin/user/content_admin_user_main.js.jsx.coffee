###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin         - общие стили для компонентов.
* HelpersMixin        - функции-хэлперы для компонентов.
* AdminStore          - flux-хранилище административных действий.
* AdminActionCreators - модуль создания клиентских административных действий.
* AdminFluxConstants  - flux-константы административной части.
* StandardFluxParams         - модуль стандартных параметров flux-инфраструктуры.
* ImplementationStore        - модуль-хранилище стандартных реализаций.
* keymirror        - модуль для генерации "зеркального" хэша.
* lodash           - модуль служебных операций.
###
StylesMixin = require('components/mixins/styles')
HelpersMixin = require('components/mixins/helpers')
AdminStore = require('stores/admin_store')
AdminActionCreators = require('actions/admin_action_creators')
AdminFluxConstants = require('constants/admin_flux_constants')
StandardFluxParams = require('components/content/implementations/standard_flux_params')
ImplementationStore = require('components/content/implementations/implementation_store')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* Button            - кнопка.
* DataTable         - таблица данных.
* AllocationContent - контент с выделением по переданному выражению.
###
Selector = require('components/core/selector')
Button = require('components/core/button')
DataTable = require('components/core/data_table')
AllocationContent = require('components/core/allocation_content')
Input = require('components/core/input')

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
ContentAdminUserMain = React.createClass
   _CAPTION: 'Администрирование пользователей'
   _MODEL_NAME: 'user'
   _BTN_ADD_CAPTION: 'Новый пользователь'
   _ADD_USER_TITLE: 'Новый пользователь'
   _EDIT_USER_TITLE: 'Редактирование пользователя'
   # @const - параметры для пользовательских опций записей таблицы.
   _CUSTOM_ROW_OPTION_PARAMS:
      changePassword:
         name: 'changePassword'
         title: 'Сбросить пароль'
         icon: 'key'
         contentParams:
            model: 'user'
            clarificationParams:
               template: ["Сбросить пароль пользователю ", "{0} {1} "].join('')
               fields: ['last_name', 'first_name']
            fields: [
               {
                  type: 'password'
                  name: 'password'
                  caption: 'Пароль'
                  value: ''
                  defaultValue: ''
               }
               {
                  type: 'password'
                  name: 'password_confirmation'
                  caption: 'Подтверждение пароля'
                  value: ''
                  defaultValue: ''
              }
            ]
         responseBehavior:
            successInscription: 'Пароль успешно обновлен'
      block:
         name: 'lock'
         title: [
            'Разблокировать пользователя'
            'Заблокировать пользователя'
         ]
         icon: [
            'unlock'
            'lock'
         ]
         fieldForCondition: 'blocked_date'
         responseBehavior:
            successInscription: [
               'Пользователь заблокирован'
               'Пользователь разблокирован'
            ]
            responseObject: 'block'
            isReRenderRecord: true
   # @const - параметры для массовых операций.
   _MASS_OPERATIONS_PARAMS:
      caption: 'Операции над пользователями'
      operations:
         delete:
            name: 'group_delete'
            caption: 'Удалить пользователей'
            icon: 'trash-o'
            confirmText: 'Удалить пользователей?'
            resposneText: 'Пользователи удалены'
         block:
            name: 'group_block'
            caption: 'Заблокировать / Разблокировать'
            icon: 'lock'
            responseText: 'Блокировка / разблокировка выполнена'
   # @const - параметры для карточки объекта.
   _OBJECT_CARD_PARAMS:
      formatRules:
        caption:
           template: "{0} {1} {2}"
           fields: ['last_name', 'first_name', 'middle_name']
           icon: 'user'
      customActions:
         appointmentWorkplaces:
            name: 'appointmentWorkplaces'
            caption: 'Назначение ролей'
            icon: 'briefcase'
            keyProp: 'userID'

   # @const {Number} - кол-во записей на странице.
   PER_PAGE: 15

   render: ->
      massOperationParams = @_MASS_OPERATIONS_PARAMS
      customRowOptionParams = @_CUSTOM_ROW_OPTION_PARAMS
      objectCardParams = @_OBJECT_CARD_PARAMS
      massOperations = massOperationParams.operations
      changePasswordOption = customRowOptionParams.changePassword
      blockOption = customRowOptionParams.block
      appointmentWorkplaces = objectCardParams.customActions.appointmentWorkplaces

      `(
         <DataTable recordsPerPage={this._PER_PAGE}
                    modelParams={ { name: this._MODEL_NAME } }
                    enableColumnsHeader={true}
                    enableRowSelect={true}
                    enableRowOptions={true}
                    enableObjectCard={true}
                    enableUserFilters={true}
                    isFitToContainer={true}
                    isUseImplementation={false}
                    implementationStore={ImplementationStore}
                    fluxParams={
                        {
                           store: AdminStore,
                           init: {
                              sendRequest: AdminActionCreators.getUsers,
                              responseType: ActionTypes.User.USERS_RESPONSE,
                              getResponse: AdminStore.getUsers,
                              getFieldParams: AdminStore.getUsersFieldParams,
                              getPageCount: AdminStore.getUsersPageCount,
                              getEntriesStatistic: AdminStore.getUsersEntriesStatistic
                           },
                           create: {
                              sendInitRequest: AdminActionCreators.getUserFields,
                              responseInitType: ActionTypes.User.NEW_RESPONSE,
                              getInitResponse: AdminStore.getUser,
                              sendRequest: AdminActionCreators.createUser,
                              getResponse: AdminStore.getUserCreationResult,
                              responseType: ActionTypes.User.CREATE_RESPONSE
                           },
                           update: {
                              sendInitRequest: AdminActionCreators.getUser,
                              responseInitType: ActionTypes.User.GET_RESPONSE,
                              getInitResponse: AdminStore.getUser,
                              sendRequest: AdminActionCreators.editUser,
                              getResponse: AdminStore.getUserEditResult,
                              responseType: ActionTypes.User.EDIT_RESPONSE
                           },
                           delete: {
                              sendRequest: AdminActionCreators.deleteUser,
                              getResponse: AdminStore.getUserDeleteResult,
                              responseType: ActionTypes.User.DELETE_RESPONSE
                           },
                           userFilters: StandardFluxParams.USER_FILTERS
                        }
                     }
                     massOperations={
                        {
                           isInPanel: true,
                           panelOpenButtonCaption: massOperationParams.caption,
                           operations: [
                              {
                                 name: massOperations.delete.name,
                                 caption: massOperations.delete.caption,
                                 icon: massOperations.delete.icon,
                                 confirmText: massOperations.delete.confirmText,
                                 responseText: massOperations.delete.responseText,
                                 isUnsetMarkedOnCallback: true,
                                 fluxParams: {
                                    store: AdminStore,
                                    sendRequest: AdminActionCreators.deleteUsers,
                                    getResponse: AdminStore.getUsersDeleteResult,
                                    responseType: ActionTypes.User.GROUP_DELETE_RESPONSE
                                 }
                              },
                              {
                                 name: massOperations.block.name,
                                 caption: massOperations.block.caption,
                                 icon: massOperations.block.icon,
                                 responseText: massOperations.block.responseText,
                                 fluxParams: {
                                    store: AdminStore,
                                    sendRequest: AdminActionCreators.blockUsers,
                                    getResponse: AdminStore.getUsersBlockResult,
                                    responseType: ActionTypes.User.GROUP_BLOCK_RESPONSE
                                 }
                              }
                           ]
                        }
                     }
                     customRowOptions={
                        [
                           {  name: changePasswordOption.name,
                              title: changePasswordOption.title,
                              icon: changePasswordOption.icon,
                              contentParams: changePasswordOption.contentParams,
                              fluxParams: {
                                 store: AdminStore,
                                 sendRequest: AdminActionCreators.changePasswordUser,
                                 getResponse: AdminStore.getUserChangePasswordResult,
                                 responseType: ActionTypes.User.CHANGE_PASSWORD_RESPONSE
                              },
                              responseBehavior: changePasswordOption.responseBehavior
                           },
                           {  name: blockOption.name,
                              title: blockOption.title,
                              icon: blockOption.icon,
                              fieldForCondition: blockOption.fieldForCondition,
                              fluxParams: {
                                 store: AdminStore,
                                 sendRequest: AdminActionCreators.blockUser,
                                 getResponse: AdminStore.getUserBlockResult,
                                 responseType: ActionTypes.User.BLOCK_RESPONSE
                              },
                              responseBehavior: blockOption.responseBehavior
                           }
                        ]
                     }
                     objectCardParams={
                        {
                           formatRules: objectCardParams.formatRules,
                           customActions: [
                              {
                                 name: appointmentWorkplaces.name,
                                 caption: appointmentWorkplaces.caption,
                                 icon: appointmentWorkplaces.icon,
                                 keyProp: appointmentWorkplaces.keyProp,
                                 content:  <AppointmentWorkplaces />
                              }
                           ]
                        }
                     }
                  />
       )`

###* Компонент: Назначение АРМов пользователю. Часть компонента ContentAdminUserMain
*
* @props:
* @state:
*     {Number} userID - идентификатор записи.
*     {Object} rightsForDuties - параметры прав доступа по АРМам.
###
AppointmentWorkplaces = React.createClass
   # @const - параметры для массовых операций.
   _MASS_OPERATIONS_PARAMS:
      operations:
         assign:
            name: 'group_appointment'
            caption: 'Применить назначение'
            icon: 'users'
            responseText: 'Назначение выполнено'
   _WORKPLACE_ID_TITLE:
      'номер: '
   # # @const - набор имен отображаемых полей
   # _COLUMN_RENDER_PARAMS:
   #    name:
   #       caption: 'АРМ пользователя'
   #       onRender: 'sdf'

   # @const {Object} - набор используемых ссылок.
   _REFS: keyMirror(
      dataTable: null
   )

   # @const {String} - наименование аттрибута.
   _SELECTED_RECORD_ATTRIBUTE: 'selected'

   # @const {Object} - параметры поля-чекбокса для назначения прав.
   _INPUT_CHECKBOX_PARAMS:
      type: 'boolean'
      isNeedClearButton: false
      captionPosition: 'right'

   # @const {Array<Object>} -  параметры для полей ввода прав.
   _ACCESS_FLAGS: [
      {
         name: 'create'
         caption: 'создание'
         field: 'isCreate'
      }
      {
         name: 'delete'
         caption: 'удаление'
         field: 'isDelete'
      }
      {
         name: 'update'
         caption: 'редактирование'
         field: 'isUpdate'
      }
      {
         name: 'updateCustom'
         caption: 'спец. операции над записью'
         title: 'Любые операции над записью специфичные для действий АРМа (например: перемещение в казну)'
         field: 'isUpdateCustom'
      }
      {
         name: 'show'
         caption: 'просмотр'
         title: 'Опция просмотра карточки объекта '
         field: 'isShow'
      }
      {
         name: 'showRelated'
         caption: 'просмотр связанных'
         title: 'Показ данных связанных с текущей записью (например: правообладания имущества)'
         field: 'isShowRelated'
      }
      {
         name: 'showCustom'
         caption: 'спец разделы просмотра'
         title: 'Доступ к специальным разделам в карточке объекта (например: анализ в правообладателях)'
         field: 'isShowCustom'
      }
      {
         name: 'massOperations'
         caption: 'массовые операции'
         field: 'isMassOperations'
      }
      {
         name: 'export'
         caption: 'экспорт'
         field: 'isExport'
      }
      {
         name: 'import'
         caption: 'импорт'
         field: 'isImport'
      }
   ]

   # @const {Object} -  правав по-умопчанию.
#   _DEFAULT_ACCESS:
#      isCreate: true
#      isUpdate: true
#      isDelete: true
#      isExport: false


   # @const {String} - маркер отмеченности поля-селектора.
   _CHECKED_MARKER: 'checked'

   # @const {String} - заголовок для элемента назначения прав.
   _ACCESS_ASSIGNER_LABEL: 'Права:'

   styles:
      assignWorkplacesTable:
         maxHeight: 400
      workplaceCell:
         whiteSpace: 'normal'
      workplaceSecondary:
         color: _COLORS.hierarchy3
         fontSize: 12
      workplaceID:
         padding: _COMMON_PADDING
         float: 'right'
      rightsContainer:
         fontSize: 12
         marginTop: 3
         paddingTop: 3
         borderTopWidth: 1
         borderTopStyle: 'solid'
         borderTopColor: _COLORS.hierarchy4
         textAlign: 'left'
         cursor: 'default'
      accessList:
         display: 'inline-block'
         listStyle: 'none'
         margin: 0
         padding: 0
      accessListCaption:
         float: 'left'
         padding: 9
         fontStyle: 'italic'
      accessListItem:
         display: 'inline-block'
      accessListItemCaption:
         fontSize: 10
         color: _COLORS.main

   getInitialState: ->
      userID: null
      rightsForDuties: {}

   render: ->
      assignOperation = @_MASS_OPERATIONS_PARAMS.operations.assign
      # columnNameRenderParams = @_COLUMN_RENDER_PARAMS.name

      `(
         <DataTable ref={this._REFS.dataTable}
                    recordsPerPage={15}
                    enableCreate={false}
                    enableEdit={false}
                    enableDelete={false}
                    enableRowOptions={true}
                    enableLazyLoad={false}
                    enableRowSelect={true}
                    enableObjectCard={false}
                    enableColumnsHeader={false}
                    enableFilter={false}
                    enableSearch={true}
                    enablePerPageSelector={false}
                    enableStatusBar={false}
                    enableRowDragAndDrop={true}
                    isSearchDoOnClient={false}
                    isFitToContainer={true}
                    isHasStripFarming={false}
                    onReady={this._onDataTableReady}
                    onSelectRow={this._onDataTableSelectRow}
                    dimension={
                       {
                          dataContainer: {
                             height: {
                                max: this.styles.assignWorkplacesTable.maxHeight
                             }
                          }
                        }
                     }
                    columnRenderParams={
                       {
                          isStrongRenderRule: true,
                          columns: {
                             name: {
                                onRenderCell: this._onRenderWorkplaceNameCell
                             }
                          }
                       }
                    }
                    instanceID={this.props.userID}
                    fluxParams={
                        {
                           store: AdminStore,
                           init: {
                              sendRequest: AdminActionCreators.getAssignedWorkplaces,
                              responseType: ActionTypes.User.ASSIGNED_WORKPLACES_RESPONSE,
                              getResponse: AdminStore.getAssignedWorkplaces,
                              getPageCount: AdminStore.getAssignedWorkplacesPageCount,
                              getEntriesStatistic: AdminStore.getAssignedWorkplacesEntriesStatistic
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
                                 customData: this.state.rightsForDuties,
                                 fluxParams: {
                                    store: AdminStore,
                                    sendRequest: AdminActionCreators.assignWorkplaces,
                                    getResponse: AdminStore.getAssignWorkplacesResult,
                                    responseType: ActionTypes.User.ASSIGN_WORKPLACES_RESPONSE
                                 }
                              }
                           ]
                        }
                     }
                  />
      )`

   ###*
   * Обработчик рендера ячейки имени АРМа. Задает произвольный вид для ячейки.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object} record - запись по строке.
   * @param {String} matchExpression - поисковая подстрока.
   * @return {React-DOM-Node} - содержимое ячейки.
   ###
   _onRenderWorkplaceNameCell: (rowRef, record, matchExpression)->
      recordFields = record.fields

      `(
         <section style={this.styles.workplaceCell}>
            <div style={this.styles.workplaceID}>
               <span style={this.styles.workplaceSecondary}>
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
               <div style={this.styles.workplaceSecondary}>
                  <AllocationContent content={recordFields.description.value}
                                     expression={matchExpression} />
               </div>
            </div>
            {this._getAccessAssigner(rowRef, record)}
         </section>
       )`

   ###*
   * Функция формирования элемента для назначения прав АРМа.
   *
   * @param {React-element-ref} rowRef - ссылка на элемент строки.
   * @param {Object} record - запись по строке.
   * @return {React-DOM-Node} - содержимое ячейки.
   ###
   _getAccessAssigner: (rowRef, record) ->

      if @_isWorkplaceAssigned(record)
         `(
             <div style={this.styles.rightsContainer}
                  onClick={this._onClickWithCancelBubble}
                  onMouseDown={this._onClickWithCancelBubble}
                  onMouseUp={this._onClickWithCancelBubble}>
                <span style={this.styles.accessListCaption}>
                   {this._ACCESS_ASSIGNER_LABEL}
                </span>
                <ul style={this.styles.accessList}>
                   {this._getAccessAssignerListItems(record)}
                </ul>
             </div>
          )`

   ###*
   * Функция формирования массива элементов для назначения прав АРМа.
   *
   * @param {Object} record - запись по строке.
   * @return {React-DOM-Node} - содержимое ячейки.
   ###
   _getAccessAssignerListItems:(record) ->
      @_ACCESS_FLAGS.map ((record, accessFlag, idx) ->
         wpRights = @state.rightsForDuties
         itemCaption = accessFlag.caption
         itemTitle = accessFlag.title
         recordKey = record.key
         rightName = accessFlag.name
         rightField = accessFlag.field
         onChangeHandler =
            @_onChangeAccessFlag.bind(this, recordKey, rightField)
         recordRights = wpRights[recordKey]

         flagValue =
            if recordRights? and !_.isEmpty(recordRights)
               recordRights[rightField]

         `(
             <li key={idx}
                 style={this.styles.accessListItem}>
                <Input title={itemTitle || itemCaption}
                       caption={itemCaption}
                       styleAddition={
                          {
                             caption: this.styles.accessListItemCaption
                          }
                       }
                       idPrefix={recordKey}
                       name={rightName}
                       value={flagValue}
                       onChange={onChangeHandler}
                       {...this._INPUT_CHECKBOX_PARAMS}
                />
             </li>
         )`
      ).bind(this, record)

   ###*
   * Функция выбора отмеченных записей из общего набора записей.
   *
   * @param {Array<Object>} sourceRecords - исходные записи
   * @return {Array<Object>} - выбранные записи.
   ###
   _getSelectedRecords: (sourceRecords) ->
      _.filter(sourceRecords, @_SELECTED_RECORD_ATTRIBUTE)

   ###*
   * Функция установки существующих прав доступа на назначенные пользователю АРМы,
   *  считанные из записей загруженной таблицы.
   *
   * @param {React-element} dataTable - экземпляр таблицы данных.
   * @return
   ###
   _setExistsAssignedAccess: (records) ->
      selectedRecords = @_getSelectedRecords(records)
      rightsForDuties = @state.rightsForDuties

      for record in selectedRecords
         rights = record.rights
         rightsForDuties[record.key] = rights

      @setState rightsForDuties: rightsForDuties

   ###*
   * Функция-предикат для проверки является ли АРМ(по ключу записи) назначаемым,
   *  т.е. его ключ есть в списке назначаемых прав.
   *
   * @param {React-element} dataTable - экземпляр таблицы данных.
   * @return
   ###
   _isWorkplaceAssigned: (record) ->
      rightsForDuties = @state.rightsForDuties
      isHasRecord = record? and !_.isEmpty(record)
      isHasRightsForDuties = rightsForDuties? and !_.isEmpty(rightsForDuties)

      if isHasRecord and isHasRightsForDuties
         rightsForDuty = rightsForDuties[record.key]
         rightsForDuty? and !_.isEmpty(rightsForDuty)
      else
         false

   ###*
   * Обработчик события готовности таблицы данных (данные загружены).
   *
   * @param {React-element} _dataTable - экземпляр таблицы данных.
   * @param {Array<Object>} records - записи.
   * @return
   ###
   _onDataTableReady: (_dataTable, records) ->
      if records? and !_.isEmpty records
         @_setExistsAssignedAccess(records)

   ###*
   * Обработчик события выбора строки таблицы(отметка галочкой)
   *
   * @param {String, Number} rowKey - ключ строки.
   * @param {Object} markedRows - флаги отмеченности строк.
   * @return
   ###
   _onDataTableSelectRow: (rowKey, markedRows) ->
      rightsForDuties = @state.rightsForDuties
      rightsForDuty =
         if _.has(rightsForDuties, rowKey)
            rightsForDuties[rowKey]
         else
            record = @refs[@_REFS.dataTable].getRecord(rowKey)

            _.clone(record.rights) if record?


      isRowMarked = markedRows[rowKey]

      if isRowMarked
         rightsForDuties[rowKey] = rightsForDuty
      else
         _.unset(rightsForDuties,rowKey)

      @setState rightsForDuties: rightsForDuties

   ###*
   * Обработчик-заглушка для отмены "всплытия".
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickWithCancelBubble: (event) ->
      event.stopPropagation()

   ###*
   * Обработчик на изменения значения флага доступа.
   *
   * @param {String, Number} recordKey -
   * @param {String} rightName - .
   * @param {Boolean} accessValue - .
   * @return
   ###
   _onChangeAccessFlag: (recordKey, rightName, accessValue) ->
      rightsForDuties = @state.rightsForDuties

      if rightsForDuties[recordKey]?
         rightsForDuties[recordKey][rightName] = accessValue
      else
         newRights = {}
         newRights[rightName] = accessValue
         rightsForDuties[recordKey] = newRights

      @setState
         rightsForDuties: rightsForDuties





module.exports = ContentAdminUserMain
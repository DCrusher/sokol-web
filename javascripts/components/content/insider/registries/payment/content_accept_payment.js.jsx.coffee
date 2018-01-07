###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin             - общие стили для компонентов.
* HelpersMixin            - функции-хэлперы для компонентов.
* MoneyFormatterMixin - модуль для форматирования денежного значения.
* InsiderStore            - flux-хранилище инсайдерских действий.
* InsiderActionCreators   - модуль создания клиентских инсайдерских действий.
* InsiderFluxConstants    - flux-константы инсайдерских части.
* StandardFluxParams      - модуль стандартных параметров flux-инфраструктуры.
* ImplementationStore     - модуль-хранилище стандартных реализаций.
* PaymentRegistryRenders  - модуль произвольных рендеров реестра платежей.
* keymirror               - модуль для генерации "зеркального" хэша.
* lodash                  - модуль служебных операций.
###
StylesMixin = require('components/mixins/styles')
HelpersMixin = require('components/mixins/helpers')
MoneyFormatterMixin = require('components/mixins/money_formatter')
InsiderStore = require('stores/insider_store')
InsiderActionCreators = require('actions/insider_action_creators')
InsiderFluxConstants = require('constants/insider_flux_constants')
StandardFluxParams = require('components/content/implementations/standard_flux_params')
ImplementationStore = require('components/content/implementations/implementation_store')
PaymentRegistryRenders = require('components/content/implementations/payment_registry_renders')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* DataTable         - таблица данных.
###
DataTable = require('components/core/data_table')

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

_ERRORS =
   noPayments: 'Платежи не выбраны'

###* Компонент: прием платежей. Компонент для приема, отклонения, отправки на
*  уточнение платежей, загруженных в систему (скорее всего из УФК).
*
* @props:
*     {Boolean} isManagerUpdated - флаг обновленного менеджера (выбран другой менеджер
*                                  имущества).
*     {Boolean} isModeChanged    - флаг измененного режима работы (режим по релевантности
*                                  или по иерархии).
* @state:
###
ContentPaymentAccept = React.createClass
# @const {String} - заголовок
   _CAPTION: 'Реестр платежей'

   # @const {Object} - параметры модели.
   _MODEL_PARAMS:
      name: 'payment'
      caption: 'Платежи'

   # @const {Number} - кол-во записей на странице.
   _PER_PAGE_COUNT: 5

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
            template: "Карточка платежа [ № {0}]"
            fields: ['id']
            icon: 'list-alt'

   # @const {Object} - параметры упорядочивания полей по секциями в форме
   #                   манипуляции данными.
   _FIELDS_ORDER_BY_SECTIONS:
      root: [
         'rightholder_payer_id',
         'rightholder_receiver_id',
         'payment_plan_id',
         'status_name'
      ]

   # @const {String} - параметры ограничений для полей.
   _FIELD_CONSTRAINTS:
      constraints: [
         {
            name: 'rightholder_payer_id'
            identifyingName: 'rightholder_id'
         }
         {
            name: 'rightholder_receiver_id'
            identifyingName: 'rightholder_id'
         }
         {
            name: 'parent_id'
            identifyingName: 'payment_id'
         }
      ]

   # @const {Object} - используемые ссылки.
   _REFS: keyMirror(
      paymentTable: null
   )

   _MASS_OPERATIONS:
      isInPanel: false
      isSparceButtons: true
      operations: [
         {
            name: 'accept'
            caption: 'Подтвердить'
            title: 'Подтвердить корректоность платежа'
            icon: 'check'
            isOrdinaryButton: true
            additionButtonParams:
               isMain: true
            responseText: 'Платежи приняты'
            recordsHandler: this._prepareAcceptedPayments
            recordsValidatorParams:
               handler: this._validatePayments
               isMarkFailedRow: true
               failText: 'Всем платежам должны быть назначены платежные графики'
            fluxParams:
               store: InsiderStore
               sendRequest: InsiderActionCreators.acceptPayments
               getResponse: InsiderStore.getPaymentsAcceptResult
               responseType: ActionTypes.Payment.ACCEPT_RESPONSE
         },
         {
            name: 'clarify'
            caption: 'Уточнить'
            title: 'Отправить файл на уточнение'
            icon: 'mail-reply'
            isOrdinaryButton: true
            responseText: 'Платежи отправлены на уточнение'
            confirmText: 'Отправить выбранные платежи на уточнение?'
            recordsHandler: this._prepareSelectedPayments
            fluxParams:
               store: InsiderStore
               sendRequest: InsiderActionCreators.clarifyPayments
               getResponse: InsiderStore.getPaymentsClarifyResult
               responseType: ActionTypes.Payment.CLARIFY_RESPONSE
         },
         {
            name: 'reject'
            caption: 'Отклонить'
            title: 'Отклонить платеж. Платеж не будет принят'
            icon: 'hand-paper-o'
            isOrdinaryButton: true
            recordsHandler: this._prepareSelectedPayments
            responseText: 'Платежи отклонены'
            confirmText: 'Отклонить выбранные платежи?'
            fluxParams:
               store: InsiderStore
               sendRequest: InsiderActionCreators.rejectPayments
               getResponse: InsiderStore.getPaymentsRejectResult
               responseType: ActionTypes.Payment.REJECT_RESPONSE
         }
      ]

   mixins: [MoneyFormatterMixin
            RightsReaderForTable]

   styles:
      caption:
         color: _COLORS.hierarchy2
         marginTop: 5
      hideColumn:
         display: 'none'
      selectedRow:
         backgroundColor: '#ecf6ee'
      failedRow:
         backgroundColor: '#ffe2e2'


   render: ->
      reflectionRenderParams = @_REFLECTION_RENDER_PARAMS
      objectCardParams = @_OBJECT_CARD_PARAMS

      # store: InsiderStore,
      # init: {
      #    sendRequest: InsiderActionCreators.getOwnerships,
      #    responseType: ActionTypes.Ownership.OWNERSHIPS_RESPONSE,
      #    getResponse: InsiderStore.getOwnerships
      # },
      # create: {
      #    sendInitRequest: InsiderActionCreators.getOwnershipFields,
      #    responseInitType: ActionTypes.Ownership.OWNERSHIP_NEW_RESPONSE,
      #    getInitResponse: InsiderStore.getOwnershipFields,
      #    sendRequest: InsiderActionCreators.createOwnership,
      #    getResponse: InsiderStore.getOwnershipCreationResult,

      #    responseType: ActionTypes.Ownership.OWNERSHIP_CREATE_RESPONSE
      # },
      # update: {
      #    sendInitRequest:InsiderActionCreators.getOwnership,
      #    responseInitType: ActionTypes.Ownership.OWNERSHIP_GET_RESPONSE,
      #    getInitResponse: InsiderStore.getOwnershipData,
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
      `(

         <DataTable recordsPerPage={this._PER_PAGE_COUNT}
                     ref={this._REFS.paymentTable}
                     modelParams={ this._MODEL_PARAMS }
                     isFitToContainer={true}
                     enableRowSelect={true}
                     enableRowSelectByClick={true}
                     enableRowOptions={true}
                     enableColumnsHeader={false}
                     enableUserFilters={true}
                     enableSettings={true}
                     isRereadData={this.props.isManagerUpdated || this.props.isModeChanged}
                     isHasStripFarming={false}
                     isUseImplementation={true}
                     isMergeImplementation={true}
                     implementationStore={ImplementationStore}
                     ManualViewer={ManualViewer}
                     enableManuals={true}
                     createButtonParams={
                        {
                           caption: 'Добавить платеж',
                           title: 'Создать новый платеж',
                           isMain: false
                        }
                     }
                     filterButtonParams={
                        {
                           ready: {
                              caption: 'Выбрать',
                              title: 'Выбрать платежи'
                           },
                           applied: {
                              caption: 'Выбрано',
                              title: 'Платежи выбраны'
                           }
                        }
                     }
                     styleAddition={
                        {
                           rowSelected: this.styles.selectedRow,
                           rowFailed: this.styles.failedRow
                        }
                     }
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
                     columnRenderParams={
                       {
                           columns: {
                              payment_plan_id: {
                                 onRenderCell: this._getPaymentPlanSelectorRender()
                              }
                           }
                        }
                     }
                     customRowOptions={
                        [
                           {
                              name: 'composition',
                              title: 'Определить состав платежа',
                              icon: 'calculator',
                              isRereadAfter: false,
                              contentParams:{
                                 clarificationParams: {
                                    template: '[{0}] Определение состава платежа',
                                    fields: ['id']
                                 },
                                 dynamicParams: {
                                    reflectionToMain: 'PaymentPart',
                                    constraints: {
                                       fields: {
                                          only: ['id']
                                       },
                                       reflections: {
                                          only: ['PaymentPart']
                                       }
                                    },
                                    onClearField: this._onHandleClearSum,
                                    onChangeField: this._onHandleChangeSum,
                                    onInitField: this._onInitPartsField,
                                    onDestroyField: this._onDestroyPartsField,
                                    eagerlyLoadedReflections: {
                                       payment_parts: {
                                          isAnywhere: true
                                       }
                                    }
                                 }
                              }
                           },
                           {
                              name: 'toGenerative',
                              title: 'Сделать платеж "порождающим"',
                              confirmText: 'Перевести платеж в статус "порождающего"?',
                              icon: 'sitemap',
                              isRereadAfter: true,
                              fluxParams: {
                                 store: InsiderStore,
                                 sendRequest: InsiderActionCreators.paymentToGenerative,
                                 getResponse: InsiderStore.getPaymentToGenerativeResult,
                                 responseType: ActionTypes.Payment.TO_GENERATIVE_RESPONSE
                              },
                              responseBehavior: {
                                 successInscription: 'Платеж переведен в статус "порождающий"',
                                 responseObject: 'id'
                              }
                           }
                        ]
                     }
                    massOperations={this._MASS_OPERATIONS}
                    {...this._getDataTableRightProps()}
         />
      )`

   # Параметры для  хранения состава платежа для выполнения процедуры
   #  автоматического перераспределения состава платежа.
   _paymentsComposition: {}

   # @const {String} - наименование поля для хранения суммы платежа.
   _SUM_FIELD_NAME: 'sum'

   # @const {String} - наименование части платежа, направляемого на погашение
   #                   основной задолжности.
   _MAIN_PART_NAME: 'main'

   ###*
   * Обработчик на инициализацию поля динамической формы для перераспределения
   *  состава платежа. Вносит начальные параметры поля в набор @_paymentComposition
   *  для дальнейшего выполнения перерасчета суммы на основную задолжность.
   *
   * @param {Object} fieldParams        - папраметры поля в динамической форме.
   * @param {React-element} dynamicForm - ссылка на экземпляр динамической формы.
   * @return
   ###
   _onInitPartsField: (fieldParams, dynamicForm) ->
      partIndex = @_getInstanceIndex(fieldParams)
      paymentIdentifier = dynamicForm.getUpdateIdentifier()
      paymentComposition = @_paymentsComposition[paymentIdentifier]
      fieldInstance = fieldParams.instance

      unless paymentComposition?
         @_paymentsComposition[paymentIdentifier] = {}
         paymentComposition = @_paymentsComposition[paymentIdentifier]

      unless paymentComposition[partIndex]?
         paymentComposition[partIndex] = {}

      @_paymentsComposition[paymentIdentifier][partIndex][fieldParams.name] =
         instance: fieldInstance
         value:  @_getProcessedSumPartsFieldValue(fieldParams.name,
                                                  fieldInstance.getValue(),
                                                  fieldParams.type)

   ###*
   * Обработчик на уничтожение поля динамической формы для перераспределения
   *  состава платежа. Уничтожает параметры поля в наборе @_paymentComposition
   *  и если данное поле поле денежной суммы - добавляет удаляемую сумму к сумме
   *  части на основную задолжность.
   *
   * @param {Object} fieldParams        - папраметры поля в динамической форме.
   * @param {React-element} dynamicForm - ссылка на экземпляр динамической формы.
   * @return
   ###
   _onDestroyPartsField: (fieldParams, dynamicForm) ->
      @_returnSumToCommonAmount(fieldParams, dynamicForm, false)

   _returnSumToCommonAmount: (fieldParams, dynamicForm, isZeroSet) ->
      sumFieldName = @_SUM_FIELD_NAME
      paymentComposition = @_paymentsComposition[dynamicForm.getUpdateIdentifier()]
      fieldName = fieldParams.name

      if fieldName is sumFieldName
         instanceMainSumIndex = @_getMainPartParamsIndex(paymentComposition)
         instanceMainSumParams = paymentComposition[instanceMainSumIndex]
         instanceMainSumField = instanceMainSumParams[sumFieldName]
         deletedPartParamsIndex = @_getInstanceIndex(fieldParams)
         deletedPartField = paymentComposition[deletedPartParamsIndex][sumFieldName]
         sumMainNew = instanceMainSumField.value + +deletedPartField.value

         instanceMainSumField.value = sumMainNew
         instanceMainSumField.instance.setValue(sumMainNew)

      if isZeroSet
         deletedPartField.value = 0.toString()
      else
         _.omit(paymentComposition, [deletedPartParamsIndex])

   ###*
   * Обработчик на изменения значения в поле динамической формы для перераспределения
   *  состава платежа. Если изменение производится в поле денежной суммы выполняет
   *  определение необходимости изменения в поле суммы основной части платежа, затем
   *  сохраняет новое значение суммы в наборе @_paymentComposition.
   *
   * @param {String} value         - значение в поле.
   * @param {Object} field         - параметры поля.
   * @param {String} fieldFormName - сгенерированное имя для формы.
   * @param {React-element} dynamicForm   - ссылка на экземпляр динамической формы.
   * @return
   ###
   _onHandleChangeSum: (value, field, fieldFormName, dynamicForm) ->
      paymentIdentifier = dynamicForm.getUpdateIdentifier()
      paymentComposition = @_paymentsComposition[dynamicForm.getUpdateIdentifier()]
      formField = dynamicForm.getFormFields()[fieldFormName]
      fieldName = field.name
      fieldType = field.type
      sumFieldName = @_SUM_FIELD_NAME

      if paymentComposition? and (fieldName is sumFieldName)
         instanceIndex = @_getInstanceIndex(formField)
         instanceFieldParams = paymentComposition[instanceIndex]
         instanceMainSumIndex = @_getMainPartParamsIndex(paymentComposition)
         instanceSumField = instanceFieldParams[sumFieldName]
         dimeSumValue = @unformatMoney(value or 0, fieldType)

         # Если произведено изменение не в поле основной суммы - произведем перерасчет
         #  суммы основной части.
         unless _.isEqual(instanceIndex, +instanceMainSumIndex)
            instanceMainSumParams = paymentComposition[instanceMainSumIndex]
            instanceMainSumField = instanceMainSumParams[sumFieldName]

            sumDelta = dimeSumValue - instanceSumField.value
            sumMainNew = instanceMainSumField.value - sumDelta

            instanceMainSumField.value = sumMainNew
            instanceMainSumField.instance.setValue(sumMainNew)

         instanceSumField.value = dimeSumValue

   ###*
   * Обработчик на сброс значения в поле. Запускает функцию возврата введенной суммы
   *  в основную сумму.
   *
   * @param {Object} fieldParams        - папраметры поля в динамической форме.
   * @return
   *###
   _onHandleClearSum: (fieldParams, dynamicForm) ->
      @_returnSumToCommonAmount(fieldParams, dynamicForm, true)

   ###*
   * Функция получения предварительно обработанного значение в поле - для
   *  поля денежной суммы выполняет преобразование обычного денежного формата
   *  к целочисленному формату в копейках(для удобного расчета).
   *
   * @param {String} fieldName  - имя поля.
   * @param {String} inputValue - введенное значение в поле.
   * @param {String} fieldType  - тип поля.
   ###
   _getProcessedSumPartsFieldValue: (fieldName, inputValue, fieldType) ->
      sumFieldName = @_SUM_FIELD_NAME

      if fieldName is sumFieldName
         @unformatMoney(inputValue or '0', fieldType)
      else
         inputValue

   ###*
   * Функция получения индекса экземпляра для которого было сформированно поле по
   *  параметрам поля. Получает индекс последней связки в цепи связок поля.
   *
   * @param {Object} formField - параметры поля.
   * @return {Number, undefined}
   ###
   _getInstanceIndex: (formField) ->
      formFieldReflection = formField.reflection

      if formFieldReflection?
         reflectionChain = formFieldReflection.chain

         if reflectionChain?
            chainLastNode = _.last(reflectionChain)

            if chainLastNode?
               chainLastNode.index

   ###*
   * Функция получения инедкса части платежа на основную задолжность. Среди
   *  набора частей платежа ищет ту для которой тип части задан 'main' и возвращает
   *  его ключ.
   *
   * @param {Object} paymentComposition - набор параметров частей платежа.
   * @return {String, undefined}
   ###
   _getMainPartParamsIndex: (paymentComposition) ->
      _.findKey(paymentComposition, ((o) ->
            o.part_type.value is @_MAIN_PART_NAME
         ).bind(this)
      )
   ###*
   * Функция получения обработчика рендера ячейки с селектором платежей.
   *
   * @return {Function}
   ###
   _getPaymentPlanSelectorRender: ->
      PaymentRegistryRenders._onRenderPaymentPlanSelectorCell.bind(PaymentRegistryRenders)

   ###*
   * Функция валидации выбранных платежей. Проверяет все платежи на то
   *  чтобы им были заданы платежные графики. Если какому-либо платежу
   *  на назначен платежный график - такой платеж является ошибочным.
   *  Функция возвращает ключи строк ошибочных записей (failedRecords). Данный возврат
   *  ожидается таблицей данных и при этом ошибочные строки будут помечены.
   *  Если для валидации не было задано записей, то возвращаем ошибку
   *  для того, чтобы прервать выполнение процесса отправки запроса.
   *  Если валидация полностью пройдена возвращается пустой результат.
   *
   * @param {Array<Object>} records - выбранные записи.
   * @return {Array, undefined}
   ###
   _validatePayments: (records) ->
      paymentWithoutPlanKeys = []

      if records.length
         for record in records
            recordReflections = record.reflections

            if !recordReflections? or !recordReflections.payment_plan?
               paymentWithoutPlanKeys.push record.key

         if paymentWithoutPlanKeys? and paymentWithoutPlanKeys.length
            failedRecords: paymentWithoutPlanKeys
      else
         error: _ERRORS.noPayments

   ###*
   * Функция подготовки выбранных записей для отправки на подтверждение.
   *
   * @param {Array<Object>} records - выбранные записи.
   * @return {Array, undefined}
   ###
   _prepareAcceptedPayments: (records) ->
      preparedData = []

      for record in records
         reflections = record.reflections

         if reflections? and !_.isEmpty reflections
            paymentPlan = reflections.payment_plan

            if paymentPlan? and !_.isEmpty paymentPlan
               preparedData.push(
                  payment: record.key
                  plan: paymentPlan.value.key
               )

      preparedData if preparedData.length

   ###*
   * Функция подготовки ключей выбранных записей.
   *
   * @param {Array<Object>} records - выбранные записи.
   * @return {Array, undefined}
   ###
   _prepareSelectedPayments: (records) ->
      records.map (record) ->
         record.key

module.exports = ContentPaymentAccept

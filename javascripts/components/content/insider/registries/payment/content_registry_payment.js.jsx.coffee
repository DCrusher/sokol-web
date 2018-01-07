###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin           - общие стили для компонентов
* StandardFluxParams    - модуль стандартных параметров flux-инфраструктуры.
* InsiderStore          - flux-хранилище инсайдерских действий.
* InsiderActionCreators - модуль создания клиентских инсайдерских действий.
* InsiderFluxConstants  - flux-константы инсайдерских части.
* ImplementationStore   - модуль-хранилище стандартных реализаций.
* keymirror             - модуль для генерации "зеркального" хэша.
###
StylesMixin = require('components/mixins/styles')
StandardFluxParams = require('components/content/implementations/standard_flux_params')
InsiderStore = require('stores/insider_store')
InsiderActionCreators = require('actions/insider_action_creators')
InsiderFluxConstants = require('constants/insider_flux_constants')
ImplementationStore = require('components/content/implementations/implementation_store')
keyMirror = require('keymirror')

###* Зависимости: компоненты
* DataTable         - таблица данных.
###
DataTable = require('components/core/data_table')

###* Зависимости: прикладные компоненты.
* ManualViewer - просмотрщик руководств.
###
ManualViewer = require('components/application/manual_viewer')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

# Типы событий
ActionTypes = InsiderFluxConstants.ActionTypes

RightsReaderForTable = require('components/content/mixins/rights_reader_for_table')

###*
* Компонент: реестр платежей
* @props:
*     {Boolean} isManagerUpdated - флаг обновленного менеджера (выбран другой менеджер
*                                  имущества).
*     {Boolean} isModeChanged    - флаг измененного режима работы (режим по релевантности
*                                  или по иерархии).
###
ContentPayment = React.createClass

   # @const {Object} - параметры модели.
   _MODEL_PARAMS:
      name: 'payment'
      caption: 'Платежи'

   # @const {Object} - наименование реестров платежей.
   _PAYMENT_REGISTRIES: keyMirror(
      accepted: null
      rejected: null
      clarified: null
   )

   # @const {Object} - опции платежей.
   _PAYMENT_ROW_OPTIONS:
      changeStatus:
         name: 'changeStatus'
         title: 'Изменить статус платежа'
         icon: 'undo'
         isRereadAfter: true
         contentParams:
            clarificationParams:
               template: 'Изменение статуса платежа № {0}'
               fields: ['id']
            dynamicParams:
               constraints:
                  fields:
                     only: ['status_name']
                  reflections:
                     isPurged: true
      clarifyAttributes:
         name: 'clarifyAttributes'
         title: 'Уточнить аттрибуты платежа'
         icon: 'pencil-square-o'
         isRereadAfter: false
         contentParams:
            clarificationParams:
               template: 'Уточняемые аттрибуты платежа № {0}'
               fields: ['id']
         fluxParams:
            store: InsiderStore
            sendInitRequest: InsiderActionCreators.getClarifiedAttributes
            responseInitType: ActionTypes.Payment.CLARIFIED_ATTR_GET_RESPONSE
            getInitResponse: InsiderStore.getPaymentClarifiedAttributes
            sendRequest: InsiderActionCreators.setClarifiedAttributes
            getResponse: InsiderStore.getSetPaymentClarifiedAttributesResult
            responseType: ActionTypes.Payment.CLARIFIED_ATTR_SET_RESPONSE
         responseBehavior:
            responseObject: 'payment'
            isReRenderRecord: true
            successInscription: 'Аттрибуты для уточнения заданы'



   # @const {Object} - массовые операции над платежами.
   _MASS_OPERATIONS:
      createClarifying:
         name: 'createClarifying'
         caption: 'Сформировать уточнение'
         title: 'Сформировать и отправить файл уточнения по выбранным платежам'
         isOrdinaryButton: true
         confirmText: 'Сформировать уточнения по выбранным файлам?'
         icon: 'file-o'
         fluxParams:
            store: InsiderStore
            sendRequest: InsiderActionCreators.clarifyingPayments
            getResponse: InsiderStore.getPaymentsClarifyingResult
            responseType: ActionTypes.Payment.CLARIFYING_RESPONSE

   mixins: [RightsReaderForTable]

   # @const {Number} - кол-во записей на странице.
   _PER_PAGE_COUNT: 5

   # @const {Number} - номер стартовой страницы.
   _START_PAGE: 1

   # @const {String} - разделитель пути ресурса
   _ENDPOINT_SPLITTER: '/'

   render: ->
      modelParams = _.clone(@_MODEL_PARAMS)
      paymentRegistry = @_getSubResource()
      modelParams.subResource = paymentRegistry

      `(
         <DataTable recordsPerPage={this._PER_PAGE_COUNT}
                    startPage={this._START_PAGE}
                    modelParams={modelParams}
                    isFitToContainer={true}
                    enableRowSelect={true}
                    enableRowOptions={true}
                    enableColumnsHeader={false}
                    enableUserFilters={true}
                    enableSettings={true}
                    isSuppressLargeTotalRecordsOutput={true}
                    isRereadData={this.props.isManagerUpdated || this.props.isModeChanged}
                    isHasStripFarming={false}
                    isUseImplementation={true}
                    implementationStore={ImplementationStore}
                    customRowOptions={this._getPaymentOptions(paymentRegistry)}
                    ManualViewer={ManualViewer}
                    enableManuals={true}
                    fluxParams={
                       {
                          isUseServiceInfrastructure: true,
                          userFilters: StandardFluxParams.USER_FILTERS
                       }
                    }
                    massOperations={this._getMassOperations(paymentRegistry)}
                    {...this._getDataTableRightProps()}
               />
      )`

   ###*
   * Функция формирования набора опций для массовых операций над записями.
   *
   * @param {String} paymentRegistry - наименование реестра платежей для которого
   *                                   формируются опции.
   * @return {Array} - набор опций.
   ###
   _getMassOperations: (paymentRegistry) ->
      massOperations = @_MASS_OPERATIONS
      paymentRegistries = @_PAYMENT_REGISTRIES
      operations = []

      if paymentRegistry is paymentRegistries.clarified
         operations.push massOperations.createClarifying

      unless _.isEmpty operations
         operations: operations
         isInPanel: false

   ###*
   * Функция формирования массива пользовательских опций действий над экземпляром
   *  платежа в реестре.
   *
   * @param {String} paymentRegistry - наименование реестра платежей для которого
   *                                   формируются опции.
   * @return {Array} - набор опций.
   ###
   _getPaymentOptions: (paymentRegistry) ->
      rowOptions = @_PAYMENT_ROW_OPTIONS
      paymentRegistries = @_PAYMENT_REGISTRIES
      paymentOptions = [
         rowOptions.changeStatus
      ]

      if paymentRegistry is paymentRegistries.clarified
         paymentOptions.push rowOptions.clarifyAttributes

      paymentOptions

   ###*
   * Функция формирования адреса вложенного ресурса в зависимости от текущего адреса.
   *
   * @return {String}
   ###
   _getSubResource: ->
      splitter = @_ENDPOINT_SPLITTER

      _.drop(window.location.pathname.split(splitter), 2).join(splitter)

module.exports = ContentPayment
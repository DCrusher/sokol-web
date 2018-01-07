###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin           - общие стили для компонентов
* HelpersMixin          - функции-хэлперы для компонентов
* InsiderStore          - flux-хранилище инсайдерских действий
* InsiderActionCreators - модуль создания клиентских инсайдерских действий
* InsiderFluxConstants  - flux-константы инсайдерских части
* StandardFluxParams         - модуль стандартных параметров flux-инфраструктуры.
* ImplementationStore        - модуль-хранилище стандартных реализаций.
###
StylesMixin = require('components/mixins/styles')
HelpersMixin = require('components/mixins/helpers')
StandardFluxParams = require('components/content/implementations/standard_flux_params')
ImplementationStore = require('components/content/implementations/implementation_store')

###* Зависимости: компоненты
* Button            - кнопка.
* DataTable         - таблица данных.
* AllocationContent - контент с выделением по переданному выражению.
###
Selector = require('components/core/selector')
Button = require('components/core/button')
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
#ActionTypes = InsiderFluxConstants.ActionTypes

###* Компонент: контент администрирования документальных оснований
*
* @props:
*     {Boolean} isManagerUpdated - флаг обновленного менеджера (выбран другой менеджер
*                                  имущества).
* @state:
###
ContentRegistryDocumentalBasis = React.createClass
   _CAPTION: 'Администрирование документальных оснований'
   _BTN_ADD_CAPTION: 'Новое документальное основание'

   # @const {Object} - параметры модели.
   _MODEL_PARAMS:
      name: 'documental_basis'
      view: 'consolidated_documental_basis'
      caption: 'Документы'

   # @const {Number} - кол-во записей на странице.
   _PER_PAGE_COUNT: 15

   _MASS_OPERATIONS:
      isInPanel: true
      panelOpenButtonCaption: this._MASS_OPERATIONS_CAPTION,
      operations: [
         {
            delete:
               caption: this._MASS_OPERATION_DELETE
         }
      ]

   mixins: [RightsReaderForTable]

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

   render: ->
      `(
         <DataTable recordsPerPage={this._PER_PAGE_COUNT}
                    modelParams={this._MODEL_PARAMS}
                    isRereadData={this.props.isManagerUpdated}
                    isFitToContainer={true}
                    isUseImplementation={true}
                    isMergeImplementation={true}
                    isHasStripFarming={false}
                    isSuppressLargeTotalRecordsOutput={true}
                    implementationStore={ImplementationStore}
                    ManualViewer={ManualViewer}
                    enableManuals={true}
                    fluxParams={
                        {
                           isUseServiceInfrastructure: true,
                           userFilters: StandardFluxParams.USER_FILTERS
                        }
                     }
                    enableColumnsHeader={false}
                    enableRowSelect={true}
                    enableRowOptions={false}
                    enableUserFilters={true}
                    enableSettings={true}
                    massOperations={this._MASS_OPERATIONS}
                    {...this._getDataTableRightProps()}
                    enableCreate={false}
                  />
       )`

module.exports = ContentRegistryDocumentalBasis
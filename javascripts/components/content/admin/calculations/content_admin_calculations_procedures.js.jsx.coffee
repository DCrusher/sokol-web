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
ImplementationStore = require('components/content/implementations/implementation_store')

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
ContentAdminCalculationProceduresMain = React.createClass
   # @const - параметры для карточки объекта.

   _MODEL_NAME: 'calculation_procedure'

   _OBJECT_CARD_PARAMS:
      formatRules:
         caption:
            template: "{0}"
            fields: ['name']
            icon: 'briefcase'
      customActions:
         operandsActions:
            name: 'operandsActions'
            caption: 'Операнды'
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
      operandsActions = objectCardParams.customActions.operandsActions

      `(
         <DataTable  recordsPerPage={15}
                     modelParams={{ name: this._MODEL_NAME }}
                     enableColumnsHeader={true}
                     isFitToContainer={true}
                     isUseImplementation={true}
                     isMergeImplementation={true}
                     implementationStore={ImplementationStore}
                     fluxParams={
                        {
                           isUseServiceInfrastructure: true
                        }
                     }
                     columnRenderParams={
                        {
                           isStrongRenderRule: false,
                           columnsOrder: ['id', 'caption', 'description', 'pattern', 'annual'],
                           columns:
                              {
                                 id: {
                                    style: this.styles.idColumn
                                 }
                              }
                        }
                     }
                     dataManipulationParams={
                        {
                           enableClientConstruct: true,
                           fieldConstraints: {
                              constraints: [
                                 {
                                    name: 'factor_id',
                                    identifyingName: 'factor',
                                    parents: ['calculation_operands']
                                 }
                              ]
                           }
                        }
                     }
                     enableRowSelect={true}
                     enableObjectCard={true}
                     objectCardParams = {
                        {
                           isDisplayReflections: true,
                           formatRules: {
                              reflections: {
                                 calculation_operands: {
                                    isUseParentResource: false,
                                    icon: 'birthday-cake',
                                    relations: [
                                    {
                                       primaryKey: {
                                          name: 'id'
                                       },

                                       isCollection: true,
                                       isReverseMultiple: false,
                                       polymorphicReverse: null,
                                       index: 1,
                                       reflection: 'calculation_operands'
                                    }
                                    ],
                                    redefinedCaption: 'Операнды'
                                 }
                              }
                           }
                        }
                     }
         />
      )`


module.exports = ContentAdminCalculationProceduresMain

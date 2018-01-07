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
ContentAdminCalculationConstantsMain = React.createClass
   # @const - параметры для карточки объекта.
   _OBJECT_CARD_PARAMS:
      formatRules:
         caption:
            template: "{0}"
            fields: ['name']
            icon: 'briefcase'
      customActions:
         constantValuesActions:
            name: 'constantValuesActions'
            caption: 'История значений'
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
      constantValuesActions = objectCardParams.customActions.constantValuesActions

      `(
         <DataTable  recordsPerPage={15}
                     modelParams={{ name: 'calculation_constant' }}
                     enableColumnsHeader={true}
                     isFitToContainer={true}
                     fluxParams={
                        {
                           isUseServiceInfrastructure: true
                        }
                     }
                     dataManipulationParams={
                        {
                           enableClientConstruct: true,
                        }
                     }
                     columnRenderParams={
                        {
                           isStrongRenderRule: false,
                           columnsOrder: ['id','name', 'caption', 'description'],
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

                     enableObjectCard={true}

                     objectCardParams = {
                        {
                           isDisplayReflections: true,
                           formatRules: {
                              reflections: {
                                 calculation_constant_values: {
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
                                          reflection: 'calculation_constant_values'
                                       }
                                    ] ,
                                    redefinedCaption: 'Значения'
                                 }
                              }
                           }
                        }
                     }
         />
      )`


module.exports = ContentAdminCalculationConstantsMain

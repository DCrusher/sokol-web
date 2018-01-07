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
ContentAdminCalculationFactorsMain = React.createClass
   # @const - параметры для карточки объекта.

   _MODEL_NAME: 'factor'

   _OBJECT_CARD_PARAMS:
      formatRules:
         caption:
            template: "{0}"
            fields: ['value']
            icon: 'briefcase'
      customActions:
         factorsActions:
            name: 'factorsActions'
            caption: 'Коэффициенты'
            icon: 'briefcase'
            keyProp: 'actionID'

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
                     max: 300
         instance:
            dimension:
               width:
                  max: 250

   # @const {Object} - параметры иерархического представления таблицы.
   _HIERARCHY_VIEW_PARAMS:
      viewType: 'tree'
      viewParams:
         mainDataParams:
            template: "{0}"
            fields: ['caption']
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


   render: ->
      objectCardParams = @_OBJECT_CARD_PARAMS
      factorsActions = objectCardParams.customActions.factorsActions
      hierarchyViewParams = @_HIERARCHY_VIEW_PARAMS
      reflectionRenderParams = @_REFLECTION_RENDER_PARAMS

      `(
         <DataTable  recordsPerPage={15}
                     modelParams={{ name: this._MODEL_NAME }}
                     viewType={hierarchyViewParams.viewType}
                     isFitToContainer={true}
                     isUseImplementation={true}
                     isMergeImplementation={true}
                     implementationStore={ImplementationStore}
                     hierarchyViewParams={
                        {
                           enableViewChildsCounter: true,
                           enableViewKey: true,
                           enableViewServiceDate: true,
                           enableSelectParents: true,
                           mainDataParams: hierarchyViewParams.viewParams.mainDataParams,
                           titleDataParams: hierarchyViewParams.viewParams.titleDataParams
                        }
                     }
                     fluxParams={
                        {
                           isUseServiceInfrastructure: true
                        }
                     }
                     dataManipulationParams={
                        {
                           enableClientConstruct: true,
                           fieldConstraints: {
                              constraints: [
                                 {
                                    name: 'parent_id',
                                    identifyingName: 'factor'
                                 }
                              ]
                           }
                        }
                     }
                     objectCardParams = {
                        {
                           isDisplayReflections: true,
                           formatRules: {
                              reflections: {
                                 factor_values: {
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
                                          reflection: 'factor_values'
                                       }
                                    ],
                                    redefinedCaption: 'Значения'
                                 }
                              }
                           }
                        }
                     }
                     enableRowSelect={true}
                     enableObjectCard={true}
         />
      )`


module.exports = ContentAdminCalculationFactorsMain

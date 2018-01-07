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
* Button            - кнопка.
* DataTable         - таблица данных.
* Label             - лейбл.
* AllocationContent - контент с выделением по переданному выражению.
###
Button = require('components/core/button')
DataTable = require('components/core/data_table')
Label = require('components/core/label')
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
ContentAdminManuals = React.createClass

   # @const {Object} - параметры лейбла-идентификатора статьи руководства.
   _MANUAL_ARTICLE_PARAMS:
      icon: 'font'
      isWithoutPadding: true
      isLink: true

   # @cons {Array} - цепь считывания статьи руководства из записи.
   _ARTICLE_READING_CHAIN: ['value', 0, 'fields', 'content', 'value']

   _PER_PAGE_COUNT: 15

   _MODEL_NAME: 'manual'

   _TABLE_TREE_VIEW: 'tree'

   styles:
      caption:
         color: _COLORS.hierarchy2
         marginTop: 5
      idColumn:
         width: 30
      hideColumn:
         display: 'none'
      articleLabelCell:
         width: '2%'

   render: ->
#      objectCardParams = @_OBJECT_CARD_PARAMS
#      operandsActions = objectCardParams.customActions.operandsActions

      `(
          <DataTable  recordsPerPage={this._PER_PAGE_COUNT}
                      modelParams={{ name: this._MODEL_NAME }}
                      enableColumnsHeader={true}
                      viewType={this._TABLE_TREE_VIEW}
                      isFitToContainer={true}
                      isUseImplementation={true}
                      isMergeImplementation={true}
                      implementationStore={ImplementationStore}
                      fluxParams={
                         {
                            isUseServiceInfrastructure: true
                         }
                      }
                      hierarchyViewParams={
                        {
                           enableViewChildsCounter: true,
                           enableViewKey: true,
                           enableViewServiceDate: true,
                           enableSelectParents: true,
                           mainDataParams: {
                              template: '{0}',
                              fields: ['caption']
                           },
                           secondaryDataParams: {

                              template: '[{0}] тип: {1}, категория: {2}, уровень доступа: {3}',
                              fields: ['name', 'manual_type', 'manual_category', 'access_level']
                           },
                           titleDataParams: {
                              template: '{0}',
                              fields: ['name']
                           },
                           styleForAdditionCell: this.styles.articleLabelCell,
                           onRenderNodeAddition: this._onRenderManualArticleLabel
                        }
                      }
                      dataManipulationParams={
                        {
                           enableClientConstruct: true,
                           fieldConstraints: {
                              constraints: [
                                 {
                                    name: 'parent_id',
                                    identifyingName: 'manual_id'
                                 },
                                 {
                                    name: 'source_id',
                                    identifyingName: 'manual_id'
                                 },
                                 {
                                    name: 'author_id',
                                    identifyingName: 'users'
                                 },
                                 {
                                    name: 'last_updated_user_id',
                                    identifyingName: 'users'
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
                                 manual_contents: {
                                    isUseParentResource: false,
                                       icon: 'bars',
                                       relations: [
                                       {
                                          primaryKey: {
                                             name: 'id'
                                          },
                                          isCollection: true,
                                          isReverseMultiple: false,
                                          polymorphicReverse: null,
                                          index: 1,
                                          reflection: 'manual_contents'
                                       }
                                    ] ,
                                    redefinedCaption: 'Статьи'
                                 }
                              }
                           }
                        }
                     }
          />
      )`

   ###*
   * Функция рендера доп. ячейки узла, отображающей лейбл-индикатор наличия
   *  статьи руководства.
   *
   * @param {Object} record
   * @return {React-element}
   ###
   _onRenderManualArticleLabel: (record) ->
      reflections = record.reflections
      manualContent = reflections.manual_contents if reflections?

      if manualContent? and !_.isEmpty(manualContent)
         manualArticle = _.get(manualContent, @_ARTICLE_READING_CHAIN)

         if manualArticle?
            `(
               <Label title={manualArticle}
                      {...this._MANUAL_ARTICLE_PARAMS}
                   />
             )`

module.exports = ContentAdminManuals

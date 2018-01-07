###* Зависимости: модули
* HelpersMixin               - модуль вспомогательных функций.
* StylesMixin                - общие стили для компонентов.
* AnalyseReleasedHandlers    - модуль произвольных обработчиков для таблицы проведенных анализов.
* RightholderRegistryRenders - модуль произвольных рендеров ячеек таблицы данных
*                              для реестра правообладателей.
* PropertyRegistryRenders    - модуль произвольных рендеров ячеек таблицы данных
*                              для реестра имущества.
* keymirror                  - модуль для генерации "зеркального" хэша.
* pluralize                  - модуль для перевода слов во множественную/единственную форму(англ.).
* lodash                     - модуль служебных операций.
*###
HelpersMixin = require('components/mixins/helpers')
StylesMixin = require('components/mixins/styles')
AnalyseReleasedHandlers = require('components/content/implementations/analyse_released_handlers')
DocumentRegistryRenders = require('components/content/implementations/document_registry_renders')
DocumentRenders = require('components/content/implementations/document_renders')
RightholderRegistryRenders = require('components/content/implementations/rightholder_registry_renders')
PropertyRegistryRenders = require('components/content/implementations/property_registry_renders')
OwnershipRegistryRenders = require('components/content/implementations/ownership_registry_renders')
OwnershipRegistryHandlers = require('components/content/implementations/ownership_registry_handlers')
PaymentRegistryRenders = require('components/content/implementations/payment_registry_renders')
PaymentPlanRenders = require('components/content/implementations/payment_plan_renders')
keyMirror = require('keymirror')
pluralize = require('pluralize')
_ = require('lodash')

Button = require('components/core/button')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

###*
* Модуль для хранения стандартных параметров рендера элементов.
*  Модуль применяется для задания стандартного вида/функцияональности одним
*  и тем же элементам в различных местах.
*
###
module.exports =

   # @const {Object} - типы компонентов для которых хранятся реализации.
   _IMPLEMENTATION_TYPES: keyMirror(
      DataTable: null
      Selector: null
   )

   ###*
   * Функция для получения свойств стандартной реализации для конкретного
   *  компонента и конкретного имени.
   *
   * @props {String} name - имя экземпляра компонента.
   * @props {String} type - тип компонента.
   * @return {Object, undefined}
   ###
   getProps: (name, type) ->
      implementationTypes = @_IMPLEMENTATION_TYPES
      storeByType = @store[type]

      if storeByType?
         isDataTable = type is @_IMPLEMENTATION_TYPES.DataTable
         instanceName = if isDataTable
                           pluralize(name)
                        else
                           name

         instanceParams = storeByType[instanceName]

         instanceParams.getProps() if instanceParams?

   store:
      # Реализации DataTable
      DataTable:

         # АДРЕСА.
         addresses:
            styles:
               typeColumn:
                  width: 100
               roomColumn:
                  width: 150
                  textAlign: 'center'

            getProps: ->
               columnRenderParams:
                  isStrongRenderRule: true
                  columns:
                     address_type:
                        style: @styles.typeColumn
                     address_landpoint_id:
                        caption: 'Адрес'
                     addresser_id:
                        isHidden: true
                     addresser_type:
                        isHidden: true
                     room_number:
                        reflections:
                           ['address_landpoint']
                        style: @styles.roomColumn
                     description:
                        reflections:
                           ['address_landpoint']
                  cells:
                     address_landpoint_id:
                        format:
                           template: '{0}'
                           arbitrary: [
                              chain: ['synthetic_address']
                           ]

         # РЕАЛИЗОВАННЫЕ АНАЛИЗЫ.
         analyse_releaseds:
            styles:
               idColumn:
                  width: 100


            getProps: ->
               handlers = AnalyseReleasedHandlers

               columnRenderParams:
                  isStrongRenderRule: true
                  columnsOrder: [
                     'id', 'name', 'user_id', 'importance_level', 'date'
                  ]
                  columns:
                     id:
                        style: @styles.idColumn
                        caption: 'Номер'
                     importance_level:
                        caption: 'Граница значимости'
                     user_id:
                        caption: 'Исполнитель'
                     date:
                        caption: 'Дата проведения'
                     name:
                        caption: 'Процедура анализа'
                        reflections: ['analyse_procedure']
                  cells:
                     user_id:
                        format:
                           template: '{0} {1} {2}'
                           arbitrary: [
                              { chain: ['reflections', 'user', 'value', 'fields', 'last_name', 'value'] }
                              { chain: ['reflections', 'user', 'value', 'fields', 'first_name', 'value'] }
                              { chain: ['reflections', 'user', 'value', 'fields', 'middle_name', 'value'] }
                           ]
               customRowOptions: [
                  name: 'getPrintForm'
                  title: 'Запросить результат анализа'
                  icon: 'file-text-o'
                  customHandler:
                     handlers.getAnalyseReleasedPrintForm.bind(handlers)
               ]

         # ОКВЭД
         rightholder_okveds:
            styles:
               idColumn:
                  width: 30
                  margin: 3

            getProps: ->
               styles = @styles

               columnRenderParams:
                  isStrongRenderRule: true
                  columns:
                     okved_id:
                        style:
                           width: 100
                        caption: 'Код'
                     okved_name:
                        isVirtual: true
                        caption: 'Наименование'
                  cells:
                     okved_id:
                        format:
                           template: "{0}"
                           arbitrary: [
                              {
                                 chain: [
                                    'reflections'
                                    'okved'
                                    'value'
                                    'fields'
                                    'code'
                                    'value'
                                 ]
                              }
                           ]
                     okved_name:
                        format:
                           template: "{0}"
                           arbitrary: [
                             {
                                 chain: [
                                    'reflections'
                                    'okved'
                                    'value'
                                    'fields'
                                    'name'
                                    'value'
                                 ]
                              }
                           ]

         # ВАРИАНТЫ ДЛЯ АНАЛИЗОВ.
         analyse_variants:
            getProps: ->
               handlers = AnalyseReleasedHandlers

               columnRenderParams:
                  isStrongRenderRule: true
                  columns:
                     level: null,
                     name: null,
                     description: null,
                     default_weight: null

         # КОНТАКТЫ ПРАВООБЛАДАТЕЛЯ.
         contacts:
            styles:
               idColumn:
                  width: 30
                  margin: 3

            getProps: ->
               styles = @styles

               columnRenderParams:
                  isStrongRenderRule: true
                  columns:
                     id:
                        style: styles.idColumn
                     contact_type: null
                     contact: null
                     person: null

         # ДОКУМЕНТЫ (сводные документальные основания).
         consolidated_documental_bases:
            getProps: ->
               renders = DocumentRegistryRenders
               reflectionRelations = @_getReflectionRelations()

               columnRenderParams:
                  isStrongRenderRule: true
                  columns:
                     id:
                        onRenderCell: renders._onRenderDocumentCell.bind(renders)
               objectCardParams:
                  isDisplayReflections: true
                  maxDataTabCountPerLine: 7
                  formatRules:
                     caption:
                        template: "Документальное основание (№ {0})"
                        fields: ['id']
                        icon: 'clipboard'
                     content:
                        render: renders._onRenderDocumentObjectCardContent.bind(renders)
                     reflections:
                        documents:
                           icon: 'file-text-o'
                           relations: reflectionRelations.documents
                        documental_basis:
                           isProhibited: true
                           isDamned: true
                        ownership:
                           icon: 'handshake-o'
                           relationAlternatives:
                              reflectionRelations.ownershipAlternatives
                           isDamned: true
                        ownership_status:
                           isHidden: true
                        payment_plan:
                           isHidden: true
                           isDamned: true
                        payment:
                           icon: 'rub'
                           relations: reflectionRelations.payment
                        kbk:
                           isHidden: true
                        legal_entity_employee:
                           icon: 'street-view'
                           relations: reflectionRelations.employee
                        legal_entity_post:
                           isProhibited: true
                        property:
                           icon: 'building-o'
                           relationAlternatives:
                              reflectionRelations.propertyAlternatives
                        property_change:
                           icon: 'exchange'
                           relations: reflectionRelations.propertyChange
                        property_milestone:
                           icon: 'briefcase'
                           relations: reflectionRelations.propertyMilestone
                        rightholder_receiver:
                           isProhibited: true
                           isDamned: true
            ###*
            * Функция формирования параметров для считывания разрешенных
            *  связок.
            *
            * @return {Object}
            ###
            _getReflectionRelations: ->
               relationDummy =
                  primaryKey:
                     name: 'id'
                  isCollection: true
                  isReverseMultiple: false
                  polymorphicReverse: null
                  index: 1

               documents = _.clone(relationDummy)
               ownership = _.clone(relationDummy)
               ownershipStatuses = _.clone(relationDummy)
               paymentPlan = _.clone(relationDummy)
               paymentPlanWithChildren = _.clone(relationDummy)
               payment = _.clone(relationDummy)
               paymentForPP = _.clone(relationDummy)
               paymentCorrectionForPP = _.clone(relationDummy)
               legalEntityEmployee = _.clone(relationDummy)
               property = _.clone(relationDummy)
               propertyChange = _.clone(relationDummy)
               propertyChangeForP = _.clone(relationDummy)
               propertyMilestone = _.clone(relationDummy)
               propertyMilestoneForP = _.clone(relationDummy)
               treasuryForP = _.clone(relationDummy)

               documents.reflection = 'documents'
               ownership.reflection = 'ownership'
               ownershipStatuses.reflection = 'ownership_status'
               paymentPlan.reflection = 'payment_plan'
               paymentPlanWithChildren.reflection = 'payment_plans'
               payment.reflection = 'payment'
               paymentForPP.reflection = 'payments'
               legalEntityEmployee.reflection = 'legal_entity_employee'
               property.reflection = 'property'
               propertyChange.reflection = 'property_change'
               propertyChangeForP.reflection = 'property_changes'
               propertyMilestone.reflection = 'property_milestone'
               propertyMilestoneForP.reflection = 'property_milestone'
               treasuryForP.reflection = 'treasuries'

               ownership.isReverseMultiple = true
               ownershipStatuses.isCollection = true
               paymentPlan.isCollection = true
               paymentPlanWithChildren.isReverseMultiple = true
               documents.isReverseMultiple = true
               payment.isCollection = false
               legalEntityEmployee.isCollection = false
               property.isReverseMultiple = true
               treasuryForP.isReverseMultiple = true
               propertyChange.isCollection = false
               propertyMilestone.isCollection = false

               documents: [documents]
               ownershipAlternatives: [
                  {
                     name: 'payment'
                     relations: [paymentForPP, paymentPlanWithChildren, ownership]
                  }
                  {
                     name: 'ownership_status'
                     relations: [ownershipStatuses, ownership]
                  }
                  {
                     name: 'payment_plan'
                     relations: [paymentPlan, ownership]
                  }
               ]
               payment: [payment]
               employee: [legalEntityEmployee]
               propertyAlternatives: [
                  {
                     name: 'property_change'
                     relations: [propertyChangeForP, property]
                  }
                  {
                     name: 'property_milestone'
                     relations: [propertyMilestoneForP, treasuryForP, property]
                  }
               ]
               propertyChange: [propertyChange]
               propertyMilestone: [propertyMilestone]

         # ДОКУМЕНТЫ (аттрибуты конкретных документов с возможностью скачивания вложений)
         documents:
            getProps: ->
               renders = DocumentRenders
               docStyles = renders.docStyles

               columnRenderParams:
                  columns:
                     id:
                        style: docStyles.idColumn
                     document_type_id:
                        style: docStyles.typeColumn
                     document_file_id:
                        style: docStyles.attachmentColumn
                        caption: 'Вложение'
                        onRenderCell: renders._onRenderAttachmentCell.bind(renders)
                  cells:
                     document_type_id:
                        format:
                           template: '{0} ({1})'
                           arbitrary: [
                              {
                                 chain: [
                                    'reflections'
                                    'document_type'
                                    'value'
                                    'fields'
                                    'name'
                                    'value'
                                 ]
                              }
                              {
                                 chain: [
                                    'reflections'
                                    'document_type'
                                    'value'
                                    'fields'
                                    'document_category'
                                    'value'
                                 ]
                              }
                           ]
                  columnsOrder: [
                     'id'
                     'name'
                     'document_type_id'
                     'number'
                     'document_date'
                     'document_file_id'
                  ]

         # СОТРУДНИКИ ЮРЛИЦА.
         legal_entity_employees:
            getProps: ->
               columnRenderParams:
                  columns:
                     legal_entity_id:
                        isHidden: true
                  cells:
                     legal_entity_post_id:
                        format:
                           template: "{0}"
                           arbitrary: [
                              chain: [
                                 'reflections',
                                 'legal_entity_post',
                                 'value',
                                 'fields',
                                 'name',
                                 'value'
                              ]
                           ]
         # ПРАВООБЛАДАНИЯ.
         ownerships:
            getProps: ->
               renders = OwnershipRegistryRenders
               reflectionRelations = @_getReflectionRelations()

               enableColumnsHeader: false
               columnRenderParams:
                  isStrongRenderRule: true
                  columns:
                     id:
                        onRenderCell: renders._onRenderOwnershipCell.bind(renders)
               filterAdditionParams:
                  search:
                    fields: [
                        {
                           names: ['name', 'number']
                           affilation: [
                              { reflection: 'ownership_statuses' }
                              { reflection: 'documental_basis' }
                              { reflection: 'documents' }
                           ]
                        }
                        {
                           names: ['name', 'number']
                           affilation: [
                              { reflection: 'payment_plans' }
                              { reflection: 'documental_basis' }
                              { reflection: 'documents' }
                           ]
                        }
                        {
                           names: ['name', 'real_cadastre_number']
                           affilation: [
                              { reflection: 'property' }
                           ]
                        }
                        {
                           names: ['old_registry_number']
                           affilation: [
                              { reflection: 'rightholder' }
                           ]
                        }
                        {
                           names: ['full_name', 'short_name', 'inn']
                           affilation: [
                              { reflection: 'rightholder' }
                              { reflection: 'entity', polyType: 'LegalEntity' }
                           ]
                        }
                        {
                           names: ['inn', 'snils']
                           affilation: [
                              { reflection: 'rightholder' }
                              { reflection: 'entity', polyType: 'PhysicalEntity' }
                           ]
                        }
                        {
                           names: 'all'
                           affilation: [
                              { reflection: 'rightholder' }
                              { reflection: 'users', polyType: null }
                           ]
                        }
                     ]
               objectCardParams:
                  isDisplayReflections: true
                  isFreezeAtInteraction: true
                  maxDataTabCountPerLine: 7
                  formatRules:
                     caption:
                        template: "Правообладание (№ {0})"
                        fields: ['id']
                        icon: 'file-text-o'
                     content:
                        render: renders._onRenderOwnershipObjectCardContent.bind(renders)
                     reflectionsOrder: [
                        'rightholder', 'property', 'ownership_statuses',
                        'payment_plans', 'ownership_addition_properties',
                        'ownership_addition_rightholders'
                     ]
                     reflections:
                        property_types:
                           isHidden: true
                        property_complexes:
                           isHidden: true
                        property_relations:
                           isHidden: true
                        ownership_type:
                           isHidden: true
                        users:
                           isHidden: true
                        entity:
                           isProhibited: true
                        rightholder:
                           icon: 'user-secret'
                        property:
                           icon: 'building-o'
                        ownership_statuses:
                           redefinedCaption: 'Статусы'
                           icon: 'anchor'
                           relations: reflectionRelations.ownershipStatuses
                        payment_plans:
                           icon: 'rub'
                           relations: reflectionRelations.paymentPlans
                        ownership_addition_properties:
                           redefinedCaption: 'Доп. имущество'
                           icon: 'object-ungroup'
                           relations: reflectionRelations.ownershipAdditionProperties
                        ownership_addition_rightholders:
                           redefinedCaption: 'Доп. правообладатели'
                           icon: 'users'
                           relations: reflectionRelations.ownershipAdditionRightholders
                        parent_ownership:
                           icon: 'angle-double-up'
                        master_ownership:
                           icon: 'angle-double-down'
                        balancekeeper_ownership:
                           icon: 'angle-double-right'

                  operationParams:
                     isUseStandard: true
                     custom: [
                        {
                           name: 'downloadDoc'
                           title: 'Скачать форму договора'
                           icon: 'file'
                           handler: OwnershipRegistryHandlers.getRentContract
                        }
                     ]

                  customActions: [
                     {
                        name: 'documents'
                        caption: 'Документы'
                        icon: 'file-text-o'
                        keyProp: 'propertyID'
                        render: renders._onRenderDocumentsContent.bind(renders)
                     }
                  ]
            ###*
            * Функция формирования параметров для считывания разрешенных
            *  связок.
            *
            * @return {Object}
            ###
            _getReflectionRelations: ->
               relationDummy =
                  primaryKey:
                     name: 'id'
                  isCollection: true
                  isReverseMultiple: false
                  polymorphicReverse: null
                  index: 1

               ownershipStatuses = _.clone(relationDummy)
               paymentPlans = _.clone(relationDummy)
               ownershipAdditionProperties = _.clone(relationDummy)
               ownershipAdditionRightholders = _.clone(relationDummy)

               ownershipStatuses.reflection = 'ownership_statuses'
               paymentPlans.reflection = 'payment_plans'
               ownershipAdditionProperties.reflection = 'ownership_addition_properties'
               ownershipAdditionRightholders.reflection = 'ownership_addition_rightholders'

#               propertyTypes.isReverseMultiple = true

               ownershipStatuses: [ownershipStatuses]
               paymentPlans: [paymentPlans]
               ownershipAdditionProperties: [ownershipAdditionProperties]
               ownershipAdditionRightholders: [ownershipAdditionRightholders]


         # СТАТУСЫ ПРАВООБЛАДАНИЙ
         ownership_statuses:
            getProps: ->
               reflectionRelations = @_getReflectionRelations()

               columnRenderParams:
                  columns:
                     ownership_id:
                        isHidden: true
                     documental_basis_id:
                        isHidden: true
               objectCardParams:
                  isDisplayReflections: true
                  formatRules:
                     reflections:
                        documental_basis:
                           isHidden: true
                        documents:
                           isUseParentResource: true
                           icon: 'file-text-o'
                           relations: reflectionRelations.documents

            ###*
            * Функция формирования параметров для считывания разрешенных
            *  связок.
            *
            * @return {Object}
            ###
            _getReflectionRelations: ->
               relationDummy =
                  primaryKey:
                     name: 'id'
                  isCollection: true
                  isReverseMultiple: false
                  polymorphicReverse: null
                  index: 1

               documentalBasisRelation = _.clone(relationDummy)
               documentRelation = _.clone(relationDummy)
               ownershipStatusRelation = _.clone(relationDummy)

               documentRelation.reflection = 'documents'
               documentalBasisRelation.reflection = 'documental_basis'
               ownershipStatusRelation.reflection = 'ownership_statuses'
               ownershipStatusRelation.isFinal = true
               documentRelation.isReverseMultiple = true
               documentalBasisRelation.isReverseMultiple = false
               documentalBasisRelation.isCollection = false


               documents: [ownershipStatusRelation, documentalBasisRelation, documentRelation]

         # ДОП. ОБЪЕКТЫ ИМУЩЕСТВА ПРАВООБЛАДАНИЯ
         ownership_addition_properties:
            getProps: ->
               columnRenderParams:
                  columns:
                     id:
                        style:
                           width: 20
                     ownership_id:
                        isHidden: true
                     property_id:
                        style:
                           width: 450
                  cells:
                     property_id:
                        format:
                           template: "({0}) {1}"
                           arbitrary: [
                              {
                                 chain: ['reflections', 'property', 'value', 'fields', 'real_cadastre_number', 'value']
                              }
                              {
                                 chain: ['reflections', 'property', 'value', 'fields', 'name', 'value']
                              }
                           ]

         # ДОП. ПРАВООБЛАДАТЕЛИ ПРАВООБЛАДАНИЯ
         ownership_addition_rightholders:
            getProps: ->
               renders = OwnershipRegistryRenders

               columnRenderParams:
                  columns:
                     id:
                        style:
                           width: 20
                     ownership_id:
                        isHidden: true
                     rightholder_id:
                        style:
                           width: 350
                        onRenderCell:
                           renders._onRenderAdditionRightholderNameCell.bind(renders)

         # ПЛАТЕЖИ
         payments:
            getProps: ->
               renders = PaymentRegistryRenders
               reflectionRelations = @_getReflectionRelations()

               enableColumnsHeader: false
               columnRenderParams:
                  isStrongRenderRule: true
                  columns:
                     id:
                        style: renders.paymentStyles.id
                        onRenderCell: renders._onRenderPaymentKeyCell.bind(renders)
                     documental_basis_id:
                        style: renders.paymentStyles.document
                        onRenderCell: renders._onRenderPaymentDocumentCell.bind(renders)
                     payment_plan_id:
                        style: renders.paymentStyles.paymentPlan
                        onRenderCell: renders._onRenderPaymentPlanCell.bind(renders)
                     rightholder_payer_id:
                        style: renders.paymentStyles.rightholder
                        onRenderCell: renders._onRenderRightholderCell.bind(renders)
                  columnsOrder: [
                     'id'
                     'documental_basis_id'
                     'payment_plan_id'
                     'rightholder_payer_id'
                  ]
               filterAdditionParams:
                  search:
                     fields: [
                        {
                           names: ['full_name', 'short_name']
                           affilation: [
                              { reflection: 'rightholder_payer', model: 'Rightholder'}
                              { reflection: 'entity', polyType: 'LegalEntity' }
                           ]
                        }
                        {
                           names: ['first_name', 'middle_name', 'last_name']
                           affilation: [
                              { reflection: 'payment_plan' }
                              { reflection: 'ownership' }
                              { reflection: 'rightholder'}
                              { reflection: 'users', isMultiple: true }
                          ]
                        }
                        {
                           names: ['full_name', 'short_name', 'inn']
                           affilation: [
                              { reflection: 'payment_plan' }
                              { reflection: 'ownership' }
                              { reflection: 'rightholder'}
                              { reflection: 'entity', polyType: 'LegalEntity' }
                          ]
                        }
                        {
                           names: ['inn', 'snils']
                           affilation: [
                              { reflection: 'payment_plan' }
                              { reflection: 'ownership' }
                              { reflection: 'rightholder'}
                              { reflection: 'entity', polyType: 'PhysicalEntity' }
                          ]
                        }
                        {
                           names: ['name', 'real_cadastre_number']
                           affilation: [
                              { reflection: 'payment_plan' }
                              { reflection: 'ownership' }
                              { reflection: 'property' }
                           ]
                        }
                        {
                           names: ['name']
                           affilation: [
                              { reflection: 'payment_plan' }
                              { reflection: 'ownership' }
                              { reflection: 'ownership_type' }
                          ]
                        }
                    ]
               objectCardParams:
                  isDisplayReflections: true
                  maxDataTabCountPerLine: 7
                  formatRules:
                     caption:
                        template: "Платеж (№ {0})"
                        fields: ['id']
                        icon: 'file-text-o'
                     # content:
                     #    render: renders._onRenderPaymentObjectCardContent.bind(renders)
                     reflections:
                        payment_plan:
                           icon: 'rub'
                           relations: reflectionRelations.paymentPlan
                        rightholder_receiver:
                           icon: 'user-secret'
                        rightholder_payer:
                           icon: 'user-secret'
                        entity:
                           isHidden: true
                  operationParams:
                     isUseStandard: true

            ###*
            * Функция формирования параметров для считывания разрешенных
            *  связок.
            *
            * @return {Object}
            ###
            _getReflectionRelations: ->
               relationDummy =
                  primaryKey:
                     name: 'id'
                  isCollection: true
                  isReverseMultiple: false
                  polymorphicReverse: null
                  index: 1

               rightholderReceiver = _.clone(relationDummy)
               rightholderPayer = _.clone(relationDummy)
               paymentPlan = _.clone(relationDummy)

               paymentPlan.reflection = 'payment_plan'

               rightholderReceiver: [rightholderReceiver]
               rightholderPayer: [rightholderPayer]
               paymentPlan: [paymentPlan]

         # ПЛАТЕЖНЫЕ ГРАФИКИ.
         payment_plans:
            getProps: ->
               renders = PaymentPlanRenders
               reflectionRelations = @_getReflectionRelations()

               columnRenderParams:
                  isStrongRenderRule: true
                  columns:
                     id:
                        onRenderCell: renders._onRenderPaymentPlanCell.bind(renders)
               enableColumnsHeader:false
               styleAddition:
                  cell:
                     padding: '10px 0px'
                  dataContainer:
                     minWidth: 640
               objectCardParams:
                  isDisplayReflections: true
                  formatRules:
                     content:
                        isHideFieldCaptions: true
                     reflections:
                        ownership:
                           isDamned: true
                           isHidden: true
                        kbk:
                           isHidden: true
                        calculation_procedure:
                           isHidden: true
                        calculation_operands:
                           isHidden: true
                        payments:
                           isUseParentResource: true
                           icon: 'rub'
                           relations: reflectionRelations.payments
                        documental_basis:
                           isHidden: true
                        documents:
                           isUseParentResource: true
                           icon: 'file-text-o'
                           relations: reflectionRelations.documents
               filterAdditionParams:
                  search:
                     fields: [
                        {
                           names: ['first_name', 'middle_name', 'last_name']
                           affilation: [
                              { reflection: 'ownership' }
                              { reflection: 'rightholder'}
                              { reflection: 'users', isMultiple: true }
                          ]
                        }
                        {
                           names: ['full_name', 'short_name', 'inn']
                           affilation: [
                              { reflection: 'ownership' }
                              { reflection: 'rightholder'}
                              { reflection: 'entity', polyType: 'LegalEntity' }
                          ]
                        }
                        {
                           names: ['inn', 'snils']
                           affilation: [
                              { reflection: 'ownership' }
                              { reflection: 'rightholder'}
                              { reflection: 'entity', polyType: 'PhysicalEntity' }
                          ]
                        }
                        {
                           names: ['name', 'real_cadastre_number']
                           affilation: [
                              { reflection: 'ownership' }
                              { reflection: 'property' }
                           ]
                        }
                        {
                           names: ['name']
                           affilation: [
                              { reflection: 'ownership' }
                              { reflection: 'ownership_type' }
                          ]
                        }
                     ]

            ###*
            * Функция формирования параметров для считывания разрешенных
            *  связок.
            *
            * @return {Object}
            ###
            _getReflectionRelations: ->
               relationDummy =
                  primaryKey:
                     name: 'id'
                  isCollection: true
                  isReverseMultiple: false
                  polymorphicReverse: null
                  index: 1

               documentalBasisRelation = _.clone(relationDummy)
               documentRelation = _.clone(relationDummy)
               paymentPlanRelation = _.clone(relationDummy)
               paymentsRelation = _.clone(relationDummy)

               documentRelation.reflection = 'documents'
               documentalBasisRelation.reflection = 'documental_basis'
               paymentPlanRelation.reflection = 'payment_plans'
               paymentsRelation.reflection = 'payments'
               paymentPlanRelation.isFinal = true
               documentRelation.isReverseMultiple = true
               documentalBasisRelation.isReverseMultiple = true
               documentalBasisRelation.isCollection = false

               payments: [paymentPlanRelation, paymentsRelation]
               documents: [paymentPlanRelation, documentalBasisRelation, documentRelation]

         # ИМУЩЕСТВО.
         properties:
            getProps: ->
               renders = PropertyRegistryRenders
               reflectionRelations = @_getReflectionRelations()

               enableColumnsHeader: false
               columnRenderParams:
                  isStrongRenderRule: true
                  columns:
                     id:
                        onRenderCell: renders._onRenderPropertyCell.bind(renders)
               objectCardParams:
                  isDisplayReflections: true
                  formatRules:
                     caption:
                        template: "Паспорт имущества (учетн номер. № {0})"
                        fields: ['id']
                        icon: 'list-alt'
                     content:
                        render: renders._onRenderPropertyObjectCardContent.bind(renders)
                     reflections:
                        oktmo:
                           isHidden: true
                        addresses:
                           icon: 'map-marker'
                           relations: reflectionRelations.addresses
                        property_types:
                           isHidden: true
                           icon: 'table'
                           relations: reflectionRelations.propertyTypes
                           redefinedCaption: 'Классификация'
                        property_costs:
                           icon: 'rub'
                           relations: reflectionRelations.propertyCosts
                           redefinedCaption: 'Стоимости'
                        property_relations:
                           icon: 'download'
                           relations: reflectionRelations.propertyRelations
                           redefinedCaption: 'Принадлежность'
                        property_affiliations:
                           icon: 'sitemap'
                           relations: reflectionRelations.propertyAffiliations
                           redefinedCaption: 'Аффилированность'
                        property_features:
                           icon: 'cog'
                           relations: reflectionRelations.propertyFeatures
                           redefinedCaption: 'Характеристики'
                        property_complexes:
                           icon: 'object-group'
                           relations: reflectionRelations.propertyComplexes
                        ownerships:
                           icon: 'handshake-o'
                           relations: reflectionRelations.ownerships
                        treasuries:
                           icon: 'briefcase'
                           relations: reflectionRelations.treasuries
                  operationParams:
                     isUseStandard: true
                     custom: [
                        {
                           name: 'treasuryChange'
                           icon: 'external-link'
                           title: 'Переместить в другую казну'
                           formParams:
                              caption: 'Перемещение имущества в другую казну'
                              reflectionsChain: [
                                 'Treasury'
                              ]
                        }
                        {
                           name: 'ownershipNew'
                           icon: 'handshake-o'
                           title: 'Новое правообладание'
                           caption: 'Создание нового правообладания'
                           formParams:
                              caption: 'Создание нового правообладания по объекту'
                              reflectionsChain: [
                                 'Ownership'
                              ]
                        }
                     ]
                  customActions: [
                     {
                        name: 'location'
                        caption: 'Расположение'
                        icon: 'map-o'
                        keyProp: 'propertyID'
                        content: renders._getPropertyMap()
                     }
                  ]

            ###*
            * Функция формирования параметров для считывания разрешенных
            *  связок.
            *
            * @return {Object}
            ###
            _getReflectionRelations: ->
               relationDummy =
                  primaryKey:
                     name: 'id'
                  isCollection: true
                  isReverseMultiple: false
                  polymorphicReverse: null
                  index: 1

               addresses = _.clone(relationDummy)
               ownerships = _.clone(relationDummy)
               treasuries = _.clone(relationDummy)
               propertyTypes = _.clone(relationDummy)
               propertyCosts = _.clone(relationDummy)
               propertyRelations = _.clone(relationDummy)
               propertyAffiliations = _.clone(relationDummy)
               propertyFeatures = _.clone(relationDummy)
               propertyComplexes = _.clone(relationDummy)

               addresses.reflection = 'addresses'
               ownerships.reflection = 'ownerships'
               treasuries.reflection = 'treasuries'
               propertyTypes.reflection = 'property_types'
               propertyRelations.reflection = 'property_relations'
               propertyAffiliations.reflection = 'property_relations'
               propertyFeatures.reflection = 'property_features'
               propertyComplexes.reflection = 'property_complexes'
               propertyCosts.reflection = 'property_costs'

               propertyAffiliations.isJustReflection = true
               propertyAffiliations.identifyingName = 'property_affiliations'

               propertyTypes.isReverseMultiple = true
               addresses.polymorphicReverse = 'addresser'

               addresses: [addresses]
               ownerships: [ownerships]
               treasuries: [treasuries]
               propertyTypes: [propertyTypes]
               propertyCosts: [propertyCosts]
               propertyFeatures: [propertyFeatures]
               propertyRelations: [propertyRelations]
               propertyAffiliations: [propertyAffiliations]
               propertyComplexes: [propertyComplexes]

         # СТОИМОСТИ ИММУЩЕСТВА.
         property_costs:
            styles:
               idColumn:
                  width: 40

            getProps: ->
               columnRenderParams:
                  alignRules:
                     cells:
                        vertical: 'middle'
                        horizontal: 'center'
                     columns:
                        horizontal: 'center'
                  columns:
                     id:
                        style: @styles.idColumn
                     property_id:
                        isHidden: true
                     created_at:
                        isHidden: true
                     updated_at:
                        isHidden: true
                  columnsOrder: [
                     'id'
                     'cost_type'
                     'value'
                     'date_start'
                     'date_end'
                     'description'
                  ]

         # ХАРАКТЕРИСТИКИ ИМУЩЕСТВА.
         property_features:
            styles:
               parameterColumn:
                  textAlign: 'left'
               idColumn:
                  width: 40

            getProps: ->
               columnRenderParams:
                  alignRules:
                     cells:
                        vertical: 'middle'
                        horizontal: 'center'
                     columns:
                        horizontal: 'center'
                  columns:
                     id:
                        style: @styles.idColumn
                     property_id:
                        isHidden: true
                     property_parameter_id:
                        style: @styles.parameterColumn
                  cells:
                     property_parameter_id:
                        format:
                           template: '{0} {1}'
                           arbitrary: [
                              {
                                 chain: ['reflections', 'property_parameter', 'value', 'fields', 'name', 'value'],
                              },
                              {
                                 chain: ['reflections', 'property_parameter', 'value', 'fields', 'measure', 'value'],
                                 template: '({0})'
                              }
                           ]

         # "ВЕХИ" ЖИЗНЕННОГО ЦИКЛА ИМУЩЕСТВА.
         property_milestones:
            # @const {Object} - возможные маркеры-значения для вывода в ячейке док. основания.
            _DOCUMENTAL_BASIS_PRESENT_MARKERS:
               present: 'задано'
               absent: 'отсутствует'

            styles:
               docBasisContainer:
                  display: 'flex'
                  alignItems: 'center'
               docBasisAbsent:
                  color: _COLORS.hierarchy3

            getProps: ->
               reflectionRelations = @_getReflectionRelations()

               columnRenderParams:
                  columns:
                     id:
                        isHidden: true
                     documental_basis_id:
                        onRenderCell: @_onRenderDocumentalBasis.bind(this)
                     treasury_id:
                        isHidden: true
                  columnsOrder: ['event_type']
               objectCardParams:
                  isDisplayReflections: true
                  formatRules:
                     reflections:
                        documental_basis:
                           isHidden: true
                        documents:
                           isUseParentResource: true
                           icon: 'file-text-o'
                           relations: reflectionRelations.documents

            ###*
            * Функция подготовки вывода в ячейке документального основания.
            *  В зависимости от того заданы или нет документальные основания выводит
            *  либо маркер "задано" или "не задано".
            *
            * @param {React-element} rowRef - ссылка на экземпляр строки таблицы.
            * @param {Object} record - объект записи.
            * @return {React-element}
            ###
            _onRenderDocumentalBasis: (rowRef, record) ->
               reflections = record.reflections
               markers = @_DOCUMENTAL_BASIS_PRESENT_MARKERS
               isAbsent = false

               marker =
                  if reflections? and !_.isEmpty(reflections) and
                  reflections.documental_basis? and !_.isEmpty(reflections.documental_basis)
                     markers.present
                  else
                     isAbsent = true
                     markers.absent

               containerStyle = _.assign(_.clone(@styles.docBasisContainer),
                                        isAbsent and @styles.docBasisAbsent)

               `(
                  <div style={containerStyle}>
                     {marker}
                  </div>
               )`

            ###*
            * Функция формирования параметров для считывания разрешенных
            *  связок.
            *
            * @return {Object}
            ###
            _getReflectionRelations: ->
               relationDummy =
                  primaryKey:
                     name: 'id'
                  isCollection: true
                  isReverseMultiple: false
                  polymorphicReverse: null
                  index: 1

               documentalBasisRelation = _.clone(relationDummy)
               documentRelation = _.clone(relationDummy)
               propertyMilestoneRelation = _.clone(relationDummy)

               documentRelation.reflection = 'documents'
               documentalBasisRelation.reflection = 'documental_basis'
               propertyMilestoneRelation.reflection = 'property_milestones'
               propertyMilestoneRelation.isFinal = true
               documentRelation.isReverseMultiple = true
               documentalBasisRelation.isReverseMultiple = true
               documentalBasisRelation.isCollection = false


               documents: [propertyMilestoneRelation, documentalBasisRelation, documentRelation]

         # ПРИНАДЛЕЖНОСТЬ ИМУЩЕСТВА
         property_relations:
            getProps: ->

               columnRenderParams:
                  isStrongRenderRule: true
                  columns:
                     date_expire:
                        style:
                           width: 100
                     property_relation_id:
                        onRenderCell: @_onRenderPropertyCell
                  columnsOrder: ['property_relation_id', 'date_expire']

            ###*
            * Функция рендера ячейки с имуществом принадлежности.
            *
            * @param {React-element} rowRef - ссылка на строку.
            * @param {Object} record        - запись по строке.
            ###
            _onRenderPropertyCell: (rowRef, record) ->
               reflections = record.reflections
               propertyRelation = reflections.property_relation if reflections?

               if propertyRelation?
                  renders = PropertyRegistryRenders
                  renders._onRenderPropertyCell.call(
                     renders, rowRef, propertyRelation.value)

         # АФФИЛИРОВАННОСТЬ ИМУЩЕСТВА
         property_affiliations:
            getProps: ->

               columnRenderParams:
                  isStrongRenderRule: true
                  columns:
                     date_expire:
                        style:
                           width: 100
                     property_id:
                        onRenderCell: @_onRenderPropertyCell
                  columnsOrder: ['property_id', 'date_expire']

            ###*
            * Функция рендера ячейки с имуществом принадлежности.
            *
            * @param {React-element} rowRef - ссылка на строку.
            * @param {Object} record        - запись по строке.
            ###
            _onRenderPropertyCell: (rowRef, record) ->
               reflections = record.reflections
               propertyAffiliation = reflections.property if reflections?

               if propertyAffiliation?
                  renders = PropertyRegistryRenders
                  renders._onRenderPropertyCell.call(
                     renders, rowRef, propertyAffiliation.value)

         # ПРАВООБЛАДАТЕЛИ.
         rightholders:
            getProps: ->
               renders = RightholderRegistryRenders
               reflectionRelations = @_getReflectionRelations()

               enableColumnsHeader: false
               columnRenderParams:
                  isStrongRenderRule: true
                  columns:
                     id:
                        onRenderCell: renders._onRenderRightholderCell.bind(renders)
               filterAdditionParams:
                  search:
                    fields: [
                        {
                           names: ['old_registry_number']
                           affilation: null
                        }
                        {
                           names: ['full_name', 'short_name', 'inn']
                           affilation: [
                              { reflection: 'entity', polyType: 'LegalEntity' }
                           ]
                        }
                        {
                           names: ['inn', 'snils']
                           affilation: [
                              { reflection: 'entity', polyType: 'PhysicalEntity' }
                           ]
                        }
                        {
                           names: 'all'
                           affilation: [
                              { reflection: 'users', polyType: null }
                           ]
                        }
                     ]
               objectCardParams:
                  isFreezeAtInteraction: true
                  isDisplayReflections: true
                  formatRules:
                     caption:
                        template: "Карточка правообладателя (реестр. № {0})"
                        fields: ['id']
                        icon: 'list-alt'
                     content:
                        render: renders._onRenderRightholderObjectCardContent.bind(renders)
                     reflections:
                        entity:
                           isHidden: true
                        legal_entity_type:
                           isHidden: true
                        oktmo:
                           isHidden: true
                        parent:
                           isHidden: true
                        rightholder:
                           isHidden: true
                        addresses:
                           icon: 'map-marker'
                           relations: reflectionRelations.addresses
                        documents:
                           icon: 'file-text-o'
                           relations: reflectionRelations.documents
                        analyse_released:
                           icon: 'flask'
                           relations: reflectionRelations.analyses
                           redefinedCaption: 'Проведенные анализы'
                        legal_entity_employees:
                           icon: 'street-view'
                           relations: reflectionRelations.employees
                        users:
                           icon: 'user'
                           relations: reflectionRelations.users
                        contacts:
                           icon: 'phone'
                           relations: reflectionRelations.contacts
                        billing_details:
                           icon: 'credit-card'
                           relations: reflectionRelations.billing
                        ownerships:
                           icon: 'handshake-o'
                           relations: reflectionRelations.ownerships
                           dataTableParams:
                              enableToolbar: true
                        rightholder_okveds:
                           relations: reflectionRelations.okveds
                  operationParams:
                     isUseStandard: true
                  customActions: [
                     {
                        name: 'location'
                        caption: 'Расположение'
                        icon: 'map-o'
                        keyProp: 'rightholderID'
                        content: renders._getRightholderMap()
                     },
                     {
                        name: 'analyse'
                        caption: 'Анализ'
                        icon: 'flask'
                        isHasManual: true
                        #keyProp: 'instanceID'
                        render: renders._getRightholderAnalyse
                     }
                  ]

            ###*
            * Функция формирования параметров для считывания разрешенных
            *  связок.
            *
            * @return {Object}
            ###
            _getReflectionRelations: ->
               relationDummy =
                  primaryKey:
                     name: 'id'
                  isCollection: true
                  isReverseMultiple: false
                  polymorphicReverse: null
                  index: 1

               addresses = _.clone(relationDummy)

               entityRelation = _.clone(relationDummy)
               employeesRelation = _.clone(relationDummy)
               usersRelation = _.clone(relationDummy)
               contactsRelation = _.clone(relationDummy)
               billingRelation = _.clone(relationDummy)
               ownershipsRelation = _.clone(relationDummy)
               documentSetRelation = _.clone(relationDummy)
               documentRelation = _.clone(relationDummy)
               analysesReleasedRelation = _.clone(relationDummy)
               okvedsRelation = _.clone(relationDummy)

               entityRelation.isCollection = false
               entityRelation.reflection = 'entity'
               entityRelation.polymorphicEntityName = 'LegalEntity'

               analysesReleasedRelation.polymorphicReverse = 'analyzed_object'
               #analysesReleasedRelation.polymorphicEntityName = 'analyse_released'

               employeesRelation.reflection = 'legal_entity_employees'
               usersRelation.isReverseMultiple = true
               usersRelation.reflection = 'users'
               contactsRelation.reflection = 'contacts'
               billingRelation.reflection = 'billing_details'
               ownershipsRelation.reflection = 'ownerships'
               documentRelation.reflection = 'documents'
               documentSetRelation.reflection = 'document_sets'
               analysesReleasedRelation.reflection = 'analyse_released'
               okvedsRelation.reflection = 'rightholder_okveds'

               #okvedsRelation.isReverseMultiple = true
               documentRelation.isReverseMultiple = true

               addresses.reflection = 'addresses'
               addresses.polymorphicReverse = 'addresser'

               addresses: [addresses]
               documents: [entityRelation, documentSetRelation, documentRelation]
               employees: [entityRelation, employeesRelation]
               users: [usersRelation]
               contacts: [contactsRelation]
               billing: [billingRelation]
               ownerships: [ownershipsRelation]
               analyses: [analysesReleasedRelation]
               okveds: [okvedsRelation]

         # РЕЙТИНГИ ПРАВООБЛАДАТЕЛЯ
         rightholder_ratings:
            getProps: ->
               columnRenderParams:
                  columns:
                     rightholder_id:
                        isHidden: true

         # КАЗНА
         treasuries:
            # @const {Object} - типы событий для вех жизненного цикла имущества.
            _MILESTONE_EVENT_TYPES:
               input: 'Ввод'
               output: 'Вывод'

            getProps: ->
               reflectionRelations = @_getReflectionRelations()

               columnRenderParams:
                  isStrongRenderRule: true
                  columns:
                     rightholder_id:
                        caption: 'Держатель казны'
                        style:
                           minWidth: 500
                     created_at:
                        caption: 'Дата ввода'
                        onRenderCell: @_prepareInputDate.bind(this)
                        style:
                           width: 150
                     updated_at:
                        caption: 'Дата вывода'
                        onRenderCell: @_prepareOutputDate.bind(this)
                        style:
                           width: 150
                  cells:
                     rightholder_id:
                        format:
                           template:
                              '({0}) {1}'
                           arbitrary:
                              [
                                 {
                                    chain: ['reflections', 'rightholder', 'value', 'key']
                                 },
                                 {
                                    chain: ['reflections', 'rightholder', 'value', 'reflections', 'entity', 'value', 'fields', 'short_name', 'value'],
                                    alternatives: [
                                       {chain: ['reflections', 'rightholder', 'value', 'reflections', 'entity', 'value', 'fields', 'full_name', 'value']}
                                    ]
                                 }
                              ]
               objectCardParams:
                  isDisplayReflections: true
                  formatRules:
                     reflections:
                        property_milestones:
                           isUseParentResource: true
                           icon: 'exchange'
                           relations: reflectionRelations.propertyMilestones
                           redefinedCaption: 'Ввод/вывод'
                        entity:
                           isProhibited: true

                        rightholder:
                           isUseParentResource: true
                           icon: 'user-secret'
                           relations: reflectionRelations.rightholder
                           redefinedCaption: 'Держатель казны'

            ###*
            * Функция подготовки даты ввода имущества в казну.
            *
            * @param {React-element} rowRef - ссылка на экземпляр строки таблицы.
            * @param {Object} record - объект записи.
            * @return {String}
            ###
            _prepareInputDate: (rowRef, record) ->
               @_getLocaleDateFromMilestone(
                  @_getTargetMilestone(record, @_MILESTONE_EVENT_TYPES.input)
               )

            ###*
            * Функция подготовки даты вывода имущества из казны.
            *
            * @param {React-element} rowRef - ссылка на экземпляр строки таблицы.
            * @param {Object} record - объект записи.
            * @return {String}
            ###
            _prepareOutputDate: (rowRef, record) ->
               @_getLocaleDateFromMilestone(
                  @_getTargetMilestone(record, @_MILESTONE_EVENT_TYPES.output)
               )

            ###*
            * Функция получения значения даты из записи вехи по имуществу.
            *
            * @param {Object} targetMilestone - запись по вехе.
            * @return {String}
            ###
            _getLocaleDateFromMilestone: (targetMilestone) ->
               if targetMilestone?
                  milestoneDate = targetMilestone.fields.event_date

                  if milestoneDate?
                     HelpersMixin.convertToHumanDateTime(milestoneDate.value)

            ###*
            * Функция получения целевой вехи жизненного цилка имущества по заданному
            *  типу события (ввод/вывод).
            *
            * @param {Object} record - запись.
            * @param {String} eventType - тип события вехи по имуществу.
            * @return {String}
            ###
            _getTargetMilestone: (record, eventType) ->
               reflections = record.reflections
               milestones_reflection = reflections.property_milestones if reflections?
               milestones = milestones_reflection.value if milestones_reflection?

               if milestones?
                  _.find(milestones, (milestone) ->
                     milestone.fields.event_type.value is eventType
                  )

            ###*
            * Функция формирования параметров для считывания разрешенных
            *  связок.
            *
            * @return {Object}
            ###
            _getReflectionRelations: ->
               relationDummy =
                  primaryKey:
                     name: 'id'
                  isCollection: true
                  isReverseMultiple: false
                  polymorphicReverse: null
                  index: 1

               treasuryRelation = _.clone(relationDummy)
               milestoneRelation = _.clone(relationDummy)
               rightholderRelation = _.clone(relationDummy)

               treasuryRelation.isFinal = true
               treasuryRelation.reflection = 'treasuries'
               milestoneRelation.reflection = 'property_milestones'
               rightholderRelation.reflection = 'rightholder'
               rightholderRelation.isCollection = false
               rightholderRelation.isReverseMultiple = true

               propertyMilestones: [treasuryRelation, milestoneRelation]
               rightholder: [treasuryRelation, rightholderRelation]

         # ПОЛЬЗОВАТЕЛИ СИСТЕМЫ.
         users:
            # @const {Object} - параметры для рендера иконки в ячейке поля "Пол".
            _GENDER_CELL_ICON_PARAMS:
               male:
                  value: 'Мужской'
                  icon: 'male'
               female:
                  value: 'Женский'
                  icon: 'female'
               unknown:
                  icon: 'question'
                  value: 'Пол не задан'

            # @const {Object} - параметры для рендера иконки в ячейке поля "Дата блокировки"
            _BLOCKED_CELL_PARAMS:
               icon: 'lock'
               prefix: 'Заблокирован: '

            # @const {Array} - порядок следования колонок.
            _COLUMNS_ORDER: ['id', 'email', 'login']

            # @const {String} - префикс класса иконок FontAwesome
            _FA_ICON_PREFIX: 'fa fa-'

            styles:
               idColumn:
                  width: 30
                  margin: 3
               emailColumn:
                  width: 140
               markerColumn:
                  textAlign: 'center'
                  width: 50
               genderIcon:
                  fontSize: 18
                  color: _COLORS.main
               blockedIcon:
                  fontSize: 18

            getProps: ->
               styles = @styles

               columnRenderParams:
                  isStrongRenderRule: false,
                  columns:
                     id:
                        style: styles.idColumn
                     email:
                        style: styles.emailColumn
                     gender:
                        style: styles.markerColumn
                     blocked_date:
                        style: styles.markerColumn
                  columnsOrder: this._COLUMNS_ORDER
                  cells:
                     gender:
                        handler: @_handleGenderCell.bind(this)
                     blocked_date:
                        handler: @_handleBlockedDateCell.bind(this)

            ###*
            * Обработчик параметров значения в ячейке строки по полю "Пол". Возвращает
            *  иконку.
            *
            * @param {Object} cellParams - параметры ячейки.
            * @return {React-Element} - иконка.
            ###
            _handleGenderCell: (cellParams) ->
               return unless cellParams?

               cellValue = cellParams.value
               cellIconParams = this._GENDER_CELL_ICON_PARAMS

               for valueName, params of cellIconParams
                  if cellValue is params.value
                     icon = params.icon
                     title = cellValue

               unless icon
                  unknownParams = cellIconParams.unknown

                  icon = unknownParams.icon
                  title = unknownParams.value

               `(<i style={this.styles.genderIcon}
                    title={title}
                    className={this._FA_ICON_PREFIX + icon} />)`

            ###*
            * Обработчик параметров значения в ячейке строки по полю "Дата блокировки".
            *  Возвращает иконку, если пользователь заблокирован.
            *
            * @param {Object} cellParams - параметры ячейки.
            * @return {React-DOM-Node} - иконка.
            ###
            _handleBlockedDateCell: (cellParams) ->
               return unless cellParams?

               cellValue = cellParams.value

               if cellValue?
                  cellIconParams = this._BLOCKED_CELL_PARAMS

                  `(<i style={this.styles.blockedIcon}
                       title={cellIconParams.prefix + cellValue}
                       className={this._FA_ICON_PREFIX + cellIconParams.icon} />)`

      # Реализации Selector
      Selector:
         # АДРЕС
         address_chain_id:
            getProps: ->
               recordsDosage:
                  dictionary: 30
               renderParams:
                  instance:
                     addresses:
                        template: "{0} {1}",
                        fields: ['shortname', 'formalname']
                     houses:
                        template: "д {0} {1}",
                        fields: ['housenum', 'buildnum']
                     dimension:
                        width:
                           max: 300
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 500
                              min: 200
                           height:
                              max: 300
                     columnRenderParams:
                        isStrongRenderRule: true,
                        columns:
                           shortname:
                              style: null
                           formalname:
                              style: null
                           housenum:
                              style: null
                           buildnum:
                              style: null
                           strucnum:
                              style: null
                        columnsOrder: ['housenum', 'buildnum'],
                        cells:
                           housenum:
                              enableCaption: true
                           buildnum:
                              enableCaption: true
                           strucnum:
                              enableCaption: true

         # ВАРИАНТЫ ДЛЯ АНАЛИЗА.
         analyse_variant_id:
            getProps: ->
               renderParams:
                  instance:
                     template: "({0}) {1}"
                     fields: ["level", "caption"]
                     dimension:
                        width:
                           max: 250
                  itemsContainer:
                     isInSingleLine: true
                     dimension:
                        width:
                           max: 400
                  dictionary:
                     viewType: 'hierarchy'
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 300
               dataTableParams:
                  hierarchyViewParams:
                     enableViewChildsCounter: true
                     mainDataParams:
                        template: "{0} {1}"
                        fields: ["level", "caption"]

         # БАНК(БИК)
         bank_id:
            getProps: ->
               renders = RightholderRegistryRenders

               renderParams:
                  instance:
                     template: "({0}) {1}"
                     fields: ['bik', 'name']
                     dimension:
                        width:
                           max: 250
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                     columnRenderParams:
                        isStrongRenderRule: true,
                        columns:
                           bik:
                              style:
                                 width: 'auto'
                           name:
                              width: 'auto'
                              minWidth: 100
                              padding: 0

         # ПЛАТЕЖНЫЕ РЕКВИЗИТЫ
         billing_detail_id:
            getProps: ->

               renderParams:
                  instance:
                     template: "({0}) {1}"
                     fields: ['account_type', 'account_number']
                     dimension:
                        width:
                           max: 250
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                     columnRenderParams:
                        isStrongRenderRule: true,
                        columns: ['account_type','account_number']

         # МЕТОДИКИ РАСЧЕТА
         calculation_procedure_id:
            getProps: ->
               renderParams:
                  instance:
                     template: "{0}"
                     fields: ['caption']
                     dimension:
                        width:
                           max: 250
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                     columnRenderParams:
                        isStrongRenderRule: true,
                        columns: ['caption', 'description']

         # КОНСТАНТЫ МЕТОДИК РАСЧЕТА
         calculation_constant_id:
            getProps: ->
               renderParams:
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                     columnRenderParams:
                        isStrongRenderRule: true,
                        columns: ['name', 'caption', 'description']


         # КОНТАКТЫ
         contact_id:
            getProps: ->
               renderParams:
                  instance:
                     template: "({0}) {1} {2}"
                     fields: ['contact_type', 'contact', 'person']
                     dimension:
                        width:
                           max: 350
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                     columnRenderParams:
                        isStrongRenderRule: true,
                        columns: ['contact_type', 'contact', 'person']

         # ДОКУМЕНТ
         document_id:
            getProps: ->
               renderParams:
                  instance:
                     template: "{0} № {1} от {2}"
                     fields: ['name', 'number', 'document_date']
                     dimension:
                        width:
                           max: 350
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                        columnRenderParams:
                           columns:
                              id:
                                 style:
                                    width: 50
                              document_type_id: null
                           cells:
                              document_type_id:
                                 format:
                                    template: '{0} ({1})'
                                    arbitrary: [
                                       {
                                          chain: [
                                             'reflections'
                                             'document_type'
                                             'value'
                                             'fields'
                                             'name'
                                             'value'
                                          ]
                                       }
                                       {
                                          chain: [
                                             'reflections'
                                             'document_type'
                                             'value'
                                             'fields'
                                             'document_category'
                                             'value'
                                          ]
                                       }
                                    ]
                           columnsOrder: [
                              'id'
                              'name'
                              'document_type_id'
                              'number'
                              'document_date'
                              'document_file_id'
                           ]

         # ТИП ДОКУМЕНТА
         document_type_id:
            getProps: ->
               renderParams:
                  instance:
                     template: "{0} ({1})"
                     fields: ['name', 'document_category']
                     dimension:
                        width:
                           max: 250
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200

         # КОЭФФИЦИЕНТЫ.
         factor:
            getProps: ->
               renderParams:
                  instance:
                     template: "{0}"
                     fields: ['caption']
                     dimension:
                        width:
                           max: 250
                  itemsContainer:
                     isInSingleLine: true
                     dimension:
                        width:
                           max: 400
                  dictionary:
                     viewType: 'hierarchy'
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 300
               dataTableParams:
                  hierarchyViewParams:
                     enableLeafActivateMode: true
                     enableViewChildsCounter: true
                     mainDataParams:
                        template: "{0} {1}"
                        fields: ["hierarchy", "caption"]

         # КБК
         kbk_id:
            getProps: ->
               renderParams:
                  instance:
                     template: "({0}) {1}"
                     fields: ['number', 'description']
                     dimension:
                        width:
                           max: 250
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                     columnRenderParams:
                        isStrongRenderRule: true,
                        columns:
                           number: null
                           description: null

         # СОТРУДНИКИ ЮРЛИЦА
         legal_entity_employee_id:
            getProps: ->
               renderParams:
                  instance:
                     template: "{0} {1} {2}"
                     fields: ['last_name', 'first_name', 'middle_name']
                     dimension:
                        width:
                           max: 200
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                     columnRenderParams:
                        columns:
                           legal_entity_id:
                              isHidden: true
                        cells:
                           legal_entity_post_id:
                              format:
                                 template: "{0}"
                                 arbitrary: [
                                    chain: [
                                       'reflections',
                                       'legal_entity_post',
                                       'value',
                                       'fields',
                                       'name',
                                       'value'
                                    ]
                                 ]

         # ТИП ЮРЛИЦА(ОКОПФ)
         legal_entity_type_id:
            getProps: ->
               renderParams:
                  instance:
                     dimension:
                        width:
                           max: 200
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                     columnRenderParams:
                        isStrongRenderRule: true,
                        columns:
                           id:
                              style:
                                 width: 'auto'
                           section:
                              style:
                                 width: 100
                           name:
                              style:
                                 width: 'auto'
                                 minWidth: 100
                                 padding: 0

         # Должность сотрудника юрлица
         legal_entity_post_id:
            getProps: ->
               renderParams:
                  instance:
                     dimension:
                        width:
                           max: 200
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                     columnRenderParams:
                        isStrongRenderRule: true,
                        columns:
                           id:
                              style:
                                 width: 'auto'
                           name:
                              style:
                                 width: 'auto'
                                 minWidth: 100
                                 padding: 0

         # ОКТМО
         oktmo_id:
            getProps: ->
               renderParams:
                  instance:
                     template: "({0}) {1}"
                     fields: ['section', 'name']
                     dimension:
                        width:
                           max: 250
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                     columnRenderParams:
                        isStrongRenderRule: true,
                        columns:
                           id:
                              style:
                                 width: 'auto'
                           section:
                              style:
                                 width: 100
                           name:
                              style:
                                 width: 'auto'
                                 minWidth: 100
                                 padding: 0

         # ОКВЭД
         okved_id:
            getProps: ->
               renderParams:
                  instance:
                     template: "{0} ({1})"
                     fields: ['code', 'name']
                     dimension:
                        width:
                           max: 250
                  dictionary:
                     viewType: 'hierarchy'
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
               dataTableParams:
                  hierarchyViewParams:
                     enableViewChildsCounter: true
                     mainDataParams:
                        template: "{0} {1}"
                        fields: ["code", "name"]

         # РУКОВОДСТВА.
         manual_id:
            getProps: ->
               renderParams:
                  instance:
                     template: "{0}"
                     fields: ['caption']
                     dimension:
                        width:
                           max: 250
                  itemsContainer:
                     isInSingleLine: true
                     dimension:
                        width:
                           max: 400
                  dictionary:
                     viewType: 'hierarchy'
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 300

         # ТИП ПРАВООБЛАДАНИЯ.
         ownership_type_id:
            getProps: ->
               renderParams:
                  instance:
                     dimension:
                        width:
                           max: 250
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                     columnRenderParams:
                        isStrongRenderRule: true,
                        columns:
                           id:
                              style:
                                 width: 'auto'
                           section:
                              style:
                                 width: 100
                           name:
                              style:
                                 width: 'auto'
                                 minWidth: 100
                                 padding: 0

         # ПРАВООБЛАДАНИЕ.
         ownership_id:
            getProps: ->
               renders = OwnershipRegistryRenders

               renderParams:
                  instance:
                     dimension:
                        width:
                           max: 250
                     template: '({0}) {1} {2}{3} {4}{5}'
                     arbitrary: [
                        {
                           chain: ['key']
                        }
                        {
                           chain: ['reflections', 'ownership_type', 'value', 'fields', 'name', 'value']
                        }
                        {
                           chain: ['reflections', 'property', 'value', 'key'],
                           template: '[{0}]'
                        }
                        {
                           chain: ['reflections', 'property', 'value', 'fields', 'name', 'value'],
                        }
                        {
                           chain: ['reflections', 'rightholder', 'value', 'key'],
                           template: '[{0}]'
                        }
                        {
                           chain: ['reflections', 'rightholder', 'value', 'reflections', 'entity', 'value', 'fields', 'short_name', 'value'],
                           alternatives: [
                              {
                                 chain: ['reflections', 'rightholder', 'value', 'reflections', 'entity', 'value', 'fields', 'full_name', 'value']
                              },
                              {
                                 chain: ['reflections', 'rightholder', 'value', 'reflections', 'users', 'value', '0', 'fields', 'last_name', 'value']
                              }
                           ]
                        }
                     ]
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 1200
                              min: 200
                           height:
                              max: 500
                     columnRenderParams:
                        isStrongRenderRule: true
                        columns:
                           id:
                              onRenderCell: renders._onRenderOwnershipCell.bind(renders)

         # ПЛАТЕЖИ.
         payment_id:
            getProps: ->
               renders = PaymentRegistryRenders

               renderParams:
                  instance:
                     dimension:
                        width:
                           max: 350
                     template: "платеж № {0} на сумму {1} руб."
                     arbitrary: [{chain: ['fields', 'id', 'value']}
                                 {chain: ['payment_content', 'payment_sum']}]
                  dictionary:
                        dimension:
                           common:
                              width:
                                 max: 700
                           dataContainer:
                              width:
                                 max: 700
                                 min: 200
                              height:
                                 max: 500
                        columnRenderParams:
                           isStrongRenderRule: true
                           columns:
                              id:
                                 style: renders.paymentStyles.id
                                 onRenderCell: renders._onRenderPaymentKeyCell.bind(renders)
                              documental_basis_id:
                                 style: renders.paymentStyles.document
                                 onRenderCell: renders._onRenderPaymentDocumentCell.bind(renders)
                              payment_plan_id:
                                 style: renders.paymentStyles.paymentPlan
                                 onRenderCell: renders._onRenderPaymentPlanCell.bind(renders)
                              rightholder_payer_id:
                                 style: renders.paymentStyles.rightholder
                                 onRenderCell: renders._onRenderRightholderCell.bind(renders)
                           columnsOrder: [
                              'id'
                              'documental_basis_id'
                              'payment_plan_id'
                              'rightholder_payer_id'
                           ]

         # ПЛАТЕЖНЫЙ ГРАФИК.
         payment_plan_id:
            getProps: ->
               renders = PaymentPlanRenders

               dataSource:
                  dictionary:
                     url: '/payment_plans.json'
                     filter:
                        filter: null
                     resultKey: null
                  instances:
                     resultKey: 'result_key'
               modelParams:
                  name: 'payment_plan'
               renderParams:
                  instance:
                     dimension:
                        width:
                           max: 350
                     onRender: renders._onRenderPaymentPlanInstance.bind(renders)
                  dictionary:
                     dimension:
                        common:
                           width:
                              max: 700
                        dataContainer:
                           width:
                              max: 700
                              min: 200
                           height:
                              max: 500
                     columnRenderParams:
                        isStrongRenderRule: true
                        columns:
                           id:
                              onRenderCell: renders._onRenderPaymentPlanCell.bind(renders)
                  browserSpecific:
                     dimension:
                        dataContainer:
                           height:
                              max: 700

         # ИМУЩЕСТВО.
         property_id:
            getProps: ->
               renders = PropertyRegistryRenders
               renderParams:
                  instance:
                     dimension:
                        width:
                           max: 200
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 500
                     columnRenderParams:
                        isStrongRenderRule: true
                        columns:
                           id:
                              onRenderCell: renders._onRenderPropertyCell.bind(renders)

         # ХАРАКТЕРИСТИКИ ИМУЩЕСТВА.
         property_parameter_id:
            getProps: ->

               renderParams:
                  instance:
                     dimension:
                        width:
                           max: 250
                  itemsContainer:
                     isInSingleLine: false
                     dimension:
                        width:
                           max: 400
                  dictionary:
                     viewType: 'hierarchy'
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 300
                     columnRenderParams:
                        isStrongRenderRule: true
               dataTableParams:
                  hierarchyViewParams:
                     enableLeafActivateMode: true
                     enableViewChildsCounter: true

         # ИМУЩЕСТВЕННЫЕ КОМПЛЕКСЫ.
         property_complex_id:
            getProps: ->
               renders = RightholderRegistryRenders
               renderParams:
                  instance:
                     dimension:
                        width:
                           max: 250
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                     columnRenderParams:
                        isStrongRenderRule: true
                        columns:
                           id:
                              onRenderCell: renders._onRenderRightholderCell.bind(renders)

         # ТИПЫ ИМУЩЕСТВА.
         property_types:
            getProps: ->
               renderParams:
                  instance:
                     dimension:
                        width:
                           max: 250
                  itemsContainer:
                     isInSingleLine: false
                     dimension:
                        width:
                           max: 400
                  dictionary:
                     viewType: 'hierarchy'
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 300
                     columnRenderParams:
                        isStrongRenderRule: true
                        columns:
                           name:
                              style:
                                 width: 'auto'
                                 minWidth: 100
                                 padding: 0
               dataTableParams:
                  hierarchyViewParams:
                     enableLeafActivateMode: true
                     enableSpecialActivateForInnerNodes: true
                     enableViewChildsCounter: true

         # ПРИНАДЛЕЖНОСТЬ ИМУЩЕСТВА.
         property_relation_id:
            getProps: ->
               renders = PropertyRegistryRenders
               renderParams:
                  instance:
                     dimension:
                        width:
                           max: 250
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 200
                     columnRenderParams:
                        isStrongRenderRule: true
                        columns:
                           id:
                              onRenderCell: renders._onRenderPropertyCell.bind(renders)

         # ПРАВООБЛАДАТЕЛИ
         rightholder_id:
            getProps: ->
               renders = RightholderRegistryRenders
               renderParams:
                  instance:
                     dimension:
                        width:
                           max: 250
                     onRender: renders._onRightholderInstanceRender.bind(renders)
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 400
                     columnRenderParams:
                        isStrongRenderRule: true
                        columns:
                           id:
                              onRenderCell: renders._onRenderRightholderCell.bind(renders)

         # ПОЛЬЗОВАТЕЛИ
         users:
            getProps: ->
               renderParams:
                  instance:
                     template: "({0}) {1} {2}"
                     fields: ['login', 'first_name', 'last_name']
                     dimension:
                        width:
                           max: 250
                  itemsContainer:
                     isInSingleLine: true
                     dimension:
                        width:
                           max: 700
                  dictionary:
                     dimension:
                        dataContainer:
                           width:
                              max: 800
                              min: 200
                           height:
                              max: 400
                     columnRenderParams:
                        isStrongRenderRule: true
                        columns: [
                           'login'
                           'email'
                           'first_name'
                           'middle_name'
                           'last_name'
                        ]

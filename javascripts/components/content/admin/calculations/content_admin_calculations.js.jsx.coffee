###* @jsx React.DOMResultKey ###

###* Зависимости: модули
* StylesMixin             - общие стили для компонентов.
###
StylesMixin = require('components/mixins/styles')
ContentAdminCalculationConstants = require './content_admin_calculations_constants'
ContentAdminCalculationProcedures = require './content_admin_calculations_procedures'
ContentAdminCalculationFactors = require './content_admin_calculations_factors'

###* Зависимости: компоненты
* Taber     - контейнер со вкладками.
* FormInput - поле ввода формы с валидациями.
###
Taber = require 'components/core/taber'
FormInput = require('components/core/form_input')

###* Константы
* _COMMON_PADDING - значение отступа
###
_COMMON_PADDING = StylesMixin.constants.commonPadding


ContentAdminManagementCalculations = React.createClass
   styles:
      taber:
         margin: -_COMMON_PADDING

   render: ->
      collection = [
         {
            caption: 'Процедуры методик расчета'
            icon: 'pencil-square-o'
            content: `(<ContentAdminCalculationProcedures />)`
         },
         {
            caption: 'Константы методик расчета'
            icon: 'building-o'
            content: `(<ContentAdminCalculationConstants />)`
         },
         {
            caption: 'Коэффициенты методик расчета'
            icon: 'building-o'
            content: `(<ContentAdminCalculationFactors />)`
         }
      ]

      `(
         <Taber tabCollection={collection}
                activeIndex={0}
                enableLazyMount={true}
                navigatorPosition='top'
                styleAddition={{common: this.styles.taber}} />
      )`


module.exports = ContentAdminManagementCalculations
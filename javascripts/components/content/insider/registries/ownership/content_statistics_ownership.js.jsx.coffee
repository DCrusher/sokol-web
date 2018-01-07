###* @jsx React.DOMResultKey ###

###* Зависимости: модули
* StylesMixin             - общие стили для компонентов.
###
StylesMixin = require('components/mixins/styles')
ContentStatisticsOwnershipMap = require './content_statistics_ownership_map'
ContentStatisticsOwnershipTable = require './content_statistics_ownership_table'

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


ContentStatisticsOwnerships = React.createClass
   styles:
      taber:
         margin: -_COMMON_PADDING

   render: ->
      collection = [
         {
            caption: 'Карта'
            icon: 'map-marker'
            content: `(<ContentStatisticsOwnershipMap />)`
         }
         {
            caption: 'Таблица договоров и платежей'
            icon: 'list'
            content: `(<ContentStatisticsOwnershipTable />)`
         }
      ]

      `(
         <Taber tabCollection={collection}
                activeIndex={0}
                enableLazyMount={true}
                navigatorPosition='top'
                styleAddition={{common: this.styles.taber}} />
      )`


module.exports = ContentStatisticsOwnerships
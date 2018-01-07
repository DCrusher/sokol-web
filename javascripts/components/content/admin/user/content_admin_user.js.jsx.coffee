###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin             - общие стили для компонентов.
* ContentAdminUserMain       - компонент администрирования пользователей.
* Taber                      - компонент контейнера со вкладками.
###
StylesMixin = require('components/mixins/styles')
ContentAdminUserMain = require('./content_admin_user_main')
Taber = require('components/core/taber')

###* Константы
* _COMMON_PADDING - значение отступа
###
_COMMON_PADDING = StylesMixin.constants.commonPadding

###*
* Компонент: Администрирование пользователей
###
ContentAdminUser = React.createClass
   styles:
      taber:
         margin: -_COMMON_PADDING

   render: ->
      collection = [
         {
            caption: 'Пользователи'
            icon: 'user'
            content: `(<ContentAdminUserMain />)`
         }
         {
            caption: 'Просмотр действий'
            icon: 'list-ul'
            content: `(<h3>Может быть когда-нибудь...</h3>)`
         }
      ]

      `(
         <Taber tabCollection={collection}
                activeIndex={0}
                navigatorPosition='top'
                styleAddition={{common: this.styles.taber}} />
       )`

module.exports = ContentAdminUser
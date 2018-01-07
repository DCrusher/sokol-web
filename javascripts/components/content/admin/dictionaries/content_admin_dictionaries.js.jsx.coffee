###* @jsx React.DOMResultKey ###

###* Зависимости: модули
* StylesMixin             - общие стили для компонентов.
###
StylesMixin = require('components/mixins/styles')
ContentAdminDictionariesPropertyTypes = require './content_admin_dictionaries_property_types'
ContentAdminDictionariesDocumentTypes = require './content_admin_dictionaries_document_types'
ContentAdminDictionariesOwnershipTypes = require './content_admin_dictionaries_ownership_types'
ContentAdminDictionariesPropertyParameters = require './content_admin_dictionaries_property_parameters'

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


ContentAdminManagementDictionaries = React.createClass
   styles:
      taber:
         margin: -_COMMON_PADDING

   render: ->
      collection = [
         {
            caption: 'Типы имущества'
            icon: 'building-o'
            content: `(<ContentAdminDictionariesPropertyTypes />)`
         }
         {
            caption: 'Параметры имущества'
            icon: 'pencil-square-o'
            content: `(<ContentAdminDictionariesPropertyParameters />)`
         },
         {
            caption: 'Типы документов'
            icon: 'file-text'
            content: `(<ContentAdminDictionariesDocumentTypes />)`
         },
         {
            caption: 'Типы правоотношений'
            icon: 'comments-o'
            content: `(<ContentAdminDictionariesOwnershipTypes />)`
         }
      ]

      `(
         <Taber tabCollection={collection}
                activeIndex={0}
                enableLazyMount={true}
                navigatorPosition='top'
                styleAddition={{common: this.styles.taber}} />
      )`


module.exports = ContentAdminManagementDictionaries
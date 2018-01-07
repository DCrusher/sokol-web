###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin         - общие стили для компонентов
* HelpersMixin        - функции-хэлперы для компонентов
* UserStore          - flux-хранилище действий с профилем
* UserActionCreators - модуль создания действий с профилем
* FluxConstants  - flux-константы
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
UserStore = require('./../../stores/user_store')
UserActionCreator = require('./../../actions/user_action_creators')
FluxConstants = require('./../../constants/flux_constants')

###* Зависимости: компоненты
* Button            - кнопка.
* Taber             - контейнер со вкладками.
* StreamContainer   - "потоковый" контейнер.
* DynamicForm       - компонент динамической формы ввода.
* StaticForm        - компонент статической формы.
* ArbitraryArea     - произвольная область.
###
Button = require('components/core/button')
Taber = require('components/core/taber')
StreamContainer = require('components/core/stream_container')
DynamicForm = require('components/core/dynamic_form')
StaticForm = require('components/core/static_form')
ArbitraryArea = require('components/core/arbitrary_area')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding

# Типы событий
ActionTypes = FluxConstants.ActionTypes

###* Компонент: контент редактирования профиля
*
* @props:
* @state:
*     {String} buttonChangePasswdCaption - текст кнопки открытия/скрытия панели редактирования
*                                            профиля.
*     {Boolean} arbitraryAreaTargrt      - флаг откртия/скрытия панели редактирования пароля
*                                            по-умолчанию true.
###
Profile = React.createClass

   # @const {Object} - коллекция страниц конфигурации
   _SETTING_PAGES:
      personal:
         name: 'personal'
         title: 'Данные пользователя'
         caption: 'Данные пользователя'
         icon: 'user'
      exchangeFormat:
         name: 'exchange'
         title: 'Параметры форматов обмена'
         caption: 'Форматы обмена'
         icon: 'exchange'

   # @const {String} - наименование модели форматов обмена.
   _EXCHANGE_CONSTANT_MODEL: 'exchange_constant'

   # @const {String} - наименование модели пользователей.
   _USER_MODEL: 'user'

   # @const {Object} - параметры заголовков триггера для потокового контейнера.
   _CHANGE_PASSWORD_CONTAINER_PARAMS:
      hidden:
         caption: 'Сменить пароль'


   # @const {Object} - параметры полей для статической формы смены пароля
   _STATIC_FORM_FIELDS_FOR_PASSWD: [
      {
         type: 'password'
         caption: 'Введите текущий пароль'
         name: 'current_password'
         value: ''
      },
      {
         type: 'password'
         caption: 'Введите новый пароль'
         name: 'password'
         value: ''
      },
      {
         type: 'password'
         caption: 'Повторите новый пароль'
         name: 'password_confirmation'
         value: ''
      }]

   _CAPTION_FOR_PASSWD: {
      submitCaption: 'Сменить пароль'
      resetCaption: 'Очистить поля'
   }

   _BUTTON_CHANGE_PASSWD_CAPTION: {
      open: 'Сменить пароль'
      close: 'Скрыть форму'
   }

   styles:
      taber:
         margin: -_COMMON_PADDING
      parentContainer:
         backgroundColor: 'white'
      container:
         maxWidth: 700
         margin: 'auto'
         padding: 5
         borderWidth: 1
         borderColor: _COLORS.hierarchy3
         borderStyle: 'solid'
         borderRadius: 10


   render: ->

      `(
          <Taber tabCollection={this._getSettingPages()}
                 enableLazyMount={true}
                 styleAddition={{common: this.styles.taber}}
               />
       )`

   ###*
   * Функция получения страниц настроек для контейнера со вкладками.
   *
   * @return {Array}
   ###
   _getSettingPages: ->
      settingPages = @_SETTING_PAGES
      personalPage = settingPages.personal
      exchangePage = settingPages.exchangeFormat

      personalPage.content = @_getPersonalContent()
      exchangePage.content = @_getExchangeFormatContent()

      [personalPage, exchangePage]

   ###*
   * Функция подготовки содержимого манипуляции личными данными пользователя.
   *
   * @return {React-element}
   ###
   _getPersonalContent: ->


      `(
         <div style={this.styles.container}>
            <DynamicForm modelParams={ { name: this._USER_MODEL } }
                         fluxParams={
                            {
                               store: UserStore,
                               sendInitRequest:UserActionCreator.getProfile,
                               responseInitType: ActionTypes.Profile.PROFILE_GET_RESPONSE,
                               getInitResponse: UserStore.getProfileData,
                               sendRequest: UserActionCreator.editProfile,
                               getResponse: UserStore.getProfileEditResult,
                               responseType: ActionTypes.Profile.PROFILE_EDIT_RESPONSE
                            }
                        }
                     />
            <StreamContainer content={this._getChangePasswordContent()}
                             triggerParams={this._CHANGE_PASSWORD_CONTAINER_PARAMS}
                           />
         </div>
      )`

   ###*
   * Функция подготовки содержимого манипуляции личными данными пользователя.
   *
   * @return {React-element}
   ###
   _getExchangeFormatContent: ->
      `(
         <DynamicForm mode="update"
                      modelParams={ { name: this._EXCHANGE_CONSTANT_MODEL } }
                      fluxParams={
                         {
                            store: UserStore,
                            sendInitRequest:UserActionCreator.getExchangeConstants,
                            responseInitType: ActionTypes.Profile.PROFILE_GET_EXCHANGE_CONSTANTS_RESPONSE,
                            getInitResponse: UserStore.getExchangeConstants,
                            sendRequest: UserActionCreator.setExchangeConstants,
                            getResponse: UserStore.getSetExchangeConstantsResult,
                            responseType: ActionTypes.Profile.PROFILE_SET_EXCHANGE_CONSTANTS_RESPONSE
                         }
                      }
                  />
       )`

   ###*
   * Функция, возвращающая содержимое формы смены пароля - статическую форму.
   *
   * @return {React-DOM-Node} - статическая форма.
   ###
   _getChangePasswordContent: ->
      `(
         <StaticForm fields={this._STATIC_FORM_FIELDS_FOR_PASSWD}
                     modelParams={ { name: this._USER_MODEL } }
                     submitCaption={this._CAPTION_FOR_PASSWD.submitCaption}
                     resetCaption={this._CAPTION_FOR_PASSWD.resetCaption}
                     fluxParams={
                        {
                           store: UserStore,
                           sendRequest: UserActionCreator.editPassword,
                           getResponse: UserStore.getProfileEditPasswordResult,
                           responseType: ActionTypes.Profile.PROFILE_CHP_RESPONSE,
                           successInscription: 'Успех'
                        }
                     }/>
      )`


module.exports = Profile
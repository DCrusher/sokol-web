###* Зависимости: модули
* UserStore             - flux-хранилище состояний пользовательской части.
* UserActionCreators    - модуль создания клиентских пользовательских действий.
* UserFluxConstants     - flux-константы пользовательской части.
###
UserFluxStore = require('stores/user_store')
UserActionCreators = require('actions/user_action_creators')
UserFluxConstants = require('constants/flux_constants')


ActionTypes = UserFluxConstants.ActionTypes

###*
* Модуль для хранения наборов параметров flux-инфраструктуры. Данный модуль содержит
*  стандартные параметры запроса в рамках проекта вне зависимости от компонента
*  или домена использования. Данные параметры могут быть использованы внутри
*  компонентов как константы по-умолчанию, но такой подход увеличивает связанность
*  модулей ядра и прикладного кода. Поэтому более правильный подход вынести
*  эти параметры в прикладной модуль и добавлять в определенных местах по необходимости.
*
###
module.exports =

   # Параметры для работы с пользовательскими фильтрами.
   USER_FILTERS:
      store: UserFluxStore
      init:
         sendRequest: UserActionCreators.getUserFilters
         getResponse: UserFluxStore.getUserFilters
         responseType: ActionTypes.UserFilter.USER_FILTERS_RESPONSE
      create:
         sendInitRequest: UserActionCreators.getUserFilterFields,
         responseInitType: ActionTypes.UserFilter.USER_FILTER_NEW_RESPONSE
         getInitResponse: UserFluxStore.getUserFilter
         sendRequest: UserActionCreators.createUserFilter
         getResponse: UserFluxStore.getUserFilterCreationResult
         responseType: ActionTypes.UserFilter.USER_FILTER_CREATE_RESPONSE
      update:
         sendInitRequest: UserActionCreators.getUserFilter,
         responseInitType: ActionTypes.UserFilter.USER_FILTER_GET_RESPONSE
         getInitResponse: UserFluxStore.getUserFilter
         sendRequest: UserActionCreators.editUserFilter
         getResponse: UserFluxStore.getUserFilterEditingResult
         responseType: ActionTypes.UserFilter.USER_FILTER_EDIT_RESPONSE
      delete:
         sendRequest: UserActionCreators.deleteUserFilter,
         getResponse: UserFluxStore.getUserFilterDeleteResult,
         responseType: ActionTypes.UserFilter.USER_FILTER_DELETE_RESPONSE
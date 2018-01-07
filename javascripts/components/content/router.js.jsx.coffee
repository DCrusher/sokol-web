###* @jsx React.DOM ###

###* Зависимости: модули
* keyMirror - модуль для генерации "зеркальных хэшей"
###

keyMirror = require('keymirror')

###* Зависимости: компоненты
* ContentHome         - компонент контента для домашней страницы кабинета
* ContentAdmin        - компонент контента для домашней страницы админки
* ContentAdminUser    - компонент контента бла-бла-бла (TODO дописать потом)
* ContentNotFound     - компонент контента для всех не найденных/запрещённых путей
###
ContentHome = require('./content_home')
ContentProfile = require('components/user/profile')
ContentAdmin = require('./admin/content_admin')
ContentAdminUser = require('./admin/user/content_admin_user')
ContentLandRegistry = require('./content_land_registry')
ContentNotFound = require('./content_not_found')
ContentAdminWorkplaces = require './admin/user_workplace/content_admin_user_workplaces'
ContentAdminDictionaries = require './admin/dictionaries/content_admin_dictionaries'
ContentAdminCalculations = require './admin/calculations/content_admin_calculations'
ContentAdminActions = require './admin/action/content_admin_action.js.jsx.coffee'
ContentAdminManuals = require './admin/manuals/content_admin_manuals.js.jsx.coffee'
ContentRegistryRightholders = require './insider/registries/rightholder/content_registry_rightholder.js.jsx.coffee'
ContentAnalyticsRightholders = require './insider/registries/rightholder/content_registry_rightholder_statistic.js.jsx.coffee'
ContentRegistryDocumentalBases = require './insider/registries/document/content_registry_documental_basis.js.jsx.coffee'
ContentRegistryProperties = require './insider/registries/property/content_registry_property.js.jsx.coffee'
ContentAnalyticsProperties = require './insider/registries/property/content_registry_property_chart.js.jsx.coffee'
ContentRegistryOwnerships = require './insider/registries/ownership/content_registry_ownership.js.jsx.coffee'
ContentStatisticsOwnerships = require './insider/registries/ownership/content_statistics_ownership.js.jsx.coffee'
ContentAcceptPayments = require './insider/registries/payment/content_accept_payment.js.jsx.coffee'
ContentRegistryPayments = require './insider/registries/payment/content_registry_payment.js.jsx.coffee'
OsmLeafletMap = require './insider/osm_leaflet_map'

###* Константы
* _COMMON_ROUTES       - общие пути
###

_COMMON_ROUTES = keyMirror(
   home: null
   profile: null
)

###*
* Модуль маршрутизатора. Содержит в себе все возможные пути (_allRoutes),
*     а также логику формирования путей (routes) в соответствии с переданными функциональными
*     действиями пользователя, через функцию initRouter
###
Router =
   ###*
   * @param {Array}
   * массив исходных путей. Он является основой для составления массива
   *     routes, который будет содержать только те пути, которые подходят под
   *     функциональную нагрузку конктретного пользователя, этот массив после
   *     формирования массива routes должен быть очищен
   * соглашение: домашний путь всегда 0-ой,
   *             путь для всех не найденых - последний
   ###
   _allRoutes: [
      { url: '/',                      alias: 'home',     component: ContentHome }
      { url: '/profile',               alias: 'profile',  component: ContentProfile}
      # { url: '/admin/:action',                component: ContentAdmin }
      { url: '/admin/users',                    component: ContentAdminUser }
      { url: '/admin/user_workplaces',          component: ContentAdminWorkplaces }
      { url: '/land_registry',                  component: ContentLandRegistry }
      { url: '/estate_registry',                component: ContentLandRegistry }
      { url: '/document_registry',              component: ContentLandRegistry }
      { url: '/admin/dictionaries',             component: ContentAdminDictionaries }
      { url: '/admin/calculations',             component: ContentAdminCalculations }
      { url: '/admin/manuals',                  component: ContentAdminManuals }
      { url: '/admin/user_actions',             component: ContentAdminActions }
      { url: '/rightholders',                   component: ContentRegistryRightholders }
      { url: '/rightholders/statistics',        component: ContentAnalyticsRightholders }
      { url: '/documental_bases',               component: ContentRegistryDocumentalBases }
      { url: '/properties',                     component: ContentRegistryProperties }
      { url: '/properties/statistics',          component: ContentAnalyticsProperties }
      { url: '/ownerships',                     component: ContentRegistryOwnerships }
      { url: '/ownerships/statistics',          component: ContentStatisticsOwnerships }
      { url: '/payments',                       component: ContentAcceptPayments }
      { url: '/payments/accepted',              component: ContentRegistryPayments }
      { url: '/payments/rejected',              component: ContentRegistryPayments }
      { url: '/payments/clarified',             component: ContentRegistryPayments }
      { url: '/payments/clarifying',            component: ContentRegistryPayments }
      { url: '/analytic/subject_map',           component: OsmLeafletMap }
      { url: '*',                               component: ContentNotFound }
   ]

   ###*
   * @param {Array}
   * массив путей, которые подходят под функциональную нагрузку контретного
   *     пользователя (все известные пути + фильтр по функциональным действиям
   *     = массив routes)
   * соглашение: такое же как в _allRoutes
   ###
   routes: []

   ###*
   * Параметры для удобного доступа к общим путям. Устанавливаются в
   *     ф-ии initRouter
   * @param {Object} homeRoute     - путь - домой
   * @param {Object} notFoundRoute - путь для всех не найденных
   ###
   homeRoute: null
   notFoundRoute: null

   ###*
   * Функция поиска подходящего пути из массива всех путей (_allRoutes)
   *     под пользовательское действие и добавление его в массив результирующих
   *     путей (routes)
   * @param {String} action - функциональное действие пользователя(строка с путем)
   * @return
   ###
   _findRouteAndAdd: (action) ->
      action = action.trim()
      actionPartsArr = []
      pathPartsArr = []

      # переберем весь массив известных путей, за исключением
      # первого и последнего (их проверять не нужно -
      #                       они и так должны быть везде)
      i = 1
      while i < @_allRoutes.length - 1
         route = @_allRoutes[i]
         path = route.url.trim()

         # если строки совпадают - путь и действие сопадают - оставим
         #      путь в массиве путей для дальнейшего доступа в компонентах
         # иначе разбиваем строку на элементы массива по разделителю для
         #      поэлементного сравнения
         if action == path
            @routes.push route
            break
         else
            actionPartsArr = action.split('/')
            pathPartsArr = path.split('/')

            # если длины массивов совпадают - дальше проверяем поэлементно
            #      на одинаковых позициях в массиве
            # иначе проверим элементы path, выходящих за диапазон элементов
            #       action, и если все они переменные (начинаются с ':'), то отбросим
            #       эти элементы и затем сравним уже равные массивы
            if actionPartsArr.length == pathPartsArr.length

               # если action и path равны - добавим этот путь
               if @_isRoutesEqual actionPartsArr, pathPartsArr
                  @routes.push route
                  break
            else

               # если часть элементов массива path, выходящая из диапазона элементов
               #     массива action является переменными (начинаются с ':'), то откидываем
               #     их и сравниваем два массива
               # иначе просто удаляем из массива путей данный путь
               if @_isOverflowElementsIsVariables actionPartsArr, pathPartsArr
                  # массив с элементами path подгоняем по длинне с массиву action
                  pathPartsArr.splice(actionPartsArr.length, pathPartsArr.length)

                  # если action и path равны - добавим путь
                  if @_isRoutesEqual actionPartsArr, pathPartsArr
                     @routes.push route
                     break

         i++

   ###*
   * Функция-предикат. Проверяет являются ли элементы пути, выходящие за
   *     диапазон элементов пользовательского действия переменными (начинающиеся с ':')
   * @param {Array} actionPartsArr - массив элементов пользовательского действия
   * @param {Array} pathPartsArr - массив элементов пути
   * @return {Boolean} - флаг
   ###
   _isOverflowElementsIsVariables: (actionPartsArr, pathPartsArr) ->
      isVariables = false

      # если элементов path - то имеет смысл проверять, если наоборот, то false
      if pathPartsArr.length > actionPartsArr.length
         isVariables = true

         # переберем все элементы path, выходящие за пределы action
         i = actionPartsArr.length
         while i < pathPartsArr.length

            # если хотя бы один член не содержит ":" - это уже не переменная
            if pathPartsArr[i][0] != ':'
               isVariables = false
               break
            i++

      isVariables

   ###*
   * Функция-предикат. Проверяет равны ли пользовательское действие и путь.
   *     Предварительно откидывает из пути и действия все элементы, являющиеся
   *     переменными в пути (в действии откидывет просто на той же позиции)
   *     Осуществляет проверку элементов массива действия и пути.
   *     Массивы должны быть одинаковой длинны
   * @param {Array} actionPartsArr - массив элементов пользовательского действия
   * @param {Array} pathPartsArr - массив элементов пути
   * @return {Boolean} - флаг
   ###
   _isRoutesEqual: (actionPartsArr, pathPartsArr) ->

      # переберем все элементы пути с конца
      i = pathPartsArr.length - 1
      while i > 0
         pathPart = pathPartsArr[i]

         # если часть path начинается с ":" - откидываем её и
         # также откидываем часть в action
         if pathPart[0] == ':'
            pathPartsArr.splice i, 1
            actionPartsArr.splice i, 1
         --i

      # вернем результат сравнения склеенных строк из неотброшенных
      # элементов path и action
      pathPartsArr.join('/') == actionPartsArr.join('/')

   ###*
   * Функция инициализации роутера.
   *     Подготовливает пути на основе массива переданных функциональных
   *     действий пользователя. Должна быть запущена до того, как будут
   *     назначены соответствия путей через page.js
   * @param {Array} funcActions - массив функциональных действий пользователя
   * @return
   ###
   initRouter: (funcActions) ->
      router = @
      notFoundRoute = @_allRoutes[@_allRoutes.length - 1]

      # # добавим домашний путь в массив и сохраним в параметре объекта
      i = 0
      while i < @_allRoutes.length-1
         currentRoute = @_allRoutes[i]
         if currentRoute.alias? and (currentRoute.alias is _COMMON_ROUTES.home)
            @homeRoute = currentRoute
            break
         i++

      # Добавим все общие пути в массив и сохраним в параметре объекта
      i = 0
      while i < @_allRoutes.length-1
         currentRoute = @_allRoutes[i]
         if currentRoute.alias? and _COMMON_ROUTES[currentRoute.alias]?
            @routes.push(currentRoute)
         i++

      # переберем все функциональные действия и добавим в массив
      # путей, только те которые совпадают() с действиями
      funcActions.forEach (action)->
         router._findRouteAndAdd(action.action)

      # добавим не найденный путь (404) в массив и сохраним в параметре объекта
      @routes.push(notFoundRoute)
      @notFoundRoute = notFoundRoute

      # чистим все пути (чтобы врагам не досталось =)
      @_allRoutes = undefined


module.exports = router: Router

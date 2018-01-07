###* @jsx React.DOM ###

###* Зависимости: модули
* page   - модуль роутинга на клиенте
* Router - модуль для хранения путей ассоциированных с данным пользователем
* StylesMixin    - общие стили для компонентов
###
page = require('page')
Router = require('../content/router')
StylesMixin = require('../mixins/styles')

constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding

###*
* Компонент-оболочка для маршрутизируемого контента
* @state:
*     {React-component} component - компонент, зависящий от текущего адреса
*     {Boolean} isManagerUpdated - флаг обновленного менеджера (выбран другой менеджер
*                                  имущества).
*     {Boolean} isModeChanged - флаг измененного режима работы.
*
###
ContentRouter = React.createClass
   mixins: [Router]

   styles:
      common:
         marginLeft: constants.userCabinet.sideMenuWidth + _COMMON_PADDING
         paddingTop: constants.userCabinet.headerHeight
      componentContainer:
         maxWidth: constants.userCabinet.contentMaxWidth
         margin: 'auto'
         borderRightColor: _COLORS.light
         borderRightWidth: 1
         borderRightStyle: 'solid'
         borderLeftColor: _COLORS.light
         borderLeftWidth: 1
         borderLeftStyle: 'solid'
         marginBottom: 30
         backgroundColor: _COLORS.light
         padding: _COMMON_PADDING

   componentDidMount: ->
      componentRouter = this

      @router.routes.forEach (route) ->
         url = route.url
         #Component = route.component

         page url, ((context)->
            # Сохраняем текущую страницу в sessionStorage
            sessionStorage.setItem('activePath', context.canonicalPath)
            isManagerUpdated =  componentRouter.props.isManagerUpdated
            isModeChanged = componentRouter.props.isModeChanged

            functionalActions = componentRouter.props.functionalActions
            rights = componentRouter._getRightsFromActions(functionalActions, url)

            Component = this.component

            componentRouter.setState
               component: `( <Component context={context}
                                        isManagerUpdated={isManagerUpdated}
                                        isModeChanged={isModeChanged}
                                        rights={rights}
                                      /> )`
         ).bind(route)
      #page.start()
      @_setInitialPath()

   getInitialState: ->
      # инициализируем роутер
      @router.initRouter(@props.functionalActions)

      HomeComponent = @router.homeRoute.component
      component: `(<HomeComponent />)`

   componentWillReceiveProps: (nextProps) ->
      isManagerUpdatedNext = nextProps.isManagerUpdated
      isModeChangedNext = nextProps.isModeChanged

      #if (@props.isManagerUpdated isnt isManagerUpdatedNext) or isModeChangedNext
      if isManagerUpdatedNext or isModeChangedNext
         @setState
            component: React.cloneElement(
               @state.component,
               isManagerUpdated: isManagerUpdatedNext
               isModeChanged: isModeChangedNext
            )


   render: ->
      `(
         <div style={this.styles.common}>
            <div style={this.styles.componentContainer}>
            {this.state.component}
            </div>
         </div>
       )`

   ###*
   * Достает последний url из sessionStorage и переходит на него в случае, если
   *  он существует и не равен домашней странице
   ###
   _setInitialPath: ->
      activePath = sessionStorage.activePath
      if activePath || activePath != @router.homeRoute.url
         page activePath

   ###*
   * Получение разрешений пользователя из functionalActions по url
   *
   * @param {Array} functionalActions - массив действий с правами.
   * @param {String} url - путь поступа.
   * @return {Hash} - набор прав
   ###
   _getRightsFromActions: (functionalActions, url)->
      if functionalActions?
         for i in [0...functionalActions.length]
            if functionalActions[i].action == url
               return functionalActions[i].rights


module.exports = ContentRouter

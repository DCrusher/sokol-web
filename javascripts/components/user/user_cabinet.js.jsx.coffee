###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin            - общие стили для компонентов.
* HelpersMixin           - функции-хэлперы для компонентов.
* lodash                 - модуль служебных функций.
* js-cookie              - модуль для работы с cookie
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
_ = require('lodash')
Cookie = require('js-cookie')

###* Константы
* _COLORS - цвета
###
constants = StylesMixin.constants
_COLORS = constants.color

###* Зависимости: компоненты
* CabinetHeader - Шапка кабинета
* SideMenu      - Боковое меню пользователя
* StatusBar     - Строка статуса
* ContentRouter - Контент с маршрутизацией (показывает различные
                  компоненты в зависимости от локации в браузере)
###
CabinetHeader = require('./cabinet_header')
SideMenu = require('./side_menu')
StatusBar = require('./status_bar')
ContentRouter = require('./content_router')

###* Компонент: Кабинет пользователя
* @props:
*     {String} environment - наименование среды исполнения, в котором работает приложение.
*                            Варианты:
*                            'development' - среда разработчика.
*                            'production'  - промышленная среда.
*     {Object} user        - хэш с параметрами пользователя
*     {Array} workplaces   - массив АРМов пользователя
*     {Array} images       - массив параметров изображений.
* @state
*     {String} headerCaption - название заголовка.
*     {Number} currentManagerId - идентификатор текущего менеджера.
*     {Object} currentModes - текущие активированные режимы
###
UserCabinet = React.createClass

   # @const {Object} - информация об общих путях.
   _CELL_PATH_INFORMATION:
      home:
         path: '/'
         caption: 'Главная'
      profile:
         path: '/profile'
         caption: 'Профиль'

   # @const {Object} - используемые символы.
   _CHARS:
      colon: ':'
      space: ' '

   # @const {Object} - наименование кукисов для получения значений различных
   #                   режимов.
   _COOKIES:
      manager: 'subordinate_manager'
      relevant: 'relevant_level'
      hierarchy: 'hierarchy_level'


   mixins: [HelpersMixin]

   propTypes:
      environment: React.PropTypes.string
      user: React.PropTypes.object
      workplaces: React.PropTypes.array
      images: React.PropTypes.object

   styles:
      common:
         minHeight: 600
      backgroundFiller:
         zIndex: -100
         backgroundColor: _COLORS.hierarchy4
         width: '100%'
         position: 'fixed'
         backgroungColor: _COLORS.hierarchy4
         top: 0
         bottom: 0
      wrapper:
         marginTop: StylesMixin.constants.userCabinet.headerHeight
      content:
         width: '77%'
         float: 'right'
         # marginBottom: StylesMixin.constants.userCabinet.headerHeight

   getInitialState: ->
      activePath = sessionStorage.activePath
      cellPath = @_CELL_PATH_INFORMATION
      chars = @_CHARS

      if activePath is cellPath.home.path or activePath is undefined
         headerCaption = cellPath.home.caption
      else if activePath is cellPath.profile.path
         headerCaption = cellPath.profile.caption
      else
         @props.workplaces.forEach (workplace, i, arr) ->
            if workplace?
               workplace.actions.forEach (parentAction, i, arr) ->
                  if parentAction? and parentAction.childs?
                     parentAction.childs.forEach (action, i, arr) ->
                        if action.action is activePath
                           headerCaption =
                              [
                                 parentAction.name
                                 chars.colon
                                 _.lowerCase(action.name)
                              ].join chars.space

      #headerCaption = '' unless headerCaption
      headerCaption: headerCaption
      currentManagerId: @_getInitManagerId()
      currentModes: @_getInitModes()
      isManagerUpdated: false
      isModeChanged: false

   componentWillUpdate: (nextProps, nextState) ->
      isManagerUpdated = @state.currentManagerId isnt nextState.currentManagerId
      isModeChanged = !_.isEqual(@state.currentModes, nextState.currentModes)
      newState = {}

      #if isManagerUpdated and !@state.isManagerUpdated
      if isManagerUpdated isnt @state.isManagerUpdated
         newState.isManagerUpdated = isManagerUpdated

      #if isModeChanged and !@state.isModeChanged
      if isModeChanged isnt @state.isModeChanged
         newState.isModeChanged = isModeChanged

      unless _.isEmpty newState
         @setState newState


   render: ->
      wrapperComputedStyle = @computeStyles(
                                 StylesMixin.mixins.blockToCenter,
                                 @styles.wrapper)

      `(
         <div>
            <CabinetHeader user={this.props.user}
                           caption={this.state.headerCaption}
                           currentModes={this.state.currentModes}
                           onClickNavigate={this._onClickNavigate}
                           onChangeManager={this._onChangeManager}
                           onChangeMode={this._onChangeMode}
                        />
            <SideMenu workplaces={this.props.workplaces}
                      onClickNavigate={this._onClickNavigate}
                      logo={this.props.images.sokol_logo2}
                      environment={this.props.environment}
                      isManagerUpdated={this.state.isManagerUpdated}
                    />
            <ContentRouter functionalActions={this.props.functionalActions}
                           isManagerUpdated={this.state.isManagerUpdated}
                           isModeChanged={this.state.isModeChanged}
                        />
            <StatusBar user={this.props.user} />
            <div style={this.styles.backgroundFiller}></div>
         </div>
      )`


   componentDidUpdate: (prevProps, prevState) ->
      if @state.isManagerUpdated
         @setState isManagerUpdated: false


#      <CabinetHeader user={this.props.user}
#      caption={this.state.headerCaption}
#      getHeaderCaption={this._getHeaderCaption} />
#            <div style={wrapperComputedStyle}>
#               <SideMenu workplaces={this.props.workplaces}
#                         getHeaderCaption={this._getHeaderCaption} />
#      <div style={this.styles.content}>
#      <ContentRouter functionalActions={this.props.functionalActions}/>
#      </div>
#            </div>
#      <div style={this.styles.common}>

   _getInitManagerId: ->
      managerId = Cookie.get(@_COOKIES.manager)

      if managerId?
         parseInt(managerId)


   ###*
   * Функция начального получения значения режимов работы из кукисов.
   *
   * @return {Object}
   ###
   _getInitModes: ->
      cookieNames = @_COOKIES
      relevantLevel = Cookie.get(cookieNames.relevant)
      hierarchyLevel = Cookie.get(cookieNames.hierarchy)

      relevant: relevantLevel
      hierarchy: hierarchyLevel

   ###*
   * Функция для установки значения для заголовка страницы при переходе с помощью меню.
   *
   * @param {String} caption - значение, которое необходимо записать в заголовок.
   * @return
   ###
   _onClickNavigate: (caption) ->
      @setState
         headerCaption: caption
         isManagerUpdated: false
         isModeChanged: false

   ###*
   * Функция на изменение текущего менеджера системы (выбран подчиненный менеджер
   *  или сброшен выбранный подчиненный). Запоминает текущего выбранного менеджера
   *  в состояние компонента.
   *
   * @param {Number, undefined} managerId - идентификатор менеджера.
   * @return
   ###
   _onChangeManager: (managerId) ->
      @setState currentManagerId: managerId

   ###*
   *  Обработчик на изменение на изменение режима работы.
   *
   * @param {String} modeName  - наименование режима.
   * @param {String} modeValue - значение режима.
   * @return
   ###
   _onChangeMode: (modeName, modeValue) ->
      currentModes = _.clone(@state.currentModes)
      currentModes[modeName] = modeValue

      @setState currentModes: currentModes

module.exports = UserCabinet
# window.UserCabinet = UserCabinet

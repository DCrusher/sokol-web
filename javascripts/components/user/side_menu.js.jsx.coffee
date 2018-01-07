###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin            - общие стили для компонентов
* HelpersMixin           - функции-хэлперы для компонентов
* SokolFluxConstants         - константы для пользовательской архитектуры flux.
* AnimationsMixin        - набор анимаций для компонентов
* AnimateMixin           - библиотека добавляющая компонентам
*                          возможность исользования анимации
* AssetsMixin            - модуль общих функций работы с ресурсами, привязанных к среде исполнения.
* page                   - модуль роутинга на клиенте
* lodash                 - модуль служебных функций.
* superagent             - библиотека работы с AJAX-запросами.
* keyMirror - модуль для генерации "зеркальных хэшей".
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
SokolFluxConstants = require('constants/flux_constants')
AssetsMixin = require('../mixins/assets')
AnimationsMixin = require('../mixins/animations')
AnimateMixin = require('react-animate')
page = require('page')
_ = require('lodash')
request = require('superagent')
keyMirror = require('keymirror')

###* Зависимости: компоненты
* Input             - строка ввода.
* AllocationContent - контент с выделением по переданному выражению.
###
Input = require('../core/input')
AllocationContent = require('../core/allocation_content')
Accordion = require '../core/accordion'
Label = require('components/core/label')

###* Константы
* _COLORS - цвета.
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius

###* Компонент: Боковое меню пользователя
*  @props:
*     {Object} logo              - параметры логотипа.
*     {String} environment       - наименование среды исполнения.
*     {Array} workplaces         - массив АРМов пользователя, содержащих массив
*                                  actions (действий).
*     {Boolean} isManagerUpdated - флаг обновленного менеджера (выбран другой менеджер
*                                  имущества).
*     {Function} onClickNavigate - обработчик клика по пункту меню. Аргументы:
*                {String} caption - заголовок действия.
*  @state:
*   {String} searchExpression - строка с выражением поиска.
*   {Object} managerParams    - параметры текущего правообладателя-менеджера.
###
SideMenu = React.createClass

   _SEARCH_PLACEHOLDER: 'введите название раздела...'
   _ACTIONS_ARE_NOT_ASSIGNED: 'Действия не назначены'
   _EMPTY_FUNCTIONAL_ACTION_LABEL: 'Функциональные действия отсутствуют'

   # @const {String} - всплывающее пояснение на наименовании текущего менеджера.
   _CURRENT_MANAGER_TITLE: 'Текущий менеджер'

   # @const {Object} - параметры для лидирующей иконки-лейбла в поле поиска
   #                   (для переопределения цвета)
   _SEARCH_INPUT_LEAD_ICON_PARAMS:
      type: 'ordinaryLight'

   # @const {Object} - используемые символы.
   _CHARS:
      colon: ':'
      space: ' '

   # @const {Object} - возможные состояния аккордеона.
   _ACCORDION_STATES: keyMirror(
      expanded: null
      collapsed: null
      default: null
   )

   # @const {Object} - параметры для ссылки на сайт менеджера
   _MANAGER_WEB_SITE_LINK_PARAMS:
      icon: 'external-link',
      isLink: true
      title: 'Открыть сайт правообладателя'
      type: 'info'
      isWithoutPadding: true

   mixins: [HelpersMixin, AssetsMixin]

   propTypes:
      environment: React.PropTypes.string
      user: React.PropTypes.object
      workplaces: React.PropTypes.array
      logo: React.PropTypes.object
      onClickNavigate: React.PropTypes.func

   styles:
      common:
         position: 'fixed'
         width: constants.userCabinet.sideMenuWidth
         backgroundColor: _COLORS.hierarchy2
         top: 0
         bottom: 0
         textAlign: 'center'
      logoContainer:
         backgroundColor: _COLORS.mainDark
         height: constants.userCabinet.headerHeight
      navigateContainer:
         height: '100%'
         overflow: 'auto'
      navigatorContent:
         marginBottom: 120
      searchInputContainer:
         borderRadius: 0
         borderColor: _COLORS.hierarchy3
         borderWidth: 0
         backgroundColor: _COLORS.transparent
      searchInputInput:
         color: _COLORS.hierarchy3
         backgroundColor: _COLORS.transparent
      searchInputClearButton:
         color: _COLORS.hierarchy3
      workplaceHeaderCommon:
         backgroundColor: _COLORS.hierarchy2
         color: _COLORS.light
         paddingTop: 10
         paddingBottom: 10
         borderWidth: 0
         borderStyle: 'none'
         margin: 0
      workplaceHeaderHighlightBack:
         backgroundColor: _COLORS.mainDark
         color: _COLORS.third
         borderWidth: 0
         borderStyle: 'none'
      webSiteLinkLabel:
         paddingLeft: _COMMON_PADDING
      workplaceContent:
         padding: 0
         marginTop: 1
      actionHeaderCommon:
         fontSize: 13
         margin: 0
         borderWidth: 0
         borderStyle: 'none'
      actionContent:
         fontSize: 12
         padding: 0
      actionContentItem:
         padding: 10
         paddingLeft: 20
      actionContentItemIcon:
         fontSize: 16
         marginLeft:-13
         paddingRight: 10
         minWidth: 15
      searchInput:
         padding: _COMMON_PADDING
      accordion:
         overflowY: 'auto'
      userActionMessage:
         fontSize: 11
         color: _COLORS.hierarchy3
      singleWorkplaceLabel:
         fontSize: 11
         color: _COLORS.hierarchy3
         textAlign: 'right'
         padding: _COMMON_PADDING
      managerLable:
         marginTop: 150
      managerName:
         margin: 'auto'
         marginBottom: 10
         padding: _COMMON_PADDING
         color: _COLORS.light
         fontSize: 'smaller'
         borderWidth: 1
         borderColor: _COLORS.light
         borderStyle: 'solid'
         borderRadius: _COMMON_BORDER_RADIUS
         maxWidth: 220

      managerLogotype:
         maxHeight: 180
         maxWidth: 180
         # position: 'absolute'
         # bottom: 0
         # width: '100%'
         # height: 200
         # background: 'gray'

   getInitialState: ->
      searchExpression: ''
      accordionMenuState: 'default'
      childAccordionStatus: 'default'
      workplaces: @_getWorkplaces()
      managerParams: null

   componentWillReceiveProps: (nextProps) ->
      if nextProps.isManagerUpdated
         @_getManagerParamsFromAPI()

   render: ->
      styles = @styles

      `(
         <aside style={styles.common}>
            <div style={styles.logoContainer}>
               <img style={styles.logo}
                    src={this._getAssetPath(this.props.logo)}/>
            </div>
            <div style={styles.searchInput}>
               <Input placeholder={this._SEARCH_PLACEHOLDER}
                      isSearch={true}
                      leadIcon={this._SEARCH_INPUT_LEAD_ICON_PARAMS}
                      styleAddition={
                         {
                            container: styles.searchInputContainer,
                            input: styles.searchInputInput,
                            clear: styles.searchInputClearButton
                         }
                      }
                      onChange={this._onChangeSearch}
                   />
            </div>
            <nav style={styles.navigateContainer}>
               <div style={styles.navigatorContent}>
                  {this._getMenu()}
                  {this._getManagerLable()}
               </div>
            </nav>
         </aside>
       )`

   componentDidMount: ->
      @_getManagerParamsFromAPI()

   ###*
   * @return {Object} - возвращает массив АРМов, в которых существуют действия
   ###
   _getWorkplaces: ->
      workplaces = @props.workplaces
      choicestWorkplaces = []

      for workplace in workplaces
         workplaceActions = workplace.actions

         if workplaceActions? and workplaceActions.length
            choicestWorkplaces.push workplace

      choicestWorkplaces

   ###*
   * В зависимости от количества АРМов с действиями возвращает:
   *     - Либо строчку 'Действия не назначены'
   *     - Либо заголовок одного АРМа с действиями в виде аккордеонов
   *     - Либо несколько групп действий в виде аккордеонов в одном главном аккордеоне
   * @return {Object} - Возвращает меню, либо фразу о его отсутствии
   ###
   _getMenu: ->
      switch @state.workplaces.length
         when 0
            `(
               <p style={this.styles.userActionMessage}>
                  {this._ACTIONS_ARE_NOT_ASSIGNED}
               </p>
            )`
         when 1
            `(
               <div>
                  <div style={this.styles.singleWorkplaceLabel}>
                     {this.state.workplaces[0].name}
                  </div>
                  {this._getAccordionContent()}
               </div>
            )`
         else
            `(
               <Accordion  isIndependent = {false}
                           status = {this.state.accordionMenuState}
                           onExpandAllComplete = {this._onExpandAllComplete}
                           hasChildren = {true}
                           items={this._getAccordionContent()}
                           styleAddition={
                              {
                                 header: {
                                    common: this.styles.workplaceHeaderCommon,
                                    highlightBack: this.styles.workplaceHeaderHighlightBack
                                 },
                                 content: this.styles.workplaceContent
                              }
                           }
                        />
            )`

   ###*
   * Функция, передающая данные для главного аккордеона, или (при его отсутствии) - один дочерний
   *  аккордеон
   * @return {Object} - данные для Аккордеона, или один дочерний Аккордеон
   ###
   _getAccordionContent:->
      sideMenu = this
      itemsContent = new Object
      accordionItems = @state.workplaces.map (workplace, index) ->
         itemsContent = workplace.actions.map (action, index) ->

            header: `(<AllocationContent content={action.name}
                           expression={sideMenu.state.searchExpression}
                           highlightColor={_COLORS.highlight1} />)`
            isOpened: true if index is 0
            leadIcon: action.icon
            content: sideMenu._getActionContent(action)
         header: `(<AllocationContent content={workplace.name}
                              expression={sideMenu.state.searchExpression}
                              highlightColor={_COLORS.highlight1} />)`
         content: `(<Accordion isIndependent = {false}
                               items={itemsContent}
                               status={sideMenu.state.accordionMenuState}
                               styleAddition={
                                 {
                                    header: {
                                       common: sideMenu.styles.actionHeaderCommon,
                                       highlightBack: sideMenu.styles.workplaceHeaderHighlightBack
                                    },
                                    content: sideMenu.styles.actionContent,
                                    contentItem: {
                                       common: sideMenu.styles.actionContentItem,
                                       icon: sideMenu.styles.actionContentItemIcon
                                    }
                                 }
                               }
                            />)`
         leadIcon: workplace.icon
         isOpened: true if index is 0

      # Если в компоненте присутствует только одно пользовательское действие, то передадим только
      #  первый дочерний аккордеон, иначе передадим все дочерние аккордеоны и их заголовки в массиве
      if @state.workplaces.length is 1
         accordionItems[0].content
      else
         accordionItems

   ###*
   * Функция получения содержимого пользовательского действия - если заданы
   *  дочерние дейсвтия - формирует набор параметров для дочерних действий,
   *  - иначе выводит заглушку.
   *
   * @param {Object} parentAction - параметры родительского действия.
   * @return {React-element}
   ###
   _getActionContent: (parentAction) ->
      itemChilds = parentAction.childs
      sideMenu = this
      chars = @_CHARS

      if itemChilds? and itemChilds.length
         parentAction.childs.map (action, index) ->
            caption:
               `(<AllocationContent content={action.name}
                                    expression={sideMenu.state.searchExpression}
                                    highlightColor={_COLORS.highlight1} />)`
            fullCaption:
               [
                  parentAction.name
                  chars.colon
                  _.lowerCase(action.name)
               ].join chars.space
            icon: action.icon
            title: action.description
            value: action.action
            onActivate: sideMenu._onClickNavigate
      else
         `( <p style={this.styles.userActionMessage}>
               {sideMenu._EMPTY_FUNCTIONAL_ACTION_LABEL}
            </p>)`


   ###*
   * Функция получения лейбла правообладателя-текущего менеджера.
   *
   * @return {Object} - стиль для обертки Аккордеона
   ###
   _getManagerLable: ->
      managerParams = @state.managerParams

      if managerParams? and !_.isEmpty managerParams
         logotypeParams = managerParams.logotype

         logotypeElement =
            if logotypeParams?
               `(
                   <img style={this.styles.managerLogotype}
                        title={managerParams.fullName}
                        src={logotypeParams.file} />
                )`
         managerName = managerParams.shortName or managerParams.fullName

         webSiteLink =
            if managerParams.webSite?
               `(
                  <Label {...this._MANAGER_WEB_SITE_LINK_PARAMS}
                         styleAddition={{common: this.styles.webSiteLinkLabel}}
                         onClick={this._onClickOpenManagerWebSite}
                     />
                )`

         `(
            <div style={this.styles.managerLable}>
               <div style={this.styles.managerName}
                    title={this._CURRENT_MANAGER_TITLE} >
                  {managerName}
                  {webSiteLink}
               </div>
               {logotypeElement}
            </div>
         )`

   ###*
   * Обработчик клика на ссылку сайта менеджера.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickOpenManagerWebSite: (event) ->
      event.stopPropagation()
      window.open(@state.managerParams.webSite)

   ###*
   * Функция отправки запроса на получение логотипа правообладателя текущего
   *  пользователя. В случае успешного получения ссылок на логотип - устанавливает
   *  устанавливает параметры в состояние.
   *
   * @return
   ###
   _getManagerParamsFromAPI: ->
      sideMenu = this

      request.get(SokolFluxConstants.APIEndpoints.PERSONAL_MANAGER)
             .set('Accept', SokolFluxConstants.AcceptTypes.json)
             .end (error, res) ->
                json = JSON.parse(res.text)

                #if json? and !_.isEmpty(json)
                sideMenu.setState managerParams: json

   ###*
   * Функция, создающая оfграниченную высоту аккордеонаю через стили.
   *
   * @return {Object} - стиль для обертки Аккордеона
   ###
   _getAccordionStyle: ->
      height =
         maxHeight: $( window ).height() * 0.75
      @computeStyles @styles.accordion,
                     height

   ###*
   * Обработчик события на ввод значение в поле поиска.
   *   Устанавливает состояние аккордеона в 'expanded', если поле не
   *     пустое, и ставит дефолтное состояние аккордеонам в иных случаях.
   * @return
   ###
   _onChangeSearch: (searchExpression) ->
      accordionStates = @_ACCORDION_STATES
      expandedState = accordionStates.expanded
      newState =
         searchExpression: searchExpression

      if searchExpression? and !_.isEmpty(searchExpression)
         if @state.accordionMenuState isnt expandedState
            newState.accordionMenuState = expandedState
      else
         newState.accordionMenuState = accordionStates.default

      @setState newState

   ###*
   * Функция, срабатывающая по завершению раскрытия всех элементов главного
   *  аккордеона. По её выполнению запускается функция раскрытия вложенных аккордеонов.
   * @return
   ###
   _onExpandComplete: ->
      @setState
         childAccordionStatus: @_ACCORDION_STATES.expanded

   ###*
   * Обработчик клика по пункту меню.
   *   Выполняет навигацию, используя модуль Page
   *
   * @param {Object} navItem - параметры элемента навигации(value, caption).
   * @return
   ###
   _onClickNavigate:(navItem) ->
      if navItem and !_.isEmpty(navItem)
         onClickNavigateHandler = @props.onClickNavigate

         page navItem.value
         @props.onClickNavigate navItem.fullCaption if onClickNavigateHandler?


module.exports = SideMenu
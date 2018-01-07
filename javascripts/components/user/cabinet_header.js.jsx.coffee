###* @jsx React.DOM ###

###* Зависимости
* HelpersMixins         - примесь с функциями-хэлперами для компонентов.
* StylesMixin           - примесь со стилями компонентов.
* SessionActionCreators - flux-создатель пользовательских действий для аутентификации.
* SokolFluxConstants    - константы архитектуры flux.
* AnimationsMixin       - набор анимаций для компонентов.
* AnimateMixin          - библиотека добавляющая компонентам.
*                         возможность исользования анимации.
* keymirror             - модуль для генерации "зеркального" хэша.
* page                  - модуль роутинга на клиенте
* superagent            - библиотека работы с AJAX-запросами.
* js-cookie             - модуль для работы с cookie
###
HelpersMixin = require('../mixins/helpers')
StylesMixin = require('../mixins/styles')
SessionActionCreators = require("actions/session_action_creators")
SessionStore = require("stores/session_store")
SokolFluxConstants = require('constants/flux_constants')
AssetsMixin = require('../mixins/assets')
AnimateMixin = require('react-animate')
AnimationsMixin = require('../mixins/animations')
keyMirror = require('keymirror')
page = require('page')
request = require('superagent')
Cookie = require('js-cookie')

###* Зависимости: компоненты
* ArbitraryArea - произвольная область.
* Button            - кнопка.
###
ArbitraryArea = require('components/core/arbitrary_area')
Button = require('components/core/button')
DropDown = require('components/core/dropdown')
Switcher = require('components/core/switcher')
#Flasher = require('../core/flasher.js.jsx.coffee')

###* Зависимости: прикладные компоненты.
* ManualViewer - просмотрщик руководств.
###
ManualViewer = require('components/application/manual_viewer')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = _CP = StylesMixin.constants.commonPadding
_COMMON_BORDER_RADIUS = StylesMixin.constants.commonBorderRadius


###* Компонент: Верхняя область личного кабинета пользователя(шапка).
* Содержит меню основных действия пользователя, логотип, область уведомлений.
*
* @props:
*     {Object} user               - хэш с данными пользователя
*     {String} caption            - надпись в заголовке.
*     {Object} currentModes       - хэш с текущими режимами личного кабинета.
*     {Function} onClickNavigate  - функция, вызываемая по переходу на страницу.
*                                   Аргументы:
*                                     {String} caption - заголовок действия.
*     {Function} onChangeManager  - функция на изменение выбранного подчиненного
*                                   менеджера. Аргументы:
*                                      {Number, undefined} managerId - идентификатор выбранного
*                                                                      менеджера.
*     {Function} onChangeMode     - функция на изменение режима работы.
* @state:
*     {React-element} userMenuTarget     - целевой узел пользовательского меню.
*     {Boolean} isMenuShown               - флаг показа меню.
*     {Object} avatarParams               - параметры аватарки.
*     {Array<Object>} subordinateManagers - коллекция параметров подчиненных менеджеров.
###
CabinetHeader = React.createClass
   # @const {String} - Заголовок при переходе на страницу профиля.
   _CAPTION_PROFILE: 'Профиль'

   # @const {Object} - используемые символы.
   _CHARS:
      space: ' '

   # @const {Object} - параметры для кнопки-селектора подчиненных
   #                   организаций-менеджеров
   _SUBORDINATE_MANAGER_SELECTOR_PARAMS:
      isComplex: true
      isLinkSelector: true
      enableClear: true
      title: 'подчиненная структура'
      clearTitle: 'выйти из режима работы подчиненной структуры'
      emptyValue: 'выбрать подчиненную структуру'
      searchPlaceholder: 'введите часть наименования'
      clearButtonParams:
         icon: 'home'

   # @const {Object} - параметры для хранения cookies.
   _COOKIE_PARAMS:
      subordinateManager:
         name: 'subordinate_manager'
         params:
            expires: 1
      relevant:
         name: 'relevant_level'
         params:
            expires: 1
      hierarchy:
         name: 'hierarchy_level'
         params:
            expires: 1

   # @const {Object} - наименования различных режимов работы.
   _MODES: keyMirror(
      relevant: null
      hierarchy: null
   )

   # @const {Object} - параметры различных режимов работы личного кабинета.
   #     relevant  - режим работы актуальные/архивные.
   #     hierarchy - режим уровня иерархии.
   _MODE_POSITIONS:
      relevant: [
            {
               name: 'actual'
               caption: 'Актуальные'
               title: 'Режим отображения актуальных данных'
               icon: 'check'
               isActivated: true
               isMain: true
            }
            {
               name: 'archival'
               caption: 'Архивные'
               title: 'Режим отображения архивных данных'
               icon: 'archive'
            }
         ]
      hierarchy: [
            {
               name: 'flat'
               caption: 'Плоский'
               title: 'Режим отображения данных по текущему менеджеру'
               icon: 'flag-o'
               isActivated: true
               isMain: true
            }
            {
               name: 'management'
               caption: 'Совместный'
               title: 'Режим отображения данных по текущему менеджеру и всем непосредственным подчиненным структурам'
               icon: 'sitemap'
            }
            {
               name: 'hierarchy'
               caption: 'Иерархия'
               title: 'Режим отображения данных по текущему менеджеру и всем подчиненным структурам на всех уровнях подчинения'
               icon: 'sort-amount-desc'

            }
         ]

   # @const {String} - строка для доступа.
   _VALUE_KEY: 'value'

   # @const {Object} - элементы меню.
   _MENU_ITEMS:
      profile:
         title: 'Профиль'
         icon: 'cog'
         value: 'profile'
         link: '/profile'
      manual:
         title: 'Открыть руководство'
         icon: 'book'
         value: 'manual'
      signout:
         title: 'Выход'
         icon: 'sign-out'
         value: 'signout'


   # @const {Number} - размер для переключателя режимов.
   _SWITCHER_SIZE: 25

   mixins: [HelpersMixin, AnimateMixin, AssetsMixin]

   styles:
      common:
         backgroundColor: StylesMixin.constants.color.main
         position: 'fixed'
         top: 0
         right: 0
         left: 0
         color: _COLORS.light
         zIndex: 100
         marginLeft: constants.userCabinet.sideMenuWidth
      menuItem:
         padding: 5
         fontSize: 16
         width: 95
         whiteSpace: 'nowrap'
#         color: '#C6E9AF'
      avatarImage:
         maxWidth: 46
         maxHeight: 46
         verticalAlign: 'middle'
         borderRadius: _COMMON_BORDER_RADIUS
      cellWithPadding:
         padding: _COMMON_PADDING
      avatarCap:
         fontSize: 36
         verticalAlign: 'middle'
      menuItemCaption:
         padding: _COMMON_PADDING
      logo:
         display: 'block'
      subordinateManagersCell:
         paddingRight: 10
      logoCell:
         width: 210
      userCell:
         whiteSpace: 'nowrap'
         paddingLeft: _COMMON_PADDING
      userName:
         display: 'inline-block'
         overflow: 'hidden'
         maxWidth: 150
         textOverflow: 'ellipsis'
         fontSize: 14
         padding: _COMMON_PADDING
         verticalAlign: 'middle'
      fillerCell:
        width: '100%'
      navBar: StylesMixin.mixins.blockToCenter
      headerContentContainer:
         width: '100%'
         height: constants.userCabinet.headerHeight
      item:
         cursor: 'pointer'
         marginRight: 8
         marginLeft: 8
      actionName:
         whiteSpace: 'nowrap'
         color: _COLORS.third
         margin: '0 5px 0 15px'
         #lineHeight: '3rem'
#      item_left:
#         float: 'right'
      highlight:
         color: _COLORS.highlight1
      subordinateManagersSelector:
         fontSize: 14
         color: _COLORS.third
      subordinateManagersCaptionContainer:
         overflow: 'hidden'
         textOverflow: 'ellipsis'
         maxWidth: 350
      subordinateManagersSelectorEmpty:
         fontSize: 13
         color: _COLORS.hierarchy4
      subordinateManagersItem:
         overflow: 'hidden'
         textOverflow: 'ellipsis'
         maxWidth: 350


   # Таймаут на потерю фокуса меню пользователя (для возможноти перехвата по клику)
   _blurMenuTimeout: null

   propTypes:
      user: React.PropTypes.object
      caption: React.PropTypes.string
      onClickNavigate: React.PropTypes.func
      onChangeManager: React.PropTypes.func

   getInitialState: ->
      userMenuTarget: {}
      avatarParams: null
      managementStructure: null
      isManualShown: false

   render: ->
      computedStyles = @computeStyles @styles.common,
                       @getAnimatedStyle('animate-highlight')
      modes = @_MODES
      user = @props.user
      menuItems = @_MENU_ITEMS

      #<img src='assets/sokol_logo2.svg'/>

               #       <span style={this.styles.item}></span>
               # <img src='assets/sokol_logo2.svg'/>
               # <span style={this.computeStyles(this.styles.item, this.styles.item_left)}
               #       ref='userActivityButton'
               #       onClick={this._onClickUserMenu}   >
               #    {this.props.user.login}
               # </span>

      userName =
         [
            user.first_name
            user.last_name
         ].join @_CHARS.space

      `(
         <header style={this.styles.common}>
            <nav>
               <table style={this.styles.headerContentContainer}
                      cellPadding='0'>
                  <tbody>
                     <tr>
                        <td>
                           <h3 style={this.styles.actionName}>
                              {this.props.caption}
                           </h3>
                        </td>
                        <td style={this.styles.fillerCell}>
                        </td>

                        {this._getModeSwitcherCell(modes.relevant)}
                        {this._getModeSwitcherCell(modes.hierarchy)}

                        {this._getSubordinateManagersCell()}

                        <CabinetHeaderMenuItem onClick={this._onClickMenuItem}
                                               {...menuItems.profile}
                                             />
                        <CabinetHeaderMenuItem onClick={this._onClickMenuItem}
                                               {...menuItems.manual}
                                             />
                        <CabinetHeaderMenuItem onClick={this._onClickMenuItem}
                                               {...menuItems.signout}
                                             />
                        <td style={this.styles.userCell}>
                           {this._getAvatar()}
                           <span style={this.styles.userName}
                                 ref='userActivityButton'
                                 onClick={this._onClickUserMenu}
                                 title={userName} >
                               {userName}
                           </span>
                        </td>
                     </tr>
                  </tbody>
               </table>
            </nav>
            <CabinetHeaderUserMenu userData={this.props.user}
                                   menuTarget={this.state.userMenuTarget}
                                   onHide={this._onHideMenu} />
            {this._getManualViewer()}
         </header>
      )`

   componentDidMount: ->
      $item = $(ReactDOM.findDOMNode(this))
      $item.hover(@_hoverIn, @_hoverOut)
      @_getAvatarFromAPI()
      @_getManagementStructureFromAPI()

   ###*
   * Функция формирования ячейки с переключателем режима работы личного кабинета.
   *
   * @param {String} modeName - наименование режима.
   * @return {React-element}
   ###
   _getModeSwitcherCell: (modeName) ->
      modePositions = @_MODE_POSITIONS[modeName]
      `(
         <td style={this.styles.cellWithPadding}>
            <Switcher positions={modePositions}
                      enableActivatedCaption={true}
                      enableIcons={true}
                      size={this._SWITCHER_SIZE}
                      activatedIndex={
                        this._getActivatedModeIndex(modePositions,
                                                    modeName)
                      }
                      onChange={this._onChangeMode.bind(this, modeName)}
                    />
         </td>
      )`

   ###*
   * Функция формирования просмотрщика руководств если задано состояние показа
   *  руководства.
   *
   * @param {String} modeName - наименование режима.
   * @return {React-element}
   ###
   _getManualViewer: ->
      if @state.isManualShown
         `(
            <ManualViewer isShown={true}
                          onHide={this._onHideManualViewer}
                     />
         )`


   ###*
   * Функция формирования ячейки с элементов-селектором подчиненных
   *
   * @return {React-element}
   ###
   _getSubordinateManagersCell: ->
      subordinateManagers = @state.subordinateManagers
      styles = @styles

      ###*
      * Функция получения индекса выбранного менеджера из коллекции. Осуществляет
      *  выбор индекса, если задан выбранный менеджер в куках.
      *
      * @param {Array<Object>} managersCollection - коллекция менеджеров.
      * @return {Number}
      ###
      getSelectedManagerIndexInCollection = ((managersCollection) ->
         subordinateManager = Cookie.get(@_COOKIE_PARAMS.subordinateManager.name)

         if subordinateManager?
            _.findIndex(managersCollection,
                        [@_VALUE_KEY, parseInt(subordinateManager)])
      ).bind(this)

      if subordinateManagers? and !_.isEmpty subordinateManagers
         selectedManagerIndex =
             getSelectedManagerIndexInCollection(subordinateManagers)
         initItem =
            if ~selectedManagerIndex
               key: selectedManagerIndex

         `(
             <td style={this.styles.subordinateManagersCell}>
                <DropDown list={subordinateManagers}
                          initItem={initItem}
                          styleAddition={
                             {
                                selector: {
                                   captionContainer: styles.subordinateManagersCaptionContainer,
                                   selected: styles.subordinateManagersSelector,
                                   empty: styles.subordinateManagersSelectorEmpty
                                },
                                item: styles.subordinateManagersItem
                             }
                          }
                          onSelect={this._onSelectSubordinateManager}
                          onClear={this._onClearSubordinate}
                          {...this._SUBORDINATE_MANAGER_SELECTOR_PARAMS}
                      />
             </td>
          )`

   ###*
   * Функция формирования объекта аватара пользователя.
   *
   * @return {React-element}
   ###
   _getAvatar: ->
      avatarParams = @state.avatarParams

      if avatarParams? and !_.isEmpty avatarParams
         `(
            <img style={this.styles.avatarImage}
                 src={avatarParams.thumb} />

         )`
      else
         `(<i style={this.styles.avatarCap}
              className="fa fa-user" />)`

   ###*
   * Функция получения текущего активированного индекса для позиционного переключателя
   *  режимов работы.
   *
   * @param {Array<Object>} positionsCollection - набор позиций режима.
   * @param {String} modeName - наименования режима.
   * @return {Number}
   ###
   _getActivatedModeIndex: (positionsCollection, modeName) ->
      currentModes = @props.currentModes

      if currentModes?
         targetModeValue = currentModes[modeName]

         if targetModeValue?
            _.findIndex(positionsCollection, {name: targetModeValue})

   ###*
   * Функция установки набора значений структуры управления (для селектора
   *  подчиненных менеджеров)
   *
   * @param {Array} rawManagerParams - коллекция параметров подчиненных управленцев,
   *                                   полученных с API.
   * @return
   ###
   _setManagementStructure: (rawManagerParams) ->
      if rawManagerParams? and !_.isEmpty rawManagerParams
         subordinateManagers = rawManagerParams.map (managerParams) ->
            entityParams = managerParams.entity
            managerParams =
               value: managerParams.id

            if entityParams?
               shortName = entityParams.short_name
               fullName = entityParams.full_name
               managerParams.caption = shortName or fullName
               managerParams.title = fullName

            managerParams

         if subordinateManagers? and !_.isEmpty subordinateManagers
            @setState subordinateManagers: subordinateManagers

   ###*
   * Обработчик выбора подчиненной структуры. Вызывает обработчик на смену
   *  выбранного подчиненного менеджера.
   *
   * @param {Object} managerParams - параметры выбранной структуры.
   * @return {}
   ###
   _onSelectSubordinateManager: (managerParams) ->
      if managerParams?
         selectedValue = managerParams.value
         managerId = selectedValue.value if selectedValue?
         cookieParams = @_COOKIE_PARAMS.subordinateManager

         if managerId?
            Cookie.set(cookieParams.name,
                       managerId,
                       cookieParams.params)
            @props.onChangeManager(managerId)

   ###*
   * Обработчик события на изменение режима работы.
   *
   * @param {String} modeName - имя режима
   * @param {Object} modeParams - параметры режима.
   * @return
   ###
   _onChangeMode: (modeName, modeParams) ->
      cookieParams = @_COOKIE_PARAMS[modeName]
      onChangeModeHandler = @props.onChangeMode
      modeValue = modeParams.name

      Cookie.set(cookieParams.name,
                 modeValue,
                 cookieParams.params)

      onChangeModeHandler(modeName, modeValue) if onChangeModeHandler?

   ###*
   * Обработчик на сброс выбранной подчиненной структуры. Удаляет установленное
   *  в куки значение текущего выбранного менеджера. Вызывает обработчик на смену
   *  выбранного подчиненного менеджера с пустым значением.
   *
   * @return
   ###
   _onClearSubordinate: ->
      @_clearSubordinateManager()
      @props.onChangeManager(null)

   ###*
   * Обработчик клика по кнопке меню.
   *
   * @param {String} cation - наименование действия кнопки меню.
   * @return
   ###
   _onClickMenuItem: (cation) ->
      menuItems = @_MENU_ITEMS

      switch cation
         when menuItems.signout.value
            @_clearSubordinateManager()
            SessionActionCreators.signout()
         when menuItems.manual.value
            @setState isManualShown: true
         when menuItems.profile.value
            page(menuItems.profile.link)
            @props.onClickNavigate  @_CAPTION_PROFILE

   ###*
   * Обработчик, запускаемый при скрытии меню. Сбрасывает целевой узел для меню.
   *  Для того, чтобы он вновь задавался по клику на кнопку показа.
   *
   * @param {Event-obj} - объект события.
   * @return
   ###
   _onHideMenu: (event) ->
      arbitraryArea = this
      delay = (ms, func) -> setTimeout func, ms
      # Сбрасываем целевой узел по таймауту, для того, чтобы клик по целевому узлу
      #  мог перехватывать это событие.
      arbitraryArea._blurMenuTimeout = delay 150, ->
         arbitraryArea.setState userMenuTarget: {}

   ###*
   * Обработчик клика по кнопке показа пользовательского меню.
   *
   * @return
   ###
   _onClickUserMenu: ->
      # Если задан таймаут на потерю фокуса меню - очистим, т.к. клик должен перехватывать
      #  потерю фокуса и самостоятельно рулить отображением меню.
      clearTimeout(@_blurMenuTimeout) if @_blurMenuTimeout?

      # Если узел для меню не был задан - зададим кнопку показа меню.
      #  и сбросим если не был задан.
      newMenuTarget = if _.isEmpty(@state.userMenuTarget)
                         @refs.userActivityButton
                      else
                         {}

      @setState userMenuTarget: newMenuTarget

   ###*
   * Функция отправки запроса на получение параметров аватара текущего
   *  пользователя. В случае успешного получения ссылок на аватар -
   *  устанавливает параметры в состояние.
   *
   * @return
   ###
   _getAvatarFromAPI: ->
      sideMenu = this

      request.get(SokolFluxConstants.APIEndpoints.PERSONAL_AVATAR)
             .set('Accept', SokolFluxConstants.AcceptTypes.json)
             .end (error, res) ->
                json = JSON.parse(res.text)

                if json? and !_.isEmpty(json)
                   sideMenu.setState avatarParams: json

   ###*
   * Функция отправки запроса на получение коллеции параметров менеджеров
   *  (управляющих имуществом). После успешного ответа запускается обработчик
   *  установки коллекции параметров менеджеров в состояние компонента.
   *
   * @return
   ###
   _getManagementStructureFromAPI: ->
      sideMenu = this

      request.get(SokolFluxConstants.APIEndpoints.PERSONAL_MANAGEMENT_STRUCTURE)
             .set('Accept', SokolFluxConstants.AcceptTypes.json)
             .end (error, res) ->
                json = JSON.parse(res.text)

                if json? and !_.isEmpty(json)
                   sideMenu._setManagementStructure(json)
   ###*
   * Обработчик на скрытие просмотрщика .
   *
   * @return
   ###
   _onHideManualViewer: ->
      @setState isManualShown: false

   ###*
   * Функция удаления куки с заданным подчиненным менеджером.
   *
   * @return
   ###
   _clearSubordinateManager: ->
      Cookie.remove(@_COOKIE_PARAMS.subordinateManager.name)

CabinetHeaderMenuItem = React.createClass

   mixins: [HelpersMixin, AnimateMixin, AnimationsMixin.highlightBack]

   styles:
      common:
         fontSize: 28
         padding: _COMMON_PADDING
         color: '#C6E9AF'
         cursor: 'pointer'
         backgroundColor: _COLORS.main
         minWidth: 28
         textAlign: 'center'
      highlightBack:
         color: _COLORS.light
         backgroundColor: _COLORS.secondary

   render: ->
      computeStyle = @computeStyles @styles.common,
                                    @getAnimatedStyle('animate-highlight-back')


      `(<td style={computeStyle}
            title={this.props.title}
            onClick={this._onClick}
            onMouseEnter={this._onMouseEnter}
            onMouseLeave={this._onMouseLeave}>
            <i className={"fa fa-" + this.props.icon}/>
        </td>)`


   _onClick: ->
      onClickHandler = @props.onClick

      onClickHandler @props.value

   ###*
   * Обработчик на вход мыши на объект.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onMouseEnter: ->
      @_animationHighlightBackIn()

   ###*
   * Обработчик на уход мыши с объекта.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onMouseLeave: ->
      @_animationHighlightBackOut()


###* Компонент: Меню пользователя в заголовке. Часть компонента CabinetHeader
*
* @props:
*     {Object} userData           - хэш с данными пользователя.
*     {React-DOM-Node} menuTarget - целевой узел для пользовательского меню.
*     {Function} onHide           - обработчик, запускаемый при потере фокуса меню.
* @state:
*
###
CabinetHeaderUserMenu = React.createClass
   _SIGNOUT_CAPTION: 'Выйти'

   render: ->
      content = `(<Button isLink={true}
                          title={this._SIGNOUT_CAPTION}
                          caption={this._SIGNOUT_CAPTION}
                          onClick={this._onClickSignout} />)`

      `(
         <ArbitraryArea target={this.props.menuTarget}
                       content={content}
                       position={
                          {
                             vertical: { "top": "bottom" },
                             horizontal: { "right": "right" }
                          }
                       }
                       animation="slideDown"
                       onHide={this.props.onHide} />
       )`

   componentDidMount: ->
      SessionStore.addChangeListener(@_onChange)

   componentWillUnmount: ->
      SessionStore.removeChangeListener(@_onChange)

   _onClickSignout: ->
      SessionActionCreators.signout()

   ###*
   * Обработчик события из session_store, срабатывающий при получении
   *   ответа с сервера.
   *
   * @return
   ###
   _onChange: ->
      if SessionStore.getLastInteration() is SokolFluxConstants.ActionTypes.Session.SIGNOUT_RESPONSE

         window.location.href = SokolFluxConstants.APIEndpoints.SIGNIN

module.exports = CabinetHeader
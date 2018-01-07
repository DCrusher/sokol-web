###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов
* HelpersMixin     - функции-хэлперы для компонентов
* HierarchyMixin   - модуль для задания иерархии компонентов.
* BehaviorsMixin   - модуль поведения компонентов.
* keymirror        - модуль для генерации "зеркального" хэша.
* lodash           - модуль служебных операций.
###
PureRenderMixin = React.addons.PureRenderMixin
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
BehaviorsMixin = require('../mixins/behaviors')
HierarchyMixin = require('../mixins/hierarchy_components')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* Button      - кнопка.
* ButtonGroup - группа кнопок.
###
Button = require('./button')
ButtonGroup = require('components/core/button_group')

###* Константы
* _COLOR          - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

###* Компонент: Диалоговое окно
* @props:
*     {Boolean} isModal               - флаг модальности. По-умолчанию = true
*     {Boolean} isShown               - флаг показа диалога. По-умолчанию = false
*     {Boolean} isHasFullWindowButton - флаг наличия кнопки разворачивания окна на весь экран. По-умолчанию = false.
*     {Boolean} isMovable             - флаг возможности перемещения диалога. По-умолчанию = true
*     {Boolean} isHasHeader           - флаг наличия заголовка диалога. По-умолчанию = true
*     {Array<Object>} customActions   - набор параметров пользовательских действий над диалогом.
*                                       Ожидаются параметры для кнопок, которые будут сформированы
*                                       в левой части заголовка диалога.
*     {Array<Object>} customFunctionalButtons - набор параметров доп. функциональных кнопок диалога.
*     {String} caption                - заголовок диалога.
*     {Object} content                - содержимое диалога.
*     {Object} styleAdditionHeader    - дополнительный стиль заголовка.
*     {Function} onHide               - обработчик на скрытие диалога.
* {Function} onFullWindowedTrigger    - обработчик на переключения полноэкранного режима.
*                                      Аргументы:
*                                      {Boolean} isFullWindowed - флаг развернутости на полный экран.
* @state
*     {Boolean} isShown  - флаг показа.
*     {Boolean} isInMove - флаг нахождения в анимации.
*     {Object} offset    - параметры смещения(для перемещаемого диалога).
###
Dialog = React.createClass
   # @const {Object} - наименования используемых ссылок.
   _REFS: keyMirror(
      dialogInner: null
   )

   mixins: [HelpersMixin,
            BehaviorsMixin.move,
            HierarchyMixin.container.parent]

   styles:
      common:
         display: 'none'
      shown:
         display: ''
      modal:
         backgroundColor: 'rgba(0, 0, 0, 0.5)'
      wrapper:
         position: 'fixed'
         top: 0
         left: 0
         width: '100%'
         height: '100%'
         overflow: 'auto'
         zIndex: 1000
      tableWrapper:
         width: '100%'
         height: '100%'
      cellWrapper:
         textAlign: 'center'
         verticalAlign: 'middle'

   propTypes:
      isModal: React.PropTypes.bool
      isShown: React.PropTypes.bool
      isMovable: React.PropTypes.bool
      isHasHeader: React.PropTypes.bool
      isHasFullWindowButton: React.PropTypes.bool
      caption: React.PropTypes.string
      content: React.PropTypes.object
      customActions: React.PropTypes.array
      customFunctionalButtons: React.PropTypes.array
      styleAdditionHeader: React.PropTypes.object
      onHide: React.PropTypes.func
      onFullWindowedTrigger: React.PropTypes.func

   getDefaultProps: ->
      isModal: true
      isShown: false
      isMovable: true
      isHasHeader: true
      isHasFullWindowButton: false

   getInitialState: ->
      isShown: @props.isShown
      isInMove: false
      isFullWindowed: false

   componentWillReceiveProps: (nextProps) ->
      @setState isShown: nextProps.isShown

   render: ->
      computedStyle = @computeStyles @styles.wrapper,
                                     @styles.common,
                                     @state.isShown and @styles.shown,
                                     @props.isModal and @styles.modal

      `(
         <div style={computedStyle}
              onClick={this._onClickWrapper}>
            <table style={this.styles.tableWrapper}>
               <tbody>
                  <tr>
                     <td style={this.styles.cellWrapper}>
                        <DialogInner {...this.props}
                                     ref={this._REFS.dialogInner}
                                     offset={this.props.isMovable ? this._getMoveOffset(): null}
                                     isInMove={this.state.isInMove}
                                     isMovable={this.props.isMovable}
                                     isHasHeader={this.props.isHasHeader}
                                     isHasFullWindowButton={this.props.isHasFullWindowButton}
                                     isFullWindowed={this.state.isFullWindowed}
                                     onClose={this._onClose}
                                     customActions={this.props.customActions}
                                     customFunctionalButtons={this.props.customFunctionalButtons}
                                     onMouseDownHeader={this._onMouseDownHeader}
                                     onMouseUpHeader={this._onMouseUpHeader}
                                     onClickFullWindow={this._onClickFullWindow}
                                  />
                     </td>
                  </tr>
               </tbody>
            </table>
         </div>
       )`

   ###*
   * Функция для возможности внешнего скрытия дилога.
   *
   * @return
   ###
   close: ->
      @_onClose(null, null)

   ###*
   * Обработчик на нажатие клавиши мыши на заголовке. Устанавливает состоянии
   *  области на "в движении" (для стилей курсоров). И запускает обработчик инициализации
   *  движения (примесь BehaviorsMixin).
   *
   * @param (Event-object) event - объект события.
   ###
   _onMouseDownHeader: (event) ->
      initOffset = @_getMoveOffset() || $(@refs.dialogInner).offset()

      @_moveInit event, initOffset
      @setState isInMove: true

   ###*
   * Обработчик на отпуск клавиши мыши на заголовке. Устанавливает состоянии
   *  области на "показан" (для стилей курсоров). И запускает обработчик окончания
   *  движения (примесь BehaviorsMixin)..
   *
   * @param (Event-object) event - объект события.
   ###
   _onMouseUpHeader: (event) ->
      @_moveTerminate event
      @setState isInMove: false

   ###*
   * Обрабочитк на событие закрытия диалогового окна (вызывается при
   *     нажатии на кнопку закрытия на заголовке диалога).
   *
   * @return
   ###
   _onClose: (value, event) ->
      event.stopPropagation() if event?
      @setState isShown: false
      onHideHandler = @props.onHide
      onHideHandler() if onHideHandler?

   ###*
   * Обрабочитк клика на кнопку разворачивания/сворачивания диалога на весь экран.
   *
   * @return
   ###
   _onClickFullWindow: (value, event) ->
      event.stopPropagation()
      isFullWindowedNew = !@state.isFullWindowed
      onFullWindowedTriggerHandler = @props.onFullWindowedTrigger

      if onFullWindowedTriggerHandler?
         onFullWindowedTriggerHandler(isFullWindowedNew)

      @setState isFullWindowed: isFullWindowedNew

   ###*
   * Обработчик клика по обертке диалогового окна
   * @return
   ###
   _onClickWrapper: ->
      # если не модальное - по клику на обертку - закрываем диалог
      if !@props.isModal
         @_onClose()

###* Компонент: содержимое диалогового окна. Часть компонента Dialog
* @props:
*     {Boolean} isModal            - флаг модальности.
*     {Boolean} isShown            - флаг показа диалога.
*     {Boolean} isMovable          - флаг показа диалога.
*     {Boolean} isHasHeader        - флаг наличия заголовка диалога.
*     {Boolean} isHasFullWindowButton - флаг наличия кнопки разворачивания на весь экран.
*     {Boolean} isFullWindowed     - флаг развернутости диалога на весь экран.
*     {String} caption             - заголовок диалога.
*     {Object} content             - содержимое диалога.
*     {Object} styleAdditionHeader - дополнительный стиль заголовка.
*     {Array} customActions        - параметры пользовательских действий.
*  {Array} customFunctionalButtons - параметры пользовательских функциональных кнопок.
*     {Function} onClose           - обработчик на скрытие диалога.
*     {Function} onClickFullWindow - обработчик клика на разворачивание/сворачивание
*                                    диалога на весь экран.
*     {Function} onMouseUpHeader   - обработчик нажатия на заголовок(клавиша мыши нажата).
*     {Function} onMouseDownHeader - обработчик отпускания клавиши с заголовка.
###
DialogInner = React.createClass
   mixins: [HelpersMixin]

   styles:
      common:
         boxShadow: "5px 5px 5px #{_COLORS.hierarchy2}"
         backgroundColor: _COLORS.light
         display: 'table'
         margin: '0 auto'
      shiftedInner:
         position: 'fixed'
      fullWindowed:
         top: 0
         left:0
         maxWidth: null
         maxHeight: null
         width: '100%'
         height: '100%'
         position: 'absolute'

   render: ->
      `(<div style={this._getInnerStyle()}
             onClick={this._onClickInner}>
            {this._getHeader()}
            <DialogIsolatedContent content={this.props.content} />
         </div>
      )`

   ###*
   * Обработчик клика по контейнеру контента.
   *
   * @param {Object} event - объект события
   * @return
   ###
   _onClickInner: (event) ->
      # Отменим проброс события до родителей
      event.stopPropagation()

   ###*
   * Функция получения скомпанованного стиля для содержимого диалога.
   *
   * @return
   ###
   _getInnerStyle: ->
      offset = @props.offset
      isHasOffset = offset? and !_.isEmpty(offset)

      @computeStyles @styles.common,
                     isHasOffset and @styles.shiftedInner,
                     offset,
                     @props.isFullWindowed and @styles.fullWindowed

   ###*
   * Обработчик клика по контейнеру контента.
   *
   * @param {Object} event - объект события
   * @return
   ###
   _getHeader: ->
      if @props.isHasHeader
         `(<DialogHeader caption={this.props.caption}
                         styleAdditionHeader={this.props.styleAdditionHeader}
                         customActions={this.props.customActions}
                         customFunctionalButtons={this.props.customFunctionalButtons}
                         isInMove={this.props.isInMove}
                         isMovable={this.props.isMovable}
                         isHasFullWindowButton={this.props.isHasFullWindowButton}
                         isFullWindowed={this.props.isFullWindowed}
                         onClickClose={this.props.onClose}
                         onClickFullWindow={this.props.onClickFullWindow}
                         onMouseDownHeader={this.props.onMouseDownHeader}
                         onMouseUpHeader={this.props.onMouseUpHeader}
                      />)`

###* Компонент: изолированный контент содержимого диалогового окна. Часть компонента Dialog.
*  Компонент нужен для прерывания пробрасывания свойств до содержимого диалога,
*  что является критичным при разных манипуляциях (перетаскивании...) и сложном
*  содержимом.
*
* @props
*     {React-Element} content - содержимое.
###
DialogIsolatedContent = React.createClass
   mixins: [PureRenderMixin]

   render: ->
      `(<div>{this.props.content}</div>)`


###* Компонент: заголовок диалогового окна. Часть компонента Dialog
* @props:
*     {String} caption             - заголовок диалога.
*     {Object} styleAdditionHeader - дополнительный стиль заголовка.
*     {Array} customActions        - параметры пользовательских действий.
*  {Array} customFunctionalButtons - параметры пользовательских функциональных кнопок.
*     {Boolean} isInMove           - флаг нахождения в движении (перемещается).
*     {Boolean} isMovable          - флаг возможности перемещения.
*     {Boolean} isFullWindowed     - флаг "развернутости" диалога.
*  {Boolean} isHasFullWindowButton - флаг наличия кнопки разворачинвания/сворачивания
*                                    диалога на весь экран.
*     {Function} onClickClose      - обработчик на скрытие диалога.
*     {Function} onClickFullWindow - обработчик клика на разворачивание/сворачивание
*                                    диалога на весь экран.
*     {Function} onMouseUpHeader   - обработчик нажатия на заголовок(клавиша мыши нажата).
*     {Function} onMouseDownHeader - обработчик отпускания клавиши с заголовка.
###
DialogHeader = React.createClass
   mixins: [HelpersMixin]
   # @const параметры кнопки  закрытия диалога.
   _CLOSE_DIALOG_BUTTON_PARAMS:
      title: 'Закрыть диалог'
      icon: 'times'

   # @const {Object} - символы для кнопки разворачивания/сворачивания
   #                   области на все окно браузера.
   _FULL_WINDOW_BUTTON_PARAMS:
      expand:
         # caption: '□'
         icon: 'expand'
         title: 'развернуть на все окно'
         isLink: true
      collapse:
         # caption: '▭'
         icon: 'compress'
         isLink: true
         title: 'вернуться к исходному размеру'

   styles:
      common:
         padding: _COMMON_PADDING
         backgroundColor: _COLORS.hierarchy3
         width: '100%'
      captionCell:
         pointerEvents: 'none'
         width: '100%'
         textAlign: 'left'
      caption:
         color: _COLORS.light
         fontWeight: 'bold'
         marginRight: _COMMON_PADDING + 5
         marginLeft: _COMMON_PADDING + 5
      closeButton:
         fontSize: 25
      additionFunctionalButton:
         fontSize: 15
         color: _COLORS.hierarchy2
      fullWindowAreaButton:
         fontSize: 15
         padding: 0
         color: _COLORS.hierarchy2
      movable:
         cursor: 'grab'
         cursor: '-webkit-grab'
      inMove:
         cursor: 'move'
      customActionButton:
         color: _COLORS.hierarchy2
         minWidth: 32
         minHeight: 32


   render: ->
      `(
         <table style={this._getComputedStyleHeader()}
                onMouseUp={this.props.onMouseUpHeader}
                onMouseDown={this.props.onMouseDownHeader}
                onDoubleClick={this._onDoubleClick}>
            <thead>
               <tr>
                  {this._getCustomActionButtonsCell()}
                  <th style={this.styles.captionCell}>
                     <span style={this.styles.caption}>
                        {this.props.caption}
                     </span>
                  </th>
                  {this._getCustomFunctionButtonCells()}
                  {this._getFullWindowButtonCell()}
                  {this._getCloseButtonCell()}
               </tr>
            </thead>
         </table>
       )`

   ###*
   * Функция формирования ячейки с кнопкой закрытия диалога.
   *
   * @return {Array<React-element>}
   ###
   _getCloseButtonCell: ->
      closeButton =
         `(
            <Button title={this._CLOSE_DIALOG_BUTTON_PARAMS.title}
                    isClear={true}
                    onClick={this._onClickClose}
                    styleAddition={this.styles.closeButton}
                 />
          )`
      @_getHeaderButtonCell(closeButton)

   ###*
   * Функция формирования ячейки с кнопкой разворачивания/сворачивания диалога на
   *  весь экран.
   *
   * @return {Array<React-element>}
   ###
   _getFullWindowButtonCell: ->
      if @props.isHasFullWindowButton
         fullWindowButtonParams = @_FULL_WINDOW_BUTTON_PARAMS
         buttonParams =
            if @props.isFullWindowed
               fullWindowButtonParams.collapse
            else
               fullWindowButtonParams.expand

         fullWindowButton =
            `(
               <Button {...buttonParams}
                       styleAddition={this.styles.fullWindowAreaButton}
                       onClick={this.props.onClickFullWindow}
                     />
             )`

         @_getHeaderButtonCell(fullWindowButton)

   ###*
   * Функция формирования ячееки с пользовательскими кнопками действия.
   *
   * @return {Array<React-element>}
   ###
   _getCustomActionButtonsCell: ->
      customActions = @props.customActions

      if customActions? and !_.isEmpty customActions
         buttons =
            customActions.map ((action) ->
               customStyleAddition = action.styleAddition
               action.styleAddition =
                  @computeStyles @styles.customActionButton, customStyleAddition
               action
            ).bind(this)

         buttonsGroup =
            `(
               <ButtonGroup buttons={buttons}
                            isIndependent={true}
                          />
             )`

         @_getHeaderButtonCell(buttonsGroup)

   ###*
   * Функция формирования ячеек с доп. функциональными кнопками диалога заданными
   *  через свойства компонента.
   *
   * @return {Array<React-element>}
   ###
   _getCustomFunctionButtonCells: ->
      customFunctionalButtons = @props.customFunctionalButtons

      if customFunctionalButtons? and !_.isEmpty(customFunctionalButtons)
         customFunctionalButtons.map ((functionalButtonParams, key) ->
            clonedButton = React.cloneElement(
               functionalButtonParams,
               styleAddition: @styles.additionFunctionalButton
            )

            @_getHeaderButtonCell(clonedButton, key)
         ).bind(this)

   ###*
   * Функция формирования ячейка заголовка таблицы.
   *
   * @param {React-element} buttonElement - элемент кнопки.
   * @param {Number} key - индекс кнопки.
   ###
   _getHeaderButtonCell: (buttonElement, key) ->
      mouseStoppingEvent = @_onMouseStoppingEventFunctionalCell

      `(
         <th key={key}
             onMouseUp={mouseStoppingEvent}
             onMouseDown={mouseStoppingEvent}>
            {buttonElement}
         </th>
       )`


   ###*
   * Функция получения скомпанованного стиля заголовка.
   *
   * @return {Object} - скомпанованный стиль заголовка.
   ###
   _getComputedStyleHeader: ->
      isMovable = @props.isMovable
      @computeStyles @styles.common,
                     @props.styleAdditionHeader,
                     isMovable and @styles.movable,
                     isMovable and @props.isInMove and @styles.inMove

   ###*
   * Обработчик двойного клика на клавишу мыши.
   *
   * @param {Object} event - объкект события.
   * @return
   ###
   _onDoubleClick: (event) ->
      @props.onClickFullWindow(null, event)

   ###*
   * Обработчик нажатия клавиши мыши на кнопку. Останавливает проброс события до
   *  заголовка, чтобы не начиналось перемещение диалога.
   *
   * @param {Object} event - объкект события.
   * @return
   ###
   _onMouseStoppingEventFunctionalCell: (event) ->
      event.stopPropagation()

   ###*
   * Обработчик на клик по кнопке закрытия диалога. Останавливает проброс клика
   *  до заголовка диалога, вызывает обрабочик закрытия.
   *
   * @param {Object} value - значение кнопки.
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickClose: (value, event) ->
      event.stopPropagation()
      onClickCloseHandler = @props.onClickClose

      onClickCloseHandler(value, event) if onClickCloseHandler?


module.exports  = Dialog


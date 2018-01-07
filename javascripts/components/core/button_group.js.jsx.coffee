###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов
* HelpersMixin     - функции-хэлперы для компонентов
* keymirror        - модуль для генерации "зеркального" хэша.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
keyMirror = require('keymirror')

###* Зависимости: компоненты
* Button            - кнопка.
###
Button = require('components/core/button')

###* Константы
* _COLORS               - цвета
* _COMMON_PADDING       - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding

###* Компонент: Группа кнопок.
*
* @props:
*     {Array<Object>} buttons         - массив из объектов, которые представляют собой параметры
*                                       кнопок. В параметрах элемента могут быть любые параметры,
*                                       принимаемые компонентом Button.
*     {Number} activatedIndex         - индекс изначально активированной кнопки.
*     {Object} styleAddition          - доп. стили.
*     {Boolean} isIndependent         - флаг независимости (зависимости). Независимые кнопки -
*                                       одновременно может быть активировано несколько кнопок.
*                                       зависимые кнопки - активирована может быть только одна.
*                                       (по-умолчанию =false).
*     {Boolean} isResetActivated      - флаг сброса текущей активированной кнопки.
*                                       (по-умолчанию =false).
*     {Boolean} isPaneled             - флаг кнопок, объединенных в панель (по-умолчанию =true).
*                                       При значении false - кнопки располагаются с отступами между друг другом.
*     {Boolean} enableDeactivating    - флаг разрешения дизактивации кнопок. Этот флаг позволяет
*                                       при клике на активированную кнопку сделать её не активной
*                                       и вернуть пустой результат. (по-умолчанию =false)
*     {Function} onClickButton        - обработчик клика по кнопке. Аргументы:
*                                       {Object, String, ...} value - значение кнопки.
*                                       {Number} buttonIndex        - индекс кнопки в наборе.
*                                       {Object} event              - объект события.
* @state
*     {Boolean} activeIndex - порядковый номер активной кнопки.
*
###
ButtonGroup = React.createClass

   # @const {String} - строковый префикс для ссылки на кнопку.
   _BUTTON_REF_PREFIX: 'button'

   # @const {Object} - используемые символы.
   _CHARS:
      empty: ''
      sqBrStart: '['
      sqBrEnd: ']'
      cap: '^'
      backslash: '\\'
      digitMark: 'd'
      plus: '+'

   mixins: [HelpersMixin]

   styles:
      isNotPaneled:
         margin: _COMMON_PADDING
      isLeftButton:
         borderTopRightRadius: 0
         borderBottomRightRadius: 0
      isRightButton:
         borderTopLeftRadius: 0
         borderBottomLeftRadius: 0
      isCenterButton:
         borderRadius: 0

   propTypes:
      buttons: React.PropTypes.array
      styleAddition: React.PropTypes.object
      activatedIndex: React.PropTypes.number
      onClickButton: React.PropTypes.func
      isIndependent: React.PropTypes.bool
      isPaneled: React.PropTypes.bool
      isResetActivated: React.PropTypes.bool
      enableDeactivating: React.PropTypes.bool

   getDefaultProps: ->
      enableDeactivating: false
      isIndependent: false
      isResetActivated: false
      isPaneled: true

   getInitialState: ->
      activeIndex: @props.activatedIndex

   componentWillReceiveProps: (nextProps) ->
      isNextResetActivated = nextProps.isResetActivated

      # Если был проброшен флаг сброса активированности - сбросим индекс текущей
      #  активной кнопки.
      if isNextResetActivated
         @setState activeIndex: null

   render: ->
      `(
         <span style={this.props.styleAddition}>
            {this._getContent()}
         </span>
      )`

   ###*
   * Функция-предикат для определения является ли передаваемое наименование
   *  ссылки - ссылкой на кнопку из набора.
   *
   * @param {String} buttonRef - наименование проверяемой ссылки.
   * @return {Boolean}
   ###
   isThisButtonByRef: (buttonRef) ->
      chars = @_CHARS
      backslash_char = chars.backslash

      regExpString =
         [
            chars.cap
            @_BUTTON_REF_PREFIX
            backslash_char
            chars.sqBrStart
            backslash_char
            chars.digitMark
            chars.plus
            backslash_char
            chars.sqBrEnd
         ].join chars.empty

      testRegExp = new RegExp(regExpString, 'gi')

      testRegExp.test buttonRef

   ###*
   * Функция получения контента для группы кнопок. В функции также вычисляются
   *  стили для каждой из кнопок в зависимости от параметров группы кнопок и
   *  расположения каждой из кнопок.
   *
   * @return {React-DOM-Node} - содержимое группы кнопок (контент).
   ###
   _getContent: ->
      buttonGroup = this
      buttonCollection = @props.buttons

      buttonCollection.map (item, index) ->
         currentParams = buttonGroup.props.buttons[index]
         buttonStyles = buttonGroup._getButtonStyles(index)
         currentStyle = buttonStyles.currentStyle
         currentStyleAddition = buttonStyles.currentStyleAddition
         isIndependent = buttonGroup.props.isIndependent

         # Если компонент зависимый и не сбрасывается активированность,
         #  то проверяется, является ли текущий элемент текущим активным элементом.
         unless isIndependent
            activeIndex = buttonGroup.state.activeIndex

            isActive = if activeIndex?
                          index is activeIndex
                       else
                          !!currentParams.isActive

         `(
            <Button key={index}
                    ref={buttonGroup._getButtonRef(index)}
                    {...currentParams}
                    isActive={isActive}
                    isDeactivatable={buttonGroup.props.enableDeactivating}
                    value={index}
                    style={currentStyle}
                    styleAddition={currentStyleAddition}
                    onClick={buttonGroup._onClickButton}
                  />

         )`



   ###*
   * Функция получения строки-ссылки на кнопку из группы.
   *
   * @param {Number} index - индекс кнопки в наборе.
   * @return {String}
   ###
   _getButtonRef: (index) ->
      chars = @_CHARS
      prefix = @_BUTTON_REF_PREFIX

      [
         prefix
         chars.sqBrStart
         index
         chars.sqBrEnd
      ].join chars.empty

   ###*
   * Функция, возвращающая стили кнопки.
   *
   * @param {Number} index - индекс кнопки.
   * @return {Object}:
   *           {Object} currentStyle - хэш текущих стилей кнопки
   *           {Object} currentStyleAddition - хэш дополнительных стилей кнопки
   ###
   _getButtonStyles: (index) ->
      isPaneled = @props.isPaneled
      currentParams = @props.buttons[index]
      currentStyle = currentParams.style
      currentStyleAddition = currentParams.styleAddition
      buttons = @props.buttons
      buttonsCount = buttons.length if buttons?
      leftButtonBorderStyle = @styles.isLeftButton
      rightButtonBorderStyle = @styles.isRightButton
      centerButtonBorderStyle = @styles.isCenterButton

      # Если компонент панельный, то присваиваются стили для границ текущего
      #  элемента, в зависимости от его расположения
      borderStyle =
         if isPaneled
            if index is 0
               if buttonsCount isnt 1
                  leftButtonBorderStyle
            else if index is buttonsCount - 1
               rightButtonBorderStyle
            else
               centerButtonBorderStyle

      # Если заданы стили примешаем к ним свои стили
      if currentStyle? or currentStyleAddition?
         if currentStyle?
            currentStyle = @computeStyles currentStyle,
               isPaneled and @styles.isPaneled,
               !isPaneled and @styles.isNotPaneled,
               isPaneled and borderStyle
         else
            currentStyleAddition = @computeStyles currentStyleAddition,
                                                  isPaneled and @styles.isPaneled,
                                                  !isPaneled and @styles.isNotPaneled,
                                                  isPaneled and borderStyle

      # Иначе (если стили не заданы) создадим styleAddition
      else
         currentStyleAddition = @computeStyles isPaneled and @styles.isPaneled,
                                 !isPaneled and @styles.isNotPaneled,
                                 isPaneled and borderStyle
      currentStyle: currentStyle,
      currentStyleAddition: currentStyleAddition

   ###*
   * Функция, срабатывающая при клике на кнопку. Если компонент является зависимым,
   *  то функция делает активной нажатую клавишу.
   * Если задана функция, по-умолчанию для нажатия определенной кнопки, то она
   *  выполнится.
   *
   * @param {Number} buttonIndex - индекс кнопки в наборе.
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickButton: (buttonIndex, event) ->
      instanceButton = @props.buttons[buttonIndex]
      instanceButtonOnClickHandler = instanceButton.onClick
      currentActiveIndex = @state.activeIndex
      isNewActiveTheSame = buttonIndex is currentActiveIndex
      instanceButtonValue = instanceButton.value unless isNewActiveTheSame
      onClickButtonHanlder = @props.onClickButton

      # Если задан обработчик конкретной кнопки - вызовем, с передачей
      #  значений и объекта события.
      if instanceButtonOnClickHandler?
         instanceButtonOnClickHandler(instanceButtonValue, event)

      # Если задан обработчик клика по кнопке для компонента - вызываем, возвращаем
      #  индекс кнопки в наборе, значение и объект события.
      if onClickButtonHanlder?
         onClickButtonHanlder(instanceButtonValue, buttonIndex, event)

      # Если группа кнопок зависимая(может быть нажата только одна кнопка), то
      #  установим индекс текущей активной кнопки.
      unless @props.isIndependent
         newActiveIndex =
            if isNewActiveTheSame
               null
            else
               buttonIndex

         @setState activeIndex: newActiveIndex


module.exports = ButtonGroup
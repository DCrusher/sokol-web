###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* HelpersMixin     - функции-хэлперы для компонентов.
* keymirror        - модуль для генерации "зеркального" хэша.
* lodash           - модуль служебных операций.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* AjaxLoader     - индикатор загрузки.
* BreadNavigator - хлебнокрошечный навигатор.
* Button         - кнопка.
* PopupFlasher      - всплывающее уведомление.
###
AjaxLoader = require('components/core/ajax_loader')
BreadNavigator = require('components/core/bread_navigator')
Button = require('components/core/button')
PopupFlasher = require('components/core/popup_flasher')

###* Константы
* _COLORS               - цвета
* _COMMON_PADDING       - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius

###* Компонент - мастер для реализации многошаговых операций.
*
* @props
*     {Array<Object>} steps - параметры последовательных шагов.
*     {Number} initStep     - индекс изначально активированного шага.
*                             По-умолчанию = 0
*     {Boolean} enableBreadNavigator - флаг разрешения отображения хлебного
*                                      навигатора. По-умолчанию = true.
*     {Boolean} enableControlButtons - флаг разрешения отображения кнопок
*                                      управления по шагам. По-умолчанию = true.
*     {Boolean} enableCaption        - флаг разрешения вывода заголовка текущего
*                                      активированного шага. Заголовок выводится
*                                      вместо хлебного навигатора, поэтому при заданном
*                                      флаге вывода навигатора enableBreadNavigator
*                                      заголовок не будет выведен. По-умолчанию = false.
*     {Object} styleAddition          - доп. стили для элементов компонента. Вид:
*              {Object} common  - стиль для основного контейнера компонента.
*              {Object} content - стили для контейнера содержимого активного шага.
*              {Object} header  - стили для заголовка.
*              {Object} footer  - стили для подвала.
*     {Function} onClickForward       - обработчик на шаг вперед мастера.
*                                      Аргументы:
*                                      {Object} step - параметры шага.
*     {Function} onClickBackward      - обработчик на шаг назад мастера.
*                                      Аргументы:
*                                      {Object} step - параметры шага.
*     {Function} onScrollContent      - обработчик скролла содержимого активного шага.
*                                      {Object} event - объект события.
* @state
*     {Number} activatedStepIndex         - текущий активированный шаг мастера.
*     {Array<React-element>} stepContents - массив элементов содержимого для шагов.
*                                           Содержимое расположено по индексам параметров
*                                           шагов.
*     {React-element} activityTarget      - целевой узел для загрузчика.
*     {Object} stepRequestedFlags         - флаги отправленного запроса для шагов.
*     {Object} popupParams                - параметры всплывающиего уведомления.
###
Clerk = React.createClass
   # @const {Object} - параметры управляющих кнопок.
   _CONTROL_BUTTONS:
      backward:
         caption: 'Назад'
         title: 'На шаг назад'
         icon: 'arrow-left'
         value: 'backward'
      forward:
         caption: 'Вперед'
         title: 'На шаг вперед'
         icon: 'arrow-right'
         value: 'forward'

   # @const {Object} - стандартные надписи-заполнители содержимого текущего шага.
   _DEFAULT_STEP_CONTENTS:
      notDefined: 'Содержимое шага не задано'
      requested: 'Загрузка...'

   # @const {Object} - используемые символы.
   _CHARS:
      empty: ''

   # @const {Object} - набор наименований используемых ссылок.
   _REFS: keyMirror(
      container: null
   )

   # @const {Object} - возможные направления переходов для проведения валидации.
   _VALIDATION_TYPES: keyMirror(
      after: null
      before: null
   )

   # @const {Object} - параметры для компонента всплывающих уведомлений.
   _POPUP_FLASHER_PARAMS:
      closeTimeout: 3000

   mixins: [HelpersMixin]

   styles:
      stepContentContainer:
         minWidth: 300
         minHeight: 200
      stepContentDefaultTextContainer:
         padding: _COMMON_PADDING
         color: _COLORS.hierarchy3
         fontSize: 16
      splitter:
         border: 'none'
         color: _COLORS.hierarchy3
         backgroundColor: _COLORS.hierarchy3
         borderWidth: 1
         height: 1
      activatedStepCaption:
         color: _COLORS.hierarchy3
         margin: 10
      buttonForward:
         marginRight: _COMMON_PADDING

   propTypes:
      steps: React.PropTypes.arrayOf(React.PropTypes.object).isRequired
      activeStep: React.PropTypes.number
      styleAddition: React.PropTypes.object
      onClickForward: React.PropTypes.func
      onClickBackward: React.PropTypes.func

   getDefaultProps: ->
      enableControlButtons: true
      enableBreadNavigator: true
      enableCaption: false

   getInitialState: ->
      activatedStepIndex: @props.initStep or 0
      stepContents: []
      stepRequestedFlags: {}
      popupParams: @_getInitPopupFlashParams()

   # componentWillReceiveProps: (nextProps) ->
   #    nextSteps = nextProps.steps

   #    if nextSteps? and @state.isContentRequested
   #       activatedStepNextParams = nextSteps[@state.activatedStepIndex]

   #       if activatedStepNextParams.render? or activatedStepNextParams.content?
   #          @setState isContentRequested: false

   shouldComponentUpdate: (nextProps, nextState) ->
      nextActivatedStepIndex = nextState.activatedStepIndex
      currentActivatedStepIndex = @state.activatedStepIndex

      # Запускаем рендер, если:
      # 1. Поменялся текущий активированный шаг.
      # 2. Изменилось состояние компонента.
      if nextActivatedStepIndex isnt currentActivatedStepIndex
         true
      else
         nextActivatedStep = @_getActivatedStep(nextActivatedStepIndex,
                                                nextProps.steps)
         nextActivatedStepOld = @_getActivatedStep(nextActivatedStepIndex,
                                                   @props.steps)

         !_.isEqual(nextActivatedStep, nextActivatedStepOld) or
         !_.isEqual(nextState, @state)

   componentWillMount: ->
      @_checkAndSendInitRequest()

   componentWillUpdate: (nextProps, nextState) ->
      @_checkAndSendInitRequest(nextProps, nextState)

   render: ->
      `(
         <div ref={this._REFS.container}
              style={this.props.styleAddition.common} >
            {this._getHeader()}
            {this._getStepContent()}
            {this._getFooter()}
            <AjaxLoader isShown={this._isActivatedStepRequested()}
                        target={this.state.activityTarget}
                     />
            <PopupFlasher flash={this.state.popupParams}
                          target={this.state.activityTarget}
                          onHide={this._onHidePopupFlash}
                          enableShowIdentifier={false}
                          {...this._POPUP_FLASHER_PARAMS}
                        />
         </div>
      )`

   componentDidMount: ->
      @setState activityTarget: @refs[@_REFS.container]

   ###*
   * Функция построения содержимого шапки компонента. Выводит хлебный навигатора
   *  если задан флаг отображения навигатора или отображает заголовок текущего
   *  активированного шага.
   *
   * @return {React-element}
   ###
   _getHeader: ->
      headerContent =
         if @props.enableBreadNavigator
            `(
               <BreadNavigator items={this._getNavigatorItems()}
                               onClickItem={this._onClickBreadNavigatorItem}
                            />
             )`
         else if @props.enableCaption
            activatedStep = @_getActivatedStep()
            activatedStepCaption = activatedStep.caption if activatedStep?

            if activatedStepCaption?
               `(
                   <h3 style={this.styles.activatedStepCaption}>
                     {activatedStepCaption}
                   </h3>
                )`


      if headerContent?

          `(
            <header style={this.props.styleAddition.header}>
               {headerContent}
               {this._getSplitter()}
            </header>
          )`

   ###*
   * Функция построения cодержимого текущего шага.
   *
   * @return {React-element}
   ###
   _getStepContent: ->
      activatedStepIndex = @state.activatedStepIndex
      activatedStep = @_getActivatedStep()
      stepContents = @state.stepContents
      existStepContent = stepContents[activatedStepIndex]
      defaultStepContents = @_DEFAULT_STEP_CONTENTS

      ###*
      * Функция оборачивания содержимого в контейнер отображения стандартных
      *  надписей-заполнителей содержимого текущего активного шага.
      *
      * @param {String} text - выводимая надпись.
      * @return {React-element}
      ###
      wrapInDefaultContainer = ((text) ->
         `(
            <span style={this.styles.stepContentDefaultTextContainer}>
               {text}
            </span>
          )`
      ).bind(this)

      stepContent =
         if existStepContent?
            existStepContent
         else if activatedStep.render?
            activatedStep.render()
         else if activatedStep.content?
            activatedStep.content
         else if activatedStep.initRequest
            wrapInDefaultContainer(defaultStepContents.requested)
         else
            wrapInDefaultContainer(defaultStepContents.notDefined)

      `(
          <div style={this._getStepContentStyle()}
               onScroll={this.props.onScrollContent}>
            {stepContent}
          </div>
       )`

   ###*
   * Функция построения кнопок управления. Формирует контейнер
   *
   * @return {React-element}
   ###
   _getFooter: ->
      if @props.enableControlButtons
         controlButtonParams = @_CONTROL_BUTTONS

         `(
            <footer style={this.props.styleAddition.footer}>
               {this._getSplitter()}
               <Button onClick={this._onClickDirectionControlButton}
                       isShown={this._isControlButtonShown()}
                       styleAddition={this.styles.buttonForward}
                       {...controlButtonParams.forward}
                     />
               <Button onClick={this._onClickDirectionControlButton}
                       isShown={this._isControlButtonShown(true)}
                       {...controlButtonParams.backward}
                     />

            </footer>
          )`

   ###*
   * Функция формирования разделителя разделов компонента. Получает стилизованную
   *  компонент-линию.
   *
   * @return {React-element}
   ###
   _getSplitter: ->
      `(<hr style={this.styles.splitter} />)`

   ###*
   * Функция получения скомпанованного стиля для контейнера шага.
   *
   * @return {Object}
   ###
   _getStepContentStyle: ->
      @computeStyles @styles.stepContentContainer,
                     @props.styleAddition.content

   ###*
   * Функция получения набора элементов для хлебного навигатора (набор шагов
   *  с 0-го по текущий выбранный).
   *
   * @return {Array}
   ###
   _getNavigatorItems: ->
      @props.steps[0..@state.activatedStepIndex] if @_isHasSteps()

   ###*
   * Функция получения параметров текущего активного шага.
   *
   * @param {Number} activatedStepIndex - индекс активированного шага.
   * @param {Array} steps               - набор шагов.
   * @return {Object}
   ###
   _getActivatedStep: (activatedStepIndex, steps) ->
      steps ||= @props.steps

      unless activatedStepIndex?
         activatedStepIndex = @state.activatedStepIndex

      steps[activatedStepIndex] if @_isHasSteps(steps)

   ###*
   * Функция получения начальных(пустых) значений для всплывающего уведомления.
   *
   * @return {Object} - хэш с пустыми параметрами.
   ###
   _getInitPopupFlashParams: ->
      text: @_CHARS.empty
      id: 0

   ###*
   * Обработчик на скрытие уведомления. Сбрасывает текст уведомления, для того, чтобы
   *  уведомление не показывалось снова.
   *
   * @return
   ###
   _onHidePopupFlash: ->
      @setState popupParams: @_getInitPopupFlashParams()

   ###*
   * Функция-обработчик клика на управляющей кнопке вперед или назад. В
   *  зависимости от значения кнопки выполяет процедуру перехода на шаг
   *  вперед или назад.
   *
   * @param {String} operationName - наименование операции.
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickDirectionControlButton: (operationName, event) ->
      controlButtonParams = @_CONTROL_BUTTONS
      activatedIndex = @state.activatedStepIndex
      validatorTypes = @_VALIDATION_TYPES

      return unless @_validateStep(activatedIndex, validatorTypes.after)

      if operationName is controlButtonParams.forward.value
         newActivatedIndex = ++activatedIndex
         onClickHandler = @props.onClickForward
      else
         stepRequestedFlags = @state.stepRequestedFlags
         stepRequestedFlags[activatedIndex] = false

         @setState stepRequestedFlags: stepRequestedFlags

         newActivatedIndex = --activatedIndex
         onClickHandler = @props.onClickBackward

      if onClickHandler?
         onClickHandler(@_getActivatedStep(newActivatedIndex))

      return unless @_validateStep(newActivatedIndex, validatorTypes.before)

      @setState
         activatedStepIndex: newActivatedIndex

   ###*
   * Функция валидации шага. По индексу считывает параметры шага и по типу
   *  валидации, если задан обработчик, запускает обработчик валидации шага
   *  (если задан) и при возврате отрицательного значения валидатора
   *  сохраняет
   *
   * @param {Number} stepIndex    - индекс проверяемого шага.
   * @param {String} validateType - тип валидации (after/before).
   * @return
   ###
   _validateStep: (stepIndex, validateType) ->
      validatableStep = @_getActivatedStep(stepIndex)
      stepValidations = validatableStep.validations
      validateResult = true

      if stepValidations? and _.has(stepValidations, validateType)
         validationParams = stepValidations[validateType]

         if validationParams? and validationParams.handler?
            validateResult = validationParams.handler()

      unless validateResult
         @setState
            popupParams:
               text: validationParams.message

      validateResult

   ###*
   * Функция-обработчик клика на элемент хлебного навигатора.
   *  Находит выбранный элемент в списке параметров шагов и если индекс этого
   *  элемента отличается от текущего выбранного - меняет его в состоянии
   *  компонента.
   *
   * @param {Object} stepParams - параметры шага.
   * @param {Object} event - параметры события.
   * @return
   ###
   _onClickBreadNavigatorItem: (stepParams, event) ->
      activatedStepIndex = @state.activatedStepIndex

      if @_isHasSteps()
         stepIndex = _.findIndex(@props.steps, stepParams)

         if stepIndex < activatedStepIndex
            @setState activatedStepIndex: stepIndex

   ###*
   * Функция-предикат для определения нужно ли показывать индикатор запроса.
   *  проверяет был ли запрошены данные для текущего шага, а также не заданы
   *  для этого шага параметры отображения (content или render).
   *
   * @return {Boolean}
   ###
   _isActivatedStepRequested: ->
      if @_isHasSteps()
         activatedStep = @_getActivatedStep()
         isActivatedStepHasView = activatedStep.render? or activatedStep.content?

         !isActivatedStepHasView and
          @state.stepRequestedFlags[@state.activatedStepIndex]
       else
         false

   ###*
   * Функция-предикат для проверки были ли заданы параметры шагов (на всякий
   *  случай защита от падений).
   *
   * @param {Array} steps - набор параметров шагов.
   * @return {Boolean}
   ###
   _isHasSteps: (steps) ->
      steps ||= @props.steps
      steps? and !_.isEmpty steps

   ###*
   * Функция-предикат для определения видна ли кнопка. Видимость определяется
   *  по наличию дальнейших шагов по функции кнопки(вперед/назад).
   *
   * @param {Boolean} isBack - флаг того, что проверка делается для кнопки "назад"
   *                           если флаг не задан, значит проверяется видимость для
   *                           кнопки "вперед".
   * @return {Boolean}
   ###
   _isControlButtonShown: (isBack) ->
      steps = @props.steps
      stepsCount = steps.length if steps? and !_.isEmpty(steps)
      activatedStepIndex = @state.activatedStepIndex

      if isBack
         activatedStepIndex > 0
      else
         (activatedStepIndex + 1) < stepsCount

   ###*
   * Метод проверки наличия параметра функции отправки начального запроса на получение
   *  содержимого текущей вкладки. Если для текущей вкладки задан параметр-функция
   *  отправки начального запроса - отправляет запрос.
   *
   * @param {Object} props - свойства с которыми работаем.
   * @param {Object} state - состояние с которыми работаем.
   * @return
   ###
   _checkAndSendInitRequest:(props, state) ->
      state ||= @state
      props ||= @props
      activatedStepIndex = state.activatedStepIndex
      activatedStep = @_getActivatedStep(activatedStepIndex, props.steps)
      stepRequestedFlags = _.clone(state.stepRequestedFlags)

      #if !activatedStep.render? and !activatedStep.content? and
      if activatedStep.initRequest? and !stepRequestedFlags[activatedStepIndex]
         activatedStep.initRequest()

         stepRequestedFlags[activatedStepIndex] = true

         @setState stepRequestedFlags: stepRequestedFlags

module.exports = Clerk
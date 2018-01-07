###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* HelpersMixin     - функции-хэлперы для компонентов.
* lodash           - модуль служебных операций.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
_ = require('lodash')

###* Зависимости: компоненты
* Button        - кнопка.
* ArbitraryArea - произвольная область
###
Button = require('components/core/button')
ArbitraryArea = require('components/core/arbitrary_area')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

###* Компонент: контейнер с возможностью скрытия/показа.
*
* @props :
*     {React-element} content      - содержимое области.
*     {String} title               - выводимая подсказка на компоненте.
*     {Object} triggerParams       - параметры для кнопки скрытия/показа области. Вид:
*           {Object} shown  - надпись при показанной панели. Если не задано берется
*                             по-умолчанию. Вид:
*                 {String} icon    - иконка.
*                 {String} caption - выводимая надпись.
*                 {String} title   - выводимая подсказка.
*           {Object} hidden - надпись при скрытой панели. Если не задано берется
*                             по-умолчанию.
*                 {String} icon    - иконка.
*                 {String} caption - выводимая надпись.
*                 {String} title   - выводимая подсказка.
*     {Object} clarificationParams - праметры для заголовка-пояснения к контейнеру.
*                                    Выводится на одном уровне с кнопкой-триггером. Вид:
*           {String} shown  - надпись при открытой панели.
*           {String} hidden - надпись при скрытой панели.
*     {Object} buttonParams        - параметры для кнопки. Через данный параметр можно
*                                    произвольным образом настроить кнопку. Принимаются
*                                    любые параметры кнопки. Параметры:
*                                    icon, caption, title, управляются через параметр
*                                    @props.triggerParams.
*     {Number} ajarHeight          - значение высоты "приоткрытости". Данный параметр
*                                    задает высоту изначально показанной нескрываемой части
*                                    области содержимого. Если данный параметр задан
*                                    и при этом все содержимое влезает в нескрываемую
*                                    часть области, то триггерная кнопка не создается.
*     {Object} areaParams          - параметры для произвольной области. Можно передать
*                                    любые параметры для области. Но привязка позиционирования
*                                    будет установлена в 'stream'. Контент будет передан
*                                    заданный в парметре @props.content. Целевой узел будет
*                                    управляться внутренней логикой компонента.
*  {Boolean} isMirrorClarification - флаг "зеркального" отображения поясняющей надписи.
*                                    Если флаг положительный, то отображает надписи, заданные
*                                    через @props.triggerParams в качестве поясняющей надписи,
*                                    только противоположно: shown - когда область скрыта.
*                                    hidden - когда область показана. По-умолчанию = false.
*     {Boolean} isTriggerTerminal  - флаг, превращающий кнопку скрытия/показа содержимого
*                                    в терминальную (то есть располагающуюся в конце содержимого с
*                                    заголовком по-умолчанию = '...'). По-умолчанию = false.
*     {Boolean} isShown            - флаг показа области. По-умолчанию = false
*     {Function} onClickTrigger    - обработчик, клика по кнопке разворачивания/сворачивания
*                                    содержимого контейнера. Аргументы:
*                                    {Object} event - объект события.
* @state :
*     {Boolean} isShown          - флаг показанности области.
*     {Object} areaContainerRect - параметры ограничений позиционирования области
*                                  с содержимым (размеры, позиционирование).
*     {Object} areaBorderSize    - параметыр размеров рамок области с содержимым.
###
StreamContainer = React.createClass

   # @const {Object} - параметры кнопки показа/скрытия области по-умолчанию.
   _TRIGGER_DEFAULT_PARAMS:
      shown:
         caption: 'Скрыть'
         title: 'Скрыть панель'
         captionTerminal: 'Свернуть'
         titleTerminal: 'Скрыть полное содержимое'
      hidden:
         caption: 'Показать'
         title: 'Показать панель'
         captionTerminal: '...'
         titleTerminal: 'Показать все'

   # @const {Object} - параметры по-умолчанию для кнопки.
   _BUTTON_DEFAULT_PARAMS:
      isLink: true

   # @const {Object} - параметры по-умолчанию для произовальной области.
   _AREA_DEFAULT_PARAMS:
      isHasBorder: false
      isCloseOnBlur: false
      isCatchFocus: false

   # @const {Object} - обязательные параметры для произвольной области.
   _AREA_STRONG_PARAMS:
      layoutAnchor: 'stream'

   mixins: [HelpersMixin]

   styles:
      clarification:
         color: _COLORS.hierarchy3
         fontSize: 11
         padding: _COMMON_PADDING

   PropTypes:
      clarificationParams: React.PropTypes.object
      triggerParams: React.PropTypes.object
      content: React.PropTypes.oneOfType([
         React.PropTypes.element
         React.PropTypes.string
      ])
      title: React.PropTypes.string
      isShown: React.PropTypes.bool
      isMirrorClarification: React.PropTypes.bool
      isTriggerTerminal: React.PropTypes.bool

   getDefaultProps: ->
      isShown: false
      isTriggerTerminal: false
      clarificationParams: {}

   getInitialState: ->
      isShown: @props.isShown
      areaSize: {}

   render: ->
      areaParams = @_getAreaParams()

      `(
         <div title={this.props.title}>
            {this._getOrdinaryTriggerContent()}
            <ArbitraryArea {...areaParams}
                           deadStyles={this._getAreaDeadStyles()}
                           target={this.state.isShown}
                           content={this.props.content}
                           onReady={this._onAreaReady}
                  />
            {this._getTerminalTrigger()}
         </div>
       )`

   ###*
   * Функция получения содержимого обычного переключателя показа/скрытия
   *  содержимого. Формирует содержимое, если не был задан флаг
   *  терминального триггера и содержимое полностью не показано с использованием
   *  параметра @props.ajarHeight.
   *
   * @return {React-element}
   ###
   _getOrdinaryTriggerContent: ->

      if !@props.isTriggerTerminal and @_isNeedTrigger()
         buttonParams = @_getButtonParams()
         triggerParams = @_getTriggerParams()

         `(
            <span>
               <Button {...buttonParams}
                       caption={triggerParams.caption}
                       title={triggerParams.title}
                       icon={triggerParams.icon}
                       onClick={this._onClickTrigger}
                     />
               {this._getHintClarification()}
            </span>
         )`

   ###*
   * Функция формирования концевой кнопки-триггера показанности содержимого.
   *  Триггер формируется, если установлен флаг @props.isTriggerTerminal
   *
   * @return {React-element}
   ###
   _getTerminalTrigger: ->
      if @props.isTriggerTerminal and @_isNeedTrigger()
         triggerParams = @_getTriggerParams()
         buttonParams = @_BUTTON_DEFAULT_PARAMS

         `(
            <Button {...buttonParams}
                    caption={triggerParams.caption}
                    title={triggerParams.title}
                    icon={triggerParams.icon}
                    onClick={this._onClickTrigger}
                 />
          )`


   ###*
   * Функция получения объекта с поясняющей надписью. Получает надписи из
   *  параметров @props.clarificationParams или если задан флаг isMirrorClarification
   *  из параметров @props.triggerParams
   *
   * @return {React-element}
   ###
   _getHintClarification: ->
      isMirrorClarification = @props.isMirrorClarification
      isHasClarificationParams = @_isHasClarificationParams()

      if isHasClarificationParams or isMirrorClarification
         clarificationParams = @props.clarificationParams
         isShown = @state.isShown

         # Пробуем считать параметр поясняющей надписи.
         #  Если заданы параметры поясняющей надписи - считываем из них,
         #  в зависимости от того показан контейнер или нет.
         #  Иначе, если установлен флаг "зеркального" считывания
         #  поясняющих надписей, считываем из параметров надписи на кнопке-триггере.
         clarification =
            if isHasClarificationParams
               if isShown
                  clarificationParams.shown
               else
                  clarificationParams.hidden
            else if isMirrorClarification
               triggerParams = @props.triggerParams

               triggerInscription =
                  if isShown
                     triggerParams.hidden
                  else
                     triggerParams.shown

               triggerInscription.caption if triggerInscription?

         if clarification?
            `(
               <span style={this.styles.clarification}>
                  {clarification}
               </span>
             )`
   ###*
   * Функция получения параметров кнопки показа/скрытия контейнера.
   *
   * @return {Object} - параметры кнопки.
   ###
   _getTriggerParams: ->
      defaultParams = @_TRIGGER_DEFAULT_PARAMS
      propParams = @props.triggerParams
      isHasTriggerParams = @_isHasTriggerParams()
      isTriggerTerminal = @props.isTriggerTerminal

      triggerParams =
         if @state.isShown
            (isHasTriggerParams and propParams.shown? and propParams.shown) or
             defaultParams.shown
         else
            (isHasTriggerParams and propParams.hidden? and propParams.hidden) or
            defaultParams.hidden

      if isTriggerTerminal
         if triggerParams.captionTerminal?
            triggerParams.caption = triggerParams.captionTerminal

         if triggerParams.titleTerminal?
            triggerParams.title = triggerParams.titleTerminal

      triggerParams


   ###*
   * Функция получения стилей для скрытой произвольной области. Функция необходима
   *  для компонента, для которого задан параметр @props.ajarHeight для задания
   *  частично нескрываемой области.
   *
   * @return {Object} - параметры для стилей
   ###
   _getAreaDeadStyles: ->
      ajarHeight = @props.ajarHeight

      if ajarHeight?
         height: ''
         display: ''
         maxHeight: ajarHeight

   ###*
   * Функция получения параметров для кнопки-триггера. Объединяет
   *  параметры по-умолчанию и параметры, заданные через свойства.
   *
   * @return {Object} - параметры произвольной области.
   ###
   _getButtonParams: ->
      defaultParams = @_BUTTON_DEFAULT_PARAMS
      propParams = @props.buttonParams

      @mergeObjects defaultParams, propParams

   ###*
   * Функция получения параметров для произвольной области. Объединяет
   *  параметры по-умолчанию, параметры, заданные через свойтсва и
   *  жестко заднанные параметры.
   *
   * @return {Object} - параметры произвольной области.
   ###
   _getAreaParams: ->
      strongParams = @_AREA_STRONG_PARAMS
      defaultParams = @_AREA_DEFAULT_PARAMS
      propParams = @props.areaParams

      @mergeObjects defaultParams, propParams, strongParams

   ###*
   * Функция-предикат для определения были ли заданны параметры надписей
   *  кнопки-триггера.
   *
   * @return {Boolean}
   ###
   _isHasTriggerParams: ->
      params = @props.triggerParams

      params? and !_.isEmpty params

   ###*
   * Функция-предикат для определения необходима ли триггерная кнопка
   *  для скрытия/показа содержимого. Кнопка не нужна в случае, если
   *  задан параметр "приоткрытости" и при этом высота области с содержимым
   *  (без учета рамки, если она задана) не превышает этот параметр.
   *
   * @return {Boolean}
   ###
   _isNeedTrigger: ->
      ajarHeight = @props.ajarHeight

      if ajarHeight?
         areaContainerRect = @state.areaContainerRect
         areaBorderSize = @state.areaBorderSize

         if areaContainerRect?
            containerHeight = areaContainerRect.height

            areaHeight =
               if areaBorderSize?
                  containerHeight - areaBorderSize.vertical
               else
                  containerHeight

            return areaHeight > ajarHeight

      true


   ###*
   * Функция-предикат для определения были ли заданны параметры
   *  заголовка-пояснения.
   *
   *
   * @return {Boolean}
   ###
   _isHasClarificationParams: ->
      params = @props.clarificationParams

      params? and !_.isEmpty params

   ###*
   * Обработчик по готовности произвольной области с содержимым к показу.
   *  Запоминает размеры области.
   *
   * @param {React-component} arbitraryArea - компонент произвольной области.
   * @param {Object} areaContainerRect      - праметры ограничений позиционирования.
   * @param {Object} areaBorderSize         - параметры размеров рамок области.
   * @return
   ###
   _onAreaReady: (arbitraryArea, areaContainerRect, areaBorderSize ) ->
      @setState
         areaContainerRect: areaContainerRect
         areaBorderSize: areaBorderSize

   ###*
   * Обработчик клика на кнопку триггера. Устанавливает флаг показа содержимого.
   *
   * @param {Object} _value - значение кнопки.
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickTrigger: (_value, event) ->
      onClickTriggerHandler = @props.onClickTrigger
      onClickTriggerHandler(event) if onClickTriggerHandler?

      @setState isShown: !@state.isShown


module.exports = StreamContainer
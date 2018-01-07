###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов.
* HelpersMixin     - функции-хэлперы для компонентов.
* keymirror        - модуль для генерации "зеркального" хэша.
* lodash                - модуль служебных операций.
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
AnimateMixin = require('react-animate')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты.
* ArbitraryArea     - произвольная область.
###
ArbitraryArea = require('components/core/arbitrary_area')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius

###* Компонент: Стек уведомлений. Принимает на вход параметры одного уведомления
*  и запоминает их в коллекцию. Отображет всю коллекцию уведомлений, показываемых
*  в данный момент, при скрытии уведомления (по клику на него) или по таймауту
*  удаляет уведомление из коллекции
*
* @props :
*     {Object} flash              - хэш параметров уведомлений. Вид:
*
*        {String} text            - содержимое информационного уведомления.
*        {String} identifier      - идентификатор уведомления(для исключения дубликатов).
*        {String} type            - тип уведомления. Варианты:
*                                   'success'     - зеленая,
*                                   'exclamation' - оранжевая,
*                                   'error'       - красная,
*                                   'info'        - синяя,
*     {Number} closeTimeout      - таймаут скрытия уведомления в мсек.
*     {React-Element} target     - целевой компонент, на котором будет выведено
*                                   уведомление.
*     {Function} onHide           - обработчик, запускаемый после скрытия всплывашки.
*                                   Аргументы:
*                                      popupName - имя всплывашки.
*     {Boolean} enableShowIdentifier    - флаг необходимости показа идентификатора уведомления.
* @state :
*     {Array<Object>} flashCollection - массив параметров уведомлений.
*     {Boolean} isFlashShifted        - флаг смещенных уведомлений (уведомления смещены).
###
PopupFlasher = React.createClass

   # @const {String} - префикс имени для уведомления.
   _FLASH_NAME_PREFIX: 'popupFlash'

   # @const {String} - наименование лейбла для идентификатора.
   _IDENTIFIER_LABEL: 'идентификатор'

   # @const {Object} - используемые символы.
   _CHARS:
      newLine: '\\n'
      colon: ':'

   # @const {Number} - максимально возможная отображаемая длина идентификатора
   # (если будет длиннее - вместо него будет отображен символ i)
   _MAX_IDENTIFIER_TITLE_LENGTH: 24

   # @const {Object} - параметры для произвольной области, отображающей уведомление.
   _FLASH_AREA_PARAMS:
      animationName: 'slideUp'
      position:
         vertical:
            bottom: 'bottom'
         horizontal:
            left: 'left'

   # @const {Object} - возможные типы уведомлений.
   _FLASH_TYPES: keyMirror(
      success: null
      error: null
      exclamation: null
      info: null
   )

   # @const {Object} - возможные иконки уведомлений.
   _FLASH_ICONS:
      success: 'check'
      error: 'times'
      exclamation: 'exclamation'
      info: 'info'

   # @const {String} - наименование префикса для иконок FontAwesome.
   _FA_ICON_PREFIX_NAME: 'fa fa-'

   mixins: [HelpersMixin]

   styles:
      tableFlashContent:
         maxWidth: 300
         fontSize: 11
         color: _COLORS.hierarchy2
         cursor: 'pointer'
      areaAddition:
         backgroundColor: ''
         boxShadow: "1px 2px 5px #{_COLORS.hierarchy2}"
      iconCell:
         fontSize: 35
         width: 40
         minWidth: 40
         color: _COLORS.light
         padding: _COMMON_PADDING
         opacity: 0.8
         textAlign: 'center'
      successIconCell:
         backgroundColor: _COLORS.success
      errorIconCell:
         backgroundColor: _COLORS.alert
      exclamationIconCell:
         backgroundColor: _COLORS.exclamation
      infoIconCell:
         backgroundColor: _COLORS.info
      textCell:
         padding: _COMMON_PADDING
      textFormatter:
         margin: 0
         fontFamily: 'inherit'
      identifierCell:
         textAlign: 'right'
         color: _COLORS.hierarchy3
         padding: _COMMON_PADDING

   propTypes:
      horizontalPosition: React.PropTypes.oneOf(['left', 'right'])
      verticalPosition: React.PropTypes.oneOf(['top','bottom'])
      target: React.PropTypes.object
      сontent: React.PropTypes.object
      closeTimeout: React.PropTypes.number
      onHide: React.PropTypes.func
      enableShowIdentifier: React.PropTypes.bool

   getDefaultProps: ->
      type: 'info'
      horizontalPosition: 'right'
      verticalPosition: 'bottom'
      closeTimeout: 5000
      enableShowIdentifier: false

   getInitialState: ->
      flashCollection: @_getInitFlashCollection()
      isFlashShifted: false

   componentWillReceiveProps: (nextProps) ->
      nextTarget = nextProps.target
      nextFlash = nextProps.flash

      # Проверим, если нужно добавить уведомление - добавляем, запоминаем
      #  в состояние компонента коллекцию и флаг необходимости сдвига уведомлений.
      if @_isNeedAddFlash nextTarget, nextFlash
         flashCollection = @state.flashCollection
         nextFlash.key = @_getNewFlashKey nextFlash.identifier
         unless nextFlash.type?
            nextFlash.type = @_FLASH_TYPES.info

         flashCollection.push(nextFlash)

         @setState
            flashCollection: flashCollection
            isFlashShifted: false

   shouldComponentUpdate: (nextProps, nextState) ->
      currentFlash = @props.flash
      nextFlash = nextProps.flash
      flashCollection = @state.flashCollection
      nextFlashCollection = nextState.flashCollection
      lastFlash = @_getLastFlash()
      isLastTextSame = lastFlash? and currentFlash.text is lastFlash.text
      isLastIdentifierSame = lastFlash? and currentFlash.identifier is lastFlash.identifier
      isNextTextExist = nextFlash.text? and nextFlash.text isnt ''
      isExistNextAndCurrentCollections = flashCollection? and
                                         flashCollection.length and
                                         nextFlashCollection? and
                                         nextFlashCollection.length

      # Если последнее уведомление совпадает с текущим по тексту и идентификатору -
      #  не обновляем.
      if isLastTextSame and isLastIdentifierSame
         false
      else
         # Если есть текст в следующем уведомлении задан текст - обновляем.
         if isNextTextExist
            true
         else
            # Если заданы коллекции уведомлений - обновляем если кол-во элементов
            #  в текущей коллекции и следующей не совпадают
            # Иначе не обновляем.
            if isExistNextAndCurrentCollections
               flashCollection.length isnt nextFlashCollection.length
            else
               true

   render: ->
      `(
         <div>{this._getAreaCollection()}</div>
       )`

   componentDidUpdate: (prevProps, prevState) ->
      isFlashShifted  = @state.isFlashShifted

      # Если уведомления не были ещё смещены - выполняем смещение, запоминаем
      #  флаг того что смещение выполнено.
      unless isFlashShifted
         @_shiftFlashCollection(prevState)

         @setState isFlashShifted: true

   ###*
   * Функция получения возможных типов уведомлений.
   *
   * @return {Object} - хэш с наименованиями возможных типов.
   ###
   getFlashTypes: ->
      @_FLASH_TYPES

   ###*
   * Функция получения коллекции компонентов уведомлений на осове компонента
   *  ArbitraryArea. Перебирает коллекцию параметров уведомлений с конца (для вывода
   *  последнего уведомления первым).
   *
   * @return {Array<React-DOM-Node>} - коллекция компонентов-произвольных областей с уведомлениями.
   ###
   _getAreaCollection: ->
      flashCollection = @state.flashCollection
      onHideHandler = @props.onHide
      areaTarget = @props.target
      areaParams = @_FLASH_AREA_PARAMS
      areaCollection = []

      flashCount = flashCollection.length
      i = flashCount - 1
      while i >= 0
         flash = flashCollection[i]
         flashKey = flash.key

         areaCollection.push(
            `(
               <ArbitraryArea key={flashKey}
                              ref={flashKey}
                              name={flashKey}
                              styleAddition={this.styles.areaAddition}
                              target={areaTarget}
                              isHasBorder={false}
                              isHasShadow={false}
                              isCatchFocus={false}
                              isCloseOnBlur={false}
                              isHasShadow={false}
                              closeTimeout={this.props.closeTimeout}
                              position={areaParams.position}
                              animation={areaParams.animationName}
                              content={this._getAreaContent(flash)}
                              onHide={this._onHideFlash}
                              onClick={this._onHideFlash}
                           />
               )`
         )
         i--

      areaCollection

   ###*
   * Функция формирования содержимого для области вывода всплывающего уведомления.
   *
   * @param {Object} flash - параметры сообщения.
   * @return {React-Element}
   ###
   _getAreaContent: (flash) ->
      types = @_FLASH_TYPES
      flashType = flash.type
      flashIcon = @_FLASH_ICONS[flashType]
      iconCellModifier = @styles["#{flashType}IconCell"]
      flashIdentifier = flash.identifier if @props.enableShowIdentifier
      opacityBackground =
         backgroundColor: @convertHex(_COLORS.light, 90)
      chars = @_CHARS

      iconCellStyle = @computeStyles @styles.iconCell,
                                     iconCellModifier

      textCellStyle = @computeStyles @styles.textCell,
                                     opacityBackground

      identifierCellStyle = @computeStyles @styles.identifierCell,
                                           opacityBackground
      textContent = @_getFlashTextContent(flash)
      # Если был передан форматированный текст(содержащий символ
      #  переноса строки), то выводим текст в контейнере для форматирования,
      #  иначе - просто выводим текст
      isTextFormatted = !!~textContent.indexOf(chars.newLine)


      flashContent = if isTextFormatted
                       `(<pre style={this.styles.textFormatter}>
                           {textContent}
                        </pre>)`
                     else
                        textContent

      # Если идентификатор слишком длинный для отображения - будем отображать
      #  символ идентификатора с подсказкой при наведении, отображающий полный
      #  идентификатор.
      identifierContent =
         if flashIdentifier?

            flashElement =
               if flashIdentifier.length > @_MAX_IDENTIFIER_TITLE_LENGTH
                 `(
                     <span title={flashIdentifier}>i...</span>
                  )`
               else
                  flashIdentifier

            `(
                <div>
                  {this._IDENTIFIER_LABEL}{chars.colon} {flashElement}
                </div>
             )`
      `(
          <table style={this.styles.tableFlashContent}>
            <tbody>
               <tr>
                  <td rowSpan={2}
                     style={iconCellStyle} >
                     <i className={this._FA_ICON_PREFIX_NAME + flashIcon} />
                  </td>
                  <td style={textCellStyle}>
                     {flashContent}
                  </td>
               </tr>
               <tr>

                  <td style={identifierCellStyle}>
                     {identifierContent}
                  </td>
               </tr>
            </tbody>
          </table>
       )`

   ###*
   * Функция получения смещения для предыдущего уведомления. Пытается получить смещение
   *  из коллекции, либо прочитать непосредственно у компонента-области, если она показана,
   *  либо при помощи костыльного способа через Jquery, если область еще не показана.
   *
   * @param {Object} prevFlash - параметры предыдущего уведомления.
   * @param {Boolean} isRemoveFromCollection - флаг того, что было удаление из коллекции.
   * @return {Object} - параметр смещения.
   ###
   _getOffsetToPrevArea: (prevFlash, isRemoveFromCollection) ->
      prevKey = prevFlash.key
      prevArea = @refs[prevKey]
      prevFlashOffset = prevFlash.topOffset

      if prevFlashOffset? and prevFlashOffset
         topOffset = prevFlashOffset
      else if prevArea.isShown()
         topOffset = $(ReactDOM.findDOMNode(prevArea)).offset().top
         unless isRemoveFromCollection
            topOffset -= prevArea.state.size.height
      else
         # АХТУНГ! костыльный метод определения смещения для скрытых элементов.
         $prevArea = $(ReactDOM.findDOMNode(prevArea))
         $clonedPrevArea = $prevArea.clone()
                     .css({visibility: 'hidden'})
                     .appendTo($prevArea.parent())
                     .show()
         $window = $(window)
         windowEdgeTop = $window.height() - _COMMON_PADDING
         clonedPrevAreaTop = $clonedPrevArea.position().top - window.scrollY
         topStart = if clonedPrevAreaTop < windowEdgeTop
                       clonedPrevAreaTop
                    else
                       windowEdgeTop

         topOffset = topStart - $prevArea.outerHeight()

         $clonedPrevArea.remove()

      topOffset

   ###*
   * Функция получения последнего уведомления из набора.
   *
   * @return {Object} - параметр последнего уведомления.
   ###
   _getLastFlash: ->
      flashCollection = @state.flashCollection

      if flashCollection? and flashCollection.length
         flashCollection[flashCollection.length - 1]

   ###*
   * Функция генерации нового ключа для уведомления.
   *
   * @param {Srting} identifier - идентификатор уведомления.
   ###
   _getNewFlashKey: (identifier) ->
      [@_FLASH_NAME_PREFIX, identifier, Date.now()].join('_')

   ###*
   * Функция получения начальной коллекции уведомлений.
   *
   * @return
   ###
   _getInitFlashCollection: ->
      if @_isNeedAddFlash @props.target, @props.flash
         firstFlash = @props.flash
         firstFlash.key =  @_getNewFlashKey firstFlash.identifier

         [@props.flash]
      else
         []

   ###*
   * Функция подготовки строки для вывода.
   *
   * @param {Object} flash - параметры сообщения.
   * @return {String}
   ###
   _getFlashTextContent: (flash) ->
      flashText = flash.text
      newLineChar = @_CHARS.newLine

      if _.isPlainObject(flashText)
         flashRows = []

         for elementName, element of flashText
            if _.isArray(element)
               flashRows = _.concat(flashRows, element)
            else
               flashRows.push element

         flashRows.join newLineChar
      else if _.isArray(flashText)
         flashRows = []

         for element in flashText
            if _.isPlainObject
               flashRows.push JSON.stringify element
            else
               flashRows.push element

         flashRows.join newLineChar
      else if _.isString(flashText)
         flashText
      else
         JSON.stringify flashText

   ###*
   * Функция-предикат для определения необходимости добавления нового уведомления
   *  в коллекцию. Добавление будет происходить если задан целевой узел и текст
   *  уведомления.
   *
   * @param {React-DOM-Node} target - целевой узел.
   * @param {Object} flash - параметры уведомления.
   * @return {Boolean}
   ###
   _isNeedAddFlash: (target, flash) ->
      flashCollection = @state.flashCollection if @state

      !!(target? and flash and flash.text and !$.isEmptyObject(target))

   ###*
   * Обработчик на скрытие произвольной области-уведомления. Производит поиск
   *  скрытого уведомления(по имени) в коллекции и удаляет его.
   *
   * @param {React-Element} flashArea - скрытая область.
   ###
   _onHideFlash: (flashArea) ->
      onHideHandler = @props.onHide
      areaName = flashArea.props.name

      onHideHandler areaName if onHideHandler?

      @_spliceFlash areaName

   ###*
   * Функция удаления из коллекции параметров уведомлений уведомления по имени.
   *
   * @param {String} flashName - имя уведомления.
   * @return
   ###
   _spliceFlash: (flashName) ->
      newFlashCollection = @state.flashCollection[..]

      for flash, idx in newFlashCollection
         if flash.key is flashName
            newFlashCollection.splice(idx,1)
            break

      @setState
         flashCollection: newFlashCollection
         isFlashShifted: false

   ###*
   * Функция выполения смещения уведомления. Двигает уведомления вверх, все уведомления,
   *  кроме первого. Либо выполняет смещение вниз, если было удаление уведомления из коллекции.
   *
   * @param {Object} prevState - предыдущее состояние.
   * @return
   ###
   _shiftFlashCollection: (prevState) ->
      flashCollection = @state.flashCollection
      prevFlashCollection = prevState.flashCollection
      flashCount = flashCollection.length
      prevFlashCount = prevFlashCollection.length
      isRemoveFromCollection = flashCount isnt prevFlashCount

      # Перебираем все элеменыт коллекции уведомлений, находим подходящий компонент-область
      #  в наборе refs и выполняем необходимое смещение.
      i = flashCount - 1
      while i >= 0
         flash = flashCollection[i]
         flashKey = flash.key
         areaElement = @refs[flashKey]
         isLastFlash = flashCount - 1 is i

         # Если это последнее уведомление
         if isLastFlash

            # Если было удаление из коллекции
            if isRemoveFromCollection
               prevFirstFlash = prevFlashCollection[prevFlashCount - 1]

               # Если предыдущее первое уведомление не данное (т.е. текущее последнее
               #  уведомление отличается от предыдущего) - выполним смещение вниз.
               if prevFirstFlash.key isnt flashKey
                  topOffset = areaElement.state.size.height +
                              areaElement.state.offset.top +
                              _COMMON_PADDING

                  flash.topOffset = topOffset
                  flashCollection[i] = flash

                  areaElement.setOffset(
                     top: topOffset
                  )

         else
            prevKey = i + 1
            prevFlash = flashCollection[prevKey]
            isPrevFirst = flashCount - 1 is prevKey

            topOffset = @_getOffsetToPrevArea(prevFlash, isRemoveFromCollection) -
                        areaElement.state.size.height -
                        _COMMON_PADDING

            flash.topOffset = topOffset
            flashCollection[i] = flash

            areaElement.setOffset(
               top: topOffset
            )

         i--


module.exports = PopupFlasher
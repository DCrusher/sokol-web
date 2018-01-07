###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов
* HelpersMixin     - функции-хэлперы для компонентов
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding

###* Компонент для отображения списка сообщений (обычно ошибки в формах)
*
* @props:
*     {String} caption       - выводимый заголовок
*     {Array} customMessages - массив хэшей с сообщениями. Используется для
*                       простого вывода сообщений. Формат:
*              {String} text: - текст
*              {String} type: - тип сообщения
*     {Object <{String}: {Array, String}>} formMessages - хэш с сообщениями по
*                       полям формы. Используется для вывода сообщений по
*                       полям формы. Представляет собой ассоциативный массив с
*                       парами имя поля(ключ) - массив ошибок или строка (значение)
*     {String} formMessagesType - строка типа сообщений формы. Возможные значения:
*                                 'error' (по-умолчанию)
*                                 'common'
*                                 'success'
###
Flasher = React.createClass
   mixins: [HelpersMixin]

   styles:
      common:
         fontSize: 10
         display: 'none'
         color: _COLORS.hierarchy2
      shown:
         display: ''
      caption:
         fontSize: 14

   propTypes:
      caption: React.PropTypes.string
      customMessages: React.PropTypes.array
      formMessages: React.PropTypes.oneOfType([
         React.PropTypes.object
         React.PropTypes.array
      ])
      formMessagesType: React.PropTypes.oneOf(['error', 'common', 'success'])

   getDefaultProps: ->
      customMessages: []
      formMessages: {}
      formMessagesType: 'error'

   render: ->

      computedStyle = @computeStyles @styles.common,
                                     @_isHasMessages() and @styles.shown

      `(
         <table style={computedStyle}>
            <tbody>
               <tr>
                  <td colSpan="2"
                      style={this.styles.caption} >
                     {this.props.caption}
                  </td>
               </tr>
                {this._getFlasherRows()}
            </tbody>
         </table>
       )`

   ###*
   * Функция получения массива строк с объектами FlasherRows, содержащих
   *  сообщения
   *
   * @return {Array<React-Element>} - массив реакт-компонентов.
   ###
   _getFlasherRows: ->
      flasherRows = []
      customMessages = @props.customMessages
      formMessages = @props.formMessages

      ###*
      * Функция создания компонента строки флешера.
      *
      * @param {String} label      - заголовок строки.
      * @param {Object} messageObj - содержимое сообщения(текст, тип).
      * @param {Number} index      - индекс строки в наборе.
      ###
      getRow = (label, messageObj, index) ->
         `( <FlasherRow key={index}
                        messageLabel={key}
                        messageObj={messageObj} /> )`

      # если есть нестандартные сообщения - сформируем строки с сообщениями
      if customMessages.length
         flasherRows = @props.customMessages.map (message, idx) ->
            getRow('', message, idx)

      # `(<FlasherRow key={index}
      #         messageObj={message} />)`

      # если есть сообщения по полям формы - сформируем строки с сообщениями
      if !$.isEmptyObject(formMessages)

         if Array.isArray(formMessages)
            for message, idx in formMessages
               messageObj =
                  text: message
                  type: @props.formMessagesType

               flasherRows.push(getRow('', messageObj, idx))
         else
            messageIndex = flasherRows.length

            # переберем все значения сообщений по полям формы
            for key of formMessages
               message = formMessages[key]

               if formMessages.hasOwnProperty key
                  if message
                     messageObj =
                        text: message
                        type: @props.formMessagesType
                     flasherRows.push(getRow(key, messageObj, messageIndex))
                     messageIndex++

      flasherRows

   ###*
   * Функция-предикат проверки наличия сообщений в компоненте.
   *  Проверяет кастомные сообщения и затем, если соощения не были найдены
   *  проверяет наличие сообщений формы.
   *
   * @return {Boolean} - флаг наличия сообщений
   ###
   _isHasMessages: ->
      isHasMessages = false
      customMessages = @props.customMessages
      formMessages = @props.formMessages

      # проверим сначала кастомные сообщения - если есть, значит есть сообщения
      if customMessages && customMessages.length
         isHasMessages = true

      # если пока флаг наличия сообщений не установлен и объект сообщений формы
      # пустой - продолжим
      if !isHasMessages && !$.isEmptyObject(formMessages)

         # переберем все значения сообщений по полям формы
         for key of formMessages
            message = formMessages[key]

            if formMessages.hasOwnProperty key
               # если сообщение не пустое - значит есть что выводить
               if message
                  isHasMessages = true
                  break

      isHasMessages


### Компонент строки списка сообщений. Часть компонента Flasher.
* @props:
*     {Object} messageObj   - Объект с параметрами сообщения
*     {String} messageLabel - Лейбл сообщения(например, название поля, по
                              которому выводистя сообщение)
###
FlasherRow = React.createClass
   mixins: [HelpersMixin]

   styles:
      labelCell:
         verticalAlign: 'top'
         textAlign: 'right'
         paddingRight: 4
         fontWeight: 'bold'
      textCell:
         textAlign: 'left'
      error:
         color: _COLORS.alert
      success:
         color: _COLORS.success
      common:
         color: _COLORS.hierarchy3

   propTypes:
      messageObj: React.PropTypes.object
      messageLabel: React.PropTypes.string

   render: ->
      computedStyleMessage = @computeStyles this.styles.textCell,
                                            @_getMessageStyle()
      messageLabel = @props.messageLabel
      label = if messageLabel then [messageLabel, ':'].join('') else ''


      `(
         <tr>
            <td style={this.styles.labelCell}>
               {label}
            </td>
            <td style={computedStyleMessage}>
               {this._getMessages()}
            </td>
         </tr>
      )`

   ###*
   * Функция получения содержимого ячейки сообщения. Проверяет, если
   *  в параметр message был передан массив - формирует отдельные
   *  блочные элементы для каждого элемента массив, иначе возвращает
   *  просто строку с сообщением.
   *
   * @return {String, Array} - элемент/элементы с сообщением
   ###
   _getMessages: ->
      message = @props.messageObj.text || @props.messageObj.errors

      # если был передан массив сообщений формируем несколько объектов
      # с сообщениями
      if Object.prototype.toString.call(message) == "[object Array]"
         messageRows = message.map (mes, index) ->
            `( <div key={index}>{mes}</div> )`
      else
         messageRows = message

      messageRows



   ###*
   * Функция возвращает стиль в зависимости от типа сообщения
   *
   * @return {Object} - стиль из параметра styles
   ###
   _getMessageStyle: ->
      type = @props.messageObj.type

      switch type
         when 'error'
            return @styles.error
         when 'success'
            return @styles.success
         when 'common'
            return @styles.common
         else
            return @styles.common

module.exports = Flasher

###* Зависимости: модули
* crc        - модуль для генерации crc хэш-суммы.
* numeral          - модуль для числовых операций.
* moment           - модуль форматирования даты.
###
crc = require('crc')
moment = require('moment')

###*
* Модуль хелперов, необходимых в различных компонентах
###
helpers =

   ###*
   * Функция получения crc32 хэш-суммы для строки.
   *
   * @param {String} targetString - строка, для которой считается сумма.
   * @param {String} - хэш-сумма.
   ###
   crc32FromString: (targetString) ->
      crc.crc32(targetString).toString()

   ###*
   * Функция-алиас для склеивания объектов. Используется для объединения стилей.
   *
   * @return {Object} - смерженный хэш.
   ###
   computeStyles: ->
      @mergeObjects.apply(this, arguments)

   ###*
   * Функция для склеивания нескольких объектов в один.
   *
   * @return {Object} - смерженный хэш.
   ###
   mergeObjects: ->
      res = {}
      i = 0
      while i < arguments.length
         if arguments[i]
            res = React.addons.update res, $merge: arguments[i]
         ++i
      res

   ###*
   * Функция серилизации значения параметров в строку для передачи в http запросе.
   *  и присоединения к уже существующей строке http-запроса.
   *  Содрана с библиотеки form-serialize.
   *
   * @param {String} result     - выходная строка.
   * @param {String} key        - ключ значения (например, имя поля).
   * @param {String, ...} value - значение.
   ###
   strUriSerialize:(result, key, value) ->

      if value? and value isnt ''
         # encode newlines as \r\n cause the html spec says so
         value = value.replace(/(\r)?\n/g, '\r\n')
         value = encodeURIComponent(value)

         # spaces should be '+' rather than '%20'.
         value = value.replace(/%20/g, '+')

      joinChar = result? and '&'
      newValue = encodeURIComponent(key) + '=' + value

      [
         result
         joinChar
         newValue
      ].join ''

   ###*
   * Функция конвертации строки даты/времени в читаемый формат.
   *
   * @param {String} dateSting - строка даты
   * @return {String}
   ###
   convertToHumanDateTime: (dateString) ->
      if dateString?
         moment.utc(dateString).format('DD.MM.YYYY, HH:mm:ss')
      else
         '-'


   ###*
   * Функция конвертации строки даты в читаемый формат.
   *
   * @param {String} dateSting - строка даты
   * @return {String}
   ###
   convertToHumanDate: (dateString) ->
      if dateString?
         moment.utc(dateString).format('DD.MM.YYYY')
      else
         '-'


   ###*
   * Хэлпер для конвертации цвета из HEX в RGBA. Нужен для создания цвета из
   *  стилей с прозрачностью.
   *
   * @param {String} hex     - шестнадцатиричное значение цвета.
   * @param {Number} opacity - значение прозрачности. Диапозон 0..100.
   * @return {Object} - смерженный хэш
   ###
   convertHex: (hex, opacity) ->
      hex = hex.replace '#', ''
      r = parseInt(hex.substring(0, 2), 16)
      g = parseInt(hex.substring(2, 4), 16)
      b = parseInt(hex.substring(4, 6), 16)

      ['rgba(', r, ',', g, ',', b, ',', opacity / 100,  ')'].join ''

   ###*
   * Функция-обертка для запуска функции с заданной задержкой.
   *
   * @param {Number} ms     - задержка (в мсек).
   * @param {Function} func - функция, запускаемая по таймауту.
   * @return {Number} - идентификатор таймаута.
   ###
   delay: (ms, func) ->
      setTimeout func, ms


   ###*
   * Функция-предикат для определения соответствия вхождения подстроки expression
   *  в строку valueString (регистронезависимо).
   *
   * @param {String} valueString - строка.
   * @param {String} expression - подстрока поиска.
   * @return {Boolean}
   ###
   isMatchedExpression: (valueString, expression) ->
      isMatched = true

      if expression? and expression isnt ''
         regExp = new RegExp(expression, 'gi')

         isMatched = regExp.test valueString

      isMatched


module.exports = helpers
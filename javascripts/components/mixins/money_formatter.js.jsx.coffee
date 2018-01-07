###* Зависимости: модули
* crc        - модуль для генерации crc хэш-суммы.
* numeral          - модуль для числовых операций.
###
numeral = require('numeral')

numeral.language('ru',
   delimiters:
      thousands: ' '
      decimal: '.'
   abbreviations:
      thousand: 'тыс'
      million: 'млн'
      billion: 'млрд'
      trillion: 'трлн'
   ordinal: (number) ->
      return if number is 1 then 'рубль' else 'рублей'
   currency:
      symbol: '₽'
)

numeral.language('ru')

###*
* Модуль хелперов, работы с денежным форматом.
###
module.exports =

   # @const {Object} - регулярные выражения для денежного формата.
   _MONEY_REGEXS:
      # для начальной замены разделителя дробной части с "," на "."
      initCommaDivider: /,{1}(?=\d{1,2}$)/
      # для разделения целой и дробной части.
      divider: /[.]/gi
      # для поиска разделителей значения денежного формата поля ввода.
      rankDivider: /[\s]/gi
      # для отфильтровки всего кроме копеек в дробной части суммы.
      decimalPart: /(\d{1,2})/gi

   # @const {Number} - делитель суммы в копейках для преобразования в рубли.
   _RUBLE_CONVERTER: 100

   # @const {String} - формат для денежного.
   _MONEY_INPUT_FORMATS:
      ordinary: '0,[0].00'
      symbolized: '0,[0].00 $'

   # @const {Object} - различные форматы денежного формата.
   _MONEY_TYPES:
      dime: ['integer']
      rub: ['decimal', 'float']

   # @const {Object} - используемые литералы.
   _MONEY_CHARS:
      point: '.'
      comma: ','
      empty: ''
      space: ' '
      negative: '-'

   ###*
   * Функция преобразование денежной суммы в зависимости от типа (целое, дробное)
   *  в форматированную строку для вывода.
   *
   * @param {Number} moneyAmount     - числовое значение денежной суммы.
   * @param {String} moneyType       - тип денежного значения (дробный/целый).
   * @param {Boolean} isWithSymbol   - флаг вывода суммы с символом.
   * @return {String}
   ###
   formatMoney: (moneyAmount, moneyType, isWithSymbol) ->
      if moneyAmount?
         outputAmount =
            if @isDimeLevel(moneyType)
               moneyAmount / @_RUBLE_CONVERTER
            else
               moneyAmount

         @formattedMoney(outputAmount, isWithSymbol)

   ###*
   * Функция для преобразования денежной суммы в формат для сохранения в базе.
   *  В зависимости от типа преобразует либо к целочисленному формату (без
   *  разделителей строки) либо к дробному формату (через билиотеку работы с
   *  числами).
   *
   * @param {String} moneyOutput - строка денежной суммы.
   * @param {String} moneyType   - тип денежного поля.
   * @return {String, Number}
   ###
   unformatMoney: (moneyOutput, moneyType) ->
      if @isDimeLevel(moneyType)
         emptyChar = @_MONEY_CHARS.empty
         moneyRegexs = @_MONEY_REGEXS

         moneyOutput.toString()
                    .replace(moneyRegexs.divider, emptyChar)
                    .replace(moneyRegexs.rankDivider, emptyChar)
      else
         numeral().unformat(moneyOutput)

   ###*
   * Функция преобразования строки денежного значения в общепринятый удобочитаемый
   *  формат с разделителями разрядов и дробной части.
   *
   * @param {String} moneyInput    - строка денежной суммы.
   * @param {Boolean} isWithSymbol - флаг вывода суммы с символом.
   * @return {String}
   ###
   formattedMoney: (moneyInput, isWithSymbol) ->
      moneyFormats = @_MONEY_INPUT_FORMATS
      chars = @_MONEY_CHARS
      isNegativeChar = moneyInput is chars.negative
      amountFormat =
         if isWithSymbol
            moneyFormats.symbolized
         else
            moneyFormats.ordinary
      moneyInput = @_normalizeMoneyInput(moneyInput)

      formattedOutput =
         if moneyInput?
            numeral(moneyInput).format(amountFormat)

      if isNegativeChar
         [moneyInput, formattedOutput].join chars.empty
      else
         formattedOutput


   ###*
   * Функция-предикат для определения уровня денежной суммы в зависимости от
   *  заданного типа - это целый формат (копейки), в остальных случаях дробный
   *  формат - рубли.
   *
   * @return {Boolean} moneyType - тип поля денежного формата.
   ###
   isDimeLevel: (moneyType) ->
      !!~_.indexOf(@_MONEY_TYPES.dime, moneyType)

   ###*
   * Функция определения позиции каретки для поля ввода денежной суммы.
   *
   * @param {String} rawValue             - старое значение в поле ввода.
   * @param {String} convertedValue       - новое значение в поле ввода.
   * @param {String} currentValue         - текущее значение в поле ввода.
   * @param {Number} currentCaretPosition - текущая позиция каретки.
   * @return {Number}
   ###
   getMoneyInputCaretPosition: (rawValue, convertedValue, currentValue, currentCaretPosition) ->
      chars = @_MONEY_CHARS
      pointChar = chars.point
      spaceChar = chars.space
      newChar = convertedValue[0]
      fillerSymbols = [pointChar, spaceChar]
      rawStringFillerCount = 0
      convertedStringFillerCount = 0
      isDeleteChar = rawValue? and currentValue? and
                     rawValue.length < currentValue.length

      # Если новый ввод в поле денежных сумм - это удаление символа - вернем
      #  текущую позицию каретки(самый простой вариант), так как учитывать
      #  удаление слишком громоздко. Такой подход может в некоторых случаях
      #  давать неудобный ввод, но в большинстве случаев будет приемлимо.
      return currentCaretPosition if isDeleteChar

      # Определим новый введенный символ
      if currentValue?
         for i in [0..rawValue.length]
            oldValueChar = rawValue[i]
            currentValueChar = currentValue[i]

            if oldValueChar isnt currentValueChar
               newChar = oldValueChar
               break

      isNewCharIsDelimiter = newChar is pointChar

      # Если новый введенный символ - символ разделителя рублей и копеек ('.') -
      #  возвращаем позицию следующую за точкой.
      if isNewCharIsDelimiter
         convertedValue.indexOf(pointChar) + 1
      else
         rawTruncatedValue = rawValue.substring(0, convertedValue.length)

         for fillerSym in fillerSymbols
            rawStringFillerCount += rawTruncatedValue.split(fillerSym).length - 1
            convertedStringFillerCount += convertedValue.split(fillerSym).length - 1

         caretDelta = convertedStringFillerCount - rawStringFillerCount
         currentCaretPosition + caretDelta

   ###*
   * Функция для проведения процедур нормализации денежной суммы. Производит
   *  обработку только для строковых значений. Отдельно определяет дробную часть
   *  по первому вхождению делителя ('.') и целую и затем склеевает в простое
   *  вещественное число. Данная функция нужна для того, чтобы если в строке
   *  в которой есть разделитель и был новый разделитель - переопределить
   *  строковое представление вещественного числа с перенесением разделителя в
   *  новую позицию.
   *
   * @param {String} moneyInput - строка денежной суммы.
   * @return {String}
   ###
   _normalizeMoneyInput: (moneyInput) ->
      if _.isString(moneyInput)
         chars = @_MONEY_CHARS
         moneyRegexs = @_MONEY_REGEXS
         decimalDevider = chars.point
         processedMoneyInput =
            moneyInput.replace(moneyRegexs.initCommaDivider, chars.point)
                      .replace(moneyRegexs.rankDivider, chars.empty)
         dividerIndex = processedMoneyInput.indexOf(decimalDevider)

         # Если разделитель дробной части найден в значении
         if dividerIndex >= 0 and (dividerIndex isnt (processedMoneyInput.length - 1))

            integerPart = processedMoneyInput.substring(0, dividerIndex)
            otherPart =
               processedMoneyInput.substring(dividerIndex)
                                  .replace(moneyRegexs.divider, chars.empty)
            decimalParts = otherPart.match(moneyRegexs.decimalPart)
            dimePart = decimalParts[0] unless _.isEmpty(decimalParts)

            return [integerPart, dimePart].join decimalDevider

      moneyInput
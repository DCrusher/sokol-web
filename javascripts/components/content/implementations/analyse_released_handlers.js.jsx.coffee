###* @jsx React.DOM ###


###* Зависимости: модули
* request          - модуль работы с ajax-запросами.
* string-template       - модуль для форматирования строк.
###
request = require('superagent')
format = require('string-template')

###*
* Модуль для хранения обработчиков для таблицы проведенных анализов.
*
###
module.exports =
   # @const {String} - адрес для получения печатной формы по проведенному анализу.
   _PRINT_FORM_ENDPOINT_TEMPLATE: "analyses/{id}/print_form.json"

   # @const {Object} - элементы для формирования параметров формата взаимодействия с API.
   _FORMAT_ELEMENTS:
      format: 'json'
      acceptRequest: 'Accept'
      acceptFormat: 'application/json'

   ###*
   * Функция-обработчик на запрос печатной формы по проведенному анализу.
   *
   * @param {Object} analyseReleased - запись по проведенному анализу.
   ###
   getAnalyseReleasedPrintForm: (analyseReleased) ->
      formatElements = @_FORMAT_ELEMENTS
      endpoint = format(@_PRINT_FORM_ENDPOINT_TEMPLATE, id: analyseReleased.key)

      request.get(endpoint)
             .set(formatElements.acceptRequest, formatElements.acceptFormat)
             .end (error, response) ->
                result = JSON.parse(response.text)

                if result.file?
                   location.href = result.file

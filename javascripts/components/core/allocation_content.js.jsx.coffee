###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов
###
StylesMixin = require('../mixins/styles')

###* Константы
* _COLORS               - цвета
###
constants = StylesMixin.constants
_COLORS = constants.color

###* Компонент для отображения контента с выделением по переданному выражению
*  @props:
*     {String} content    - контент, который нужно отображать
*     {String} expression - выражение, по которому ищется подстрока,
*                           которую нужно выделять
*     {String} highlightColor - цвет выделения
###
AllocationContent = React.createClass

   getDefaultProps: ->
      highlightColor: _COLORS.highlight1

   render: ->
      actionContent = ''

      `(
         <span>{this._getActionContent()}</span>
       )`

   ###*
   * Функция получает контент с выделением по выражению
   * @return {JSX-object} or {String}
   ###
   _getActionContent: ->
      expression = @props.expression
      content = @props.content
      actionContent = content

      # сформируем регулярку с запоминаемым значением(досутпна из $1),
      # нечувствительной к регистру и глобальной (по всему тексту)
      searchStr = ['(', expression, ')'].join('')
      regExpSearch = new RegExp(searchStr, 'gi')

      # Если поисковое выражение не пустое - будем проверять
      # на соответствие выражению
      if expression

         # Если подстрока поискового запроса найдена в имени пункта -
         # то продолжим
         if regExpSearch.test(content)

            # Сформируем отрывающий тэг для подсветки
            highlightTagOpen = [
               '<span style = "color:'
               @props.highlightColor
               '; text-decoration: underline;">'
            ].join('')

            # в контенте заменим все вхождения подстроки на подстроку,
            # обернутую в подсвечивающий тэг
            if content?
               content = content.toString().replace(regExpSearch,
                                      [highlightTagOpen, '$1</span>'].join(''))

            # сформируем jsx выражение со вставкой сырого HTML
            actionContent = `(<span dangerouslySetInnerHTML={{__html: content}} />)`

      actionContent

module.exports = AllocationContent
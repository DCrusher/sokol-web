###*
* Модуль для операций с узлами DOM. Нужен для создания аналогов функций jquery
*  (для последующего отказа) и др. необходимых в компонентах функций.
###

domOperations =


   # outerHeight: (elm) ->

   #    if (document.all)   # IE
   #      elmHeight = elm.currentStyle.height
   #      elmMargin =
   #          parseInt(elm.currentStyle.marginTop, 10) +
   #          parseInt(elm.currentStyle.marginBottom, 10)
   #    else                # Mozilla
   #       elmHeight =
   #          parseInt(
   #             document.defaultView
   #                     .getComputedStyle(elm, '')
   #                     .getPropertyValue('height')
   #          )
   #       elmMargin =
   #          parseInt(document.defaultView.getComputedStyle(elm, '').getPropertyValue('margin-top')) + parseInt(document.defaultView.getComputedStyle(elm, '').getPropertyValue('margin-bottom'))

   #    elmHeight + elmMargin

   ###*
   * Функция получения высоты компонента с отсупами последнего и первого дочернего
   *  узлов(при наличии). Функция возвращает высоту элемента для последующего
   *  сравнения его с scrollHeight с целью проверки наличия прокрутки.
   *
   * @param {DOM-Node} - целевой узел.
   * @return {Number} - высота с отступами дочерних элементов.
   ###
   _heightWithChildrenMargin: (elm)->
      firstChild = elm.firstChild
      lastChild = elm.lastChild
      clientHeight = elm.clientHeight
      resultHeight = clientHeight

      if firstChild? and firstChild.nodeType is 1
         marginTopVal = firstChild.style.marginTop
         marginTop = if marginTopVal isnt ''
                        parseInt(marginTopVal)
                     else
                        0

      if lastChild? and lastChild.nodeType is 1
         marginBottomVal = lastChild.style.marginBottom
         marginBottom = if marginBottomVal isnt ''
                           parseInt(marginBottomVal)
                        else
                           0

      resultHeight + marginBottom + marginTop

   ###*
   * Функция-предикат для определения имеет ли элемент вертикальную прокрутку.
   *
   * @param {DOM-Node} - целевой узел.
   * @param {Number} allowanceSize - размер погрешности.
   * @return {Boolean}
   ###
   _isHasVerticalScroll: (elm, allowanceSize) ->

      elm.clientHeight + (allowanceSize or 0)  < elm.scrollHeight

   ###*
   * Функция-предикат для определения имеет ли элемент горизонтальную прокрутку.
   *
   * @param {DOM-Node} elm - целевой узел.
   * @param {Number} allowanceSize - размер погрешности.
   * @return {Boolean}
   ###
   _isHasHorizontalScroll: (elm, allowanceSize) ->

      elm.clientWidth + (allowanceSize or 0) < elm.scrollWidth

   ###*
   * Возвращает ближайшего родителя, у которого установлен скролл, или, в случае,
   *  если такого не имеется, возвращает document. В случае, если ближайший родитель
   *  со скроллом - body возвращает также document
   *
   * @param {DOM-Node} elm - целевой узел.
   * @return {DOM-Node} - родитель со скроллом или document.
   ###
   _getScrollParent: (elm)->
      $elm = $(elm)
      overflowRegex = /(auto|scroll)/
      position = $elm.css('position')
      isExcludeStaticParent = position is 'absolute'

      scrollParent = $elm.parents().filter(->
         parent = $(this)
         if isExcludeStaticParent and parent.css('position') is 'static'
            return false
         isParentHasSize = parent.clientHeight > 0 and parent.clientWidth > 0
         isHasOverflow =
            overflowRegex.test parent.css('overflow') + parent.css('overflow-y') + parent.css('overflow-x')

         isParentHasSize and isHasOverflow
      ).eq(0)

      if position is 'fixed' or !scrollParent.length
         $($elm[0].ownerDocument or document)
      else
         scrollParent

   ###*
   * Функция-предикат для определения находится ли фокус на узле.
   *
   * @param {DOM-node} - целевой узел.
   * @return {Boolean}
   ###
   _isNodeFocused: (node) ->
      node is document.activeElement

   ###*
   * Функция-предикат для определения виден ли узел.
   *
   * @param {DOM-node} - целевой узел.
   * @return {Boolean}
   ###
   _isNodeVisible: (node) ->
      if node?
         node.clientWidth isnt 0 and
         node.clientHeight isnt 0 and
         node.style.opacity isnt 0 and
         node.style.visibility isnt 'hidden'
      else
         false




module.exports = domOperations
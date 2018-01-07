###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов
* HelpersMixin     - функции-хэлперы для компонентов
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')

###* Зависимости: компоненты
* Button - кнопка-ссылка
###
Button = require('./button')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
* _ICON_CONTAINER_WIDTH - константа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding

###* Компонент: Хлебные крошки
*  @props
*     {Array} initData - данные, поступающие на вход компонента в формате строки
*                         , в виде 'a/b/c/../z', либо массива в формате [a,b..z]
*                         , либо хэша в формате
*                         [{value:'value',caption:'caption'}, ......
*                         ......, {value:'value',caption:'caption'}]
*     {Function} onClickNavigation - функция, принимаемая компонентом, которая
*                         возвращает текущий путь по нажатию на кнопку-ссылку
*  @state
*     {Array} itemsArray        - массив всех элементов, первоначально
*                                отправленных в компонент
*     {Array} selectedPathArray - массив текущих элементов, необходим для
*                                отслеживания и отправки текущего адреса
*     {Boolean} isServiceCell   - флаг, указывающий, что кнопки прокрутки не
*                                 нужны
###
BreadcrumbNavigation = React.createClass

   mixins: [HelpersMixin]
   # флаг, необходимый для показа/скрытия кнопок прокрутки
   _clickScrollButton: true

   styles:
      tableWrapper:
         width: '100%'
         tableLayout: 'fixed'
      serviceCell:
         width:22
         position: 'relative'
         zIndex: 1
      HideServiceCell:
         display: 'none'
      container:
         position:'relative'
         whiteSpace:'nowrap'
         overflowX: 'hidden'
         margin: 0
      scrollButton:
         backgroundColor: 'transparent'
         borderColor: 'transparent'
         opacity: 0.3
         fontSize: 'xx-large'
      common:
         display:'inline-block'
         margin: '0 .5em 0 1em'
      itemCell:
         background: '#ddd'
         padding: '.7em 1em'
         float: 'left'
         textDecoration: 'none'
         color: '#444'
         textShadow: '0 1px 0 rgba(255,255,255,.5)'
         position: 'relative'
         whiteSpace:'nowrap'
      beforeTriangle:
         position: 'absolute'
         top: '50%'
         marginTop: '-1.5em'
         borderWidth: '1.5em 0 1.45em 1em'
         borderStyle: 'solid'
         borderColor: '#ddd #ddd #ddd transparent'
         left: '-1em'
      afterTriangle:
         position: 'absolute'
         top: '50%'
         marginTop: '-1.5em'
         borderTop: '1.5em solid transparent'
         borderBottom: '1.5em solid transparent'
         borderLeft: '1em solid #ddd'
         right: '-1em'
      buttonLink:
         color: 'rgb(7, 62, 132)'
         cursor: 'pointer'
         borderColor: 'transparent'
         backgroundColor: 'transparent'
         textDecoration: 'underline'
         borderWidth: '0.25em'

   propTypes:
      initData: React.PropTypes.oneOfType [
            React.PropTypes.string
            React.PropTypes.array
         ]
      onClickNavigation: React.PropTypes.func

   getDefaultProps: ->
      initData: []


   getInitialState: ->
      itemsArray: @_fromStringToArray()
      selectedPathArray: @_fromStringToArray()
      isServiceCell: true
      isScrollButtonLeft: true
      isScrollButtonRight: true

   render: ->
      pathArray = @state.selectedPathArray
      pathCount = pathArray.length - 1
      contents = []

      scrollButtonLeft = @computeStyles @styles.serviceCell,
                                        !@state.isScrollButtonLeft and
                                        @styles.HideServiceCell,
                                        !@state.isServiceCell and
                                        @styles.HideServiceCell

      scrollButtonRight = @computeStyles @styles.serviceCell,
                                         !@state.isScrollButtonRight and
                                         @styles.HideServiceCell,
                                         !@state.isServiceCell and
                                         @styles.HideServiceCell

      index = 0
      for path in pathArray
         contents.push(@_getItem path, index)
         index++

      `(
         <table style={this.styles.tableWrapper}>
            <tbody>
               <tr>
                  <td style={scrollButtonLeft}
                      onMouseOut={this._onMouseOut}
                      onMouseOver={this._onMouseOverLeft}>
                      <Button icon={'chevron-left'}
                              isLink={true}
                              style={this.styles.scrollButton}/>
                  </td>

                  <td >
                     <ol  ref="breadcrumbBody" style={this.styles.container}>
                        {contents}
                     </ol>
                  </td>

                  <td style={scrollButtonRight}
                      onMouseOut={this._onMouseOut}
                      onMouseOver={this._onMouseOverRight}>
                      <Button icon={'chevron-right'}
                              isLink={true}
                              style={this.styles.scrollButton}/>
                  </td>
               </tr>
            </tbody>
         </table>
      )`

   componentDidUpdate: (nextProps, nextState) ->
      if @_clickScrollButton
         @_HideServiceCell()

   componentDidMount: ->
      @_HideServiceCell()

   ###*
   * Функция, необходимая для инициализации @state.itemsArray и
   *  @state.selectedPathArray. Преобразует строку вида 'a/b/../z' или массив в
   *  формате [a,b..z] в массив в формате [{value:'a',caption:'a'} ,............
   *  ...,{value:'z',caption:'z'}]
   ###
   _fromStringToArray: ->
      propInitData = @props.initData

      return unless propInitData

      if $.isArray propInitData #@props.initData[0].value != undefined
         propInitData
      else
         if typeof propInitData == 'string'
            initData = propInitData.split('/')
         else
            initData = propInitData
         returnInitData = []
         i=0;
         while i < initData.length
            returnInitData.push new Object()
            returnInitData[i].value = initData[i]
            returnInitData[i].caption = initData[i]
            i++
         returnInitData

   ###*
   * Функция восстанавливает состояние, изначально переданное в компонент
   ###
   _toGetToTheEnd: ->
      @setState
         selectedPathArray: @state.itemsArray


   ###*
   * Функция, возвращающая название (value.caption) отдельной ячейки в render.
   * @params
   *     {string} value - значение передаваемого объекта
   *     {number} index - индекс передаваемого объекта
   *
   ###
   _getItem: (value, index) ->
      `(
         <li style={this.styles.common}>
            <a key={index}
                 style={this.styles.itemCell}>
               <div style={this.styles.beforeTriangle}></div>
               <Button isLink={true}
                       caption={value.caption}
                       value={index}
                       onClick={this._onItemSelect}
                       styleAddition={this.styles.buttonLink}/>
               <div style={this.styles.afterTriangle}></div>
            </a>
         </li>
      )`

   ###*
   * Функция, обрезающая текущий массив объектов до объекта, с передаваемым
   *  индексом. Вызывается по клику на объект, по завершении отправляет строку с
   *  текущим адресом в функцию onClickNavigation
   * @params
   *     {number} index - индекс передаваемого объекта
   *
   ###
   _onItemSelect: (index) ->
      @_clickScrollButton = true
      selectedPathArray = @state.selectedPathArray.slice(0, index + 1)
      selectedPathString = []
      for value in selectedPathArray
         selectedPathString.push(value.value)
      @props.onClickNavigation selectedPathString.join('/')
      @setState selectedPathArray: selectedPathArray

   ###*
   * Функция, меняющая состояние isServiceCell, которое используется для
   *  отображения/скрытия кнопок прокрутки.
   * В теле функции вытаскивается ol элемент, затем массив li элементов, и
   *  сравниваются их длины. Если длина ol больше массива li, то кнопки
   *  появляются
   ###
   _HideServiceCell:->
      @_clickScrollButton = false
      if $(@refs.breadcrumbBody.getDOMNode()).parent().width() < @refs.breadcrumbBody.getDOMNode().scrollWidth
         @setState
            isServiceCell: true
      else
         @setState
            isServiceCell: false

   ###*
   * Функция, обнуляющая таймер прокрутки при выходе из элемента прокрутки
   ###
   _onMouseOut:->
      clearTimeout @_timeout

   ###*
   * Функция, запускающая таймер прокрутки при наведении на левый элемент
   * прокрутки
   ###
   _onMouseOverLeft:->
      clearTimeout @_timeout
      @_timeout = setInterval(@_ScrollLeft, 50)

   ###*
   * Функция, запускающая таймер прокрутки при наведении на парвый элемент
   * прокрутки
   ###
   _onMouseOverRight:->
      clearTimeout @_timeout
      @_timeout = setInterval(@_ScrollRight, 50)

   ###*
   * Функция, прокручивающая элемент прокрутки на 20px влево
   ###
   _ScrollLeft:->
      breadcrumb = $(@refs.breadcrumbBody.getDOMNode())
      breadcrumb.scrollLeft(breadcrumb.scrollLeft()-20)
      if $(@refs.breadcrumbBody.getDOMNode()).scrollLeft() == 0
         @setState
            isScrollButtonLeft: false
            isScrollButtonRight: true
      else
         @setState
            isScrollButtonRight: true

   ###*
   * Функция, прокручивающая элемент прокрутки на 20px вправо
   ###
   _ScrollRight:->
      breadcrumb = $(@refs.breadcrumbBody.getDOMNode())
      breadcrumb.scrollLeft(breadcrumb.scrollLeft()+20)
      if $(@refs.breadcrumbBody.getDOMNode()).scrollLeft() ==
       @refs.breadcrumbBody.getDOMNode().scrollWidth -
        $(@refs.breadcrumbBody.getDOMNode()).innerWidth()
         @setState
            isScrollButtonLeft: true
            isScrollButtonRight: false
      else
         @setState
            isScrollButtonLeft: true

module.exports = BreadcrumbNavigation

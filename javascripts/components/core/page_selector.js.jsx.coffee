###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin      - общие стили для компонентов
* HelpersMixin     - функции-хэлперы для компонентов
* AnimationsMixin  - набор анимаций для компонентов
* AnimateMixin     - библиотека добавляющая компонентам
*                    возможность исользования анимации
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
AnimationsMixin = require('../mixins/animations')
AnimateMixin = require('react-animate')


###* Зависимости: компоненты
* Button - кнопка
* Input  - поле ввода
###
Button = require('components/core/button')
Input = require('components/core/input')

###* Константы
* _COLORS               - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

###* Компонент: Выбор страницы (для постраничной навигации)
* @props :
*     {Number} pagesCount           - кол-во страниц
*     {Number} siblingSelectorCount - максимальное кол-во страниц в рядом с активным
*                                    селектором (параметр нужен чтобы выводить только
*                                    n-e кол-во селекторов рядом с активным, чтобы
                                     не отображать 100500 селекторов)
*     {Number} selectedPage        - номер выбранной страницы по-умолчанию
*     {Boolean} isInLinkMode       - флаг отображения селекторов страниц в виде ссылок.
*                                    По-умолчанию = false.
*     {Boolean} isSimple           - флаг, обозначающий состояние компонента с
*                                    одним окошком страницы - окном текущей страницы
*     {Function} onPageSelect      - обработчик, вызываемый на выбор страницы
* @state :
*     {Number} activePage          - текущая выбранная страница
*     {String} customPageSelector  - значение в поле выбора произвольной страницы
###
PageSelector = React.createClass
   # @const {String} - надпись в поле ввода номера страницы.
   _INPUT_PLACEHOLDER: 'стр.'
   # @const {String} - подсказка при вводе в поле произвольного селектора.
   _POPUP_CONTENT: 'Нажмите клавишу Enter для перехода'
   # @const {String} - подсказка при наведении на селектор.
   _SELECTOR_TITLE: 'перейти к странице'
   # @const {String} - идентификатор наличие не показанных селекторов.
   _MORE_PAGES_STRING: '...'
   # @const {String} - максимальная ширина поля ввода - селектора произвольной страницы.
   _MAX_WIDTH_INPUT_SELECTOR: 150
   # @const {String} - максимальная высота поля ввода(для растягивания по высоте).
   _INPUT_SELECTOR_HEIGHT: 22
   # @const {Object} - набор имен возможных сервисных селекторов(иконок).
   _SERVICE_SELECTORS:
      backward: 'step-backward'
      forward: 'step-forward'
      left: 'arrow-left'
      right: 'arrow-right'
   # @const {Object} - набор возможных ключей расположения идентификатора наличия
   #                   не показанных селекторов.
   _MORE_PAGES_KEYS:
      start: 'more_start'
      end: 'more_end'


   mixins: [HelpersMixin]

   styles:
      common:
         display: 'inline-flex'
      selector:
         padding: _COMMON_PADDING
         minWidth: 30
         marginRight: _COMMON_PADDING
      linkSelector:
         padding: 0
         overflow: ''
         minWidth: ''
      moreSelector:
         minWidth: 18
         marginTop: 12
      inputSelector:
         maxWidth: 100
         display: 'inline-table'
         paddingBottom: 2

   propTypes:
      pagesCount: React.PropTypes.number
      siblingSelectorCount: React.PropTypes.number
      selectedPage: React.PropTypes.number
      onPageSelect: React.PropTypes.func
      isInLinkMode: React.PropTypes.bool
      isSimple: React.PropTypes.bool

   getDefaultProps: ->
      selectedPage: 1
      siblingSelectorCount: 2
      isSimple: false
      isInLinkMode: false

   getInitialState: ->
      activePage: @props.selectedPage
      customPageSelector: ''

   componentWillReceiveProps: (nextProps) ->

      # Если через свойства была прокинута другая выбранная страница по-умолчанию,
      #  чем была раньше - поменяем.
      if @props.selectedPage isnt nextProps.selectedPage
         @setState activePage: nextProps.selectedPage

   render: ->
      `(
         <div style={this.styles.common}>
            {this._getSelectorsContent()}
         </div>
       )`

   ###*
   * Функция получения селекторов страниц. Проверяет, если кол-во страниц больше
   *  1, то генерирует селекторы, если нет - селекторы не нужны
   *
   * @return {Array, undefined}
   ###
   _getSelectorsContent: ->
      if @props.pagesCount > 1
         selectors = @_SERVICE_SELECTORS
         elements = []
         if @props.isSimple
            elements.push(
               @_getServiceSelector(selectors.backward),
               @_getServiceSelector(selectors.left),
               @_getPagуSelectors(),
               @_getServiceSelector(selectors.right),
               @_getServiceSelector(selectors.forward),
               @_getInputSelector()
            )
         else
            elements.push(
               @_getServiceSelector(selectors.backward),
               @_getServiceSelector(selectors.left),
               @_getServiceSelector(selectors.right),
               @_getServiceSelector(selectors.forward),
               @_getPageSelectors(),
               @_getInputSelector()
            )

         elements


   ###*
   * Функция сервисного селектора. В зависимости от переданного типа селектора
   *  генерирует селектор и возвращает его
   *
   * @param {String} selectorType - тип сервисного селекора (имя совпадает
   *                                с иконкой FortAwesome)
   * @return {Button-copmonent, undefined} - сервисный селектор
   ###
   _getServiceSelector: (selectorType) ->
      activePage =  @state.activePage
      pagesCount = @props.pagesCount
      selectors = @_SERVICE_SELECTORS

      # если ещё нет кол-ва страниц - ничего не генерируем
      return unless pagesCount

      switch selectorType
         when selectors.right
            nextPage = if activePage < pagesCount
                          activePage + 1
                       else
                          @props.pagesCount
         when selectors.left
            nextPage = if activePage == 1
                          activePage
                       else
                          activePage - 1
         when selectors.backward
            nextPage = 1
         when selectors.forward
            nextPage = pagesCount

      @_getSelector(nextPage, selectorType)


   ###*
   * Функция получения коллекции селекторов страниц. Если общее кол-во страниц
   *  превышает ограничитель то выводятся страницы
   *
   * @return {Array<React-node>, undefined} - массив селекторов страниц
   ###
   _getPageSelectors: ->
      pagesCount = @props.pagesCount
      activePage = @state.activePage
      siblingCount = @props.siblingSelectorCount
      selectors = []

      # если ещё нет кол-ва страниц - ничего не генерируем
      return unless pagesCount
      if @props.isSimple
         @_getSelector(activePage)
      else
         moreKyes = @_MORE_PAGES_KEYS

         # Добавим первую страницу.
         selectors.push @_getSelector(1)

         # Определяем необходимость добавления в массив объекта "..." в начале
         #  последовательности, а также начальную границу селекторов страниц слева
         #  от активной.
         if activePage - siblingCount > 2
            selectors.push(@_getMoreObject(moreKyes.start))
            startEdge = activePage - siblingCount
         else
            startEdge = 2

         # Определяем конечную(правую границу) последовательности селекторов страниц.
         endEdge = if activePage + siblingCount < pagesCount
                      activePage + siblingCount
                   else
                      pagesCount - 1

         # Генерируем селекторы страниц вокруг активного селектора.
         for i in [startEdge..endEdge]
            if i != 1 and i != pagesCount
               selectors.push @_getSelector(i)

         # Определим необходимость добавления объекта "..." в конец последовательности
         if activePage + siblingCount < (pagesCount - 1)
            selectors.push(@_getMoreObject(moreKyes.end))

         # Добавим селектор последней страницы.
         selectors.push @_getSelector(pagesCount)

         selectors

   ###*
   * Фукнция получения DOM-объекта для обозначения наличия множества объектов
   *
   * @param {String} key - ключ узла (необходим, так как добавляется в коллекцию
   *                       объектов, которые затем будут использованы при рендере
   *                       компонента)
   * @return {DOM-object}
   ###
   _getMoreObject: (key) ->
      `(
         <span style={this.styles.moreSelector}
               key={key}>{this._MORE_PAGES_STRING}</span>
       )`

   ###*
   * Функция получения селектора (кнопки выбора страницы). Генерирует либо служебный
   *  селектор (вперед/назад) либо селектор конкретной страницы
   *
   * @param {Number} identifier - идентификатор селектора (номер страницы)
   * @param {Number} iconName   - имя иконки на селекторе. (если задано - признак
   *                              служебного селектора)
   * @return {Button-copmonent} - компонент кнопка - селектор страницы
   ###
   _getSelector: (identifier, iconName) ->
      activePage = @state.activePage
      isService = if iconName then true else false
      isActiveSelector = !isService and identifier is activePage
      isActiveFirstPage = activePage is 1
      isActiveLastPage = activePage is @props.pagesCount
      isInLinkMode = @props.isInLinkMode
      caption = identifier unless isService
      serviceSelectors = @_SERVICE_SELECTORS

      # ключ
      selectorKey =  if isService
                        [identifier, iconName].join('_')
                     else
                        identifier
      selectorTitle = [@_SELECTOR_TITLE, identifier].join(' ')

      if isService
         if isActiveFirstPage
            isButtonDisabled = iconName in [ serviceSelectors.left, serviceSelectors.backward ]

         if isActiveLastPage
            isButtonDisabled = iconName in [ serviceSelectors.right, serviceSelectors.forward ]


      styleAddition =
         if isInLinkMode
            @styles.linkSelector
         else
            @styles.selector


      `(
         <Button key={selectorKey}
                 isDisabled={isButtonDisabled}
                 isActive={isActiveSelector}
                 isLink={isInLinkMode}
                 value={identifier}
                 caption={caption}
                 icon={iconName}
                 title={isButtonDisabled ? '' : selectorTitle}
                 styleAddition={styleAddition}
                 onClick={this._onSelect} />
      )`

   ###*
   * Функция получения строки ввода страницы
   *
   * @return {DOM-object}
   ###
   _getInputSelector: ->

      # если ещё нет кол-ва страниц - ничего не генерируем
      return unless @props.pagesCount


      `( <Input key='pageSelectorInput'
                type="text"
                placeholder={this._INPUT_PLACEHOLDER}
                value={this.state.customPageSelector}
                onKeyDown={this._onKeyDownInputSelector}
                maxWidth={this._MAX_WIDTH_INPUT_SELECTOR}
                inputHeight={this._INPUT_SELECTOR_HEIGHT}
                isStretchable={true}
                isNeedClearButton={true}
                popupParams={
                      {
                         verticalPosition: 'top',
                         popupContent: this._POPUP_CONTENT,
                         typeEvent:'onInputEnd'
                      }
                   }/>
       )`

   ###*
   * Обработчик нажатия клавиши в поле ввода селектора страницы.
   *  Ловит Enter - запускает функцию провекри и перехода на страницу
   *
   * @param {JavaScript - envetnt object} - объект события
   * @return
   ###
   _onKeyDownInputSelector: (event) ->
      # Если это Enter - выполним
      if event.keyCode == 13
         @_estimatedPageSelect event.target.value
         @setState customPageSelector: ''

   ###*
   * Обработчик клика по кнопке выбора страницы. Устанавливает в состояние
   *  текущий активный селектор Пробрасывает номер страницы на
   *  обработчик, заданный в свойствах
   *
   * @param {Number} pageNumber - номер страницы
   * @return
   ###
   _onSelect: (pageNumber) ->
      @props.onPageSelect pageNumber

      if @isMounted
         @setState activePage: pageNumber

   ###*
   * Функия перехода на произвольную страницу.
   *
   * @param {String} estimatedPage - пердполагаемая страница
   * @return
   ###
   _estimatedPageSelect: (estimatedPage) ->
      pageNumber = +estimatedPage

      # Если переданная страница число.
      if isFinite pageNumber

         # Если страница находится в допустимом диапазоне - запустим функцию
         #  выбора страницы
         if pageNumber in [1..@props.pagesCount]
            @_onSelect pageNumber



module.exports = PageSelector

###* @jsx React.DOM ###

###* Зависимости: Модули.
* AnimateMixin     - библиотека добавляющая компонентам
                     возможность исользования анимации.
###
StylesMixin = require('../mixins/styles')
Animate = require('react-animate')

###* Константы
* _COLORS               - цвета
###
constants = StylesMixin.constants
_COLORS = constants.color

###*
* Модуль-примесь для хранения анимации. Для анимации используются функции библиотеки
*  react-animate.
###
animations =

   ###* Анмация сворачивания-разворачивания
   # для использования в компоненте должно
   # быть задано состояние componentInitialHeight - для определния на
   # какую высоту(с какой высоты) должен быть свернут/развернут блок
   ###
   collapse:
      ###*
      * Обработчик анимации сворачивания.
      *
      * @param {function} callback - обратный вызов по завершению
      * @param {Number} finishHeightForCollapse - начальная высота. Если не задана берется, то
      *                                из @state.componentInitialHeight
      * @return {Object} - скомпанованный стиль анимации.
      ###
      collapseIn: (callback, finishHeightForCollapse) ->
         finishHeightForCollapse ||= @state.componentInitialHeight
         @animate 'animate-collapse',
            { height: finishHeightForCollapse },
            { height: 0 },
            500,
            { easing: 'linear', onComplete: callback }

      ###*
      * Обработчик анимации разворачивания.
      *
      * @param {Function} callback - обратный вызов по завершению.
      * @param {Number} finishHeightForCollapse - конечная высота. Если не задана берется, то
      *                                из @state.componentInitialHeight
      * @return {Object} - скомпанованный стиль анимации.
      ###
      collapseOut: (callback, finishHeightForCollapse) ->
         finishHeightForCollapse ||= @state.componentInitialHeight
         @animate 'animate-collapse',
            { height: 0 },
            { height: finishHeightForCollapse },
            500,
            { easing: 'linear', onComplete: callback }

   ###* Анмация скольжения (разворачивание). Пока реализованы только анимации показа.
   *  Если нужны будут анимации скрытия - додалать.
   ###
   slide:
      ###*
      * Обработчик анимации скольжения вниз
      *
      * @param {Function} callback   - обратный вызов по завершению.
      * @param {Number} finishHeight - конечная высота. Если не задана берется
      *                                из @state.size.height
      * @param {Number} startHeight  - начальная высота. Если не задана берется 0.
      * @return {Object} - скомпанованный стиль анимации.
      ###
      _slideDownIn: (callback, finishHeight, startHeight) ->
         finishHeight ||= @state.size.height
         startHeight ||= 0

         @animate 'animate-slide',
            { height: startHeight },
            { height: finishHeight },
            150,
            { easing: 'linear', onComplete: callback }

      ###*
      * Обработчик анимации скольжения вниз  (сворачивание)
      *
      * @param {Function} callback   - обратный вызов по завершению.
      * @param {Number} startHeight  - начальная высота. Если не задана берется
      *                                из @state.size.height.
      * @param {Number} finishHeight - конечная высота. Если не задана берется 0.
      * @return {Object} - скомпанованный стиль анимации.
      ###
      _slideDownOut: (callback, startHeight, finishHeight) ->
         startHeight ||= @state.size.height
         finishHeight ||= 0

         @animate 'animate-slide',
            { height: startHeight },
            { height: finishHeight },
            150,
            { easing: 'linear', onComplete: callback }

      ###*
      * Обработчик анимации скольжения вверх
      *
      * @param {Function} callback   - обратный вызов по завершению.
      * @param {Number} finishHeight - конечная высота. Если не задана берется
      *                                из @state.size.height
      * @param {Number} finishTop    - конечная позиция сверху. Если не задана берется
      *                                из @state.offset.top
      * @return {Object} - скомпанованный стиль анимации.
      ###
      _slideUpIn: (callback, finishHeight, finishTop) ->
         finishHeight ||= @state.size.height
         finishTop ||= @state.offset.top

         finishTop = 0 unless finishTop?

         @animate 'animate-slide',
            { height: 0, top: (finishTop + finishHeight) },
            { height: finishHeight , top:  finishTop },
            150,
            { easing: 'linear', onComplete: callback }

      ###*
      * Обработчик анимации скольжения вверх (сворачивание)
      *
      * @param {Function} callback   - обратный вызов по завершению.
      * @param {Number} finishHeight - конечная высота. Если не задана берется
      *                                из @state.size.height
      * @param {Number} finishTop    - конечная позиция сверху. Если не задана берется
      *                                из @state.offset.top
      * @return {Object} - скомпанованный стиль анимации.
      ###
      _slideUpOut: (callback, finishHeight, finishTop) ->
         finishHeight ||= @state.size.height
         finishTop ||= @state.offset.top

         finishTop = 0 unless finishTop?

         @animate 'animate-slide',
            { height: finishHeight , top:  finishTop },
            { height: 0, top: finishTop + finishHeight },
            150,
            { easing: 'linear', onComplete: callback }

      ###*
      * Обработчик анимации скольжения вправо
      *
      * @param {Function} callback  - обратный вызов по завершению.
      * @param {Number} finishWidth - конечная ширина. Если не задана берется
      *                               из @state.size.width
      * @return {Object} - скомпанованный стиль анимации.
      ###
      _slideRightIn: (callback, finishWidth) ->
         finishWidth ||= @state.size.width

         @animate 'animate-slide',
            { width: 0 },
            { width: finishWidth },
            150,
            { easing: 'linear', onComplete: callback }

      ###*
      * Обработчик анимации скольжения вправо (сворачивание)
      *
      * @param {Function} callback   - обратный вызов по завершению.
      * @param {Number} finishWidth  - конечная ширина. Если не задана берется
      *                                из @state.size.width
      * @return {Object} - скомпанованный стиль анимации.
      ###
      _slideRightOut: (callback, finishWidth) ->
         finishWidth ||= @state.size.width

         @animate 'animate-slide',
            { width: finishWidth },
            { width: 0 },
            150,
            { easing: 'linear', onComplete: callback }

      ###*
      * Обработчик анимации скольжения влево
      *
      * @param {Function} callback  - обратный вызов по завершению.
      * @param {Number} finishWidth - конечная ширина. Если не задана берется
      *                               из @state.size.width
      * @param {Number} finishLeft  - конечная позиция слева. Если не задана берется
      *                               из @state.offset.left
      * @return {Object} - скомпанованный стиль анимации.
      ###
      _slideLeftIn: (callback, finishWidth, finishLeft) ->
         finishWidth ||= @state.size.width
         finishLeft ||= @state.offset.left

         finishLeft = 0 unless finishLeft?

         @animate 'animate-slide',
            { width: 0, left: finishLeft + finishWidth },
            { width: finishWidth , left:  finishLeft },
            150,
            { easing: 'linear', onComplete: callback }

      ###*
      * Обработчик анимации скольжения вверх (сворачивание)
      *
      * @param {Function} callback  - обратный вызов по завершению.
      * @param {Number} finishWidth - конечная ширина. Если не задана берется
      *                               из @state.size.width
      * @param {Number} finishLeft  - конечная позиция слева. Если не задана берется
      *                               из @state.offset.left
      * @return {Object} - скомпанованный стиль анимации.
      ###
      _slideLeftOut: (callback, finishWidth, finishLeft) ->
         finishWidth ||= @state.size.width
         finishLeft ||= @state.offset.left

         finishLeft = 0 unless finishLeft?

         @animate 'animate-slide',
            { width: finishWidth , left:  finishLeft },
            { width: 0, left: finishLeft + finishWidth },
            150,
            { easing: 'linear', onComplete: callback }

   ###* Анмация затемнения-высвечивания(скрыть/показать)
   # для использования в компоненте должно:
   ###
   fade:
      ###*
      * Обработчик анимации скрытия.
      * @param {function} callback    - обратный вызов по завершению.
      *        {number} finishOpacity - начальное значение прозрачности (если на
      *                                 задана берется 1).
      ###

      _fadeIn: (callback, finishOpacity) ->
         finishOpacity ||= 1

         @animate 'animate-fade',
            { opacity: finishOpacity },
            { opacity: 0 },
            250,
            { easing: 'linear', onComplete: callback }

      ###*
      * Обработчик анимации показа.
      * @param {function} callback     - обратный вызов по завершению.
      *        {number} defaultOpacity - конечное значение прозрачности (если на задана
      *                                  берется 1).
      ###
      _fadeOut: (callback, finishOpacity) ->
         finishOpacity ||= 1
         @animate 'animate-fade',
            { opacity: 0 },
            { opacity: finishOpacity },
            250,
            { easing: 'linear', onComplete: callback }

   ###* Анимация подсветки текста.
   *  для использования в компоненте должен быть член
   *  со стилями styles.common.color - цвет в обычном состоянии
   *             styles.highlighted.color - цвет подсветки.
   *  Либо целевой цвет должен быть задан через параметры входных функций _hoverIn
   *  и _hoverOut.
   *  Примесь добавляет в состояние компонента флаг isHighlightReseted, для корректной
   *  работы анимации.
   ####
   highlight:

      getInitialState: ->
         isHighlightReseted: true

      # @const {String} - Наименование анимации.
      _H_ANIMATION_NAME: 'animate-highlight'

      # @const {String} - тип затухания анимации.
      _H_ANIMATION_EASING: 'linear'

      ###*
      * Функция получения стиля анимации.
      *
      * @return {Object, undefined}
      ###
      _getAnimateStyle: ->
         !@state.isHighlightReseted and @getAnimatedStyle(@_H_ANIMATION_NAME)

      ###*
      * Обработчик входа в анимацию. Если цвета не заданы, через параметры пытается
      *  считать их из стилей компонента - common и highlight.
      *
      * @param {function} callback   - обратный вызов по завершению
      * @param {String} currentColor - текушее значение цвета (от какого).
      * @param {String} targetColor  - значение целеового цвета (к какому).
      * @return
      ###
      _highlightIn: (callback, currentColor, targetColor) ->
         currentColor ||= @styles.common.color
         targetColor ||=  (@styles.highlight and @styles.highlight.color) or
                          _COLORS.highlight1

         @setState isHighlightReseted: false

         @animate @_H_ANIMATION_NAME,
            { color: currentColor },
            { color: targetColor },
            150,
            { easing: @_H_ANIMATION_EASING, onComplete: callback }

      ###*
      * Обработчик выхода из анимации.
      *
      * @param {function} callback - обратный вызов по завершению.
      * @param {String} currentColor - текушее значение цвета (от какого).
      * @param {String} targetColor  - значение целеового цвета (к какому).
      ###
      _highlightOut: (callback, currentColor, targetColor) ->
         currentColor ||= (@styles.highlight and @styles.highlight.color) or
                          _COLORS.highlight1
         targetColor ||= @styles.common.color

         @animate @_H_ANIMATION_NAME,
            { color: currentColor },
            { color: targetColor },
            150,
            { easing: @_H_ANIMATION_EASING, onComplete: callback }
      ###*
      * Обработчик наведения курсором на объект - запускает анимацию.
      *
      * @param {String} currentColor - текущий цвет (от какого).
      * @param {String} targetColor - целевой цвет (до какого).
      * @return
      ###
      _animationHighlightIn: (currentColor, targetColor) ->
         @setState isHighlightReseted: false
         @_highlightIn(undefined, currentColor, targetColor)

      ###*
      * Обработчик выхода курсора за пределы объекта -
      *  запускает анимацию возврата к обычному цвету после подсветки
      *
      * @param {String} currentColor - текущий цвет (от какого).
      * @param {String} targetColor - целевой цвет (до какого).
      * @return
      ###
      _animationHighlightOut: (currentColor, targetColor) ->
         @_highlightOut(@_highlightOutComplete, currentColor, targetColor)

      ###*
      * Обработчик обратного вызова по окончанию анимации -
      *  устанавливает состояние сброса цвета (очистищение ошметков анимации).
      *
      * @return
      ###
      _highlightOutComplete: ->
         @setState isHighlightReseted: true

   ###* Анимация подсветки фона
   * для использования в компоненте должен быть член
   * со стилями styles:
   *              common:
   *                 color:           - цвет текста в обычном состоянии
   *                 backgroundColor: - цвет фона в обычном состоянии
   *            styles:
   *              highlightBack:
   *                 color:           - цвет подсветки
   *                 backgroundColor: - фвет фона подсветки
   * также применяет стиль цвета текста если задан в соответствующих стилях
   * в компоненте должно быть состояние isHighlightedReset,
   *     для корерктной работы анимации
   *
   * @param {Object}
   ####
   highlightBack:
      getInitialState: ->
         isHighlightBackReseted: true

      # @const {String} - Наименование анимации.
      _HB_ANIMATION_NAME: 'animate-highlight-back'

      # @const {String} - тип затухания анимации.
      _HB_ANIMATION_EASING: 'linear'

      ###*
      * Функция получения стиля анимации.
      *
      * @return {Object, undefined}
      ###
      _getAnimateStyle: ->
         !@state.isHighlightBackReseted and @getAnimatedStyle(@_HB_ANIMATION_NAME)

      ###*
      * Обработчик входа в анимацию
      *
      * @param {Object} common - параметры обычного состояния элемента.
      * @param {Object} highlightBack - параметры выделенного состояния элемента.
      * @param {function} callback - обратный вызов по завершению.
      * @return
      ###
      _highlightBackIn: (callback, common, highlightBack, key) ->
         common ||= @styles.common
         highlightBack ||= @styles.highlightBack
         animationName = @_HB_ANIMATION_NAME

         animationName += "_#{key}" if key?

         @setState isHighlightBackReseted: false

         @animate animationName,
            {
               backgroundColor: common.backgroundColor,
               color: common.color
            },
            {
               backgroundColor: highlightBack.backgroundColor
               color: highlightBack.color
            },
            250,
            { easing: @_HB_ANIMATION_EASING, onComplete: callback }

      ###*
      * Обработчик выхода из анимации.
      *
      * @param {Object} common - параметры обычного состояния элемента.
      * @param {Object} highlightBack - параметры выделенного состояния элемента.
      * @param {function} callback - обратный вызов по завершению.
      * @return
      ###
      _highlightBackOut: (callback, common, highlightBack, key) ->
         common ||= @styles.common
         highlightBack ||= @styles.highlightBack
         animationName = @_HB_ANIMATION_NAME

         animationName += "_#{key}" if key?

         @animate animationName,
            {
               backgroundColor: highlightBack.backgroundColor,
               color: highlightBack.color
            },
            {
               backgroundColor: common.backgroundColor
               color: common.color
            },
            150,
            { easing: @_HB_ANIMATION_EASING, onComplete: callback }

      ###*
      * Обработчик наведения курсором на объект - запускает анимацию подсветки фона
      *
      * @param {Object} common - параметры обычного состояния элемента.
      * @param {Object} highlightBack - параметры выделенного состояния элемента.
      * @return
      ###
      _animationHighlightBackIn: (common, highlightBack, key) ->
         # установим флаг сброса цвета = false, чтобы цветом рулила анимация
         @setState isHighlightBackReseted: false
         @_highlightBackIn(null, common, highlightBack, key)

      ###*
      * Обработчик выхода курсора за пределы объекта -
      *     запускает анимацию возврата к обычному цвету после подсветки.
      *
      * @param {Object} common - параметры обычного состояния элемента.
      * @param {Object} highlightBack - параметры выделенного состояния элемента.
      * @return
      ###
      _animationHighlightBackOut: (common, highlightBack, key) ->
         @_highlightBackOut(@_highlightBackOutComplete, common, highlightBack, key)

      ###*
      * Обработчик обратного вызова по окончанию анимации -
      *     устанавливает состояние сброса цвета (очистищение ошметков анимации)
      *
      * @return
      ###
      _highlightBackOutComplete: ->
         @setState isHighlightBackReseted: true

   ###* Анимация подсветки рамки эффектом "свечения"
   *  для использования в компоненте должен быть член
   *  со стилями styles:
   *              common:
   *                 glowColor:       - начальное значение подсветки рамки(для сброса значения)
   *              glowBorder:
   *                 glowColor:       - конечное значение подсветки рамки
   *  Анимация не может использоваться стандартным методом, так как оперирует
   *  не CSS-атрибутами (ими нельзя создать эффект свечения через boxShadow, т.к.
   *  это сложное составное свойство у которого не получается вычислять промежуточные
   *  значения). Анимация возвращает переход от одного цвета до другого (glowColor).
   *  Реализация корректной логики добавления свойства в анимируемый компонент ложится
   *  на сам комопнент(реализовано в комопненте Input)
   *
   * @param {Object}
   ####
   glowBorder:
      ###*
      * Обработчик входа в анимацию.
      *
      * @param {function} callback - обратный вызов по завершению
      ###
      _glowBorderIn: (callback) ->
         @animate 'animate-glow-border',
            { glowColor: @styles.common.glowColor },
            { glowColor: @styles.glowBorder.glowColor },
            200,
            { easing: 'linear', onComplete: callback }

      ###*
      * Обработчик выхода из анимации.
      *
      * @param {function} callback - обратный вызов по завершению
      ###
      _glowBorderOut: (callback) ->
         @animate 'animate-glow-border',
            { glowColor: @styles.glowBorder.glowColor },
            { glowColor: @styles.common.glowColor },
            200,
            { easing: 'linear', onComplete: callback }

      ###*
      * Обработчик наведения курсором на объект -
      *  запускает анимацию подсветки текста
      *
      * @return
      ###
      _glowIn: (callback) ->
         @_glowBorderIn(callback)

      ###*
      * Обработчик выхода курсора за пределы объекта -
      *  запускает анимацию возврата к обычному цвету после подсветки
      *
      * @return
      ###
      _glowOut: (callback) ->
         @_glowBorderOut(callback)
   ###* Анимация изменения цвета и размера рамки
   *  для использования в компоненте должен быть член
   *  со стилями styles:
   *              common:
   *                 borderColor:       - начальное значение цвета рамки
   *                 borderWidth:       - начальное значение толщины рамки
   *              changeOfBorders:
   *                 borderColor:       - конечное значение цвета рамки
   *                 borderWidth:       - конечное значение толщины рамки
   *
   * @param {Object}
   ####
   changeOfBorders:
      ###*
      * Обработчик входа в анимацию.
      *
      * @param {function} callback - обратный вызов по завершению
      ###
      _changeBorderIn: (callback) ->
         @animate 'animate-change-of-borders',
            {
               borderColor: @styles.common.borderColor,
               borderWidth: @styles.common.borderWidth
            },
            {
               borderColor: @styles.changeOfBorders.borderColor,
               borderWidth: @styles.changeOfBorders.borderWidth,
            },
            200,
            { easing: 'linear', onComplete: callback }

      ###*
      * Обработчик выхода из анимации.
      *
      * @param {function} callback - обратный вызов по завершению
      ###
      _changeBorderOut: (callback) ->
         @animate 'animate-change-of-borders',
            {
               borderColor: @styles.changeOfBorders.borderColor,
               borderWidth: @styles.changeOfBorders.borderWidth
            },
            {
               borderColor: @styles.common.borderColor,
               borderWidth: @styles.common.borderWidth
            },
            200,
            { easing: 'linear', onComplete: callback }

      ###*
      * Обработчик наведения курсором на объект -
      *  запускает анимацию изменения цвета и размера рамки
      *
      * @return
      ###
      _borderIn: ->
         @_changeBorderIn()

      ###*
      * Обработчик выхода курсора за пределы объекта -
      *  запускает анимацию возврата к обычному цвету и размеру
      *
      * @return
      ###
      _borderOut: ->
         @_changeBorderOut()

module.exports = animations

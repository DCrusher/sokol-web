###* @jsx React.DOM ###

###* Зависимости: модули
* lodash                - модуль служебных операций.
###
_ = require('lodash')

###*
* Модуль-примесь для хранения возможных поведений компонентов (перетаскивание...
*  и возможно ещё что-то)
###
behaviors =
   ###*
   *  Поведение перемещение по окну. Предназначен для фиксировано или абсолютно
   *  позиционированных компонентов у которых задано состояние @state.offset.
   ###
   move:
      ###*
      * Обработчик инициализации возможности перетаскивания
      *  (обычно вешается на onMouseDown). Устанавливает параметры смещения
      *  для перетаскивания области. Задает обработчик на перемещение курсора по окну.
      *
      * @param {Event-object} event - объект события.
      * @param {Object} initOffset  - начальное значение смещения (нужно задавать
      *                               смещенеие объекта, который предполагается смещать).
      *                               Если не задано берется от event.target.
      * @return
      ###
      _moveInit: (event, initOffset) ->
         initClientX = event.clientX
         initClientY = event.clientY
         initOffset ||= $(event.target).offset()

         window.addEventListener('mousemove', @_move, true)

         @setState
            initMoveShift:
               left: initClientX - initOffset.left
               top: initClientY - initOffset.top
            moveOffset: initOffset

      ###*
      * Обработчик отключения возможности перетаскивания (обычно вешается на onMouseUp).
      *  Удаляет обработчик движения курсора на окне.
      *
      * @param {Event-object} event - объект события.
      * @return
      ###
      _moveTerminate: (event) ->
         window.removeEventListener('mousemove', @_move, true)

      ###*
      * Обработчик перемещения. Устанавливает смещение цели с учетом инициализационного
      *  значения смещения.
      *
      * @param {Object} event - объект события.
      * @return
      ###
      _move: (event) ->
         event.preventDefault()
         clientX = event.clientX
         clientY = event.clientY
         moveOffset = @state.moveOffset
         initShift = @state.initMoveShift

         @setState
            moveOffset:
               left: clientX - initShift.left
               top: clientY - initShift.top

      ###*
      * Функция получения смещения движения.
      *
      * @return
      ###
      _getMoveOffset: ->
         if @state
            moveOffset = @state.moveOffset if @state.moveOffset?
            moveOffset if moveOffset? and !$.isEmptyObject(moveOffset)
   ###*
   * Поведение изменения размеров. TODO: сейчас реализовано только изменение ширины.
   *
   ###
   resize:
      all:
         ###*
         * Функция инициализации изменения размеров (точка начала изменения).
         *  Принимает на вход левую позицию элемента и ширину. Устанавливает обработчики
         *  на движение курса по окну и отпуск кнопки мыши на окне(для отмены изменения размеров).
         *
         * @param {Object} initPosition - начальная позиция.
         * @param {Object} initSize     - начальные размеры.
         ###
         _initResize: (initPosition, initSize)->
            window.addEventListener('mousemove', @_moveResize, true)
            window.addEventListener('mouseup', @_terminateResize, true)

            resizeParams = (@state and @state.resizeParams) or {}
            resizeParams.initTop = initPosition.initTop
            resizeParams.initLeft = initPosition.initLeft

            unless resizeParams.size?
               resizeParams.size = {}

            resizeParams.size = initSize

            @setState
               resizeParams: resizeParams
               isInResize: true

         ###*
         * Функция окончания изменения размеров. Удаляет обработчики.
         *
         * @return
         ###
         _terminateResize: (event) ->
            window.removeEventListener('mousemove', @_moveResize, true)
            window.removeEventListener('mouseup', @_terminateResize, true)

            @setState isInResize: false

         ###*
         * Функция обработки движения курсора по окну. Вычисляет новые размеры объекта.
         *  и устанавливает в состоянии объекта.
         *
         * @param {Object} event - объект собятия
         * @return
         ###
         _moveResize: (event) ->
            event.stopPropagation()
            event.preventDefault()
            clientY = event.clientY
            clientX = event.clientX

            resizeParams = _.clone(@state.resizeParams)
            elementWidth = resizeParams.size.width
            elementHeight = resizeParams.size.height
            elementBottom = resizeParams.initTop + elementHeight
            elementRight = resizeParams.initLeft + elementWidth
            newHeight = elementHeight + (clientY - elementBottom)
            newWidth = elementWidth + (clientX - elementRight)

            # Заглушка, чтобы нельзя было сильно уменьшить элемент.
            newHeight = 5 if newHeight < 5
            newWidth = 5 if newWidth < 5

            resizeParams.size.width = newWidth
            resizeParams.size.height = newHeight

            @setState
               resizeParams: resizeParams

         ###*
         * Функция получения размеров.
         *
         * @return
         ###
         _getResizeSize: ->
            if @state
               resizeParams = @state.resizeParams

               if resizeParams?
                  resizeSize = resizeParams.size

                  resizeSize if resizeSize?

      height:
         ###*
         * Функция инициализации изменения размеров (точка начала изменения).
         *  Принимает на вход левую позицию элемента и ширину. Устанавливает обработчики
         *  на движение курса по окну и отпуск кнопки мыши на окне(для отмены изменения размеров).
         *
         * @param {Number} initHeight - начальная высота.
         * @param {Number} initTop - начальная левая позиция.
         ###
         _initResizeHeight: (initHeight, initTop)->
            window.addEventListener('mousemove', @_moveResizeHeight, true)
            window.addEventListener('mouseup', @_terminateResizeHeight, true)

            resizeParams = (@state and @state.resizeParams) or {}
            resizeParams.initTop = initTop

            unless resizeParams.size?
               resizeParams.size = {}

            resizeParams.size.height = initHeight

            @setState
               resizeParams: resizeParams
               isInResize: true

         ###*
         * Функция окончания изменения размеров. Удаляет обработчики.
         *
         * @return
         ###
         _terminateResizeHeight: (event) ->
            window.removeEventListener('mousemove', @_moveResizeHeight, true)
            window.removeEventListener('mouseup', @_terminateResizeHeight, true)

            @setState isInResize: false

         ###*
         * Функция обработки движения курсора по окну. Вычисляет новые размеры объекта.
         *  и устанавливает в состоянии объекта.
         *
         * @param {Object} event - объект собятия
         * @return
         ###
         _moveResizeHeight: (event) ->
            event.stopPropagation()
            event.preventDefault()
            clientY = event.clientY
            resizeParams = _.clone(@state.resizeParams)
            elementHeight = resizeParams.size.height
            elementBottom = resizeParams.initTop + elementHeight
            newHeight = elementHeight + (clientY - elementBottom)

            # Заглушка, чтобы нельзя было сильно уменьшить элемент.
            newHeight = 5 if newHeight < 5

            resizeParams.size.height = newHeight

            @setState
               resizeParams: resizeParams

         ###*
         * Функция получения ширины при изменении размеров. Получает ширину только
         *  если она была задана через обработчики изменения размеров.
         *
         * @return
         ###
         _getResizeHeight: ->
            if @state
               resizeParams = @state.resizeParams

               if resizeParams?
                  resizeSize = resizeParams.size

                  resizeSize if resizeSize?

      width:
         ###*
         * Функция инициализации изменения размеров (точка начала изменения).
         *  Принимает на вход левую позицию элемента и ширину. Устанавливает обработчики
         *  на движение курса по окну и отпуск кнопки мыши на окне(для отмены изменения размеров).
         *
         * @param {Number} initWidth - начальная ширина.
         * @param {Number} initLeft - начальная левая позиция.
         ###
         _initResizeWidth: (initWidth, initLeft)->
            window.addEventListener('mousemove', @_moveResizeWidth, true)
            window.addEventListener('mouseup', @_terminateResizeWidth, true)

            resizeParams = (@state and @state.resizeParams) or {}
            resizeParams.initLeft = initLeft

            unless resizeParams.size?
               resizeParams.size = {}

            resizeParams.size.width = initWidth

            @setState
               resizeParams: resizeParams
               isInResize: true

         ###*
         * Функция окончания изменения размеров. Удаляет обработчики.
         *
         * @return
         ###
         _terminateResizeWidth: (event) ->
            window.removeEventListener('mousemove', @_moveResizeWidth, true)
            window.removeEventListener('mouseup', @_terminateResizeWidth, true)

            @setState isInResize: false

         ###*
         * Функция обработки движения курсора по окну. Вычисляет новые размеры объекта.
         *  и устанавливает в состоянии объекта.
         *
         * @param {Object} event - объект собятия
         * @return
         ###
         _moveResizeWidth: (event) ->
            event.stopPropagation()
            event.preventDefault()
            clientX = event.clientX
            resizeParams = _.clone(@state.resizeParams)
            elementWidth = resizeParams.size.width
            elementRight = resizeParams.initLeft + elementWidth
            newWidth = elementWidth + (clientX - elementRight)

            # Заглушка, чтобы нельзя было сильно уменьшить элемент.
            newWidth = 5 if newWidth < 5

            resizeParams.size.width = newWidth

            @setState
               resizeParams: resizeParams
         ###*
         * Функция получения ширины при изменении размеров. Получает ширину только
         *  если она была задана через обработчики изменения размеров.
         *
         * @return
         ###
         _getResizeWidth: ->
            if @state
               resizeParams = @state.resizeParams

               if resizeParams?
                  resizeSize = resizeParams.size

                  resizeSize if resizeSize?


   ###* Поведение перетаскивания (drag-and-drop).
   *
   ###
   dragAndDrop:
      ###*
      * @const {String} - наименование класса, которое можно использовать для защиты
      *                   от начала перемещения.
      ###
      _UNDRAGGABLE_CLASS_NAME: 'undraggable'

      ###*
      * Функция инициализации перетаскивания. Задает начальные параметры позиционирования
      *  и параметры смещения.
      *
      * @param {Event-obj} event - объект события.
      * @return
      ###
      _dragAndDropInit: (event) ->
         clientRect = ReactDOM.findDOMNode(this).getBoundingClientRect()
         clientLeft = clientRect.left
         clientTop = clientRect.top
         clientWidth = clientRect.width
         clientHeight = clientRect.height

         window.addEventListener('mousemove', @_dragAndDropMove, true)

         @setState
            dragAndDropParams:
               left: clientLeft
               top: clientTop
               width: clientWidth
               height: clientHeight
            initShift:
               left:  event.clientX - clientLeft
               top: event.clientY - clientTop

      ###*
      * Обработчик перемещения по окну перетаскиваемого объекта.
      *  Задает текущие параметры позиционирования.
      *
      * @param {Event-obj} event - объект события.
      * @return
      ###
      _dragAndDropMove: (event) ->
         event.preventDefault()
         clientX = event.clientX
         clientY = event.clientY
         initShift = @state.initShift
         newDragAndDropParams = @state.dragAndDropParams
         newDragAndDropParams['left'] = clientX - initShift.left
         newDragAndDropParams['top'] = clientY - initShift.top

         @setState
            dragAndDropParams: newDragAndDropParams
      ###*
      * Обработчик отключения возможности перетаскивания (обычно вешается на onMouseUp).
      *  Удаляет обработчик движения курсора на окне.
      *
      * @param {Event-object} event - объект события.
      * @return
      ###
      _dragAndDropTerminate: (event) ->
         window.removeEventListener('mousemove', @_dragAndDropMove, true)

      ###*
      * Функция получения параметров позиционирования при перетаскивании
      *
      * @return {Object} - параметры перетаскивания.
      ###
      _getDragAndDropPosition: ->
         if @state
            dragAndDropParams = @state.dragAndDropParams if @state.dragAndDropParams?
            dragAndDropParams if dragAndDropParams? and !$.isEmptyObject(dragAndDropParams)

module.exports = behaviors
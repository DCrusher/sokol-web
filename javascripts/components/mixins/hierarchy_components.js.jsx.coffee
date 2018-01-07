###*
* Модуль для создания инфраструктуры иерархии компонентов.
###

hierarchy =

   # Для хранения иерархии компонентов.
   hierarchy:
      child:
         contextTypes:
            parentIdentifier: React.PropTypes.oneOfType([
               React.PropTypes.string
               React.PropTypes.number
            ])
            parentsIdentifier: React.PropTypes.array
            parents: React.PropTypes.array

         ###*
         * Функция получения идентификатора родительского элемента.
         *
         * @return {String, Number}
         ###
         getParentIdentifier: ->
            @context.parentIdentifier

         ###*
         * Функция получения коллекции родительских идентификаторов.
         *
         * @return {Array}
         ###
         getParentsIdentifier: ->
            @context.parentsIdentifier

         ###*
         * Функция получения коллекции родительских элементов.
         *
         * @return {Array}
         ###
         getParents: ->
            @context.parentComponents

   # Для хранения контейнера.
   container:
      child:
         contextTypes:
            container: React.PropTypes.object

      parent:
         childContextTypes:
            container: React.PropTypes.object

         getChildContext: ->
            container: this



module.exports = hierarchy
###* @jsx React.DOM ###

###* Зависимости: модули
* lodash                - модуль служебных операций.
###
_ = require('lodash')

# Модуль-примесь добавляющая функционал считывания свойств компонента в зависимости
#  от заданных параметров @props, @state.implementationProps.
module.exports =
   ###*
   * Функция выбора текущего свойства элемента. Получает свойства
   *  элемента по приоритету: 1. @props 2. @state.implementationProps.
   *  Если задан флаг isImplementationHigherPriority, то в обратном порядке.
   *  Если задан флаг isMergeImplementation, то выполняет слияние свойств компонента
   *  со свойствами, заданными через хранилище реализаций.
   *
   * @param {String} propName - наименование получаемого свойства.
   * @return {Object}
   ###
   _getComponentProp: (propName, isNotCloneProp) ->
      props = @props
      state = @state
      implProps = state.implementationProps
      isImplHigherPriority = @props.isImplementationHigherPriority
      isMergeImplementation = @props.isMergeImplementation
      isHasImpl = implProps? and !_.isEmpty(implProps)
      propProp =
         if isNotCloneProp
            props[propName]
         else
            _.cloneDeep(props[propName])
      implProp =
         if isHasImpl
            if isNotCloneProp
               implProps[propName]
            else
               _.cloneDeep(implProps[propName])
      isFlagProp = _.isBoolean propProp

      ###*
      * Функция слияния параметров свойств.
      *
      * @param {Object, Array ...} primaryData - основные параметры свойства.
      * @param {Object, Array ...} secondaryData - второстепенные параметры свойства.
      * @return {Object, Array}
      ###
      mergeProps = (primaryData, secondaryData) ->

         if primaryData? and secondaryData?
            if _.isArray(primaryData)
               _.concat(primaryData, secondaryData)
            else if _.isPlainObject(primaryData)
               _.merge({}, primaryData, secondaryData)
            else
               _.merge(primaryData, secondaryData)
         else if primaryData?
            primaryData
         else if secondaryData?
            secondaryData


      # Для свойств флагов - отдельная логика, для остальных другая.
      # Для флагов - если задан приоритет хранилища реализаций и при этом
      #  значение в хранилище реализаций задано - значение берется из хранилища,
      #  иначе - из свойств (включая заданные по-умолчанию).
      # Для всех остальных - если задан приоритет хранилища реализаций -
      #  либо берутся свойства по приоритету 1. хранилище, 2. Непосредственно свойства.
      #  Иначе - наоборот. При этом если задано слияние свойств, то слияние также
      #  производится по приоритету.
      if isFlagProp
         if isImplHigherPriority and isHasImpl and implProps[propName]?
            implProp
         else
            propProp
      else
         if isImplHigherPriority
            if isMergeImplementation
               mergeProps(propProp,implProp)
            else
               implProp or propProp
         else
            if isMergeImplementation
               mergeProps(implProp, propProp)
            else
               propProp or implProp

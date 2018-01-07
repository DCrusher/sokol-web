###* @jsx React.DOM ###

###*
* Модуль для хранения общих параметров рендера элементов селекторов(полей выбора).
###
module.exports =
    # @const {Object} - параметры рендера значений в полях выборки (Selector).
   _REFLECTION_RENDER_PARAMS:
      addressChain:
         instance:
            addresses:
               template: "{0} {1}",
               fields: ['shortname', 'formalname']
            houses:
               template: "д {0} {1}",
               fields: ['housenum', 'buildnum']
            dimension:
               width:
                  max: 300
         dictionary:
            dimension:
               dataContainer:
                  width:
                     max: 500
                     min: 200
                  height:
                     max: 300
      bank:
         instance:
            template: "({0}) {1}"
            fields: ['bik', 'name']
            dimension:
               width:
                  max: 250
         dictionary:
            dimension:
               dataContainer:
                  width:
                     max: 800
                     min: 200
                  height:
                     max: 200
      documentType:
         instance:
            template: "{0} ({1})"
            fields: ['name', 'document_category']
            dimension:
               width:
                  max: 250
         dictionary:
            dimension:
               dataContainer:
                  width:
                     max: 800
                     min: 200
                  height:
                     max: 200
      legalEntityTypeID:
         instance:
            dimension:
               width:
                  max: 200
         dictionary:
            dimension:
               dataContainer:
                  width:
                     max: 800
                     min: 200
                  height:
                     max: 200
      legalEntityPostID:
         instance:
            dimension:
               width:
                  max: 200
         dictionary:
            dimension:
               dataContainer:
                  width:
                     max: 800
                     min: 200
                  height:
                     max: 200
      Oktmo:
         instance:
            template: "({0}) {1}"
            fields: ['section', 'name']
            dimension:
               width:
                  max: 250
         dictionary:
            dimension:
               dataContainer:
                  width:
                     max: 800
                     min: 200
                  height:
                     max: 200
      ownershipType:
         instance:
            dimension:
               width:
                  max: 250
         dictionary:
            dimension:
               dataContainer:
                  width:
                     max: 800
                     min: 200
                  height:
                     max: 200
      ownership:
         instance:
            dimension:
               width:
                  max: 250
         dictionary:
            dimension:
               dataContainer:
                  width:
                     max: 800
                     min: 200
                  height:
                     max: 200
      property:
         instance:
            dimension:
               width:
                  max: 250
         dictionary:
            dimension:
               dataContainer:
                  width:
                     max: 800
                     min: 200
                  height:
                     max: 500
      propertyType:
         instance:
            dimension:
               width:
                  max: 250
         itemsContainer:
            isInSingleLine: false
            dimension:
               width:
                  max: 400
         dictionary:
            viewType: 'hierarchy'
            dimension:
               dataContainer:
                  width:
                     max: 800
                     min: 200
                  height:
                     max: 300
      propertyParameter:
         instance:
            dimension:
               width:
                  max: 250
         itemsContainer:
            isInSingleLine: false
            dimension:
               width:
                  max: 400
         dictionary:
            viewType: 'hierarchy'
            dimension:
               dataContainer:
                  width:
                     max: 800
                     min: 200
                  height:
                     max: 300
      propertyComplex:
         instance:
            dimension:
               width:
                  max: 250
         dictionary:
            dimension:
               dataContainer:
                  width:
                     max: 800
                     min: 200
                  height:
                     max: 200
      rightholder:
         instance:
            dimension:
               width:
                  max: 250
         dictionary:
            dimension:
               dataContainer:
                  width:
                     max: 800
                     min: 200
                  height:
                     max: 400
      user:
         instance:
            template: "({0}) {1} {2}"
            fields: ['login', 'first_name', 'last_name']
            dimension:
               width:
                  max: 250
         itemsContainer:
            isInSingleLine: true
            dimension:
               width:
                  max: 700
         dictionary:
            dimension:
               dataContainer:
                  width:
                     max: 800
                     min: 200
                  height:
                     max: 400
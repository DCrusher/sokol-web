###* @jsx React.DOM ###

DataTable = require('components/core/data_table')
Selector = require('components/core/selector')


ContentLandRegistry = React.createClass
   render: ->
      `(
         <div>
            <h3>Землища</h3>
            <Selector model="address_landpoint"
                      dataSource={
                           {
                              dictionary: {
                                 filter: {
                                    filter: null
                                 },
                                 url: "/classifier/addresses.json",
                                 resultKey: [
                                    {
                                       key:'houses',
                                       caption: 'Дома',
                                       alternativeFieldName: 'house'
                                    },
                                    {
                                       key: 'addresses',
                                       caption: 'Элементы адреса'
                                    }
                                 ]
                              },
                              instances: {
                                 resultKey: [
                                    {
                                       key: 'addresses',
                                       caption: 'Элементы адреса'
                                    },
                                    {
                                       key:'houses',
                                       caption: 'Дома',
                                       alternativeFieldName: 'house'
                                    }
                                 ]
                              },
                              additional: {
                                 directRequest: {
                                    filter: {
                                       filter: null
                                    },
                                    url: "/classifier/address_recognized.json",
                                 },
                                 firstChoiceRequest: {
                                    filger: {
                                       filter: null
                                    },
                                    url: "/classifier/address_parents.json"
                                 }
                              }
                           }
                      }
                      enableMultipleSelect={true}
                      enableConsistentClear={true}
                      additionFilterParams={
                        {
                           isAddingSelectedItems: true
                        }
                      }
                      name="address"
                      renderParams={
                         {
                            instance: {
                              addresses: {
                                 template: "{0} {1}",
                                 fields: ['shortname', 'formalname']
                              },
                              houses: {
                                 template: "д {0} {1}",
                                 fields: ['housenum', 'buildnum']
                              }
                            },
                            itemsContainer: {
                              dimension: {
                                 width: {max: 200}
                              },
                              isInSingleLine: true
                            },
                            dictionary: {
                               dimension: {
                                 dataContainer: {
                                     width: {
                                        max: 400
                                     },
                                     height: {
                                        max: 300
                                     }
                                  }
                               },
                               columnRenderParams: {
                                 isStrongRenderRule: true,
                                 columns: {
                                    shortname: {
                                       style: null
                                    },
                                    formalname: {
                                       style: null
                                    },
                                    housenum: {
                                       style: null
                                    },
                                    buildnum: {
                                       style: null
                                    }
                                 },
                                 columnsOrder: ['housenum', 'buildnum'],
                                 cells: {
                                    housenum: {
                                       enableCaption: true
                                    },
                                    buildnum: {
                                       enableCaption: true
                                    }
                                 }
                              }
                           }
                        }
                     }
               />
         </div>
       )`

module.exports = ContentLandRegistry
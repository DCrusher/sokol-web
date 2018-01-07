###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin           - общие стили для компонентов
* Chart                 - npm модуль для работы графика
* keymirror             - модуль для генерации "зеркального" хэша.
* lodash                - модуль служебных операций.
###

Chart = require('chart.js')
StylesMixin = require('components/mixins/styles')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* AjaxLoader      - индикатор загрузки.
###
AjaxLoader = require('components/core/ajax_loader')

###* Константы
* _COLORS         - цвета
###
_COLORS = StylesMixin.constants.color

###* Компонент: контент статистики правообладателей и типов юридических лиц.
*
* @props:
*     {Boolean} isVisible - переменная, указывающая, что вкладка с компонентом открыта.
* @state:
*     {Object} data - объект, содержащий данные для отрисовки графика
###
ContentRightholderStatistic = React.createClass
   _CAPTION: 'Соотношение правообладателей: физические и юридические лица'
   _CAPTION_LE_TYPES: 'Типы юридических лиц'
   _PATH: [
            location.protocol
            '//'
            location.host
            '/rightholders/statistics.json'
          ].join('')
   _REFS: keyMirror(
      chart: null
   )

   styles:
      caption:
         color: _COLORS.hierarchy2
         marginTop: 5
         textAlign: 'center'
      physicalEntities:
         width: '15px'
         height: '15px'
         background: "#F7464A"
         borderRadius: '50px'
         display: 'inline-block'
         marginBottom: '0px'
         marginTop: '4px'
      legalEntities:
         width: '15px'
         height: '15px'
         background: "#46BFBD"
         borderRadius: '50px'
         display: 'inline-block'
         marginBottom: '4px'
         marginTop: '4px'
      legendDiv:
         width: '240px'
         marginBottom: '0px'
         marginTop: '4px'
      legendText:
         float: 'right'
         marginBottom: '0px'
         marginTop: '4px'
      rowLine:
         borderTopWidth: '1px'
         borderTopStyle: 'solid'
         borderTopColor: 'rgb(112, 128, 144)'
      tableAlign:
         marginLeft: '6%'

   getInitialState: ->
      data: undefined
      loaderTarget: null

   render: ->
      loaderTarget = @state.loaderTarget
      isLoaderShown = loaderTarget?
      refs = @_REFS
      chartRef = refs.chart

      if @state.data
         physical_entities = @state.data.physical_entities
         legal_entities = @state.data.legal_entities
         legal_entity_types = @state.data.legal_entity_types
         count = physical_entities + legal_entities
         physical_entities = ((physical_entities / count ) * 100).toFixed(2)
         legal_entities = (100 - physical_entities).toFixed(2)
      else
         physical_entities = 0
         legal_entities = 0
         legal_entity_types = 0

      `(
      <table ref={chartRef}
             style={this.styles.tableAlign}>
         <tbody >
            <tr>
               <td>

                  <div>
                     <AjaxLoader target={loaderTarget}
                                 isShown={isLoaderShown}/>
                     <h3 style={this.styles.caption}>
                         {this._CAPTION}
                     </h3>
                     <PieChart isVisible = {this.props.isVisible}
                               data = {this.state.data}/>
                     <div>
                        <div style={this.styles.legendDiv}>
                           <p style={this.styles.physicalEntities}>
                           </p>
                           <p style={this.styles.legendText}>
                              Физические лица - {physical_entities} %
                           </p>
                        </div>
                        <div style={this.styles.legendDiv}>
                           <p style={this.styles.legalEntities}>
                           </p>
                           <p style={this.styles.legendText}>
                              Юридические лица - {legal_entities} %
                           </p>
                        </div>
                     </div>
                  </div>
               </td>
            </tr>
            <tr>
               <td style={this.styles.rowLine}>
                  <div>
                     <h3 style={this.styles.caption}>
                        {this._CAPTION_LE_TYPES}
                     </h3>
                     <BarStatistic isVisible = {true}
                                   data = {this.state.data}/>
                  </div>

               </td>
            </tr>
         </tbody>
      </table>
      )`

   componentDidMount: ->
      #if @props.isVisible and not prevProps.isVisible
      @_loadData()
      @setState loaderTarget: @refs[@_REFS.chart]

   ###*
   * Функция, подгружающая данные с сервера
   *
   * @return
   ###
   _loadData: ->
      Statistic = this
      $.get Statistic._PATH, (json) ->
         Statistic.setState
            data: json
            loaderTarget: null

###* Компонент: PieChart - часть компонента ContentRightholderStatistic
* @props:
*     {Boolean} isVisible - переменная, указывающая, что вкладка с компонентом открыта.
* @state:
###
PieChart = React.createClass

   myPieChart: undefined

   styles:
      height: '80%'
      width: '80%'

   componentWillReceiveProps: (nextProps) ->
      currentData = @props.data
      nextData = nextProps.data

      unless _.eq currentData, nextData
         @_updateChart(nextData)

   render: ->
      `(
         <canvas width="1000" height="450">
         </canvas>
      )`

   ###*
   * Функция, создающая график в канвас
   *
   * @return
   ###
   _updateChart: (statistic) ->

      data = [
         {
            value: statistic.physical_entities,
            color:"#F7464A",
            highlight: "#FF5A5E",
            label: "Физические лица"
         },
         {
            value: statistic.legal_entities,
            color: "#46BFBD",
            highlight: "#5AD3D1",
            label: "Юридические лица"
         }
      ]

      ctx = ReactDOM.findDOMNode(this).getContext('2d')
      @myPieChart = new Chart(ctx).Pie(data)


###* Компонент: BarStatistic - часть компонента ContentRightholderStatistic
* @props:
*     {Boolean} isVisible - переменная, указывающая, что вкладка с компонентом открыта.
* @state:
###
BarStatistic = React.createClass

   myBarChart: undefined

   styles:
      height: '100%'
      width: '100%'

   componentWillReceiveProps: (nextProps) ->
      currentData = @props.data
      nextData = nextProps.data

      unless _.eq currentData, nextData
         @_updateChart(nextData)

   render: ->
      `(
         <canvas width="1100" height="800">
         </canvas>
      )`

   ###*
   * Функция, создающая график в канвас
   *
   * @return
   ###
   _updateChart: (statistic) ->
      legal_entity_types = statistic.legal_entity_types
      labels = new Array
      values = new Array
      for key, value of legal_entity_types
         labels.push key
         values.push value

      data = {
         labels: labels,
         datasets: [
            {
               label: "Типы юридических лиц",
               fillColor: [
                  'rgba(116, 156, 124, 0.7)',
                  'rgba(144, 190, 154, 0.7)',
                  'rgba(127, 200, 143, 0.7)',
                  'rgba(113, 180, 127, 0.7)',
                  'rgba(110, 167, 123, 0.7)',
                  'rgba(98, 154, 110, 0.7)',
                  'rgba(89, 147, 101, 0.7)',
                  'rgba(77, 139, 90, 0.7)',
                  'rgba(62, 129, 76, 0.7)',
                  'rgba(52, 122, 67, 0.7)',
                  'rgba(169, 170, 170, 0.7)'
               ]
               highlightFill: [
                  'rgba(198, 226, 204, 1)',
                  'rgba(198, 226, 204, 1)',
                  'rgba(198, 226, 204, 1)',
                  'rgba(198, 226, 204, 1)',
                  'rgba(198, 226, 204, 1)',
                  'rgba(198, 226, 204, 1)',
                  'rgba(198, 226, 204, 1)',
                  'rgba(198, 226, 204, 1)',
                  'rgba(198, 226, 204, 1)',
                  'rgba(198, 226, 204, 1)',
                  'rgba(135, 135, 135, 1)'
               ],
               strokeColor: "rgba(120,120,120,0.8)",
               borderWidth: 2,
               data: values
            }
         ]
      }


      ctx = ReactDOM.findDOMNode(this).getContext('2d')
      @myBarChart = new Chart(ctx).Bar(data)


module.exports = ContentRightholderStatistic

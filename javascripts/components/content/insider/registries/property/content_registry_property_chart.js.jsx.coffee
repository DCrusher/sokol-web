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

###* Компонент: контент статистики стоимости недвижимости.
*
* @props:
* @state:
*     {Object} data - объект, содержащий данные для отрисовки графика
###
ContentAdminPropertyStatistic = React.createClass
   _CAPTION_COST: 'Стоимость объектов имущества'
   _CAPTION_TYPES: 'Состав государственного имущества по категориям'
   _PATH: [
            location.protocol
            '//'
            location.host
            '/properties/statistics.json'
          ].join('')
   _REFS: keyMirror(
      chart: null
   )

   styles:
      caption:
         color: _COLORS.hierarchy2
         marginTop: 5
      captionColumn:
         verticalAlign: 'top'
         textAlign: 'center'
      properties:
         width: '15px'
         height: '15px'
         background: "rgb(220,220,220)"
         borderRadius: '50px'
         display: 'inline-block'

   getInitialState: ->
      data: undefined
      loaderTarget: null

   render: ->
      loaderTarget = @state.loaderTarget
      isLoaderShown = loaderTarget?
      refs = @_REFS
      chartRef = refs.chart

      if @state.costData
         count = 0
         for key, value of @state.costData
            count += value
      else
         count = 0

      # if @state.typeData
      #    propertyType = @state.typeData['Недвижимость']
      #    land = @state.typeData['Земля']
      #    movableProperty = @state.typeData['Движимое имущество']
      #    intangibleProperty = @state.typeData['Нематериальное имущество']
      #    propertyComplex = @state.typeData['Имущественный комплекс']
      # else
      #    propertyType = 0
      #    land = 0
      #    movableProperty = 0
      #    intangibleProperty = 0
      #    propertyComplex = 0

            # <h3 style={this.styles.caption}>
            #    {this._CAPTION_COST}
            # </h3>

      `(
         <table style={{background: _COLORS.light}}
                ref={chartRef}>
            <tbody>
               <tr>
                  <td style={this.styles.captionColumn}>
                     <h3 style={this.styles.caption}>
                        {this._CAPTION_COST}
                     </h3>
                     <AjaxLoader target={loaderTarget}
                                 isShown={isLoaderShown}/>
                     <BarStatistic isVisible = {this.props.isVisible}
                                   data = {this.state.costData}/>
                     <div>
                        <div style={this.styles.properties}></div>
                        <span>Всего объектов - {count} </span>

                     </div>
                  </td>
                  <td style={this.styles.captionColumn}>
                     <h3 style={this.styles.caption}>
                        {this._CAPTION_TYPES}
                     </h3>

                     <DoughnutStatistic isVisible = {true}
                                        data = {this.state.typeData}/>
                  </td>
               </tr>
            </tbody>
         </table>
      )`
         # <div>
         #    <p> <div style={this.styles.propertyType}></div> Недвижимость - {propertyType} </p>
         #    <p> <div style={this.styles.land}></div> Земля - {land} </p>
         #    <p> <div style={this.styles.movableProperty}></div> Движимое имущество - {movableProperty} </p>
         #    <p> <div style={this.styles.intangibleProperty}></div> Нематериальное имущество - {intangibleProperty} </p>
         #    <p> <div style={this.styles.propertyComplex}></div> Имущественный комплекс - {propertyComplex} </p>
         # </div>
         # <div>
         #    <p> <div style={this.styles.propertyType}></div> Недвижимость - {propertyType} </p>
         # </div>
         # <div>
         #    <p> <div style={this.styles.land}></div> Земля - {land} </p>
         # </div>
         # <div>
         #    <p> <div style={this.styles.movableProperty}></div> Движимое имущество - {movableProperty} </p>
         # </div>
         # <div>
         #    <p> <div style={this.styles.intangibleProperty}></div> Нематериальное имущество - {intangibleProperty} </p>
         # </div>
         # <div>
         #    <p> <div style={this.styles.propertyComplex}></div> Имущественный комплекс - {propertyComplex} </p>
         # </div>
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
            costData: json.statistic.cost_of_property
            typeData: json.statistic.types_of_property
            loaderTarget: null



###* Компонент: BarStatistic - часть компонента ContentAdminPropertyStatistic
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
         <canvas width="750" height="800">
         </canvas>
      )`

   ###*
   * Функция, создающая график в канвас
   *
   * @return
   ###
   _updateChart: (statistic) ->
      statistic ||= @props.data
      lables = new Array
      values = new Array
      for key, value of statistic
         lables.push key
         values.push value

      data = {
         labels: lables,
         datasets: [
            {
               label: "My First dataset",
               backgroundColor: [
                  'rgba(255, 99, 132, 0.2)',
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(255, 206, 86, 0.2)',
                  'rgba(75, 192, 192, 0.2)',
                  'rgba(153, 102, 255, 0.2)',
                  'rgba(255, 159, 64, 0.2)'
               ],
               borderColor: [
                  'rgba(255,99,132,1)',
                  'rgba(54, 162, 235, 1)',
                  'rgba(255, 206, 86, 1)',
                  'rgba(75, 192, 192, 1)',
                  'rgba(153, 102, 255, 1)',
                  'rgba(255, 159, 64, 1)'
               ],
               borderWidth: 1,
               data: values,
            }
         ]
      }

#      data = {
#          labels: lables
#          options:
#             responsive: true
#             fullWidth: true
#          datasets: values
#          datasets: [
#              {
#                label: "Недвижимость",
#                fillColor: "rgba(151,187,205,0.5)",
#                strokeColor: "rgba(151,187,205,0.8)",
#                highlightFill: "rgba(151,187,205,0.75)",
#                highlightStroke: "rgba(151,187,205,1)",
#                data: values
#              }
#          ]
#      }
      ctx = ReactDOM.findDOMNode(this).getContext('2d')
      @myBarChart = new Chart(ctx).Bar(data)


###* Компонент: DoughnutStatistic - часть компонента ContentAdminPropertyStatistic
* @props:
*     {Boolean} isVisible - переменная, указывающая, что вкладка с компонентом открыта.
* @state:
###
DoughnutStatistic = React.createClass

   myDoughnutChart: undefined

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
         <canvas width="400" height="400">
         </canvas>
      )`

   ###*
   * Функция, создающая график в канвас
   *
   * @return
   ###
   _updateChart: (statistic) ->
      statistic ||= @props.data
      data = [
        {
          color: '#F7464A'
          highlight: '#FF5A5E'
        }
        {
          color: '#46BFBD'
          highlight: '#5AD3D1'
        }
        {
           color: "#FDB45C"
           highlight: "#FFC870"
        }
        {
           color: "#949FB1"
           highlight: "#A8B3C5"
        }
        {
           color: "#4D5360"
           highlight: "#616774"
        }
      ]
      options = {
         responsive: true
      }
      i = 0
      for key, value of statistic
         data[i].value = value
         data[i].label = key
         i++


      ctx2 = ReactDOM.findDOMNode(this).getContext('2d')
      @myDoughnutChart = new Chart(ctx2).Doughnut(data, options)


module.exports = ContentAdminPropertyStatistic

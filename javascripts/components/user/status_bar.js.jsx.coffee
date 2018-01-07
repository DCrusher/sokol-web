###* @jsx React.DOM ###

###* Зависимости
* stylesMixins - примесь с функциями-хэлперами для компонентов
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = _CP = StylesMixin.constants.commonPadding

###* Компонент статусной строки
*
###
StatusBar = React.createClass
   _OWNER_LABEL: 'Только для служащих министерства земельных и имущественных отношений РБ.'
   _YEAR_CREATION: '2016 г.'

   mixins: [HelpersMixin]
   styles:
      common:
         backgroundColor: _COLORS.secondary
         position: 'fixed'
         bottom: 0
         height: 20
         color: _COLORS.hierarchy2
         fontSize: 13
         right: 0
         left: 0
         marginLeft: constants.userCabinet.sideMenuWidth
      highlight:
         color: _COLORS.highlight1
      statusBarContent: StylesMixin.mixins.blockToCenter
      yearLabel:
         color: _COLORS.dark
         padding: _COMMON_PADDING


   getInitialState: ->
      user: @props.user

   render: ->

      `(
         <div style={this.styles.common}
              onClick={this.fadeIn} >
            <div style={this.styles.statusBarContent}>
               {this._OWNER_LABEL}
               <span style={this.styles.yearLabel}>
                  {this._YEAR_CREATION}
               </span>
            </div>
         </div>
       )`


module.exports = StatusBar
#window.StatusBar = StatusBar
###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin            - общие стили для компонентов
* HelpersMixin           - функции-хэлперы для компонентов
* page                   - модуль роутинга на клиенте
###
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
page = require('page')

###* Зависимости: компоненты
* AllocationContent - контент с выделением по переданному выражению
###
AllocationContent = require('../core/allocation_content')

###* Константы
* _COLORS - цвета
###
_COLOR = StylesMixin.constants.color

###* Компонент для отображения информации об отсутствующем
*              контенте для отображения (эмуляция 404, 403 ошибок)
*  @props:
*     {String} location - строка с адресом по которому была попытка перехода
###
ContentNotFound = React.createClass
   mixins: [HelpersMixin]

   _CAPTION: 'Запрашиваемый контент недоступен'
   _TEXT_PREFIX: 'Контент по адресу '
   _TEXT_SUFFIX: ' не найден.'
   _TEXT_EXPLANATION: [
      'Возможно контент отсутствует или к нему запрещён доступ. '
      'Обратитесь к администратору системы.'
    ].join ''
   _LINK: 'На главную'
   _LINK_TITLE: 'Вернуться на главную страницу кабинета'

   styles:
      caption:
         color: _COLOR.alert
      textExplanation:
         color: _COLOR.hierarchy3
      homeLink:
         marginTop: 12

   render: ->

      locat = @props.context.path
      text = [
               @_TEXT_PREFIX
               locat
               @_TEXT_SUFFIX
             ].join ''

      linkComputedStyle = @computeStyles @styles.homeLink,
                                        StylesMixin.mixins.link

      `(
         <div>
            <h3 style={this.styles.caption}>
               {this._CAPTION}
            </h3>
            <AllocationContent content={text}
                               expression={locat}
                               highlightColor={_COLOR.alert} />
            <div style={this.styles.textExplanation}>
               {this._TEXT_EXPLANATION}
            </div>
            <div style={linkComputedStyle}
                 onClick={this._onClickHomeLink}
                 title={this._LINK_TITLE} >
               {this._LINK}
            </div>
         </div>
       )`

   ###*
   * Обработчик клика по ссылке перехода на главную страницу
   *     Выполняет маршрутизацию на главную страницу через модуль page
   ###
   _onClickHomeLink: ->
      page('/')

module.exports = ContentNotFound
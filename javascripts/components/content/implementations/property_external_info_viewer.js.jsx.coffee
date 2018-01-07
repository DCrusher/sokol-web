###* @jsx React.DOM ###

###* Зависимости: модули
* HelpersMixin             - модуль хэлперов.
* StylesMixin              - общие стили для компонентов.
* RequestBuilderMixin      - модуль взаимодействия с API.
* MoneyFormatter           - модуль для форматирования денежного значения.
* keymirror                - модуль для генерации "зеркального" хэша.
* lodash                   - модуль служебных операций.
* numeral                  - модуль для числовых операций.
###
HelpersMixin = require('components/mixins/helpers')
StylesMixin = require('components/mixins/styles')
RequestBuilderMixin = require('components/application/mixins/request_builder')
MoneyFormatter = require('components/mixins/money_formatter')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* AjaxLoader     - индикатор загрузки.
* StreamContainer - контейнер в потоке.
###
AjaxLoader = require('components/core/ajax_loader')
StreamContainer = require('components/core/stream_container')

###* Константы
   * _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding


###*
* Прикладной компонент для отображения информации из внешних систем по
*  определенному объекту имущества.
*
* @props:
*     {Number} propertyKey - идентификатор имущества по которому выводится.
*
* @state:
*     {Object} externalData - загруженные данные из внешних систем по объекту
*                             имущества.
*
###
PropertyExternalInfoViewer = React.createClass

   _ENDPOINT_PARAMS:
      root: 'properties'
      action: 'external_data'

   # @const {Object} - параметры контейнера отображения данных из внешних систем.
   _STREAM_CONTAINER_PARAMS:
      # ajarHeight: 30
      areaParams:
         isWithoutSubstrate: true
      triggerParams:
         hidden:
            caption: 'Информация из внешних систем'
      isMirrorClarification: true

   # @const {Object} - данные для разных категорий.
   _DATA_CATEGORIES:
      cadastral:
         key: 'cadastral'
         caption: 'Из кадастра:'
      state:
         key: 'state'
         caption: 'Уровень субъекта:'

   # @const {Object} - сервисные поля по категориям.
   _SERVICES_FIELDS:
      cadastral: ['costs']

   mixins: [HelpersMixin, RequestBuilderMixin]

   styles:
      categoryCaption:
         fontSize: 12
         color: _COLORS.main
         paddingTop: _COMMON_PADDING
         paddingBottom: _COMMON_PADDING
         # fontWeight: 'bold'
         fontStyle: 'italic'
         textDecoration: 'underline'
      contentTable:
         fontSize: 12
      captionCell:
         color: _COLORS.hierarchy3
      valueCell:
         color: _COLORS.hierarchy2

   getInitialState: ->
      externalData: null

   render: ->
      `(
         <StreamContainer content={this._getContent()}
                          onClickTrigger={this._onClickTriggerStreamContainer}
                          {...this._STREAM_CONTAINER_PARAMS}
                        />
      )`

   ###*
   * Функция формирования содержимого потокового контейнера. Если данные ещё не
   *  загружены - выводи загрузчик, если загружены строит таблицы для отображения
   *  данных из кадастра и данные по республиканскому имуществу.
   *
   * @param {Object}  error  - ошибки.
   * @param {Object} response - результат запроса(ответ).
   * @return {React-element}
   ###
   _getContent: ->
      externalData = @state.externalData

      if externalData?
         dataCategories = @_DATA_CATEGORIES

         cadastralContent = @_getContentForCategory(
            externalData,
            dataCategories.cadastral.key
         )

         stateContent = @_getContentForCategory(
            externalData,
            dataCategories.state.key
         )

         `(
            <div>
               {cadastralContent}
               {stateContent}
            </div>
         )`
      else
         `(
            <AjaxLoader isShown={true}
                           isStatic={true}
                           isWithoutSubstrate={true}
                        />
          )`

   ###*
   * Функция формирования содержимого для определенной категории данных внешних
   *  систем.
   *
   * @param {Object} externalData  - данные внешних систем.
   * @param {Object} category      - наименование категории для которой
   *                                 формируется содержимое.
   * @return {React-element}
   ###
   _getContentForCategory: (externalData, category) ->
      dataForCategory = externalData[category]
      captionForCategory = @_DATA_CATEGORIES[category].caption
      servicesFields = @_SERVICES_FIELDS[category]

      if dataForCategory?
         cadastralContentTable = @_getContentTable(dataForCategory, servicesFields)

         if cadastralContentTable?
            `(
               <div>
                  <div style={this.styles.categoryCaption}>
                     {captionForCategory}
                  </div>
                  {cadastralContentTable}
               </div>
             )`

   ###*
   * Функция формирования таблицы для отображения данных. Формирует 2 столбца -
   *  наименование и значение и только в том случае, если значение задано.
   *
   * @param {Object}  serializedRecord - серилизованная запись.
   * @param {Array<String>, undefined} servicesFields - массив наименований сервисных
   *                                     полей(они исключаются из отображения).
   * @return {React-element}
   ###
   _getContentTable: (serializedRecord, servicesFields) ->
      recordFields = serializedRecord.fields
      rows = []
      servicesFields ||= []

      for fieldName, field of recordFields
         fieldValue = field.value
         fieldCaption = field.caption
         isIgnored = _.includes(servicesFields, fieldName)

         continue if isIgnored

         if fieldValue? and !_.isEmpty(fieldValue) and !_.isObject(fieldValue)
            rows.push(
               `(
                   <tr key={fieldName}>
                     <td style={this.styles.captionCell}>
                        {fieldCaption}
                     </td>
                     <td style={this.styles.valueCell}>
                        {fieldValue}
                     </td>
                   </tr>
                )`
            )

      unless _.isEmpty(rows)
         `(
            <table style={this.styles.contentTable}>
               <tbody>
                  {rows}
               </tbody>
            </table>
          )`

   ###*
   * Функция-колбэк на получения данных из внешних ситсем.
   *
   * @param {Object}  error  - ошибки.
   * @param {Object} response - результат запроса(ответ).
   * @return
   ###
   _getExternalData: (error, response) ->
      externalData = @_getResponseData(error, response).data

      @setState externalData: externalData

   ###*
   * Обработчик клика на кнопке скрытия/разворачивания потокового контейнера, в
   *  котором располагается содержимое информации из внешних систем.
   *  Останавливает проброс события.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickTriggerStreamContainer: (event) ->
      event.stopPropagation()

      unless @state.externalData?
         @_requestExternalData()

   ###*
   * Функция запроса внешнего содержимого по объекту имущества.
   *
   * @return
   ###
   _requestExternalData: ->
      propertyKey = @props.propertyKey
      endpointParams = @_ENDPOINT_PARAMS

      if propertyKey?
         externalDataEndpoint =  @_constructEndpoint(endpointParams.action,
                                                     endpointParams.root,
                                                     @props.propertyKey)
         @_sendRequest(
            endpoint: externalDataEndpoint,
            callback: @_getExternalData
         )


module.exports = PropertyExternalInfoViewer
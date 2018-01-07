###* @jsx React.DOM ###

###* Зависимости: модули.
* keymirror             - модуль для генерации "зеркального" хэша.
###
keyMirror = require('keymirror')

###*
* Модуль-примесь для хранения логики работы функций, работы с ресурсами,
*  привязанных к среде исполения.
###
module.exports =

   # @const {Hash} - набор наименований сред исполнения.
   _ENVIRONMENTS: keyMirror(
      production: null
      development: null
   )

   # @const {Hash} - набор используемых символов.
   _ASSET_CHARS:
      point: '.'
      empty: ''
      dash: '-'
      backSlash: '/'

   # @const {String} - папка для ресурсов приложения (для конструирования пути к файлам).
   _ASSETS_DIR: 'assets'

   ###*
   * Функция получения пути до ресурса.
   *
   * @param {Object} fielParams - параметры файла ресурса.
   * @return {String} - путь до ресурса.
   ###
   _getAssetPath: (fileParams)  ->

      return unless fileParams?

      chars = @_ASSET_CHARS
      pointChar = chars.point
      dashChar = chars.dash
      emptyChar = chars.empty
      isProduction = @props.environment is @_ENVIRONMENTS.production
      fileParams = fileParams
      fileName = fileParams.name

      processedName =
         if isProduction
            fileNameParts = fileName.split(chars.point)
            name = fileNameParts[0]
            extension = fileNameParts[1]

            [
               name,
               dashChar,
               fileParams.digest
               pointChar,
               extension
            ].join emptyChar
         else
            fileName

      [
         @_ASSETS_DIR
         processedName
      ].join chars.backSlash
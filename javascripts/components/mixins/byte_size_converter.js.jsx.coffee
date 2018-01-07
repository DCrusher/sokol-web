# Модуль для конвертации размеров.
i18nBytes = require('bytes-i18n')

# Конфигурация для локализации конвертора.
i18nConfig =
   'b': 'б'
   'kb': 'Кб'
   'mb': 'Мб'
   'gb': 'Гб'
   'tb': 'Тб'

###*
* Модуль конвертации разметов файлов.
###
module.exports =
   _convertSize: (bytes)->
      i18nBytes(bytes, i18nConfig)
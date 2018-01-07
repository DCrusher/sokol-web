###* Зависимости: модули
* InsiderActionCreators - модуль создания клиентских инсайдерских действий
*###
InsiderActionCreators = require('actions/insider_action_creators')

###*
* Модуль для хранения обработчиков для реестра правообладаний.
*
###
module.exports =
   getRentContract: (event) ->
      InsiderActionCreators.getRentContract(event.key)

   ###*
   * Функция запроса формирования документа.
   *
   * @param {String, Number} ownershipID - идентификатор правообладания.
   * @param {Object} params - параметры запроса. Вид:
   *                 'document' - тип документа.
   *                 'format'   - формат.
   * @return
   ###
   getDocument: (ownershipID, params) ->
      InsiderActionCreators.getDocumentForm(ownershipID, params)
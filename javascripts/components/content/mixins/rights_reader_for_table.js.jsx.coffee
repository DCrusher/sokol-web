###* @jsx React.DOM ###

###* Зависимости: модули
* lodash                - модуль служебных операций.
###
_ = require('lodash')

# Модуль-примесь добавляющая функционал формирования свойств компонента DataTable
#  по правам, назначенным на АРМ для конкретного пользователя.
#
module.exports =
   _OBJECT_CARD_RESET_CUSTOM_OPERATION:
      custom: null

   _getDataTableRightProps: ->
      objectCardParams = {}
      rights = @props.rights

      if rights?
         isCreate = rights.isCreate
         isUpdate = rights.isUpdate
         isDelete = rights.isDelete
         isUpdateCustom = rights.isUpdateCustom
         isShow = rights.isShow
         isShowRelated = rights.isShowRelated
         isShowCustom = rights.isShowCustom
         isMassOperations = rights.isMassOperations
         isExport = rights.isExport
         isImport = rights.isImport

      tableProps =
         enableCreate: isCreate
         enableEdit: isUpdate
         enableDelete: isDelete
         enableObjectCard: isShow
         enableExport: isExport
         enableImport: isImport

      unless isMassOperations
         tableProps.massOperations = null

      unless isUpdateCustom
         tableProps.customRowOptions = null
         objectCardParams.operationParams = @_OBJECT_CARD_RESET_CUSTOM_OPERATION

      unless isShowRelated
         objectCardParams.isDisplayReflections = false

      unless isShowCustom
         objectCardParams.customActions = null

      if objectCardParams? and !_.isEmpty(objectCardParams)
         tableProps.objectCardParams = objectCardParams

      tableProps
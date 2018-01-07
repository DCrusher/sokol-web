###* @jsx React.DOM ###

###* Зависимости: модули
* loglevel              - модуль для вывода формитированных логов в отладчик.
###
log = require('loglevel')

###*
* Модуль для хранения обработчиков для реестра платежей.
*
###
module.exports =

   ###*
   * Обработчик выбора платежного графика в селекторе.
   *
   * @context {React-component} DataTableRow - контекст функции - строка компонента DataTable
   * @param {Object} paymentRecord       - запись по строке(данные платежа) для которой был
   *                                       сформирован селектор платежного графика.
   * @param {Arrat} selectedPaymentPlans - выбранные в селекторе графики (возвращается всегда
   *                                       массив - берем первый).
   * @param {Boolean} isInitSet          - флаг начальной установки значения.
   * @return
   ###
   onSelectPaymentPlan: (paymentRecord, selectedPaymentPlans, isInitSet) ->

      return if isInitSet

      dataTableRow = this
      processedPaymentRecord = _.cloneDeep(paymentRecord)
      paymentKey = processedPaymentRecord.key
      paymentPlan = selectedPaymentPlans[0]
      isWrongContext = !dataTableRow? or dataTableRow instanceof Window

      if isWrongContext
         log.warn('Не установлен корректный контекст для обработчика выбора платежного графика.')
         return

      if paymentPlan? and !_.isEmpty paymentPlan
         paymentPlanReflections = paymentPlan.reflections

         if paymentPlanReflections? and !_.isEmpty(paymentPlanReflections)
            ownership = paymentPlanReflections.ownership

            if ownership? and !_.isEmpty ownership
               ownershipReflections = ownership.value.reflections

               if ownershipReflections? and !_.isEmpty(ownershipReflections)
                  rightholder = ownershipReflections.rightholder

         processedPaymentRecord.reflections.payment_plan =
            value: paymentPlan

         if rightholder?
            processedPaymentRecord.reflections.rightholder_payer = rightholder

         processedPaymentRecord
      else if processedPaymentRecord.reflections?
         delete processedPaymentRecord.reflections.rightholder_payer
         delete processedPaymentRecord.reflections.payment_plan


      dataTableRow.refreshRecord(processedPaymentRecord)



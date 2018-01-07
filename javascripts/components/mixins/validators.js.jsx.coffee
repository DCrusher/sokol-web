
###* Зависимости: модули
* request - модудь для работы с HTTP запросами.
* keymirror             - модуль для генерации "зеркального" хэша.
* lodash                - модуль служебных операций.
###
request = require('superagent')
keyMirror = require('keymirror')
_ = require('lodash')

# TODO подумать, может пути как то отдельно хранить, а то в
# в нескольких местах уже повторения ссылка на корень ресурса
VALIDATE_ENDPOINT_ROOT = [ location.protocol, '//',
                           location.host, 'validate' ].join('/')

###*
* Модуль валидаторов
*  Для корректной работы модуля в компоненте должно быть:
*  {Array} props.field.validators    - массив валидаторов
*  {String} props.field.name         - имя поля
*  {Boolean} state.isValidateRequest - флаг запроса валидации в БЛ
*  {Array} state.validateErrors      - массив ошибок валидации
###
validators =
   ###*
   * @param {Object} - хэш с константами ошибок
   ###
   _ERRORS:
      PRESENCE:   [ 'Значение не может быть пустым.',
                    'Поле обязательно для заполнения' ].join(' ')
      FORMAT:       'Значение не соответствует заданному формату'
      FORMAT_EMAIL: 'Некорректный адрес электронной почты'
      LENGTH_MAX:   'Длина строки должна быть максимум'
      LENGTH_MIN:   'Длина строки должна быть минимум'
      LENGTH_IS:    'Символов в строке должно быть'

   ###*
   * @param {Object} - хэш с API валидации
   *  Пока одно значение, хэш сделан на будующее, может пригодится,
   *  а может и нет.
   ###
   _VALIDATE_ENDPOINTS:
      UNIQUENESS: [ VALIDATE_ENDPOINT_ROOT, 'uniqueness' ].join('/')

   # @const {Object} - типы валидаторов.
   _VALIDATOR_TYPES: keyMirror(
      presence: null
      format: null
      uniqueness: null
      length: null
   )

   ###*
   * Метод валидации. Использует для проверки значения свойство объекта
   *  @props.validators компонента. Также используем доп. параметры
   *  @props.validationParams
   *
   * @param {String} value       - строка, которую нужно проверить.
   * @param {String, Number} instanceKey - ключ записи, по которому создано поле
   *                                       (редактирование).
   * @param {Fucntion} callback  - функция обратного вызова, срабатывает по
   *                               завершению валидации.
   * @return
   ###
   _validate: (value, instanceKey, callback) ->
      # Флаг того, что нужен удаленный запрос (влияет на то когда нужно вызвать
      # колбэк).
      isNeedRemoteRequest = false
      validatorTypes = @_VALIDATOR_TYPES
      currentErrors = @state.validateErrors
      validators = @props.field.validators
      validationParams = @props.validationParams
      isHasValidationParams = validationParams? and !_.isEmpty validationParams
      isValuePresent = !_.isEmpty value
      disablePresence = if isHasValidationParams
                           validationParams.disablePresence
      isNeedValidation = isValuePresent or
                   (!isValuePresent and !disablePresence)
      errors = []

      # Если заданы параметры валидации - проверяем если задан обработчик произвольной
      #  валидации поля - проводим её.
      if validationParams? and isNeedValidation
         customValidator = validationParams.customHandler

         if customValidator?
            customErrors = customValidator(value)

            if customErrors?
               errors = errors.concat(customErrors)

      # Если есть валидаторы и при этом задано значение, или
      #  задано пустое значение и при этом не задан флаг запрета на валидацию
      #  присутствия - запускаем валидацию по параметрам поля.
      if validators and isNeedValidation

         # Переберем все валидаторы.
         i = 0
         while i < validators.length
            validator = validators[i]
            validatorType = validator.type
            validatorOptions = validator.option

            validatorErrors =
               # В зависимости от типа валидатора выполняем различные проверки.
               switch validatorType
                  # Присутствие(обязательность).
                  when validatorTypes.presence
                     # Проводим валидацию присутствия, только если не задан флаг
                     #  запрета валидации присутствия.
                     unless disablePresence
                        @_validatePresense(value)
                  # Формат (регулярки).
                  when validatorTypes.format
                     if isValuePresent
                        @_validateFormat(value, validatorOptions)
                  # Уникальность (запрос в API).
                  when validatorTypes.uniqueness
                     if isValuePresent
                        # валидация уникальности делается только запросом на сервер
                        # поэтому по результату выполнения валидации не вызываем
                        # колбэк. Его вызываем только после запроса в БЛ в методе
                        # _validateUniqueness
                        isNeedRemoteRequest = true

                        paramsForValidate =
                           value: value
                           instanceKey: instanceKey
                           options: validatorOptions
                           errors: errors
                           callback: callback

                        @_validateUniqueness(paramsForValidate)
                  # Длинна (кол-во символов).
                  when validatorTypes.length
                     if isValuePresent
                        @_validateLength(value, validatorOptions)

            # Сохраним все ошибки валидации в результирующий массив
            unless _.isEmpty(validatorErrors)
               errors = errors.concat(validatorErrors)

            i++

      # Если не нужен удаленный запрос (валидация на сервере) - выполним операции
      #  сохранения результатов и вызова колбэка здесь, иначе, это будет выполнено
      #  в обратном вызове валидации с запросом.
      unless isNeedRemoteRequest

         # Установим состояние ошибок валидации в компоненте, если ошибки
         #  отличаются от уже находящихся в состоянии
         unless _.isEqual(currentErrors, errors)
            @setState validateErrors: errors

         # Если задана функция обратного вызова и не нужно делать удалённый
         # запрос  - вызываем колбэк по завершению валидации
         if callback?

            # Если есть ошибки - в результате вернем их, иначе ok.
            result = if errors.length then errors else null

            callback(null, result)

   ###*
   * Функция валидации присутствия. Просто смотрит, если значение пустое
   *  возвращает ошибку
   * @param {String} value - значение для проверки
   * @return {Array} - массив ошибок
   ###
   _validatePresense: (value) ->
      errors = []

      # если пустая строка - значит ошибка
      if !value
         errors.push @_ERRORS.PRESENCE
      errors

   ###*
   * Функция валидации формата. Получает регулярное выражение из
   *  строки с подготовленной регуляркой для javascript на бизнес-логике
   *  методом _getRegularExp, и тестирует значение на соответсвие регулярке.
   *  Проверяет название поле по которому идет валидация - если это email
   *  и формат не верен - выдается специфичное предупреждение, в остальных
   *  случаях - обычная ошибка.
   *
   * @param {String} value   - значение для проверки
   * @param {Object} options - опции валидации
   * @return {Array} - массив ошибок
   ###
   _validateFormat: (value, options) ->
      errors = []

      # получим регулярку из строки, полученной из БЛ
      regExpFormat = @_getRegularExp(options.with)

      # проверим значение на соответствие регулярке
      if !regExpFormat.test(value)

         # если валидация идет по полю email - выдадим специфичную ошибку,
         # иначе выдадим обычную ошибку формата
         if @props.name == "email"
            errors.push @_ERRORS.FORMAT_EMAIL
         else
            errors.push @_ERRORS.FORMAT

      errors

   ###*
   * Функция проверки на уникальность. Посылает запрос в БЛ с запросом проверки
   *  на уникальность. Дожидается ответа и считывает результат в обратном
   *  вызове, где устанавливает в состояние компонента ошибки валидации.
   *  Перед запросом устанавливает в компоненте состояние запроса валидации
   *  isValidateRequest = true (для возможности показа иконки загрузчика),
   *  по выполнению запроса - снимает данный флаг.
   *
   *  @param {Object} params - параметры для выполнения валидации. Вид:
   *        {String} value      - проверяемое значение.
   *        {String, Number} instanceKey - ключ записи по которой создан
   *                                       проверяемый объект.
   *        {Object} options    - опции валидации.
   *        {Array} errors      - массив ошибок валидации (уже определенные ошибки).
   *        {Function} callback - функция обратного вызова, которая должна быть вызвана
   *                              по завершению валидации.
   *  @return {superagent Request} - объект запроса в БЛ
   ###
   _validateUniqueness: (params) ->
      value = params.value
      instanceKey = params.instanceKey
      options = params.options
      errors = params.errors
      callback = params.callback
      verifiableObject = this
      model = options.model
      fields = {}
      fields[@props.field.name] = value

      # установим флаг запроса
      @setState isValidateRequest: true

      paramsForRequest =
         model: model
         fields: JSON.stringify(fields)
         instance_key: instanceKey

      return request.get(@_VALIDATE_ENDPOINTS.UNIQUENESS)
         .query(paramsForRequest)
         .set('Accept', 'application/json')
         .end (err, res) ->
            responseErrors = []
            result = res.text

            # если получили ответ пробуем распарсить результат
            # и считать ошибки
            if result

               # TODO пока затычка на обработку исключений, может быть
               #  и навсегда
               try
                  responseErrors = JSON.parse(result).errors
               catch err
                  responseErrors = []

            errors = errors.concat(responseErrors)

            # снимем флаг запроса
            # установим склееный массив ошибок валидации
            verifiableObject.setState
               isValidateRequest: false
               validateErrors: errors

            # если есть колбэк - вызываем
            if callback
               # если есть ошибки - в результате вернем их, иначе ok
               result = if errors.length then errors else null
               callback(null, result)

   ###*
   * Функция валидации длинны. Проверяет выход длинны строки за диапазоны
   *  минимума и максимума
   *
   * @param {String} value   - значение для проверки
   * @param {Object} options - опции валидации
   * @return {Array} - массив ошибок
   ###
   _validateLength: (value, options) ->
      errors = []
      max = options.maximum
      min = options.minimum
      is_length = options.is

      # если значение не пустое и задан максимум
      if value && max
         # если длинна превышает макс, то - ошибка
         if value.length > max
            maxError = [ @_ERRORS.LENGTH_MAX,
                         max, 'символов' ].join(' ')
            errors.push(maxError)

      # если задан минимум
      if min
         # если если она пустая, то - ошибка
         # или длинна строки меньше минимума
         if !value || value.length < min
            minError = [ @_ERRORS.LENGTH_MIN,
                          min, 'символов' ].join(' ')
            errors.push(minError)

      # если задано конкретное число
      if value && is_length
         if value.length != is_length
            isError = [ @_ERRORS.LENGTH_IS, is_length ].join(' ')
            errors.push(isError)

      errors

   ###*
   * Функция получения регулярного выражения из подготовленной на бизнес-логике
   *  строке
   *
   * @param {String} regExpString - строка с регуляркой
   * @return {RegExp} - регулярка
   ###
   _getRegularExp: (regExpString) ->
      strLength = regExpString.length
      lastSlashIndex = regExpString.lastIndexOf('/')
      flags = regExpString.substr(lastSlashIndex + 1, strLength)
      trimString = regExpString.substr(1, lastSlashIndex - 1)

      new RegExp(trimString, flags)


module.exports = validators
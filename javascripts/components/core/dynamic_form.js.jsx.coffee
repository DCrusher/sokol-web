###* @jsx React.DOM ###

###* Зависимости: модули
* StylesMixin           - общие стили для компонентов.
* HelpersMixin          - функции-хэлперы для компонентов.
* HierarchyMixin        - модуль для задания иерархии компонентов.
* ServiceStore          - flux-хранилище состояний сервисной части.
* ServiceActionCreators - модуль создания клиентских сервисной действий.
* ServiceFluxConstants  - flux-константы сервисной части.
* async                 - модуль для асинхронной работы с функциями.
* keymirror             - модуль для генерации "зеркального" хэша.
* string-template       - модуль для форматирования строк.
* loglevel              - модуль для вывода формитированных логов в отладчик.
* form-serialize        - модуль для серилизации данных формы.
* superagent            - модуль запросов к бизнес-логике.
* lodash                - модуль служебных операций.
###
PureRenderMixin = React.addons.PureRenderMixin
StylesMixin = require('../mixins/styles')
HelpersMixin = require('../mixins/helpers')
HierarchyMixin = require('../mixins/hierarchy_components')
ServiceStore = require('stores/service_store')
ServiceActionCreators = require('actions/service_action_creators')
ServiceFluxConstants = require('constants/service_flux_constants')
async = require('async')
keyMirror = require('keymirror')
format = require('string-template')
log = require('loglevel')
serialize = require('form-serialize')
request = require('superagent')
_ = require('lodash')

###* Зависимости: компоненты
* ArbitraryArea   - произвольная область.
* Flasher         - список сообщений.
* FormInput       - поле ввода формы с валидациями.
* DropDown        - выпадающий список.
* Button          - кнопка.
* AjaxLoader      - индикатор загрузки.
* Accordion       - аккордеон.
* StreamContainer - контейнер с возможностью скрытия/показа.
###
ArbitraryArea = require('components/core/arbitrary_area')
Flasher = require('components/core/flasher')
FormInput = require('components/core/form_input')
DropDown = require('components/core/dropdown')
Button = require('components/core/button')
AjaxLoader = require('components/core/ajax_loader')
Accordion = require('components/core/accordion')
StreamContainer = require('components/core/stream_container')

###* Константы
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
constants = StylesMixin.constants
_COLORS = constants.color
_COMMON_PADDING = constants.commonPadding
_COMMON_BORDER_RADIUS = constants.commonBorderRadius

# *     {String} submitCaption - надпись на кнопке отправки формы (при пустом
# *                              значении будет надпись по умолчанию для submit).
# *   {String} completeCaption - надпись на кнопке завершения операции (при пустом
# *                              значении будет надпись по умолчанию для complete)
# *     {String} resetCaption  - надпись на кнопке очистки формы (при пустом
# *                              значении будет надпись по умолчанию для reset)

###* Компонент: динамическая форма ввода
*
* @props :
*     {Object} actionButtonParams   - параметры для кнопко действия формы. Вид:
*              {Object} submit   - параметры для кнопки отправки запроса. Вид:
*                   {String} caption - надпись на кнопке.
*                   {String} title   - всплывающее пояснение на кнопке.
*                   {String} icon    - наименование иконки кнопки.
*                 {Boolean} isAbsent - флаг отсутствия (кнопка не формируется).
*                 {Boolean} isMain   - флаг главной кнопки (выделения цветом).
*               {Boolean} isComplete - флаг завершенной процедуры (для возможности
*                                      реакции после процедуру - например закрытие
*                                      контейнера в котором находится форма).
*              {Object} complete - параметры для кнопки сохранения и отправки запроса.
*                                  Параметры аналогичны submit.
*              {Object} reset    - параметры для кнопки сброса значений формы. Вид
*                                  Параметры аналогичны submit.
*     {Object} modelParams         - Параметры модели для которой сформирована форма.
*                                     Вид:
*                    {String} name - имя модели с которой работаем (для создания
*                                    корректных форм работы с данными).
*                 {String} caption - название модели (локализованное название).
*        {Array<Object>} relations - массив имен связанных сущностей. Если задан данный
*                                    параметр, то данные параметры будут переданы в API
*                                    для получения записей не модели заданной через параметр
*                                    @props.modelParams.name, а записей последней связки в наборе.
*                                    Для работы с данным параметром должен быть задан
*                                    параметр @props.instanceID, задающий экземпляр, по которой
*                                    будут отбираться связанные записи.
*                                    Например:
*                                       @props.model.name = 'rightholder'
*                                       @props.model.relations = ['LegalEntity', 'legal_entity_employee']
*                                       При этом будут выбраны записи сущности LegalEntityEmployee по
*                                       связи LegalEntityEmployee -> LegalEntity -> Rightholder.
*                                       и отобраны по параметру Rightholder.id == @props.instanceID
*     {String} mode          - режим работы формы. Варианты:
*                              'create' - форма создания (отправляются только заполненные
*                                         поля).
*                              'update' - форма обновления (отправляются все поля).
*     {Boolean} enableManuals    - флаг, разрешения отображения основного мануала по форме.
*                                     По-умолчанию = true.
*     {Object} customServiceFluxParams - произвольные параметры взаимодействия с API через
*                                    сервисную инфраструктуру flux. Вид:
*                              {String} endpoint - адрес API для отправки запроса(относительный).
*                              {String} method   - метод отправки запроса(post, get, ...).
*     {Object} accompanyingRequestData - произвольный набор "сопутствующих" параметров для запроса.
*                                        отправляемых в API. Вид:
*                 {Object} init   - данные, отправляемые вместе с инициализационным запросом.
*                 {Object} action - данные, отправляемые вместе с основным запросом.
*     {String, Number} updateIdentifier - идентификатор для обновления (ИД записи,
*                                         которую нужно обновлять).
*     {String, Number} rootIdentifier - идентификатор корневого экземпляра по которому
*                                       строятся цепь - таблица данных - форма - таблица ...
*                                       Параметр задается начальным источником (таблицей данных)
*                                       и передается затем по цепочке без изменений.
*                                       Параметр необходим для корректного построения
*                                       параметров для запроса на редактирование связанных
*                                       запись через контроллер корневой модели.
*     {Object} presetParams  - предварительно заданные параметры для создания содержимого
*                              формы. Если данные параметры были заданы, то форма не отправляет
*                              запрос в БЛ для считывания данных. Вид:
*                              {String} ignoredField     - имя игнорируемого поля.
*                              {Object} fields           - параметры полей.
*                              {Object} externalEntities - параметры внешних связок.
*     {Object} fieldsOrder   - хэш, задающий порядок следования полей. Вид:
*                              {Object} [entityName]: - наимненование сущности.
*                                   {Array} [sectionName]: - наимение секции(внешней сущности
*                                                            или основных параметров) для которой
*                                                            задаются упорядочиваемые поля.
*                              Например: { root: { main: ['entity_type', 'old_registry_number'] } }-
*                                        задает порядок следования полей для главной секции
*                                        корневой сущности (основные параметрты для сущности).
*                                        { entity: {} }
*     {Object} sectionsOrder - хэш, задающий порядок следования секций. Актуально для
*                              форм, включающих в себя внешние сущности. Вид:
*                              {Array} root - массив названий секций, задающих порядок
*                                             следования для корневого набора секций.
*                                             например, root: ['PopertyType', 'main'] -
*                                             задаст порядок вывода секций - сначала секция
*                                             внешней сущности PropertyType, затем секция основных
*                                             параметров модели, затем все остальные неупорядоченные
*                                             секции, если заданы.
*                              {Array} [entityName] - задаст порядок следований для набора секций
*                                                     сущности entityName.
*     {Object} reflectionParams - хэш с параметрами внешних связок. Вид:
*                                {String} [reflectionKey]: [reflectionType] - вид связки:
*                                         'dictionary' - только словарь выбора существующих
*                                         'new' - только поля создания нового экземпляра. (по-умолчанию).
*                                         'combine' - комбинированный подход (не реализовано),
*     {Object} hierarchyBreakParams - хэш с параметрами прерывания создания иерархии связанных сущностей.
*                                     Данный параметр необходим:
*                                      - для корректного формирования имен полей формы
*                                        (исключения взаимных ссылок или выключение лишних звеньев
*                                         цепи иерархии),
*                                      - для корретного(последовательного) поведения переходов
*                                        в мастер-форме при переходе между шагами с помощью управляющих
*                                        кнопок.
*                                      - для повышения быстродействия рендера формы.
*                                   Вид(например): properties: 'addresses' - значит, что для объектов
*                                      собственности не нужно считывать параметры адресов(ломает дальнейшую
*                                      цепь иерархии properties-> addresses(уже не будет) -> ничего).
*                                   В канестве имени связанной сущности может быть массив связанных сущностей.
*                                      Например: documents: ['document_type', 'document_file']/
*     {Object} externalEntitiesParams - хэш параметров для внешних сущностей текущей сущности. Вид:
*         {Boolean} isDenyExistInstances         - флаг запрета формирования полей для существующих
*                                                  экземпляров связок.
*         {Boolean} isAllowAllExternalToExternal - флаг разрешения построения всех внешних для всех внешних.
*              {Object} allowExternalToExternal: - хэш параметров разрешения добавления внешних
*                                                  сущностей для какой-либо из внешних сущностей
*                                                  текущей. По-умолчанию генерируются поля для заполнения
*                                                  только на один уровень внешних сущностей.
*                                Пример: PropertyBirth: 'PropertyHistory' - для внешней модели
*                                        рождение объекта сделать доступной сущность история
*                                        создания объекта.
*     {Object} reflectionRenderParams - хэш параметров рендера полей выборки. Вид:
*              {Object} [reflectionName]: - параметры рендера поля выборки сущности reflectionName. Вид:
*                       {Object} instance - параметры рендера выбранной сущности. Вид:
*                             {String} template - строка-шаблон для формирования значения, содержащая
*                                                 маркеры на места которых будут подставлены значения.
*                                                 Например: "{0} ({1})"
*                        {Array<String>} fields - набор полей, значения которых будут подставлены в
*                                                 строку-шаблон(template) при выводе выбранного экземпляра
*                                                 сущности. Например: ['field1', 'field2']
*                            {Object} dimension - параметры размеров выбранного экземпляра. Вид:
*                                   {Object} width - ширина. Вид:
*                                      {Number} max - значение максимальной ширины обображаемого значения.
*                                Также внутри параметров instance можно задать параметры отображения
*                                 выбранных экземпляров сущностей для случаев, когда идет работа с
*                                 вариативным словарем (разнородные данные). В этом случае параметры задаются
*                                 аналогично параметрам общего отображения экземпляров. Например:
*                                 {Object} [data2]:
*                                    {String} template - шаблон.
*                               {Array<String>} fields - поля.
*                          {Object} instanceContainer - параметры рендера контейнера выбранных экземпляров. Вид:
*                                   {Boolean} isInSingleLine - флаг расположения контейнера выбранных
*                                                              элементов в одну линию без переноса строки.
*                                                              В случае расположения элементов в линию и
*                                                              если выбранные элементы не умещаются в контейнер.
*                                                              будут отображены последние влезающие + кнопка показа
*                                                              всех выбранных в отдельном контейнере (...)
*                                         {Object} dimension - параметры размеров контейнера. Вид
*                                                {Object} width - параметры ширины. Вид:
*                                                       {Number} max - максимальная ширина.
*                         {Object} dictionary - параметры рендера словаря выбора. Вид:
*                                 {String} viewType - тип таблицы, в котором будут выведены элементы словаря.
*                                 {Object} dimension - параметры размеров словаря. Вид:
*                                     {Object} dataContainer - параметры размеров контейнера для таблицы данных. Вид:
*                                         {Object} width - параметры ширины. Вид:
*                                            {Number} min - минимальная.
*                                            {Number} max - максимальная.
*                                 {Object} columnRenderParams - параметры рендера колонок таблицы. Параметр аналогичен
*                                                               такому параметру компонента DataTable.
*     {Object} denyToEditReflections   - набор запрещенных для редактирования параметров. Вид:
*                                   {String} [reflection_name] - {Object,null} - параметры разрешенной для
*                                                                           редактирования связки. Вид:
*                                         {Array} chain - цепь имен связок до разрешенной для редактирования
*                                                         связок.
*     {Object} denyReflections - запрещенные связки. Если связка
*                                запрещается для нее не будет создан раздел для работы.
*                                Вид:
*                                  {String} [reflection_name] : {Object, null} - параметры для связки reflection_name.
*                                  {Array<String>} chain - набор наименований связок до данной связки.
*                                  {Boolean} isAnywhere  - флаг расположения связки в любом месте (вне зависимости от parents)
*     {Object} fieldConstraints - хэш с параметрами ограничений/специфичных настроек полей. Вид:
*                                   {Array} constraints - массив ограничений по конкретным полям. Вид элемента:
*                                            {
*                                               {String} name   - имя поля.
*                                    {RegExp object} nameRegExp - регулярное значение имени. Если задан данный
*                                                                 параметр и не занад параметр name - то название
*                                                                 поля, для которого будут применяться ограничения
*                                                                 будут проверяться не по точному совпаданию, а
*                                                                 по соответсвию регулярному выражению.
*                                               {Array} parents - массив наименований родительских сущностей.
*                                  {String, Number} strongValue - значение "жестко" устанавливаемое
*                                                                 в поле, вне зависимости от того
*                                                                 было ли установлено значение ранее.
*                                            {Boolean} isHidden - флаг того, что поле скрывается.
*                                            {Boolean} isLocked - флаг того, что поле не доступно для изменений.
*                                      {String} identifyingName - идентифицирующее имя поля (для выборки параметров
*                                                      из хранилища реализаций). Если данный
*                                                      параметр не задан для поля, то в качестве идентифицурующего
*                                                      имени будет задано имя поля, по которому построено поле.
*                                            }
*                                   {Object} prefixAnchors - якоря на префиксы полей. Вид:
*                                         {Object} [prefixName]: {Object}(параметры по которым поле с данным
*                                         префиксом будет создано) Вид:
*                                            [dictionaryName] : {Array} - наименование связки-ограничения.
*                                      Например:
*                                         real: { property_types: [1,2] } - ограничения на поля с префиксом
*                                         "real" - они будут показаны, только если в словаре property_type
*                                         будут заданы значения 1 или 2.
*   {Object} sectionConstraints - хэш с параметрами ограничений/специфичных настроек секций. Вид:
*                                 {String} [sectionName]: {Object} [sectionParams]
*                                      {String} sectionName   - наименование секции(главная секция - root).
*                                      {Object} sectionParams - параметры секции. Вид:
*                                          {Array} groups - набор групп полей внутри секций. Данная
*                                                           опция нужна для группировки полей внутри одной
*                                                           секции. Вид элемента:
*                                               {String} name          - имя группы.
*                                               {String} caption       - выводимый заголовок группы.
*                                               {Array<String>} fields - имена полей, входящих в группу.
*   {Object} additionalValidationParams - дополнительные параметры для валидации. Вид:
*                    {Object} allowedPresenceForExternal - параметры разрешенной валидации
*                                                          присутствия(обязательности) для внешних
*                                                          связок(по-умолчанию для этих связок такой
*                                                          вид валидации отключен). Вид:
*                          {String} [reflection_name] - {Object, null} params - параметры связки. Если
*                                                          параметры не заданы ищется связки с единичной
*                                                          длинной цепи связей. Вид параметров:
*                                   {Array<String>} - цепь наименований связок.
*                              Пример:
*                                 allowedPresenceForExternal: {
*                                    entity: null,             - разрешена валидация присутствия полей связки
*                                                                единичной длинны:
*                                                                [@props.modelParams.name] -> entity.
*                                    documents:
*                                       chain: ['ownerships', 'payment_plans', 'documental_basis'] -
*                                                              - разрешена валидация присутсвия полей связки:
*                                                                @props.modelParams.name -> ownerships ->
*                                                                payment_plans -> documental_basis -> documents
*                                }
*                    {Array<Object>} customValidators - набор пользовательских валидаторов для
*                                                       конкретных полей. Вид элемента:
*                          {String} field        - имя поля.
*                          {Array<String>} chain - цепь связок до поля.
*                          {Function} handler    - функция валидатора.
*                              Аргументы:
*                                   {Object, String, Number, Array} value - значение в поле.
*                              Возврат:
*                                   {Array<String>} - массив ошибок (валидация не прошла).
*                                     или
*                                   {null, undefined} - нет ошибок (валидация прошла).
*                             Пример: Задается валидатор для поля с именем 'first_name' связки
*                                     @props.modelParams.name -> entity -> legal_entity_employees:
*                                customValidators:[
*                                   {
*                                      field: 'first_name',
*                                      chain: ['entity', 'legal_entity_employees']
*                                      handler: validateEnmployeeFirstName
*                                   }
*                                ]
*                   {Function} totalValidator - пользовательская функция общей проверки
*                                               полей формы. Через данную функцию можно задать
*                                               комплексную проверку полей. Функция вызывается
*                                               в контексте экземпляра динамической формы.
*                       Аргументы:
*                            {Object} formElements - элементы формы. Вид :
*                                {Array} accordions - контейнеры-аккордеоны формы.
*                                {Object} fields    - поля формы. Вид:
*                                     {String} name - имя поля (имя поля в таблице).
*                                     {String} fieldName - имя поля формы (сгенерированное для
*                                                          DOM-элемента).
*                                     {React-Element-ref} instance - ссылка на экземпляр поля.
*                                      ...
*                       Возврат:
*                            {null, undefined} - нет ошибок (валидация прошла).
*                             или
*                            {Object} - набор ошибок (валидация не прошла). Варианты возврата:
*                                {
*                                   error1: 'Ошибка'  - будет выведено: error1: 'Ошибка'
*                                   error2: { error: 'Еще одна ошибка' } - будет выведено:
*                                                                          error2: 'Ещё одна ошибка'.
*                                   error3: { error: 'Последняя ошибка', caption: 'локализованная ошибка' } -
*                                                                          будет выведено:
*                                                                          'локализованная ошибка': 'Последняя ошибка'
*                                }
*     {Object} implementationStore  - хранилище стандартных реализаций.
*     {Boolean} isUseImplementation - флаг использования хранилища стандартных реализаций.
*     {Boolean} isImplementationHigherPriority - флаг более приоритетных свойств из хранилища реализаций.
*                                               Нужен для переопределения свойств, заданных по-умолчанию.
*                                               По-умолчанию = false.
*     {Boolean} isMergeImplementation - флаг "слияния" свойств компонента со свойствами, заданными в
*                                       хранилище реализаций. По-умолчанию = false.
*     {Boolean} isAddAttributesSuffixForChain - флаг добавления суффикса '_attributes' к именам
*                                               родительских сущностей в цепи родителей при формировании
*                                               имен полей. По-умолчанию = true.
*     {Boolean} enableManageReflections - флаг разрешения управления связанными сущностями.
*                                         Если данный флаг установлен, то в сложных формах
*                                         с внешними связками в режиме обновления, присутствует
*                                         возможность управления связанными записями через
*                                         элементы - таблица данных со связанными записями -
*                                         динамическая форма для манипуляции.
*                                         По-умолчанию = true
*     {Obejct<Object, String, Function>} fluxParams - хэш с параметрами flux-архитектуры
*                                                     для работы с данными:
*                    {Object} store             - хранилище flux, изменения которого слушаем
*                    {Function} sendInitRequest - фукнция, которую компонент вызывает для
*                                                 получения полей
*                    {String} responseInitType   - тип события в хранилище flux, которое слушаем
*                                                 для начального получения полей формы
*                    {Function} getInitResponse  - функция получения инициализационных данных
*                                                  (поля формы)
*                    {Function} sendRequest      - функция отправки данных формы
*                    {Funciton} getResponse      - функция получения данных из хранилища flux
*                    {String} responseType       - тип события в сторе, которое слушаем.
*     {React-Element-ref} organizer              - ссылка на элемент органайзера операций.
*     {Function} customSubmitHandler - произвольный обработчик отправки запроса с пепедачей данных формы.
*                                      Аргументы:
*                                         {String} data - серилизованные данные формы, подготовленные
*                                                          для отправки запроса.
*                                      {String, Number} udpateIdentifier - идентификатор обновляемого в
*                                                                          форме экземпляра.
*     {Function} onAfterGetResponse  - обработчик на получение ответа после отправки запроса.
*                                   {Object} result - параметры ответа.
*                                   {Object} isComplete - флаг полностью выполненной операции(требуется
*                                                         закрытие контейнера).
*     {Function} onClearField   - обработчик на очистку поля формы.
*                                 Аргументы:
*                                   {Object} formFieldParams - параметры поля формы, содержащие
*                                                              ссылку на экземпляр компонента
*                                                              FormInput.
*                                   {React-element} dynamicForm - ссылка на экземпляр компонента
*                                                                 динамической формы.
*     {Function} onChangeField  - обработчик на изменение значения в поле формы.
*                                 Аргументы:
*                                   {String, Number} value      - новое значение в поле.
*                                   {Object} field              - параметры поля.
*                                   {String} fieldFormName      - имя поля.
*                                   {React-element} dynamicForm - ссылка на экземпляр компонента
*                                                                 динамической формы.
*     {Function} onInitField    - обработчик на добавление поля.
*                                 Аргументы:
*                                   {Object} formFieldParams - параметры поля формы, содержащие
*                                                              ссылку на экземпляр компонента
*                                                              FormInput.
*                                   {React-element} dynamicForm - ссылка на экземпляр компонента
*                                                                 динамической формы.
*     {Function} onDestroyField - обработчик на уничтожение поля.
*                                 Аргументы:
*                                   {Object} formFieldParams - параметры поля формы, содержащие
*                                                              ссылку на экземпляр компонента
*                                                              FormInput.
*                                   {React-element} dynamicForm - ссылка на экземпляр компонента
*                                                                 динамической формы.
*     {Function} onReady        - обработчик события на начала готовности компонента к операциям.
*                                 Аргументы:
*                                   {React-element} dynamicForm - ссылка на экземпляр компонента.
*     {Function} onClickOpenManual - обработчик клика на кнопку открытия руководства.
*                                 Аргументы:
*                                   {Array<String>} reflectionsChain - цепь наименований связок по
*                                                                      которым запрашивается руководство.
*                                   {Object} event - объект события.
* @state :
*     {Object} fields                   - хэш с полями формы.
*     {Object} actionParams             - хэш параметров для кнопок действия формы.
*                                         Хранит значения параметров по-умолчанию с
*                                         переопределенными значениями через параметр
*                                         @props.actionButtonParams.
*     {Object} externalEntities         - хэш с параметрами внешних связанных сущностей.
*     {Object} editReflectionParams             - параметры редактируемой связки.
*     {Object<Object>} reflectionsMap    - хэш параметров карты связанных сущностей. Вид
*                 {Object} [reflection_name] - хэш параметров связки [reflection_name]. Вид:
*                       {Array<Array>} parents - массив цепей родительских связок.
*                               {Array} childs - массив имен дочерних связок.
*     {Object} polymorphicStates        - хэш для хранения выбранных полиморфных сущностей.
*     {Object} validationResult         - хэш с результатами валидации. Вид:
*              {Object<Object>} flasherOutput - хэш с параметрами для вывода собщений в
*                                               списке сообщений в компоненте Flasher. Вид:
*                                               {Array} [fieldName] - массив ошибок по полю.
*              {Object} accordionSectionErrors - хэш с параметрами ошибок в секциях аккордеона. Вид:
*                                               {Number} [accordionSectionName] - кол-во ошибок в секции.
*     {Object} dictionariesSelectedValues - хэш для хранения выбранных значений в словарях.
*                                         (параметр нужен для работы с ограничением полей).
*     {Boolean} isRefreshed             - флаг того что форма была сброшена.
*     {Boolean} isInitProcess           - флаг того что компонент находится в потоковом процессе
*                                         инициализации. Данный флаг нужен для остановки рендера в процессе
*                                         потока инициализаций для оптимизации рендера.
*     {String} activatedAction          - наименование активированного действия (нажатая кнопка дейтсвия).
*     {String} requestStatus            - идентификатор, результата отправки формы:
*                                         'readyInit'     - компонент готов к начальному запросу(получение полей).
*                                         'ready'         - компонент готов к запросу на действие.
*                                         'requested'     - компонент отправил запрос.
*                                         'responded'     - компонент получил ответ.
*                                         'respondedInit' - компонент получил инициализационный ответ.
*     {Object} masterButtonStates - хэш состоянии кнопок мастер-формы. Вид:
*                 {Boolean} forward  - состояние кнопки "Вперед". По-умолчанию = true.
*                 {Boolean} backward - состояние кнопки "Назад". По-умолчанию = false.
*     {Object} formElements - хэш для хранения параметров элементов формы. Вид:
*          {Array<Object>} accordions - массив аккордеонов, используемых в форме.
*          {Array<Object>} fields     - массив полей формы.
*     {React-elements} activityTarget - целевой узел для плавающих компонентов.
* @functions:
*   getFormFields - функция получения параметры экземпляров полей формы.
*     @return {Object} - ассоциативный массив(хэш) параметров экземпларов полей формы. Вид:
*           {formFieldName}: {Object} - параметры поля. Вид:
*              {String} name      - имя поля (в модели).
*              {String} fieldName - имя поля (сгенерированное для формы).
*              {Object} instance  - ссылка на экземпляр компонента FormInput.
*              ... - другие параметры (расписать?).
*   getUpdateIdentifier - функция получения идентификатора экземпляра для которого
*                         построена форма для режима "обновления".
*     @return {Number, String} - идентификатор записи.
*   finalizeRequest - функция финализации запроса.
###
DynamicForm = React.createClass

   # @const {Object} - параметры для компонента вывода сообщений
   _FLASHER_PARAMS:
      errorCaption: 'Форма содержит ошибки:'
      successParams:
         text: 'Запрос успешно выполнен'
         type: 'success'

   # @const {String} - набор используемых строковых маркеров-псевдонимов.
   _ALIASES:
      mainSection: 'main'
      rootNode: 'root'

   # @const {String} - набор используемых строковых префиксов.
   _SUFFIXES:
      polySelector: 'type'
      caption: 'Caption'
      splitter: 'splitter'
      exist: 'exist'
      fieldSet: 'fieldSet'

      modeSplitter: 'modeSplitter' # TODO: убрать

   # @const {Object} - типы формы.
   _FORM_MODES: keyMirror(
      create: null
      update: null
   )

   # @const {Object} - хэш возможных состояний компонента.
   _REQUEST_STATUSES: keyMirror(
      readyInit: null
      ready: null
      requested: null
      responded: null
      respondedInit: null
   )

   # @const {Object} - хэш возможных видов связок.
   _REFLECTION_TYPES: keyMirror(
      dictionary: null,
      new: null,
      combine: null
   )

   # @const {Object} - ключи для считывания данных из ответа из API
   _RESPONSE_METHOD_KEYS: keyMirror(
      update: null
      create: null
   )

   # @const {Object} - ключи для считывания параметров ответа на запрос в API.
   _RESPONSE_KEYS: keyMirror(
      fields: null
      externalEntities: null
      reflectionsMap: null
   )

   # @const {Object} - набор стандартых сообщений.
   _MESSAGES:
      errors:
         presetOrFluxParamsNotSet: [
               'Не заданы параметры для работы с API(fluxParams) и '
               'предустановленные параметры для построения содержимого(presetParams).'
            ].join ''

   # @const {Object} - хэш с параметами функциональных кнопок для создания/удаления
   #                   экземпляров внешних сущностей.
   _INSTANCE_CONTROL_PARAMS:
      add:
         caption: 'Добавить'
         title: 'Добавить новый связанный объект'
         icon: 'plus'
      remove:
         caption: 'Удалить'
         title: 'Удалить последний объект'
         icon: 'trash-o'

   # @const {Object} - набор используемых строковых литералов.
   _CHARS:
      empty: ''
      sqBrStart: '['
      sqBrEnd: ']'
      brStart: '('
      brEnd: ')'
      quote: '"'
      underscore: '_'
      colon: ':'
      newLine: '\n'
      space: ' '
      slash: '/'
      sharp: '#'
      backSlash: '\\'

   # @const {Object} - параметры для кнопок действия формы по-умолчанию.
   _DEFAULT_ACTION_BUTTON_PARAMS:
      complete:
         caption: 'Готово'
         title: 'Сохранить и закрыть'
         type: 'submit'
         icon: 'check'
         isAbsent: true
         isComplete: true
      submit:
         caption: 'Отправить'
         title: 'Отправить данные'
         type: 'submit'
         icon: 'save'
         isMain: true
      reset:
         caption: 'Сбросить'
         title: 'Сбросить введенные данные'
         type: 'reset'
         icon: 'refresh'

   # @const {Object} - параметры для кнопок формы-мастера.
   _MASTER_BUTTON_PARAMS:
      back:
         caption: 'Назад'
         icon: 'arrow-left'
         title: 'Перейти к предыдущему шагу'
      forward:
         caption: 'Далее'
         icon: 'arrow-right'
         title: 'Перейти к следующему шагу'

   # @const {Object} - ключи для доступа к результатам выполнения валидации.
   _VALIDATION_RESULT_KEYS: keyMirror(
      flasherOutput: null,
      accordionSectionErrors: null
   )

   # @cosnt {Object} - набор возможных префиксов элементов формы.
   _ELEMENT_REF_REFIXES: keyMirror(
      accordion: null
      container: null
      field: null
      dynamicForm: null
   )

   # @const {Object} - параметры для защиты от зацикливаний.
   _TOO_MANY_ITERATE_PARAMS:
      counter: 0
      maxCounter: 10000
      error: 'Алгоритм был остановлен, так как было выполнено слишком много итераций.'

   # @const {Object} - параметры кнопок показа метаданных
   _META_BUTTON_PARAMS:
      description:
         icon: 'info-circle'
      question:
         icon: 'question-circle'

   # @const {Object} - параметры режима "навигатора" для главного аккордеона.
   _ROOT_NAVIGATOR_MOD_PARAMS:
      position: 'left'

   # @const {Object} - типы всплывашек.
   _TIP_TYPES: keyMirror(
      info: null
      question: null
      exclamation: null
   )

   # {Object} -возможные типы сопутсвующих данных.
   _ACCOMPANYING_DATA_TYPES: keyMirror(
      init: null
      action: null
   )


   # @const {String} - псевдоним-маркер поля ключа.
   _ID_FIELD_ALIAS: 'id'

   # @const {String} - вид индикатора ajax-загрузки.
   _LOADER_VIEW: 'spinner'

   # @const {String} - ключ считывания данных запроса в API.
   _JSON_KEY: 'json'

   # @const {String} - заголовок при не известной ошибке, произошедней в API.
   _REQUEST_ERROR_CAPTION: 'При операции приозошли ошибки'

   # @const {String} - элемент для формирования наименования операции редактировани.
   _EDIT_OPERATION_NAME_ELEMENT: 'Обновление записи'

   # @cosnt {Stirng} - наименование свойства общего валидатора формы.
   _TOTAL_VALIDATOR_PROP_NAME: 'totalValidator'

   # @const {String} - тип поля для поля-флага.
   _CHECKBOX_TYPE: 'boolean'

   # @const {Number} - таймаут(мс) задержки для сброса флага процесса инициализации.
   _INIT_PROCESS_RESET_DELAY: 500

   # Переменная хранящая задержку для пропуска инициализационного процесса
   _initProcessDelay: null

   # Переменная для хранения текущего активного пути(последовательности) пройденных
   #  секций в мастер-форме. Не реализовано через состояния, т.к. у данного компонента
   #  в режиме мастер-формы сложный рендер, который не рационально запускать каждый раз
   #  при переключении секций, а проверку через componentWillUpdate сделать просто не получится,
   #  поэтому это самый простой вариант, для улучшения быстродействия.
   _masterSectionsPath: []

   # {String} - идентификатор компонента (временная метка при монтировании)
   _componentIdentifier: null

   mixins: [HelpersMixin,
            HierarchyMixin.container.child]

   styles:
      common:
         margin: _COMMON_PADDING
      commandWrapper:
         textAlign: 'left'
         padding: _COMMON_PADDING
         borderTopWidth: 1
         borderTopStyle: 'solid'
         borderTopColor: _COLORS.hierarchy3
         marginTop: _COMMON_PADDING
         overflow: 'auto'
      contentWrapper:
         #maxHeight: 850
         overflow: 'auto'
      mainCommandContainer:
         float: 'right'
      elementsSplitter:
         color: 'red'
         margin: _COMMON_PADDING
         display: 'block'
         border: 0
         borderTopStyle: 'solid'
         borderTopColor: _COLORS.hierarchy4
         borderTopWidth: 1
         padding: 0
      actionButton:
         marginLeft: _COMMON_PADDING
      masterButton:
         marginLeft: _COMMON_PADDING
      organizerElementCaption:
         fontSize: 16
      organizerElementSubCaption:
         fontSize: 11
         textAlign: 'left'

   propTypes:
      actionButtonParams: React.PropTypes.object
      modelParams: React.PropTypes.object
      mode: React.PropTypes.oneOf(['create', 'update'])
      enableManuals: React.PropTypes.bool
      customServiceFluxParams: React.PropTypes.object
      accompanyingRequestData: React.PropTypes.object
      presetParams: React.PropTypes.object
      denyReflections: React.PropTypes.object
      denyToEditReflections: React.PropTypes.object
      fluxParams: React.PropTypes.object
      reflectionRenderParams: React.PropTypes.object
      implementationStore: React.PropTypes.object
      isUseImplementation: React.PropTypes.bool
      isMergeImplementation: React.PropTypes.bool
      isAddAttributesSuffixForChain: React.PropTypes.bool
      isImplementationHigherPriority: React.PropTypes.bool
      enableManageReflections: React.PropTypes.bool
      reflectionParams: React.PropTypes.object
      fieldConstraints: React.PropTypes.object
      sectionConstraints: React.PropTypes.object
      sectionsOrder: React.PropTypes.object
      fieldsOrder: React.PropTypes.object
      hierarchyBreakParams: React.PropTypes.object
      externalEntitiesParams: React.PropTypes.object
      onInitField: React.PropTypes.func
      onDestroyField: React.PropTypes.func
      onChangeField: React.PropTypes.func
      onClearField: React.PropTypes.func
      onReady: React.PropTypes.func
      onClickOpenManual: React.PropTypes.func

   getDefaultProps: ->
      mode: 'create'
      enableManuals: false
      implementationStore: {}
      isAddAttributesSuffixForChain: true
      enableManageReflections: true

   getInitialState: ->
      requestStatuses = @_REQUEST_STATUSES
      presetParams = @props.presetParams
      reflectionToMain = @props.reflectionToMain
      requestStatus = requestStatuses.readyInit

      # Если заданы предустановленные параметры, то считаем параметры полей,
      #  внешних сущностей, а также установим статус запроса на "данные получены".
      if presetParams?
         presetFields = presetParams.fields
         presetExternalEntities = presetParams.externalEntities
         requestStatus = requestStatuses.respondedInit

         if reflectionToMain?
            castlingResult = @_castlingElements(reflectionToMain,
                                                presetFields,
                                                presetExternalEntities)
            presetFields = castlingResult.fields
            presetExternalEntities = castlingResult.externalEntities
            initChain = castlingResult.initChain

      initChain: initChain
      actionParams: @_getActionParams()
      formElements: @_getInitFormElements()
      requestStatus: requestStatus
      masterButtonStates: @_getInitMasterButtonStates()
      isRefreshed: false
      isInitProcess: false
      fields: presetFields || {}
      externalEntities: presetExternalEntities || {}
      validationResult: {}
      activityTarget: {}
      polymorphicStates: {}
      containersParams: {}
      dictionariesSelectedValues: {}
      reflectionsMap: {}
      modelParams: {}
      editReflectionParams: null
      activatedAction: null

   componentWillReceiveProps: (nextProps) ->
      currentPresetParams = @props.presetParams
      nextPresetParams = nextProps.presetParams
      isPresetDifferent = !_.isEqual(currentPresetParams, nextPresetParams)
      nextReflectionToMain = nextProps.reflectionToMain

      # currentModelParams = @props.modelParams
      # nextModelParams = nextProps.modelParams
      # isModelParamsDifferent =
      #    JSON.stringify(currentModelParams) isnt JSON.stringify(nextModelParams)
      # newState = {}

      if isPresetDifferent
         newPresetParams =
            if nextReflectionToMain?
               @_castlingElements(nextReflectionToMain,
                                  nextPresetParams.fields,
                                  nextPresetParams.externalEntities)
            else
               nextPresetParams

         @setState newPresetParams

   shouldComponentUpdate: (nextProps, nextState) ->

      # Хак для ускорения работы формы при инициализации полей. Так как
      #  инициализация каждого поля может быть длительной процедурой (отправка
      #  запроса, прием ответа), то после такого процесса запускать рендер
      #  всей формы слишком накладный процесс реализован данный подход.
      #  В местах где может потребоваться потоковые тяжелые операции (инициализация
      #  поля, изменение значения в поле) устанавливается флаг isInitProcess и
      #  в данной функции-предикате на определение необходимости рендера
      #  проверяется: Если данный флаг не установлен - дается разрешение на
      #  рендер, иначе очищается возможный предыдущий таймаут на сброс флага
      #  инициализационного процесса и запускается новый таймаут по прошествии
      #  которого выполняется сброс флага.
      if nextState.isInitProcess
         clearTimeout(@_initProcessDelay)

         @_initProcessDelay = @delay(@_INIT_PROCESS_RESET_DELAY, (->
               @setState isInitProcess: false
            ).bind(this)
         )
         false
      else
         true


   render: ->
      statuses = @_REQUEST_STATUSES
      formRef = @_ELEMENT_REF_REFIXES.dynamicForm
      flasherContent = @_getFlasherContent()
      requestStatus = @state.requestStatus
      isRequested = requestStatus is statuses.requested

      `(
         <div>
            <form style={this.styles.common}
                  method={this.props.method}
                  onKeyDown={this._onKeyDownForm}
                  onKeyPress={this._onKeyPressForm}
                  onSubmit={this._onSubmit}
                  onReset={this._onReset}
                  ref={formRef}>
               <Flasher formMessages={this._getFlasherMessages()}
                        customMessages={flasherContent.messages}
                        caption={flasherContent.caption} />
               {this._getRelationKeyFields()}
               <div style={this.styles.contentWrapper}>
                  {this._getFormContent()}
               </div>
               <div style={this.styles.commandWrapper}>
                  {this._getActionCommandContent()}
                  {this._getMasterCommandContent()}
               </div>
               <AjaxLoader isShown={isRequested}
                           target={this.state.activityTarget}
                           view={this._LOADER_VIEW} />
            </form>
            {this._getInstancesController()}
         </div>
       )`


   componentDidUpdate: (prevProps, prevState) ->
      requestStatus = @state.requestStatus
      requestStatuses = @_REQUEST_STATUSES
      isRespondedInit = requestStatus is requestStatuses.respondedInit

      # # Считываем параметры элементов формы.
      # @_readFormElements()

   componentWillMount: ->
      @_masterSectionsPath = []

   componentDidMount: ->
      fluxParams = @props.fluxParams
      isHasFluxParams = @_isHasFluxParams()
      isUseServiceFlux = @_isUseServiceFlux()
      isHasPresetParams = @_isHasPresetParams()
      updateIdentifier = @props.updateIdentifier
      requestedFormState = @_REQUEST_STATUSES.requested
      preparedFormState =
         activityTarget: @refs.dynamicForm
      # Создадим идентификатор компонента.
      @_componentIdentifier = Date.now()

      # Если задан флаг использования сервисной инфраструктуры, то
      #  подписываемся на сервисную инфраструктуру.
      # Иначе, если заданы пользовательские параметры инфраструктуры flux,
      #  подписываемся на пользовательскую инфраструктуру flux.
      if isUseServiceFlux
         ServiceStore.addChangeListener @_onChangeService
      else if isHasFluxParams
         fluxParams.store.addChangeListener @_onChange

      # Если были заданы предустановленные параметры, то запускаем функцию запуска
      #  обработчика готовности компонента.
      # Иначе(если не были заданы предустановленные параметры), то отправляем запрос
      #  на получение начальных данных.
      if isHasPresetParams
         @_readyHandler()
      else
         # Если задан какой-либо флаг наличия параметров flux, то установим состояние
         #  запроса данных на "запрошено".
         if isUseServiceFlux or isHasFluxParams
            preparedFormState.requestStatus = requestedFormState

         # Если задан флаг использования сервисной инфраструктуры, то
         #  отправляем сервисный запрос,
         # Иначе, если заданы пользовательские параметры инфраструктуры flux, то
         #  отправляем запрос через заданные параметры, подписываемся на пользовательскую
         #  инфраструктуру flux.
         # В остальных случаях выдаем предупреждение о том, что необходимые параметры
         #  не были заданы.
         if isUseServiceFlux
            @_sendServiceInitRequest()
         else if isHasFluxParams
            fluxParams.sendInitRequest(updateIdentifier)
         else
            log.warn(@_MESSAGES.errors.presetOrFluxParamsNotSet)

      @setState preparedFormState

   componentWillUnmount: ->
      fluxParams = @props.fluxParams
      isHasFluxParams = @_isHasFluxParams()
      isUseServiceFlux = @_isUseServiceFlux()

      if isUseServiceFlux
         ServiceStore.removeChangeListener @_onChangeService
      else if isHasFluxParams
         fluxParams.store.removeChangeListener @_onChange

      # Запустим функцию удаления ссылки на элемент в органайзере операций
      #  (если он был задан).
      @_participateInToOrganizer(true)

   ###*
   * Функция получения параметров сформированных экземпляров полей формы.
   *
   * @return {Object}
   ###
   getFormFields: ->
      @state.formElements.fields

   ###*
   * Функция получения идентификатора обновляемого экземпляра.
   *
   * @return {Object}
   ###
   getUpdateIdentifier: ->
      @props.updateIdentifier

   ###*
   * Функция финализации отправленного запроса формы.
   *
   * @return {Object} response - полученный ответ финализируемого запроса.
   * @return {Object}
   ###
   finalizeRequest:(response) ->
      if @state.requestStatus is @_REQUEST_STATUSES.requested
         @_getResponse(response)

   ###*
   * Функция получения серилизованных данных формы.
   *
   * @return {String}
   ###
   getSerializedData: ->
      formElement = @refs[@_ELEMENT_REF_REFIXES.dynamicForm]
      serialize(ReactDOM.findDOMNode(formElement))

   ###*
   * Функция создания элемента с кнопками операции формы (отправка запроса, сброс).
   *
   * @return {React-element}
   ###
   _getActionCommandContent: ->
      actionParams = @state.actionParams
      actionButtons = []

      for actionName, actionParam of actionParams

         unless actionParam.isAbsent
            actionButtons.push(
               `(
                   <Button key={actionName}
                           type={actionParam.type}
                           title={actionParam.title}
                           caption={actionParam.caption}
                           isMain={actionParam.isMain}
                           icon={actionParam.icon}
                           styleAddition={this.styles.actionButton}
                           value={actionName}
                           onClick={this._onClickActionButton}
                        />
               )`
            )

      `(
         <span style={this.styles.mainCommandContainer}>
            {actionButtons}
         </span>
      )`

   # ###*
   # * Функция получения выводимой надписи на кнопке дейтсвия (отправка данных, сброс).
   # *
   # * @param {String} - тип кнопки дейтвия.
   # * @return {String}
   # ###
   # _getActionButtonCaption: (type)->
   #    defaultCaption = @_DEFAULT_ACTION_BUTTON_PARAMS[type].defaultCaption
   #    captionPropName = [type, @_SUFFIXES.caption].join @_CHARS.empty
   #    @props[captionPropName] || defaultCaption

   ###*
   * Функция получения функциональных командных кнопок для работы с формой.
   *  Функция проверяет является ли форма мастером (формой с заполнением аттрибутов
   *  внешних сущностей) и если является возвращает управляющие элементы для мастера.
   *
   * @return {Read-Element, undefined}
   ###
   _getMasterCommandContent: ->
      if @_isMasterForm()
         masterButtonParams = @_MASTER_BUTTON_PARAMS
         backParams = masterButtonParams.back
         forwardParams = masterButtonParams.forward
         masterButtonStates = @state.masterButtonStates
         isForwardDisabled = !masterButtonStates.forward
         isBackwardDisabled = !masterButtonStates.backward

         `(
            <span>
               <Button caption={backParams.caption}
                       icon={backParams.icon}
                       title={backParams.title}
                       styleAddition={this.styles.masterButton}
                       onClick={this._onClickMasterBackward}
                       onBlur={this._onBlurMasterButton.bind(this, isBackwardDisabled)}
                       isDisabled={isBackwardDisabled} />
               <Button caption={forwardParams.caption}
                       icon={forwardParams.icon}
                       title={forwardParams.title}
                       iconPosition='right'
                       styleAddition={this.styles.masterButton}
                       onClick={this._onClickMasterForward}
                       onBlur={this._onBlurMasterButton.bind(this, isForwardDisabled)}
                       isDisabled={isForwardDisabled} />
            </span>
          )`

   ###*
   * Функция создания полей для элементов цепи связок, непосредственно не входящих
   *  в набор полей, переданных для построения правильных параметров обновления
   *  записей.
   *
   * @return {Array<React-Elements>}
   ###
   _getRelationKeyFields: ->
      modelRelations = @props.modelParams.relations

      if modelRelations and modelRelations.length > 1
         chainLength = modelRelations.length
         immutable = @_constructImmutableSet()
         keyFields = []

         for idx in [0..(chainLength - 2)]
            relation = modelRelations[idx]
            elPrimaryKey = relation.primaryKey

            if elPrimaryKey?
               cuttedModelRelations = modelRelations[0..idx]
               immutable.modelRelations = undefined

               elPrimaryKey.value = relation.recordKey

               paramsForFormField =
                  field: elPrimaryKey
                  chain: cuttedModelRelations

               keyFields.push @_getFormField(paramsForFormField,
                                             idx,
                                             immutable)

         if keyFields.length
            `(
                <table>
                  <tbody>{keyFields}</tbody>
                </table>
            )`


   ###* TODO: убрать использование reflectionParams здесь и далее в цепи компонентов.
   * Функция получения содержимого динамической формы - поля и внешние сущности.
   *
   * @param {Object} params - хэш параметров для создания содержимого формы. Вид:
   *        {Object} fields                    - набор полей.
   *        {Object, Boolean} externalEntities - набор внешних сущностей. Если передано undefined -
   *                                             берем поля из @state.externalEntities. Если
   *                                             передан false - ничего не берем.
   *        {Object} reflectionParams          - параметры связки. Вид:
   *                 {String} name: - имя связки.
   *                 {String} caption: - локализованный заголовок связки.
   *                 {Array<String>} parents: - массив имен родительских связок.
   *        {Number} instanceNumber            - номер нового экземпляра содержимого.
   *        {Array<Object>} chain              - массив параметров иерархии связки.
   * @return {React-Element}
   ###
   _getFormContent: (params) ->
      if params? and !_.isEmpty params
         fields = params.fields
         externalEntities = params.externalEntities
         reflectionParams = params.reflectionParams
         instanceNumber = params.instanceNumber
         chain = params.chain

      unless chain?
         chain = @state.initChain or []

      unless externalEntities is false
         externalEntities ||= @state.externalEntities

      fields ||= @state.fields
      isHasExternalEntities = externalEntities? and !_.isEmpty externalEntities
      isCastlingWasDone = @_isCastlingWasDone()

      `(
         <DynamicFormContent externalEntities={externalEntities}
                             reflectionParams={reflectionParams}
                             fields={fields}
                             chain={chain}
                             isSingle={!isCastlingWasDone}
                             isShouldUpdate={this._isShouldContentUpdate()}
                             immutable={this._constructImmutableSet()}
                           />
       )`

   ###*
   * Функция получения элемента управления экземплярами связанных сущностей.
   *
   * @return {React-Element}
   ###
   _getInstancesController: ->
      editReflectionParams = @state.editReflectionParams

      if editReflectionParams?
         `(
            <DynamicFormInstancesController {...editReflectionParams}
                                            rootIdentifier={this.props.rootIdentifier}
                                            implementationStore={this.props.implementationStore}
                                            isUseImplementation={this.props.isUseImplementation}
                                            isMergeImplementation={this.props.isMergeImplementation}
                                            target={this}
                                            model={this.props.modelParams.name}
                                            organizer={this.props.organizer}
                                            chars={this._CHARS}
                                            onHide={this._onHideInstancesController}
                                            onShow={this._onShowInstancesController}
                                    />
          )`

   ###*
   * Функция получения разделителя для наборов полей.
   *
   * @param {Number} identifier - идентификатор разделителя.
   * @return {React-Element}
   ###
   _getElementsSplitter: (identifier) ->
      identifier ||= 1

      keyIdentifier = [
            Date.now()
            identifier
            @_SUFFIXES.splitter
         ].join @_CHARS.underscore

      `(
         <hr key={keyIdentifier}
             style={this.styles.elementsSplitter} />
      )`

   ###*
   * Функция получения кнопок управления кол-вом экземпляров элементов формы.
   *  Используется соглашение о том, что значение кнопки добавления = true,
   *  а кнопки удаления = false. Для возможности задания одного обработчика
   *  на обе кнопки.
   *
   * @param {Function} clickHandler - обработчик клика на кнопку добавления/удаления.
   * @param {Number} instancesCount - кол-во экземпляров.
   * @return {React-Element}
   ###
   _getInstanceControls: (clickHandler, instancesCount) ->
      externalEntityFunctionsParams = @_INSTANCE_CONTROL_PARAMS
      addFunction = externalEntityFunctionsParams.add
      removeFunction = externalEntityFunctionsParams.remove
      isHasDeletedElements = instancesCount? and instancesCount > 1

      deleteButton =
         if isHasDeletedElements
            `(
               <Button isLink={true}
                    caption={removeFunction.caption}
                    title={removeFunction.title}
                    icon={removeFunction.icon}
                    value={true}
                    onClick={clickHandler} />
             )`

      `(
         <div>
            <Button isLink={true}
                    caption={addFunction.caption}
                    title={addFunction.title}
                    icon={addFunction.icon}
                    value={false}
                    onClick={clickHandler} />
            {deleteButton}
         </div>
      )`

   ###*
   * Функция получения поля формы.
   *
   * @param {Object} params             - параметры для полей (свойства
   *                                      элемента DynamicFormField).
   * @parma {Number, String} elementKey - ключ элемента (для идентификации в наборе).
   * @param {Object} immutable          - неизменяемые параметры, передаваемые
   *                                      по всей цепи связок.
   * @return {React-Element}
   ###
   _getFormField: (params, elementKey, immutable) ->

      if params?
         clonedProps = _.cloneDeep(params)

         `(
             <DynamicFormField {...clonedProps}
                               key={elementKey}
                               immutable={immutable}
                             />
          )`

   ###*
   * Функция получения элемента с содержимым заголовка операции по которой
   *  построена форма для отображения в органайзере операций.
   *
   * @return {React-Element}
   ###
   _getOperationCaptionElement: (caption, subCaption) ->
      `(
         <span>
            <div style={this.styles.organizerElementSubCaption}>
               {subCaption}
            </div>
            <div style={this.styles.organizerElementCaption}>{caption}</div>
         </span>
       )`

   ###*
   * Функция получения параметров первичного ключа из набора полей.
   *
   * @param {Object} fields - коллекция параметров полей.
   * @return {Object} - параметры поля первичного ключа.
   ###
   _getPrimaryKeyFromFields: (fields) ->
      if fields?
         for fieldName, fieldParams of fields
            if fieldParams.isPrimaryKey
               return fieldParams

   ###*
   * Функция получения параметров полей значения в которых были "сброшены"
   *  (в полях были установлены начальные значения, затем они были установлены в
   *  "пустое" значение). Данные поля нужны для добавления в данные формы при
   *  обновлении.
   *
   * @return {Array<Object>}
   ###
   _getResetedFields: ->
      formElements = @state.formElements
      fields = formElements.fields if formElements?

      if fields?
         resetedFields = []

         for _fieldName, fieldParams of fields
            if fieldParams.isReseted
               resetedFields.push fieldParams

         resetedFields

   ###*
   * Функция получения дополнительного общего валидатора формы.
   *
   * @return {Function, undefined}
   ###
   _getTotalValidator: ->
      additionalValidationParams = @props.additionalValidationParams
      totalValidatorProp = @_TOTAL_VALIDATOR_PROP_NAME

      if additionalValidationParams
         if additionalValidationParams.hasOwnProperty totalValidatorProp
            totalValidator = additionalValidationParams[totalValidatorProp]

            _.isFunction(totalValidator) and totalValidator

   ###*
   * Функция получения параметров кнопок действия формы. Выполняет слияние
   *  параметров по-умолчанию и параметров, заданных через свойство
   *  @props.actionButtonParams.
   *
   * @return {Object}
   ###
   _getActionParams: ->
      _.merge {}, @_DEFAULT_ACTION_BUTTON_PARAMS, @props.actionButtonParams

   ###*
   * Функция получения начального набора элементов формы.
   *
   * @return {Object}
   ###
   _getInitFormElements: ->
      accordions: []
      fields: {}

   ###*
   * Функция получения начального состояния кнопок мастер-формы. Внопка "вперед"
   *  доступна, кнопка "назад" не доступна.
   *
   * @return {Object, undefined}
   ###
   _getInitMasterButtonStates: ->
      forward: true
      backward: false

   ###*
   * Функция получения списка сообщений для компонента Flasher - для отображения
   *  сообщения об ошибках формы.
   *
   * @return {Object, undefined} - набор сообщений.
   ###
   _getFlasherMessages: ->
      validationResult = @state.validationResult
      validationKeys = @_VALIDATION_RESULT_KEYS
      outputKey = validationKeys.flasherOutput

      if validationResult? and validationResult.hasOwnProperty(outputKey)
         validationOutput = validationResult[outputKey]

         # Если вывод валидации представлен в ввиде массива или хэша, то
         #  без изменения возвращаем их,
         # Иначе формируем хэш с ошибкой (формат, необходимый для компонента
         #  списка сообщений)
         if _.isArray(validationOutput) or _.isPlainObject(validationOutput)
            validationOutput
         else
            requestErrorCaption = @_REQUEST_ERROR_CAPTION

            validObj = {}
            validObj[@_REQUEST_ERROR_CAPTION] = validationOutput
            validObj

   ###*
   * Функция получения данных для списка сообщений (Flasher) с результатами запроса.
   *
   * @return {Object} - хэш для flasher - caption  - заголовок для Flasher-a
   *                                      messages - массив(формат нужен для Flahser-a),
   *                                                 содержащее сообщение об успехе запроса.
   ###
   _getFlasherContent: ->
      validationResult = @state.validationResult
      validationKeys = @_VALIDATION_RESULT_KEYS
      isResultHasErrors = validationResult? and
                          !$.isEmptyObject(validationResult) and
                          !$.isEmptyObject(validationResult[validationKeys.flasherOutput])
      statuses = @_REQUEST_STATUSES
      flasherParams = @_FLASHER_PARAMS
      respondedStat = statuses.responded
      isRespondedStatus = @state.requestStatus is respondedStat
      flasherCaption = @_CHARS.empty
      successMessages = []

      # Если нет ошибок - формируем результат успешного запроса.
      if isRespondedStatus and !isResultHasErrors
         successParams = flasherParams.successParams
         successMessages.push
            text: successParams.text
            type: successParams.type
      else if isResultHasErrors
         flasherCaption = flasherParams.errorCaption

      caption: flasherCaption
      messages: successMessages

   ###*
   * Функция считывания параметров для формы из ответа. Так как в ответе может
   *  быть передан полный ответ из API (json, errors, ...) или непосредственно только
   *  поля формы, то нужно искать как считать - сначала проверяем полную структуру
   *  овтета, если не находим - возвращаем в качестве параметров полей объект ответа.
   *
   * @param {Object} response - параметры ответа
   * @return {Object} - хэш с параметрами для формы. Вид:
   *         {Object} fields - параметры полей.
   *         {Object, undefined} externalEntities - параметры внешних связок.
   ###
   _getFormParams: (response)->
      jsonKey = @_JSON_KEY

      ###*
      * Функция считывания параметров ответа.
      *
      * @param {Object} response - параметры ответа.
      * @return {Object} - считанные данные.
      ###
      readParams = (response) ->
         responseKeys = @_RESPONSE_KEYS
         fieldsKey = responseKeys.fields
         externalEntitiesKey = responseKeys.externalEntities
         reflectionsMapKey = responseKeys.reflectionsMap
         params = {}

         params.fields = if response.hasOwnProperty fieldsKey
                            response[fieldsKey]
                         else
                            response

         params.externalEntities = if response.hasOwnProperty externalEntitiesKey
                                      response[externalEntitiesKey]

         params.reflectionsMap = if response.hasOwnProperty reflectionsMapKey
                                    response[reflectionsMapKey]

         params

      if response? and response.hasOwnProperty jsonKey
         responseJson = response[jsonKey]
         readParams.call(this, responseJson)
      else
         readParams.call(this, response)


   ###*
   * Обработчик на получение инициализационных данных формы.
   *  Получает поля формы и сохраняет их в состянии компонента
   *
   * @param {Object} response - данные ответа. Если параметр не задан, то
   *                            идет попытка считывания по заданным параметрам.
   * @return
   ###
   _getResponseInit: (response) ->
      responseParams = response || @props.fluxParams.getInitResponse()
      formParams = @_getFormParams(responseParams)
      fields = formParams.fields
      externalEntities = formParams.externalEntities
      reflectionsMap = formParams.reflectionsMap
      reflectionToMain = @props.reflectionToMain
      fieldReflectionParams = {}

      if reflectionToMain
         castlingResult = @_castlingElements(reflectionToMain,
                                             fields,
                                             externalEntities)
         fields = castlingResult.fields
         externalEntities = castlingResult.externalEntities
         initChain = castlingResult.initChain

      @_readyHandler()

      @setState
         fields: fields
         externalEntities: externalEntities
         initChain: initChain
         reflectionsMap: reflectionsMap
         requestStatus: @_REQUEST_STATUSES.respondedInit

   ###*
   * Обработчик на получение результата отправки данных формы в API.
   *  Проверяет на наличие ошибок, если ошибки есть - устанавливает статус
   *  отправки на неуспешный и устанавливает ошибки в состяние validationResult.
   *  При успешном результате (нет ошибок) устанавливает статус отправки на успешный
   *
   * @param {Object} response - данные ответа. Если параметр не задан, то
   *                            идет попытка считывания по заданным параметрам.
   * @return
   ###
   _getResponse: (response) ->
      fluxParams = @props.fluxParams
      onAfterGetResponseHandler = @props.onAfterGetResponse
      result = response || fluxParams.getResponse()
      errors = result.errors

      preparedState =
         requestStatus: @_REQUEST_STATUSES.responded

      # Если есть ошибки - утановим их в результат валидации и зададим статус
      #  отправки формы на ошибочный,
      # Иначе - установим статус на успешный, вызовем обработчик на событие после
      #  получения ответа
      if errors? # && !$.isEmptyObject(errors)
         validationResult = {}
         validationResult[@_VALIDATION_RESULT_KEYS.flasherOutput] = errors

         preparedState.validationResult = validationResult
      else
         preparedState.validationResult = {}
         activatedAction = @state.activatedAction
         activatedActionParams = @state.actionParams[activatedAction]

         if activatedActionParams.isClearAfter
            @_resetForm()

         # Вызываем обработчик на событие после получения ответа.
         if onAfterGetResponseHandler?
            onAfterGetResponseHandler result, activatedActionParams.isComplete

      @setState preparedState


   ###*
   * Функция получения цепи активных секций дочерних аккордеонов, начиная от текущей активной.
   *  Запускается рекурсивно для поиска всех дочерних секци. Возможно избыточна, т.к.
   *  в дальнейшем используется только последняя секция, хотя изначально предполагалось
   *  разворачивать все секции в цепи (возможно в дальнейшем потребуется).
   *
   * @param {Object} activeSection - параметры активной секции.
   * @param {Array<Object>} chain - цепь дочерних секций от текущей.
   * @return
   ###
   _getSectionsChain: (activeSection, chain) ->
      activeSectionIdentifier = activeSection.identifier
      formAccordions = @state.formElements.accordions

      ###*
      * Функция проверки находится ли данная секция в цепи секций.
      *
      * @param {Object} sectionParams - параметры текущей секции.
      * @param {Array} chain - цепь секций.
      * @return {Boolean} - флаг нахождения в цепи.
      ###
      isAccordionAlreadyInChain = (sectionParams, chain) ->
         for element in chain
            return true if sectionParams.identifier is element.accordion.identifier

         false

      # Перебираем все аккордеоны формы и для аккордеона родительский идентификатор
      #  которого сопадает с идентификатором секции - возьмем его текущую активную секцию.
      for accordionParams in formAccordions
         accordionSections = accordionParams.sections
         accordionComponent = accordionParams.accordion
         accordionParentIdentifier = accordionComponent.getParentIdentifier()

         # Продолжим, если секция уже в цепи.
         continue if isAccordionAlreadyInChain(accordionParams, chain)

         # Если идентификатор аккордеона совпадает с идентификатором секции - добавляем
         #  параметры в цепь.
         if accordionParentIdentifier is activeSectionIdentifier
            accordionActiveSection = accordionComponent.getActiveSectionParams()

            chain.push
               accordion: accordionParams
               activeSection: accordionActiveSection

            # Рекурсивно вызываем функцию обработки цепи.
            @_getSectionsChain(accordionActiveSection, chain)

   ###*
   * Функция получения параметров аккордеона по идентификатору одной из его секций.
   *
   * @param {String, Number} identifier - идентификатор секции.
   * @return {Object, null}
   ###
   _getAccordionBySectionIdentifier: (identifier) ->
      formAccordions = @state.formElements.accordions
      resultAccordion = null

      # Перебираем параметры всех аккордеонов формы и выбираем те, в которых
      #  находится секция с переданным идентификатором.
      for formAccordion in formAccordions
         fromSections = formAccordion.sections

         break if resultAccordion?

         for section in fromSections

            if section.identifier is identifier
               resultAccordion = formAccordion
               break

      resultAccordion

   ###*
   * Функция нахождения следующей секции в аккордеоне (или дочерних) и возврата
   *  индекса следующей этой секции в наборе.
   *
   * @param {String, Number} accordionIdentifier - идентификатор аккордеона.
   * @return {Number, undefined} - индекс секции в наборе.
   ###
   _getAndExpandNextSection: (accordionIdentifier) ->
      iterateProtectParams = @_TOO_MANY_ITERATE_PARAMS
      accordionParams = @_getAccordionParams(accordionIdentifier)
      accordionComponent = accordionParams.accordion
      accordionSections = accordionParams.sections
      activeSectionIdx = accordionComponent.getActiveSectionIndex()

      # Если в данном аккордеоне активная секция не последняя - берем следующую
      #  секцию из набора.
      # Иначе найдем родительский аккордеон в котором есть ещё не пройденные секции.
      if activeSectionIdx < accordionSections.length - 1
         nextActiveIdx = ++activeSectionIdx
         nextActiveSection = accordionSections[nextActiveIdx]
         nextAccordionIdentifier = accordionIdentifier
      else
         parentIdentifier = accordionComponent.context.parentIdentifier
         iterateProtectParams.counter = 0

         # Пока остается заданным идентификатор родителся ищем родительский
         #  аккордеон секции которого были ещё не все пройдены.
         while parentIdentifier?
            parentAccordion = @_getAccordionBySectionIdentifier(parentIdentifier)
            parentAccordionName = parentAccordion.name
            parentAccordionIdentifier = parentAccordion.identifier
            parentAccordionSections = parentAccordion.sections
            parentAccordionComponent = parentAccordion.accordion
            parentAccordionActiveSectionIdx = parentAccordionComponent.getActiveSectionIndex()

            # Защита от зацикливания.
            if iterateProtectParams.counter > iterateProtectParams.maxCounter
               log.error iterateProtectParams.error
               break

            # Если текущая активная секция не последняя в наборе - получаем её параметры
            #  задаем параметры выхода из цикла.
            # Иначе берем родительский элемент из контекста аккордеона и продолжаем.
            if parentAccordionActiveSectionIdx < parentAccordionSections.length - 1
               nextActiveIdx = ++parentAccordionActiveSectionIdx
               nextActiveSection = parentAccordionSections[nextActiveIdx]
               nextAccordionIdentifier = parentAccordionIdentifier
               accordionComponent = parentAccordionComponent
               parentIdentifier = null
            else
               parentIdentifier = parentAccordionComponent.context.parentIdentifier

            iterateProtectParams.counter++

      # Если удалось получить компонент аккордеона и следующую активную секцию в ней
      #  - развернем эту секцию добавим элемент с параметрами в путь мастер-формы.
      if accordionComponent? and nextActiveIdx?
         accordionComponent.expandSection(nextActiveIdx)

         @_masterSectionsPath.push
            accordionIdentifier: nextAccordionIdentifier
            activeSection: nextActiveSection

      nextActiveIdx

   ###*
   * Функция нахождения предыдущей секции в аккордеоне (или родительских),
   *  раскрытие этой секции и возврата индекса этой секции в наборе.
   *
   * @param {String, Number} accordionIdentifier - идентификатор аккордеона.
   * @return {Number, undefined} - индекс секции в наборе.
   ###
   _getAndExpandPrevSection: (activeAccordionIdentifier) ->
      iterateProtectParams = @_TOO_MANY_ITERATE_PARAMS
      activeAccordionParams = @_getAccordionParams(activeAccordionIdentifier)
      activeAccordionSections = activeAccordionParams.sections
      activeAccordionComponent = activeAccordionParams.accordion
      activeAccordionActiveSectionIdx = activeAccordionComponent.getActiveSectionIndex()
      activeSectionIdentifier =
         activeAccordionSections[activeAccordionActiveSectionIdx].identifier

      # Если индекс активной секции больше нуля, значит берем предыдущую секцию
      #  из набора.
      # Иначе - ищем предыдущие секции в родительских элементах.
      if activeAccordionActiveSectionIdx > 0
         prevActiveIdx = activeAccordionActiveSectionIdx - 1
         prevSectionIdentifier = activeAccordionSections[prevActiveIdx].identifier
         prevAccordionIdentifier = activeAccordionIdentifier
      else
         parentIdentifier = activeAccordionComponent.context.parentIdentifier
         iterateProtectParams.counter = 0

         # Пока задан родительский идентификатор - ищем предыдущую нераскрытую
         #  секцию в родительских секциях
         while parentIdentifier?
            parentAccordion = @_getAccordionBySectionIdentifier(parentIdentifier)
            parentAccordionName = parentAccordion.name
            parentAccordionIdentifier = parentAccordion.identifier
            parentAccordionSections = parentAccordion.sections
            parentAccordionComponent = parentAccordion.accordion
            parentAccordionActiveSectionIdx = parentAccordionComponent.getActiveSectionIndex()

            # Если в текущем аккордеоне есть предыдущие от текущей активной секции
            #  считываем парметры этой секции и устанавливаем условие выхода из цикла.
            # Иначе - берем родительский идентификатор из контекста и продолжаем цикл.
            if parentAccordionActiveSectionIdx > 0
               prevActiveIdx = --parentAccordionActiveSectionIdx
               activeAccordionComponent = parentAccordionComponent
               parentIdentifier = null
            else
               parentIdentifier = parentAccordionComponent.context.parentIdentifier

            # Защита от зацикливания.
            if iterateProtectParams.counter > iterateProtectParams.maxCounter
               log.error iterateProtectParams.error
               break

            iterateProtectParams.counter++

         prevSectionIdentifier = parentIdentifier
         prevAccordionIdentifier = parentAccordionIdentifier

      # Если удалось получить индекс предыдущей секции - раскроем её и сократим
      #  путь мастер-формы до этой секции.
      if prevActiveIdx? and activeAccordionComponent?
         activeAccordionComponent.expandSection prevActiveIdx

         @_spliceMasterPath(activeSectionIdentifier, prevAccordionIdentifier)

      prevActiveIdx

   ###*
   * Функция получения параметров аккордеона по переданным параметрам.
   *
   * @param {String, Number} identifier - идентификатор аккордеона.
   * @param {Array, undefined} formAccordions - набор аккордеонов.
   *                           Если параметр не задан, берется из состояний.
   * @return {Object, undefined}
   ###
   _getAccordionParams: (identifier, formAccordions) ->
      formAccordions ||= @state.formElements.accordions

      for accordion in formAccordions
         return accordion if accordion.identifier is identifier

   ###*
   * Функция получения данных, сопутствующих запросу в бизнес-логику.
   *
   * @props {String} dataType - считываемый тип данных.
   * @return {Object, nil}
   ###
   _getAccompanyingData: (dataType) ->
      accompanyingRequestData = @props.accompanyingRequestData
      accompanyingRequestData[dataType] if accompanyingRequestData?

   ###*
   * Функция установки значения в поле, сохраненного в состоянии компонента. Также
   *  устанавливает флаг "сброшенности", если в поле ранее было задано значение
   *  а новое значение "пустое" - такое поведение нужно для определения того, какие
   *  поля были сброшены при обновлении, и это позволяет добавить эти в поля в параметры
   *  передаваемые в API, так как пустые поля не серилизуются.
   *
   * @param {String, Array, Object, Number} values - значение(я) заданные в поле.
   * @param {Object} field                         - параметры поля.
   * @param {Object} name                          - имя поля.
   * @param {Boolean} isInitSet                    - флаг начальной установки значения
   *                                                 поля.
   * @return
   ###
   _setFieldValue: (value, field, name, isInitSet) ->
      formElements = @state.formElements
      formFields = formElements.fields

      if formFields?
         targetField = formFields[name]

         if targetField?
            # Если это начальная установка значения в поле, просто сохраняем
            #  значение в параметре initValue.
            # Иначе проверяем было ли задано ранее начальное значение и если было
            #  задано и при этом новое значение пустое - установим флаг сброса поля.
            if isInitSet
               targetField.initValue = value
               isNeedSetState = true
            else
               initFieldValue = targetField.initValue
               isInitValuePresent = initFieldValue?
               isFlagField = field.type is @_CHECKBOX_TYPE
               isNewValueEmpty = !value? or
                                 (_.isString(value) and value is @_CHARS.empty) or
                                 (_.isObject(value) and _.isEmpty value)
               isValueReseted = initFieldValue and (value isnt initFieldValue)
               isReseted = isInitValuePresent and ((!isFlagField and isNewValueEmpty) or
                                                   (isFlagField and isValueReseted))
               isResetedPrev = targetField.isReseted
               isResetedTrigger = isReseted isnt !!isResetedPrev

               # Если флаг сброшенности поменялся, то устанавливаем его в параметры
               if isResetedTrigger
                  targetField.isReseted = isReseted

               if isFlagField
                  targetField.isFlag = isFlagField

            # Меняет состояние компонента только если это начальная установка или
            #  флаг сброса поменялся.
            if isInitSet or isResetedTrigger
               formElements.fields[name] = targetField

               @setState formElements: formElements

   ###*
   * Функция запоминания для поля-словаря выбранных значений в состоянии компонента.
   *
   * @param {String, Array, Object, Number} values - значение(я) заданные в поле.
   * @param {Object} field                         - параметры поля.
   * @return
   ###
   _setDictionaryValues: (values, field) ->

      if @_isHasDictionaryRequestingParams field.reflection
         dictionariesSelectedValues = @state.dictionariesSelectedValues
         dictionariesSelectedValues[field.reflectionName] =
            if Array.isArray(values)
               values
            else
               [values]

         @setState dictionariesSelectedValues: dictionariesSelectedValues

   ###*
   * Функция установки состояния полиморфной связи в соответствии с
   *  выбранным значением. Производит установку состояния только если было
   *  передано поле типа полиморфной связи.
   *
   * @param {String} value - выбранная полиморфная сущность.
   * @param {Object} field - параметры поля.
   ###
   _setPolymorphicState: (value, field) ->
      isPolymorphicType = field.isPolymorphicType if field?
      chars = @_CHARS
      underscoreChar = chars.underscore

      if isPolymorphicType
         polymorphicStates = @state.polymorphicStates
         fieldName = field.name
         polymorphicStates = {} unless polymorphicStates?

         polymorphicStates[fieldName] = value

         @setState polymorphicStates: polymorphicStates

   ###*
   * Функция-предикат для определения были ли заданы параметры flux-инфраструктуры.
   *
   * @return {Boolean}
   ###
   _isHasFluxParams: ->
      fluxParams = @props.fluxParams
      fluxParams? and !_.isEmpty(fluxParams) and fluxParams.store?

   ###*
   * Функция-предикат для определения был ли задан флаг работы с сервисной
   *  инфраструктурой flux.
   *
   * @return {Boolean}
   ###
   _isUseServiceFlux: ->
      fluxParams = @props.fluxParams
      fluxParams? and fluxParams.isUseServiceInfrastructure

   ###*
   * Функция-предикат для определения были ли заданы предустановленные параметры
   *  для построения содержимого формы.
   *
   * @return {Boolean}
   ###
   _isHasPresetParams: ->
      presetParams = @props.presetParams
      presetParams? and !_.isEmpty(presetParams) and
      (presetParams.fields? or presetParams.externalEntities?)

   ###*
   * Функция-предикат для определения того, что форма находится в режиме
   *  редактирования.
   *
   * @return {Boolean}
   ###
   _isInUpdateMode: ->
      @props.mode is @_FORM_MODES.update

   ###*
   * Функция-предикат для определения было ли изменено состояние кнопок мастер-формы.
   *
   * @param {Object} newMasterButtonStates - хэш с новыми состояниями кнопок мастер-формы.
   ###
   _isMasterButtonStatesTriggered: (newMasterButtonStates) ->
      masterButtonStates = @state.masterButtonStates

      newMasterButtonStates.forward isnt masterButtonStates.forward or
      newMasterButtonStates.backward isnt masterButtonStates.backward

   ###*
   * Функция-предикат для определения является ли форма мастером(есть связки
   *  с внешними сущностями).
   *
   * @return {Boolean}
   ###
   _isMasterForm: ->
      @_isHasExternalEntities() or @_isHasComplexInternalReflection()

   ###*
   * Функция-предикат для определения должен ли переформировываться контент формы
   *  Контент будет переформировываться если форма находится в состоянии запроса
   *  "инициализационные данные получены" (то есть форма готова к построению
   *  содержимого).
   *
   * @return {Boolean}
   ###
   _isShouldContentUpdate: ->
      requestStatuses = @_REQUEST_STATUSES
      (@state.requestStatus is requestStatuses.respondedInit) or
      @state.isRefreshed


   ###*
   * Функция-предикат для проверки была ли выполнена "рокировка" элементов.
   * Определение идет по совокупности признаков.
   *
   * @return {Boolean}
   ###
   _isCastlingWasDone: ->
      reflectionToMain = @props.reflectionToMain
      initChain = @state.initChain

      reflectionToMain? and !_.isEmpty(initChain)

   ###*
   * Функция-предикат для определения содержат ли поля формы - ссылки на внешние
   *  сущности, у которых есть ссылки на внешние сущности.
   *  Функция проверяет есть ли в наборе полей формы - поля-ссылки на внешние
   *  сущности и они не являются полями выбора из словаря, а также данная связка не является
   *  разрывом цепи иерархии.
   *
   * @return {Boolean}
   ###
   _isHasComplexInternalReflection: ->
      fields = @state.fields

      if fields? and !_.isEmpty fields

         for fieldName, field of fields
            fieldInternalReflection = field.reflection

            if fieldInternalReflection?

               # Если для связки не заданы параметры считывания справочника
               unless @_isHasDictionaryRequestingParams fieldInternalReflection

                  # И это не прерывание цепи иерархии, - то это параметры для
                  #  создания полей нового экземпляра связанной сущности и
                  #  соответственно вернем положительный результат наличия
                  #  внутренней связки.
                  unless @_isHierarchyBreak null, fieldInternalReflection.name
                     instanceParams = fieldInternalReflection.instance

                     if instanceParams?
                        relations = instanceParams.relation

                        if relations?
                           for relName, rel in relations
                              isHasExtEntities =
                                 @_isHasExternalEntities rel.externalEntities

                              if isHasExtEntities
                                 return true
      false

   ###*
   * Функция-предикат для определения содержит ли форма полноценные связки с внешними
   *  сущностями(не являющиеся разрывом цепи иерархии).
   *
   * @param {Object} externalEntities - проверяемый набор внешних сущностей.
   * @return {Boolean}
   ###
   _isHasExternalEntities: (externalEntities) ->
      externalEntities ||= @state.externalEntities
      isExistExternalEntities =
         externalEntities? and
         _.isPlainObject(externalEntities) and
         !_.isEmpty(externalEntities)

      if isExistExternalEntities
         for extEntityName, externalEntity of externalEntities

            # Если для сущности не задан зарзыв цепи иерарихии, значит есть
            #  полноценная связка с внешними сущностями - возвращаем положительное
            #  значения наличия внешней связанной сущности.
            unless @_isHierarchyBreak(null, externalEntity.reflectionName)
               return true

      false


   ###*
   * Функция-предикат для проверки наличия параметров для запроса справочника
   *  поля.
   *
   * @param {Object} reflection - параметры связки.
   * @return {Boolean} - флаг наличия параметров.
   ###
   _isHasDictionaryRequestingParams: (reflection) ->
      dictionaryReflection = undefined
      isHasRequestingParams = false

      if reflection? and !$.isEmptyObject(reflection)
         dictionaryReflection = reflection.dictionary

      if dictionaryReflection? and !$.isEmptyObject dictionaryReflection
         isHasRequestingParams =
            dictionaryReflection.requestingParams? and
            !_.isEmpty(dictionaryReflection.requestingParams)

      isHasRequestingParams

   ###*
   * Функция-предикат для определения является ли связка родитель-сущность разрывом иерархии.
   *  Функция нужна для определения мест, где необходимо обрывать формирование иерархии.
   *
   * @param {String} parentName     - имя родительской сущности.
   * @param {String} reflectionName - имя связанной сущности.
   * @return {Boolean}
   ###
   _isHierarchyBreak: (parentName, reflectionName) ->
      hierarchyBreakParams = @props.hierarchyBreakParams

      # Если имя родительской сущности не задано - зададим в качестве её
      #  алиас корневой сущности.
      unless parentName?
         parentName = @_ROOT_NODE_CONTENT_ALIAS

      if hierarchyBreakParams? and !$.isEmptyObject hierarchyBreakParams
         for breakParentName, breakReflectionNames of hierarchyBreakParams
            isBreakForParent = breakParentName is parentName
            isBreakForReflection =
               if _.isArray breakReflectionNames
                  reflectionName in breakReflectionNames
               else
                  breakReflectionNames is reflectionName

            if isBreakForParent and isBreakForReflection
               return true

      false

   # ###*
   # * Обработчик клика на кнопку добавления экземпляра сущности.
   # *
   # * @param {String} elementParams - параметры добавляемого элемента элемента. Вид:
   # *        {String} identifier - идентификатор.
   # *        {String} type - тип элемента (секция/аккордеон).
   # * @return
   # ###
   # _onClickAddElementInstance: (elementParams)->
   #    @_changeElementInstancesCount(elementParams, false)

   # ###*
   # * Обработчик клика на кнопку удаления экземпляра сущности.
   # *
   # * @param {String} elementParams - параметры добавляемого элемента элемента. Вид:
   # *        {String} identifier - идентификатор.
   # *        {String} type - тип элемента (секция/аккордеон).
   # * @return
   # ###
   # _onClickRemoveElementInstance: (elementParams)->
   #    @_changeElementInstancesCount(elementParams, true)

   ###*
   * Обработчик на изменения значения в поле. Необходим для отлова событий изменения
   *  перечислений типов полиморфных связей, полей-справочников и установки
   *  введенных значений в полях.
   *
   * @param {String, Object, Array} value - значение в поле.
   * @param {Object} field                - параметры поля.
   * @param {String} name                 - имя поля в форме.
   * @param {Boolean} isInitSet           - флаг начальной установки значения в поле.
   * @return
   ###
   _onChangeField: (value, field, name, isInitSet)->
      @_setPolymorphicState(value, field)
      @_setDictionaryValues(value, field)
      @_setFieldValue(value, field, name, isInitSet)
      @_resetRefreshed()

      onChangeHandler = @props.onChangeField
      onChangeHandler(value, field, name, this) if onChangeHandler?

      @setState isInitProcess: true

   ###*
   * Обработчик на очистку значения в поле.
   *
   * @param {String, Object, Array} value - значение в поле.
   * @param {Object} field                - параметры поля.
   * @param {String} name                 - имя поля в форме.
   * @param {Boolean} isInitSet           - флаг начальной установки значения в поле.
   * @return
   ###
   _onClearField: (field, name)->
      formElements = @state.formElements
      formFields = formElements.fields
      onClearHandler = @props.onClearField

      onClearHandler(formFields[name], this) if onClearHandler?
   ###*
   * Обработчик клика на кнопку действия формы.
   *
   * @param {String} actionName - наименование действия.
   * @return
   ###
   _onClickActionButton: (actionName) ->
      @setState activatedAction: actionName

   ###*
   * Обработчик на добавление поля ввода в форму. Добавляет параметры поля
   *  в коллекцию полей в состоянии формы для дальнейших манипуляций.
   *
   * @param {React-element} field - экземпляр поля ввода.
   * @return
   ###
   _onInitField: (field) ->
      fieldValue = field.getValue()
      fieldParams = field.getFieldParams()
      fieldName = field.getName()
      formElements = @state.formElements
      formFields = formElements.fields
      onInitFieldHanlder = @props.onInitField

      @setState isInitProcess: true

      ###*
      * Функция получения параметров поля.
      *
      * @param {React-element} field - элемент поля ввода.
      * @return {Object}
      ###
      getFieldParams = ((field) ->
         chars = @_CHARS
         fieldParams = field.getFieldParams()
         fieldModelParams = field.getModelParams()
         fieldName = field.getName()
         fieldValue = field.getValue()
         fieldNameFromParams = fieldParams.name
         fieldType = fieldParams.type
         fieldCaption = fieldParams.caption
         fieldModelCaption = fieldModelParams.caption
         isPolymorphicType = fieldParams.isPolymorphicType

         # Формируем заголовок валидации в зависимости от того задан ли заголовок
         #  модели поля или нет.
         validationCaption =
            if fieldModelCaption?
               [
                  fieldModelCaption
                  fieldCaption
               ].join chars.colon
            else
               fieldCaption

         instance: field
         fieldName: fieldName
         name: fieldNameFromParams
         type: fieldType
         initValue: fieldValue
         parentsIdentifier: field.getParentsIdentifier()
         isPolymorphicType: isPolymorphicType
         validation:
            handler: field.validate
            caption: validationCaption
         reflection:
            name:fieldModelParams.reflectionName
            chain: fieldModelParams.chain
      ).bind(this)

      formFieldParams = getFieldParams(field)
      formFields[fieldName] = formFieldParams
      formElements.fields = formFields

      onInitFieldHanlder(formFieldParams, this) if onInitFieldHanlder?
      #@_onChangeField(fieldValue, fieldParams)

      @_setPolymorphicState(fieldValue, fieldParams)
      @_setDictionaryValues(fieldValue, fieldParams)

      @setState formElements: formElements

   ###*
   * Обработчик на размонирование поля ввода. Находит удаляемое поле в наборе
   *  элементов формы и удаляет его.
   *
   * @param {React-element} field - элемент поля ввода.
   * @return
   ###
   _onDestroyField: (field) ->
      formElements = @state.formElements
      formFields = formElements.fields
      destroyedFieldName = field.getName()
      onDestroyFieldHanlder = @props.onDestroyField

      if onDestroyFieldHanlder?
         onDestroyFieldHanlder(formFields[destroyedFieldName], this)

      if formFields.hasOwnProperty(destroyedFieldName)
         formFields = _.omit(formFields, [destroyedFieldName])

         formElements.fields = formFields

         @setState formElements: formElements

   ###*
   * Обработчик на добавление аккордеона в форму. Добавляет параметры аккордеона
   *  в состояние формы для дальнейших манипуляций.
   *
   * @param {React-element} accordion - элемент аккордеона.
   * @return
   ###
   _onInitAccordion: (accordion) ->
      formElements = @state.formElements
      masterSectionsPath = @_masterSectionsPath
      formAccordions = formElements.accordions
      accordionName = accordion.getName()
      accordionSections = accordion.getSectionParams()
      accordionIdentifier = accordion.getIdentifier()
      accordionActiveSection = accordion.getActiveSectionParams()

      formAccordions.push
         accordion: accordion
         sections: accordionSections
         name: accordionName
         identifier: accordionIdentifier

      unless masterSectionsPath.length
         masterSectionsPath.push
            activeSection: accordionActiveSection
            accordionIdentifier: accordionIdentifier

      formElements.accordions = formAccordions

      @setState formElements: formElements

   ###*
   * Обработчик на удаление аккордеона из формы. Удаляет параметры аккордеона
   *  из состояния формы.
   *
   * @param {React-element} accordion - элемент аккордеона.
   * @return
   ###
   _onDestroyAccordion: (accordion) ->
      formElements = @state.formElements
      formAccordions = formElements.accordions
      deletedIdentifier = accordion.getIdentifier()

      for formAccordion, idx in formAccordions
         if formAccordion.identifier is deletedIdentifier
            formAccordions.splice(idx, 1)
            break

      formElements.accordions = formAccordions

      @setState formElements: formElements

   ###*
   * Обработчик клика по кнопке редактирования связанной сущности.
   *
   * @param {Object} value - значение, необходимые для редактирования экземпляров
   *                         связанных сущностей.
   * @return
   ###
   _onClickEditReflection: (value) ->
      modelRelations = @props.modelParams.relations
      isHasModelRelations = modelRelations? and modelRelations.length

      if isHasModelRelations
         chainValue = value.chain
         chainValue = Array.concat(modelRelations, chainValue)
         value.chain = chainValue

      value.dataManipulationParams =
         @_prepareDataManipulationParams(value.chain)

      @setState editReflectionParams: value
   ###*
   * Обработчик на скрытие области редактирования связанных записей. Сбрасывает
   *  значения редактируемых параметров.
   *
   * @return
   ###
   _onHideInstancesController: ->
      @setState editReflectionParams: null

   ###*
   * Обработчик клика по кнопке "вперед" в мастере. Ищет следующую
   *  активную секцию и раскрывает её.
   *
   * @return
   ###
   _onClickMasterForward: ->
      masterPath = @_masterSectionsPath
      activeSectionParams = masterPath[masterPath.length - 1]
      formAccordions = @state.formElements.accordions
      newMasterButtonStates = _.cloneDeep(@state.masterButtonStates)
      newMasterButtonStates.backward = true

      # Если заданы аккордеоны формы.
      if formAccordions? and formAccordions.length
         nextSectionsChain = []

         @_getSectionsChain(activeSectionParams.activeSection, nextSectionsChain)

         if nextSectionsChain.length
            lastElementInChain = nextSectionsChain[nextSectionsChain.length - 1]
            accordionIdx = lastElementInChain.accordion.identifier
         else
            accordionIdx = activeSectionParams.accordionIdentifier

         nextActiveSectionIndex = @_getAndExpandNextSection accordionIdx

         unless nextActiveSectionIndex?
            newMasterButtonStates.forward = false

         # Устанавливаем состояние компонента, только если состояние кнопок было изменено.
         if @_isMasterButtonStatesTriggered(newMasterButtonStates)
            @setState
               masterButtonStates: newMasterButtonStates

   ###*
   * Обработчик клика по кнопке "назад" в мастере. Ищет предыдущюю активную секцию
   *  на корневом аккордеоне и раскрывает её.
   *
   * @return
   ###
   _onClickMasterBackward: ->
      newMasterButtonStates = _.clone(@state.masterButtonStates)
      newMasterButtonStates.forward = true
      masterPath = @_masterSectionsPath
      activeSectionParams = masterPath[masterPath.length - 1]
      activeAccordionIdentifier = activeSectionParams.accordionIdentifier
      prevActiveIdx = @_getAndExpandPrevSection activeAccordionIdentifier

      # Если предыдущая секция не найдена - установим неактивной кнопку "Назад".
      unless prevActiveIdx?
         newMasterButtonStates.backward = false

      # Устанавливаем состояние компонента, только если состояние кнопок было изменено.
      if @_isMasterButtonStatesTriggered(newMasterButtonStates)
         @setState
            masterButtonStates: newMasterButtonStates

   ###*
   * Обработчик после окончания открытия секции аккордеона. Устанавливает
   *  в переменную экземпляра параметры текущей активной секции аккордеона.
   *
   * @param {Object} sectionParams - параметры открытой секции.
   * @param {String} accordionIdentifier - идентификатор аккордеона.
   * @return
   ###
   _onAccordionSectionOpened: (sectionParams, accordionIdentifier) ->
      newMasterButtonStates = _.clone(@state.masterButtonStates)
      masterPath = @_masterSectionsPath

      @_masterSectionsPath.push
         activeSection: sectionParams
         accordionIdentifier: accordionIdentifier

      # Если в состоянии кнопка "вперед" не активна - разблокируем её.
      unless newMasterButtonStates.forward
         newMasterButtonStates.forward = true

      # Если в состоянии кнопка "назад" не активна - разблокируем её.
      unless newMasterButtonStates.backward
         newMasterButtonStates.backward = true

      # Устанавливаем состояние компонента, только если состояние кнопок было изменено.
      if @_isMasterButtonStatesTriggered newMasterButtonStates
         @setState masterButtonStates: newMasterButtonStates

   ###*
   * Функция-обработчик на потерю фокуса кнопками мастер-формы. Для отлова события
   *  ухода фокуса с деактивируемой кнопки(и закрытия области на которой расположена форма) -
   *  когда целевой узел не задан.
   *
   * @param {Boolean} isButtonDisabled - флаг того, что кнопка деактивируется.
   * @param {Object} event - объект события.
   * @return
   ###
   _onBlurMasterButton: (isButtonDisabled, event) ->
      thisButton = event.target
      relatedTarget = event.relatedTarget

      if isButtonDisabled and !relatedTarget?
         masterButtons = thisButton.parentNode.childNodes
         otherButton = _.find(masterButtons, (button) ->
            button.dataset.reactid isnt thisButton.dataset.reactid
         )

         otherButton.focus()

   ###*
   * Обработчик на изменение состояния сервисного хранилища. Проверяет событие,
   *  на которое был вызван данный обработчик произошло для данного компонента
   *  или нет, затем получает данные и вызывает различные обработчики результата
   *  в зависимости от того по какому методу взаимодействия с API произошло
   *  событие.
   *
   * @return
   ###
   _onChangeService: ->
      model = @props.modelParams.name
      componentIdentifier = @_componentIdentifier
      isEventOccuredForComponent =
         ServiceStore.isEventOccuredForComponent(model, componentIdentifier)

      if isEventOccuredForComponent
         lastEvent = ServiceStore.getLastEvent()
         APIMethods = ServiceFluxConstants.APIMethods
         lastAPIMethod = lastEvent.APIMethod
         lastCustomMethod = lastEvent.customMethod
         responseData = ServiceStore.getData(model,
                                             componentIdentifier,
                                             lastAPIMethod,
                                             lastCustomMethod)

         switch lastAPIMethod
            when APIMethods.show, APIMethods.new
               @_getResponseInit(responseData)
            when APIMethods.create, APIMethods.update
               @_getResponse(responseData)

   ###*
   * Обработчик на изменение состояния хранилища.
   *  Считывает результаты:
   *     - инициализационного запроса полей формы;
   *     - результат отправки запроса данных формы и проверяет объект
   *       на наличие ошибок. Если есть ошибки устанавливает их в качестве
   *       результата валидации. Если нет устанавливает результат отправки формы на успешный
   *
   * @return
   ###
   _onChange: ->
      fluxParams = @props.fluxParams
      storeLastInteraction = fluxParams.store.getLastInteraction()

      switch storeLastInteraction
         # событие на принятие данных инициализационного запроса (поля формы и значения(опционально))
         when fluxParams.responseInitType
            @_getResponseInit()
         # Событие на принятие результата отправки данных формы
         when fluxParams.responseType
            @_getResponse()

   ###*
   * Обработчик на отправку результатов формы.
   *  Отменяет стандартое поведение(отправка с перезагрузкой),
   *  запускает валидацию, по результатам которой, либо выдает
   *  список ошибок, либо отпавляет целевой ajax-запрос формы.
   *
   * @param {Object} event - объект события
   * @return
   ###
   _onSubmit: (event) ->
      event.preventDefault()
      @_validateFieldsAndSubmit()

   ###*
   * Обработчик на очистку полей формы
   *
   * @param {Object} event - объект события
   * @return
   ###
   _onReset: (event) ->
      event.preventDefault()
      @_resetForm()

   ###*
   * Функция подготовки параметров "рокировки" главных полей полями одной из
   *  внешних связок. Нужна для создания формы на основе данных начиная от какой-либо
   *  внешней связки. TODO: в настоящий момент реализована "рокировка" только для
   *  непосредственных внешних связок, заданных в форме(один уровень вложенности)
   *  и только внешние.
   *
   * @param {String} reflectionToMain - связка для которой будут браться параметры для
   *                                    для преобразования в главные параметры.
   * @param {Object} fields - текущие главные поля.
   * @param {Object} extenalEntities - текущие внешние связки.
   ###
   _castlingElements: (reflectionToMain, fields, externalEntities) ->
      mainExtReflection = externalEntities[reflectionToMain]

      if mainExtReflection?
         modelParams = @props.modelParams
         fields = mainExtReflection.fields
         externalEntities = mainExtReflection.externalEntities
         chain = []
         @_addElementToChain(chain,
            reflection: mainExtReflection.reflectionName
            caption: mainExtReflection.entityCaption
            index: 1
            isCollection: true
         )

         if modelParams? and !_.isEmpty modelParams
            modelName = modelParams.name

            if modelName?
               foreignKeyFieldName = [
                  modelName
                  @_ID_FIELD_ALIAS
               ].join @_CHARS.underscore

               _.unset(fields, foreignKeyFieldName)

      fields: fields
      externalEntities: externalEntities
      initChain: chain

   ###*
   * Функция обарбатывающее событие готовности компонента к проведению операции.
   *
   * @return
   ###
   _readyHandler: ->
      onReadyHandler = @props.onReady

      # Если начальные данные были получены, то вызываем обработчик события
      #  готовности к проведению операции.
      if onReadyHandler?
         onReadyHandler(this)

      @_participateInToOrganizer()

   ###*
   * Функция добавления/удаленя в/из органайзер(а) опреаций, если они был задан
   *  через свойства компонента.
   *
   * @props {Boolean} isRemove - флаг удаления из органайзера.
   * @return
   ###
   _participateInToOrganizer: (isRemove) ->
      organizer = @props.organizer

      if organizer?
         componentIdentifier = @_componentIdentifier

         if isRemove
            organizer.removeElement(componentIdentifier)
         else

            element =
               identifier: @_componentIdentifier
               caption: @_prepareOperationCaption()
               component: this

            organizer.addElement(element)

   ###*
   * Функция подготовки параметров манипуляции данными для контроллера связанных
   *  экземпляров.
   *
   * @param {Array<Object>} chain
   * @return
   ###
   _prepareDataManipulationParams: (chain) ->
      lastReflectionParams = _.last(chain)
      lastReflection = lastReflectionParams.reflection if lastReflectionParams?
      processedFieldsOrder = _.cloneDeep(@props.fieldsOrder)
      processedSectionsOrder = _.cloneDeep(@props.sectionsOrder)
      processedFieldConstraints = _.cloneDeep(@props.fieldConstraints)
      processedSectionConstraints = _.cloneDeep(@props.sectionConstraints)

      # Если получено наименование последей связки - подготавливаем параметры
      #  упорядочивания секций и полей.
      if lastReflection?
         reflectionSectionsOrder =
            if processedSectionsOrder? and !_.isEmpty(processedSectionsOrder)
               processedSectionsOrder[lastReflection]
         reflectionFieldsOrder =
            if processedFieldsOrder? and !_.isEmpty(processedFieldsOrder)
               processedFieldsOrder[lastReflection]

         if reflectionSectionsOrder? and !_.isEmpty(processedSectionsOrder)
            processedSectionsOrder.root = reflectionSectionsOrder
            _.unset(processedSectionsOrder, lastReflection)

         if reflectionFieldsOrder? and !_.isEmpty(processedFieldsOrder)
            processedFieldsOrder.root = reflectionFieldsOrder
            _.unset(processedFieldsOrder, lastReflection)

      # Если цепь связок не пустая(просто для перестраховки) и
      #  заданы ограничения для полей - выполним предварительную обработку
      #  ограничений для корректной работы на контроллере связанных экземпляров
      #  (таблице данных для подготовки динамической формы).
      if !_.isEmpty(chain) and !_.isEmpty(processedFieldConstraints)
         processedConstraints = processedFieldConstraints.constraints
         chainReflections = chain.map (element) -> element.reflection

         unless _.isEmpty(processedConstraints)
            for constr, idx in processedConstraints
               constrParents = constr.parents

               if constrParents?
                  parentsDiff = _.difference(constrParents, chainReflections)

                  unless _.isEqual(parentsDiff, constrParents)
                     constr.parents = parentsDiff

      fieldConstraints: processedFieldConstraints
      sectionConstraints: processedSectionConstraints
      fieldsOrder: processedFieldsOrder
      sectionsOrder: processedSectionsOrder
      hierarchyBreakParams: @props.hierarchyBreakParams
      externalEntitiesParams: @props.externalEntitiesParams
      reflectionParams: @props.reflectionParams

   ###*
   * Функция подготовки заголовка операции, по которой построена данная форма.
   *  для вывода в органайзере операций.
   *
   * @props {String}
   ###
   _prepareOperationCaption: ->
      modelParams = @props.modelParams
      modelRelations = modelParams.relations
      chars = @_CHARS
      emptyChar = chars.empty
      colonChar = chars.colon
      spaceChar = chars.space
      editNameElement = @_EDIT_OPERATION_NAME_ELEMENT

      if modelRelations?
         lastRelation = modelRelations[modelRelations.length - 1]

         operationKey = lastRelation.recordKey
         relationCaption =
            [
               lastRelation.caption
               colonChar
            ].join emptyChar
      else
         relationCaption = modelParams.caption
         operationKey = @props.updateIdentifier

      editString =
         [
            editNameElement
            spaceChar
            operationKey
         ].join emptyChar

      @_getOperationCaptionElement(editString, relationCaption)

   ###*
   * Функция создания набора неизменяемых параметров, прокидываемых по всей цепи
   *  связок.
   *
   * @return {Object}
   ###
   _constructImmutableSet: ->
      props = @props
      state = @state

      dictionariesSelectedValues: state.dictionariesSelectedValues
      mode: props.mode
      updateIdentifier: props.updateIdentifier
      modelParams: props.modelParams
      additionalValidationParams: props.additionalValidationParams
      fieldsOrder: props.fieldsOrder
      fieldConstraints: props.fieldConstraints
      sectionConstraints: props.sectionConstraints
      denyToEditReflections: props.denyToEditReflections
      denyReflections: props.denyReflections
      enableManuals: props.enableManuals
      sectionsOrder: props.sectionsOrder
      externalEntitiesParams: props.externalEntitiesParams
      reflectionControlParams: props.reflectionParams
      reflectionRenderParams: props.reflectionRenderParams
      implementationStore: props.implementationStore
      isUseImplementation: props.isUseImplementation
      isMergeImplementation: props.isMergeImplementation
      isImplementationHigherPriority: props.isImplementationHigherPriority
      isAddAttributesSuffixForChain: props.isAddAttributesSuffixForChain
      enableManageReflections: props.enableManageReflections
      isRefreshed: state.isRefreshed
      validationResult: state.validationResult
      polymorphicStates: state.polymorphicStates
      isInUpdateMode: @_isInUpdateMode()
      aliases: @_ALIASES
      suffixes: @_SUFFIXES
      chars: @_CHARS
      prefixes: @_ELEMENT_REF_REFIXES
      tipTypes: @_TIP_TYPES
      idFieldAlias: @_ID_FIELD_ALIAS
      metaButtonParams: @_META_BUTTON_PARAMS
      getPrimaryKeyFromFields: @_getPrimaryKeyFromFields
      getElementsSplitter: @_getElementsSplitter
      getInstanceControls: @_getInstanceControls
      getFormField: @_getFormField
      addElementToChain: @_addElementToChain
      changeLastNodeIndex: @_changeLastNodeIndex
      onChangeField: @_onChangeField
      onClearField: @_onClearField
      onInitField: @_onInitField
      onDestroyField: @_onDestroyField
      onInitAccordion: @_onInitAccordion
      onDestroyAccordion: @_onDestroyAccordion
      onClickEditReflection: @_onClickEditReflection
      onClickOpenManual: props.onClickOpenManual

   ###*
   * Функция отправки запроса на получение начальных данных с использованием
   *  сервисной инфраструктуры flux. Подготавливает параметры для общего
   *  запроса через сервисную инфраструктуру и отправляет запрос.
   *
   * @return
   ###
   _sendServiceInitRequest: ->
      isInUpdateMode = @_isInUpdateMode()
      updateIdentifier = @props.updateIdentifier
      modelParams = @props.modelParams
      serviceAPIMethods = ServiceFluxConstants.APIMethods
      APIMethod =
         if isInUpdateMode
            serviceAPIMethods.show
         else
            serviceAPIMethods.new

      paramsForRequest =
         requestData:
            relations: modelParams.relations
         instanceID: updateIdentifier
         accompanying: @_getAccompanyingData(@_ACCOMPANYING_DATA_TYPES.init)
         componentID: @_componentIdentifier
         model: modelParams.name
         APIMethod: APIMethod

      ServiceActionCreators.dataRequest paramsForRequest

   ###*
   * Функция отправки запроса в бизнес-логику с использованием
   *  сервисной инфраструктуры flux. Подготавливает параметры для общего
   *  запроса через сервисную инфраструктуру и отправляет запрос.
   *
   * @param {Object} formData         - данные формы для отправки в API.
   * @param {Number} updateIdentifier - идентификатор обновляемой записи.
   * @return
   ###
   _sendServiceRequest: (formData, updateIdentifier) ->
      isInUpdateMode = @_isInUpdateMode()
      serviceAPIMethods = ServiceFluxConstants.APIMethods
      modelParams = @props.modelParams
      customServiceFluxParams = @props.customServiceFluxParams

      APIMethod =
         if isInUpdateMode
            serviceAPIMethods.update
         else
            serviceAPIMethods.create

      paramsForRequest =
         requestData:
            accompanying: @_getAccompanyingData(@_ACCOMPANYING_DATA_TYPES.action)
            relations: modelParams.relations
            data: formData
         instanceID: updateIdentifier
         componentID: @_componentIdentifier
         model: modelParams.name
         customSendParams: customServiceFluxParams
         APIMethod: APIMethod

      ServiceActionCreators.dataRequest paramsForRequest

   ###*
   * Функция вырезки части пути секций мастер-формы, начиная от определенной секции.
   *
   * @param {String} sectionIdentifier - идентификатор секции.
   * @param {String} accordionIdentifier - идентификатор аккордеона.
   * @return
   ###
   _spliceMasterPath: (sectionIdentifier, accordionIdentifier) ->
      pathLength = @_masterSectionsPath.length
      masterPath = @_masterSectionsPath

      if masterPath.length > 1
         for element, idx in masterPath
            if element.accordionIdentifier is accordionIdentifier and
            element.activeSection.identifier is sectionIdentifier
               startIdx = idx
               break

         # Последний(т.е. первый) элемент не удаляем.
         startIdx = 1 if startIdx is 0

         @_masterSectionsPath.splice(startIdx, pathLength)

   ###*
   * Функция установки параметров сброса формы.
   *
   * @return
   ###
   _resetForm: ->
      @setState
         validationResult: {}
         isRefreshed: true
         requestStatus: @_REQUEST_STATUSES.ready

   ###*
   * Функция отправки данных формы.
   *
   * @return
   ###
   _submitFormData: ->
      isHasFluxParams = @_isHasFluxParams()
      isUseServiceFlux = @_isUseServiceFlux()
      customSubmitHandler = @props.customSubmitHandler
      formData = @getSerializedData()
      updateIdentifier = @props.rootIdentifier || @props.updateIdentifier
      # { hash: true, empty: false, disabled: true}
      #formData = $(ReactDOM.findDOMNode(this)).serialize()

      # В режиме "обновления" - ищем поля, значения в которых были сброшены, серилизуем
      #  в строку для передачи по http и добавляем в основную строку данных запроса.
      if @_isInUpdateMode()
         resetedFields = @_getResetedFields()
         isResetedFieldsPresent = !_.isEmpty(resetedFields)
         emptyChar = @_CHARS.empty

         if isResetedFieldsPresent
            for resetedField in resetedFields

               # Определяем значение в сброшенно поле - если поле-флаг, значит
               #  зададим булево значение(конвертированой в строку),
               #  иначе просто пустую строку.
               resetedValue = if resetedField.isFlag
                                 false.toString()
                              else
                                 emptyChar

               formData = @strUriSerialize(formData,
                                           resetedField.fieldName,
                                           resetedValue)


      if isUseServiceFlux
         @_sendServiceRequest(formData, updateIdentifier)
      else if isHasFluxParams
         fluxParams = @props.fluxParams

         dataForRequest =
            data: formData
            relations: @props.modelParams.relations

         fluxParams.sendRequest(dataForRequest, updateIdentifier)
      else if customSubmitHandler?
         customSubmitHandler(formData, updateIdentifier)

      @setState
         requestStatus: @_REQUEST_STATUSES.requested
         activityTarget: @refs.dynamicForm

   ###*
   * Функция сброса флага обновленности.
   *
   * @return
   ###
   _resetRefreshed: ->
      if @state.isRefreshed
         @setState
            isRefreshed: false

   ###*
   * Функция проверки полей формы на корректность. Параллельно асинхронно выполняет
   *  функции валидации.
   *
   * @return
   ###
   _validateFieldsAndSubmit: ->
      dynamicForm = this
      formElements = @state.formElements
      formFields = formElements.fields

      # Tсли объект с валидацями не пустой - продолжим.
      if !_.isEmpty(formFields)
         validationFunctions = {}

         for fieldName, params of formFields
            validationFunctions[fieldName] = params.validation.handler

         # Асинхронно выполним все функции валидации, и в
         # колбэке получим результат выполнения валидаций.
         async.parallel validationFunctions, (errors, result) ->
            isHasErrors = false

            # переберем все результаты валидации
            for key of result
               resultValidation = result[key]

               if result.hasOwnProperty key

                  # если есть какой-то результат - это ошибка
                  if resultValidation
                     isHasErrors = true
                     break

            # Если в полях нет ошибок (валидаторы полей не вернули ошибок),
            #  то получаем валидатор всей формы.
            unless isHasErrors
               totalValidator = dynamicForm._getTotalValidator()

               # Если для формы задан общий валидатор, то вызываем его с передачей
               #  контекста - текущего экземпляра.
               if totalValidator?
                  formElements =
                  totalValidatorResult = totalValidator.call(this, formElements)

                  # Если общий валидатор вернул какой-то результат - значит это
                  #  ошибки - добавим в результирующий хэш, установим флаг наличия
                  #  ошибок.
                  if totalValidatorResult? and !_.isEmpty totalValidatorResult
                     isHasErrors = true
                     result = totalValidatorResult

            # Если есть ошибки - сохраняем их в состоянии компонента
            #  иначе - запускаем отправку данных формы.
            if isHasErrors
               dynamicForm._saveValidationResult(result, formFields)
            else
               dynamicForm._submitFormData()
               dynamicForm._resetRefreshed()

   ###*
   * Функция проверки на наличие ошибок валидации. Если хэши текущего результата
   *  валидации и результатов, полученных из последней проверки.
   *
   * @param {Object} validationResult - хэш с результатами валидации.
   * @param {Object} formFields       - хэш парметров полей формы с валидациями.
   * @return
   ###
   _saveValidationResult: (validationResult, formFields) ->
      chars = @_CHARS
      aliases = @_ALIASES
      newLineChar = chars.newLine
      underscoreChar = chars.underscore
      spaceChar = chars.space
      colonChar = chars.colon

      mainRootSectionName = [
                               aliases.mainSection
                               aliases.rootNode
                            ].join chars.underscore
      flasherOutput = {}
      accordionSectionErrors = {}
      sectionsErrors = {}

      # Перебираем параметры ответа результатов валидации и считываем, только если
      #  были какие-то ошибки (результат валидации не пустой).
      # Для ошибочных результатов сохраняем хэш с параметрами вывода для списка
      #  сообщений и параметры с кол-вом ошибок по секциям аккордеона.
      for resName, res of validationResult
         if res?
            fieldParams = formFields[resName]

            if fieldParams?
               validationParam = fieldParams.validation
               reflectionParams = fieldParams.reflection
               validationCaption = validationParam.caption
               reflectionName = reflectionParams.name || mainRootSectionName
               parentsIdentifier = fieldParams.parentsIdentifier
               parentIdentifier =
                  if parentsIdentifier?
                     parentsIdentifier[parentsIdentifier.length - 1]

               flasherOutput[validationCaption] = res

               sectionErrors = if sectionsErrors[parentIdentifier]?
                                  sectionsErrors[parentIdentifier].errors
                               else
                                  []

               errorsString = [
                  validationCaption
                  spaceChar
                  colonChar
                  newLineChar
                  flasherOutput[validationCaption].join(newLineChar)
                  newLineChar
                  newLineChar
               ].join('')

               if sectionErrors?
                  sectionErrors.push(errorsString)
               else
                  sectionErrors = [errorsString]

               accordionSectionErrors[reflectionName] = sectionErrors
               sectionsErrors[parentIdentifier] =
                  errors: sectionErrors
                  parents: parentsIdentifier
            else
               resCustomCaption = res.caption || resName
               resCustomError = res.error or res

               flasherOutput[resCustomCaption] = resCustomError

      # Проверим на идентичность хэша результата валидации в состоянии компонента
      #  и аргумента, переданного в функцию.
      # Если хэши не равны - установим новое значение результата валидации в состояние
      #  а также флаг того, что форма готова к отправке.
      if JSON.stringify(@state.validationResult) isnt JSON.stringify(validationResult)
         @setState
            validationResult:
               flasherOutput: flasherOutput
               accordionSectionErrors: accordionSectionErrors
               sectionsErrors: sectionsErrors
            requestStatus: @_REQUEST_STATUSES.ready

   ###*
   * Функция добавления элемента в цепь связок. Функция используется в разных
   *  частях цепи связанных компонентов. Создает новый элемент-хэш в массиве
   *  с переданными параметрами.
   *
   *
   * @param {Array<Object>} chain  - цепь связок.
   * @param {Object} elementParams - новый элементы цепи.
   *     {String} reflection - имя связки.
   *     {String} caption - заголовок связки.
   *     {Boolean} isCollection - флаг множественной связки.
   *     {Number} index - номер экземпляр.
   * @return
   ###
   _addElementToChain: (chain, elementParams) ->
      chainLength = chain.length
      chain[chainLength] = elementParams

   ###*
   * Функция изменения индекса(номера экзмепляра) последнего узла в цепи связок.
   *  Функция используется для обновления цепи при генерации элементов управления
   *  сущностями в цикле по кол-ву заданных пользователем экземпляров (кнопки
   *  "Добавить", "Удалить").
   *
   * @param {Array<Object>}   - цепь связок.
   * @param {Number} newIndex - новый индекс последнего узла цепи.
   ###
   _changeLastNodeIndex: (chain, newIndex) ->
      chainLength = chain.length

      if chainLength
         lastIdx = chainLength - 1
         newLastNode = $.extend(true, {}, chain[lastIdx])
         newLastNode.index = newIndex
         chain[lastIdx] = newLastNode

### Компонент: содержимое динамической формы. Часть компонента DynamicForm.
*  В зависимости от того заданы ли параметры внешних сущностей строит
*  навигатор динамической формы (DynamicFormNavigator) или поля сущности
*  (DynamicFormFields). Имеется возможность строить множественные экземпляры
*  содержимого в зависимости от типа связки (@prosp.isSingle) для множественной связки.
*
*     {Object} fields           - набор полей.
*     {Object} externalEntities - набор внешних сущностей. Если передано undefined -
*                                 берем поля из @state.externalEntities. Если
*                                 передан false - ничего не берем.
*     {Array<Object>} chain     - массив параметров иерархии связки.
*     {String} ignoredFieldName - имя игнорируемого поля. Параметр нужен для скрытия
*                                 поля внешнего ключа при создании цепи внешней связки.
*     {Boolean} isSingle        - флаг одиночной связки. Этот флаг говорит о том,
*                                 что контент связан с родительской сущностью одиночной
*                                 связью. Если флаг = false значит связка множественная
*                                 и нужны компоненты контроля кол-ва экземляров.
*                                 По-умолчанию = true
*{Boolean} isExternalReflection - флаг того, что это содержимое внешней связки.
*     {Object} immutable - набор свойств, неизменяемых в цепи компонентов. Вид:
*
*           {Object} modelParams                - параметры модели
*           {Number} updateIdentifier           - идентификатор обновляемой записи.
*           {Object} dictionariesSelectedValues - значения, выбранные в словарях формы.
*           {String} mode                       - режим работы формы.
*           {Object} additionalValidationParams - дополнительные параметры валидации.
*           {Object} sectionsOrder              - параметры порядка следования
*                                                 секций в аккордеонах-навигаторах формы.
*           {Object} fieldsOrder                - параметры порядка следования полей
*                                                 в секциях аккордеонов-навигаторах формы.
*           {Object} denyToEditReflections      - параметры запрещенных для редактирования связок.
*           {Object} denyReflections            - параметры запрещенных связок.
*           {Object} fieldConstraints           - параметры ограничений полей.
*           {Object} sectionConstraints         - параметры ограничений секций.
*           {Object} externalEntitiesParams     - параметры для сущностей, связанных внешними
*                                                 связками.
*           {Object} reflectionControlParams    - параметры для всех сущностей-связок.
*           {Object} reflectionRenderParams     - параметры рендера для всех сущносей-связок.
*           {Object} implementationStore        - хранилище стандартных реализаций.
*           {Boolean} isUseImplementation       - флаг использования хралища реализаций.
*           {Boolean} isImplementationHigherPriority - флаг более приоритетных свойств из хранилища реализаций.
*                                                  Нужен для переопределения свойств, заданных по-умолчанию.
*           {Boolean} isMergeImplementation     - флаг "слияния" свойств компонента со свойствами, заданными в
*                                                 хранилище реализаций.
*           {Boolean} isAddAttributesSuffixForChain - флаг добалвения суффикса _attributes в имя
*                                                     родительской сущности для поля.
*           {Boolean} enableManageReflections   - флаг разрешения управления связанными записями в
*                                                 режиме обновления.
*           {Boolean} enableManuals             - флаг разрешения работы с руководствами.
*           {Object} validationResult           - параметры результата валидации полей.
*           {Object} polymorphicStates          - параметры состояний полиморфных связок.
*           {Object} aliases                    - константные параметры строк-псевдонимов,
*                                                 используемых в форме для различных элементов.
*           {Object} suffixes                   - константные параметры используемых суффиксов,
*                                                 используемых при генерации строк.
*           {Object} chars                      - константные параметры используемых символов для
*                                                 генерации строк.
*           {Object} prefixes                   - константные параметры строк-суффиксов для
*                                                 различных элементов формы, испольуемые для
*                                                 формирования ссылок (TODO: скорее всего убрать).
*           {Object} tipTypes                   - константные парметры для кнопок-подсказок.
*           {Object} idFieldAlias               - псевдоним ключевого поля.
*           {Object} metaButtonParams           - параметры для кнопок отображения метаданных.
*           {Boolean} isRefreshed               - флаг того, что формы была сброшена.
*           {Boolean} isInUpdateMode            - флаг того, что форма находится в
*                                                 режиме "обновления".
*           {Function} onClickOpenManual        - обработчик клика на кнопку открытия руководства
*           {Function} getElementsSplitter      - функция получения разделителя элементов
*                                                 (горизонтальная линия). Возврат:
*                                                 {React-Element} splitter - элемент разделителя.
*           {Function} getInstanceControls      - функция получения кнопок управления экземплярами.
*                                                 Возврат:
*                                                 {React-Element} controls - элементы кнопок.
*           {Function} getPrimaryKeyFromFields  - функция получения параметров первичного ключа
*                                                 из набора полей. Возврат:
*                                                 {Object} - параметры поля первичного ключа.
*           {Function} getFormField             - функция получения поля формы. Возврат:
*                                                 {React-Element} formField - поле формы.
*           {Function} addElementToChain        - функция добавления элемента в цепь связок. Ожидаемые
*                                                 аргументы:
*                                                 {Array} chain - цепь (выходной параметр).
*                                                 {Object} item - параметры нового элемента.
*           {Function} changeLastNodeIndex      - функция иземениия индекса последнего элемента в цепи
*                                                 сязок (используется в циклах по кол-ву заданных
*                                                 экземпляров). Ожидаемые аргументы:
*                                                 {Array} chain     - цепь (выходной параметр).
*                                                 {Object} newIndex - новый индекс последнего элемента.
*           {Function} onChangeField            - обработчик на изменение значения в поле. Аргументы:
*                                                 {Object, String, Number} value - значение поля.
*                                                 {Object} field                 - параметры поля.
*                                                 {Object} fieldName             - имя поля.
*           {Function} onClearField             - обработчик на сброс значения в поле. Аргументы:
*                                                 {Object} field                 - параметры поля.
*                                                 {Object} fieldName             - имя поля.
*           {Function} onInitField              - обработчик на инициализацию поля (событие перед
*                                                 монтированием компонента). Агрументы:
*                                                 {React-Element} input - экземпляр поля.
*           {Function} onClickEditReflection    - обработчик клика на кнопку редактирования экземпляров
*                                                 связанных сущностей (открывает диалог редактирования).
*                                                 Аргументы:
*                                                 {Object} value - параметры, необходимые для редактирования.
*           {Function} onDestroyField           - обработчик на уничтожение поля (событие перед
*                                                 размонтированием). Аргументы:
*                                                 {React-Element} input - экземпляр поля.
*           {Function} onInitAccordion          - обработчик на инициализацию аккордеона-навигатора.
*                                                 (событие перед монтированием компонента). Аргументы:
*                                                 {React-Element} accordion - экземпляр аккордеона.
*           {Function} onDestroyAccordion       - обработчика на уничтожения аккордеона-навигатора.
*                                                 (событие перед размонтированием компонента). Аргументы:
*                                                 {React-Element} accordion - экземпляр аккордеона.
* @state
*     {Number} instancesCount - кол-во экземляров содержимого формы. Начальное значение = 1.
###
DynamicFormContent = React.createClass

  # mixins: [PureRenderMixin]

   getDefaultProps: ->
      isSingle: true
      chain: []

   getInitialState: ->
      instancesCount: 1

   shouldComponentUpdate: (nextProps, nextState) ->
      isShouldUpdateNext = nextProps.isShouldUpdate

      if isShouldUpdateNext?
         isShouldUpdateNext
      else
         true


   render: ->
      `(
         <div>
            {this._getContent()}
            {this._getSplitter()}
            {this._getControls()}
         </div>
      )`

   ###*
   * Функция получения содержимого формы. Создает заданное кол-во
   *  экземпляров формы.
   *
   * @return {Array<React-Element>} - коллекция элементов формы.
   ###
   _getContent: ->
      instancesCount = @state.instancesCount
      getSplitter = @props.immutable.getElementsSplitter
      chain = @props.chain
      contentElements = []

      for instanceNumber in [1..instancesCount]

         if instanceNumber > 1
            contentElements.push getSplitter(instanceNumber)

         contentElements.push @_getElements(chain[..], instanceNumber)

      contentElements

   ###
   * Функция получения содержимого динамической формы - поля и внешние сущности.
   *
   * @param {Array} chain           - цепь связок.
   * @param {Number} instanceNumber - номер экземпляра
   * @return {React-Element}
   ###
   _getElements: (chain, instanceNumber) ->
      fields = @props.fields
      isSingle = @props.isSingle
      isExternalReflection = @props.isExternalReflection
      reflectionParams = @props.reflectionParams
      externalEntities = @props.externalEntities
      immutableProps = @props.immutable
      changeLastNodeIndex = immutableProps.changeLastNodeIndex
      changeLastNodeIndex(chain, instanceNumber)

      mainFormFields =
         `(
             <DynamicFormFields key={instanceNumber}
                                instanceNumber={instanceNumber}
                                immutable={immutableProps}
                                isExternalReflection={isExternalReflection}
                                fields={fields}
                                chain={chain}
                                ignoredFieldName={this.props.ignoredFieldName}
                              />
          )`


      # Если есть внешние связанные сущности - для гененируем аккордион с разделами.
      #  Иначе выдаем просто плоскую форму.
      if @_isHasExternalEntities()
         `(
            <DynamicFormNavigator key={instanceNumber}
                                  immutable={immutableProps}
                                  fields={fields}
                                  isSingle={isSingle}
                                  isExternalReflection={isExternalReflection}
                                  mainFormFields={mainFormFields}
                                  externalEntities={externalEntities}
                                  chain={chain}
                               />
          )`

      else
         mainFormFields

   ###*
   * Функция получения разделителя элементов.
   *
   * @return {React-Element} - компонент с кнопками управления.
   ###
   _getSplitter: ->
      unless @props.isSingle
         @props.immutable.getElementsSplitter()

   ###*
   * Функция получения кнопок управления кол-вом экземпляров элементов.
   *
   * @return {React-Element} - компонент с кнопками управления.
   ###
   _getControls: ->
      instancesCount = @state.instancesCount

      unless @props.isSingle
         @props.immutable.getInstanceControls(@_onClickControlInstance,
                                              instancesCount)

   ###*
   * Обработчик клика на кнопку управления кол-вом экземпляров.
   *
   * @param {Boolean} isDecrement - флаг того, что это декремент.
   * @return
   ###
   _onClickControlInstance: (isDecrement) ->
      instancesCount = @state.instancesCount

      if isDecrement
         instancesCount-- if instancesCount > 1
      else
         instancesCount++

      @setState instancesCount: instancesCount


   ###*
   * Функция-предикат для определения наличия внешних связок в параметрах компонента.
   *
   * @return {Boolean}
   ###
   _isHasExternalEntities: ->
      externalEntities = @props.externalEntities
      externalEntities? and !_.isEmpty externalEntities

###* Компонент - Навигатор динамической формы ввода. Компонент предназначен для организации
*                внешних сущностей по секциям аккордеона.
*
* @props
*     {Object} fields                  - набор полей.
*     {React-Elements} mainFormFields  - набор полей для заполнения основных данных сущности.
*     {Object} externalEntities        - набор внешних сущностей.
*     {Array<Object>} chain            - массив параметров иерархии связки.
*     {Boolean} isSingle               - флаг одиночного отношения к родительской сущности.
*     {Boolean} isExternalReflection   - флаг того, что это содержимое внешней связки.
*     {Object} immutable - набор свойств, неизменяемых в цепи компонентов. Вид:
*
*           {Object} modelParams                - параметры модели
*           {Number} updateIdentifier           - идентификатор обновляемой записи.
*           {Object} dictionariesSelectedValues - значения, выбранные в словарях формы.
*           {String} mode                       - режим работы формы.
*           {Object} additionalValidationParams - дополнительные параметры валидации.
*           {Object} sectionsOrder              - параметры порядка следования
*                                                 секций в аккордеонах-навигаторах формы.
*           {Object} fieldsOrder                - параметры порядка следования полей
*                                                 в секциях аккордеонов-навигаторах формы.
*           {Object} fieldConstraints           - параметры ограничений полей.
*           {Object} sectionConstraints         - параметры ограничений секций.
*           {Object} denyToEditReflections      - параметры запрещенных для редактирования связок.
*           {Object} denyReflections            - параметры запрещенных связок.
*           {Object} externalEntitiesParams     - параметры для сущностей, связанных внешними
*                                                 связками.
*           {Object} reflectionControlParams    - параметры для всех сущностей-связок.
*           {Object} reflectionRenderParams     - параметры рендера для всех сущносей-связок.
*           {Object} implementationStore        - хранилище стандартных реализаций.
*           {Boolean} isUseImplementation       - флаг использования хралища реализаций.
*           {Boolean} isImplementationHigherPriority - флаг более приоритетных свойств из хранилища реализаций.
*                                                  Нужен для переопределения свойств, заданных по-умолчанию.
*           {Boolean} isMergeImplementation     - флаг "слияния" свойств компонента со свойствами, заданными в
*                                                 хранилище реализаций.
*           {Boolean} isAddAttributesSuffixForChain - флаг добалвения суффикса _attributes в имя
*                                                     родительской сущности для поля.
*           {Boolean} enableManageReflections   - флаг разрешения управления связанными записями в
*                                                 режиме обновления.
*           {Boolean} enableManuals             - флаг разрешения работы с руководствами.
*           {Object} validationResult           - параметры результата валидации полей.
*           {Object} polymorphicStates          - параметры состояний полиморфных связок.
*           {Object} aliases                    - константные параметры строк-псевдонимов,
*                                                 используемых в форме для различных элементов.
*           {Object} suffixes                   - константные параметры используемых суффиксов,
*                                                 используемых при генерации строк.
*           {Object} chars                      - константные параметры используемых символов для
*                                                 генерации строк.
*           {Object} prefixes                   - константные параметры строк-суффиксов для
*                                                 различных элементов формы, испольуемые для
*                                                 формирования ссылок (TODO: скорее всего убрать).
*           {Object} tipTypes                   - константные парметры для кнопок-подсказок.
*           {Object} idFieldAlias               - псевдоним ключевого поля.
*           {Object} metaButtonParams           - параметры для кнопок отображения метаданных.
*           {Boolean} isRefreshed               - флаг того, что формы была сброшена.
*           {Boolean} isInUpdateMode            - флаг того, что форма находится в
*                                                 режиме "обновления".
*           {Function} getElementsSplitter      - функция получения разделителя элементов
*                                                 (горизонтальная линия). Возврат:
*                                                 {React-Element} splitter - элемент разделителя.
*           {Function} getInstanceControls      - функция получения кнопок управления экземплярами.
*                                                 Возврат:
*                                                 {React-Element} controls - элементы кнопок.
*           {Function} getPrimaryKeyFromFields  - функция получения параметров первичного ключа
*                                                 из набора полей. Возврат:
*                                                 {Object} - параметры поля первичного ключа.
*           {Function} getFormField             - функция получения поля формы. Возврат:
*                                                 {React-Element} formField - поле формы.
*           {Function} addElementToChain        - функция добавления элемента в цепь связок. Ожидаемые
*                                                 аргументы:
*                                                 {Array} chain - цепь (выходной параметр).
*                                                 {Object} item - параметры нового элемента.
*           {Function} changeLastNodeIndex      - функция иземениия индекса последнего элемента в цепи
*                                                 сязок (используется в циклах по кол-ву заданных
*                                                 экземпляров). Ожидаемые аргументы:
*                                                 {Array} chain     - цепь (выходной параметр).
*                                                 {Object} newIndex - новый индекс последнего элемента.
*           {Function} onClickOpenManual        - обработчик клика на кнопку открытия руководства
*           {Function} onChangeField            - обработчик на изменение значения в поле. Аргументы:
*                                                 {Object, String, Number} value - значение поля.
*                                                 {Object} field                 - параметры поля.
*                                                 {Object} fieldName             - имя поля.
*           {Function} onClearField             - обработчик на сброс значения в поле. Аргументы:
*                                                 {Object} field                 - параметры поля.
*                                                 {Object} fieldName             - имя поля.
*           {Function} onInitField              - обработчик на инициализацию поля (событие перед
*                                                 монтированием компонента). Агрументы:
*                                                 {React-Element} input - экземпляр поля.
*           {Function} onClickEditReflection    - обработчик клика на кнопку редактирования экземпляров
*                                                 связанных сущностей (открывает диалог редактирования).
*                                                 Аргументы:
*                                                 {Object} value - параметры, необходимые для редактирования.
*           {Function} onDestroyField           - обработчик на уничтожение поля (событие перед
*                                                 размонтированием). Аргументы:
*                                                 {React-Element} input - экземпляр поля.
*           {Function} onInitAccordion          - обработчик на инициализацию аккордеона-навигатора.
*                                                 (событие перед монтированием компонента). Аргументы:
*                                                 {React-Element} accordion - экземпляр аккордеона.
*           {Function} onDestroyAccordion       - обработчика на уничтожения аккордеона-навигатора.
*                                                 (событие перед размонтированием компонента). Аргументы:
*                                                 {React-Element} accordion - экземпляр аккордеона.
###
DynamicFormNavigator = React.createClass

   # @const {String} - заголовок для элемента аккордиона с основными данными таблицы
   #                   (если присутствуют внешние сущности.)
   _MAIN_FIELDS_HEADER: 'Основные данные'

   # @const {String} - префикс информационной подсказки для главного раздела
   #                   аккордеона сущности.
   _MAIN_SECTION_INFO_PARAMS:
      basis: 'Раздел основных данных '
      forSection: 'секции '

   # @const {Object} - параметры режима "навигатора" для главного аккордеона.
   _ROOT_NAVIGATOR_MOD_PARAMS:
      position: 'left'

   # @const {Object} - парметры для комбинированного режима работы с данными сущности.
   _COMBINE_MODE_PARAMS:
      select:
         label:
            single: 'Выбор существующей записи'
            many: 'Выбор существующих записей'
      new:
         label:
            single: 'Создание записи'
            many: 'Создание записей'

   # @const {Object} - параметры счетчика ошибок секции аккордеона.
   _ACCORDION_COUNTER_PARAMS:
      type: 'error'
      titlePrefix: 'Раздел содержит ошибки. Кол-во полей с ошибками: '
      inSectionsErrorTitle: 'В подразделах содержатся ошибки'

   # @const {Object} - хэш возможных видов связок.
   _REFLECTION_TYPES: keyMirror(
      dictionary: null,
      new: null,
      combine: null
   )

   # @const {Object} - предварительные параметры для кнопки редактирования
   #                   связанных записей.
   _EDIT_BUTTON_SCAFFOLD:
      icon: 'edit'
      title: 'Открыть диалог редактирования связанных записей.'
      isResetDefaultHeight: true
      isWithoutPadding: true
      isLink: true

   # @const {Object} - предварительные параметры для кнопки открытия
   #                   руководства по разделу.
   _MANUAL_BUTTON_SCAFFOLD:
      icon: 'book'
      title: 'Открыть руководство по разделу'
      isResetDefaultHeight: true
      isWithoutPadding: true
      isLink: true

   # @const {Object} - наименование свойств ограничений.
   _DENY_CONSTRAINT_NAMES:
      toEdit: 'denyToEditReflections'
      toConstruct: 'denyReflections'

   # @const {String} - ключ для считывания параметров цепи связок для
   #                   разрешенных для редактирования.
   _CHAIN_KEY: 'chain'

   mixins: [HelpersMixin]

   styles:
      dictionaryWrapper:
         padding: _COMMON_PADDING
         paddingBottom: 0
         width: '100%'
      externalEntityFieldsContainer:
         overflow: 'auto'
         maxHeight: 600
      externalEntityContainer:
         marginBottom: _COMMON_PADDING
         textAlign: 'left'
      externalToExternalContainer:
         textAlign: 'right'
         padding: _COMMON_PADDING
         marginTop: -2
         marginBottom: 2
      functionalButton:
         fontSize: 20

   render: ->
      immutable = @props.immutable
      params = @_getAccordionParams()
      items = params.items


      if items.length > 1
         `(
            <Accordion items={params.items}
                       name={params.name}
                       identifier={params.identifier}
                       navigatorModParams={params.navigatorModParams}
                       enableDeactivate={params.enableDeactivate}
                       onSectionOpened={this._onAccordionSectionOpened}
                       onInit={immutable.onInitAccordion}
                       onDestroy={immutable.onDestroyAccordion}
                     />
         )`
      else unless _.isEmpty(items)
         _.head(items).content

   ###*
   * Функция получения параметров для аккордиона-навигатора формы.
   *
   * @return {Object} - аккордеон с секциями. Вид:
   *     {Array} items                          - секции.
   *     {String} name                          - имя.
   *     {Number} identifier                    - идентификатор.
   *     {Object, undefined} navigatorModParams - параметры режима навигатора.
   *     {Boolean} enableDeactivate             - флаг возможности закрытия секций.
   ###
   _getAccordionParams: ->
      fields = @props.fields
      isHasFields = fields? and !_.isEmpty fields
      mainFormFields = @props.mainFormFields
      chain = @props.chain
      reflectionParams = chain[chain.length - 1]
      immutable = @props.immutable
      aliases = immutable.aliases
      mainSectionAlias = aliases.mainSection
      rootNodeAlias = aliases.rootNode
      chars = immutable.chars
      sectionOrder = @_getSectionOrder reflectionName
      accordionSections = []
      accordionSectionsCollection = {}

      # Если аккордеон создается для связки - считаем имя и заголовок связки.
      if reflectionParams?
         reflectionName = reflectionParams.reflection
         reflectionCaption = reflectionParams.caption
      else
         reflectionName = rootNodeAlias

      isRootDynamicFormNavigator = reflectionName is rootNodeAlias
      accordionIdentifiers = @_getAccordionIdentifiers()
      accordionIdentifier = accordionIdentifiers.accordion
      firstSectionIdentifier = accordionIdentifiers.firstSection
      firstSectionInfo = @_getAccordionSectionInfo reflectionCaption

      ###*
      * Функция установки для переданной секции состояния раскрытости (если ранее
      *  не было раскрыто секций).
      *
      * @param {Boolean} isHasExpanded - флаг была ли ранее раскрыта какая-либо секция.
      * @param {Object} section - параметры секции.
      * @return {Boolean}
      ###
      setSectionExpanded = (isHasExpanded, section) ->
         unless isHasExpanded
            if section? and _.isPlainObject section
               section.isOpened = true
               isHasExpanded = true

         isHasExpanded

      # Если заданы поля - добавляем главную секцию с полями.
      if isHasFields
         # Формируем хэш с параметрами секций для аккордиона. Сначала секция
         #  основных параметров, затем будем добавлять секции внешних сущностей.
         accordionSectionsCollection[mainSectionAlias] =
            header: @_MAIN_FIELDS_HEADER
            content: mainFormFields
            name: mainSectionAlias
            identifier: firstSectionIdentifier
            counter: @_getSectionCounter(firstSectionIdentifier)

      # Заполним параметры секций аккордеона.
      @_fillAccordionSections(accordionSectionsCollection, reflectionParams)

      isHasExpanded = false
      # Если для данной секции задан порядок следования секций - переберем эти
      #  сущности и вставим их в начало массива секций аккордиона.
      if sectionOrder?

         for orderedSectionName in sectionOrder
            orderedSection = accordionSectionsCollection[orderedSectionName]
            isHasExpanded = setSectionExpanded(isHasExpanded, orderedSection)

            if orderedSection?
               accordionSections.push orderedSection
               delete accordionSectionsCollection[orderedSectionName]

      # Перебираем оставшиеся неупорядоченные секции аккордиона.
      for _sectionName, section of accordionSectionsCollection
         isHasExpanded = setSectionExpanded(isHasExpanded, section)
         accordionSections.push section

      # Если это корневой навигатор, то для него зададим особые параметры.
      if isRootDynamicFormNavigator
         navigatorModParams = @_ROOT_NAVIGATOR_MOD_PARAMS
         enableDeactivate = false

      items: accordionSections
      name: reflectionName
      identifier: accordionIdentifier
      navigatorModParams: navigatorModParams
      enableDeactivate: enableDeactivate

   ###*
   * Функция генерирования содержимого для создания секции аккордеона с содержимым
   *  сущности.
   *
   * @param {Object} params  - хэш параметров для создания аккордеона. Вид:
   *        {String} sectionIdentifier               - идентификатор секции.
   *        {Object} entity                          - параметры сущности.
   *        {Object} reflectionParams                - параметры связки.
   *        {String} ignoredFieldName                - имя игнорируемого поля.
   *        {Array<Object>} chain                    - массив параметров иерархии связки.
   *        {Boolean} isNew                          - флаг полей нового экземпляра.
   *        {Boolean} isDictionary                   - флаг сущности-словаря(только выбор).
   *        {Boolean} isCombine                      - флаг комбинированной сущности(словарь+поля) TODO: пока не реализовано.
   *       {Boolean} isHasDictionaryRequestingParams - флаг наличия параметров запроса словаря.
   *        {Boolean} isEntitySingle                 - флаг одиночной связки.
   *        {Boolean} isMultiSelectDictionary        - флаг словаря множественного выбора.
   *        {Boolean} isHasAllowedExternalToExternal - флаг наличия разрешенных внешних
   *                                                   для внешних связок.
   * @return {React-Element}
   ###
   _getAccordionSection: (params) ->
      immutable = @props.immutable
      elementRefPrefixes = immutable.prefixes
      sectionIdentifier = params.sectionIdentifier
      entity = params.entity
      reflectionParams = params.reflectionParams
      entityFields = params.entityFields
      ignoredFieldName = params.ignoredFieldName
      isNew = params.isNew
      isDictionary = params.isDictionary
      isCombine = params.isCombine
      isHasDictionaryRequestingParams = params.isHasDictionaryRequestingParams
      isEntitySingle = params.isEntitySingle
      isMultiSelectDictionary = params.isMultiSelectDictionary
      isHasAllowedExternalToExternal = params.isHasAllowedExternalToExternal
      recordKeys = params.recordKeys
      chain = params.chain
      dynamicFormNavigator = this

      ###*
      * Функция получения доп. параметров для "комбинированного" режима.
      *
      * @param {Boolean} isSingle  - флаг одиночной связи.
      * @param {Boolean} isMultiDictionary - флаг словаря с множественным выбором.
      * @return {Object}:
      *     {String} selectorLabel - лейбл для селектора(ов).
      *     {String} newLable      - лейбл для полей.
      ###
      getAdditionCombineElements = ((isSingle, isMultiDictionary) ->
         combineModeParams = @_COMBINE_MODE_PARAMS
         selectorLabelParams = combineModeParams.select.label
         newLabelParams = combineModeParams.new.label

         selectorLabel =
            if isSingle and !isMultiDictionary
               selectorLabelParams.single
            else
               selectorLabelParams.many

         newLabel =
            if isSingle
               newLabelParams.single
            else
               newLabelParams.many

         selectorLabel: selectorLabel
         newLabel: newLabel
      ).bind(dynamicFormNavigator)

      ###*
      * Функция помещения элемента  в контейнер с элементами управления.
      *
      * @param {React-Element} element - элемент, помещаемый в контейнер.
      * @param {String} caption        - выводимый заголовок.
      * @param {String} identifier     - идентификатор секции.
      * @param {Boolean} isShown       - флаг того, что секция показана.
      * @return  {React-Element}
      ###
      placeInContainer = ((element, caption, identifier, isShown) ->
         key = @crc32FromString(caption + identifier)

         `(
             <StreamContainer key={key}
                              content={element}
                              triggerParams={
                                 {
                                    hidden: {
                                       caption: caption
                                    }
                                 }
                              }
                              isShown={isShown}
                              isMirrorClarification={true}
                           />
          )`
      ).bind(dynamicFormNavigator)

      # Если для внешней сущности задан режим "словаря" или "комбинированный"
      #  режим и при этом есть параметры словаря, то создаем селектор сущностей
      #  для внешней сущности.
      if (isDictionary or isCombine) and isHasDictionaryRequestingParams

         instancesSelector =
            @_getExternalEntitySelectors(
               entity: entity
               chain: chain
            )

      # Если для внешней сущности задан режим "нового экземпляра" или
      #  "комбинированный" режим, то создаем поля для создания нового(новых)
      #  экземпляра(ов).
      if isNew or isCombine
         paramsForFormFields =
            fields: entityFields
            ignoredFieldName: ignoredFieldName
            isSingle: isEntitySingle
            # isCombine: isCombine
            recordKeys: recordKeys
            chain: chain

         entityFormFields = @_getFormContent(paramsForFormFields)

      isSetBothParts = instancesSelector? and entityFormFields?

      # Если сформированы элементы для обоих способов ввода данных (комбинированный
      #  режим), то выполняем дополнительную обработку.
      if isSetBothParts
         # Если сформированы поля экземпялра и селектор экземпляра(ов), то
         #  сформируем дополнительные элементы для разделения различных
         #  способов работы с полями (комбинированный режим).
         additionCombineElements =
            getAdditionCombineElements(isEntitySingle, isMultiSelectDictionary)
         selectorLabel = additionCombineElements.selectorLabel
         newLabel = additionCombineElements.newLabel
         isInUpdateMode = immutable.isInUpdateMode
         isFieldsShown = !isInUpdateMode

         instancesSelector = placeInContainer(instancesSelector,
                                              selectorLabel,
                                              sectionIdentifier,
                                              isInUpdateMode)
         entityFormFields = placeInContainer(entityFormFields,
                                             newLabel,
                                             sectionIdentifier,
                                             isFieldsShown)

         modeSplitter = immutable.getElementsSplitter()

      `(
         <div style={this.styles.externalEntityContainer}>
            {instancesSelector}
            {modeSplitter}
            {entityFormFields}
         </div>
       )`

   ###*
   * Функция получения селектора внешней сущности.
   *
   * @param {Object} params - хэш параметров для селектора.
   *        {Object} entity         - параметры внешней сущнсти.
   *        {String} reflectionParams - параметры внешней сущности (имя, заголовок, родительски связки).
   *        {Array<Object>} chain     - массив параметров иерархии связки.
   * @return {Array<React-DOM-Node>, React-DOM-Node} - набор селекторов/ селектор внешней сущности.
   ###
   _getExternalEntitySelectors: (params) ->
      entity = params.entity
      entityName = entity.reflectionName
      immutable = @props.immutable
      getFormField = immutable.getFormField
      chain = params.chain
      dynamicFormNavigator = this

      ###*
      * Функция оборачивания селектора в контейнер содержащий форматирование.
      *
      * @param {React-DOM-Node} selector - компонент селектора.
      * @return {React-DOM-Node}
      ###
      wrapSelector = ((selector, name) ->
         `(
            <table style={this.styles.dictionaryWrapper}
                   key={name}>
               <tbody>
                 {selector}
               </tbody>
            </table>
         )`
      ).bind(dynamicFormNavigator)

      params =
         field: entity
         chain: chain

      selector = getFormField(params, null, immutable)

      wrapSelector(selector, entityName)

   ###*
   * Функция получения содержимого внешней cущности. Функция применяется для получения
   *  элементов для манипуляции разрешенной внешней связанной сущностью. Создает
   *  элемент контента динамической формы, запуская рекурсивноую связанность компонентов.
   *
   * @param {Object} params     - параметры для содержимого (свойства
   *                              элемента DynamicFormContent).
   * @param {String} identifier - идентификатор содержимого.
   * @return {React-Element}
   ###
   _getFormContent: (params, identifier) ->
      clonedProps = _.cloneDeep(params)

      `(
          <DynamicFormContent {...clonedProps}
                              key={identifier}
                              isExternalReflection={true}
                              immutable={this.props.immutable}
                           />
       )`

   ###*
   * Функция получения разрешенных внешнех связок для текущей внешней сущности.
   *
   * @param {String} entityName - имя внешней сущности.
   * @param {Object} entity -  хэш параметров внешней связки.
   * @return {Object, undefined} - параметры внешней связки.
   ###
   _getAllowedExternalForEntity: (entityName, entity) ->
      externalEntities = entity.externalEntities
      externalEntitiesParams = @props.immutable.externalEntitiesParams
      isHasExternalEntitisParams =
         externalEntitiesParams? and !_.isEmpty externalEntitiesParams
      isAllowAllExternalToExternal =
         isHasExternalEntitisParams and
         externalEntitiesParams.isAllowAllExternalToExternal
      allowedExternalEntities = {}

      if isAllowAllExternalToExternal
         allowedExternalEntities = externalEntities
      else if isHasExternalEntitisParams
         allowExternalToExternal = externalEntitiesParams.allowExternalToExternal
         isHasAllowedExternalToExternal = allowExternalToExternal? and
                                          !_.isEmpty allowExternalToExternal

         if isHasAllowedExternalToExternal
            allowedEntities = allowExternalToExternal[entityName]
            isHasAllowedEntities = allowedEntities? and
                                   externalEntities? and
                                   !_.isEmpty externalEntities

            if isHasAllowedEntities

               # В зависимости от того в каком виде заданы разрешенные внешние
               #  сущности, по разному обрабатываем значения.
               if _.isArray allowedEntities
                  for allowedEntityName in allowedEntities
                     if _.has(externalEntities, allowedEntityName)
                        allowedExternalEntities[allowedEntityName] =
                           externalEntities[allowedEntityName]
               else
                  allowedExternalEntities[allowedEntities] =
                     externalEntities[allowedEntities]

      if allowedExternalEntities? and !_.isEmpty allowedExternalEntities
         allowedExternalEntities

   ###*
   * Функция получения идентификатора секции в зависимости от переданных параметров.
   *
   * @param {String} reflectionName - имя связки по которой создается секция.
   ###
   _getSectionIdentifier: (reflectionName) ->
      chars = @props.immutable.chars
      sequenseString =
         [
            @_getChainSequenseString()
            reflectionName
         ].join chars.empty

      @crc32FromString sequenseString

   ###*
   * Функция получения склееной строки последовательности свзок, для дальнейшего
   *  подсчета хэша для идентификатора.
   *
   * @return {String}
   ###
   _getChainSequenseString: ->
      chain = @props.chain
      chars = @props.immutable.chars
      emptyChar = chars.empty
      chainString = emptyChar

      for node in chain
         chainString +=
            [
               node.index
               node.reflection
            ].join emptyChar

      chainString

   ###*
   * Функция получения идентификаторов для аккордеона и его первой
   *  секции (основных параметров).
   *
   * @return {Object} - Идентификаторы для аккордеона. Вид:
   *        {String} accordion - хэш для аккордеона.
   *        {String} firstSection - хэш для перой секции.
   ###
   _getAccordionIdentifiers: ->
      immutable = @props.immutable
      chars = immutable.chars
      emptyChar = chars.empty
      mainSectionName = immutable.aliases.mainSection
      accordionString = @_getChainSequenseString()

      firstSectionString =
         [
            accordionString
            mainSectionName
         ].join emptyChar

      accordion: @crc32FromString accordionString
      firstSection: @crc32FromString firstSectionString

   ###*
   * Функция получения порядка следования секций в содержимом, содержащие
   *  внешние сущности из заданных параметров.
   *
   * @param {String, undefined} reflectionName - имя связки.
   * @return {Array<String>, undefined} - порядок следования секций.
   ###
   _getSectionOrder: (reflectionName) ->
      immutable = @props.immutable
      sectionsOrder = immutable.sectionsOrder
      rootNodeAlias = immutable.aliases.rootNode

      if sectionsOrder?
         if reflectionName?
            sectionsOrder[reflectionName]
         else
            sectionsOrder[rootNodeAlias]

   ###*
   * Функция получения параметров счетчика секции аккордеона для отображения ошибок
   *  валидации полей, находящихся в секции. Находит возможное кол-во ошибок
   *  после валидации по названию секции.
   *
   * @param {String} sectionIdentifier - идентификатор секции.
   * @return {Object, undefined} - параметры счетчика секции.
   ###
   _getSectionCounter: (sectionIdentifier) ->
      validationResult = @props.immutable.validationResult
      chars = @props.immutable.chars

      if validationResult? and !$.isEmptyObject validationResult
         sectionsErrorsParams = validationResult.sectionsErrors

         if sectionsErrorsParams? and !$.isEmptyObject sectionsErrorsParams
            counterParams = @_ACCORDION_COUNTER_PARAMS
            titlePrefix = counterParams.titlePrefix
            inSectionsErrorTitle = counterParams.inSectionsErrorTitle
            sectionErrorsParams = sectionsErrorsParams[sectionIdentifier]
            countErrorsInFields = 0
            countErrorsInSections = 0
            errorsTotalCount = 0
            errorsTitleElements = []

            # Если секция содержит ошибки - определим их кол-во и сформируем
            #  выводимый заголовок на ошибках.
            if sectionErrorsParams?
               sectionErrors = sectionErrorsParams.errors
               countErrorsInFields = sectionErrors.length
               errorsTitleElements =
                  errorsTitleElements.concat([
                        titlePrefix
                        countErrorsInFields
                        chars.newLine
                        chars.newLine
                        sectionErrors.join('')
                     ]
                  )

            # Ищем ошибки в дочерних секциях.
            for sectionIdx, errorParams of sectionsErrorsParams
               errors = errorParams.errors
               sectionParents = errorParams.parents

               if sectionParents? and sectionParents.length > 1
                  parentWithoutLast =
                     sectionParents.slice(0, sectionParents.length - 1)

                  if ~parentWithoutLast.indexOf sectionIdentifier
                     countErrorsInSections += errors.length
                     lastErrorTitleElement = errorsTitleElements[errorsTitleElements.length - 1]

                     if lastErrorTitleElement isnt inSectionsErrorTitle
                        errorsTitleElements =
                           errorsTitleElements.concat([
                                 inSectionsErrorTitle
                              ]
                           )

            errorsTotalCount += countErrorsInFields if countErrorsInFields?
            errorsTotalCount += countErrorsInSections if countErrorsInSections?

            if countErrorsInFields or countErrorsInSections
               type: counterParams.type
               count: errorsTotalCount
               title: errorsTitleElements.join('')

   ###*
   * Функция конструирования текста вспомогательной информации по резделу аккордеона.
   *
   * @param {String} reflectionCaption - заголовок секции.
   * @return {String}
   ###
   _getAccordionSectionInfo: (reflectionCaption) ->
      chars = @props.immutable.chars
      quoteChar = chars.quote
      emptyChar = chars.empty
      mainSectionInfoParams = @_MAIN_SECTION_INFO_PARAMS
      sectionInfoBasis = mainSectionInfoParams.basis
      sectionInfoAddition = mainSectionInfoParams.forSection

      if reflectionCaption?
         [
            sectionInfoBasis
            sectionInfoAddition
            quoteChar
            reflectionCaption
            quoteChar
         ].join emptyChar
      else
         sectionInfoBasis

   ###*
   * Функция-предикат для проверки наличия параметров для запроса справочника
   *  поля.
   *
   * @param {Object} reflection - параметры связки.
   * @return {Boolean} - флаг наличия параметров.
   ###
   _isHasDictionaryRequestingParams: (reflection) ->
      dictionaryReflection = undefined
      isHasRequestingParams = false

      if reflection? and !_.isEmpty(reflection)
         dictionaryReflection = reflection.dictionary

      if dictionaryReflection? and !_.isEmpty dictionaryReflection
         isHasRequestingParams =
            dictionaryReflection.requestingParams? and
            !_.isEmpty(dictionaryReflection.requestingParams)

      isHasRequestingParams

   ###*
   * Функция-предикат для проверки запрета связки по определенному ограничению
   *  (ограничение на формирование, на редактирование).
   *
   * @param {String} reflectionName - имя связки.
   * @param {String} constraintName - наименование ограничения по которой проверяется
   *                                  запрет.
   * @return {Boolean}
   ###
   _isDenyByConstraint: (reflectionName, constraintName) ->
      immutable = @props.immutable
      isDeny = false
      denyReflections = immutable[constraintName]

      ###*
      * Функция для получения имен родительских связок из параметров цепи.
      *
      * @param {Array<Object>} chain - набор элементов цепи родительских связок.
      * @return {Array<String>, undefined}
      ###
      getChainReflectionNames = (chain) ->
         if chain? and !_.isEmpty chain
            chain.map (element) ->
               element.reflection

      if denyReflections? and !_.isEmpty denyReflections
         isHasReflectionToDeny = _.has(denyReflections, reflectionName)

         if isHasReflectionToDeny
            denyReflectionParams = denyReflections[reflectionName]

            if denyReflectionParams? and !_.isEmpty denyReflectionParams
               isAnywhereDeny = denyReflectionParams.isAnywhere

               isDeny =
                  if isAnywhereDeny
                     true
                  else
                     chainKey = @_CHAIN_KEY
                     isHasChainProp = _.has(denyReflectionParams, chainKey)

                     if isHasChainProp
                        denyReflectionChainParents = denyReflectionParams[chainKey]
                        chainParents = getChainReflectionNames(@props.chain)

                        _.isEqual(denyReflectionChainParents, chainParents)
                     else
                        false
      isDeny

   ###*
   * Функция получения секций аккордеона с элементами манипуляции
   *  внешними сущностями. Выполняет обработку только одного уровня иерархии
   *  внешних сущностей, если более глубокая вложенность не задана через
   *  параметр @props.immutable.externalEntitiesParams.allowExternalToExternal.
   *
   * @param {Object} items            - хэш для заполнения элементами для аккордиона.
   *                                    (выходной аргумент).
   *        {Object} reflectionParams - параметры внешней связки. Вид:
   *                 {String} name    - имя внешней связки.
   *                 {String} caption - заголовок внешней связки.
   * @return
   ###
   _fillAccordionSections: (items, reflectionParams) ->
      denyConstraintNames = @_DENY_CONSTRAINT_NAMES
      externalEntities = @props.externalEntities
      immutable = @props.immutable
      initialChain = @props.chain[..]
      mode = immutable.mode
      elementRefPrefixes = immutable.prefixes
      addElementToChain = immutable.addElementToChain
      getPrimaryKeyFromFields = immutable.getPrimaryKeyFromFields
      isHasExternalEntities = externalEntities? and !_.isEmpty externalEntities
      externalEntitiesParams = immutable.externalEntitiesParams
      isInUpdateMode = immutable.isInUpdateMode
      enableManuals = immutable.enableManuals
      enableManageReflections = immutable.enableManageReflections
      onClickOpenManual = immutable.onClickOpenManual
      dynamicFormNavigator = this
      functionalButtonStyle = @styles.functionalButton
      externalEntitiesItems = {}

      ###*
      * Функция помещения содержимого разрешенной внешней сущности с содержимым
      *  текущей внешней сущности в контейнер
      *
      * @param {Array} contentElements - массив элементов для вывода.
      * @return {React-Element}
      ###
      placeExternalToExternalInContainer = ((contentElements) ->
         `(
            <div style={this.styles.externalToExternalContainer}>
               {contentElements}
            </div>
          )`
      ).bind(dynamicFormNavigator)

      return unless isHasExternalEntities

      # Перебираем все внешние сущности и для каждой сущности создаем отдельную
      #  секцию аккордеона.
      for entityName, entity of externalEntities
         chain = initialChain[..]
         entityFields = entity.fields
         entityParent = entity.parent
         entityCaption = entity.entityCaption
         entityMetadata = entity.metadata
         entityReflectionName = entity.reflectionName
         entityIntermediateReflection = entity.intermediateReflection
         ignoredFieldName =
            if entityParent? and !_.isEmpty entityParent
               entityParent.key
         allowedExternal = @_getAllowedExternalForEntity(entityName, entity)

         definedReflectionFlags = @_defineReflectionFlags(entityName)
         recordKeys = entity.recordKeys
         isNew = definedReflectionFlags.isNew
         isDictionary = definedReflectionFlags.isDictionary
         isCombine = definedReflectionFlags.isCombine
         isMultiSelectDictionary = definedReflectionFlags.isMultiSelectDictionary
         isEntitySingle = entity.isSingle
         isReverseMultiple = entity.isReverseMultiple
         polymorphicReverse = entity.polymorphicReverse
         sectionIdentifier = @_getSectionIdentifier(entityReflectionName)
         isDenyReflection = @_isDenyByConstraint(entityReflectionName,
                                                 denyConstraintNames.toConstruct)
         isDenyToEdit =
            if (isInUpdateMode and enableManageReflections)
               @_isDenyByConstraint(entityReflectionName,
                                    denyConstraintNames.toEdit)
            else
               true
         isHasDictionaryRequestingParams =
            @_isHasDictionaryRequestingParams(entity.reflection)
         isHasAllowedExternalToExternal =
            allowedExternal? and !_.isEmpty allowedExternal


         entityElements = []
         sectionButtons = []
         sectionInfo = null
         sectionQuestion = null
         instancesSelector = null

         continue if isDenyReflection

         # Добавим параметры связки в цепь.
         addElementToChain(chain,
               caption: entityCaption
               reflection: entityReflectionName
               primaryKey: getPrimaryKeyFromFields(entityFields)
               intermediateReflection: entityIntermediateReflection
               isCollection: !isEntitySingle
               isReverseMultiple: isReverseMultiple
               polymorphicReverse: polymorphicReverse
               index: 1
            )

         # Формируем параметры для создания содежимого секции.
         paramsForSection =
            sectionIdentifier: sectionIdentifier
            entity: entity
            entityFields: entityFields
            ignoredFieldName: ignoredFieldName
            recordKeys: recordKeys
            chain: chain
            isNew: isNew
            isDictionary: isDictionary
            isCombine: isCombine
            isHasDictionaryRequestingParams: isHasDictionaryRequestingParams
            isEntitySingle: isEntitySingle
            isMultiSelectDictionary: isMultiSelectDictionary
            isHasAllowedExternalToExternal: isHasAllowedExternalToExternal

         accordionSection = @_getAccordionSection(paramsForSection)


         # Если заданы внешние разрешенные сущности для текущей внешней
         #  сущности - генерируем доп.секции с основной секцией - данными по основной
         #  внешней сущности.
         entityContent =
            if isHasAllowedExternalToExternal
               mainFormFields = accordionSection

               paramsForContent =
                  fields: entityFields
                  externalEntities: allowedExternal
                  ignoredFieldName: ignoredFieldName
                  isSingle: isEntitySingle
                  chain: chain

               # Получим аккордеон с основными данными текущей сущности и с секциями
               #  разрешенных к выводу внешних связанных сущностей.
               accordionWithExternalToExternal =
                  @_getFormContent(paramsForContent, sectionIdentifier)

               entityElements.push(accordionWithExternalToExternal)

               placeExternalToExternalInContainer(entityElements)
            else
               accordionSection

         # Считываем метаинформацию, если она задана.
         if entityMetadata? and !_.isEmpty entityMetadata
            sectionInfo = entityMetadata.description
            sectionQuestion = entityMetadata.help

         if enableManuals and onClickOpenManual?
            manualButtonParams = @_MANUAL_BUTTON_SCAFFOLD
            manualButtonParams.value =
               action: mode
               relatives:
                  chain.map (element)->
                     element.reflection
            manualButtonParams.onClick = onClickOpenManual
            manualButtonParams.styleAddition = functionalButtonStyle

            sectionButtons.push _.clone(manualButtonParams)

         # Если данная связка не запрещена для редактирования - добавим кнопку
         #  открытия диалога редактирования (элемент для управления компонентом
         #  DynamicFormInstancesController).
         unless isDenyToEdit
            editButtonParams = @_EDIT_BUTTON_SCAFFOLD
            editButtonParams.value =
               identifier: immutable.updateIdentifier
               ignoredFieldName: ignoredFieldName
               chain: chain
               fields: entityFields
               externalEntities: allowedExternal

            editButtonParams.onClick = @props.immutable.onClickEditReflection
            editButtonParams.styleAddition = functionalButtonStyle

            sectionButtons.push _.clone(editButtonParams)

         items[entityName] =
            header: entity.entityCaption
            headerButtons: sectionButtons
            identifier: sectionIdentifier
            content: entityContent
            info: sectionInfo
            question: sectionQuestion
            name: entityReflectionName
            counter: @_getSectionCounter(sectionIdentifier)

   ###*
   * Функция определения флагов типов веншних сущностей - генерация нового экземпляра,
   *  выбор существующего или комбинированный подход.
   *
   * @param {String} entityName - имя внешней связки.
   * @return {Object<Boolean>} - набор флагов.
   ###
   _defineReflectionFlags: (entityName) ->
      reflTypes = @_REFLECTION_TYPES
      reflectionParams = @props.immutable.reflectionControlParams
      isNew = true
      isDictionary = false
      isCombine = false
      isMultiSelectDictionary = false

      if reflectionParams? and !_.isEmpty reflectionParams
         reflectionParam = reflectionParams[entityName]

         if reflectionParam? and !_.isEmpty reflectionParam
            reflectionType = reflectionParam.type
            reflectionDictionaryParams = reflectionParam.dictionaryParams

            if reflectionDictionaryParams? and !_.isEmpty reflectionDictionaryParams
               isMultiSelectDictionary = !!reflectionDictionaryParams.enableMultipleSelect

            if reflectionType is reflTypes.dictionary
               isDictionary = true
               isNew = false
               isCombine = false

            if reflectionType is reflTypes.combine
               isDictionary = false
               isNew = false
               isCombine = true

      isNew: isNew
      isDictionary: isDictionary
      isCombine: isCombine
      isMultiSelectDictionary: isMultiSelectDictionary


###* Компонент: поля динамической формы. Часть компонента DynamicForm. Создает
*  поля для манипуляции аттрибутами сущности. Если задан флаг коллекции
*  (@props.isCollection) экземпляров - добавляется возможность добавления новых
*  экземпляров полей для задания новых экземпляров сущностей.
*
*     {Array<Object>} chain     - цепь связок(родителей) до текущих полей.
*     {Object} fields           - параметры полей.
*     {Number} instanceNumber   - номер экземпляра для которого создаются поля.
*     {Array} recordKeys        - набор идентификаторов существующих записей.
*     {String} ignoredFieldName - наименование игнорируемого поля (поле внешнего ключа).
*     {Boolean} isCombine       - флаг нахождения полей в комбинированном режиме работе
*                                 с сущностью. По-умолчанию = false
*     {Boolean} isCollection    - флаг множественной связки.
*                                 При множественной связке добавляется возможность
*                                 добавления/удаления экземпляров сущностей.
*                                 По-умолчанию = false.
*{Boolean} isExternalReflection - флаг внешней связки.
*     {Object} immutable - набор свойств, неизменяемых в цепи компонентов. Вид:
*
*           {Object} modelParams                - параметры модели
*           {Number} updateIdentifier           - идентификатор обновляемой записи.
*           {Object} dictionariesSelectedValues - значения, выбранные в словарях формы.
*           {String} mode                       - режим работы формы.
*           {Object} additionalValidationParams - дополнительные параметры валидации.
*           {Object} sectionsOrder              - параметры порядка следования
*                                                 секций в аккордеонах-навигаторах формы.
*           {Object} fieldsOrder                - параметры порядка следования полей
*                                                 в секциях аккордеонов-навигаторах формы.
*           {Object} fieldConstraints           - параметры ограничений полей.
*           {Object} sectionConstraints         - параметры ограничений секций(набора полей).
*           {Object} denyToEditReflections      - параметры запрещенных для редактирования связок.
*           {Object} denyReflections            - параметры запрещенных связок.
*           {Object} externalEntitiesParams     - параметры для сущностей, связанных внешними
*                                                 связками.
*           {Object} reflectionControlParams    - параметры для всех сущностей-связок.
*           {Object} reflectionRenderParams     - параметры рендера для всех сущносей-связок.
*           {Object} implementationStore        - хранилище стандартных реализаций.
*           {Boolean} isUseImplementation       - флаг использования хралища реализаций.
*           {Boolean} isImplementationHigherPriority - флаг более приоритетных свойств из хранилища реализаций.
*                                                  Нужен для переопределения свойств, заданных по-умолчанию.
*           {Boolean} isMergeImplementation     - флаг "слияния" свойств компонента со свойствами, заданными в
*                                                 хранилище реализаций.
*           {Boolean} isAddAttributesSuffixForChain - флаг добалвения суффикса _attributes в имя
*                                                     родительской сущности для поля.
*           {Boolean} enableManageReflections   - флаг разрешения управления связанными записями в
*                                                 режиме обновления.
*           {Boolean} enableManuals             - флаг разрешения работы с руководствами.
*           {Object} validationResult           - параметры результата валидации полей.
*           {Object} polymorphicStates          - параметры состояний полиморфных связок.
*           {Object} aliases                    - константные параметры строк-псевдонимов,
*                                                 используемых в форме для различных элементов.
*           {Object} suffixes                   - константные параметры используемых суффиксов,
*                                                 используемых при генерации строк.
*           {Object} chars                      - константные параметры используемых символов для
*                                                 генерации строк.
*           {Object} prefixes                   - константные параметры строк-суффиксов для
*                                                 различных элементов формы, испольуемые для
*                                                 формирования ссылок (TODO: скорее всего убрать).
*           {Object} tipTypes                   - константные парметры для кнопок-подсказок.
*           {Object} idFieldAlias               - псевдоним ключевого поля.
*           {Object} metaButtonParams           - параметры для кнопок отображения метаданных.
*           {Boolean} isRefreshed               - флаг того, что формы была сброшена.
*           {Boolean} isInUpdateMode            - флаг того, что форма находится в
*                                                 режиме "обновления".
*           {Function} getElementsSplitter      - функция получения разделителя элементов
*                                                 (горизонтальная линия). Возврат:
*                                                 {React-Element} splitter - элемент разделителя.
*           {Function} getInstanceControls      - функция получения кнопок управления экземплярами.
*                                                 Возврат:
*                                                 {React-Element} controls - элементы кнопок.
*           {Function} addElementToChain        - функция добавления элемента в цепь связок. Ожидаемые
*                                                 аргументы:
*                                                 {Array} chain - цепь (выходной параметр).
*                                                 {Object} item - параметры нового элемента.
*           {Function} getPrimaryKeyFromFields  - функция получения параметров первичного ключа
*                                                 из набора полей. Возврат:
*                                                 {Object} - параметры поля первичного ключа.
*           {Function} getFormField             - функция получения поля формы. Возврат:
*                                                 {React-Element} formField - поле формы.
*           {Function} changeLastNodeIndex      - функция иземениия индекса последнего элемента в цепи
*                                                 сязок (используется в циклах по кол-ву заданных
*                                                 экземпляров). Ожидаемые аргументы:
*                                                 {Array} chain     - цепь (выходной параметр).
*                                                 {Object} newIndex - новый индекс последнего элемента.
*           {Function} onClickOpenManual        - обработчик клика на кнопку открытия руководства
*           {Function} onChangeField            - обработчик на изменение значения в поле. Аргументы:
*                                                 {Object, String, Number} value - значение поля.
*                                                 {Object} field                 - параметры поля.
*                                                 {Object} fieldName             - имя поля.
*           {Function} onClearField             - обработчик на сброс значения в поле. Аргументы:
*                                                 {Object} field                 - параметры поля.
*                                                 {Object} fieldName             - имя поля.
*           {Function} onClickEditReflection    - обработчик клика на кнопку редактирования экземпляров
*                                                 связанных сущностей (открывает диалог редактирования).
*                                                 Аргументы:
*                                                 {Object} value - параметры, необходимые для редактирования.
*           {Function} onInitField              - обработчик на инициализацию поля (событие перед
*                                                 монтированием компонента). Агрументы:
*                                                 {React-Element} input - экземпляр поля.
*           {Function} onDestroyField           - обработчик на уничтожение поля (событие перед
*                                                 размонтированием). Аргументы:
*                                                 {React-Element} input - экземпляр поля.
*           {Function} onInitAccordion          - обработчик на инициализацию аккордеона-навигатора.
*                                                 (событие перед монтированием компонента). Аргументы:
*                                                 {React-Element} accordion - экземпляр аккордеона.
*           {Function} onDestroyAccordion       - обработчика на уничтожения аккордеона-навигатора.
*                                                 (событие перед размонтированием компонента). Аргументы:
*                                                 {React-Element} accordion - экземпляр аккордеона.
* @state
*     {Number} instancesCount
###
DynamicFormFields = React.createClass

   # @const {String} - строка, используемая при создании ссылок на поля для обозначения
   #                   номера нового поля.
   _NEW_INSTANCE_MARKER_STRING: 'new'

   # @const {String} - суффикс ключа для разделителя существующих экземпляров.
   _SPLITTER_EXIST_FINISH_KEY_SUFFIX: 'existFinish'

   mixins: [HelpersMixin]

   styles:
      fieldsContainer:
         width: '100%'
         padding: _COMMON_PADDING
      fieldSetGroup:
         borderWidth: 1
         borderStyle: 'solid'
         borderColor: _COLORS.hierarchy3
         borderRadius: _COMMON_BORDER_RADIUS
         color: _COLORS.hierarchy2
         marginTop: _COMMON_PADDING

   getDefaultProps: ->
      isCollection: false
      isCombine: false

   getInitialState: ->
      instancesCount: 1

   render: ->
      #containerRef = @_getContainerRef()
      fieldParams = @_getFields()

      if fieldParams
         newInstance = fieldParams.newInstance
         existInstances = fieldParams.existInstances

      `(
         <div>
            {existInstances}
            {newInstance}
            {this._getSplitter()}
            {this._getControls()}
         </div>
      )`

   ###*
   * Функция получения полей динамической формы.
   *
   * @return {Object} - набор элементов
   ###
   _getFields: ->
      fields = @props.fields
      chain = @props.chain
      immutable = @props.immutable
      changeLastNodeIndex = immutable.changeLastNodeIndex
      getElementsSplitter = immutable.getElementsSplitter
      getFormField = immutable.getFormField
      suffixes = immutable.suffixes
      chars = immutable.chars
      existSuffix = suffixes.exist
      splitterSuffix = suffixes.splitter
      underscoreChar = chars.underscore
      chainLength = chain.length
      reflectionParams = chain[chainLength - 1]
      isCollection = @props.isCollection
      isCombine = @props.isCombine
      isHasFields = fields? and !_.isEmpty(fields)
      isHasReflectionParams = reflectionParams? and !_.isEmpty reflectionParams
      newInstancesCount = @state.instancesCount
      ignoredFieldName = @props.ignoredFieldName
      # Определим имя связки - если заданы параметры связки - считаем из них,
      #  иначе - зададим псевдоним корневого узла.
      reflectionName = if isHasReflectionParams
                          reflectionParams.reflection
                       else
                          immutable.aliases.root
      fieldsParams = @_getOrderedFieldParams(reflectionName)
      fieldsArray = fieldsParams.fields
      fieldsCount = fieldsArray.length
      fieldsKey = fieldsParams.key
      isSingleField = @_isSingleField(fieldsArray, ignoredFieldName)
      isExistRecordInstances = @_isExistRecordInstances()
      isDenyExistInstances = @_isDenyExistInstances()
      fieldsInstanceNumber = @props.instanceNumber
      sectionConstraints = @_getSectionConstraints()
      newFormFields = []
      formFieldSetsForExistRecords = {}
      newInstanceFieldsElement = []
      existInstancesFieldsElements = []

      # Для набора полей формируем объекты для ввода.
      if isHasFields
         # Создаем элементы манипуляции новыми экземплярами - для каждого
         #  номера в заданном кол-ве экземпляров.
         #for instanceNumber in [1..newInstancesCount]
         fieldRows = []
         fieldRowsForExist = []

         # Меняем индекс последней связки в цепи только если это не первый
         #  номер экземпляра.
         # changeLastNodeIndex(chain, instanceNumber) if instanceNumber > 1

         actualChain = chain[..]

         # # Если это не первый экземпляр - добавим визуальный разделитель
         # #  набора полей экземпляра.
         # if instanceNumber > 1
         #    newInstanceFieldsElement.push(
         #       getElementsSplitter(instanceNumber)
         #    )

         # Переберем все поля и для каждого подготавливаем параметры и
         #  получаем компонент DynamicFormField и сохраняем в массиве.
         for fieldParams, idx in fieldsArray
            field = _.cloneDeep(fieldParams)
            fieldName = field.name
            fieldValue = field.value
            isReadOnlyField = field.isReadOnly
            isNotIgnoredField = fieldName isnt ignoredFieldName
            isValueWithInstances = @_isValueWithInstances(fieldValue)

            # Если это поле не игнорируется - продолжим
            if isNotIgnoredField
               fieldConstraints = @_getFieldConstraints(field, actualChain)

               if fieldConstraints?
                  fieldStrongValue = fieldConstraints.strongValue
                  isFieldHidden = fieldConstraints.isHidden
                  isFieldReadOnly = fieldConstraints.isReadOnly
                  identifyingName = fieldConstraints.identifyingName
                  isHideFormField = field.isPrimaryKey or isFieldHidden

                  # Обработаем ограничения поля:
                  # "Жесткое" значение поля.
                  if fieldStrongValue?
                     field.value = fieldStrongValue

                  # Флаг скрытого поля.
                  if isFieldHidden
                     field.isHidden = isFieldHidden

                  # Флаг поля только для чтения.
                  if isFieldReadOnly
                     field.isReadOnly = isFieldReadOnly

                  # Свойство "идентификационного имени" поля.
                  if identifyingName?
                     field.identifyingName = identifyingName

               # Если это не поле только для чтения(заданное бизнес-логикой
               #  - создаем новое поле и добавляем в коллекцию).
               unless isReadOnlyField
                  paramsForFormField =
                     field: field
                     recordKey: fieldsKey if fieldsKey? #  fieldsKey + idx if fieldsKey?
                     isResetFieldValue: isExistRecordInstances
                     chain: actualChain

                  fieldRow = getFormField(paramsForFormField, idx, immutable)
                  fieldRows.push(
                     name: fieldName
                     row: fieldRow
                  )

                  # Если не задано запрета на формирование полей для внешних связок,
                  #  а также значения в поле заданы особым образом в виде ассоциативного
                  #  массива с разбиением на экземпляры и это компонент первого набора
                  #  (остальные наборы будут только для полей новых экземпляров), то
                  #  создаем поля формы для каждого существующего экземпляра и особым
                  #  образом заполняем массив строк полей формы для дальнейшего легкого
                  #  разбиения их на наборы конкретных экземпляров.
                  if !isDenyExistInstances and isValueWithInstances and (fieldsInstanceNumber is 1)
                     fieldClone = _.cloneDeep(field)
                     valueIndex = 0

                     for instanceKey, instanceFieldValue of fieldValue
                        fieldClone.value = instanceFieldValue

                        paramsForFormField =
                           field: fieldClone
                           recordKey: instanceKey
                           isResetFieldValue: false
                           chain: actualChain
                        indexForExist = (fieldsCount * valueIndex) + idx

                        fieldRowForExist =
                           getFormField(
                              paramsForFormField,
                              [existSuffix, indexForExist].join(underscoreChar),
                              immutable
                           )

                        fieldRowsForExist[indexForExist] =
                           row: fieldRowForExist
                           name: fieldName

                        valueIndex++

         newInstanceFieldsElement =
            @_getSectionContent(fieldRows, 0, sectionConstraints)

         # Если были сформированы строки с заполненными полями существующих записей
         #  сформируем наборы полей с разделителями.
         if fieldRowsForExist? and !_.isEmpty(fieldRowsForExist)
            # Разбиваем полученные строки с полями равными частями по кол-ву полей.
            #  Затем для каждого получившегося набора создаем персональную таблицу
            #  (вставляем строки полей формы в оболочку-таблицу), добавляем её в набор
            #  элементов существующих экземпляров, затем добавляем визуальный разделитель
            #  областей.
            _.forEach(_.chunk(fieldRowsForExist, fieldsCount), ((fieldRows, idx) ->
                  existInstancesFieldsElements.push(
                     @_getSectionContent(fieldRows,
                                         [existSuffix, idx].join(underscoreChar),
                                         sectionConstraints)
                  )

                  existInstancesFieldsElements.push(
                     getElementsSplitter([
                           existSuffix
                           splitterSuffix
                           idx
                        ].join(underscoreChar)
                     )
                  )
               ).bind(this)
            )

         existInstances: existInstancesFieldsElements
         newInstance: newInstanceFieldsElement

   ###*
   * Функция получения таблицы с полями одного экземпляра сущности.
   *
   * @param {Array<Object>} fieldRowParams   - набор параметров элементов-строк с полями формы.
   * @param {String} sectionKey              - ключ для текущей секции.
   * @param {Object} sectionConstraints      - набор ограничений/специфичных настроек для
   *                                           данной секции.
   * @return {React-element}    - содержимое секции с полями.
   ###
   _getSectionContent: (fieldRowParams, sectionKey, sectionConstraints) ->

      ###
      * Функция оборачивания строк с полями формы в таблицу.
      *
      * @param {Array<Object>} fieldRowParams - набор параметров строк с полями таблицы.
      * @return {React-element}
      ###
      getTableWithFieldRows = ((fieldRowParams, tableKey)->
         fieldRows = fieldRowParams.map (rowParams) ->
            rowParams.row

         `(
            <table key={tableKey}
                   style={this.styles.fieldsContainer}>
               <tbody>
                  {fieldRows}
               </tbody>
            </table>
         )`
      ).bind(this)

      ###
      * Функция создания группировки полей.
      *
      * @param {Array<React-element>} fieldRowsInGroup  - набор строк с полями формы,
      *                                                   входящие в текущую группу.
      * @param {String} sectionKey - ключ секции в которой размещается группа полей.
      * @param {String} groupName - наименование группы.
      * @param {String} groupCaption - выводимый заголоовк группы.
      * @return {React-element}
      ###
      getGroupFieldSet = ((fieldRowsInGroup, sectionKey, groupName, groupCaption) ->
         immutable = @props.immutable
         suffixes = immutable.suffixes
         underscoreChar = immutable.chars.underscore
         groupTableKey = [sectionKey, groupName].join(underscoreChar)
         groupFieldSetKey = [
            sectionKey
            groupName
            suffixes.fieldSet
         ].join(underscoreChar)

         groupTable = getTableWithFieldRows(fieldRowsInGroup,
                                            groupTableKey)

         `(
             <fieldset key={groupFieldSetKey}
                       style={this.styles.fieldSetGroup} >
               <legend>{groupCaption}</legend>
               {groupTable}
             </fieldset>
          )`
      ).bind(this)

      ###
      * Функция выбора строк с полями формы по выборке имен. После выборки
      *  из целевой коллекции параметров полей производится удаления параметров,
      *  который попали в выборку по наименованиям.
      *
      * @param {Object} params - параметры функции. Вид:
      *     {String} groupName                     - имя коллекции
      *     {Array<Object>} targetRowParams        - целевая коллекция параметров строк полей -
      *                                              из которой выбираются и из которой исключаются.
      *     {Array} selectedFieldNames             - выбираемые и исключаемые имена полей.
      *     {Array} isConvertFieldPrefixToGrouping - флаг группировки полей с префиксами,
      *                                              совпадающими с именем группы.
      * @return {Array<React-element>, undefined}
      ###
      selectFieldRowsAndExcludeFromTargetCollection = ((params) ->
         groupName = params.groupName
         targetRowParams = params.targetRowParams
         selectedFieldNames = params.selectedFieldNames
         isConvertFieldPrefixToGrouping = params.isConvertFieldPrefixToGrouping
         selectedFieldRows = []

         for selectedField in selectedFieldNames
            selectedRowParamsIndex =
               _.findIndex(targetRowParams, { name: selectedField })
            selectedRowParams = targetRowParams[selectedRowParamsIndex]

            if selectedRowParams? and !_.isEmpty(selectedRowParams)
               clonedRowParams = _.clone(selectedRowParams)

               selectableRowParams =
                  if isConvertFieldPrefixToGrouping
                     getRowParamsWithChangedFieldNameToGrouping(clonedRowParams,
                                                                groupName)
                  else
                     clonedRowParams

               selectedFieldRows.push(
                  selectableRowParams
               )

            delete targetRowParams[selectedRowParamsIndex]

         selectedFieldRows unless _.isEmpty(selectedFieldRows)
      ).bind(this)

      ###
      * Функция получения параметров поля ввода формы с измененными именем поля
      *  для группировки по наименование группы в которой оно находится. Получает
      *  элемент строки с полем, считывает его свойства и меняет их таким образом
      *  чтобы значение поля находилось в группе при передаче в API
      *  (group_filedName -> [group][fieldName])
      *
      * @param {Object} rowParams - параметры функции. Вид:
      * @param {String} groupName   - параметры функции. Вид:
      * @return {Array<React-element>, undefined}
      ###
      getRowParamsWithChangedFieldNameToGrouping = ((rowParams, groupName) ->
         chars = @props.immutable.chars
         underscoreChar = chars.underscore
         rowNameParts = rowParams.name.split(underscoreChar)
         rowNamePrefix = _.head(rowNameParts)

         if rowNamePrefix is groupName
            rowElement = rowParams.row
            rowProps = rowElement.props
            fieldProp = rowProps.field
            chainProp = rowProps.chain
            fieldNameWithoutPrefix =
               _.without(rowNameParts, rowNamePrefix).join(underscoreChar)

            chainProp.push(
               reflection: rowNamePrefix
               index: 1
            )

            fieldProp.name = fieldNameWithoutPrefix

         rowParams



      ).bind(this)

      ###
      * Функция получения содержимого секции с группировкой полей. Не
      *  группированные поля выводятся снизу от сгруппированных.
      *
      * @param {Object} params - аргументы функции. Вид:
      *     {Array<Object>} fieldRowParams           - набор параметров
      *                                                элементов-строк с полями формы.
      *     {Array} sectionGroupts                   - группы полей.
      *     {String} sectionKey                      - ключ секции.
      *     {Boolean} isConvertFieldPrefixToGrouping - флаг конвертации префиксов полей,
      *                                                совпадающих с именем группы
      *                                                в группировку(для создания вложенности
      *                                                при передачи в API).
      * @return {React-element}
      ###
      getContentWithGroups = ((params) ->
         fieldRowParams = params.fieldRowParams
         sectionGroups = params.sectionGroups
         sectionKey = params.sectionKey
         isConvertFieldPrefixToGrouping = params.isConvertFieldPrefixToGrouping
         totalRowParams = _.cloneDeep(fieldRowParams)
         groupsContent = []

         for sectionGroup in sectionGroups
            groupFieldNames = sectionGroup.fields
            groupName = sectionGroup.name
            groupCaption = sectionGroup.caption

            if groupFieldNames
               fieldRowsInGroup =
                  selectFieldRowsAndExcludeFromTargetCollection(
                     groupName: groupName
                     targetRowParams: totalRowParams,
                     selectedFieldNames: groupFieldNames,
                     isConvertFieldPrefixToGrouping: isConvertFieldPrefixToGrouping
                  )

               groupsContent.push(
                  getGroupFieldSet(fieldRowsInGroup,
                                   sectionKey
                                   groupName,
                                   groupCaption)
               )

         # Если остались поля, не упорядоченные по группам - выберем оставшиеся
         #  обернем в таблицу и добавим в набор содержимого по группам.
         ungroupedRowParams = _.compact(totalRowParams)
         if ungroupedRowParams? and !_.isEmpty(ungroupedRowParams)
            groupsContent.push(
               getTableWithFieldRows(ungroupedRowParams, sectionKey)
            )

         groupsContent

      ).bind(this)


      if sectionConstraints? and !_.isEmpty(sectionConstraints)
         sectionGroups = sectionConstraints.groups
         isConvertFieldPrefixToGrouping = sectionConstraints.isConvertFieldPrefixToGrouping

      # Если для текущей секции заданы группы - делаем разбивку полей по группам.
      # Иначе формируем таблицу со сплошным последовательным выводом полей.
      if sectionGroups? and !_.isEmpty(sectionGroups)
         getContentWithGroups(
            fieldRowParams: fieldRowParams,
            sectionGroups: sectionGroups,
            sectionKey: sectionKey,
            isConvertFieldPrefixToGrouping: isConvertFieldPrefixToGrouping
         )
      else
         getTableWithFieldRows(fieldRowParams, sectionKey)

   ###*
   * Функция получения разделителя элементов.
   *
   * @return {React-Element} - компонент с кнопками управления.
   ###
   _getSplitter: ->
      @props.immutable.getElementsSplitter() if @props.isCollection

   ###*
   * Функция получения кнопок управления полями новых экземеляров сущностей.
   *
   * @param {Object} params - параметры для создания кнопок управления. Вид:
   *        {String} identifier - идентификатор элемента.
   *        {String} type - тип элемента. Варианты:
   *              'accordion' - аккордеон.
   *              'container' - контейнер полей(секция аккордеона).
   * @return {React-DOM-Element}
   ###
   _getControls: (params) ->
      if @props.isCollection
         instancesCount = @state.instancesCount
         getControlsHandler = @props.immutable.getInstanceControls

         getControlsHandler(@_onClickControlInstance, instancesCount)

   ###*
   * Обработчик клика по кнопке управления кол-вом экземпляров (добавить/удалить).
   *
   * @param {Boolean} isDecrement - флаг декремента (понижение кол-ва).
   * @return
   ###
   _onClickControlInstance: (isDecrement) ->
      instancesCount = @state.instancesCount

      if isDecrement
         instancesCount-- if instancesCount > 1
      else
         instancesCount++

      @setState instancesCount: instancesCount

   ###*
   * Функция получения параметров полей из хэша. Функция нужна для упорядочивания полей,
   *  (если упорядочивание задано для данной сущности) и первичного ключа.
   *
   * @param {String} reflectionName - имя связки.
   * @return  {Object} - хэш параметров. Вид:
   *          {Array} fileds - упорядоченный массив полей.
   *          {String} key   - ключ записи.
   ###
   _getOrderedFieldParams: (reflectionName) ->
      fields = @props.fields
      fieldsOrder = @_getSectionFieldsOrder(reflectionName)
      resultFields = []
      recordKey = null

      # Если задан порядок полей для данной сущности - сортируем,
      # Иначе - просто перебираем в порядке текущего следования и преобразуем
      #  в массив.
      if fieldsOrder?
         fieldsClone = _.cloneDeep(fields)
         sortedFields = []

         # Сначала перебираем упорядочиваемые поля.
         for fieldName in fieldsOrder
            field = fieldsClone[fieldName]
            item = {}

            if field?
               sortedFields.push(field) if field?

               recordKey = field.value if field.isPrimaryKey

               delete fieldsClone[fieldName]

         # Затем перебираем все оставшиеся в порядке текущего следования.
         for _fieldName, field of fieldsClone
            recordKey = field.value if field.isPrimaryKey

            sortedFields.push(field)

         resultFields = sortedFields
      else
         for _fieldName, field of fields
            recordKey = field.value if field.isPrimaryKey

            resultFields.push(field)

      fields: resultFields
      key: recordKey

   ###*
   * Функция получения порядка следования полей в секции.
   *
   * @param {String, undefined} reflectionName - имя связки.
   * @return {Array<String>, undefined} - порядок следования полей.
   ###
   _getSectionFieldsOrder: (reflectionName) ->
      immutable = @props.immutable
      fieldsOrder = immutable.fieldsOrder
      rootNodeAlias = immutable.aliases.rootNode

      if fieldsOrder?
         if reflectionName?
            fieldsOrder[reflectionName]
         else
            fieldsOrder[rootNodeAlias]

   ###*
   * Функция получения ограничения для текущей секции набора полей.
   *
   * @return {Object} - параметры огрнаичений текущей секции.
   ###
   _getSectionConstraints: ->
      immutable = @props.immutable
      sectionConstraints = immutable.sectionConstraints if immutable?
      currentSectionParams = _.last(@props.chain)
      aliases = immutable.aliases

      if sectionConstraints
         currentSectionName =
            if currentSectionParams?
               currentSectionParams.reflection
            else
               aliases.rootNode

         sectionConstraints[currentSectionName]

   ###*
   * Функция считывания ограничений по полю. Считывает параметры ограничений полей
   *  из свойств компонента. Если параметры ограничений для поля не заданы -
   *  возвращает параметры по-умолчанию.
   *
   * @param {Object} field - параметры поля.
   * @param {Array<Hash>} chain  - массив родительских связок.
   * @return {Object}
   ###
   _getFieldConstraints: (field, chain) ->
      fieldConstraints = @props.immutable.fieldConstraints
      constraints = fieldConstraints.constraints if fieldConstraints?
      isHidden = false
      isReadOnly = false
      strongValue = null
      fieldConstraint = null

      # Если заданы ограничения - продолжим.
      if constraints?
         fieldName = field.name
         isSetChainParents = !!(chain? and chain.length)
         emptyChar = @props.immutable.chars.empty
         chainParents = if isSetChainParents
                           chain.map (element) ->
                              element.reflection

         # Перебираем все заданные ограничения и ищем ограничение, совпадающее
         #  с проверяемым полем по наименованию полю и по цепи родителей.
         for constraint in constraints
            constrParents = constraint.parents
            constrFieldName = constraint.name
            constrFieldNameRegExp = constraint.nameRegExp
            isSetConstrParents = !!(constrParents? and constrParents.length)
            isNameMatches =
               if constrFieldName?
                  fieldName is constrFieldName
               else if constrFieldNameRegExp?
                  new RegExp(constrFieldNameRegExp).test fieldName
               else
                  false

            isParentsMatches =
               if isSetChainParents and isSetConstrParents
                  _.isEqual(chainParents, constrParents)
               else if isSetChainParents is isSetConstrParents
                  true
               else
                  false

            if isNameMatches and isParentsMatches
               fieldConstraint = constraint
               break

      # Если ограничения удалось считать - считываем параметры ограничений по полю.
      fieldConstraint if fieldConstraint?


   ###*
   * Получения параметров метаданных по модели внешней связки.
   *
   * @param {Object} fieldParams - параметры поля.
   * @return {Array, undefined} - массив параметров метаданных.
   ###
   _getIntenalReflectionMetadata: (fieldParams) ->
      reflectionParams = fieldParams.reflection

      if reflectionParams?
         instanceReflection = @_getInstanceReflection(reflectionParams)

         if instanceReflection?
            metadataCollection = []
            instanceRelation = instanceReflection.relation
            isPolymorphic = instanceReflection.isPolymorphic

            for _relName, relation of instanceRelation
               metadata = relation.metadata
               metadataCollection.push metadata if metadata?

      metadataCollection if metadataCollection? and  metadataCollection.length

   ###*
   * Функция-предикат для определения является ли поле одиночным доступным
   *  для манипуляций для сущности.
   *
   * @param {Array} fieldsArray - набор полей.
   * @param {String} ignoredFieldName - имя игнорируемого поля.
   * @return {Boolean}
   ###
   _isSingleField: (fieldsArray, ignoredFieldName) ->
      count = 0

      for field in fieldsArray
         break if count > 1

         if field.name isnt ignoredFieldName and !field.isPrimaryKey
            count++

      count is 1

   ###*
   * Функция-предикат для определения является ли переданное значение -
   *  коллекцией значений для существующих экземпляров. Значения в поле должны
   *  быть представлены в виде ассоциативного массива в виде :
   *    [instanceKey]: [fieldValue].
   *
   * @param {Object, String, Number} fieldValue - значение поля.
   * @return {Boolean}
   ###
   _isValueWithInstances: (fieldValue) ->
      if _.isPlainObject fieldValue
         fieldKeys = _.keys(fieldValue)
         !!!_.find(fieldKeys, (key) -> !_.isFinite(+key))
      else
         false

   ###*
   * Функция-предикат для определения запрешено ли формирование полей для
   *  существующих экземпляров. Проверяет является ли набор полей
   *  - полями внешней связки, а также в параметрах внешних связок проверяет флаг
   *  запрета формирования существующих экземпляров.
   *
   * @return {Boolean}
   ###
   _isDenyExistInstances: ->
      externalEntitiesParams = @props.immutable.externalEntitiesParams
      isDenyExistInstances =
         if externalEntitiesParams?
            externalEntitiesParams.isDenyExistInstances
      isExternalReflection = @props.isExternalReflection

      if isDenyExistInstances?
         isDenyExistInstances and isExternalReflection

   ###*
   * Функция-предикат для определения заданы ли ключи существующих экземпляров.
   *
   * @return {Boolean}
   ###
   _isExistRecordInstances: ->
      recordKeys = @props.recordKeys

      !!(recordKeys? and recordKeys.length)


###* Компонент: поле динамической формы. Часть компонента DynamicForm.
*
*  @props
*     {Array<Object>} chain         - цепь связок(родителей) до текущих полей.
*     {Object} field                - параметры поля.
*     {String} recordKey            - ключ считываемого значения (если значения в поле в виде хэша).
*     {Boolean} isResetFieldValue   - флаг сброса значения в поле. Параметр нужен для добавления
*
*     {Object} immutable - набор свойств, неизменяемых в цепи компонентов. Вид:
*
*           {Object} modelParams                - параметры модели
*           {Number} updateIdentifier           - идентификатор обновляемой записи.
*           {Object} dictionariesSelectedValues - значения, выбранные в словарях формы.
*           {String} mode                       - режим работы формы.
*           {Object} additionalValidationParams - дополнительные параметры валидации.
*           {Object} sectionsOrder              - параметры порядка следования
*                                                 секций в аккордеонах-навигаторах формы.
*           {Object} fieldsOrder                - параметры порядка следования полей
*                                                 в секциях аккордеонов-навигаторах формы.
*           {Object} fieldConstraints           - параметры ограничений полей.
*           {Object} sectionConstraints         - параметры ограничений секций.
*           {Object} denyToEditReflections      - параметры запрещенных для редактирования связок.
*           {Object} denyReflections            - параметры запрещенных связок.
*           {Object} externalEntitiesParams     - параметры для сущностей, связанных внешними
*                                                 связками.
*           {Object} reflectionControlParams    - параметры для всех сущностей-связок.
*           {Object} reflectionRenderParams     - параметры рендера для всех сущносей-связок.
*           {Object} implementationStore        - хранилище стандартных реализаций.
*           {Boolean} isUseImplementation       - флаг использования хралища реализаций.
*           {Boolean} isImplementationHigherPriority - флаг более приоритетных свойств из хранилища реализаций.
*                                                  Нужен для переопределения свойств, заданных по-умолчанию.
*           {Boolean} isMergeImplementation     - флаг "слияния" свойств компонента со свойствами, заданными в
*                                                 хранилище реализаций.
*           {Boolean} isAddAttributesSuffixForChain - флаг добалвения суффикса _attributes в имя
*                                                     родительской сущности для поля.
*           {Boolean} enableManageReflections   - флаг разрешения управления связанными записями в
*                                                 режиме обновления.
*           {Boolean} enableManuals             - флаг разрешения работы с руководствами.
*           {Object} validationResult           - параметры результата валидации полей.
*           {Object} polymorphicStates          - параметры состояний полиморфных связок.
*           {Object} aliases                    - константные параметры строк-псевдонимов,
*                                                 используемых в форме для различных элементов.
*           {Object} suffixes                   - константные параметры используемых суффиксов,
*                                                 используемых при генерации строк.
*           {Object} chars                      - константные параметры используемых символов для
*                                                 генерации строк.
*           {Object} prefixes                   - константные параметры строк-суффиксов для
*                                                 различных элементов формы, испольуемые для
*                                                 формирования ссылок (TODO: скорее всего убрать).
*           {Object} tipTypes                   - константные парметры для кнопок-подсказок.
*           {Object} idFieldAlias               - псевдоним ключевого поля.
*           {Object} metaButtonParams           - параметры для кнопок отображения метаданных.
*           {Boolean} isRefreshed               - флаг того, что формы была сброшена.
*           {Boolean} isInUpdateMode            - флаг того, что форма находится в
*                                                 режиме "обновления".
*           {Function} getElementsSplitter      - функция получения разделителя элементов
*                                                 (горизонтальная линия). Возврат:
*                                                 {React-Element} splitter - элемент разделителя.
*           {Function} getInstanceControls      - функция получения кнопок управления экземплярами.
*                                                 Возврат:
*                                                 {React-Element} controls - элементы кнопок.
*           {Function} getPrimaryKeyFromFields  - функция получения параметров первичного ключа
*                                                 из набора полей. Возврат:
*                                                 {Object} - параметры поля первичного ключа.
*           {Function} getFormField             - функция получения поля формы. Возврат:
*                                                 {React-Element} formField - поле формы.
*           {Function} addElementToChain        - функция добавления элемента в цепь связок. Ожидаемые
*                                                 аргументы:
*                                                 {Array} chain - цепь (выходной параметр).
*                                                 {Object} item - параметры нового элемента.
*           {Function} changeLastNodeIndex      - функция иземениия индекса последнего элемента в цепи
*                                                 сязок (используется в циклах по кол-ву заданных
*                                                 экземпляров). Ожидаемые аргументы:
*                                                 {Array} chain     - цепь (выходной параметр).
*                                                 {Object} newIndex - новый индекс последнего элемента.
*           {Function} onClickOpenManual        - обработчик клика на кнопку открытия руководства
*           {Function} onChangeField            - обработчик на изменение значения в поле. Аргументы:
*                                                 {Object, String, Number} value - значение поля.
*                                                 {Object} field                 - параметры поля.
*                                                 {Object} fieldName             - имя поля.
*           {Function} onClearField             - обработчик на сброс значения в поле. Аргументы:
*                                                 {Object} field                 - параметры поля.
*                                                 {Object} fieldName             - имя поля.
*           {Function} onClickEditReflection    - обработчик клика на кнопку редактирования экземпляров
*                                                 связанных сущностей (открывает диалог редактирования).
*                                                 Аргументы:
*                                                 {Object} value - параметры, необходимые для редактирования.
*           {Function} onInitField              - обработчик на инициализацию поля (событие перед
*                                                 монтированием компонента). Агрументы:
*                                                 {React-Element} input - экземпляр поля.
*           {Function} onDestroyField           - обработчик на уничтожение поля (событие перед
*                                                 размонтированием). Аргументы:
*                                                 {React-Element} input - экземпляр поля.
*           {Function} onInitAccordion          - обработчик на инициализацию аккордеона-навигатора.
*                                                 (событие перед монтированием компонента). Аргументы:
*                                                 {React-Element} accordion - экземпляр аккордеона.
*           {Function} onDestroyAccordion       - обработчика на уничтожения аккордеона-навигатора.
*                                                 (событие перед размонтированием компонента). Аргументы:
*                                                 {React-Element} accordion - экземпляр аккордеона.
*  @state
*     {Object} relation       - параметры связи.
*     {Object} uploadParams   - параметры поля загрузки файла.
*     {Boolean} isPolymorphic - признак полиморфной связи.
*     {Boolean} isReflection  - признак поля-связки
*     {Boolean} isRelation    - признак поля с параметрами для поля выбора.
*     {Boolean} isUploader    - признак поля загрузки файла.
*     {Boolean} isHasRequestingParams - признак наличия параметров для построения поля выбора.
*     {Boolean} isRestrictedByPrefix  - признак запрета поля по префиксу(поле не строится).
###
DynamicFormField = React.createClass

   # @const {String} - ключ для доступа к члену параметров связанной сущности.
   _ENTITY_CAPTION_KEY: 'entityCaption'

   # @const {Object} - объект с типом валидатора на присутствие (для поиска).
   _PRESENCE_VALIDATOR_TYPE_OBJ:
      type: 'presence'

   # @const {Object} - параметры для иконки вывода метаданных-описания по полю.
   _FIELD_META_DESCRIPTION_ICON:
      type: 'common'
      name: 'info'

   # @const {Object} - параметры кнопки-маркера метаданных.
   _METADATA_BUTTON_PARAMS:
      isLink: true
      isWithoutPadding: true

   # @const {Object} - возможные типы метаданных.
   _METADATA_TYPES: keyMirror(
      description: null
      question: null
   )

   # @const {Object} - параметры кнопки вызова пояснения для презентации
   #                   реагируемого поля.
   _HINT_BUTTON_PARAMS:
      tipModeParams:
         tipType: 'info'
      isLink: true

   # @const {String} - параметры для индикатора загрузки "реагируемого" содержимого.
   _RESPONSIVE_LOADER_PARAMS:
      view: 'spinner'
      text: 'Подождите, идет загрузка содержимого...'

   # @const {String} - ожидаемые формат ответа бизнес-логики.
   _JSON_ACCEPT_FORMAT: 'json'

   # @const {String} - ключ на установку ожидаемого формата ответа.
   _REQUEST_ACCEPT_KEY: 'Accept'

   # @const {Number} - код успешного ответа бизнес-логики.
   _SUCCESS_STATUS_CODE: 200

   # @const {Number} - смещение индекса для поля сущестующего экземпляра(для того,
   #                   чтобы значения не смешивались с новыми экземплярами).
   _EXIST_INSTNCE_BIAS_INDEX: 1000

   mixins: [HelpersMixin]

   styles:
      unionFieldsRow:
         padding: 1
         # outlineStyle: 'solid'
         # outlineColor: _COLORS.hierarchy3
         # outlineWidth: 1
         # outlineOffset: -2
      hiddenFieldRow:
         display: 'none'
      unionFieldsCaptionCell:
         fontWeight: 'bold'
         backgroundColor: _COLORS.hierarchy4
         borderWidth: 1
         borderStyle: 'solid'
         borderColor: _COLORS.hierarchy3
         whiteSpace: 'normal'
         fontSize: 14
         textAlign: 'center'
      reflectionContentCell:
         borderWidth: 1
         borderStyle: 'solid'
         borderColor: _COLORS.hierarchy3
         borderLeftWidth: 0
         padding: 0
      responsiveContentCell:
         padding: 3
      fieldCaptionCell:
         textAlign: 'right'
         fontStyle: 'italic'
         color: _COLORS.hierarchy2
         padding: _COMMON_PADDING - 2
         fontSize: 13
         maxWidth: 300
         whiteSpace: 'nowrap'
         overflow: 'hidden'
         textOverflow: 'ellipsis'
      fieldInputCell:
         padding: 2
         textAlign: 'left'
         minWidth: 250
         width: '100%'
      metadataInternalButtonContainer:
         textAlign: 'right'
      metadataButton:
         fontSize: 18
         color: _COLORS.hierarchy2
         paddingLeft: 3
      responsivePresentationContainer:
         textAlign: 'center'
         color: _COLORS.hierarchy2
         fontSize: 14
         padding: _COMMON_PADDING
      responsivePresentationHeader:
         backgroundColor: _COLORS.hierarchy4
      responsivePresentationDescription:
         maxWidth: 500
         color: _COLORS.hierarchy3
         fontSize: 12

   getInitialState: ->
      @_getInitFieldState()

   componentWillReceiveProps: (nextProps) ->
      # TODO: возможно и не стоит так с горяча - может обрабатывать только конкретные
      #  случаи.
      @setState @_getInitFieldState(nextProps)

   render: ->
      rowParams = @_getRowParams()
      fieldCaption = rowParams.caption


      `(
         <tr style={rowParams.rowStyle}>
            <td style={rowParams.captionCellStyle}
                title={fieldCaption}  >
               <span>{fieldCaption}</span>
               {this._getMetadataMarkers()}
            </td>
            <td style={rowParams.fieldCellStyle}>
               {this._getFieldInput()}
               {this._getResponsiveContent()}
               <AjaxLoader target={this.state.loaderTarget}
                           isShown={this.state.isResponsiveContentRequested}
                           {...this._RESPONSIVE_LOADER_PARAMS}
                        />
            </td>
         </tr>
       )`

   componentDidMount: ->
      @setState loaderTarget: this

   ###*
   * Функция получения маркеров метаданных связки по полю.
   *
   * @return {React-element}
   ###
   _getMetadataMarkers: ->
      ###*
      * Функция формирования кнопки для отображения метаданных поля.
      *
      * @param {String} title            - выводимый текст-пояснение.
      * @param {String} type             - тип кнопки (description/question)
      * @param {Object} metaButtonParams - параметры для кнопок метаданных,
      *                                    пробрасываемых с родительского элемента.
      * @param {Number} key              - ключ элемента в коллекции.
      * @return {React-element}
      ###
      getMetadataButton = ((title, type, key) ->
         metadataButtonParams = @_METADATA_BUTTON_PARAMS
         metadataTypes = @_METADATA_TYPES
         metaButtonStyle = @styles.metadataButton
         tipTypes = @props.immutable.tipTypes
         metaButtonParams = @props.immutable.metaButtonParams

         switch type
            when metadataTypes.description
               tipModeParams =
                  tipType: tipTypes.info
               icon = metaButtonParams.description.icon
            when metadataTypes.question
               tipModeParams =
                  tipType: tipTypes.question
               icon = metaButtonParams.question.icon
         `(
            <Button tipModeParams={tipModeParams}
                    key={key}
                    icon={icon}
                    title={title}
                    styleAddition={metaButtonStyle}
                    {...metadataButtonParams}
                  />
         )`
      ).bind(this)

      ###*
      * Функция создания кнопок для отображения метаданных и добавления
      *  этих кнопок в коллекцию кнопок метаданных по полю.
      *
      * @param {Array} metadataCollection - коллекция метаданных.
      * @param {Array} buttonCollection - коллекция кнопок (целевой аттрибут).
      * @return
      ###
      addMetadataButtonsToCollection = ((metadataCollection, buttonCollection) ->
         if metadataCollection?
            metaDescription = metadataCollection.description
            metaQuestion = metadataCollection.question
            metadataTypes = @_METADATA_TYPES

            if metaDescription?
               buttonCollection.push(
                  getMetadataButton(metaDescription,
                                    metadataTypes.description,
                                    buttonCollection.length)
               )

            if metaQuestion?
               buttonCollection.push(
                  getMetadataButton(metaQuestion,
                                    metadataTypes.question,
                                    buttonCollection.length)
                  )
      ).bind(this)

      metadata = @state.metadata
      metadataRelation = metadata.relation
      metadataFieldCollection = metadata.field
      metadataButtons = []

      metadataCollectionRelation =
         if @state.isPolymorphic
            metadataRelation[@state.polyEntityName]
         else
            metadataRelation

      if metadataCollectionRelation?
         addMetadataButtonsToCollection(metadataCollectionRelation, metadataButtons)

      if metadataFieldCollection?
         addMetadataButtonsToCollection(metadataFieldCollection, metadataButtons)

      unless _.isEmpty(metadataButtons)
         `(
            <span style={this.styles.metadataInternalButtonContainer}>
               {metadataButtons}
            </span>
         )`

   ###*
   * Функция получения поля формы или содержимого внутренней связки.
   *
   * @return {React-Element}
   ###
   _getFieldInput: ->
      field = @props.field
      recordKey = @props.recordKey
      isResetFieldValue = @props.isResetFieldValue
      immutable = @props.immutable
      addElementToChain = immutable.addElementToChain
      getPrimaryKeyFromFields = immutable.getPrimaryKeyFromFields
      modelRelations = immutable.modelParams.relations
      implementationStore = immutable.implementationStore
      isUseImplementation = immutable.isUseImplementation
      isImplementationHigherPriority = immutable.isImplementationHigherPriority
      isMergeImplementation = immutable.isMergeImplementation
      updateIdentifier = immutable.updateIdentifier
      chain = _.cloneDeep(@props.chain)
      chainLength = chain.length
      reflectionParams = chain[chainLength - 1]
      reflection = field.reflection
      fieldCaption = field.caption
      validationParams = @_getValidationParams()
      uploadParams = @state.uploadParams
      instanceRelation = @state.relation
      isAddAttributesSuffixForChain = immutable.isAddAttributesSuffixForChain
      isPolymorphic = @state.isPolymorphic
      isHasRequestingParams = @state.isHasRequestingParams
      isRestrictedByPrefix = @state.isRestrictedByPrefix
      isUploader = @state.isUploader
      isRelation = @state.isRelation
      isReflection = @state.isReflection
      polyEntityName = @state.polyEntityName
      dictionaryParams = @_getDictionaryParams(field, isRelation)
      fieldMetadata = @state.metadata.field

      # Если заданы метаданные для поля - пробуем определить заполнитель пустого
      #  поля и параметры для информационной иконки-описания поля.
      if fieldMetadata?
         placeholder =
            if fieldMetadata.placeholder?
               fieldMetadata.placeholder
            else
               @_PLACEHOLDER

      # Если поле - это внутренняя связки и это не словарь(поле выбора), то запустим
      #  цепь получения содержимого формы для этой сущности и вернем полученный результат.
      # Иначе сформируем обычное поле формы.
      if isReflection
         internalReflectionName = reflection.name

         # internalReflectionParams =
         #    name: internalReflectionName
         #    caption: fieldCaption
         #    parents: field.reflection.parentReflections

         # Для полиморфных связок - формируем поля, только если тип полиморфной связи
         #  уже задан.
         # Для обычных связок - сформируем полноценный контент формы.
         if isPolymorphic

            if polyEntityName?
               polyEntity = instanceRelation[polyEntityName]
               relationFields = polyEntity.fields
               relationExternalEntities = polyEntity.externalEntities

               paramsForForm =
                  chain: chain
                  fields: relationFields
                  externalEntities: relationExternalEntities
         else
            relationKey = Object.keys(instanceRelation)[0]

            if relationKey?
               relationFields = instanceRelation[relationKey].fields
               relationExternalEntities = instanceRelation[relationKey].externalEntities
               externalEntities = @_checkAndGetExternalEntities(relationExternalEntities)

               paramsForForm =
                  fields: relationFields
                  externalEntities: externalEntities
                  chain: chain

         addElementToChain(chain,
            caption: fieldCaption
            reflection: internalReflectionName
            primaryKey: getPrimaryKeyFromFields(relationFields)
            isCollection: false
            isReverseMultiple: reflection.isReverseMultiple
            polymorphicEntityName: polyEntityName
            index: 1
         )

         @_getFormContent(paramsForForm) if paramsForForm?

      else unless isRestrictedByPrefix
         isExternalReflection = field.reflectionName?

         # Если был задан флаг сброса значения(создается новый пустой экземпляр
         #  от заполненного поля) - сбросим значения в параметрах поля.
         if isResetFieldValue
            field.value = null

         fieldChain = if modelRelations? and modelRelations.length
                         if chain? and chain.length
                            Array.concat(modelRelations, chain)
                         else
                            modelRelations
                      else
                        chain

         # Определим новый индекс поля для последней связки в цепи. Если задан ключ
         #  существующего экземпляра, то создаем индекс поля на основе данного ключа +
         #  константа смещения(для отделения новых экземпляров от существующих).
         lastNodeNewIndex =
            (_.isString(recordKey) or _.isInteger(recordKey)) and +recordKey

         if _.isFinite(lastNodeNewIndex)
            lastNode = _.last(chain)

            if lastNode?
               lastNode.index = lastNodeNewIndex + @_EXIST_INSTNCE_BIAS_INDEX

         modelParams =
            name: @props.immutable.modelParams.name,
            chain: fieldChain,
            isInstancesSelector: isExternalReflection

         `(<FormInput selectedKey={recordKey}
                      updateIdentifier={updateIdentifier}
                      field={field}
                      title={field.caption}
                      modelParams={modelParams}
                      uploadParams={uploadParams}
                      validationParams={validationParams}
                      implementationStore={implementationStore}
                      isAddAttributesSuffixForChain={isAddAttributesSuffixForChain}
                      isUseImplementation={isUseImplementation}
                      isMergeImplementation={isMergeImplementation}
                      isImplementationHigherPriority={isImplementationHigherPriority}
                      isResetSelectedValue={isResetFieldValue}
                      isReset={this.props.immutable.isRefreshed}
                      isKeyHidden={true}
                      isUploader={isUploader}
                      dictionaryParams={dictionaryParams}
                      placeholder={placeholder}
                      reflectionRenderParams={this._getReflectionRenderParams(field)}
                      onChange={this._onChangeFormInput}
                      onClear={this._onClearFormInput}
                      onInit={immutable.onInitField}
                      onDestroy={immutable.onDestroyField}
                   />)`

   ###*
   * Функция подготовки содержиого "реагируемого" поля.
   *
   * @return {React-element}
   ###
   _getResponsiveContent: ->
      responsiveContent = @state.responsiveContent
      field = @props.field
      immutable = @props.immutable
      chars = immutable.chars
      styles = @styles

      if responsiveContent and !_.isEmpty(responsiveContent)
         responsiveFields = responsiveContent.fields
         responsivePresentation = responsiveContent.presentation
         clonedChain = _.cloneDeep(@props.chain)


         # Подготовим имя для добавления в связку - пытаемся убрать маркер внешнего
         #  ключа (_id) от имени поля(т.к. предполагается что реагируемое поле - поле
         #  селектор сущности.)
         responsive_entity_name =  _.trimEnd(field.name,
            [
               chars.underscore
               immutable.idFieldAlias
            ].join chars.empty
         )

         immutable.addElementToChain(clonedChain,
            caption: field.caption
            reflection: responsive_entity_name
            isCollection: false
            index: 1
         )

         responsiveForm =
            @_getFormContent(
               fields: responsiveFields
               chain: clonedChain
            )

         presentationContent =
            if responsivePresentation? and !_.isEmpty(responsivePresentation)
               presentationHint = responsivePresentation.hint

               hintButton =
                  if presentationHint?
                     `(
                         <Button {...this._HINT_BUTTON_PARAMS}
                                 title={presentationHint}
                               />
                      )`

               `(
                  <article style={styles.responsivePresentationContainer}>
                     <header style={styles.responsivePresentationHeader}>
                        {responsivePresentation.caption}
                     </header>
                     <section style={styles.responsivePresentationDescription}>
                        {responsivePresentation.description}
                     </section>
                     <section>
                        {responsivePresentation.content}
                        {hintButton}
                     </section>
                  </article>
               )`


         `(
            <div>
               {presentationContent}
               {responsiveForm}
            </div>
          )`

         #@_getFormContent(paramsForForm)

   ###*
   * Обработчик на изменение поля значение в поле формы. Пробрасывает вызов на
   *  обработчик корневого родительского компонента.
   *
   * @param {String} value - выбранное значение.
   * @param {Object} field - параметры поля.
   * @param {String} name  - имя поля в форме.
   * @param {Boolean} isInitSet - флаг начальной установки значения в поле.
   * @return
   ###
   _onChangeFormInput: (value, field, name, isInitSet) ->
      @props.immutable.onChangeField(value, field, name, isInitSet)
      @_processResponsive(value)

   ###*
   * Обработчик на сброс значения в поле.
   * @param {Object} field - параметры поля.
   * @param {String} name  - имя поля в форме.
   * @return
   ###
   _onClearFormInput: (field, name) ->
      @props.immutable.onClearField(field, name)

   ###*
   * Функция получения содержимого формы для поля-внутренней связки. Запускает
   *  цепь построения рекурсивных компонентов.
   *
   * @param {Object} props   - параметры для содержимого динамической формы.
   * @return {React-element} - компонент содержимого формы.
   ###
   _getFormContent: (props) ->
      clonedProps = _.cloneDeep(props)

      `(
          <DynamicFormContent {...clonedProps}
                              immutable={this.props.immutable}
                           />
       )`

   ###*
   * Функция получения параметров заголовка поля формы.
   *
   * @return {Object} - параметры. Вид:
   *     {React-Element} caption   - ячейка заголовка.
   *     {Object} rowStyle         - стиль для строки поля формы.
   *     {Object} captionCellStyle - стиль для ячейки заголовка.
   ###
   _getRowParams: (params) ->
      formField = @props.field
      fieldCaption = formField.caption
      responsiveContent = @state.responsiveContent
      isHasResponsiveContent = responsiveContent and !_.isEmpty(responsiveContent)
      isPolymorphic = @state.isPolymorphic
      isRestrictedByPrefix = @state.isRestrictedByPrefix
      isPolyHidden = isPolymorphic and !@state.polyEntityName
      isHidden = formField.isHidden or
                 formField.isPrimaryKey or
                 isPolyHidden or
                 isRestrictedByPrefix

      key = @props.key
      isSingleField = @props.isSingleField
      isReflection = @state.isReflection
      fieldCellStyle = @styles.fieldInputCell
      captionCellStyle = @styles.fieldCaptionCell
      rowStyle = @styles.hiddenFieldRow if isHidden

      # Если формируется строка не для простого поля (а для содержимого внутренней
      #  связки), то задаются доп. стили для ячейки заголовка и для строки.
      if isReflection or isHasResponsiveContent
         captionCellStyle =
            @computeStyles captionCellStyle,
                           @styles.unionFieldsCaptionCell
         fieldCellStyle =
            @computeStyles fieldCellStyle,
                           @styles.reflectionContentCell,
                           isHasResponsiveContent and @styles.responsiveContentCell
         rowStyle = @computeStyles rowStyle, @styles.unionFieldsRow

      caption: fieldCaption
      rowStyle: rowStyle
      captionCellStyle: captionCellStyle
      fieldCellStyle: fieldCellStyle

   ###*
   * Функция получения параметров связи из параметров связки поля
   *
   * @param {Object} componentProps - свойства компонента. Если не заданы, беруться
   *                                  @props.
   * @return {Object} - парметры поля. Вид
   *     {Object} relation       - параметры связи.
   *     {Object} uploadParams   - параметры поля загрузки файла.
   *     {Boolean} isPolymorphic - признак полиморфной связи.
   *     {Boolean} isReflection  - признак поля-связки
   *     {Boolean} isRelation    - признак поля с параметрами для поля выбора.
   *     {Boolean} isUploader    - признак поля загрузки файла.
   *     {Boolean} isHasRequestingParams - признак наличия параметров для построения поля выбора.
   *     {Boolean} isRestrictedByPrefix  - признак запрета поля по префиксу(поле не строится).
   ###
   _getInitFieldState: (componentProps) ->
      componentProps ||= @props
      fieldParams = componentProps.field
      fieldMetadata = fieldParams.metadata
      uploadParams = fieldParams.uploadParams
      reflection = fieldParams.reflection
      isHasRequestingParams = @_isHasDictionaryRequestingParams(reflection)
      instanceReflection = undefined
      isPolymorphic = false

      if reflection? and !_.isEmpty(reflection)
         instanceReflection = reflection.instance
         isPolymorphic = reflection.isPolymorphic

         if isPolymorphic
            polyEntityName = @_getPolymorphicEntityName reflection.name

      instanceReadingParams =
         if instanceReflection? and !_.isEmpty(instanceReflection)
            instanceReflection.readingParams

      instanceRelation =
         if instanceReadingParams?
            instanceReadingParams.relation

      isHasInstanceRelation = instanceRelation? and !_.isEmpty(instanceRelation)


      # Получим метаданные.
      relationMetadata =
         if isHasInstanceRelation
            metadataObj = {}
            for relName, rel of instanceRelation
               if rel.metadata?
                  relMetadata = rel.metadata
                  metadataObj[relName] = rel.metadata

            if isPolymorphic
               metadataObj
            else
               relMetadata

      relation: instanceRelation
      metadata:
         relation: relationMetadata
         field: fieldMetadata
      uploadParams: uploadParams
      polyEntityName: polyEntityName
      isPolymorphic: isPolymorphic
      isReflection: isHasInstanceRelation and !isHasRequestingParams
      isRestrictedByPrefix: @_isRestrictByPrefix(fieldParams.name)
      isHasRequestingParams: isHasRequestingParams
      isUploader: uploadParams? and !_.isEmpty(uploadParams)
      isRelation: fieldParams.hasOwnProperty @_ENTITY_CAPTION_KEY

   ###*
   * Функция получения параметров рендера для поля формы. В зависимости от того
   *  является ли данное поле полем выбора экземпляра или обычным полем ввода
   *  пробует взять параметры рендера по различным параметрам.
   *
   * @param {Object} field - параметры поля.
   * @return {Object, undefined}
   ###
   _getReflectionRenderParams: (field) ->
      reflectionRenderParams = @props.immutable.reflectionRenderParams
      isModelReflection = field.reflectionName?

      if reflectionRenderParams?
         if isModelReflection
            reflectionRenderParams[field.reflectionName]
         else
            reflectionRenderParams[field.name]

   ###*
   * Функция получения дополнительных параметров валидации для поля.
   *
   * @return {Object}
   ###
   _getValidationParams: ->
      field = @props.field
      fieldName = field.name
      additionalParams = @props.immutable.additionalValidationParams
      isReflectionField = @_isReflectionField()
      validatorFlags = @_getValidatorFlags()
      isHasValidators = validatorFlags.isHasValidators
      isHasPresenceValidator = validatorFlags.isHasPresence
      chain = @props.chain
      chainLength = chain.length

      # Зададим начальный параметр - для валидации: Если это поля связанной
      #  сущности и у него есть валидатор присутствия(обязательности),
      #  то установим отрицательный флаг, т.к. все поля в связанных сущностях
      #  не должны быть обязательными, если иное не задано через параметры.
      validationParams = if isReflectionField and isHasPresenceValidator
                            disablePresence: true
                         else
                            {}

      # Если заданы дополнительные параметры валидации формы, то формируем
      #  параметры валидации для данного поля
      if additionalParams? and !_.isEmpty(additionalParams)
         customValidators = additionalParams.customValidators

         # Если заданы параметры произвольных валидаторов, пробуем найти среди
         #  них те которые заданы для данного поля.
         if customValidators? and !_.isEmpty customValidators

            # Так как произвольные валидаторы задаются при помощи массива параметров
            #  ищем среди них те, которые могли быть заданы для данного поля:
            # Если это поля связанной сущности - ищем по имени поля и по цепи связок.
            # Иначе - ищем по имени связки и по пустой цепи.
            vIndex =
               if isReflectionField
                  checkedChain = chain.map (element) -> element.reflection

                  _.findIndex(customValidators,
                              ((el) ->
                                 el.field is @name and
                                 _.isEqual(el.chain, checkedChain)
                              ).bind(field)
                             )
               else
                  _.findIndex(customValidators,
                              chain: null
                              field: fieldName)

            # Если индекс произвольного валидатора был найден - добавим
            if vIndex >= 0
               validationParams.customHandler = customValidators[vIndex].handler

         # Если для поля задан валидатор присутствия(обязательности) и это поле
         #  связанной сущности - проверим задано ли разрешение на данный тип валидации
         #  т.к. по-умолчанию валидация присутсвия в связанных сущностях должна
         #  быть отключена.
         if isHasPresenceValidator and isReflectionField
            allowedPresenceForExternal = additionalParams.allowedPresenceForExternal
            lastRelation = _.last(chain)
            reflectionName = lastRelation.reflection
            isHasParamsForThisRefl =
               allowedPresenceForExternal.hasOwnProperty(reflectionName)

            # Если задан параметр разрешающий валидацию присутствия для внешних
            #  и среди них заданы параметры для сущности текущего поля -
            #  проверяем совпадения цепи связок(если есть).
            if allowedPresenceForExternal? and isHasParamsForThisRefl

               allowedParams = allowedPresenceForExternal[reflectionName]

               # Если цепь связки содержит не один элемент (вложенная связка)-
               #  осуществим проверку на совпадение цепей связок,
               #  если цепи совпадают - значит для данного поля разрешена проверка
               #  на присутствие.
               # Иначе, если параметров не задано, значит валидация присутсвия
               #  разрешена (раз находимся в этом блоке).
               if chainLength > 1
                  allowedChain = allowedParams.chain if allowedParams?
                  chainToReflection = _.take(chain, (chainLength - 1))
                                       .map (el) -> el.reflection

                  if _.isEqual(allowedChain, chainToReflection)
                     validationParams.disablePresence = false
               else
                  validationParams.disablePresence = false

      validationParams

   ###*
   * Функция получения флагов валидаторов поля.
   *
   * @return {Object} - флаги валидаторов. Вид:
   *     {Boolean} isHasValidators - флаг наличия валидаторов.
   *     {Boolean} isHasPresence   - флаг наличия валидатора присутствия
   *                                (обязательности).
   ###
   _getValidatorFlags: ->
      field = @props.field
      validators = field.validators
      presenceTypeObj = @_PRESENCE_VALIDATOR_TYPE_OBJ
      isHasValidators = validators? and !_.isEmpty(validators)
      isHasPresence = false

      if isHasValidators
         isHasPresence = _.findIndex(validators, presenceTypeObj) >= 0

      isHasValidators: isHasValidators
      isHasPresence: isHasPresence


   ###*
   * Функция получения параметров словаря по имени связки, если таковые были
   *  заданы в параметрах.
   *
   * @param {Object} field - параметры поля.
   * @param {Boolean} isRelation - флаг поля-связки.
   * @return {Object, undefined}
   ###
   _getDictionaryParams: (field, isRelation) ->
      reflectionParams = @props.immutable.reflectionControlParams
      reflectionName =
         if isRelation
            field.reflectionName
         else
            field.name

      if reflectionParams?
         for _modelName, reflectionParam of reflectionParams
            if reflectionParam.reflectionName is reflectionName
               dictionaryParams = reflectionParam.dictionaryParams
               break

      dictionaryParams

   # ###*
   # * Функция получения массива-иерархии цепи связок для параметров модели моля формы.
   # *
   # * @param {Array<Object>} chain - исходный массив.
   # * @return {Array<Object>} - преобразованный массив.
   # ###
   # _getProcessedReflectionChain: (chain) ->
   #    chain.map (element) ->
   #       index: element.instanceNumber
   #       recordKey: element.recordKey
   #       isCollection: element.isCollection
   #       reflection: element.reflection

   ###*
   * Функция получения имени выбранной полиморфной сущности.
   *
   * @param {String} reflectionName - имя связки.
   * @retrun {String} - имя сущности.
   ###
   _getPolymorphicEntityName: (reflectionName)->
      immutable = @props.immutable
      polymorphicStates = immutable.polymorphicStates
      reflectionType =
         [
            reflectionName
            immutable.suffixes.polySelector
         ].join immutable.chars.underscore

      for polyTypeName, polyState of polymorphicStates
         return polyState if polyTypeName is reflectionType

   ###*
   * Функция-предикат для проверки наличия параметров для запроса справочника
   *  поля.
   *
   * @param {Object} reflection - параметры связки.
   * @return {Boolean} - флаг наличия параметров.
   ###
   _isHasDictionaryRequestingParams: (reflection) ->
      dictionaryReflection = undefined
      isHasRequestingParams = false

      if reflection? and !_.isEmpty(reflection)
         dictionaryReflection = reflection.dictionary

      if dictionaryReflection? and !_.isEmpty dictionaryReflection
         isHasRequestingParams =
            dictionaryReflection.requestingParams? and
            !_.isEmpty(dictionaryReflection.requestingParams)

      isHasRequestingParams

   ###*
   * Функция-предикат для проверки является ли поле полем связанной сущности.
   *  (присутствуют параметры связанности).
   *
   * @return {Boolean}
   ###
   _isReflectionField: ->
      chain = @props.chain

      chain? and !_.isEmpty(chain)

   ###*
   * Функция-предикат для определения ограничивается ли поле по префиксу
   *  (ограничивается - не генерируется).
   *
   * @param {String} fieldName - имя поля.
   * @return {Boolean}
   ###
   _isRestrictByPrefix: (fieldName) ->
      # Если заданы ограничения по префиксам полей, перебираем ограничения и ищем
      #  заданы ли необходимые значения словарей для прохождения ограничения. Если
      #  заданые значения не были найдены - значит поле ограничивается (не генерируется).
      # Иначе - поле не ограничивается по префиксу.
      if @_isHasPrefixAnchors() and fieldName?
         filedNamePrefix = fieldName.split(@props.immutable.chars.underscore)[0]
         fieldConstraints = @props.immutable.fieldConstraints
         fieldPrefixAnchor = fieldConstraints.prefixAnchors[filedNamePrefix]

         # Если по данному полю есть ограничение по префиксу.
         if fieldPrefixAnchor? and !_.isEmpty fieldPrefixAnchor
            dictionariesSelectedValues = @props.immutable.dictionariesSelectedValues

            # Если выбраны какие-либо значения в словарях.
            if dictionariesSelectedValues? and !_.isEmpty dictionariesSelectedValues

               # Перебираем все значения в параметрах ограничения по префиксу поля.
               for dictName, dictValues of fieldPrefixAnchor
                  dictionary = dictionariesSelectedValues[dictName]

                  # Если словарь, по которому задано ограничение задан(выбраны значения).
                  if dictionary?
                     # Перебираем все значения среди значений ограничения по словарю.
                     # Возвращаем false (поле не ограничивается), если нашли искомое
                     #  значение в словаре.
                     if _.isArray dictValues
                        for value in dictValues
                           return false if value in dictionary
                     else
                        return false if dictValues in dictionary
            true
         else
            false
      else
         false

   ###*
   * Функция-предикат для определения были ли заданы ограничительные параметры
   *  на префиксы полей.
   *
   * @return {Boolean}
   ###
   _isHasPrefixAnchors: ->
      if @_isHasFieldsConstraints()
         anchors = @props.immutable.fieldConstraints.prefixAnchors

         return anchors? and !_.isEmpty anchors

      false

   ###*
   * Функция-предикат для определения были ли заданы ограничительные параметры
   *  на поля.
   *
   * @return {Boolean}
   ###
   _isHasFieldsConstraints: ->
      fieldConstraints = @props.immutable.fieldConstraints

      fieldConstraints? and !_.isEmpty fieldConstraints

   ###*
   * Функция проверки и получения внешних сущностей. Проверяет переданный объект
   *  внешних сущностей на наличие. Если передан undefined или пустой объект -
   *  возвращает false. Это нужно чтобы функция формирования содержимого формы
   *  _getFormContent распознавала когда не нужно брать внешние сущности по-умолчанию.
   *
   * @param {Object} externalEntities - хэш с параметрами внешних сущностей.
   * @return {Object, Boolean} - или хэш или false
   ###
   _checkAndGetExternalEntities: (externalEntities) ->
      if externalEntities? and !_.isEmpty(externalEntities)
         return externalEntities
      false

   ###*
   * Функция обработки поведения "реагируемого" поля. Если выбранный объект задан
   *  и для компонента заданы параметры "реагируемого" поля - отправляет запрос
   *  на получение содержимого "реагируемого" поля. После успешного получения ответа
   *  сохраняет полученный ответ в состояние компонента. Если выбранное в поле значение
   *  пустое - сбрасывает реагируемый контент в состоянии компонента.
   *
   * @param {String, Number} selectedItem - выбранное значение.
   * @return
   ###
   _processResponsive: (selectedItem) ->
      fieldParams = @props.field
      if selectedItem?
         responsiveParams = fieldParams.responsiveParams

         if responsiveParams?
            preparePathPattern = responsiveParams.preparePathPattern

            @setState isResponsiveContentRequested: true

            if preparePathPattern?
               prepareEndpoint = format(preparePathPattern, [selectedItem])

               request.get(prepareEndpoint)
                      .set(@_REQUEST_ACCEPT_KEY, @_JSON_ACCEPT)
                      .end ((error, res) ->
                         if res.status is @_SUCCESS_STATUS_CODE
                            json = JSON.parse(res.text)
                            @setState
                              isResponsiveContentRequested: false
                              responsiveContent: json
                       ).bind(this)
      else
         @setState
            responsiveContent: null
            isResponsiveContentRequested: false


###* Компонент: элемент манипуляции существующими экземплярами связанных записей.
*  Представляет собой произвольную область, открываемую в режиме "дока",
*  содержащую таблицу данных с заполненными экземплярами и позволяющую производить
*  операции манипуляции с ними. Операции манипуляции вызывают добавление доп.
*  полей на динамическую форму в случае редактирования или удаления существующих
*  экземпляров.
*
* @props
*     {String} model                  - имя модели
*     {Object} fields                 - параметры полей.
*     {Object} externalEntities       - параметры внешних сущностей.
*     {Object} implementationStore    - хранилище стандартных реализаций.
*     {Object} denyToEditReflections  - запрещенные для редактирования сущности.
*     {Object} externalEntitiesParams - параметры внешних связок.
*     {Object} fieldConstraints       - ограничения полей.
*     {Object} sectionConstraints     - параметры ограничений секций.
*     {Object} fieldsOrder            - порядок полей.
*     {Object} sectionsOrder          - порядок секций
*     {Object} reflectionParams       -
*     {Boolean} isUseImplementation   - флаг использования хралища реализаций.
*     {Boolean} isMergeImplementation - флаг слияния "реализуемых"" свойств.
*     {String, Number} identifier     - идентификатор экземпляра, по которому происходит
*                                       обновление.
*     {String, Number} rootIdentifier - идентификатор корневого экземпляра, по которому
*                                       происходит обновление.
*     {String} ignoredFieldName       - "игнорируемое" поле ввода.
*     {Array<Object>} chain           - набор параметров связок.
*     {Object} chars                  - набор используемых символов.
*     {React-Element-ref} organizer   - ссылка на элемент органайзера операций.
*     {Function} onHide               - обработчик на скрытие контейнера компонента.
*     {Function} onShow               - обработчик на показ контейнера компонента.
* @state
*     {Boolean} isChainSame - флаг того, что было проброшена та же цепь что и ранее
*     {Boolean} isAreaShown - флаг того, что произвольная область была показана.
###
DynamicFormInstancesController = React.createClass

   # @const {Object} - параметры для произвольной области.
   _AREA_PARAMS:
      layoutAnchor: 'window'
      animation: 'slideLeft'
      isTriggerOnSameTarget: false
      isHasBorder: false
      isHasShadow: true
      isCloseOnBlur: false
      isHasCloseButton: true
      dockModeParams:
         position: 'right'

   # @const {Object} - параметры для таблицы данных.
   _DATA_TABLE_PARAMS:
      enableCreate: false
      enableFilter: false
      enablePerPageSelector: false
      searchPlaceholder: 'Найти'
      isHasStripFarming: false
      isFitToContainer: true
      isPageSelectorInLinkMode: true
      isImplementationHigherPriority: true
      dataManipulationParams:
         enableClientConstruct: true
      fluxParams:
         isUseServiceInfrastructure: true
      dimension:
         dataContainer:
            width:
               min: 700
               max: 1000
            height:
               max: 750

   styles:
      dataTableCommon:
         padding: _COMMON_PADDING
         paddingTop: 0
      areaHeader:
         padding: 2
         backgroundColor: _COLORS.hierarchy3
         textAlign: 'left'
      closeButton:
         color: _COLORS.light

   getInitialState: ->
      isAreaShown: false
      isChainSame: false

   componentWillReceiveProps: (nextProps) ->
      nextChain = nextProps.chain
      currentChain = @props.chain
      isChainSame = _.isEqual(currentChain, nextChain)

      @setState isChainSame: isChainSame

   render: ->
      `(
          <ArbitraryArea {...this._getAreaParams()}
                         content={this._getContent()}
                         target={this._getAreaTarget()}
                         onHide={this._onHideArea}
                         onShow={this._onShowArea}
                         onKeyDown={this._onKeyDownArea}
                         onKeyUp={this._onKeyUpArea}
                         onKeyPress={this._onKeyPressArea}
                      />
       )`

   ###*
   * Функция получения содержимого области редактирования связанных экземпляров.
   *  получает таблицу данных с заранее подготовленными данными.
   *
   * @return {React-Element}
   ###
   _getContent: ->
      DataTable = require('components/core/data_table')
      clonedChain = @props.chain[..]
      styleAddition =
         common: @styles.dataTableCommon
      instanceID = @props.rootIdentifier or @props.identifier

      modelParams =
         name: @props.model
         relations: clonedChain

      #initData={this._getPreparedInitData()}
      #dataManipulationParams={this._getPreparedManipulationParams()}
      #this._getPreparedModelRelations()

      `(
         <DataTable {...this._prepareDataTableParams()}
                    implementationStore={this.props.implementationStore}
                    isUseImplementation={this.props.isUseImplementation}
                    isMergeImplementation={this.props.isMergeImplementation}
                    modelParams={modelParams}
                    instanceID={instanceID}
                    styleAddition={styleAddition}
                    operationsOrganizer={this.props.organizer}
                 />
      )`

   ###*
   * Функция получения целевого узла для показа произвольной области. Если область
   *  уже показана и была передана та же цепочка что и текущая, то области задасться
   *  цель для скрытия.
   *
   * @return {React-Element, Boolean}
   ###
   _getAreaTarget: ->
      #currentTarget =
      isAreaShown = @state.isAreaShown
      isChainSame = @state.isChainSame
      isTriggered = @props.isTriggered

      if isAreaShown and isChainSame
         false
      else
         @props.target

   ###*
   * Функция получения параметров для произвольной области.
   *
   * @return {Object} - параметры
   ###
   _getAreaParams: ->
      areaParams = @_AREA_PARAMS
      chars = @props.chars
      spaceChar = chars.space
      slashChar = chars.slash
      chain = @props.chain
      chainCaptions =
         chain.map (element) ->
            element.caption
      joinerString = [spaceChar, spaceChar].join slashChar

      areaParams.captionParams =
         text: chainCaptions.join(joinerString)
         styleAddition:
            common: @styles.areaHeader
            closeButton: @styles.closeButton

      areaParams

   # TODO: функция, необходимая при централизованном подходе работе с записями
   #       но для реализации был выбран другой подход(унитарный), поэтому эта
   #       функция пока не нужна(может позже удалить надо).
   # ###*
   # * Функция подготовки инициализационных данных для таблицы данных.
   # *
   # * @return {Object} - хэш инициализационных параметров для таблицы данных. Формат
   # *                    соответсвует ожидаемому параметру DataTable.props.initialData.
   # ###
   # _getPreparedInitData: ->
   #    fields = @props.fields
   #    ignoredFieldName = @props.ignoredFieldName
   #    chain = @props.chain
   #    reflectionParams = chain[chain.length - 1]
   #    reflectionName = reflectionParams.reflection
   #    keyValues = {}
   #    preparedRecords = []



   #    # Подготавливаем хэш по ключам, содержащий в себе значение каждого поля:
   #    #  key1:
   #    #     field1: value1
   #    #     field2: value2
   #    #  key2:
   #    #     ...
   #    for fieldName, fieldParams of fields
   #       fieldValue = fieldParams.value
   #       enumValues = fieldParams.enumValues
   #       isEnum = enumValues? and !$.isEmptyObject enumValues

   #       # Обрабатываем поле, только если оно не игнорируемое.
   #       if fieldName isnt ignoredFieldName
   #          for key, value of fieldValue
   #             definedValue = if isEnum
   #                               enumValues[value]
   #                            else
   #                               value

   #             # Если по данному ключу ещё не задавались значения - создадим пустой хэш.
   #             unless keyValues[key]?
   #                keyValues[key] = {}

   #             keyValues[key][fieldName] = definedValue

   #    # Из заранее подготовленного хэша значений по ключам создаем
   #    #  массив параметров записей (в формате компонента таблицы данных).
   #    for key, values of keyValues
   #       clonedFields = $.extend(true, {}, fields)
   #       record = {}
   #       recordFields = {}

   #       for fieldName, clonedField of clonedFields

   #          if fieldName isnt ignoredFieldName
   #             recordFields[fieldName] =
   #                type: clonedField.type
   #                caption: clonedField.caption
   #                value: values[fieldName]

   #       record =
   #          fields: recordFields
   #          key: key
   #          model: reflectionName
   #          reflections: null       # TODO: возможно необходимо реализовать формирование и назначение связки.

   #       preparedRecords.push record

   #    entityParams:
   #       fieldParams: fields
   #    records: preparedRecords

   ###* TODO: пока что бесполезная функция, т.к. просто копирует цепь. Возможно
   *          в дальнейшем потребуется более сложная логика.
   * Функция получения связок модели, для считывания записей из связанных сущностей.
   *  Удаляет лишние (для API) элементы из элементов массива и возвращает массив
   *  элементов цепи связок с необходимыми элементами.
   *
   * @return {Array<Object>}
   ###
   _getPreparedModelRelations: ->
      chain = @props.chain[..]
      instancesController = this

      chain.map (element, idx) ->
         recordKey: element.recordKey
         index: element.index
         caption: element.caption
         reflection: element.reflection
         primaryKey: element.primaryKey
         polymorphicEntityName: element.polymorphicEntityName
         polymorphicReverse: element.polymorphicReverse
         isReverseMultiple: element.isReverseMultiple
         isCollection: element.isCollection

   ###*
   * Функция подготовки параметров для предустановленных параметров манипуляции.
   *  данными (параметрами для форм).
   *
   * @return {Object} - параметры для манипуляции данными.
   ###
   _getPreparedManipulationParams: ->
      fields = @props.fields
      ignoredFieldName = @props.ignoredFieldName

      # Если задано имя игнорируемого поля - найдем его среди набора параметров
      #  полей и установим флаг скрытого поля.
      if ignoredFieldName?
         for fieldName, fieldParams of fields

            if fieldName is ignoredFieldName
               fieldParams.isHidden = true
               fields[fieldName] = fieldParams
               break

      presetParams:
         fields: fields
         externalEntities: @props.externalEntities

   ###*
   * Обработчик на событие показа произвольной области. Устанавливает флаг показанности
   *  области.
   *
   * @return
   ###
   _onShowArea: ->
      @setState isAreaShown: true

      onShowAreaHandler = @props.onShow
      onShowAreaHandler() if onShowAreaHandler?

   ###*
   * Обработчик на событие скрытие произвольной области. Сбрасывает флаг показанности
   *  области. Вызывает обработчик, заданный через свойства.
   *
   * @return
   ###
   _onHideArea: ->
      @setState isAreaShown: false

      onHideAreaHandler = @props.onHide
      onHideAreaHandler() if onHideAreaHandler?


   ###*
   * Обработчик события на нажатие клавиши с привязкой на напечатанный символ.
   *  Прерывает проброс события.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onKeyPressArea: (event) ->
      event.stopPropagation()

   ###*
   * Обработчик события на нажатие клавиши с привязкой на клавишу на клавиатуре.
   *  Прерывает проброс события.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onKeyDownArea: (event) ->
      event.stopPropagation()

      # Если была нажата клавиша 'Enter' - отменим поведение по-умолчанию,
      #  для того, чтобы на сработало событие 'submit' на форме.
      if event.keyCode is 13
         event.preventDefault()

   ###*
   * Обработчик события на отпускание нажатой клавиши с привязкой на клавишу на
   *  клавиатуре. Прерывает проброс события.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onKeyUpArea: (event) ->
      event.stopPropagation()

   ###*
   * Функция подготовки параметров для таблицы данных контроллера экземпляров.
   *  За основу берутся параметры по-умолчанию и для параметров манипуляции данными
   *  делается слияние параметров, заданых через свойства и параметрами
   *  манипуляции по-умолчанию.
   *
   * @return {Object}
   ###
   _prepareDataTableParams: ->
      resultDataTableParams = _.cloneDeep(@_DATA_TABLE_PARAMS)
      dataManipulationParams = _.cloneDeep(@props.dataManipulationParams)

      resultDataTableParams.dataManipulationParams =
         _.merge(dataManipulationParams,
                 resultDataTableParams.dataManipulationParams)

      resultDataTableParams

module.exports = DynamicForm
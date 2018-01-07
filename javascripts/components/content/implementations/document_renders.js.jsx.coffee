###* @jsx React.DOM ###

###* Зависимости: модули
* lodash           - модуль служебных операций.
###
StylesMixin = require('components/mixins/styles')
keyMirror = require('keymirror')
_ = require('lodash')

###* Зависимости: компоненты
* Button            - кнопка.
###
Button = require('components/core/button')

###* Константы.
* _COLORS         - цвета
* _COMMON_PADDING - значение отступа
###
_COLORS = StylesMixin.constants.color
_COMMON_PADDING = StylesMixin.constants.commonPadding

###*
* Модуль рендеров для отображения сущностей документов (с возможностью скачивания).
###
DocumentRenders =

   # @const {Object} - цепи считывания параметров из вложенного хэша-записи.
   _DOC_REFLECTION_CHAINS:
      attachment: ['reflections', 'document_file', 'value', 'file_links']

   # @const {Object} - ключи для считывания параметров вложения.
   _DOC_ATTACHMENT_KEYS: keyMirror(
      file: null
      thumb: null
   )

   # @const {Object} - параметры для кнопки скачивания вложения.
   _DOC_ATTACHMENT_BUTTON_PARAMS:
      isLink: true
      icon: 'download'
      title: 'скачать'

   # @const {Object} - надпись при отсутствующем вложении.
   _DOC_NO_ATTACHMENT_PLACEHOLDER: 'вложений нет'

   docStyles:
      attachmentColumn:
         verticalAlign: 'middle'
         textAlign: 'center'
         color: _COLORS.hierarchy3
         width: 100
      attachmentContainer:
         display: 'flex'
         #justifyContent: 'center'
         alignItems: 'center'
      typeColumn:
         width: 220
      idColumn:
         width: 30
      thumbImage:
         maxHeight: 50
         maxWidth: 60
      downloadButton:
         fontSize: 20

   ###*
   * Функция рендера ячейки для отображения вложения -
   *  миниатюры файла и ссылки на скачивание.
   *
   * @param {Object} _rowRef - ссылка на строку таблицы.
   * @param {Object} record  - запись по строке.
   * @return {React-element, String}
   ###
   _onRenderAttachmentCell: (_rowRef, record) ->
      readChains = @_DOC_REFLECTION_CHAINS
      attachmentKeys = @_DOC_ATTACHMENT_KEYS
      fileLinkKey = attachmentKeys.file
      thumbLinkKey = attachmentKeys.thumb
      fileLinks = _.get(record, readChains.attachment)
      styles = @docStyles

      if fileLinks? and !_.isEmpty(fileLinks) and _.has(fileLinks, fileLinkKey)
         thumbLink = fileLinks[thumbLinkKey]
         fileLink = fileLinks[fileLinkKey]

         thumbImage =
            if thumbLink?
               `(
                  <img style={styles.thumbImage}
                       src={fileLinks.thumb}
                       data-file-link={fileLink}
                       onClick={this._onClickThumb} />
                )`

         `(
             <div style={styles.attachmentContainer}>
               {thumbImage}
               <Button {...this._DOC_ATTACHMENT_BUTTON_PARAMS}
                       styleAddition={styles.downloadButton}
                       onClick={this._onClickDownloadAttachment}
                       value={fileLink}
                     />
             </div>
          )`
      else
         @_DOC_NO_ATTACHMENT_PLACEHOLDER

   ###*
   * Обработчик клика по иконке миниатюры - открывает файл в новом окне/вкладке.
   *
   * @param {Object} event - объект события.
   * @return
   ###
   _onClickThumb: (event) ->
      event.stopPropagation()
      thumbImage = event.target

      if thumbImage?
         fileLink = thumbImage.dataset.fileLink

         if fileLink?
            window.open(fileLink, '_blank')

   ###*
   * Обработчик клика на кнопку скачивания вложения документа.
   *
   * @param {String} fileLink - ссылка на файл в файловом хранилище.
   * @param {Object} event    - объект события.
   * @return
   ###
   _onClickDownloadAttachment: (fileLink, event) ->
      event.stopPropagation()

      if fileLink?
         document.location.href = fileLink

module.exports = DocumentRenders

###*
* Модуль для хранения стилевых констант компонентов
###

constants =
   color:
      main: '#38A94B'
      mainDark: '#24562D'
      secondary: '#8CE09E' #'#C6E9AF'
      third: '#C6E9AF'

      hierarchy1: '#000000'
      hierarchy2: '#666666'
      hierarchy3: '#BDBDBD' #'#9A9A9A'
      hierarchy4: '#E6E5E5'

      light: '#FFFFFF'
      dark: '#000000'

      alert: '#FF4D4D'
      alertLight: '#FFb3b3'
      alertDark: '#B30000'

      exclamation: '#FF8E46'
      exclamationLight: '#FFCDAD'
      exclamationDark: '#AD4200'

      success: '#65C87A'
      successLight: '#B1E3BC'
      successDark: '#276e37'

      info: '#7C9BED'
      infoLight: '#D7E0FA'
      infoDark: '#1A44b8'

      highlight1: '#FF3000'
      highlight2: '#F8CCAB'
      link1: '#073E84'
      opacityBackingLight: 'rgba(245, 245, 245, 0.5)'
      transparent: 'transparent'
   commonPadding: 5
   commonBorderRadius: 5
   iconContainerWidth: 10
   userCabinet:
      headerHeight: 37
      sideMenuWidth: 250
      headerHeight: 50
      contentMaxWidth: 1248

mixins =
   blockToCenter:
      width: 1248
      margin: '0 auto'
   blockBorder:
      borderColor: constants.color.hierarchy3
      borderStyle: 'solid'
      borderWidth: 1
      borderRadius: constants.commonBorderRadius - 2
   inputBorder:
      borderColor: constants.color.hierarchy3
      borderStyle: 'solid'
      borderWidth: 1
      borderRadius: constants.commonBorderRadius
   link:
      cursor: 'pointer'
      color: constants.color.link1
      textDecoration: 'underline'

styles =
   constants: constants
   mixins: mixins

module.exports = styles
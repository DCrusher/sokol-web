/**
 * Файл-манифест для загрузки компонентов React для
 * которых требуется не требуется серверный рендеринг
 * и которые работают с объектами DOM или другими браузерными
 */
//= require react
//= require react_ujs
//= require ./components_serverside.js

UserCabinet = require('./components/user/user_cabinet');
window.componentsRoot = 'components/'
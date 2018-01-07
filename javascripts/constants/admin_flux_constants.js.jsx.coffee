
###* Зависимости: модули
* keyMirror - модуль для генерации "зеркальных хэшей"
###
keyMirror = require('keymirror')

# Корень ресурса (не работает нормально с серверным рендерингом)
APIRoot = [
            location.protocol
            '//'
            location.host
            '/admin'
          ].join('')
###*
* Модуль для хранения констант flux для административной части сайта
###
module.exports =
   APIEndpoints:
      ROOT:                      APIRoot
      USERS_ROOT:                [APIRoot, 'users'].join('/')
      USERS:                     [APIRoot, 'users.json'].join('/')
      NEW_USER:                  [APIRoot, 'users', 'new.json',].join('/')
      CHANGE_PASSWORD_USER:      [APIRoot, 'users', '{0}', 'change_password.json'].join('/')
      BLOCK_USER:                [APIRoot, 'users', '{0}', 'block.json'].join('/')
      ASSIGNED_WORKPLACES:       [APIRoot, 'users', '{0}', 'assigned_workplaces.json'].join('/')
      ASSIGN_WORKPLACES:         [APIRoot, 'users', '{0}', 'assign_workplaces.json'].join('/')
      GROUP_DESTROY_USERS:       [APIRoot, 'users', 'group_destroy.json'].join('/')
      GROUP_BLOCK_USERS:         [APIRoot, 'users', 'group_block.json'].join('/')

      WORKPLACES_ROOT:      [APIRoot, 'user_workplaces'].join('/')
      WORKPLACES:           [APIRoot, 'user_workplaces.json'].join('/')
      NEW_WORKPLACE:        [APIRoot, 'user_workplaces', 'new.json',].join('/')
      ASSIGNED_ACTIONS:     [APIRoot, 'user_workplaces', '{0}', 'assigned_actions.json'].join('/')
      ASSIGN_ACTIONS:       [APIRoot, 'user_workplaces', '{0}', 'assign_actions.json'].join('/')

      ACTIONS_ROOT:         [APIRoot, 'user_actions'].join('/')
      ACTIONS:              [APIRoot, 'user_actions.json'].join('/')
      NEW_ACTION:           [APIRoot, 'user_actions', 'new.json'].join('/')

      PROPERTY_TYPES_ROOT:  [APIRoot, 'dictionaries', 'property_types'].join('/')
      PROPERTY_TYPES:       [APIRoot, 'dictionaries', 'property_types.json'].join('/')
      NEW_PROPERTY_TYPES:   [APIRoot, 'dictionaries', 'property_types', 'new.json'].join('/')

      DOCUMENT_TYPES_ROOT:  [APIRoot, 'dictionaries', 'document_types'].join('/')
      DOCUMENT_TYPES:       [APIRoot, 'dictionaries', 'document_types.json'].join('/')
      NEW_DOCUMENT_TYPES:   [APIRoot, 'dictionaries', 'document_types', 'new.json'].join('/')

      OWNERSHIP_TYPES_ROOT: [APIRoot, 'dictionaries', 'ownership_types'].join('/')
      OWNERSHIP_TYPES:      [APIRoot, 'dictionaries', 'ownership_types.json'].join('/')
      NEW_OWNERSHIP_TYPES:  [APIRoot, 'dictionaries', 'ownership_types', 'new.json'].join('/')

      PROPERTY_PARAMETERS_ROOT:  [APIRoot, 'dictionaries', 'property_parameters'].join('/')
      PROPERTY_PARAMETERS:       [APIRoot, 'dictionaries', 'property_parameters.json'].join('/')
      NEW_PROPERTY_PARAMETERS:   [APIRoot, 'dictionaries', 'property_parameters', 'new.json'].join('/')

   StandardMessages:
      COMMON_ERROR: 'Что-то пошло не так, пожалуйста, попробуйте снова'
   PayloadSources: keyMirror(
      SERVER_ACTION: null
      VIEW_ACTION: null)
   ActionTypes:
      User: keyMirror(
         USERS_REQUEST: null
         USERS_RESPONSE: null
         GET_REQUEST: null
         GET_RESPONSE: null
         NEW_REQUEST: null
         NEW_RESPONSE: null
         CREATE_REQUEST: null
         CREATE_RESPONSE: null
         EDIT_REQUEST: null
         EDIT_RESPONSE: null
         DELETE_REQUEST: null
         DELETE_RESPONSE: null
         CHANGE_PASSWORD_REQUEST: null
         CHANGE_PASSWORD_RESPONSE: null
         BLOCK_REQUEST: null
         BLOCK_RESPONSE: null
         GROUP_DELETE_REQUEST: null
         GROUP_DELETE_RESPONSE: null
         GROUP_BLOCK_REQUEST: null
         GROUP_BLOCK_RESPONSE: null
         ASSIGNED_WORKPLACES_REQUEST: null
         ASSIGNED_WORKPLACES_RESPONSE: null
         ASSIGN_WORKPLACES_REQUEST: null
         ASSIGN_WORKPLACES_RESPONSE: null
      ),
      Workplace: keyMirror(
         WP_REQUEST: null
         WP_RESPONSE: null
         WP_GET_REQUEST: null
         WP_GET_RESPONSE: null
         WP_NEW_REQUEST: null
         WP_NEW_RESPONSE: null
         WP_CREATE_REQUEST: null
         WP_CREATE_RESPONSE: null
         WP_EDIT_REQUEST: null
         WP_EDIT_RESPONSE: null
         WP_DELETE_REQUEST: null
         WP_DELETE_RESPONSE: null
         ASSIGNED_ACTIONS_REQUEST: null
         ASSIGNED_ACTIONS_RESPONSE: null
         ASSIGN_ACTIONS_REQUEST: null
         ASSIGN_ACTIONS_RESPONSE: null
      ),
      Action: keyMirror(
         ACTIONS_REQUEST: null
         ACTIONS_RESPONSE: null
         ACTIONS_GET_REQUEST: null
         ACTIONS_GET_RESPONSE: null
         ACTIONS_NEW_REQUEST: null
         ACTIONS_NEW_RESPONSE: null
         ACTIONS_CREATE_REQUEST: null
         ACTIONS_CREATE_RESPONSE: null
         ACTIONS_EDIT_REQUEST: null
         ACTIONS_EDIT_RESPONSE: null
         ACTIONS_DELETE_REQUEST: null
         ACTIONS_DELETE_RESPONSE: null
      ),
      PropertyType: keyMirror(
         PROPERTY_TYPES_REQUEST: null
         PROPERTY_TYPES_RESPONSE: null
         PROPERTY_TYPES_GET_REQUEST: null
         PROPERTY_TYPES_GET_RESPONSE: null
         PROPERTY_TYPES_NEW_REQUEST: null
         PROPERTY_TYPES_NEW_RESPONSE: null
         PROPERTY_TYPES_CREATE_REQUEST: null
         PROPERTY_TYPES_CREATE_RESPONSE: null
         PROPERTY_TYPES_EDIT_REQUEST: null
         PROPERTY_TYPES_EDIT_RESPONSE: null
         PROPERTY_TYPES_DELETE_REQUEST: null
         PROPERTY_TYPES_DELETE_RESPONSE: null
      ),
      PropertyParameter: keyMirror(
         PROPERTY_PARAMETERS_REQUEST: null
         PROPERTY_PARAMETERS_RESPONSE: null
         PROPERTY_PARAMETER_GET_REQUEST: null
         PROPERTY_PARAMETER_GET_RESPONSE: null
         PROPERTY_PARAMETER_NEW_REQUEST: null
         PROPERTY_PARAMETER_NEW_RESPONSE: null
         PROPERTY_PARAMETER_CREATE_REQUEST: null
         PROPERTY_PARAMETER_CREATE_RESPONSE: null
         PROPERTY_PARAMETER_EDIT_REQUEST: null
         PROPERTY_PARAMETER_EDIT_RESPONSE: null
         PROPERTY_PARAMETER_DELETE_REQUEST: null
         PROPERTY_PARAMETER_DELETE_RESPONSE: null
      ),
      DocumentType: keyMirror(
         DOCUMENT_TYPES_REQUEST: null
         DOCUMENT_TYPES_RESPONSE: null
         DOCUMENT_TYPE_GET_REQUEST: null
         DOCUMENT_TYPE_GET_RESPONSE: null
         DOCUMENT_TYPE_NEW_REQUEST: null
         DOCUMENT_TYPE_NEW_RESPONSE: null
         DOCUMENT_TYPE_CREATE_REQUEST: null
         DOCUMENT_TYPE_CREATE_RESPONSE: null
         DOCUMENT_TYPE_EDIT_REQUEST: null
         DOCUMENT_TYPE_EDIT_RESPONSE: null
         DOCUMENT_TYPE_DELETE_REQUEST: null
         DOCUMENT_TYPE_DELETE_RESPONSE: null
      ),
      OwnershipType: keyMirror(
         OWNERSHIP_TYPES_REQUEST: null
         OWNERSHIP_TYPES_RESPONSE: null
         OWNERSHIP_TYPE_GET_REQUEST: null
         OWNERSHIP_TYPE_GET_RESPONSE: null
         OWNERSHIP_TYPE_NEW_REQUEST: null
         OWNERSHIP_TYPE_NEW_RESPONSE: null
         OWNERSHIP_TYPE_CREATE_REQUEST: null
         OWNERSHIP_TYPE_CREATE_RESPONSE: null
         OWNERSHIP_TYPE_EDIT_REQUEST: null
         OWNERSHIP_TYPE_EDIT_RESPONSE: null
         OWNERSHIP_TYPE_DELETE_REQUEST: null
         OWNERSHIP_TYPE_DELETE_RESPONSE: null
      )

   EventTypes:
      CHANGE_EVENT: 'change'

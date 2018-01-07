SokolFluxConstants = require('../constants/flux_constants')
Dispatcher = require('flux').Dispatcher
assign = require('object-assign')

PayloadSources = SokolFluxConstants.PayloadSources

SokolAppDispatcher = assign(new Dispatcher(),
   handleServerAction: (action) ->
      payload =
         source: PayloadSources.SERVER_ACTION
         action: action
      @dispatch payload
      return
   handleViewAction: (action) ->
      payload =
         source: PayloadSources.VIEW_ACTION
         action: action
      @dispatch payload
      return
)

module.exports = SokolAppDispatcher
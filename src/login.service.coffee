
module = angular.module 'SimpleAuth.Login', [
  'SimpleAuth.Constants'
  'SimpleAuth.Session'
  'SimpleAuth.UrlService'
]

module.factory 'saLogin', [
  '$http'
  '$rootScope'
  'saSession'
  'urlService'
  'AUTH_EVENTS'

  ($http, saSession, urlService, AUTH_EVENTS) ->

    service =
      # `login`
      # -------
      # Attempt to login to the system using the
      # given set of credentials
      # @param {Object.<string,string> credentials
      # @return {Promise}
      # @api {public}
      login: (credentials) ->
        promise = $http.post(urlService('login'), credentials)
        promise.then (res) ->
            $rootScope.$broadcast AUTH_EVENTS.loginSuccess, res

      # `logout`
      # --------
      # Log out any user that is currently logged in.
      # @return {Promise}
      # @api (public}
      logout: () ->
        promise = $http.post(urlService('logout'), {})
        promise.then (res) ->
          session.destroy() if @isAuthenticated()
          $rootScope.$broadcast AUTH_EVENTS.logoutSuccess, res

        return promise

      # `isAuthenticated`
      # -----------------
      # Do we currently have an authenticated user?
      # @return {boolean}
      # @api {public}
      isAuthenticated: () ->
        return saSession.isValid()

      # `isAuthorized`
      # --------------
      # Does the user have any of the given authorized roles?
      # @param {Array.<string>} roles
      # @api {public}
      isAuthorized: (roles) ->
        roles = [ roles ] if not angular.isArray(roles)

        return ( @isAuthenticated() and saSession.hasRole(roles) )

    return service
]
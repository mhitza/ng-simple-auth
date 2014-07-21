
module  = angular.module 'SimpleAuth.Session', [
  'SimpleAuth.Constants'
]

module.factory 'saSession', [
  '$rootScope'
  'AUTH_EVENTS'

  ($rootScope, AUTH_EVENTS) ->

    saSession = {

      # `create`
      # -------
      # Initialize the session object for a new user.
      # @param {string} token
      # @param {string} user
      # @return {saSession}
      # @api {public}
      create: (token, user) ->
        @destroy()
        # Order matters here because the @setUser function
        # calls the `userChange` event
        @setToken(token)
        @setUser(user)

        return @

      # `isValid`
      # ---------
      # Is this session object valid?
      # @return {boolean}
      # @api {public}
      isValid: () ->
        return angular.isObject(@user) and angular.isString(@token)

      # `hasRole`
      # ---------
      # @param {Array.<string>} roles
      # @return {boolean}
      # @api {public}
      hasRole: (roles) ->
        if not @isValid() then return false

        roles = [ roles ] if not angular.isArray(roles)

        return true for role in roles when @roles.indexOf(role) isnt -1

        return false

      # `destroy`
      # ---------
      # Invalidate this session object, in effect
      # log the current user out.
      # @return {boolean}
      # @api {public}
      destroy: () ->
        @token = null
        @user = $rootScope.user = null
        @roles = []
        return true

      # `setUser`
      # --------
      # Set the user object. Check to see if the incoming
      # user object is different than the current one.  If
      # it is different, then broadcast the user change event.
      # @param {Object} user
      # @return {saSession}
      # @api {public}
      setUser: (user) ->
        user = angular.fromJson(user) if angular.isString(user)

        if not angular.equals(user, @user)
          @user = $rootScope.user = user

          @roles = user.roles if angular.isArray(user?.roles)

          $rootScope.$broadcast AUTH_EVENTS.userChange, @user

        return @

      # `setToken`
      # ----------
      # Set the current access token if the incoming token
      # is different than the current one.
      # @param {string} token
      # @return {saSession}
      # @api {public}
      setToken: (token) ->
        @token = token if not angular.equals(token, @token)
        return @
    }
    return saSession
]
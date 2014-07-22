
module = angular.module 'SimpleAuth.UrlService', []


# `url_list`
# ----------
# A keyed list of URLs that are utilized in the SimpleAuth
# module.
# @type {Object.<string,string>}
# @api {private}
url_list =
  login: '/login'
  logout: '/logout'

class urlServiceProvider
  constructor: () ->


    # `urlService`
    # ------------
    # The service function that will return the
    # URL associated with the given key
    # @param {string} key
    # @return {string}
    # @api {public}
    @urlService = (name) ->
      if not url_list[name] then return null
      return url_list[name]

  # `setUrl`
  # --------
  # Setter function to allow user configuration of
  # the URLs
  # @param {string} key - url key
  # @param {string} url - url to associate with the given key.
  # @return {urlService}
  # @api {public}
  setUrl: (key, url) ->
    url_list[key] = url
    return @

  # `$get`
  # ------
  # Special provider service get function that
  # AngularJS uses to retrieve the properly configured
  # service object.
  # @return {urlService}
  # @api {private}
  $get: [ () -> return @urlService ]

module.provider 'urlService', new urlServiceProvider



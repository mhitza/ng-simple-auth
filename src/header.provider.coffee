# Response Header Service
# =======================
# This module provides a service that will return a
# given key from the given response headers.
module = angular.module 'SimpleAuth.HeaderService', []

class headerServiceProvider
  constructor: () ->
    # `header_map`
    # -------------
    # This object maintains a list of the data value key to
    # header name mappings.
    # @type {Object.<string,string>}
    # @api {private}
    @header_map =
      user: 'x-authenticate-user'
      token: 'x-access-token'

    # `headerService`
    # ---------------
    # Service function that will retrieve the value from the
    # given response headers for the given data value key.
    # @param {HTTPResponse} res
    # @param {string} data_key
    # @return {*}
    # @api {public}
    @headerService = (res, data_key) ->
      header_name = @header_map[data_key]
      return res.headers header_name

  # `setKey`
  # --------
  # Allow the user to configure which header names map to
  # their associated data values.
  # @param {string} value_name
  # @param {string} header_name
  # @return {headerService}
  # @api {public}
  setKey: (value_name, header_name) ->
    @header_map[value_name] = header_name
    return @
  # `$get`
  # ------
  # Special provider service get function that
  # AngularJS uses to retrieve the properly configured
  # service object.
  # @return {headerService}
  # @api {private}
  $get: () ->
    return @headerService

module.provider 'headerService', new headerServiceProvider()

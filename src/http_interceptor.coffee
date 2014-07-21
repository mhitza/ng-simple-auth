module  = angular.module 'SimpleAuth.AuthInterceptor', [
  'SimpleAuth.Session'
  'SimpleAuth.HeaderService'
]

module.factory 'saAuthResponseInterceptor', [
  'saSession'
  'headerService'

  (saSession, headerService) ->

    success = (res) ->
      token = headerService(res, 'token')
      user = headerService(res, 'user')

      saSession.setUser user if user
      saSession.setToken token if token

      return res

    return (promise) ->
      return promise.then(success)
]

module.config [
  '$httpProvider',

  ($httpProvider) ->
    $httpProvider.interceptors.push 'saAuthResponseInterceptor'
]
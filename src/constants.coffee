
module  = angular.module 'SimpleAuth.Constants', []

module.constant 'AUTH_EVENTS',
  loginSuccess: "event:auth-loginConfirmed"
  loginFailed: "event:auth-loginCancelled"
  logoutSuccess: "event:auth-logoutSuccess"
  notAuthenticated: "event:auth-loginRequired"
  notAuthorized: "event:auth-credentialsInsufficient"
  userChange: "event:session-userChange"

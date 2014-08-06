
module = angular.module 'SimpleAuth.HasPerm', [
  'SimpleAuth.Constants'
  'SimpleAuth.Session'
]

module.directive 'saHasPerm', [
  '$rootScope'
  'saSession'
  'AUTH_EVENTS'

  ($rootScope, saSession, AUTH_EVENTS) ->

    return {

      restrict: 'A'

      link: (scope, element, attrs) ->
        perms = attrs.saHasPerm.split ' '
        show  = angular.bind element, element.css, 'display', element.css('display')
        hide  = angular.bind element, element.css, 'display', 'none'
        toggle = () ->
          if saSession.hasRole perms then show() else hide()

        toggle()

        $rootScope.$on AUTH_EVENTS.userChange, toggle
    }
]

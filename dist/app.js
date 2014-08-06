(function() {
  var module;

  module = angular.module('SimpleAuth', ['SimpleAuth.Constants', 'SimpleAuth.Session', 'SimpleAuth.AuthInterceptor', 'SimpleAuth.HasPerm']);

}).call(this);

(function() {
  var module;

  module = angular.module('SimpleAuth.Constants', []);

  module.constant('AUTH_EVENTS', {
    loginSuccess: "event:auth-loginConfirmed",
    loginFailed: "event:auth-loginCancelled",
    logoutSuccess: "event:auth-logoutSuccess",
    notAuthenticated: "event:auth-loginRequired",
    notAuthorized: "event:auth-credentialsInsufficient",
    userChange: "event:session-userChange"
  });

}).call(this);

(function() {
  var module;

  module = angular.module('SimpleAuth.HasPerm', ['SimpleAuth.Constants', 'SimpleAuth.Session']);

  module.directive('saHasPerm', [
    '$rootScope', 'saSession', 'AUTH_EVENTS', function($rootScope, saSession, AUTH_EVENTS) {
      return {
        restrict: 'A',
        link: function(scope, element, attrs) {
          var hide, perms, show, toggle;
          perms = attrs.saHasPerm.split(' ');
          show = angular.bind(element, element.css, 'display', element.css('display'));
          hide = angular.bind(element, element.css, 'display', 'none');
          toggle = function() {
            if (saSession.hasRole(perms)) {
              return show();
            } else {
              return hide();
            }
          };
          toggle();
          return $rootScope.$on(AUTH_EVENTS.userChange, toggle);
        }
      };
    }
  ]);

}).call(this);

(function() {
  var headerServiceProvider, header_map, module;

  module = angular.module('SimpleAuth.HeaderService', []);

  header_map = {
    user: 'x-authenticate-user',
    token: 'x-access-token'
  };

  headerServiceProvider = (function() {
    function headerServiceProvider() {
      this.headerService = function(res, data_key) {
        var header_name;
        header_name = header_map[data_key];
        if (!header_name) {
          return null;
        }
        return res.headers(header_name);
      };
    }

    headerServiceProvider.prototype.setKey = function(value_name, header_name) {
      header_map[value_name] = header_name;
      return this;
    };

    headerServiceProvider.prototype.$get = function() {
      return this.headerService;
    };

    return headerServiceProvider;

  })();

  module.provider('headerService', new headerServiceProvider());

}).call(this);

(function() {
  var module;

  module = angular.module('SimpleAuth.AuthInterceptor', ['SimpleAuth.Session', 'SimpleAuth.HeaderService']);

  module.factory('saAuthResponseInterceptor', [
    'saSession', 'headerService', function(saSession, headerService) {
      var success;
      success = function(res) {
        var token, user;
        token = headerService(res, 'token');
        user = headerService(res, 'user');
        if (user) {
          saSession.setUser(user);
        }
        if (token) {
          saSession.setToken(token);
        }
        return res;
      };
      return function(promise) {
        return promise.then(success);
      };
    }
  ]);

  module.config([
    '$httpProvider', function($httpProvider) {
      return $httpProvider.interceptors.push('saAuthResponseInterceptor');
    }
  ]);

}).call(this);

(function() {
  var module;

  module = angular.module('SimpleAuth.Login', ['SimpleAuth.Constants', 'SimpleAuth.Session', 'SimpleAuth.UrlService']);

  module.factory('saLogin', [
    '$http', '$rootScope', 'saSession', 'urlService', 'AUTH_EVENTS', function($http, $rootScope, saSession, urlService, AUTH_EVENTS) {
      var service;
      service = {
        login: function(credentials) {
          var request;
          request = $http.post(urlService('login'), credentials);
          return request.success(function(res) {
            return $rootScope.$broadcast(AUTH_EVENTS.loginSuccess, res);
          });
        },
        logout: function() {
          var request;
          request = $http.post(urlService('logout'), {});
          request.success((function(_this) {
            return function(res) {
              if (_this.isAuthenticated()) {
                saSession.destroy();
              }
              return $rootScope.$broadcast(AUTH_EVENTS.logoutSuccess, res);
            };
          })(this));
          return request;
        },
        isAuthenticated: function() {
          return saSession.isValid();
        },
        isAuthorized: function(roles) {
          if (!angular.isArray(roles)) {
            roles = [roles];
          }
          return this.isAuthenticated() && saSession.hasRole(roles);
        }
      };
      return service;
    }
  ]);

}).call(this);

(function() {
  var module;

  module = angular.module('SimpleAuth.Session', ['SimpleAuth.Constants']);

  module.factory('saSession', [
    '$rootScope', 'AUTH_EVENTS', function($rootScope, AUTH_EVENTS) {
      var saSession;
      saSession = {
        create: function(token, user) {
          this.destroy();
          this.setToken(token);
          this.setUser(user);
          return this;
        },
        isValid: function() {
          return angular.isObject(this.user) && angular.isString(this.token);
        },
        hasRole: function(roles) {
          var role, _i, _len;
          if (!this.isValid()) {
            return false;
          }
          if (!angular.isArray(roles)) {
            roles = [roles];
          }
          for (_i = 0, _len = roles.length; _i < _len; _i++) {
            role = roles[_i];
            if (this.roles.indexOf(role) !== -1) {
              return true;
            }
          }
          return false;
        },
        destroy: function() {
          this.token = null;
          this.user = $rootScope.user = null;
          this.roles = [];
          return true;
        },
        setUser: function(user) {
          if (angular.isString(user)) {
            user = angular.fromJson(user);
          }
          if (!user) {
            this.user = $rootScope.user = null;
          } else if (!angular.equals(user, this.user)) {
            this.user = $rootScope.user = user;
            if (angular.isArray(user.roles)) {
              this.roles = user.roles;
            }
            $rootScope.$broadcast(AUTH_EVENTS.userChange, this.user);
          }
          return this;
        },
        setToken: function(token) {
          if (!angular.equals(token, this.token)) {
            this.token = token;
          }
          return this;
        }
      };
      return saSession;
    }
  ]);

}).call(this);

(function() {
  var module, urlServiceProvider, url_list;

  module = angular.module('SimpleAuth.UrlService', []);

  url_list = {
    login: '/login',
    logout: '/logout'
  };

  urlServiceProvider = (function() {
    function urlServiceProvider() {
      this.urlService = function(name) {
        if (!url_list[name]) {
          return null;
        }
        return url_list[name];
      };
    }

    urlServiceProvider.prototype.setUrl = function(key, url) {
      url_list[key] = url;
      return this;
    };

    urlServiceProvider.prototype.$get = [
      function() {
        return this.urlService;
      }
    ];

    return urlServiceProvider;

  })();

  module.provider('urlService', new urlServiceProvider);

}).call(this);

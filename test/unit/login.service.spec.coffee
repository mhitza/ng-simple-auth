
describe "LoginService", ->
  loginService  = null
  $httpBackend  = null
  $rootScope    = null
  AUTH_EVENTS   = null
  urlService    = null
  eventSpy      = null

  mockSession   = null

  beforeEach angular.mock.module "SimpleAuth.Login"

  beforeEach () ->
    mockSession   = sinon.stub({
      isValid: ->

      hasRole: ->

      destroy: ->
    })

  beforeEach angular.mock.module ($provide) ->
    $provide.decorator 'saSession', () -> return mockSession

  beforeEach inject (saLogin, AUTH_EVENTS, _$httpBackend_, _$rootScope_) ->
    $httpBackend  = _$httpBackend_
    $rootScope    = _$rootScope_
    eventSpy      = sinon.spy $rootScope, '$broadcast'

  beforeEach inject (saLogin, _AUTH_EVENTS_, _urlService_) ->
    loginService  = saLogin
    AUTH_EVENTS   = _AUTH_EVENTS_
    urlService    = _urlService_

  describe "::login", ->

    it "should be a function", ->
      expect(loginService.login).to.be.a 'function'

    it 'should broadcast a loginSuccess event on successful login', (done) ->
      credentials = {
        user: 'test'
        password: 'test'
      }
      $httpBackend.expectPOST(urlService('login'), credentials,
        (headers) ->
          headers['x-access-token'] = 'AUTH_TOKEN'
          headers['x-authenticate-user'] = angular.toJson({
              name: "AUTH USER"
          })
      ).respond(200, angular.toJson { test: "yes" } )

      loginService.login(credentials).success (res) ->
        expect(res.test).to.eql 'yes'
        expect(eventSpy.withArgs(AUTH_EVENTS.loginSuccess, res).calledOnce).to.be.true
        done()

      $httpBackend.flush()

  describe "::logout", ->

    it "should be a function", ->
      expect(loginService.logout).to.be.a 'function'

    it 'should broadcast a logoutSuccess event', (done) ->
      $httpBackend.expectPOST(urlService('/logout'), {})
        .respond(200)

      loginService.logout().success (res) ->
        expect(eventSpy.withArgs(AUTH_EVENTS.logoutSuccess, res).calledOnce).to.be.true
        done()

      $httpBackend.flush()

    it 'should call saSession.destroy if user is authenticated', (done) ->
      mockSession.isValid.returns true

      $httpBackend.expectPOST(urlService('/logout'), {}).respond(200)

      loginService.logout().success (res) ->
        expect(mockSession.destroy.calledOnce).to.be.true
        done()

      $httpBackend.flush()

  describe "::isAuthenticated", ->

    it "should be a function", ->
      expect(loginService.isAuthenticated).to.be.a 'function'

    it 'should delegate to saSession.isValid', ->
      mockSession.isValid.returns true

      expect(loginService.isAuthenticated()).to.be.true

      expect(mockSession.isValid.calledOnce).to.be.true

  describe '::isAuthorized', ->

    it "should be a function", ->
      expect(loginService.isAuthorized).to.be.a 'function'

    it 'should turn a string role into an array', ->
      mockSession.isValid.returns true
      mockSession.hasRole.withArgs([ 'test' ]).returns true

      expect(loginService.isAuthorized('test')).to.be.true

    it 'should pass an array of roles to the saSession.hasRole method', ->
      roles = [ 'one', 'two' ]
      mockSession.isValid.returns true
      mockSession.hasRole.withArgs(roles).returns true

      expect(loginService.isAuthorized(roles))
      expect(mockSession.hasRole.withArgs(roles).calledOnce).to.be.true

    it 'should return false the when not authenticated', ->
      roles = [ 'one' ]
      mockSession.isValid.returns false
      mockSession.hasRole.returns true

      expect(loginService.isAuthorized(roles)).to.be.false





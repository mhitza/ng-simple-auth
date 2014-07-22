
describe 'saAuthResponseInterceptor', ->
  deferred      = null
  scope         = null
  interceptor   = null
  header        = null
  fakeRes       = null
  headers       = {}

  mockHeaderService = sinon.stub()
  setUserSpy    = null
  setTokenSpy   = null

  beforeEach angular.mock.module 'SimpleAuth.AuthInterceptor'

  beforeEach angular.mock.module ($provide) ->
    $provide.decorator 'headerService', () -> return mockHeaderService

  beforeEach inject (saSession) ->
    setUserSpy    = sinon.spy saSession, 'setUser'
    setTokenSpy   = sinon.spy saSession, 'setToken'

  beforeEach inject ($q, $rootScope, saAuthResponseInterceptor) ->
    deferred      = $q.defer()
    scope         = $rootScope

    interceptor   = saAuthResponseInterceptor

    fakeRes =
      headers: (name) -> return headers[name]

  it 'should be a function', ->
    expect(interceptor).to.be.a 'function'

  it 'should call the saSession object to set the user if it exists in the header', (done) ->
    user =
      name: 'Auth Interceptor'

    mockHeaderService.withArgs(fakeRes, 'user').returns(user)
    mockHeaderService.withArgs(fakeRes, 'token').returns(null)

    interceptor(deferred.promise).then () ->
      expect(setUserSpy.withArgs(user).calledOnce).to.be.true
      expect(setTokenSpy.called).to.be.false
      done()

    deferred.resolve fakeRes

    scope.$apply()

  it 'should call the saSession.setToken function is an auth token exists in the header', (done) ->
    token = "Auth Token"

    mockHeaderService.withArgs(fakeRes, 'user').returns(null)
    mockHeaderService.withArgs(fakeRes, 'token').returns(token)

    interceptor(deferred.promise).then () ->
      expect(setUserSpy.called).to.be.false
      expect(setTokenSpy.withArgs(token).calledOnce).to.be.true
      done()

    deferred.resolve fakeRes
    scope.$apply()


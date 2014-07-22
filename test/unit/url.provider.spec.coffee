
describe "UrlService", ->
  provider  = null
  service   = null

  beforeEach () ->
    fakeModule = angular.module 'test.urlService', []
    fakeModule.config (urlServiceProvider) ->
      provider = urlServiceProvider

    angular.mock.module 'SimpleAuth.UrlService', 'test.urlService'

  beforeEach inject (urlService) ->
    service = urlService

  describe ' - urlService', ->

    it 'should return null for an undefined key', ->
      expect(service 'not_there').to.be.null

    it 'should have "login" defaulted to "/login"', ->
      expect(service 'login').to.eql '/login'

    it 'should have "logout" defaulted to "/logout"', ->
      expect(service 'logout').to.eql '/logout'

  describe '::setUrl', ->

    it 'should set a new key for one that does not exist', ->
      expect(service 'test').to.be.null

      provider.setUrl 'test', '/test'

      expect(service 'test').to.eql '/test'

    it 'should change a key for one that exists', ->
      expect(service 'login').to.eql '/login'

      provider.setUrl 'login', '/authenticate'

      expect(service 'login').to.eql '/authenticate'
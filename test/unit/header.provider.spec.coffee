
describe "HeaderService", ->
  provider    = null
  service     = null
  response    = null
  test_token  = "Test Token"
  test_user   =
    name: 'Test User'
  headers =
    'x-authenticate-user': test_user
    'x-access-token': test_token

  beforeEach () ->
    fakeModule = angular.module 'test.headerService', []
    fakeModule.config (headerServiceProvider) ->
      provider = headerServiceProvider

    angular.mock.module 'SimpleAuth.HeaderService', 'test.headerService'

  beforeEach inject (headerService) ->
    service = headerService

  beforeEach () ->
    response =
      headers: (name) -> return headers[name]

  describe ' - headerService', ->

    it 'should return null for an undefined key', ->
      expect(service response, 'test').to.be.null

    it 'should have a user default key of x-authenticate-user', ->
      expect(service response, 'user').to.eql test_user

    it 'should have a token default key of x-access-token', ->
      expect(service response, 'token').to.eql test_token

  describe '::setKey', ->

    it 'should be a function', ->
      expect(provider.setKey).to.be.a 'function'

    it 'should add a new key when given a non-existant one', ->
      headers['dude'] = 'sweet'

      expect(service response, 'test').to.be.null

      provider.setKey 'test', "dude"

      expect(service response, 'test').to.eql 'sweet'
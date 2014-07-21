
describe 'saSession', ->
  session   = null
  scope     = null
  events    = null

  beforeEach angular.mock.module 'SimpleAuth'

  beforeEach inject ($rootScope, saSession, AUTH_EVENTS) ->
    scope   = $rootScope
    session = saSession
    events  = AUTH_EVENTS

  describe '::create', ->

    it 'Should be a function', ->
      expect(session.create).to.be.a 'function'

    it 'Should have the token set when the `userChange` event is broadcast', (done) ->
      user =
        name: 'test'
        roles: [ 'test' ]

      scope.$on events.userChange, ->
        expect(session.token).to.eql 'test'
        done()

      session.create 'test', user

    it 'Should set the token to be the given token', ->
      session.create('test', {});
      expect(session.token).to.eql 'test'

    it 'Should set the user to be the given user', ->
      user =
        name: 'test'

      session.create 'test', user
      expect(session.user).to.eql user

    it 'Should set the user every time', ->
      sinon.spy scope, '$broadcast'

      user =
        name: 'test'

      session.create 'test', user
      session.create 'test', user


      expect(scope.$broadcast.calledTwice).to.be.true

    it 'Should call destroy', ->
      sinon.spy session, 'destroy'
      session.create 'test',
        name: 'test'

      expect(session.destroy.called).to.be.true

    it 'should set the roles is they are provided in the user object.', ->
      roles = [ 'boo', 'scary' ]
      user =
        name: 'test'
        roles: roles

      session.create 'test', user

      expect(session.roles).to.eql roles

    it 'should not set the roles if the user object does not have them', ->
      user =
        name: 'test'

      session.create 'test', user
      expect(session.roles).to.eql []

  describe '::isValid', ->

    it 'should be a function', ->
      expect(session.isValid).to.be.a 'function'

    it 'should return false before ::create is called', ->
      expect(session.isValid()).to.be.false

    it 'should return true after ::create is called', ->
      session.create 'test',
        name: 'test'

      expect(session.isValid()).to.be.true

    it 'should return false after destroy has been called', ->
      session.create 'test',
        name: 'test'

      expect(session.isValid()).to.be.true

      session.destroy()

      expect(session.isValid()).to.be.false

    it 'should return false if we supply a null token', ->
      session.create null,
        name: 'test'

      expect(session.isValid()).to.be.false

    it 'should return false if we supply a null user', ->
      session.create 'test', null
      expect(session.isValid()).to.be.false

  describe '::hasRole', ->

    it 'should be a function', ->
      expect(session.hasRole).to.be.a 'function'

    it 'should return false when the session is invalid', ->
      session.roles = [ 'test' ]
      expect(session.hasRole('test')).to.be.false

    it 'should return true when the user has the role provided as a string', ->
      session.create 'test',
        name: 'test'
        roles: [ 'test', 'other' ]

      expect(session.hasRole('test')).to.be.true
      expect(session.hasRole('other')).to.be.true

    it 'should return false when the user does not have the role provided as a string', ->
      session.create 'test',
        name: 'test'
        roles: [ 'test', 'other' ]

      expect(session.hasRole('boo')).to.be.false

    it 'should return true when the user has any one of the roles in a given array of roles', ->
      session.create 'test',
        name: 'test'
        roles: [ 'test', 'other', 'more' ]

      roles = [ 'not', 'here', 'ok', 'test', 'another' ]

      expect(session.hasRole(roles)).to.be.true

    it 'should return false when the user does not have any of the roles in the given array', ->
      session.create 'test',
        name: 'test'
        roles: [ 'test', 'other', 'more' ]

      roles = [ 'not', 'here', 'ok', 'maybe', 'nope' ]

      expect(session.hasRole(roles)).to.be.false

    it 'should return true when the user has one of the two roles', ->
      session.create 'test',
        name: 'saSessionTest'
        roles: [ 'test' ]

      # This is how we retrieve roles from the saHasPerm directive
      roles = "test another".split ' '

      expect(session.hasRole(roles)).to.be.true

  describe '::destroy', ->

    it 'should be a function', ->
      expect(session.destroy).to.be.a 'function'

    it 'should cause the session to invalidate', ->
      session.create 'test',
        name: 'test'

      expect(session.isValid()).to.be.true

      session.destroy()

      expect(session.isValid()).to.be.false

  describe '::setUser', ->
    it 'should be a function ', ->
      expect(session.setUser).to.be.a 'function'

    it 'should set the user to the given user object if one is not already set', ->
      user =
        name: 'test'

      expect(session.user).to.be.undefined

      session.setUser user

      expect(session.user).to.eql user

    it 'should not set the user if the given user is not different than the current user', ->
      sinon.spy scope, '$broadcast'
      sinon.spy session, 'setUser'

      user  =
        name: 'test'

      session.create 'test', user

      session.setUser user

      expect(session.setUser.calledTwice).to.be.true
      expect(scope.$broadcast.calledOnce).to.be.true

    it 'should set the user if the given user is different than the current user', ->
      sinon.spy scope, '$broadcast'
      sinon.spy session, 'setUser'

      user  =
        name: 'test'

      session.create 'test', user

      session.setUser
        name: 'another'

      expect(session.setUser.calledTwice).to.be.true
      expect(scope.$broadcast.calledTwice).to.be.true

    it 'should parse the given JSON string', ->
      user =
        name: 'json_test'

      json = angular.toJson(user)

      session.setUser(json)
      expect(session.user).to.eql user

  describe '::setToken', ->
    it 'should be a function', ->
      expect(session.setToken).to.be.a 'function'

    it 'should set the token object is one is not already set', ->
      token = 'test'
      expect(session.token).to.be.undefined

      session.setToken token
      expect(session.token).to.eql token

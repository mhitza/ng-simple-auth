describe 'saHasPerm', ->
  element = null
  session = null

  beforeEach angular.mock.module('SimpleAuth.HasPerm')

  beforeEach inject ($rootScope, $compile, saSession) ->
    template  = '<div sa-has-perm="test another">Hello</div>'
    element   = $compile(template)($rootScope)
    session   = saSession

  it 'should not modify the content', ->
    expect(element.text()).to.eql 'Hello'

  it 'should hide the element on initialization.', ->
    expect(element.css('display')).to.eql 'none'

  it 'should show the element when a user with one of the roles is logged in.', ->
     user =
       name: "perm_test"
       roles: [ 'test' ]

     session.create('test', user)

     expect(element.css('display')).to.not.eql 'none'

  it 'should hide the element when a user without the proper roles is logged in', ->
    user =
      name: "perm_test"
      roles: [ "bad" ]

    session.setUser(user)

    expect(element.css('display')).to.eql 'none'

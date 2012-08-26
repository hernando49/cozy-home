applicationsTemplate = require('../templates/applications')
User = require("../models/user").User

AppRow = require('views/application').ApplicationRow
AppCollection = require('collections/application').ApplicationCollection
Application = require("models/application").Application


# Small widget used to changed installatio button style easily
class InstallButton

    constructor: (@button) ->

    displayOrange: (text) ->
        @button.html text
        @button.removeClass "btn-success"
        @button.removeClass "btn-danger"
        @button.removeClass "disabled"
        @button.addClass "btn-warning"

    displayGreen: (text) ->
        @button.html text
        @button.addClass "btn-success"
        @button.addClass "disabled"
        @button.removeClass "btn-danger"
        @button.removeClass "btn-warning"

    displayRed: (text) ->
        @button.html text
        @button.removeClass "btn-success"
        @button.addClass  "btn-danger"
        @button.removeClass "disabled"
        @button.removeClass "btn-warning"


# View describing main screen for user once he is logged
class exports.ApplicationsView extends Backbone.View
  id: 'applications-view'

  ### Constructor ###

  constructor: ->
    super()

    @isManaging = false
    @apps = new AppCollection @

 
  ### Listeners ###

  onAddClicked: =>
    @installAppButton.displayOrange "install"

    @addApplicationForm.show()
    @addApplicationModal.toggle()

  onInstallClicked: =>
    data =
      name: @$("#app-name-field").val()
      description: @$("#app-description-field").val()
      git: @$("#app-git-field").val()

    @errorAlert.hide()
    @installAppButton.displayOrange "install"

    if @checkData data
        @errorAlert.hide()
        @installAppButton.button.html "installing..."
        @installInfo.spin()

        app = new Application data
        app.install
            success: =>
                @apps.add app
                @installAppButton.displayGreen "Install succeeds!"
                @installInfo.spin()
                setTimeout =>
                    @addApplicationForm.slideToggle()
                , 1000
            error: (data) =>
                @installAppButton.displayRed "Install failed"
                @installInfo.spin()
    else
        @displayError "All fields are required"

  onManageAppsClicked: =>
      $(".application-outer").toggle()
      @isManaging = not @isManaging

  onCloseAddAppClicked: =>
      @addApplicationModal.hide()

  ### Functions ###

  # Clear current application list.
  clearApps: =>
      @appList.html null

  # Add an application row to the app list.
  addAppRow: (app) =>
      row = new AppRow app
      el = row.render()
      @appList.append el
      @$(el).hide()
      @$(el).fadeIn()
      @$(el).find(".application-outer").show() if @isManaging

  # Check that given data are corrects.
  checkData: (data) =>
    rightData = true
    for property of data
      rightData = data[property]? and data[property].length > 0
      break if not rightData
    rightData

  # Display message inside info box.
  displayInfo: (msg) =>
    @errorAlert.hide()
    @infoAlert.html msg
    @infoAlert.show()

  # Display message inside error box.
  displayError: (msg) =>
    @infoAlert.hide()
    @errorAlert.html msg
    @errorAlert.show()

  ### Init functions ###

  fetchData: ->
    @apps.fetch()

  render: ->
    $(@el).html applicationsTemplate()
    @el

  setListeners: ->
    @appList = @$ "#app-list"

    @addApplicationButton = @$ "#add-app-button"
    @addApplicationButton.click @onAddClicked
    @addApplicationForm = @$ "#add-app-form"
    @addApplicationModal = @$ "#add-app-modal"
    @manageAppsButton = @$ "#manage-app-button"
    @manageAppsButton.click @onManageAppsClicked
    @installAppButton = new InstallButton @$ "#add-app-submit"
    @installAppButton.button.click @onInstallClicked
    @infoAlert = @$ "#add-app-form .info"
    @errorAlert = @$ "#add-app-form .error"

    @appNameField = @$ "#app-name-field"
    @appDescriptionField = @$ "#app-description-field"
    @appGitField = @$ "#app-git-field"

    @installInfo = @$ "#add-app-modal .loading-indicator"
    @errorAlert.hide()
    @infoAlert.hide()
    @installInfo.spin()

    @addApplicationCloseCross = @$ "#add-app-modal .close"
    @addApplicationCloseCross.click @onCloseAddAppClicked
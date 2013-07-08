timer = null

window.enableSubmitButton = ->
  $submit_button = $("#payment-form").find("a.submit-button")
  $submit_button.attr("disabled", false).removeAttr "disabled"

window.IndexCtrl = ($scope, $http) ->
  $scope.legislators = []
  
  $credit_card_modal = $("#credit-card-modal").modal("hide")

  $( ->
    setTimeout( ->
      $(".mass-hide.hidden").hide().removeClass("hidden").fadeIn()
    , 500)

    $("textarea").bind "keypress", (e) ->
      if (e.keyCode or e.which) is 13
        false
  )

  $scope.searchByZip = ->
    clearTimeout timer
    timer = setTimeout(->
      $scope.getLegislators() 
    , 800)

  $scope.showPaymentForm = ->
    $(".errors").html("")
    errors = []
    errors.push("You haven't filled out any fields.") if !$scope.postcard
    errors.push("A message is required.") if $scope.postcard && !$scope.postcard.message
    errors.push("Representative is required. <small>Enter your zip in step #1 and then click on a representative's photo.</small>") if $scope.postcard && !$scope.postcard.street1

    if errors.length <= 0
      $credit_card_modal.modal "show"
    else
      $(".errors").html(errors.join(" "))

  $scope.showSenderAddress = ->
    $(".sender_address").removeClass("hidden")

  $scope.showSenderStreet2 = ->
    if !!$scope.postcard.sender_street2
      $(".sender_street2").removeClass("hidden")
    else
      $(".sender_street2").addClass("hidden") 

  $scope.chargeAndDeliver = ->
    $submit_button = $("#payment-form").find("a.submit-button")
    $submit_button.attr "disabled", true
    $(".payment-errors").html ""
    Stripe.createToken
      number: $(".card-number").val()
      cvc: $(".card-cvc").val()
      exp_month: $(".card-expiry-month").val()
      exp_year: $(".card-expiry-year").val()
    , $scope.stripeResponseHandler

  $scope.getLegislators = ->
    $http.get("/api/v0/legislators.json?postalcode=#{$scope.postcard.sender_postalcode}").success (res) ->
      if !!timer
        $scope.legislators  = res.legislators
        if $scope.legislators.length > 0
          $(".zip-no-results").hide()
          $(".reps-list .help-text").show()
        else
          $(".reps-list .help-text").hide()
          $(".zip-no-results").show() if $scope.postcard.sender_postalcode.length >= 5

        setTimeout( ->
          $("a[rel='popover']").tooltip({trigger: 'hover', placement: 'top'})
        , 500)


  $scope.setLegislator = (i) ->
    for legislator in $scope.legislators
      legislator.class = null

    $scope.postcard =
      class:                $scope.legislators[i].class = 'active'
      name:                 $scope.legislators[i].name
      street1:              $scope.legislators[i].street1
      street2:              $scope.legislators[i].street2
      city:                 $scope.legislators[i].city
      state:                $scope.legislators[i].state
      postalcode:           $scope.legislators[i].postalcode
      greeting:             $scope.legislators[i].greeting
      sender_name:          $scope.postcard.sender_name if !!$scope.postcard
      sender_street1:       $scope.postcard.sender_street1 if !!$scope.postcard
      sender_street2:       $scope.postcard.sender_street2 if !!$scope.postcard
      sender_city:          $scope.postcard.sender_city if !!$scope.postcard
      sender_state:         $scope.postcard.sender_state if !!$scope.postcard
      sender_postalcode:    $scope.postcard.sender_postalcode if !!$scope.postcard

  $scope.stripeResponseHandler = (status, response) ->
    if response.error
      $(".payment-errors").text response.error.message
      enableSubmitButton()
    else
      $form = $("#payment-form")
      token = response["id"]
      $form.append "<input type='hidden' name='stripeToken' value='" + token + "'/>"
      url   = "/api/v0/postcards.json"
      data  = {}
      
      $scope.$apply ->
        data =
          card:              token
          message:           "#{$scope.postcard.greeting}\n\n#{$scope.postcard.message}"
          name:              $scope.postcard.name
          street1:           $scope.postcard.street1
          street2:           $scope.postcard.street2
          city:              $scope.postcard.city
          state:             $scope.postcard.state
          postalcode:        $scope.postcard.postalcode
          sender_name:       $scope.postcard.sender_name
          sender_street1:    $scope.postcard.sender_street1
          sender_street2:    $scope.postcard.sender_street2
          sender_city:       $scope.postcard.sender_city
          sender_state:      $scope.postcard.sender_state
          sender_postalcode: $scope.postcard.sender_postalcode

      $.ajax
        type: "POST"
        url: url
        data: data
        success: (res) ->
          enableSubmitButton()

          json = JSON.parse(res)
          if !!json.success
            $credit_card_modal  = $("#credit-card-modal").modal("hide")
            $thank_you_modal    = $("#thank-you-modal").modal("show")
          else
            $(".payment-errors").text json.error.message
        error: ->
          enableSubmitButton()
          alert("There was an error. Refresh the page and try again.")

IndexCtrl.$inject = ['$scope', '$http']

class window.CreditCard
  constructor: ->
    @preloadCardIcons()
    @showCCProvider()

  showCCProvider: ->
    $card_number = $(".card-number")
    l = 0
    m = not 1
    $card_number.keyup(=>
      current = $card_number.val()
      return @_showCard() unless current
      first   = current.charAt(0)
      second  = current.charAt(1)
      third   = current.charAt(2)
      fourth  = current.charAt(3)

      if @_isVisa(first)
        @_showCard("visa")
      else if @_isMastercard(first, second)
        @_showCard("mastercard")
      else if @_isAmex(first, second)
        @_showCard("amex")
      else if @_isDiscover(first, second, third, fourth)
        @_showCard("discover")
      else
        @_showCard()
    )

  preloadCardIcons: ->
    cardIcons = [
      '/images/cc/generic.png',
      '/images/cc/visa.png',
      '/images/cc/mastercard.png',
      '/images/cc/amex.png',
      '/images/cc/discover.png'
    ]

    for src in cardIcons
      $("<img/>")[0].src = src

  _showCard: (card_name) ->
    $card_icon = $(".card-icon")

    $card_icon.css({opacity: 1})

    switch card_name
      when "visa"
        $card_icon.attr("src", "/images/cc/visa.png")
      when "mastercard"
        $card_icon.attr("src", "/images/cc/mastercard.png")
      when "amex"
        $card_icon.attr("src", "/images/cc/amex.png")
      when "discover"
        $card_icon.attr("src", "/images/cc/discover.png")
      else
        $card_icon.css({opacity: .2})
        $card_icon.attr("src", "/images/cc/generic.png")

  _isVisa: (first) ->
    parseInt(first) is 4

  _isMastercard: (first, second) ->
    first   = parseInt(first)
    second  = parseInt(second)
    (first is 5) and (second is 1) or (second is 2) or (second is 3) or (second is 4) or (second is 5)

  _isAmex: (first, second) ->
    first   = parseInt(first)
    second  = parseInt(second)
    (first is 3) and (second is 4) or (second is 7)

  _isDiscover: (first, second, third, fourth) ->
    first   = parseInt(first)
    second  = parseInt(second)
    third   = parseInt(third)
    fourth  = parseInt(fourth)
    (first is 6) and (second is 0) and (third is 1) and (fourth is 1)

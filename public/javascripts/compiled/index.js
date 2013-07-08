(function() {
  var timer;

  timer = null;

  window.enableSubmitButton = function() {
    var $submit_button;
    $submit_button = $("#payment-form").find("a.submit-button");
    return $submit_button.attr("disabled", false).removeAttr("disabled");
  };

  window.IndexCtrl = function($scope, $http) {
    var $credit_card_modal;
    $scope.legislators = [];
    $credit_card_modal = $("#credit-card-modal").modal("hide");
    $(function() {
      setTimeout(function() {
        return $(".mass-hide.hidden").hide().removeClass("hidden").fadeIn();
      }, 500);
      return $("textarea").bind("keypress", function(e) {
        if ((e.keyCode || e.which) === 13) {
          return false;
        }
      });
    });
    $scope.searchByZip = function() {
      clearTimeout(timer);
      return timer = setTimeout(function() {
        return $scope.getLegislators();
      }, 800);
    };
    $scope.showPaymentForm = function() {
      var errors;
      $(".errors").html("");
      errors = [];
      if (!$scope.postcard) {
        errors.push("You haven't filled out any fields.");
      }
      if ($scope.postcard && !$scope.postcard.message) {
        errors.push("A message is required.");
      }
      if ($scope.postcard && !$scope.postcard.street1) {
        errors.push("Representative is required. <small>Enter your zip in step #1 and then click on a representative's photo.</small>");
      }
      if (errors.length <= 0) {
        return $credit_card_modal.modal("show");
      } else {
        return $(".errors").html(errors.join(" "));
      }
    };
    $scope.showSenderAddress = function() {
      return $(".sender_address").removeClass("hidden");
    };
    $scope.showSenderStreet2 = function() {
      if (!!$scope.postcard.sender_street2) {
        return $(".sender_street2").removeClass("hidden");
      } else {
        return $(".sender_street2").addClass("hidden");
      }
    };
    $scope.chargeAndDeliver = function() {
      var $submit_button;
      $submit_button = $("#payment-form").find("a.submit-button");
      $submit_button.attr("disabled", true);
      $(".payment-errors").html("");
      return Stripe.createToken({
        number: $(".card-number").val(),
        cvc: $(".card-cvc").val(),
        exp_month: $(".card-expiry-month").val(),
        exp_year: $(".card-expiry-year").val()
      }, $scope.stripeResponseHandler);
    };
    $scope.getLegislators = function() {
      return $http.get("/api/v0/legislators.json?postalcode=" + $scope.postcard.sender_postalcode).success(function(res) {
        if (!!timer) {
          $scope.legislators = res.legislators;
          if ($scope.legislators.length > 0) {
            $(".zip-no-results").hide();
            $(".reps-list .help-text").show();
          } else {
            $(".reps-list .help-text").hide();
            if ($scope.postcard.sender_postalcode.length >= 5) {
              $(".zip-no-results").show();
            }
          }
          return setTimeout(function() {
            return $("a[rel='popover']").tooltip({
              trigger: 'hover',
              placement: 'top'
            });
          }, 500);
        }
      });
    };
    $scope.setLegislator = function(i) {
      var legislator, _i, _len, _ref;
      _ref = $scope.legislators;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        legislator = _ref[_i];
        legislator["class"] = null;
      }
      return $scope.postcard = {
        "class": $scope.legislators[i]["class"] = 'active',
        name: $scope.legislators[i].name,
        street1: $scope.legislators[i].street1,
        street2: $scope.legislators[i].street2,
        city: $scope.legislators[i].city,
        state: $scope.legislators[i].state,
        postalcode: $scope.legislators[i].postalcode,
        greeting: $scope.legislators[i].greeting,
        sender_name: !!$scope.postcard ? $scope.postcard.sender_name : void 0,
        sender_street1: !!$scope.postcard ? $scope.postcard.sender_street1 : void 0,
        sender_street2: !!$scope.postcard ? $scope.postcard.sender_street2 : void 0,
        sender_city: !!$scope.postcard ? $scope.postcard.sender_city : void 0,
        sender_state: !!$scope.postcard ? $scope.postcard.sender_state : void 0,
        sender_postalcode: !!$scope.postcard ? $scope.postcard.sender_postalcode : void 0
      };
    };
    return $scope.stripeResponseHandler = function(status, response) {
      var $form, data, token, url;
      if (response.error) {
        $(".payment-errors").text(response.error.message);
        return enableSubmitButton();
      } else {
        $form = $("#payment-form");
        token = response["id"];
        $form.append("<input type='hidden' name='stripeToken' value='" + token + "'/>");
        url = "/api/v0/postcards.json";
        data = {};
        $scope.$apply(function() {
          return data = {
            card: token,
            message: "" + $scope.postcard.greeting + "\n\n" + $scope.postcard.message,
            name: $scope.postcard.name,
            street1: $scope.postcard.street1,
            street2: $scope.postcard.street2,
            city: $scope.postcard.city,
            state: $scope.postcard.state,
            postalcode: $scope.postcard.postalcode,
            sender_name: $scope.postcard.sender_name,
            sender_street1: $scope.postcard.sender_street1,
            sender_street2: $scope.postcard.sender_street2,
            sender_city: $scope.postcard.sender_city,
            sender_state: $scope.postcard.sender_state,
            sender_postalcode: $scope.postcard.sender_postalcode
          };
        });
        return $.ajax({
          type: "POST",
          url: url,
          data: data,
          success: function(res) {
            var $thank_you_modal, json;
            enableSubmitButton();
            json = JSON.parse(res);
            if (!!json.success) {
              $credit_card_modal = $("#credit-card-modal").modal("hide");
              return $thank_you_modal = $("#thank-you-modal").modal("show");
            } else {
              return $(".payment-errors").text(json.error.message);
            }
          },
          error: function() {
            enableSubmitButton();
            return alert("There was an error. Refresh the page and try again.");
          }
        });
      }
    };
  };

  IndexCtrl.$inject = ['$scope', '$http'];

  window.CreditCard = (function() {

    function CreditCard() {
      this.preloadCardIcons();
      this.showCCProvider();
    }

    CreditCard.prototype.showCCProvider = function() {
      var $card_number, l, m,
        _this = this;
      $card_number = $(".card-number");
      l = 0;
      m = !1;
      return $card_number.keyup(function() {
        var current, first, fourth, second, third;
        current = $card_number.val();
        if (!current) {
          return _this._showCard();
        }
        first = current.charAt(0);
        second = current.charAt(1);
        third = current.charAt(2);
        fourth = current.charAt(3);
        if (_this._isVisa(first)) {
          return _this._showCard("visa");
        } else if (_this._isMastercard(first, second)) {
          return _this._showCard("mastercard");
        } else if (_this._isAmex(first, second)) {
          return _this._showCard("amex");
        } else if (_this._isDiscover(first, second, third, fourth)) {
          return _this._showCard("discover");
        } else {
          return _this._showCard();
        }
      });
    };

    CreditCard.prototype.preloadCardIcons = function() {
      var cardIcons, src, _i, _len, _results;
      cardIcons = ['/images/cc/generic.png', '/images/cc/visa.png', '/images/cc/mastercard.png', '/images/cc/amex.png', '/images/cc/discover.png'];
      _results = [];
      for (_i = 0, _len = cardIcons.length; _i < _len; _i++) {
        src = cardIcons[_i];
        _results.push($("<img/>")[0].src = src);
      }
      return _results;
    };

    CreditCard.prototype._showCard = function(card_name) {
      var $card_icon;
      $card_icon = $(".card-icon");
      $card_icon.css({
        opacity: 1
      });
      switch (card_name) {
        case "visa":
          return $card_icon.attr("src", "/images/cc/visa.png");
        case "mastercard":
          return $card_icon.attr("src", "/images/cc/mastercard.png");
        case "amex":
          return $card_icon.attr("src", "/images/cc/amex.png");
        case "discover":
          return $card_icon.attr("src", "/images/cc/discover.png");
        default:
          $card_icon.css({
            opacity: .2
          });
          return $card_icon.attr("src", "/images/cc/generic.png");
      }
    };

    CreditCard.prototype._isVisa = function(first) {
      return parseInt(first) === 4;
    };

    CreditCard.prototype._isMastercard = function(first, second) {
      first = parseInt(first);
      second = parseInt(second);
      return (first === 5) && (second === 1) || (second === 2) || (second === 3) || (second === 4) || (second === 5);
    };

    CreditCard.prototype._isAmex = function(first, second) {
      first = parseInt(first);
      second = parseInt(second);
      return (first === 3) && (second === 4) || (second === 7);
    };

    CreditCard.prototype._isDiscover = function(first, second, third, fourth) {
      first = parseInt(first);
      second = parseInt(second);
      third = parseInt(third);
      fourth = parseInt(fourth);
      return (first === 6) && (second === 0) && (third === 1) && (fourth === 1);
    };

    return CreditCard;

  })();

}).call(this);

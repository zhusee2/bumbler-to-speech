(function() {
  var AUDIO_MAP, BumblerSpeech, checkInput, defaultOptions, delay;

  delay = function(ms, func) {
    return setTimeout(func, ms);
  };

  AUDIO_MAP = {
    d1: {
      start: 0.45,
      duration: 0.5
    },
    d2: {
      start: 1.43,
      duration: 0.5
    },
    d3: {
      start: 2.65,
      duration: 0.5
    },
    d4: {
      start: 3.55,
      duration: 0.5
    },
    d5: {
      start: 4.9,
      duration: 0.6
    },
    d6: {
      start: 5.9,
      duration: 0.6
    },
    d7: {
      start: 6.7,
      duration: 0.55
    },
    d8: {
      start: 7.75,
      duration: 0.5
    },
    d9: {
      start: 8.77,
      duration: 0.53
    },
    d10: {
      start: 9.52,
      duration: 0.53
    },
    thank: {
      start: 10.73,
      duration: 1.55
    }
  };

  defaultOptions = {
    player: '#ma-speech',
    numbers: [2, 37, 69]
  };

  BumblerSpeech = (function() {

    function BumblerSpeech(options) {
      var mergedOptions,
        _this = this;
      if (options == null) {
        options = {};
      }
      if (typeof options === "string") {
        this.player = document.querySelector(options);
        this.numberQueue = [];
        this.playing = false;
      } else {
        mergedOptions = $.extend({}, defaultOptions, options);
        this.player = document.querySelector(mergedOptions.player);
        this.numberQueue = mergedOptions.numbers;
        this.playing = false;
      }
      $(this).on('speechEnd', function() {
        return delay(300, function() {
          var currentNumber;
          currentNumber = _this.numberQueue.shift();
          if (currentNumber === void 0 || null) {
            _this.playing = false;
            return;
          }
          return _this.playNumber(currentNumber);
        });
      });
    }

    BumblerSpeech.prototype.playPartial = function(partialIndex, rate) {
      var duration, partial,
        _this = this;
      if (rate == null) {
        rate = 1.0;
      }
      partial = AUDIO_MAP[partialIndex];
      this.player.currentTime = partial.start;
      this.player.play();
      duration = partial.duration / rate * 1000;
      return setTimeout(function() {
        return _this.player.pause();
      }, duration);
    };

    BumblerSpeech.prototype.playSequence = function(indexQueue, literal) {
      var audioEventHandler, queueIterate,
        _this = this;
      if (literal == null) {
        literal = false;
      }
      audioEventHandler = function() {
        _this.player.removeEventListener('pause', audioEventHandler);
        return queueIterate();
      };
      queueIterate = function() {
        var currentIndex, playbackRate;
        currentIndex = indexQueue.shift();
        playbackRate = 0.9;
        if (currentIndex === void 0 || null) {
          $(_this).trigger('speechEnd');
          return false;
        }
        if (indexQueue.length > 0) {
          playbackRate = currentIndex === "d10" ? 1.55 : 1.20;
        }
        if (literal) {
          playbackRate = 1;
        }
        _this.player.addEventListener('pause', audioEventHandler);
        return _this.playPartial(currentIndex, playbackRate);
      };
      return queueIterate();
    };

    BumblerSpeech.prototype.numberToSpeechQueue = function(number) {
      var digit1, digit10, queueArray;
      if (number === "thank") {
        return ["thank"];
      }
      if (number >= 100 || number < 1) {
        return false;
      }
      queueArray = [];
      digit1 = number % 10;
      digit10 = (number - digit1) / 10;
      if (digit10 > 0) {
        if (digit10 > 1) {
          queueArray.push("d" + digit10);
        }
        queueArray.push("d10");
      }
      if (digit1 > 0) {
        queueArray.push("d" + digit1);
      }
      return queueArray;
    };

    BumblerSpeech.prototype.playNumber = function(number) {
      var speechQueue;
      speechQueue = this.numberToSpeechQueue(number);
      return this.playSequence(speechQueue);
    };

    BumblerSpeech.prototype.play = function() {
      if (!this.playing) {
        $(this).trigger('speechEnd');
      }
      return this.playing = true;
    };

    return BumblerSpeech;

  })();

  checkInput = function() {
    var numberToPlay;
    numberToPlay = $('#ma-number').val();
    numberToPlay = numberToPlay.match(/\d+/);
    if ((numberToPlay != null) && (0 < numberToPlay && numberToPlay < 100)) {
      return numberToPlay;
    } else {
      $('#ma-number').val("").focus();
      return false;
    }
  };

  $(function() {
    window.speaker = new BumblerSpeech("#ma-speech");
    $('#btn-play').on('click', function(event) {
      var numberToPlay;
      numberToPlay = checkInput();
      if (numberToPlay) {
        speaker.numberQueue = [numberToPlay];
        speaker.play();
      }
      return event.preventDefault();
    });
    $('#btn-countup').on('click', function(event) {
      var numberToPlay, _i, _results;
      numberToPlay = checkInput();
      if (numberToPlay) {
        speaker.numberQueue = (function() {
          _results = [];
          for (var _i = 1; 1 <= numberToPlay ? _i <= numberToPlay : _i >= numberToPlay; 1 <= numberToPlay ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this);
        speaker.numberQueue.push("thank");
        speaker.play();
      }
      return event.preventDefault();
    });
    $('#btn-countdown').on('click', function(event) {
      var numberToPlay, _i, _results;
      numberToPlay = checkInput();
      if (numberToPlay) {
        speaker.numberQueue = (function() {
          _results = [];
          for (var _i = numberToPlay; numberToPlay <= 1 ? _i <= 1 : _i >= 1; numberToPlay <= 1 ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this);
        speaker.numberQueue.push("thank");
        speaker.play();
      }
      return event.preventDefault();
    });
    return $('#btn-digitplay').on('click', function(event) {
      var numberToPlay, seq;
      numberToPlay = $('#ma-number').val();
      numberToPlay = numberToPlay.match(/^[1-9]+$/);
      $(this).popover('destroy');
      if (numberToPlay) {
        seq = numberToPlay[0].replace(/([\d])/g, ",d$1").split(",");
        seq.splice(0, 1);
        speaker.playSequence(seq, true);
      }
      if ($('#ma-number').val().match(/0/)) {
        $(this).popover({
          title: '念不出來...',
          content: '很抱歉，邦伯現在還不會念「零」喔！',
          placement: 'top',
          trigger: 'manual'
        });
        $(this).popover('show');
      }
      return event.preventDefault();
    });
  });

}).call(this);

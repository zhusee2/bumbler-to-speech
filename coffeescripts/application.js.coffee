NUMS = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]

AUDIO_MAP = {
  d1: {start: 0.45, duration: 0.5}
  d2: {start: 1.43, duration: 0.5}
  d3: {start: 2.65, duration: 0.5}
  d4: {start: 3.55, duration: 0.5}
  d5: {start: 4.9, duration: 0.6}
  d6: {start: 5.9, duration: 0.6}
  d7: {start: 6.7, duration: 0.55}
  d8: {start: 7.75, duration: 0.5}
  d9: {start: 8.77, duration: 0.53}
  d10: {start: 9.52, duration: 0.53}
  thank: {start: 10.73, duration: 1.55}
}

defaultOptions = {
  player: '#ma-speech'
  caption: '.caption'
  numbers: [2, 37, 69]
}

class BumblerSpeech
  constructor: (options = {}) ->
    if typeof options is "string"
      @player = document.querySelector(options)
      @caption = document.querySelector(".caption")
      @numberQueue = []
    else
      mergedOptions = $.extend({}, defaultOptions, options)
      @player = document.querySelector(mergedOptions.player)
      @caption = document.querySelector(mergedOptions.caption)
      @numberQueue = mergedOptions.numbers

  playPartial: (partialIndex, rate = 1.0) ->
    partial = AUDIO_MAP[partialIndex]
    @player.currentTime = partial.start
    @player.playbackRate = rate
    @player.play()

    setTimeout( =>
      @player.pause()
    , partial.duration / rate * 1000)

  playSequence: (indexQueue) ->
    audioEventHandler = =>
      @player.removeEventListener('pause', audioEventHandler)
      queueIterate()

    queueIterate = =>
      currentIndex = indexQueue.shift()

      if currentIndex is undefined or null
        $(@).trigger('speechEnd')
        return false

      @player.addEventListener('pause', audioEventHandler)
      if indexQueue.length > 0
        if currentIndex is "d10"
          @playPartial(currentIndex, 1.50)
        else
          @playPartial(currentIndex, 1.33)
      else
        @playPartial(currentIndex, 0.90)

    queueIterate()

  showCaption: (caption) ->
    $(@caption).text(caption)

  numberToCaption: (number) ->
    return "謝謝大家 請坐" if number is "thank"
    return false if number >= 100 or number < 1

    caption = "(邦伯式數數) "
    digit1 = number % 10
    digit10 = (number - digit1) / 10

    if digit10 > 0
      caption += "#{NUMS[digit10]}" if digit10 > 1
      caption += "十"

    caption += NUMS[digit1]
    caption

  numberToSpeechQueue: (number) ->
    return ["thank"] if number is "thank"
    return false if number >= 100 or number < 1

    queueArray = []
    digit1 = number % 10
    digit10 = (number - digit1) / 10

    if digit10 > 0
      queueArray.push "d#{digit10}" if digit10 > 1
      queueArray.push "d10"

    queueArray.push "d#{digit1}" if digit1 > 0

    queueArray

  playNumber: (number) ->
    caption = @numberToCaption(number)
    @showCaption(caption)
    speechQueue = @numberToSpeechQueue(number)
    @playSequence(speechQueue)

  play: ->
    queueEventHandler = ->
      $(@).off('speechEnd', queueEventHandler)
      setTimeout(queueIterate, 300)

    queueIterate = =>
      currentNumber = @numberQueue.shift()

      if currentNumber is undefined or null
        $(@).trigger('queueSpeechEnd')
        return false

      $(@).on('speechEnd', queueEventHandler)
      @playNumber(currentNumber)

    queueIterate()

checkInput = ->
  numberToPlay = $('#ma-number').val()
  numberToPlay = numberToPlay.match(/\d+/)

  if numberToPlay? and 0 < numberToPlay < 100
    return numberToPlay
  else
    $('#ma-number').val("").focus()
    return false

$ ->
  window.speaker = new BumblerSpeech("#ma-speech")
  speaker.numberQueue = [1..100]

  $('#btn-play').on 'click', (event) ->
    numberToPlay = checkInput()
    speaker.playNumber(numberToPlay) if numberToPlay

    event.preventDefault()

  $('#btn-countup').on 'click', (event) ->
    numberToPlay = checkInput()

    if numberToPlay
      speaker.numberQueue = [1..numberToPlay]
      speaker.numberQueue.push "thank"
      speaker.play()

    event.preventDefault()

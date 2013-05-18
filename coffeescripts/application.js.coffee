delay = (ms, func) -> setTimeout func, ms

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
  numbers: [2, 37, 69]
}

class BumblerSpeech
  constructor: (options = {}) ->
    if typeof options is "string"
      @player = document.querySelector(options)
      @numberQueue = []
      @playing = false
    else
      mergedOptions = $.extend({}, defaultOptions, options)
      @player = document.querySelector(mergedOptions.player)
      @numberQueue = mergedOptions.numbers
      @playing = false

    $(@).on 'speechEnd', =>
      delay 300, ->
        currentNumber = speaker.numberQueue.shift()
        if currentNumber is undefined or null
          speaker.playing = false
          return
        speaker.playNumber(currentNumber)

  playPartial: (partialIndex, rate = 1.0) ->
    partial = AUDIO_MAP[partialIndex]
    @player.currentTime = partial.start
    @player.play()

    duration = partial.duration / rate * 1000

    setTimeout( =>
      @player.pause()
    , duration)

  playSequence: (indexQueue) ->
    audioEventHandler = =>
      @player.removeEventListener('pause', audioEventHandler)
      queueIterate()

    queueIterate = =>
      currentIndex = indexQueue.shift()
      playbackRate = 0.9

      if currentIndex is undefined or null
        $(@).trigger('speechEnd')
        return false

      if indexQueue.length > 0
        playbackRate = if currentIndex is "d10" then 1.55 else 1.20

      @player.addEventListener('pause', audioEventHandler)
      @playPartial(currentIndex, playbackRate)

    queueIterate()

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
    speechQueue = @numberToSpeechQueue(number)
    @playSequence(speechQueue)

  play: ->
    $(@).trigger('speechEnd') if !@playing
    @playing = true


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

    speaker.numberQueue = [numberToPlay]
    speaker.play()

    event.preventDefault()

  $('#btn-countup').on 'click', (event) ->
    numberToPlay = checkInput()

    if numberToPlay
      speaker.numberQueue = [1..numberToPlay]
      speaker.numberQueue.push "thank"
      speaker.play()

    event.preventDefault()

  $('#btn-countdown').on 'click', (event) ->
    numberToPlay = checkInput()

    if numberToPlay
      speaker.numberQueue = [numberToPlay..1]
      speaker.numberQueue.push "thank"
      speaker.play()

    event.preventDefault()

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
    else
      mergedOptions = $.extend({}, defaultOptions, options)
      @player = document.querySelector(mergedOptions.player)
      @numberQueue = mergedOptions.numbers

  playPartial: (partialIndex) ->
    partial = AUDIO_MAP[partialIndex]
    @player.currentTime = partial.start
    @player.play()

    setTimeout( =>
      @player.pause()
    , partial.duration*1000)

  playSequence: (indexQueue) ->
    audioEventHandler = =>
      @player.removeEventListener('pause', audioEventHandler)
      queueIterate()

    queueIterate = =>
      curentIndex = indexQueue.shift()

      if curentIndex is undefined or null
        $(@).trigger('speechEnd')
        return false

      @player.addEventListener('pause', audioEventHandler)
      @playPartial(curentIndex)

    queueIterate()

  numberToSpeechQueue: (number) ->
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
      speaker.play()

    event.preventDefault()

jQuery = require 'jquery'

jQuery ($) ->
  currentIndex = 0
  slideshowContainer = $('.slideshow-container')
  numberOfImages = $('ul.images li').size()

  $('ul.images li', slideshowContainer).each (i,e) ->
    $li = $(e)
    $li.hide()
  $('ul.images li', slideshowContainer).eq(currentIndex).show()

  showImage = (nextIndex) ->
    $nextIndexElement = $('ul.images li', slideshowContainer).eq(nextIndex)
    $currentIndexElement = $('ul.images li', slideshowContainer).eq(currentIndex)

    $nextIndexElement.css('z-index', 2)
    $nextIndexElement.stop().fadeIn(250)

    $currentIndexElement.css('z-index', 1)
    $currentIndexElement.stop().delay(250).fadeOut()

    return

  intervalHandler = window.setInterval(->
    nextIndex = currentIndex + 1
    nextIndex = nextIndex % numberOfImages

    showImage(nextIndex)

    currentIndex = nextIndex
  ,5000)

  $('a.previousButton').on 'click', (event) ->
    event.preventDefault()

    clearInterval(intervalHandler)
    nextIndex = currentIndex - 1
    nextIndex = nextIndex % numberOfImages

    showImage(nextIndex)

    currentIndex = nextIndex
    return

  $('a.nextButton').on 'click', (event) ->
    event.preventDefault()

    clearInterval(intervalHandler)
    nextIndex = currentIndex + 1
    nextIndex = nextIndex % numberOfImages

    showImage(nextIndex)

    currentIndex = nextIndex
    return
  return

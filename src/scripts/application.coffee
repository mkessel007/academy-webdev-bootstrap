jQuery = require 'jquery'

jQuery ($) ->
  currentIndex = 0
  slideshowContainer = $('.slideshow-container')
  numberOfImages = $('ul.images li').size()
  $('ul.images li', slideshowContainer).each (i,e) ->
    $li = $(e)
    $li.hide()
  $('ul.images li', slideshowContainer).eq(currentIndex).show()

  window.setInterval(->
    nextIndex = currentIndex + 1
    nextIndex = nextIndex % numberOfImages
    $nextIndexElement = $('ul.images li', slideshowContainer).eq(nextIndex)
    $currentIndexElement = $('ul.images li', slideshowContainer).eq(currentIndex).delay(250)

    $nextIndexElement.css('z-index', 2)
    $nextIndexElement.fadeIn(250)

    $currentIndexElement.css('z-index', 1)
    $currentIndexElement.fadeOut()

    currentIndex = nextIndex
  ,1000)
  return

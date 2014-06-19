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
    $('ul.images li', slideshowContainer).eq(nextIndex).fadeIn(250)
    $('ul.images li', slideshowContainer).eq(currentIndex).delay(250).fadeOut()
    currentIndex = nextIndex
  ,1000)
  return

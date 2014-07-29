es             = require 'event-stream'
gulp           = require 'gulp'
gutil          = require 'gulp-util'
runSequence    = require 'run-sequence'
clean          = require 'gulp-clean'
concat         = require 'gulp-concat'
compass        = require 'gulp-compass'
haml           = require 'gulp-ruby-haml'
coffeelint     = require 'gulp-coffeelint'
cssmin         = require 'gulp-cssmin'
rename         = require 'gulp-rename'
uglify         = require 'gulp-uglify'
notify         = require 'gulp-notify'
refresh        = require 'gulp-livereload'
express        = require 'express'
livereload     = require 'connect-livereload'
tinylr         = require 'tiny-lr'
fs             = require 'fs'
source         = require 'vinyl-source-stream'
watchify       = require 'watchify'
coffeeify      = require 'coffeeify'
plumber        = require 'gulp-plumber'

###############################################################################
# constants
###############################################################################

BASES =
  src: './src'
  build: './build'

SERVER_PORT       = 3456
LIVE_RELOAD_PORT  = 35729

VENDOR_DIR        = "./#{BASES.src}/scripts/vendor/"
SCRIPTS_BUILD_DIR = "#{BASES.build}/scripts"

EXTERNALS         = [
  { require: "lodash", expose: 'underscore' }
  { require: "jquery", expose: 'jquery' }
  { require: "rsvp",   expose: 'rsvp' }
]

lrserver = tinylr()

server = express()
server.use(livereload(
  port: LIVE_RELOAD_PORT
))
server.use(express.static(BASES.build))

###############################################################################
# clean
###############################################################################

gulp.task 'clean', ->
  gulp.src(BASES.build).pipe(clean())

###############################################################################
# haml
###############################################################################

gulp.task 'haml', ->
  gulp.src(["#{BASES.src}/**/*.haml", "!#{BASES.src}/pages/**/_*"])
    .pipe(plumber())
    .pipe(haml())
    .on('error', notify.onError({ onError: true }))
    .on('error', gutil.log)
    .on('error', gutil.beep)
    .pipe(gulp.dest("#{BASES.build}"))
    .pipe(refresh(lrserver))

###############################################################################
# coffeelint
###############################################################################

gulp.task 'coffeelint', ->
  gulp.src('#{BASES.src}/scripts/**/*.coffee')
    .pipe(plumber())
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())

###############################################################################
# compass
###############################################################################

gulp.task 'compass', ->
  gulp.src(["#{BASES.src}/stylesheets/**/*.{css,scss,sass}", "!#{BASES.src}/pages/**/_*"])
    .pipe(plumber())
    .pipe(compass(
      config_file: './config.rb'
      css: "build/stylesheets",
      sass: "src/stylesheets"
    ))
    .on('error', notify.onError({ onError: true }))
    .on('error', gutil.log)
    .on('error', gutil.beep)
    .pipe(gulp.dest("#{BASES.build}/stylesheets"))
    .pipe(refresh(lrserver))

###############################################################################
# copy
###############################################################################

gulp.task 'copy', ->
  gulp.src("#{BASES.src}/assets/**")
    .pipe(plumber())
    .pipe(gulp.dest("#{BASES.build}/assets"))
    .pipe(refresh(lrserver))

###############################################################################
# uglify:all
###############################################################################

gulp.task 'uglify:all', ->
  gulp.src('#{BASES.build}/scripts/*.js')
    .pipe(plumber())
    .pipe(uglify())
    .pipe(rename({ suffix: '.min' }))
    .pipe(gulp.dest("#{BASES.build}/scripts"))

###############################################################################
# cssmin:minify
###############################################################################

gulp.task 'cssmin:minify', ->
  gulp.src('#{BASES.build}/stylesheets/*.css')
    .pipe(plumber())
    .pipe(cssmin())
    .pipe(rename({ suffix: '.min' }))
    .pipe(gulp.dest("#{BASES.build}/stylesheets"));

###############################################################################
# Browserify
###############################################################################

requireExternals = (bundler, externals) ->
  for external in externals
    if external.expose?
      bundler.require external.require, expose: external.expose
    else
      bundler.require external.require

gulp.task 'watchify', ->
  console.log 'watchify'
  entry = "#{BASES.src}/scripts/application.coffee"
  output = 'application.js'
  bundler = watchify entry
  bundler.transform coffeeify
  requireExternals bundler, EXTERNALS

  rebundle = ->
    console.log "rebundle"
    stream = bundler.bundle()
    stream.on 'error', notify.onError({ onError: true })
      .pipe(plumber())
      .pipe(source(output))
      .pipe(gulp.dest(SCRIPTS_BUILD_DIR))
      .pipe(refresh(lrserver))
    stream

  bundler.on 'update', rebundle
  rebundle()

###############################################################################
# watch
###############################################################################

gulp.task 'watch', ->
  gulp.watch "#{BASES.src}/**/*.haml", ['build:markup']
  gulp.watch "#{BASES.src}/assets/**/*", ['copy']
  gulp.watch "#{BASES.src}/stylesheets/**/*.{css,scss,sass}", ['build:stylesheets']

###############################################################################
# serve
###############################################################################

gulp.task 'serve', ->
  server.listen SERVER_PORT
  lrserver.listen LIVE_RELOAD_PORT

###############################################################################
# high level tasks
###############################################################################

gulp.task 'build:markup', ['copy', 'haml']
gulp.task 'build:scripts', ->
  runSequence 'coffeelint', 'watchify', 'uglify:all'
gulp.task 'build:stylesheets', ->
  runSequence 'compass', 'cssmin:minify'

gulp.task 'build', ->
  console.log 'browserify:sequence'
  seq = runSequence(
    'clean',
    [
      'build:markup'
      'build:scripts'
      'build:stylesheets'
    ],
    [
      'serve'
      'watch'
    ]

  )
  seq

gulp.task 'default', ['build']

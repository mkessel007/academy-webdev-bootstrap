es              = require 'event-stream'
gulp            = require 'gulp'
fs              = require 'fs'
source          = require 'vinyl-source-stream'
browserify      = require 'browserify'
watchify        = require 'watchify'
coffeeify       = require 'coffeeify'
runSequence     = require 'run-sequence'
gulpLoadPlugins = require 'gulp-load-plugins'
browserSync     = require 'browser-sync'
reload          = browserSync.reload
$               = gulpLoadPlugins()
isProduction    = false

###############################################################################
# constants
###############################################################################

BASES =
  src: './src'
  build: './build'

SERVER_PORT       = 3456

VENDOR_DIR        = "./#{BASES.src}/scripts/vendor/"
SCRIPTS_BUILD_DIR = "#{BASES.build}/scripts"

EXTERNALS         = [
  { require: "lodash", expose: 'underscore' }
  { require: "jquery", expose: 'jquery' }
  { require: "rsvp",   expose: 'rsvp' }
]
###############################################################################
# clean
###############################################################################
gulp.task 'set-production', ->
  isProduction = true

###############################################################################
# clean
###############################################################################

gulp.task 'clean', ->
  gulp.src(BASES.build).pipe($.clean())

###############################################################################
# haml
###############################################################################

gulp.task 'haml', ->
  gulp.src(["#{BASES.src}/**/*.haml", "!#{BASES.src}/pages/**/_*"])
    .pipe($.plumber())
    .pipe($.rubyHaml())
    .on('error', $.notify.onError({ onError: true }))
    .on('error', $.util.log)
    .on('error', $.util.beep)
    .pipe(gulp.dest("#{BASES.build}"))
    .pipe($.if(!isProduction, reload({ stream: true, once: true })))

###############################################################################
# coffeelint
###############################################################################

gulp.task 'coffeelint', ->
  gulp.src('#{BASES.src}/scripts/**/*.coffee')
    .pipe($.plumber())
    .pipe($.coffeelint())
    .pipe($.coffeelint.reporter())

###############################################################################
# compass
###############################################################################

gulp.task 'compass', ->
  gulp.src(["#{BASES.src}/stylesheets/**/*.{css,scss,sass}", "!#{BASES.src}/pages/**/_*"])
    .pipe($.plumber())
    .pipe($.compass(
      config_file: './config.rb'
      css: "build/stylesheets",
      sass: "src/stylesheets"
    ))
    .on('error', $.notify.onError({ onError: true }))
    .on('error', $.util.log)
    .on('error', $.util.beep)
    .pipe(gulp.dest("#{BASES.build}/stylesheets"))
    .pipe($.if(!isProduction, reload({ stream: true, once: true })))

###############################################################################
# copy
###############################################################################

gulp.task 'copy', ->
  gulp.src("#{BASES.src}/assets/**")
    .pipe($.plumber())
    .pipe(gulp.dest("#{BASES.build}/assets"))
    .pipe($.if(!isProduction, reload({ stream: true, once: true })))

###############################################################################
# uglify:all
###############################################################################

gulp.task 'uglify:all', ->
  gulp.src('#{BASES.build}/scripts/*.js')
    .pipe($.plumber())
    .pipe($.uglify())
    .pipe($.rename({ suffix: '.min' }))
    .pipe(gulp.dest("#{BASES.build}/scripts"))

###############################################################################
# cssmin:minify
###############################################################################

gulp.task 'cssmin:minify', ->
  gulp.src('#{BASES.build}/stylesheets/*.css')
    .pipe($.plumber())
    .pipe($.cssmin())
    .pipe($.rename({ suffix: '.min' }))
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
  if isProduction
    bundler = browserify(entry)
  else
    bundler = watchify(entry)
  bundler.transform coffeeify
  requireExternals bundler, EXTERNALS

  rebundle = ->
    console.log "rebundle"
    stream = bundler.bundle()
    stream.on 'error', $.notify.onError({ onError: true })
      .pipe($.plumber())
      .pipe(source(output))
      .pipe(gulp.dest(SCRIPTS_BUILD_DIR))
      .pipe($.if(!isProduction, reload({ stream: true, once: true })))
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
  browserSync({
    notify: false,
    server: {
      baseDir: [BASES.build]
    },
    ports: {
      min: SERVER_PORT
    }
  })
  console.log "Point your browser to #{SERVER_PORT}"

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
    ]
  )
  seq

gulp.task 'heroku', ->
  runSequence('set-production', 'build')
gulp.task 'default', ->
  runSequence('build', 'serve', 'watch')

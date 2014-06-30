# Web Development Bootstrap (with Gulp)

This repository contains some of the 9elements best practices for front-end web development. Using gulp as a build tool to compile coffeescript into javascript then minify it and solving dependencies from browserify. Also .sass or .scss files can be compiled with this neat script.

# Usage

Using the gulp task is easy as hell, just run the following command and you are ready to go:

```
gulp build:markup        # Run the markup build task (copying assets and compiling HAML)
gulp build:scripts       # Run the scripts build task (Coffeelint, Watchify, Uglify:all)
gulp build:stylesheets   # Run the stylesheets build task (Running compass and css minifying)

gulp build               # Run every build task in sequence
gulp                     # Just a synonym for gulp build
```

Other than this you can also execute the following tasks to run a specific task of the Gulpfile.

#### Cleaning

The `gulp clean` task can be used for cleaning folders or files. With our configuration it is cleaning up the `./build` folder.

#### Compile HAML

The `gulp haml` task can be used for compiling the .haml files. With our configuration it is compiling all .haml files in  `./src` folder.

#### Coffeelint

The `gulp coffeelint` task can be used for linting coffeescript files. With our configuration it is linting all .coffee files in the `./src` folder.

#### Compass

The `gulp compass` task can be used for applying compass onto your css. Configuration can be viewed in `config.rb`

#### Copy

The `gulp copy` task can be used for copying all assets into the build folder.

#### Uglify javascript

The `gulp uglify:all` task can be used for uglifying your javascript code. With out configuration it is uglifying every .js file in `./build/scripts`.

#### Minify CSS

The `gulp cssmin:minify` task can be used for minifying your stylesheets. With our configuration it is minifying every .css file in `./build/stylesheets/`

#### Browserify

The `gulp browserify` task can be used for solving the dependencies from javascript files and compiling coffeescript.

#### Watch

The `gulp watch` task can be used for watching all assets, haml files and stylesheets and run the specific task when needed.

#### Serve

The `gulp serve` task can be used for serving a local server to view your current page under `http://localhost:3456` and serving a LiveReload server on port `35729`.


### Tools we are using

  - gulp (as build tool)
  - browserify via watchify
  - CoffeeScript
  - scss / sass
  - React.js
  - Bundler

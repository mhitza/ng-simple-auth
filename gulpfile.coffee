gulp      = require 'gulp'
coffee    = require 'gulp-coffee'
concat    = require 'gulp-concat'
uglify    = require 'gulp-uglify'
rimraf    = require 'rimraf'
paths     =
  coffee: 'src/**/*.coffee'

gulp.task 'clean', (done) ->
  rimraf './dist', done

gulp.task 'build', ->
  gulp.src paths.coffee
  .pipe coffee()
  .pipe concat 'app.js'
  .pipe gulp.dest 'dist'
  .pipe uglify()
  .pipe concat 'app.min.js'
  .pipe gulp.dest 'dist'

gulp.task 'default', ['clean', 'build']
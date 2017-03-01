'use strict';

var gulp = require('gulp');
var sass = require('gulp-sass');
var browserSync = require('browser-sync').create();

gulp.task('sass', function() {
    return gulp.src('./public/sass/*.scss')
        .pipe(sass().on('error', sass.logError))
        .pipe(gulp.dest('./public/css/'))
	.pipe(browserSync.reload({
		stream: true
	}))
});

gulp.task('browserSync', function() {
  browserSync.init({
    server: {
      baseDir: './public'
    },
  })
})

//Watch task
gulp.task('watch', ['browserSync', 'sass'], function() {
    gulp.watch('./public/sass/*.scss',['sass']);
});

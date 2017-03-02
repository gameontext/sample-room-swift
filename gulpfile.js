'use strict';

var gulp = require('gulp');
var sass = require('gulp-sass');
var browserSync = require('browser-sync').create();

var webpack = require('webpack-stream');
var child = require('child_process');

var server = null;

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

gulp.task('webpack', function() {
    return gulp.src('./public')
          .pipe(webpack( require('./webpack.config.js')))
          .pipe(gulp.dest('./public/'));
          });

gulp.task('develop', ['webpack','compile:swift','run:server','watch']);

//Watch task
gulp.task('watch', ['browserSync', 'sass'], function() {
    gulp.watch('./public/sass/*.scss',['sass']);
    gulp.watch('./Sources/**/*.swift', ['compile:swift','run:server']);
    gulp.watch('./public/*.js', ['webpack'])
});

gulp.task('compile:swift', function() {
    return child.spawnSync('swift', ['build'], {
        cwd: '.'
    })
});

gulp.task('run:server', function() {
    if (server)
        server.kill();
        server = child.spawn('./GameOn', [], {
            cwd: './.build/debug'
        });
        server.stderr.on('data', function(data) {
            process.stdout.write(data.toString());
        });
});

gulp.task('default', ['webpack','sass','compile:swift']);

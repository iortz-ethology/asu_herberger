var gulp = require('gulp');
var shell = require('gulp-shell');
var browserSync = require('browser-sync').create();
var sass = require('gulp-sass');
var $ = require('gulp-load-plugins')();
var sourcemaps = require('gulp-sourcemaps');
var filter = require('gulp-filter');
var imagemin = require('gulp-imagemin');
var postcss = require('gulp-postcss');
var autoprefixer = require('gulp-autoprefixer');
var sasspaths = [
  'node_modules/foundation-sites/scss',
  'node_modules/motion-ui/src'
];

gulp.task('build', shell.task(['jekyll serve --incremental']));

gulp.task('copy', function () {
  return gulp.src([
    './node_modules/jquery/dist/jquery.js',
    './node_modules/what-input/dist/what-input.js',
    './node_modules/foundation-sites/dist/js/foundation.min.js'])
    .pipe(gulp.dest('js'));
});

gulp.task('sass', function () {
  return gulp.src('css/*.scss')
    .pipe($.sass({ includePaths: sasspaths })).on('error', $.sass.logError)
    .pipe(sourcemaps.init())
    .pipe(postcss([autoprefixer()]))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest('_site/css'))
    .pipe(sass())
    .pipe(filter('**/*.css'))
    .pipe(browserSync.stream());
});

gulp.task('imagemin', function () {
  gulp.src('images/*')
    .pipe(imagemin())
    .pipe(gulp.dest('_site/images'));
});

gulp.task('serve', ['sass'], function () {
  browserSync.init({ server: { baseDir: '_site/' }});
  gulp.watch('*/**/*.scss', ['sass']);
  gulp.watch('_site/**/*.*').on('change', browserSync.reload);
});

gulp.task('default', ['build', 'serve', 'imagemin', 'copy']);
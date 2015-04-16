var gulp            = require('gulp'),
    gutil           = require('gulp-util'),
    styl            = require('gulp-stylus'),
    jeet            = require('jeet'),
    coffee          = require('gulp-coffee'),
    concat          = require('gulp-concat'),
    uglify          = require('gulp-uglify'),
    sourcemaps      = require('gulp-sourcemaps'),
    connect         = require('gulp-connect'),
    imageminOptipng = require('imagemin-optipng'),
    gulpEnv         = require('gulp-env'),
    plumber         = require('gulp-plumber'),
    babel           = require('gulp-babel'),
    babelify        = require('babelify'),
    browserify      = require('browserify'),
    source          = require('vinyl-source-stream'),

    // Input files
    input = {
      'styles': 'src/stylus/**/*.styl',
      'scripts': 'src/coffeescript/**/*.coffee',
      'html': 'src/**/*.html',
      'images': 'src/images/**/*.png',
      'vendor': {
        'css': 'src/vendor/css/**/*.css',
        'js': 'src/vendor/js/**/*.js'
      }
    },
    // Output files
    output = {
      'css': 'dist/css',
      'js': 'dist/js',
      'html': 'dist',
      'images': 'dist/images'
    };

// Default task
gulp.task('default', [
  'build-vendor',
  'build-html',
  'build-coffee',
  'build-styl',
  // 'build-images',
  'connect',
  'watch'
]);

// Build production
gulp.task('build-prod', [
  'env-prod',
  'build-vendor',
  'build-html',
  'build-coffee',
  'build-styl',
  'build-images'
]);

// Build stylus styles
gulp.task('build-styl', function() {
  return gulp.src(input.styles)
    .pipe(plumber())
    .pipe(sourcemaps.init())
    .pipe(styl({use: [jeet()]}))
    .pipe(concat('styles.css'))
    .pipe(gutil.env.type === 'production' ? uglify() : gutil.noop())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(output.css))
    .pipe(connect.reload());
});

// Build coffescript into js
gulp.task('build-coffee', function() {
  return gulp.src(input.scripts)
    .pipe(plumber())
    .pipe(sourcemaps.init())
    .pipe(coffee())
    .pipe(concat('app.js'))
    .pipe(gutil.env.type === 'production' ? uglify() : gutil.noop())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(output.js))
    .pipe(connect.reload());
});

// Copy HTML to dist
gulp.task('build-html', function() {
  return gulp.src(input.html)
    .pipe(gulp.dest(output.html))
    .pipe(connect.reload());
});

// Build images
gulp.task('build-images', function() {
  return gulp.src(input.images)
    .pipe(imageminOptipng({optimizationLevel: 3})())
    .pipe(gulp.dest(output.images))
    .pipe(connect.reload());
});

// Run livereload
gulp.task('connect', function() {
  connect.server({
    root: output.html,
    livereload: true
  });
});

// Set gulp env to prod
gulp.task('env-prod', function(){
  // gutil.env.type = 'production';
});

// Build vendor assets
gulp.task('build-vendor', function() {
  gulp.src(input.vendor.css)
    .pipe(concat('vendor.css'))
    .pipe(gulp.dest(output.css))
    .pipe(connect.reload());

  gulp.src(input.vendor.js)
    .pipe(concat('vendor.js'))
    .pipe(gulp.dest(output.js))
    .pipe(connect.reload());
});

// Watch files
gulp.task('watch', function() {
  gulp.watch(input.scripts, ['build-coffee']);
  gulp.watch(input.styles, ['build-styl']);
  gulp.watch(input.html, ['build-html']);
  gulp.watch(input.images, ['build-images']);
  gulp.watch(input.vendor.js, ['build-vendor']);
  gulp.watch(input.vendor.css, ['build-vendor']);
});

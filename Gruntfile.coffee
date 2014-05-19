module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  lang = 'en-US'
  langFile = lang + '.lang.json'

  options = 
    langName: lang
    lang: grunt.file.readJSON(langFile)
    development: true
    libs: [
      "angular/angular.js"
      "angular-resource/angular-resource.js"
    ]

  grunt.initConfig
    options: options
    less:
      build:
        src: 'less/style.less'
        dest: 'build/style.css'
    copy:
      libs:
        expand: true
        cwd: 'bower_components/'
        src: options.libs
        flatten: true
        dest: 'build/libs/'
      fonts:
        expand: true
        cwd: 'bower_components/bootstrap/fonts'
        src: '**'
        dest: 'build/fonts/'
      assets:
        src: 'assets/**'
        dest: 'build/'
    coffee:
      options:
        bare: true
        join: true
      build:
        src: 'coffee/**/*.coffee'
        dest: 'build/app.js'
    clean:
      options:
        force: true
      all: [
        'build/**'
      ]
    jade:
      options:
        pretty: true
        data: options
      build:
        expand: true
        cwd: 'jade'
        src: '**/*.jade'
        dest: 'build'
        ext: '.html'
        extDot: 'last'
        rename: (dest, src) ->
          return dest + '/' + src.replace(/\//g, '-')
    watch:
      options:
        atBegin: true
        livereload: true
      gruntfile:
        files: 'Gruntfile.coffee'
        tasks: ['default']
      less:
        cwd: 'less'
        files: '**/*.less'
        tasks: ['less']
      assets:
        files: '<%= copy.assets.src %>'
        tasks: ['copy:assets']
      coffee:
        files: '<%= coffee.build.src %>'
        tasks: ['coffee']
      jade:
        cwd: '<%= jade.build.cwd %>'
        files: '<%= jade.build.src %>'
        tasks: ['jade']
      langs:
        files: langFile
        tasks: ['jade']

  grunt.registerTask('default', ['less', 'copy', 'coffee', 'jade'])
  grunt.registerTask('rebuild', ['clean:all', 'default'])

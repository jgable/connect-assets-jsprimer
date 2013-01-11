fs = require "fs"

watchr = require "watchr"

class FileLoader
  constructor: (@assetsModule, @log, skipHidden) ->
    @assets = assetsModule.instance
    @assetJS = @assets.options.helperContext.js
    @jsFilesRoot = "#{@assets.options.src}/#{@assetJS.root}"

  loadFiles: ->
    @_loadJSFileOrDirectory @jsFilesRoot

  _loadJSDirectory: (dirPath) ->
    paths = fs.readdirSync dirPath
  
    @_loadJSFileOrDirectory "#{dirPath}/#{path}" for path in paths
    true

  _loadJSFileOrDirectory: (path) ->
    stat = fs.statSync path
    if stat?.isDirectory()
      @_loadJSDirectory path
    else
      # Remove the js extension if any
      assetName = ((path.replace @jsFilesRoot, '').replace '.js', '').slice 1

      # Remove all the compiler extensions
      for ext, compiler of @assetsModule.jsCompilers
        assetName = assetName.replace ".#{ext}", ''

      # Skip if a hidden file
      return if "." == assetName.split("/")[assetName.split("/").length - 1][0]
      
      @log?("Assetizing #{assetName}")
      @assetJS assetName

  watchFiles: (fileChangedCallback, done) ->

    watchOptions = 
      # Watch our js root
      path: @jsFilesRoot

      # When a file is changed, run this
      listener: (evt, filePath, fileStat, filePrevStat) =>
        @_loadJSFileOrDirectory filePath
        fileChangedCallback?(null, filePath)
      
      # Wait til we're ready before continuing
      next: (err, watchr) ->
        done(err, watchr)

    # Let's light this candle
    watchr.watch watchOptions

module.exports = FileLoader

fs = require "fs"
path = require "path"

watchr = require "watchr"

class FileLoader
  constructor: (@assetsModule, @log, skipHidden) ->
    @assets = @assetsModule.instance
    @assetJS = @assets.options.helperContext.js
    @jsFilesRoot = path.join @assets.options.src, @assetJS.root

  loadFiles: ->
    @_loadJSFileOrDirectory @jsFilesRoot

  _loadJSDirectory: (dirPath) ->
    paths = fs.readdirSync dirPath

    @_loadJSFileOrDirectory path.join(dirPath, filePath) for filePath in paths
    true

  _loadJSFileOrDirectory: (sourcePath) ->
    stat = fs.statSync sourcePath
    if stat?.isDirectory()
      @_loadJSDirectory sourcePath
    else
      # Get the relative path to the jsFilesRoot
      assetName = path.relative @jsFilesRoot, sourcePath

      # Remove the extension from the file
      assetName = assetName.replace path.extname(assetName), ''

      # Remove all the compiler extensions
      for ext, compiler of @assetsModule.jsCompilers
        assetName = assetName.replace ".#{ext}", ''

      # Skip if a hidden file
      return if "." is path.basename(assetName).slice(0, 1)

      # connet-assets will not route correctly with '\' in the name.
      # Replacing them to so that connect-assets will have the correct c
      assetName = assetName.replace /\\/g, '/'

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

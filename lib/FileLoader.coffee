fs = require "fs"

class FileLoader
  constructor: (assetsModule, @log, skipHidden) ->
    @assets = assetsModule.instance
    @assetJS = @assets.options.helperContext.js
    @jsFilesRoot = @assets.options.src + "/js"

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
      assetName = (((path.replace @jsFilesRoot, "").replace ".coffee", "").replace ".js", "").slice 1

      # Skip if a hidden file
      return if assetName[0] == "."
      
      @log?("Assetizing #{assetName}")
      @assetJS assetName

module.exports = FileLoader
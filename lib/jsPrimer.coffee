fs = require "fs"

loadFiles = (assetsModule, log) ->
  assets = assetsModule.instance
  assetJS = assets.options.helperContext.js
  jsFilesRoot = assets.options.src + "/js"
  
  loadJSFileOrDirectory = (path) ->
    stat = fs.statSync path
    if stat?.isDirectory()
      loadJSDirectory path
    else
      assetName = (((path.replace jsFilesRoot, "").replace ".coffee", "").replace ".js", "").slice 1
      log?("Assetizing #{assetName}")
      assetJS assetName

  loadJSDirectory = (dirPath) ->
    paths = fs.readdirSync dirPath
  
    loadJSFileOrDirectory "#{dirPath}/#{path}" for path in paths
    true

  loadJSFileOrDirectory jsFilesRoot

module.exports = (assets, log) ->
    loadFiles assets, log
fs = require "fs"
FileLoader = require "./FileLoader"

module.exports = (assets, log) ->
  loader = new FileLoader assets, log

  do loader.loadFiles
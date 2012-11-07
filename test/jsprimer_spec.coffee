should = require "should"
FileLoader = require "../lib/FileLoader"

describe "FileLoader", ->

	assetsMock = null
	loader = null

	beforeEach ->
		assetsMock = 
			instance: 
				options:
					helperContext:
						js: (path) ->
							# TODO: Something?
					src: process.cwd() + "/test/assets"

		loader = new FileLoader assetsMock

	it "can instantiate", ->
		should.exist loader

	it "can load files from connect-assets src directory", ->
		fileNames = ["one", "two", "three", "model/book", "view/shelf", "controller/library"]
		called = 0
		loader.assetJS = (path) ->
			called++
			(path in fileNames).should.equal true

		loader.loadFiles()
		called.should.equal fileNames.length

	it "skips files with leading '.'", ->
		filesLoaded = []
		loader.assetJS = (path) ->
			filesLoaded.push path

		loader.loadFiles()
		(".hidden.swp" in filesLoaded).should.equal false
		("test/.hidden.swp" in filesLoaded).should.equal false

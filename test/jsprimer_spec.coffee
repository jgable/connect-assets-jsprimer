fs = require "fs"

should = require "should"

assets = require 'connect-assets'
path = require 'path'

FileLoader = require "../lib/FileLoader"

describe "FileLoader", ->

	loader = null
	testRoot = path.join process.cwd(), "test/assets"

	toEditFilePath = path.join testRoot, "js/new.coffee"
	toEditFilePathWin = path.join testRoot, "js/new-win.coffee"
	
	fileNames = [
		"one", 
		"two", 
		"three", 
		# specifically the seperator needs to be a '/' to route corretly in connect-assets
		"model/book", 
		"view/shelf", 
		"controller/library",
		"admin/user/account"
	]
	
	removeNewFiles = ->
		if fs.existsSync toEditFilePath
			fs.unlinkSync toEditFilePath
		if fs.existsSync toEditFilePathWin
			fs.unlinkSync toEditFilePathWin

	beforeEach ->
		removeNewFiles()

		assets (
			src: testRoot
			helperContext: {}
		)
		loader = new FileLoader assets

	afterEach ->
		removeNewFiles()

	it "can instantiate", ->
		should.exist loader

	it "can load files from connect-assets src directory", ->
		called = 0
		loader.assetJS = (path) ->
			called++
			(path in fileNames).should.equal true, path

		loader.loadFiles()
		called.should.equal fileNames.length

	it "can load files from connect-assets with relative src directory", ->
		assets
			src: 'test/assets'
			helperContext: {}
		
		loader = new FileLoader assets
		
		called = 0
		loader.assetJS = (path) ->
			called++
			(path in fileNames).should.equal true, path

		loader.loadFiles()
		called.should.equal fileNames.length
	
	it "skips files with leading '.'", ->
		filesLoaded = []
		loader.assetJS = (path) ->
			filesLoaded.push path

		loader.loadFiles()
		(".hidden.swp" in filesLoaded).should.equal false
		("test/.hidden.swp" in filesLoaded).should.equal false

	it "can monitor when files change", (done) ->
		called = 0
		loader.assetJS = (path) ->
			called++
		fileChangedCallback = (err, changedFilePath) ->
			throw err if err
			
			changedFilePath.should.equal toEditFilePath

			called.should.equal (fileNames.length + 1)

			done()

		loader.loadFiles()

		called.should.equal fileNames.length

		loader.watchFiles fileChangedCallback, (err, watcher) ->
			fs.writeFile toEditFilePath, "blah = 123\nother = 456", (err) ->
				throw err if err
				# Should have triggered the fileChangedCallback


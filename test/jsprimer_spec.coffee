should = require "should"
FileLoader = require "../lib/FileLoader"

describe "FileLoader", ->

	assetsMock = 
		instance: 
			options:
				helperContext:
					js: (path) ->
						# TODO: Something?
				src: "/assets"


	it "can instantiate", ->
		loader = new FileLoader assetsMock

		should.exist loader

	it "can load files"

	it "skips files with leading '.'"

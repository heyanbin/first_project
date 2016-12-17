#!/usr/bin/python
# -*- coding: UTF-8 -*-

import xml.sax
import sys

class MovieHandler( xml.sax.ContentHandler ):
	print "num\tretentionTime\tbasePeakMz\tbasePeakIntensity"
	def __init__(self):
		self.CurrentData = ""
		self.num = ""
		self.retentionTime = ""
		self.basePeakMz = ""
		self.basePeakIntensity = ""
	
	def startElement(self, tag, attributes):
		self.CurrentData = tag
		if tag == "scan":
			num = attributes["num"]
			retentionTime = attributes["retentionTime"]
			basePeakMz = attributes["basePeakMz"]
			basePeakIntensity = attributes["basePeakIntensity"]
			print num,"\t",retentionTime,"\t",basePeakMz,"\t",basePeakIntensity
		
if ( __name__ == "__main__"):
	
	# 创建一个 XMLReader
	parser = xml.sax.make_parser()
	# turn off namepsaces
	parser.setFeature(xml.sax.handler.feature_namespaces, 0)
	
	# 重写 ContextHandler
	Handler = MovieHandler()
	parser.setContentHandler( Handler )
	
	parser.parse(sys.argv[1])
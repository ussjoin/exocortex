#!ruby

require 'rubygems'

require 'exocortex/view'

trap('INT') { ExoCortex::View::shutdown }
at_exit { ExoCortex::View::shutdown }



ExoCortex::View.instance.run




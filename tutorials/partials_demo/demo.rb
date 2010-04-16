require 'rubygems'
require 'documatic'
require 'fileutils'

File.directory?('output') or FileUtils.mkdir('output')
FileUtils.cp 'master.odt', 'output'

t = Documatic::Template.new('output/master.odt')
t.process :people => [ {:given => 'Fred', :surname => 'Bloggs', :phone => '9876 5432'},
                       {:given => 'Mary', :surname => 'Smith',  :phone => '1234 5678'} ]
t.save ; t.close

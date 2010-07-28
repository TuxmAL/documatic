require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

spec = Gem::Specification.new do |s|
  s.name = 'documatic'
  s.version = '0.2.0'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'Documatic is an OpenDocument extension for Ruby Reports (Ruport). It is a template-driven formatter that can be used to produce attractive printable documents such as database reports, invoices, letters, faxes and more.'
  s.description = s.summary
  s.author = 'urbanus'
  s.email = 'urbanus@240gl.org'
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "testeach Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end

########################################à
##--- !ruby/object:Gem::Specification
##rubygems_version: 0.9.4
##specification_version: 1
##name: documatic
#version: !ruby/object:Gem::Version
##  version: 0.2.0
#date: 2008-04-26 00:00:00 +10:00
##summary: Documatic is an OpenDocument extension for Ruby Reports (Ruport). It is a template-driven formatter that can be used to produce attractive printable documents such as database reports, invoices, letters, faxes and more.
#require_paths:
##- lib
##email: urbanus@240gl.org
#homepage: http://stonecode.svnrepository.com/documatic/trac.cgi
#rubyforge_project: documatic
#description:
#autorequire: init.rb
#default_executable:
#bindir: bin
#has_rdoc: true
#required_ruby_version: !ruby/object:Gem::Version::Requirement
#  requirements:
#  - - ">"
#    - !ruby/object:Gem::Version
#      version: 0.0.0
#  version:
#platform: ruby
#signing_key:
#cert_chain:
#post_install_message:
#authors: []
#
#files:
#- lib/
#- lib/documatic.rb
#- lib/documatic/
#- lib/documatic/component.rb
#- lib/documatic/formatter/
#- lib/documatic/formatter/open_document.rb
#- lib/documatic/init.rb
#- lib/documatic/open_document_spreadsheet/
#- lib/documatic/open_document_spreadsheet/component.rb
#- lib/documatic/open_document_spreadsheet/helper.rb
#- lib/documatic/open_document_spreadsheet/template.rb
#- lib/documatic/open_document_text/
#- lib/documatic/open_document_text/component.rb
#- lib/documatic/open_document_text/helper.rb
#- lib/documatic/open_document_text/partial.rb
#- lib/documatic/open_document_text/template.rb
#- tests
#- README
#test_files: []
#
#rdoc_options:
#- --main
#- README
#- --inline-source
#extra_rdoc_files:
#- README
#executables: []
#
#extensions: []
#
#requirements: []
#
#dependencies:
#- !ruby/object:Gem::Dependency
#  name: rubyzip
#  version_requirement:
#  version_requirements: !ruby/object:Gem::Version::Requirement
#    requirements:
#    - - ">="
#      - !ruby/object:Gem::Version
#        version: 0.9.1
#    version:
#- !ruby/object:Gem::Dependency
#  name: ruport
#  version_requirement:
#  version_requirements: !ruby/object:Gem::Version::Requirement
#    requirements:
#    - - ">="
#      - !ruby/object:Gem::Version
#        version: 1.6.0
#    version:

#from http://blog.101ideas.cz/post/353002256/the-truth-about-gemspecs
# encoding: utf-8
require "base64"

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

spec = Gem::Specification.new do |s|
  s.name = 'documatic'
  s.version = '0.2.2'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'Documatic is an OpenDocument extension for Ruby Reports (Ruport). It is a template-driven formatter that can be used to produce attractive printable documents such as database reports, invoices, letters, faxes and more.'
  s.description = s.summary
  s.author = %q{"urbanus" "Antonio Liccardo" "Zachris Trolin"}
  #s.email = 'urbanus@240gl.org'
  s.email = Base64.decode64("dHV4bWFsQHRpc2NhbGkuaXQK\n")
  s.homepage = "http://github.com/tuxmal/documatic"
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  #s.files = FileList["lib/**/**", "tutorials/**/**/**"].to_a
  #s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.require_path = "lib"
  s.bindir = "bin"
  s.platform  = Gem::Platform::RUBY
  s.autorequire = "documatic.rb"
  s.add_dependency("rubyzip")
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end
                             
task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
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

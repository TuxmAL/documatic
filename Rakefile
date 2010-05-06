require 'rubygems'
require 'rake/gempackagetask'


spec = Gem::Specification.new do |s| 
  s.name = "documatic"
  s.version = "0.2.1"
  s.author = ["Dave Nelson", "Antonio Liccardo", "Zachris Trolin"]
  #s.email = ...
  s.homepage = "http://github.com/zachris/documatic"
  s.platform  =   Gem::Platform::RUBY
  s.summary = "Documatic: ruby reports templating of Open Document Text and Spreadsheet"
  s.files = FileList["lib/**/**", "tutorials/**/**/**"].to_a
  s.require_path = "lib"
  s.autorequire = "documatic.rb"
  #s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = false
  s.extra_rdoc_files = ["README"]
  s.add_dependency("ruport")
  s.add_dependency("rubyzip")
end
                             
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true
end 

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end

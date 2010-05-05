require 'rubygems'
require 'rake/gempackagetask'


spec = Gem::Specification.new do |s| 
  s.name = "documatic"
  s.version = "0.2.1"
  #s.author = "Zachris Trolin"
  #s.email = "zachris.trolin@gmail.com"
  s.homepage = "http://github.com/zachris/documatic"
  s.platform  =   Gem::Platform::RUBY
  s.summary = "Documatic fork, with better spreadsheet templating"
  s.files = FileList["lib/**/**", "tutorials/**/**/**"].to_a
  s.require_path = "lib"
  s.autorequire = "documatic.rb"
  #s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = false
  s.extra_rdoc_files = ["README"]
  s.add_dependency("ruport")
end
                             
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true
end 

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end

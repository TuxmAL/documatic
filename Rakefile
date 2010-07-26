require 'rubygems'
require 'rake/gempackagetask'
#from http://blog.101ideas.cz/post/353002256/the-truth-about-gemspecs
# encoding: utf-8
require "base64"


spec = Gem::Specification.new do |s| 
  s.name = "documatic"
  s.version = "0.2.2"
  s.author = %q{"Dave Nelson" "Antonio Liccardo" "Zachris Trolin"}
  s.homepage = "http://github.com/tuxmal/documatic"
  s.email = Base64.decode64("dHV4bWFsQHRpc2NhbGkuaXQK\n")
  s.platform  = Gem::Platform::RUBY
  s.summary = "Documatic: ruby reports templating of Open Document Text and Spreadsheet"
  s.description = <<EOF
Documatic: ruby reports templating of Open Document Text and Spreadsheet.
Useful as a standalone generator, may be used in conjunction with Ruport.
See examples in the tutorial section.
EOF

  s.files = FileList["lib/**/**", "tutorials/**/**/**"].to_a
  s.require_path = ["lib"]
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

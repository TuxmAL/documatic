  Gem::Specification.new do |s|
    s.platform    = Gem::Platform::RUBY
    s.name = 'documatic'
    s.version = '0.3.0.pre'
    s.has_rdoc = false
    s.extra_rdoc_files = ['README', 'LICENSE']
    s.summary = 'Documatic is a template-driven formatter that can be used to produce attractive printable OpenDocument documents such as reports, invoices, letters, faxes and more.'
    s.description = s.summary
    s.author = %q{"urbanus" "Antonio Liccardo" "Zachris Trolin"}
    #s.email = 'urbanus@240gl.org'
    s.email = Base64.decode64("dHV4bWFsQHRpc2NhbGkuaXQK\n")
    s.required_ruby_version     = '>= 2.0.0'
    s.required_rubygems_version = '>= 1.3.6'
    s.date              = %q{2019-04-06}
    s.homepage = "http://github.com/tuxmal/documatic"
    # s.executables = ['your_executable_here']
    s.files = %w(LICENSE README Rakefile Gemfile documatic.gemspec) + Dir.glob("{bin,lib,spec}/**/*")
    s.require_paths = ['lib']
    s.bindir = "bin"
    s.platform  = Gem::Platform::RUBY
    s.autorequire = "documatic.rb"
    s.add_runtime_dependency('rubyzip', '>= 1.2.0')
    s.add_development_dependency 'rake'
  end

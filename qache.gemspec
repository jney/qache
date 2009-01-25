spec = Gem::Specification.new do |s|
  s.name                      = "qache"
  s.version                   = "0.0.1"
  s.platform                  = Gem::Platform::RUBY
  s.authors                   = ["Jean-Sébastien Ney"]
  s.date                      = %q{2009-01-01}
  s.has_rdoc                  = true
  s.extra_rdoc_files          = %w(CHANGELOG LICENSE README.textile)
  s.summary                   = "a queue based on memcacheq"
  s.description               = "a queue based on memcacheq"
  s.email                     = "jeansebastien.ney@gmail.com"
  s.homepage                  = "http://moses.fr"
  s.require_paths             = ["lib"]
  s.files                     = %w(CHANGELOG LICENSE README.textile Rakefile) + Dir.glob("{lib,specs}/**/*")
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version          = "1.2.0"
  
  # Uncomment this to add a dependency
  s.add_dependency "memcache", "~> 1.5.8"
end

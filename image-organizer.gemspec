# frozen_string_literal: true

require_relative "lib/image/organizer/version"

Gem::Specification.new do |spec|
  spec.name = "image-organizer"
  spec.version = Image::Organizer::VERSION
  spec.authors = ["gzamfir-ca"]
  spec.email = ["gzamfir_ca@icloud.com"]

  spec.summary = "image organizer"
  spec.description = "an image organizer to ingest digital camera files"
  spec.homepage = "https://github.com/gzamfir-ca/image-organizer"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/gzamfir-ca/image-organizer"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .rubocop.yml Rakefile .idea/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", ">= 1.5.0"
end

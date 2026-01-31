require_relative "lib/kcli/version"

Gem::Specification.new do |spec|
  spec.name          = "kcli"
  spec.version       = Kcli::VERSION
  spec.authors        = ["Kevin"]
  spec.email          = ["kevin@example.com"]

  spec.summary       = "A modular Ruby CLI framework for operations."
  spec.description   = "A tool for quick ops tasks with Ruby-based configuration."
  spec.homepage      = "https://github.com/kevin/kcli"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "bin"
  spec.executables   = ["kcli"]
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.add_dependency "tabulo", "~> 3.0"
  spec.add_dependency "ostruct", "~> 0.6"
  spec.add_dependency "google-cloud-compute-v1", "~> 3.0"
end

# frozen_string_literal: true

require_relative 'lib/legion/extensions/moral_reasoning/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-moral-reasoning'
  spec.version       = Legion::Extensions::MoralReasoning::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LegionIO moral reasoning extension'
  spec.description   = 'Moral reasoning for LegionIO — Kohlberg stages, Haidt moral foundations, ' \
                       'ethical framework evaluation, and dilemma resolution'
  spec.homepage      = 'https://github.com/LegionIO/lex-moral-reasoning'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['changelog_uri']         = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['lib/**/*']
  spec.require_paths = ['lib']
end

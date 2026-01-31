require 'zeitwerk'
require 'ostruct'

module Kcli
  class << self
    def loader
      @loader ||= Zeitwerk::Loader.for_gem.tap do |l|
        l.setup
      end
    end

    def configure(name, &block)
      @configs ||= {}
      @configs[name] = block
    end

    def config_for(name)
      @configs ||= {}
      @configs[name]
    end
  end
end

Kcli.loader

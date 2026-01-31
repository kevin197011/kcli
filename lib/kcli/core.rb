require 'thor'

module Kcli
  class Core < Thor
    def self.load_modules
      # Load all ruby files in modules directory
      Dir[File.join(__dir__, 'modules', '*.rb')].each do |file|
        require file
      end
      
      # Register each class in Kcli::Modules as a subcommand
      Kcli::Modules.constants.each do |const|
        klass = Kcli::Modules.const_get(const)
        if klass.is_a?(Class) && klass < Kcli::Module
          command_name = const.to_s.downcase
          desc "#{command_name} [COMMAND]", "Run commands for #{command_name}"
          subcommand command_name, klass
        end
      end
    end
    
    def self.load_configs
      config_paths = [
        File.expand_path('~/.kcli/*.rb'),
        File.join(Dir.pwd, '.kcli', '*.rb')
      ]
      
      config_paths.each do |path|
        Dir[path].each do |file|
          load file
        end
      end
    end

    def self.start(args = ARGV)
      load_configs
      load_modules
      super(args)
    end
  end
end

require 'thor'

module Kcli
  class Module < Thor
    no_commands do
      def config
        @config ||= begin
          parts = self.class.name.split('::')
          module_key = if parts[0] == "Kcli" && parts[1] == "Modules" && parts[2]
                         parts[2].downcase.to_sym
                       else
                         parts.last.downcase.to_sym
                       end
          
          block = Kcli.config_for(module_key)
          OpenStruct.new.tap { |s| block&.call(s) }
        end
      end
    end
  end
end

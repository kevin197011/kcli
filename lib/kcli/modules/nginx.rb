require 'thor'

module Kcli
  module Modules
    class Nginx < Kcli::Module
      class Site < Kcli::Module
        desc "add DOMAIN", "Create a new Nginx virtual host configuration"
        method_option :proxy, type: :string, desc: "Proxy pass target (e.g., http://127.0.0.1:8080)"
        method_option :root, type: :string, desc: "Document root", default: "/var/www/html"
        method_option :enable, type: :boolean, desc: "Automatically enable the site", default: true
        def add(domain)
          config_dir = parent_config.conf_dir || "/etc/nginx/sites-available"
          enabled_dir = parent_config.enabled_dir || "/etc/nginx/sites-enabled"
          
          content = if options[:proxy]
            proxy_template(domain, options[:proxy])
          else
            static_template(domain, options[:root])
          end

          target_file = File.join(config_dir, domain)
          
          puts "Creating configuration for #{set_color(domain, :cyan)}..."
          
          # Since we likely need sudo, we use a command approach or just print if we can't write
          begin
            # Example of how we might handle writing (requires permissions)
            # File.write(target_file, content)
            puts set_color("Generated configuration:", :yellow)
            puts "-" * 40
            puts content
            puts "-" * 40
            
            if options[:enable]
              puts "To enable, run: " + set_color("ln -s #{target_file} #{enabled_dir}/#{domain}", :green)
              puts "Then run: " + set_color("kcli nginx verify && kcli nginx reload", :green)
            end
          rescue => e
            puts set_color("Error: #{e.message}", :red)
          end
        end

        desc "list", "List available and enabled sites"
        def list
          config_dir = parent_config.conf_dir || "/etc/nginx/sites-available"
          enabled_dir = parent_config.enabled_dir || "/etc/nginx/sites-enabled"
          
          unless Dir.exist?(config_dir)
            puts set_color("Nginx configuration directory not found: #{config_dir}", :red)
            return
          end

          sites = Dir.children(config_dir).map do |name|
            enabled = File.exist?(File.join(enabled_dir, name))
            { name: name, enabled: enabled ? "YES" : "NO" }
          end

          table = Tabulo::Table.new(sites) do |t|
            t.add_column(:name, header: "SITE")
            t.add_column(:enabled, header: "ENABLED")
          end
          puts table.pack
        end

        private

        def parent_config
          # Access the Nginx module's config
          @parent_config ||= begin
            block = Kcli.config_for(:nginx)
            OpenStruct.new.tap { |s| block&.call(s) }
          end
        end

        def static_template(domain, root)
          <<~CONF
            server {
                listen 80;
                server_name #{domain};
                root #{root};
                index index.html index.htm;

                location / {
                    try_files $uri $uri/ =404;
                }

                access_log /var/log/nginx/#{domain}.access.log;
                error_log /var/log/nginx/#{domain}.error.log;
            }
          CONF
        end

        def proxy_template(domain, proxy)
          <<~CONF
            server {
                listen 80;
                server_name #{domain};

                location / {
                    proxy_pass #{proxy};
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
                }

                access_log /var/log/nginx/#{domain}.access.log;
                error_log /var/log/nginx/#{domain}.error.log;
            }
          CONF
        end
      end

      desc "install", "Install Nginx on the local system"
      def install
        puts "Detecting OS..."
        case RbConfig::CONFIG['host_os']
        when /darwin/
          puts "Detected macOS. Using Homebrew..."
          system("brew install nginx")
        when /linux/
          if system("which apt-get > /dev/null")
            puts "Detected Debian/Ubuntu. Using APT..."
            system("sudo apt-get update && sudo apt-get install -y nginx")
          elsif system("which yum > /dev/null")
            puts "Detected RHEL/CentOS. Using YUM..."
            system("sudo yum install -y nginx")
          else
            puts set_color("Unsupported Linux distribution.", :red)
          end
        else
          puts set_color("Unsupported OS: #{RbConfig::CONFIG['host_os']}", :red)
        end
      end

      desc "status", "Check Nginx service status"
      def status
        nginx_bin = config.nginx_path || "nginx"
        if system("which #{nginx_bin} > /dev/null 2>&1")
          version = `#{nginx_bin} -v 2>&1`.chomp
          puts set_color("Nginx Path: ", :cyan) + `which #{nginx_bin}`.strip
          puts set_color("Version: ", :cyan) + version
          
          # Running check
          if `pgrep nginx`.empty?
            puts set_color("Status: STOPPED", :red)
          else
            puts set_color("Status: RUNNING", :green)
            system("ps aux | grep nginx | grep -v grep")
          end
        else
          puts set_color("Nginx is not installed or not in PATH.", :red)
        end
      end

      desc "verify", "Test Nginx configuration (nginx -t)"
      def verify
        nginx_bin = config.nginx_path || "nginx"
        puts "Verifying configuration..."
        result = `sudo #{nginx_bin} -t 2>&1`
        if $?.success?
          puts set_color("Configuration is valid.", :green)
        else
          puts set_color("Configuration error detected:", :red)
          puts result
        end
      end

      desc "reload", "Reload Nginx service"
      def reload
        nginx_bin = config.nginx_path || "nginx"
        puts "Reloading Nginx..."
        if system("sudo #{nginx_bin} -s reload")
          puts set_color("Nginx reloaded successfully.", :green)
        else
          puts set_color("Failed to reload Nginx. Check configuration with 'kcli nginx verify'.", :red)
        end
      end

      desc "restart", "Restart Nginx service"
      def restart
        puts "Restarting Nginx..."
        if system("sudo systemctl restart nginx 2>/dev/null || sudo brew services restart nginx 2>/dev/null")
          puts set_color("Nginx restarted successfully.", :green)
        else
          puts set_color("Failed to restart Nginx service.", :red)
        end
      end

      desc "logs", "Show Nginx access and error logs"
      method_option :lines, type: :numeric, default: 10, aliases: "-n"
      method_option :error, type: :boolean, desc: "Show only error logs"
      def logs
        access_log = "/var/log/nginx/access.log"
        error_log = "/var/log/nginx/error.log"
        
        if options[:error]
          puts set_color("--- Error Log (last #{options[:lines]} lines) ---", :red)
          system("sudo tail -n #{options[:lines]} #{error_log}")
        else
          puts set_color("--- Access Log (last #{options[:lines]} lines) ---", :green)
          system("sudo tail -n #{options[:lines]} #{access_log}")
          puts set_color("--- Error Log (last #{options[:lines]} lines) ---", :red)
          system("sudo tail -n #{options[:lines]} #{error_log}")
        end
      end

      desc "site [COMMAND]", "Manage virtual hosts"
      subcommand "site", Site
    end
  end
end

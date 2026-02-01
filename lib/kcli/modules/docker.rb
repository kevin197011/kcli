require 'thor'

module Kcli
  module Modules
    class Docker < Kcli::Module
      class Container < Kcli::Module
        desc "ls", "List containers"
        method_option :all, type: :boolean, aliases: "-a", desc: "Show all containers (default shows just running)"
        def ls
          format = '{"id":"{{.ID}}", "names":"{{.Names}}", "status":"{{.Status}}", "image":"{{.Image}}"}'
          all_flag = options[:all] ? "-a" : ""
          output = `docker ps #{all_flag} --format '#{format}'`
          
          containers = output.split("\n").map { |line| JSON.parse(line) }

          if containers.empty?
            puts "No containers found."
          else
            table = Tabulo::Table.new(containers) do |t|
              t.add_column(:names, header: "NAME")
              t.add_column(:image, header: "IMAGE")
              t.add_column(:status, header: "STATUS")
              t.add_column(:id, header: "ID")
            end
            puts table.pack
          end
        rescue => e
          puts set_color("Error: #{e.message}", :red)
        end

        desc "stop NAME", "Stop a container"
        def stop(name)
          puts "Stopping container #{name}..."
          if system("docker stop #{name}")
            puts set_color("Container stopped.", :green)
          end
        end

        desc "rm NAME", "Remove a container"
        method_option :force, type: :boolean, aliases: "-f"
        def rm(name)
          force = options[:force] ? "-f" : ""
          if system("docker rm #{force} #{name}")
            puts set_color("Container removed.", :green)
          end
        end

        desc "logs NAME", "Fetch the logs of a container"
        method_option :tail, type: :numeric, default: 100, aliases: "-n"
        method_option :follow, type: :boolean, aliases: "-f"
        def logs(name)
          tail = options[:tail]
          follow = options[:follow] ? "-f" : ""
          system("docker logs --tail #{tail} #{follow} #{name}")
        end
      end

      class Image < Kcli::Module
        desc "ls", "List images"
        def ls
          format = '{"id":"{{.ID}}", "repository":"{{.Repository}}", "tag":"{{.Tag}}", "size":"{{.Size}}"}'
          output = `docker images --format '#{format}'`
          images = output.split("\n").map { |line| JSON.parse(line) }

          table = Tabulo::Table.new(images) do |t|
            t.add_column(:repository, header: "REPOSITORY")
            t.add_column(:tag, header: "TAG")
            t.add_column(:id, header: "IMAGE ID")
            t.add_column(:size, header: "SIZE")
          end
          puts table.pack
        end

        desc "prune", "Remove unused images"
        def prune
          system("docker image prune -f")
        end
      end

      desc "ps", "List running containers (shortcut for container ls)"
      def ps
        Container.new.ls
      end

      desc "stats", "Display a live stream of container(s) resource usage statistics"
      def stats
        system("docker stats --no-stream")
      end

      desc "info", "Display system-wide information"
      def info
        system("docker info")
      end

      desc "container [COMMAND]", "Manage containers"
      subcommand "container", Container

      desc "image [COMMAND]", "Manage images"
      subcommand "image", Image
    end
  end
end

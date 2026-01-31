require 'google/cloud/compute/v1'
require 'tabulo'

module Kcli
  module Modules
    class Gcp < Kcli::Module
      class Compute < Kcli::Module
        desc "list", "List GCP compute instances"
        def list
          project = config.project_id
          if project.nil?
            puts "Error: project_id not configured for GCP."
            puts "Please create ~/.kcli/gcp.rb with:"
            puts "Kcli.configure(:gcp) { |c| c.project_id = 'YOUR_PROJECT' }"
            return
          end

          client = Google::Cloud::Compute::V1::Instances::Rest::Client.new
          
          begin
            request = Google::Cloud::Compute::V1::AggregatedListInstancesRequest.new(project: project)
            responses = client.aggregated_list(request)
            
            instances = []
            responses.each do |zone, list|
              next if list.instances.nil?
              list.instances.each do |inst|
                instances << {
                  name: inst.name,
                  status: inst.status,
                  zone: zone.split('/').last
                }
              end
            end

            if instances.empty?
              puts "No instances found in project #{project}."
            else
              table = Tabulo::Table.new(instances) do |t|
                t.add_column(:name, header: "NAME")
                t.add_column(:status, header: "STATUS")
                t.add_column(:zone, header: "ZONE")
              end
              puts table.pack
            end
          rescue => e
            puts "Error fetching instances: #{e.message}"
          end
        end
      end

      desc "compute [COMMAND]", "GCP Compute commands"
      subcommand "compute", Compute
    end
  end
end

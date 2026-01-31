Kcli.configure(:gcp) do |config|
  config.project_id = ENV['GCP_PROJECT'] || 'test-project'
end

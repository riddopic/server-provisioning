# encoding: UTF-8

require 'fileutils'
require 'erb'
require 'json'
require 'chef-config/config'
require 'colorize'
require 'tty'
require 'sgviz'

# String Colorization
class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end
end

# Provisioning Environment for ERB Rendering
class ProvisioningEnvironment
  def initialize(name, options)
    options.each_pair do |key, value|
      instance_variable_set('@' + key.to_s, value)
    end
    @name = name
    @data = json
  end

  def self.template
    '<%= JSON.pretty_generate(@data) %>'
  end

  def json
    {
      'name' => @name,
      'description' => 'Chef Infrastructure Provisioning Environment',
      'json_class' => 'Chef::Environment',
      'chef_type' => 'environment',
      'override_attributes' => {
        'provisioning' => {
          'id' => @cluster_id,
          'driver' => @driver_name,
          @driver_name => @driver,
          'acl' => (@acl if @acl && ! @acl.empty?),
          'chef-server' => @chef_server,
          'analytics' => (@analytics if @analytics && ! @analytics.empty?),
          'compliance' => (@compliance if @compliance && ! @compliance.empty?),
          'supermarket' => (@supermarket if @supermarket && ! @supermarket.empty?)
        }.delete_if { |_k, v| v.nil? }
      }
    }
  end

  def do_binding
    binding
  end
end

ENV['CHEF_ENV'] ||= 'test'
ENV['CHEF_ENV_FILE'] = "environments/#{ENV['CHEF_ENV']}.json"

# Validate the environment file
#
# If the environment file does not exist or it has syntax errors fail fast
def validate_environment
  unless File.exist?(ENV['CHEF_ENV_FILE'])
    puts 'You need to configure an Environment under "environments". ' \
         'Check the README.md'.red
    puts 'You can use the "generate_env" task to auto-generate one:'
    puts '  # rake setup:generate_env'
    puts "\nOr if you just have a different chef environment name run:"
    puts "  # export CHEF_ENV=#{'my_new_environment'.yellow}"
    raise
  end

  begin
    JSON.parse(File.read(ENV['CHEF_ENV_FILE']))
  rescue JSON::ParserError
    puts "You have syntax errors on the environment file '#{ENV['CHEF_ENV_FILE']}'".red
    puts 'Please fix the problems and re run the task.'
    raise
  end
end

def chef_apply(recipe)
  succeed = system "chef exec chef-apply recipes/#{recipe}.rb"
  raise 'Failed executing ChefApply run' unless succeed
end

def provisioning_data_dir
  File.expand_path('.chef/provisioning-data')
end

def chef_config
  knife_rb = File.join(provisioning_data_dir, 'knife.rb')
  ChefConfig::Config.from_file(knife_rb) if File.exist?(knife_rb)
  ChefConfig::Config
end

def chef_server_url
  chef_config[:chef_server_url]
end

def chefdk_version
  @chef_dk_version ||= `chef -v`.split("\n").first.split.last
rescue
  puts 'ChefDk was not found'.red
  puts 'Please install it from: https://downloads.chef.io/chef-dk'.yellow
  raise
end

def chef_zero(recipe)
  validate_environment
  succeed = system "chef exec chef-client -z -o provisioning::#{recipe} -E #{ENV['CHEF_ENV']}"
  raise 'Failed executing ChefZero run' unless succeed
end

def render_environment(environment, options)
  ::FileUtils.mkdir_p 'environments'

  env_file = File.open("environments/#{environment}.json", 'w+')
  env_file << ERB.new(ProvisioningEnvironment.template)
              .result(ProvisioningEnvironment.new(environment, options).do_binding)
  env_file.close

  puts File.read("environments/#{environment}.json")
end

def bool(string)
  case string
  when 'no'
    false
  when 'yes'
    true
  else
    string
  end
end

def ask_for(thing, default = nil)
  thing = "#{thing} [#{default.yellow}]: " if default
  stdin = nil
  loop do
    print thing
    stdin = STDIN.gets.strip
    case default
    when 'no', 'yes'
      break if stdin.empty? || stdin.eql?('no') || stdin.eql?('yes')
      print 'Answer (yes/no) '
    when nil
      break unless stdin.empty?
    else
      break
    end
  end
  bool(stdin.empty? ? default : stdin)
end

def msg(text)
  ttable = TTY::Table.new
  ttable << [text]
  renderer = TTY::Table::Renderer::Unicode.new(ttable)
  renderer.border.style = :red
  puts renderer.render
end

Rake::TaskManager.record_task_metadata = true

namespace :setup do
  desc 'Generate a Chef Infrastructure Provisioning Environment'
  task :generate_env do
    msg 'Gathering Chef Infrastructure Provisioning Environment Information'
    puts 'Provide the following information to generate your environment.'

    options = {}
    puts "\nGlobal Attributes".pink
    # Environment Name
    environment = ask_for('Environment Name', 'test')

    if File.exist? "environments/#{environment}.json"
      puts "ERROR: Environment environments/#{environment}.json already exist".red
      exit 1
    end

    options['cluster_id'] = ask_for('Cluster ID', environment)
    puts "\nAvailable Drivers: [ aws | ssh | vagrant ]"
    options['driver_name'] = ask_for('Driver Name', 'aws')

    puts "\nDriver Information [#{options['driver_name']}]".pink
    options['driver'] = {}
    case options['driver_name']
    when 'ssh'
      options['driver']['ssh_username'] = ask_for('SSH Username: ')
      loop do
        puts 'Key File Not Found'.red if options['driver']['key_file']
        options['driver']['key_file'] = ask_for('Key File', File.expand_path('~/.ssh/id_rsa'))
        break if File.exist?(options['driver']['key_file'])
      end
    when 'aws'
      options['driver']['key_name'] = ask_for('Key Name: ')
      options['driver']['ssh_username'] = ask_for('SSH Username', 'ubuntu')
      options['driver']['region'] = ask_for('AWS Region', 'us-west-2')
      options['driver']['image_id'] = ask_for('Image ID', 'ami-e4a54c84')
      options['driver']['use_private_ip_for_ssh'] = ask_for('Use private ip for ssh?', 'yes')
      if ask_for('Would you like to specify source IP for the AWS Security group?', 'yes')
        src_ips = ask_for('Source IPs:', '24.7.32.100/32 162.119.232.109/32 162.119.232.149/32')
        options['acl'] = {}
        options['acl']['source-ips'] = src_ips.split
      end
    when 'vagrant'
      options['driver']['ssh_username'] = ask_for('SSH Username', 'vagrant')
      options['driver']['vm_box'] = ask_for('Box Type: ', 'opscode-centos-6.6')
      options['driver']['image_url'] = ask_for('Box URL: ', 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.6_chef-provisionerless.box')
      loop do
        puts 'Key File Not Found'.red if options['driver']['key_file']
        options['driver']['key_file'] = ask_for('Key File',
                                                File.expand_path('~/.vagrant.d/insecure_private_key'))
        break if File.exist?(options['driver']['key_file'])
      end
    else
      puts 'ERROR: Unsupported Driver.'.red
      puts 'Available Drivers are [ aws | ssh | vagrant ]'.yellow
      exit 1
    end
    # Proxy Settings
    if ask_for('Would you like to configure Proxy Settings?', 'no')
      http_proxy = ask_for('http_proxy: ')
      https_proxy = ask_for('https_proxy: ')
      no_proxy = ask_for('no_proxy: ')
      options['driver']['bootstrap_proxy'] = https_proxy || http_proxy || nil
      options['driver']['chef_config'] = "http_proxy '#{http_proxy}'\n" \
                                         "https_proxy '#{https_proxy}'\n" \
                                         "no_proxy '#{no_proxy}'"
    end

    puts "\nChef Server".pink
    options['chef_server'] = {}
    options['chef_server']['organization'] = ask_for('Organization Name', environment)
    case options['driver_name']
    when 'aws'
      options['chef_server']['flavor'] = ask_for('Flavor', 'c3.xlarge')
    when 'ssh'
      options['chef_server']['existing'] = ask_for('Use existing chef-server?', 'no')
      options['chef_server']['host'] = ask_for('Host', '33.33.33.10')
    when 'vagrant'
      options['chef_server']['existing'] = ask_for('Use existing chef-server?', 'no')
      options['chef_server']['vm_hostname'] = 'chef.example.com'
      options['chef_server']['network'] = ask_for('Network Config', ":private_network, {:ip => '33.33.33.10'}")
      options['chef_server']['vm_memory'] = ask_for('Memory allocation', '2048')
      options['chef_server']['vm_cpus'] = ask_for('Cpus allocation', '2')
    end

    puts "\nChef Analytics Server".pink
    if ask_for('Enable Chef Analytics?', 'no')
      options['analytics'] = {}
      case options['driver_name']
      when 'aws'
        options['analytics']['flavor'] = ask_for('Flavor', 'c3.xlarge')
      when 'ssh'
        options['analytics']['host'] = ask_for('Host', '33.33.33.12')
      when 'vagrant'
        options['analytics']['vm_hostname'] = 'analytics.example.com'
        options['analytics']['network'] = ask_for('Network Config', ":private_network, {:ip => '33.33.33.12'}")
        options['analytics']['vm_memory'] = ask_for('Memory allocation', '2048')
        options['analytics']['vm_cpus'] = ask_for('Cpus allocation', '2')
      end
    end

    puts "\nChef Compliance Server".pink
    if ask_for('Enable Chef Compliance?', 'no')
      options['compliance'] = {}
      case options['driver_name']
      when 'aws'
        options['compliance']['flavor'] = ask_for('Flavor', 'c3.xlarge')
      when 'ssh'
        options['compliance']['host'] = ask_for('Host', '33.33.33.13')
      when 'vagrant'
        options['compliance']['vm_hostname'] = 'compliance.example.com'
        options['compliance']['network'] = ask_for('Network Config', ":private_network, {:ip => '33.33.33.13'}")
        options['compliance']['vm_memory'] = ask_for('Memory allocation', '2048')
        options['compliance']['vm_cpus'] = ask_for('Cpus allocation', '2')
      end
    end

    puts "\nChef Supermarket Server".pink
    if ask_for('Enable Chef Supermarket?', 'no')
      options['supermarket'] = {}
      case options['driver_name']
      when 'aws'
        options['supermarket']['flavor'] = ask_for('Flavor', 'c3.xlarge')
      when 'ssh'
        options['supermarket']['host'] = ask_for('Host', '33.33.33.14')
      when 'vagrant'
        options['supermarket']['vm_hostname'] = 'supermarket.example.com'
        options['supermarket']['network'] = ask_for('Network Config', ":private_network, {:ip => '33.33.33.14'}")
        options['supermarket']['vm_memory'] = ask_for('Memory allocation', '2048')
        options['supermarket']['vm_cpus'] = ask_for('Cpus allocation', '2')
      end
    end

    msg "Rendering Chef Infrastructure Provisioning Environment => environments/#{environment}.json"

    render_environment(environment, options)

    puts "\nExport your new environment by executing:".yellow
    puts "  # export CHEF_ENV=#{environment.green}\n"
  end

  desc 'Install all the prerequisites on you system'
  task prerequisites: [:terraform] do
    msg 'Verifying ChefDK version'
    if Gem::Version.new(chefdk_version) < Gem::Version.new('0.10.0')
      puts "Running ChefDK version #{chefdk_version}".red
      puts 'The required version is >= 0.10.0'.red
      raise
    else
      puts "Running ChefDK version #{chefdk_version}".green
    end

    msg 'Configuring the provisioner node'
    chef_apply 'provisioner'

    msg 'Download and vendor the necessary cookbooks locally'
    system 'chef exec berks vendor cookbooks'

    msg "Current chef environment => #{ENV['CHEF_ENV_FILE']}"
    validate_environment
  end

  desc 'Terraform the Infrastructure, Network and Environment'
  task :terraform do
    msg 'Terraform the Infrastructure, Network and Environment'
    Dir.chdir('terraform') do
      sh('terraform plan && terraform apply')
    end
  end

  desc 'Setup the Chef Infrastructure Provisioning Environment'
  task cluster: [:prerequisites] do
    msg 'Setup the Chef Infrastructure Provisioning Environment'
    chef_zero 'setup'
  end

  desc 'Create a Chef Server'
  task :chef_server do
    msg 'Setup a Chef Server'
    chef_zero 'setup_chef_server'
  end

  desc 'Create a Chef Analytics Server'
  # task analytics: [:chef_server] do
  task :analytics do
    msg 'Setup a Chef Analytics Server'
    chef_zero 'setup_analytics'
  end

  desc 'Create a Chef Compliance Server'
  # task compliance: [:chef_server] do
  task :compliance do
    msg 'Setup a Chef Compliance Server'
    chef_zero 'setup_compliance'
  end

  desc 'Create a Splunk Server with Analytics Integration'
  task splunk: [:analytics] do
    msg 'Setup Splunk Server to show some Analytics Integrations'
    chef_zero 'setup_splunk'
  end

  desc 'Create a Supermarket Server'
  task supermarket: [:chef_server] do
    msg 'Setup a Chef Supermarket Server'
    chef_zero 'setup_supermarket'
  end

  desc 'Create a Jenkins Server'
  task :jenkins do
    msg 'Setup a Chef Jenkins Server'
    chef_zero 'setup_jenkins_server'
  end
end

namespace :maintenance do
  desc 'Update cookbook dependencies'
  task :update do
    msg 'Updating cookbooks locally'
    system 'chef exec berks update'
  end

  desc 'Clean the cache'
  task :clean_cache do
    FileUtils.rm_rf('.chef/local-mode-cache')
    FileUtils.rm_rf('cookbooks/')
  end
end

namespace :destroy do
  desc 'Destroy Everything'
  task :all do
    chef_zero 'destroy_all'
  end

  desc 'Destroy the Infrastructure, Network and Environment'
  task :terraform do
    Dir.chdir('terraform') do
      sh('terraform destroy')
    end
  end

  desc 'Destroy Chef Compliance Server'
  task :compliance do
    chef_zero 'destroy_compliance'
  end

  desc 'Destroy Chef Analytics Server'
  task :analytics do
    chef_zero 'destroy_analytics'
  end

  desc 'Destroy Splunk Server'
  task :splunk do
    chef_zero 'destroy_splunk'
  end

  desc 'Destroy Chef Supermarket Server'
  task :supermarket do
    chef_zero 'destroy_supermarket'
  end

  desc 'Destroy Jenkins Server'
  task :jenkins do
    chef_zero 'destroy_jenkins_server'
  end

  desc 'Destroy Chef Server'
  task :chef_server do
    chef_zero 'destroy_chef_server'
  end
end

namespace :info do
  desc 'List nodes in the Chef Infrastructure Provisioning Environment'
  task :list_core_services do
    system 'knife search node \'name:*server* OR name:node*\' -a cloud.public_ipv4'
    puts "Chef Server URL: #{chef_server_url}"
  end

  desc 'Inspect state the Infrastructure, Network and Environment'
  task :terraform do
    Dir.chdir('terraform') do
      sh('terraform show')
    end
  end

  # brew install graphviz terraform
  desc 'Generate a graph of the VPC'
  task :graph, :region, :vpc_id do |_t, args|
    sh <<-CMD
    sgviz generate --output-path provisioned_vpc \
                   --region #{args[:region]} \
                   --vpc-ids #{args[:vpc_id]}
    CMD
    sh("sgviz open --output-path provisioned_vpc --region #{args[:region]}")
  end
end

task default: [:help]
task :help do
  puts "\nChef Infrastructure Provisioning Environment Helper".green
  puts "\nSetup Tasks".pink
  puts 'The following tasks should be used to set up your environment'.yellow
  Rake.application.options.show_tasks = :tasks
  Rake.application.options.show_task_pattern = /setup/
  Rake.application.display_tasks_and_comments
  puts "\nMaintenance Tasks".pink
  puts 'The following tasks should be used to maintain your environment'.yellow
  Rake.application.options.show_task_pattern = /maintenance/
  Rake.application.display_tasks_and_comments
  puts "\nDestroy Tasks".pink
  puts 'The following tasks should be used to destroy your environment'.yellow
  Rake.application.options.show_task_pattern = /destroy/
  Rake.application.display_tasks_and_comments
  puts "\nCluster Information".pink
  puts 'The following tasks should be used to get information about your environment'.yellow
  Rake.application.options.show_task_pattern = /info/
  Rake.application.display_tasks_and_comments
  puts "\nTo switch your environment run:"
  puts "  # export CHEF_ENV=#{'my_environment_name'.yellow}\n"
end

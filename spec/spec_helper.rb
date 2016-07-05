require 'serverspec'
require 'docker'

MYSQL_ROOT_PASSWORD="super-secret-password"
MYSQL_USER="fhwordpresstest"
MYSQL_PASSWORD="super-secret-password1"
MYSQL_DATABASE="fhwordpresstest"
MYSQL_HOST="mysqltesting"

#Include Tests
base_spec_dir = Pathname.new(File.join(File.dirname(__FILE__)))
Dir[base_spec_dir.join('../../drone-tests/shared/**/*.rb')].sort.each { |f| require_relative f }

if not ENV['IMAGE'] then
  puts "You must provide an IMAGE env variable"
end

#@network = Docker::Network.create "wordpresstest1"
#@mysqlimage = Docker::Image.create('fromImage' => 'mysql:latest')
#@container = Docker::Container.create(
#  'name'           => MYSQL_HOST,
#  'Image'          => @mysqlimage.id,
#  'Config'         => { "Hostname" => "#{MYSQL_HOST}"},
#  'HostConfig'     => {
#     'NetworkMode' => @network.info["Name"],
#  },
#  'Env'            => [
#    "MYSQL_ROOT_PASSWORD=#{MYSQL_ROOT_PASSWORD}",
#    "MYSQL_USER=#{MYSQL_USER}",
#    "MYSQL_PASSWORD=#{MYSQL_PASSWORD}",
#    "MYSQL_DATABASE=#{MYSQL_DATABASE}"
#  ]
#)
#@container.start


LISTEN_PORT=8080
CONTAINER_START_DELAY=10

RSpec.configure do |c|
  @image = Docker::Image.get(ENV['IMAGE'])
  set :backend, :docker
  set :docker_image, @image.id
  set :docker_container_create_options, {
      'User'           => '100000',
      #'Host Config'    => {
      #   'NetworkMode' => @network.info["Name"],
      #},
      'Env'            => [
        "WORDPRESS_DB_USER=#{MYSQL_USER}",
        "WORDPRESS_DB_PASSWORD=#{MYSQL_PASSWORD}",
        "WORDPRESS_DB_NAME=#{MYSQL_DATABASE}",
        "WORDPRESS_DB_HOST=#{MYSQL_HOST}"
  ]

  }

  describe command("sleep #{CONTAINER_START_DELAY}") do
    its(:stdout) { should eq "" }
  end

  describe "tests" do
    include_examples 'docker-ubuntu-16'
    include_examples 'docker-ubuntu-16-apache-2.4'
    include_examples 'php-5.6-tests'
    include_examples 'wordpress'
  end
end

#@container.kill
#@container.delete
#@network.delete

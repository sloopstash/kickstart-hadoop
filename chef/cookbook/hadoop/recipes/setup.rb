version = node['hadoop']['version']
home_dir = node['hadoop']['home_dir']

# Install system packages.
yum_package 'Install system packages' do
  package_name ['wget','vim','net-tools','initscripts','gcc','make','tar','bind-utils','nc','git','unzip']
  action :install
end

# Install OpenSSH server.
yum_package 'Install OpenSSH server' do
  package_name ['openssh-server','openssh-clients','passwd']
  action :install
end

# Install Java.
yum_package 'Install Java' do
  package_name ['java-1.8.0-openjdk','java-1.8.0-openjdk-devel']
  action :install
end

# Create system group for Hadoop.
group 'hadoop' do
  action 'create'
end

# Create system user for Hadoop.
user 'hadoop' do
  gid 'hadoop'
  home home_dir
  manage_home true
  shell '/bin/bash'
  system true
  action 'create'
end

# Create OpenSSH user directory.
directory "#{home_dir}/.ssh" do
  owner 'hadoop'
  group 'hadoop'
  recursive true
  mode 0700
  action 'create'
  only_if do
    File.exists?home_dir
  end
end

# Create Hadoop directories.
[
  node['hadoop']['base_dir'],
  node['hadoop']['config_dir'],
  node['hadoop']['system_dir'],
  node['hadoop']['log_dir'],
  node['hadoop']['data_dir'],
  node['hadoop']['tmp_dir']
].each do |dir|
  directory dir do
    owner 'hadoop'
    group 'hadoop'
    recursive true
    mode 0700
    action 'create'
    not_if do
      File.exists?dir
    end
  end
end

# Download Hadoop.
remote_file "/tmp/hadoop-#{version}.tar.gz" do
  source "https://archive.apache.org/dist/hadoop/common/hadoop-#{version}/hadoop-#{version}.tar.gz"
  mode 0644
  not_if do
    File.exists?"/tmp/hadoop-#{version}.tar.gz"
  end
end

# Extract Hadoop.
execute 'Extract Hadoop' do
  command "tar xvzf hadoop-#{version}.tar.gz > /dev/null"
  cwd '/tmp'
  user 'root'
  group 'root'
  returns [0]
  action 'run'
  only_if do
    File.exists?"/tmp/hadoop-#{version}.tar.gz"
  end
end

# Install Hadoop.
execute 'Install Hadoop' do
  command <<-EOH
    cp -r hadoop-#{version}/* #{home_dir}/
    chown -R hadoop:hadoop #{home_dir}
  EOH
  cwd '/tmp'
  user 'root'
  group 'root'
  returns [0]
  action 'run'
  only_if do
    File.exists?"/tmp/hadoop-#{version}"
  end
end

# Include recipes.
include_recipe 'hadoop::configure'
include_recipe 'hadoop::initialize'
include_recipe 'hadoop::start'

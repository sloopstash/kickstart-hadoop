version = node['hadoop']['version']
home_dir = node['hadoop']['home_dir']

# install system packages.
yum_package 'install system packages' do
  package_name ['wget','vim','net-tools','initscripts','gcc','make','tar','bind-utils','nc','git','unzip']
  action :install
end

# install openssh.
yum_package 'install openssh' do
  package_name ['openssh-server','openssh-clients','passwd']
  action :install
end

# install java.
yum_package 'install java' do
  package_name ['java-1.8.0-openjdk','java-1.8.0-openjdk-devel']
  action :install
end

# create system group.
group 'hadoop' do
  action 'create'
end

# create system user.
user 'hadoop' do
  gid 'hadoop'
  home home_dir
  manage_home true
  shell '/bin/bash'
  system true
  action 'create'
end

# create openssh user directory.
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

# create hadoop directories.
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

# download hadoop.
remote_file "/tmp/hadoop-#{version}.tar.gz" do
  source "http://apachemirror.wuchna.com/hadoop/common/hadoop-#{version}/hadoop-#{version}.tar.gz"
  mode 0644
  not_if do
    File.exists?"/tmp/hadoop-#{version}.tar.gz"
  end
end

# extract hadoop.
execute 'extract hadoop' do
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

# install hadoop.
execute 'install hadoop' do
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

# include recipes.
include_recipe 'hadoop::configure'
include_recipe 'hadoop::initialize'
include_recipe 'hadoop::start'

home_dir = node['hadoop']['home_dir']
data_dir = node['hadoop']['data_dir']
tmp_dir = node['hadoop']['tmp_dir']
java_home = node['hadoop']['java_home']
heap_size = node['hadoop']['heap_size']

current_instance = search('aws_opsworks_instance','self:true').first
current_layer_id = current_instance['layer_ids'].first
node_name = current_instance['hostname']
nodes = Array.new
name_nodes = Array.new
data_nodes = Array.new

search('aws_opsworks_instance',"layer_ids:#{current_layer_id}").each do |instance|
  nodes << instance['hostname']
  if instance['hostname'].include?('-nm-')
    name_nodes << instance['hostname']
  end
  if instance['hostname'].include?('-dt-')
    data_nodes << instance['hostname']
  end
end

if node_name.include?('-nm-')
  # configure private key of openssh user.
  template "#{home_dir}/.ssh/id_rsa" do
    source 'ssh/id_rsa.erb'
    owner 'hadoop'
    group 'hadoop'
    variables(
      'private_key'=>node['hadoop']['ssh']['private_key']
    )
    mode 0600
    atomic_update true
    sensitive true
    backup false
    action 'create'
  end

  # configure hosts for openssh user.
  template "#{home_dir}/.ssh/config" do
    source 'ssh/config.erb'
    owner 'hadoop'
    group 'hadoop'
    variables(
      'nodes'=>nodes
    )
    mode 0600
    atomic_update true
    backup false
    action 'create'
  end

# configure hadoop slaves.
template "#{home_dir}/etc/hadoop/slaves" do
  source 'slaves.erb'
  owner 'hadoop'
  group 'hadoop'
  variables(
    'data_nodes'=>data_nodes
  )
  mode 0600
  backup false
  action 'create'
end
end

# configure public key of openssh user.
template "#{home_dir}/.ssh/authorized_keys" do
  source 'ssh/id_rsa.pub.erb'
  owner 'hadoop'
  group 'hadoop'
  variables(
    'public_key'=>node['hadoop']['ssh']['public_key']
  )
  mode 0600
  atomic_update true
  sensitive true
  backup false
  action 'create'
end

# configure hadoop core.
template "#{home_dir}/etc/hadoop/core-site.xml" do
  source 'core-site.xml.erb'
  owner 'hadoop'
  group 'hadoop'
  variables(
    'node_name'=>node_name,
    'name_node'=>name_nodes.first,
    'tmp_dir'=>tmp_dir
  )
  mode 0600
  backup false
  action 'create'
end

# configure hadoop environment variables.
template "#{home_dir}/etc/hadoop/hadoop-env.sh" do
  source 'hadoop-env.sh.erb'
  owner 'hadoop'
  group 'hadoop'
  variables(
    'java_home'=>java_home,
    'heap_size'=>heap_size
  )
  mode 0600
  backup false
  action 'create'
end

# configure hadoop hdfs.
template "#{home_dir}/etc/hadoop/hdfs-site.xml" do
  source 'hdfs-site.xml.erb'
  owner 'hadoop'
  group 'hadoop'
  variables(
    'node_name'=>node_name,
    'data_dir'=>data_dir
  )
  mode 0600
  backup false
  action 'create'
end

# configure hadoop mapreduce.
template "#{home_dir}/etc/hadoop/mapred-site.xml" do
  source 'mapred-site.xml.erb'
  owner 'hadoop'
  group 'hadoop'
  mode 0600
  backup false
  action 'create'
end

# configure hadoop yarn.
template "#{home_dir}/etc/hadoop/yarn-site.xml" do
  source 'yarn-site.xml.erb'
  owner 'hadoop'
  group 'hadoop'
  variables(
    'name_node'=>name_nodes.first
  )
  mode 0600
  backup false
  action 'create'
end

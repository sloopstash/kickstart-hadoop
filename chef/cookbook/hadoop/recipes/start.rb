home_dir = node['hadoop']['home_dir']

current_instance = search('aws_opsworks_instance','self:true').first
node_name = current_instance['hostname']

if node_name.include?('-nm-')
  # Start Hadoop HDFS.
  execute 'Start Hadoop HDFS' do
    command "#{home_dir}/sbin/start-dfs.sh"
    user 'hadoop'
    group 'hadoop'
    returns [0]
    action 'run'
    only_if do
      File.exists?home_dir
    end
  end

  # Start Hadoop YARN.
  execute 'Start Hadoop YARN' do
    command "#{home_dir}/sbin/start-yarn.sh"
    user 'hadoop'
    group 'hadoop'
    returns [0]
    action 'run'
    only_if do
      File.exists?home_dir
    end
  end
end

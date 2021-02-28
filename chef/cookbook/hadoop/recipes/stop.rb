home_dir = node['hadoop']['home_dir']

current_instance = search('aws_opsworks_instance','self:true').first
node_name = current_instance['hostname']

if node_name.include?('-nm-')
  # Stop Hadoop HDFS.
  execute 'Stop Hadoop HDFS' do
    command "#{home_dir}/sbin/stop-dfs.sh"
    user 'hadoop'
    group 'hadoop'
    returns [0]
    action 'run'
    only_if do
      File.exists?home_dir
    end
  end

  # Stop Hadoop YARN.
  execute 'Stop Hadoop YARN' do
    command "#{home_dir}/sbin/stop-yarn.sh"
    user 'hadoop'
    group 'hadoop'
    returns [0]
    action 'run'
    only_if do
      File.exists?home_dir
    end
  end
end

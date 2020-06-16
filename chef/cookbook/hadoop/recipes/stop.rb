home_dir = node['hadoop']['home_dir']

# stop hadoop hdfs.
execute 'stop hadoop hdfs' do
  command "#{home_dir}/sbin/stop-dfs.sh"
  user 'hadoop'
  group 'hadoop'
  returns [0]
  action 'run'
  only_if do
    File.exists?home_dir
  end
end

# stop hadoop yarn.
execute 'stop hadoop yarn' do
  command "#{home_dir}/sbin/stop-yarn.sh"
  user 'hadoop'
  group 'hadoop'
  returns [0]
  action 'run'
  only_if do
    File.exists?home_dir
  end
end

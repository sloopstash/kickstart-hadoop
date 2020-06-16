home_dir = node['hadoop']['home_dir']

# start hadoop hdfs.
execute 'start hadoop hdfs' do
  command "#{home_dir}/sbin/start-dfs.sh"
  user 'hadoop'
  group 'hadoop'
  returns [0]
  action 'run'
  only_if do
    File.exists?home_dir
  end
end

# start hadoop yarn.
execute 'start hadoop yarn' do
  command "#{home_dir}/sbin/start-yarn.sh"
  user 'hadoop'
  group 'hadoop'
  returns [0]
  action 'run'
  only_if do
    File.exists?home_dir
  end
end
# Default attributes.
default['hadoop'] = {
  'version' => '2.10.0',
  'java_home' => '/usr/lib/jvm/jre-1.8.0-openjdk',
  'heap_size' => '256',
  'home_dir' => '/usr/local/lib/hadoop',
  'base_dir' => '/opt/hadoop',
  'config_dir' => '/opt/hadoop/conf',
  'system_dir' => '/opt/hadoop/system',
  'data_dir' => '/opt/hadoop/data',
  'tmp_dir' => '/opt/hadoop/tmp',
  'log_dir' => '/opt/hadoop/log',
  'ssh' => {
    'private_key' => 'xxxxxxxxx',
    'public_key' => 'xxxxxxxxx'
  }
}

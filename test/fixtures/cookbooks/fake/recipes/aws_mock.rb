include_recipe 'python'

python_pip 'moto'
python_pip 'argparse'

cookbook_file '/usr/local/bin/runmoto' do
  source 'runmoto'
  owner  'root'
  group  'root'
  mode   0755
end

execute 'runmoto' do
  command '/usr/local/bin/runmoto'
  creates '/var/run/moto_server'
  action  :run
end

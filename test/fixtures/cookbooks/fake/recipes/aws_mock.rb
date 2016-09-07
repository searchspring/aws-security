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

# packages to get nokogiri to install with serverspec
package %w(zlib1g-dev liblzma-dev) if platform_family?('debian')

package %w(gcc ruby-devel zlib-devel) if platform_family?('rhel')

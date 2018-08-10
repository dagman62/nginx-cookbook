#
# Cookbook:: nginx
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

log "Your Platform is, #{node["distro"]}!" do
  level :info
end

platform = node['platform']

if platform == 'centos' || platform == 'fedora'
  template '/etc/yum.repos.d/nginx.repo' do
    source 'nginx.repo.erb'
      variables ({
        :distro => node['distro']
      })
      action :create
  end
end

bash 'Update cache and Update' do
  code <<-EOH
  yum makecache && yum update -y
  touch /tmp/updated
  EOH
  action :run
  not_if { File.exist?('/tmp/updated') }
end

package 'nginx' do
  action :install
end

bash 'Create Sites Directories' do
  code <<-EOH
  mkdir /etc/nginx/sites-enabled
  mkdir /etc/nginx/sites-available
  touch /tmp/directories
  EOH
  action :run
  not_if { File.exist?('/tmp/directories') }
end

cookbook_file '/etc/nginx/sites-available/default.conf' do
  source 'default.conf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

cookbook_file '/etc/nginx/nginx.conf' do
  source 'nginx.conf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

link '/etc/nginx/sites-enabled/default.conf' do
  to '/etc/nginx/sites-available/default.conf'
  link_type :symbolic
end

template '/etc/nginx/sites-available/webmin.conf' do
  source 'webmin.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables ({
    :fqdn => node['fqdn']
  })
  action :create
end

template '/etc/nginx/sites-available/jenkins.conf' do
    source 'jenkins.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables ({
      :fqdn => node['fqdn']
    })
    action :create
end
  
link '/etc/nginx/sites-enabled/webmin.conf' do
  to '/etc/nginx/sites-available/webmin.conf'
  link_type :symbolic
end

link '/etc/nginx/sites-enabled/default.conf' do
  to '/etc/nginx/sites-available/webmin.conf'
  link_type :symbolic
end

service 'nginx' do
  action [:start, :enable]
end






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

if platform == 'centos' || platform == 'fedora'
  bash 'Update cache and Update' do
    code <<-EOH
    yum makecache && yum update -y
    touch /tmp/updated
    EOH
    action :run
    not_if { File.exist?('/tmp/updated') }
  end
end

package 'nginx' do
  action :install
end

if platform == 'centos' || platform == 'fedora'
  bash 'Create Sites Directories' do
    code <<-EOH
    mkdir /etc/nginx/sites-enabled
    mkdir /etc/nginx/sites-available
    touch /tmp/directories
    EOH
    action :run
    not_if { File.exist?('/tmp/directories') }
  end
end

cookbook_file '/etc/nginx/sites-available/default.conf.save' do
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

template '/etc/nginx/sites-available/default.conf' do
  source 'default.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables ({
    :staticname => node['staticname'],
    :fqdn       => node['fqdn'],
    :host       => node['hostname'],
    :port       => node['port'],
  })
  action :create
end

link '/etc/nginx/sites-enabled/default.conf' do
  to '/etc/nginx/sites-available/default.conf'
  link_type :symbolic
end

template '/usr/share/nginx/html/index.html' do
  source 'index.html.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables ({
    :fqdn => node['fqdn'],
  })
  action :create
end

service 'nginx' do
  action [:start, :enable]
end






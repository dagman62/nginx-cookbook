#
# Cookbook:: nginx
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

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
  cookbook_file '/etc/nginx/nginx.conf' do
    source 'nginx.conf'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end
end

if platform == 'ubuntu' || platform == 'debian'
  file '/etc/nginx/sites-enabled/default' do
    action :delete
  end
  template '/etc/nginx/sites-available/app.conf' do
    source 'app.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables ({
      :fqdn     =>  node['fqdn'],
      :portnum  =>  node['app']['port'],
    })
    action :create
  end
  link '/etc/nginx/sites-enabled/default' do
    to '/etc/nginx/sites-avaliable/app.conf'
    link_type :symbolic
  end
end

service 'nginx' do
  action [:start, :enable]
end






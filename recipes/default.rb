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
  EOH
  action :run
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



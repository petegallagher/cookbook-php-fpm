#
# Author::  Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: php-fpm
# Recipe:: default
#
# Copyright 2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if node['php-fpm']['skip_repository_install'] == false
  include_recipe 'php-fpm::repository'
end

if node['php-fpm']['package_name'].nil?
  if platform_family?("rhel")
    php_fpm_package_name = "php-fpm"
  else
    php_fpm_package_name = "php5-fpm"
  end
else
  php_fpm_package_name = node['php-fpm']['package_name']
end

package php_fpm_package_name do
  action :upgrade
end

template node['php-fpm']['conf_file'] do
  source "php-fpm.conf.erb"
  mode 00644
  owner "root"
  group "root"
  notifies :restart, "service[php-fpm]"
end

if node['php-fpm']['service_name'].nil?
  php_fpm_service_name = php_fpm_package_name
else
  php_fpm_service_name = node['php-fpm']['service_name']
end

service "php-fpm" do
  provider service_provider if service_provider
  service_name php_fpm_service_name
  supports :start => true, :stop => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

if node['php-fpm']['pools']
  node['php-fpm']['pools'].each do |pool|
    php_fpm_pool pool[:name] do
      pool.each do |k, v|
        self.params[k.to_sym] = v
      end
    end
  end
end

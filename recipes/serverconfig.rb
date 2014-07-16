# Cookbook Name:: wlp
# Attributes:: serverconfig
#
# (C) Copyright IBM Corporation 2013.
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

=begin
#<
Creates a Liberty profile server instance for each `node[:wlp][:servers][<server_name>]` definition.
The following definition creates a simple `airport` server instance:
```ruby
node[:wlp][:servers][:airport] = {
  "enabled" => true,
  "description" => "Airport Demo App",
  "featureManager" => {
    "feature" => [ "jsp-2.2" ]
  },
  "httpEndpoint" => {
    "id" => "defaultHttpEndpoint",
    "host" => "*",
    "httpPort" => "9080",
    "httpsPort" => "9443"
  }
}
```
#>
=end

wlp_user = node[:wlp][:user]
wlp_group = node[:wlp][:group]

utils = Liberty::Utils.new(node)
servers_dir = utils.serversDirectory

node[:wlp][:servers].each_pair do |key, value| 
  map = value.to_hash()
  enabled = map.delete("enabled")
  collective = map.delete("collective")
  isCollectiveController = map.delete("isCollectiveController")
  isCollectiveMember = map.delete("isCollectiveMember")
  Chef::Log.warn "#{key} will be added to the #{collective} collective. Is controller: #{isCollectiveController} member: #{isCollectiveMember}"
  if enabled.nil? || enabled == true || enabled == "true"
    serverName = map.delete("serverName") || key

    directory "#{servers_dir}/#{serverName}" do
      mode   "0775"
      owner  wlp_user
      group  wlp_group
      recursive true
    end

    wlp_config "#{servers_dir}/#{serverName}/server.xml" do
      config map
    end
	
	if enabled.nil? || isCollectiveController == true || isCollectiveController == "true"
	  Chef::Log.warn "Calling wlp_collective"
	  wlp_collective "#{serverName}" do
	    server_name serverName
		keystorePassword "Liberty"
#	    collective "default"
#	    isController true
	  end
	end

	if enabled.nil? || isCollectiveMember == true || isCollectiveMember == "true"
	  Chef::Log.warn "Calling wlp_collective::join"
	  wlp_collective "#{serverName}" do
	    action :join
	    server_name serverName
		host "localhost"
		port "9443"
		user "admin"
		password "adminpwd"
		keystorePassword "Liberty"
#	    collective "default"
#	    isController true
	  end
	end
  end
end

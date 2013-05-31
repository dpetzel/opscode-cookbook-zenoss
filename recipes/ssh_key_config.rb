#Handles configuration of SSH Key related tasks

#store the public key on the server as an attribute
ruby_block "zenoss public key" do
  block do
    pubkey = IO.read("#{node['zenoss']['server']['zenoss_user_homedir']}/.ssh/id_dsa.pub")
	#Don't save to the server, if we are running solo
	if Chef::Config[:solo]
		Chef::Log::warn("Not Saving Key as Attribute since you are running under Chef-Solo")
	else
		node.set["zenoss"]["server"]["zenoss_pubkey"] = pubkey
		node.save
	end
    #write out the authorized_keys for the zenoss user
    ak = File.new("#{node['zenoss']['server']['zenoss_user_homedir']}/.ssh/authorized_keys", "w+")
    ak.puts pubkey
    ak.chown(File.stat("#{node['zenoss']['server']['zenoss_user_homedir']}/.ssh/id_dsa.pub").uid,File.stat("/home/zenoss/.ssh/id_dsa.pub").gid)
  end
  action :nothing
end

#generate SSH key for the zenoss user
execute "ssh-keygen -q -t dsa -f #{node['zenoss']['server']['zenoss_user_homedir']}/.ssh/id_dsa -N \"\" " do
  user "zenoss"
  action :run
  not_if {File.exists?("#{node['zenoss']['server']['zenoss_user_homedir']}/.ssh/id_dsa.pub")}
  notifies :create, resources(:ruby_block => "zenoss public key"), :immediate
end

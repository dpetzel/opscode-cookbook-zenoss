require_relative "./test_helper.rb"

describe_recipe "zenoss::client" do
  describe "users and groups" do
    it "creates the zenoss user" do
      skip "Local user creation attribute set to false" unless node['zenoss']['client']['create_local_zenoss_user'] 
      skip "Local Zenoss user creation not supported on Windows" if node[:os] == "windows"
      user_name = node['zenoss']['client']['zenoss_user_name'] 
      home_dir = node['zenoss']['client']['zenoss_user_homedir']
      user(user_name).must_exist
      user(user_name).must_have(:home, home_dir) unless node[:os] == "windows"
      user(user_name).must_have(:comment, 'Zenoss monitoring account')
    end
  end
  
  describe "directories" do
    it "creates the zenoss user's .ssh directory" do
      skip "Local user creation attribute set to false" unless node['zenoss']['client']['create_local_zenoss_user'] 
      skip "Local Zenoss user creation not supported on Windows" if node[:os] == "windows"
      user_name = node['zenoss']['client']['zenoss_user_name'] 
      home_dir = node['zenoss']['client']['zenoss_user_homedir']
      directory("#{home_dir}/.ssh").must_exist.with(:owner, user_name)
    end
  end
end
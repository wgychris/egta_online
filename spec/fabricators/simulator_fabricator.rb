Fabricator(:simulator) do
  name "epp_sim"
  email 'test@test.com'
  version {Fabricate.sequence(:version, 1) {|i| "test#{i}"}}
  parameter_hash { {"Parm1"=>"2","Parm2"=>"3"} }
  after_create {|sim| if sim.parameter_hash.is_a?(String); sim.update_attribute(:parameter_hash, eval(sim.parameter_hash)); end }
end

Fabricator(:simulator_with_strategies, :from => :simulator) do
  name "epp_sim"
  version "testing"
  email 'test@test.com'
  roles(:count => 1) {|sim, i| Fabricate(:role, :role_owner => sim, :name => "All", :count => nil)}
  parameter_hash { Hash["a" => "2"] }
  after_create do |sim| 
    if sim.parameter_hash.is_a?(String)
      sim.update_attribute(:parameter_hash, eval(sim.parameter_hash))
    end
    sim.roles.first.strategies << "A"
    sim.roles.first.strategies << "B"
  end
end

Fabricator(:simulator_realistic, :from => :simulator) do
  name "epp_sim"
  version "test"
  email 'test@test.com'
  simulator_source File.new("#{Rails.root}/features/support/epp_sim.zip")
end
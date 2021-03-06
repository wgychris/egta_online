Given /^that simulator has the strategy array "([^"]*)"$/ do |arg1|
  eval(arg1).each {|st| @simulator.add_strategy("All", st)}
  @simulator.save!
end

Then /^that simulator should have a role named "([^"]*)" with the strategy array "([^"]*)"$/ do |arg1, arg2|
  r = Simulator.last.roles.where(name: arg1).first
  r.should_not == nil
  r.strategies == eval(arg2)
end

Given /^that simulator has the role strategy hash "([^"]*)"$/ do |arg1|
  Simulator.last.update_attribute(:role_strategy_hash, eval(arg1))
end

Given /^that simulator has (\d+) role$/ do |arg1|
  arg1.to_i.times {@simulator.roles << Fabricate.build(:role)}
  @simulator.save!
end

Given /^that simulator has (\d+) game scheduler$/ do |arg1|
  arg1.to_i.times {Fabricate(:game_scheduler, :simulator => @simulator)}
  @simulator.save!
end

Given /^that role has (\d+) strategies$/ do |arg1|
  role = @simulator.roles.last
  arg1.to_i.times {|i| role.strategies << "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[i]}
  role.save!
end

Given /^that role has the strategies "([^"]*)" and "([^"]*)"$/ do |arg1, arg2|
  role = @simulator.roles.last
  role.strategies << arg1
  role.strategies << arg2
  role.save!
end

Given /^the strategy "([^"]*)"$/ do |arg1|
  @strategy = arg1
end
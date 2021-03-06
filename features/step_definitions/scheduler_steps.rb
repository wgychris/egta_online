When /^I add strategy "([^"]*)" to that symmetric game scheduler$/ do |arg1|
  @symmetric_game_scheduler.add_strategy(arg1)
end

Then /^I should have (\d+) simulations?$/ do |arg1|
  Simulation.count.should == arg1.to_i
end

Then /^I should have (\d+) simulations? scheduled$/ do |arg1|
  (Simulation.active.count+Simulation.pending.count).should == arg1.to_i
end

Then /^that simulation should have profile "([^"]*)"$/ do |arg1|
  @simulation = Simulation.first
  Profile.find(@simulation.profile_id).name.should == arg1
end

Then /^that simulation should have state "([^"]*)"$/ do |arg1|
  @simulation.state.should == arg1
end

Then /^all simulations should have state "([^"]*)"$/ do |arg1|
  Simulation.all.each { |sim| sim.state.should == "pending" }
end

Given /^that symmetric game scheduler is active$/ do
  @symmetric_game_scheduler.update_attribute(:active, true)
end

When /^I fail a simulation$/ do
  with_resque do
    @simulation = Simulation.first
    @simulation.failure!
  end
end

Then /^a new simulation should exist with identical settings to that simulation$/ do
  @new_simulation = Simulation.last
  @new_simulation.state.should == 'pending'
  @new_simulation.scheduler.should == @simulation.scheduler
  @new_simulation.profile.should == @simulation.profile
  @new_simulation.size.should == @simulation.size
end

Then /^a new simulation should not be created$/ do
  Simulation.count.should == 1
end

Given /^that symmetric profile belongs to the last scheduler$/ do
   scheduler = Scheduler.last
   scheduler.profiles << @symmetric_profile
   @symmetric_profile.save!
end

Given /^the last scheduler has that profile$/ do
  scheduler = Scheduler.last
  scheduler.profile_ids << @profile.id
  scheduler.save!
end

Given /^the last scheduler has the strategy "([^"]*)"$/ do |arg1|
  scheduler = Scheduler.last
  scheduler.add_strategy("All", arg1)
  scheduler.save!
end

When /^I delete the strategy "([^"]*)"$/ do |arg1|
  Scheduler.last.remove_strategy("All", arg1)
end

Then /^the last scheduler should have (\d+) profiles$/ do |arg1|
  Scheduler.last.profile_ids.size.should == 0
end

Given /^there is a simulator with corresponding game scheduler$/ do
  with_resque do
    @simulator = Fabricate(:simulator)
    @simulator.add_role("All")
    @simulator.add_strategy("All", "A")
    @simulator.add_strategy("All", "B")
    @game_scheduler = Fabricate(:game_scheduler, :simulator_id => @simulator.id)
    @game_scheduler.add_role("All", @game_scheduler.size)
    @game_scheduler.add_strategy("All", "A")
    @game_scheduler.add_strategy("All", "B")
  end
end

Then /^I should have (\d+) profile to be scheduled$/ do |arg1|
  ProfileScheduler.should have_scheduled(Profile.last.id).in(5 * 60)
end

Then /^that game should match the game scheduler$/ do
  @game = Game.last
  @game_scheduler = Scheduler.last
  @game.parameter_hash.should == @game_scheduler.parameter_hash
  Profile.where(:_id.in => @game.profile_ids).order_by(:name).to_a.should == Profile.where(:_id.in => @game_scheduler.profile_ids).order_by(:name).to_a
  Profile.count.should == @game.profile_ids.size
end
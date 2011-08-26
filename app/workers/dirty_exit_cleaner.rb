class DirtyExitCleaner
  @queue = :profile_actions

  def self.perform
    puts "making sure pending simulations got queued"
    Simulation.pending.each {|s| Resque.enqueue(SimulationQueuer, s.id)}
    puts "ensuring profiles that are due for more simulations get them"
    Simulation.finished.where(:updated_at.gt => (Time.current-3600)).each {|s| s.requeue}
  end
end
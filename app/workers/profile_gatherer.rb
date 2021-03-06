class ProfileGatherer
  @queue = :profile_actions

  def self.perform(game_id)
    game = Game.find(game_id) rescue nil
    if game != nil
      game.profiles = Profile.where(simulator_id: game.simulator_id, parameter_hash: game.parameter_hash, size: game.size)
      game.save
    end
  end
end
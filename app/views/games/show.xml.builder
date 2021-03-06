xml.instruct! :xml, :version=>"1.0"
xml.nfg(:name=>game.simulator.fullname, :description=>game.parameter_hash) do |nfg|

  nfg.players do |players|
    for i in 1..@profiles.first.size do
      players.player(:id=>"player#{i}")
    end
  end
  nfg.actions do |actions|
    game.roles.first.strategies.each do |strategy|
      actions.action(:id=>strategy)
    end
  end
  nfg.payoffs do |payoffs|
    @profiles.each do |profile|
      payoffs.payoff do |payoff|
        strategies = profile.name.split(": ")[1].split(", ")
        strategies.each do |strategy|
          payoff.outcome(:action=>strategy.split(" ")[1],
                         :count=>strategy.split(" ")[0],
                         :value=>profile.role_instances.first.strategy_instances.where(name: strategy.split(" ")[1]).first.payoff)
        end
      end
    end
  end
end
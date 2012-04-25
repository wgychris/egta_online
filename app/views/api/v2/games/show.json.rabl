object @object

attributes :id, :name, :simulator_fullname, :parameter_hash
child :roles do |r|
  attributes :name, :count, :strategies
end
if @full == "true"
  child :cv_manager do |cv|
    child :features => :features do |f|
      attributes :name, :expected_value, :adjustment_coefficient
    end
  end
end
if @adjusted == "true"
  if @full != "true"
    child :cv_manager do |cv|
      child :features => :features do |f|
        attributes :name, :expected_value, :adjustment_coefficient
      end
    end
  end
  child :display_profiles => :profiles do |p|
    attributes :id, :sample_count
    child :role_instances => :roles do |r|
      attribute :name
      child :strategy_instances => :strategies do |s|
        attributes :name, :count
        node(:payoff){|m| @payoffs = m.adjusted_payoffs(@object.cv_manager); @payoffs.mean }
        node(:payoff_sd){|m| @payoffs.sd }
      end
    end
  end
else
  child :display_profiles => :profiles do |p|
    extends "api/v2/profiles/show"
  end
end
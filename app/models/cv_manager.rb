# Manages control variables
class CvManager
  include Mongoid::Document
  embedded_in :game
  embeds_many :features
  
  def add_feature(feature_params)
    f = self.features.create(feature_params)
    self.save
  end
  
  def remove_feature(feature_id)
    self.features.where(:_id => feature_id).destroy_all
    self.save
  end
  
  def calculate_coefficients
    payoffs = []
    feature_hash = Hash.new {|hash, key| hash[key] = []}
    self.game.display_profiles.each do |profile|
      profile.sample_records.limit(10).collect do |sample_record|
        flag = true
        self.features.each do |feature|
          flag = false if sample_record.features[feature.name] == nil
        end
        if flag
          self.features.each do |feature|
            feature_hash[feature.name] << sample_record.features[feature.name]
          end
          payoff_array = sample_record.payoffs.values.collect{|r| r.values}.flatten
          payoffs << payoff_array.reduce(:+)/payoff_array.size
        end
      end
    end
    if payoffs != []
      feature_hash.each{|key, value| feature_hash[key] = feature_hash[key].to_scale}
      ds = feature_hash.to_dataset
      ds['payoff'] = payoffs.to_scale
      lr = Statsample::Regression.multiple(ds, 'payoff')
      self.features.each do |feature|
        feature.update_attribute(:adjustment_coefficient, lr.coeffs[feature.name])
      end
    end
  end
end
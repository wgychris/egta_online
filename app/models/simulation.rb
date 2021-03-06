# This class represents simulations run by the testbed. It uses AASM (Act-As-State-Machine) gem to
# make a transition between different states.

class Simulation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Sequence

  belongs_to :account
  belongs_to :profile, :inverse_of => :simulations
  belongs_to :scheduler, :inverse_of => :simulations

  delegate :name, :to => :profile, :prefix => true
  delegate :nodes, :to => :scheduler, :prefix => true
  delegate :simulator_fullname, :to => :scheduler

  field :size, :type => Integer
  field :state
  field :job_id
  field :error_message
  field :created_at
  field :flux, :type => Boolean, :default => false
  field :account_username
  field :profile_name
  field :number, :type=>Integer
  sequence :number
  index [[:state, Mongo::ASCENDING]]
  scope :flux, where(:flux => true)
  scope :pending, where(:state=>'pending')
  scope :queued, where(:state=>'queued')
  scope :running, where(:state=>'running')
  scope :complete, where(:state=>'complete')
  scope :failed, where(:state=>'failed')
  scope :stale, where(:state.in=>['queued', 'complete', 'failed']).and(:updated_at.lt => (Time.current-300000))
  scope :active, where(:state.in=>['queued','running'])
  scope :finished, where(:state.in=>['complete', 'failed'])
  scope :scheduled, where(:state.in=>['pending','queued','running'])
  validates_presence_of :state, :on => :create, :message => "can't be blank"
  validates_presence_of :profile
  validates_numericality_of :size, :only_integer=>true, :greater_than=>0

  before_save(:on => :create){self.account_username = self.account.username; self.profile_name = self.profile.name}

  state_machine :state, :initial => :pending do
    state :pending
    state :queued
    state :running
    state :complete
    state :failed

    after_transition :on => [:failure, :finish], :do => :requeue

    event :queue do
      transition [:queued, :pending] => :queued
    end

    event :failure do
      transition [:pending, :queued, :running] => :failed
    end

    event :start do
      transition [:queued, :running] => :running
    end

    event :finish do
      transition [:pending, :queued, :running, :failed] => :complete
    end

  end

  def requeue
    self.profile.try_scheduling
  end
end
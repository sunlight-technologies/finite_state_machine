require "./lib/fsm"

class Fsm::TransitionError < StandardError
  attr_accessor :message, :object

  def initialize(object)
    @object = object
  end
end

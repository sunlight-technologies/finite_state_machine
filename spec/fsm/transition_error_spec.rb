require "spec_helper"

RSpec.describe Fsm::TransitionError, type: :error do
  subject { described_class.new(double(:fsm)) }

  it "is a StandardError" do
    expect(subject).to be_a(StandardError)
  end
end

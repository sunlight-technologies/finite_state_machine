require "spec_helper"

RSpec.describe Fsm::Machine, type: :machine do
  let(:schema) do
    [
      {
        from: [:open],
        to:   :waiting,
        call: :send_order_for_approval
      },
      {
        from: [:open, :waiting, :approved, :waiting_manager_approval, :manager_approved],
        to:   :cancelled,
        call: :cancel
      },
      {
        from: [:waiting],
        to:   :approved,
        call: :approve_order_as_recipient
      },
      {
        from: [:approved, :manager_approved],
        to:   :completed,
        call: :complete
      },
      {
        from: [:approved],
        to:   :waiting_manager_approval,
        call: :send_for_manager_approval
      },
      {
        from: [:waiting_manager_approval],
        to:   :manager_approved,
        call: :approve_order_as_manager
      },
      {
        from: [:completed],
        to:   :refunded,
        call: :refund
      }
    ]
  end

  describe "#transition" do
    context "when a transition is valid" do
      it "returns the name of the transition to be executed" do
        expect(Fsm::Machine.new(schema: schema, changeset: [:open, :waiting]).transition).to eq(:send_order_for_approval)
        expect(Fsm::Machine.new(schema: schema, changeset: [:open, :cancelled]).transition).to eq(:cancel)
        expect(Fsm::Machine.new(schema: schema, changeset: [:waiting, :approved]).transition).to eq(:approve_order_as_recipient)
        expect(Fsm::Machine.new(schema: schema, changeset: [:approved, :completed]).transition).to eq(:complete)
        expect(Fsm::Machine.new(schema: schema, changeset: [:approved, :waiting_manager_approval]).transition).to eq(:send_for_manager_approval)
        expect(Fsm::Machine.new(schema: schema, changeset: [:waiting_manager_approval, :manager_approved]).transition).to eq(:approve_order_as_manager)
        expect(Fsm::Machine.new(schema: schema, changeset: [:manager_approved, :completed]).transition).to eq(:complete)
        expect(Fsm::Machine.new(schema: schema, changeset: [:completed, :refunded]).transition).to eq(:refund)
      end
    end

    context "when a transition is invalid" do
      it "returns false" do
        expect(Fsm::Machine.new(schema: schema, changeset: [:approved, :waiting]).transition).to eq(false)
        expect(Fsm::Machine.new(schema: schema, changeset: [:completed, :waiting_manager_approval]).transition).to eq(false)
        expect(Fsm::Machine.new(schema: schema, changeset: [:manager_approved, :waiting_manager_approval]).transition).to eq(false)
      end

      it "populates errors" do
        fsm = Fsm::Machine.new(schema: schema, changeset: [:approved, :waiting])
        fsm.transition
        expect(fsm.error.message).to eq("Could not find a transition from approved to waiting")
      end
    end
  end

  describe "transition!" do
    context "when a transition is invalid" do
      subject do
        Fsm::Machine.new(schema: schema, changeset: [:approved, :waiting])
      end

      it "raises an exception and populates errors" do
        expect { subject.transition! }.to raise_exception(Fsm::TransitionError)
        expect(subject.error).to be_a(Fsm::TransitionError)
      end
    end
  end
end

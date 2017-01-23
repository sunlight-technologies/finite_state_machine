module Fsm
  class Machine
    attr_accessor :schema, :from, :to, :error

    def initialize(schema:, changeset:)
      raise ArgumentError.new("changeset argument must be an array with only 2 elements") unless (changeset.is_a?(Array) && changeset.length == 2)
      raise ArgumentError.new("schema is invalid") unless valid_schema?(schema)
      @schema    = schema
      @from, @to = changeset
    end

    def transition
      found_transition = schema.dup.select do |mapping|
        mapping[:from].include?(from.to_sym) && mapping[:to] == to.to_sym
      end

      if found_transition.length > 1
        @error = TransitionError.new(self)
        @error.message = "Found an ambiguous number of transitions that can ocurr: #{found_transition.map { |x| x[:call] }}"
        false
      elsif found_transition.length < 1
        @error = TransitionError.new(self)
        @error.message = "Could not find a transition from #{from} to #{to}"
        false
      else
        found_transition.pop[:call]
      end
    end

    def transition!
      transition || raise(error)
    end

    def valid_schema?(schema)
      return false unless schema.is_a?(Array)
      schema.all? do |mapping|
        mapping.keys == [:from, :to, :call] &&
        mapping[:from].is_a?(Array) &&
        mapping[:to].is_a?(Symbol) &&
        mapping[:call].is_a?(Symbol)
      end
    end
  end
end

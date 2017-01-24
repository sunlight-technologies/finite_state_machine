# Finite state machine 

>  A FSM is defined by a list of its states, its initial state, and the conditions for each transition.

[Source](https://en.wikipedia.org/wiki/Finite-state_machine)

This library provides a dependency-free finite state machine implementation in Ruby that allows you to elegantly manage state making use of it's tiny API. Using it has only 3 simple steps

- 1) Declare a schema of transitions 📝
- 2) Build a machine using the schema and a changeset of statuses(which is just an array with `[old_status, new_status]`) 🤖
- 3) Act on transition! 🦍

```ruby
require "fsm"

# Declare a schema as a list of transitions

schema = [
  {
    from: [:walking, :running],
    to:   :flying,
    call: :jump
  },
  {
    from: [:flying],
    to:   :walking,
    call: :soft_landing
  },
  {
    from: [:flying],
    to:   :running,
    call: :hard_landing
  }
]

Fsm::Machine.new(schema: schema, changeset: [:walking, :flying]).transition
#=> :jump
```

## Contributing

- Open an issue
- Discuss details
- Submit a PR

# Skip pending test. "mix test --include pending" to force include
ExUnit.configure(exclude: [pending: true])
ExUnit.start()

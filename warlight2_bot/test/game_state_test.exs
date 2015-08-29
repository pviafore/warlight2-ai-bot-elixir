defmodule GameStateTestMacro do

  defmacro test_state desc, setting, func, first_val, second_val do

    quote do
       test unquote(desc) do
          assert %{GameState.initial | unquote(setting) => unquote(first_val)} ==  apply(GameState, unquote(func), [GameState.initial(), unquote(first_val)])
          assert %{GameState.initial | unquote(setting) => unquote(second_val)} == apply(GameState, unquote(func), [apply(GameState, unquote(func), [GameState.initial(), unquote(first_val)]), unquote(second_val)])

       end
    end
  end

end

defmodule GameStateTest do
   use ExUnit.Case
   require GameStateTestMacro
   test "should have correct initial state" do
       assert %{:timebank => 0, :time_per_move => 0,
                :max_rounds => 0, :bot_name =>""} == GameState.initial()
   end
   GameStateTestMacro.test_state "should set timebank", :timebank, :set_timebank, 1000, 100
   GameStateTestMacro.test_state "should set time per move", :time_per_move, :set_time_per_move, 500, 50
   GameStateTestMacro.test_state "should set max_rounds", :max_rounds, :set_max_rounds, 100, 200

end

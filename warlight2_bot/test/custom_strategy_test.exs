defmodule CustomStrategyTest do
   use ExUnit.Case
   test "can assign number of moves to conquer region - one region" do
       game_state = GameState.initial
                  |> GameState.set_super_regions([["1", 2]])
                  |> GameState.set_regions [{"1", ["1"]}]
       assert CustomStrategy.get_expected_number_of_moves_to_conquer(game_state, "1") == 1
   end

end

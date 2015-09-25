defmodule CustomStrategyTestMacro do
   defmacro test_strategy_pick_starting(text, regions, state, expected) do
     quote do
        test unquote(text) do
            strategy = CustomStrategy.start(self())
            send strategy, {:pick_starting, {unquote(regions), unquote(state)}}
            receive do
               {:message, m} -> assert m == unquote(expected)
               _ -> assert false, "Incorrect message received"
            end
        end

     end

   end

end

defmodule CustomStrategyTest do
   use ExUnit.Case
   require CustomStrategyTestMacro

   defp create_game_state super_regions, regions do
      GameState.initial
      |> GameState.set_super_regions(super_regions)
      |> GameState.set_regions regions
   end

   CustomStrategyTestMacro.test_strategy_pick_starting "picks only starting region when one region", ["1"], create_game_state([["1", 2]],  [{"1", ["1"]}]), "1"
   CustomStrategyTestMacro.test_strategy_pick_starting "picks starting region with higher troop count if equal size", ["1", "2"], create_game_state([["1", 2], ["2", 3]],  [{"1", ["1"]}, {"2", ["2"]}]), "2"


end

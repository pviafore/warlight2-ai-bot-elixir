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

   defp create_game_state super_regions,  regions, wastelands do
       create_game_state(super_regions, regions) |> GameState.set_wastelands(wastelands)
   end


      defp create_game_state super_regions,  regions, wastelands,neighbors do
          create_game_state(super_regions, regions, wastelands) |> GameState.set_neighbors(neighbors)
      end

   CustomStrategyTestMacro.test_strategy_pick_starting "picks only starting region when one region", ["1"], create_game_state([["1", 2]],  [{"1", ["1"]}]), "1"
   CustomStrategyTestMacro.test_strategy_pick_starting "picks starting region with higher troop count if equal size", ["1", "2"], create_game_state([["1", 2], ["2", 3]],  [{"1", ["1"]}, {"2", ["2"]}]), "2"
   CustomStrategyTestMacro.test_strategy_pick_starting "picks starting region with less moves to make if equal troop counts", ["1", "2"], create_game_state([["1", 2], ["2", 2]],  [{"1", ["1", "3"]}, {"2", ["2" ]}]), "2"
   CustomStrategyTestMacro.test_strategy_pick_starting "picks starting region with no wastelands over one with wastelands", ["1", "2"], create_game_state([["1", 2], ["2", 2]],  [{"1", ["1", "3"]}, {"2", ["2", "4" ]}], ["2", "4"]), "2"
   #CustomStrategyTestMacro.test_strategy_pick_starting "picks starting region with fewer moves to conquer", ["1", "2"], create_game_state([["1", 2], ["2", 2]],  [{"1", ["1", "3", "5", "6"]}, {"2", ["2", "4", "7", "8" ]}], [], %{"1"=>["3"], "2"=>["4", "7", "8"], "3"=>["5"], "5"=>["6"], "2"=>["4"]}), "2"



end

defmodule CustomStrategy do


   def start(outputter) do
       {:ok, logic} = Task.start_link(fn->recv(outputter) end)
       logic
   end

#this strategy works by prioritizing super regions for more bang for the buck
   def get_expected_number_of_moves_to_conquer(state, super_region) do
      1
   end

   defp pick_random list do
     if length(list) == 1 do
         List.first(list)
     else
        Enum.at(list, :random.uniform(length(list)) - 1)
     end
   end

   defp get_own_areas(state) do
      Enum.map (Enum.filter state.ownership, (fn {_, {player_name, _}} -> player_name == state.bot_name end)), &(elem(&1, 0))
   end

   defp place_armies_randomly_at_one_location(state) do
       own_areas = get_own_areas state
       state.bot_name <> " place_armies " <> pick_random(own_areas) <> " " <> Integer.to_string state.starting_armies
   end

   defp attack_randomly(state) do

       own_areas = get_own_areas state
       big_areas = Enum.filter own_areas, &(GameState.get_armies(state, &1) > 1)
       starting_region = pick_random(big_areas)
       neighbors = state.neighbors[starting_region]
       num_armies = Integer.to_string(GameState.get_armies(state, starting_region) - 1)

       state.bot_name <> " attack/transfer " <> starting_region <> " " <> pick_random(neighbors) <> " " <> num_armies

   end

   defp get_super_region(region, state) do
       {region, elem( (Enum.find state.map, &(region in elem(&1, 1).regions)), 0)}

   end

   defp get_number_of_wastelands(state, super_region) do
      regions = state.map[super_region].regions
      Enum.filter((Enum.map regions, &(elem(state.ownership[&1], 1))), &(&1 == 6))

   end


   defp super_region_sort_func(state) do

     fn
      {reg1, super1}, {reg2, super2} ->
         cond do
            get_number_of_wastelands(state, super1) != get_number_of_wastelands(state, super2) -> get_number_of_wastelands(state, super1) >= get_number_of_wastelands(state, super2)
            length(state.map[super1].regions) != length(state.map[super2].regions) -> length(state.map[super2].regions) >= length(state.map[super1].regions)
            true ->state.map[super1].bonus_armies >= state.map[super2].bonus_armies
         end
     end
   end

   defp pick_starting areas, state do
      super_regions = areas |> Enum.map &(get_super_region &1, state)
      elem(List.first(Enum.sort(super_regions, super_region_sort_func(state))), 0)

   end

   def recv outputter do
         receive do
          {:pick_starting, {areas, state}} ->
               send outputter, {:message, pick_starting(areas, state)}
          {:place_armies, state} ->
               msg = place_armies_randomly_at_one_location(state)
               send outputter, {:message, msg}
          {:attack_transfer, state} ->
               msg = attack_randomly(state)
               send outputter, {:message, msg}
          _ ->
               send outputter, {:error, "Invalid Message Received"}
       end
       recv(outputter)
   end

end

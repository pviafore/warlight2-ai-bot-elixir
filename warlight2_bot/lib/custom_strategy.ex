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


   defp get_other_areas(state) do
      Enum.map (Enum.filter state.ownership, (fn {_, {player_name, _}} -> player_name != state.bot_name end)), &(elem(&1, 0))
   end

   defp place_armies_randomly_at_one_location(state) do
       own_areas = MapHelper.get_owned_areas state.ownership, state.bot_name
       unowned_areas = MapHelper.get_unowned_areas state.ownership, state.bot_name
       fringe_areas = Enum.sort_by own_areas, &(length Enum.filter(state.neighbors[&1], fn(x) -> x in unowned_areas end))
       state.bot_name <> " place_armies " <> pick_random(own_areas) <> " " <> Integer.to_string state.starting_armies
   end

   defp get_areas_to_attack state, region do
       unowned_regions = MapHelper.get_unowned_areas(state.ownership, state.bot_name)
       Enum.filter state.neighbors[region], &(&1 in unowned_regions)

   end


   defp get_attacks(state, region) do
      areas_to_attack = get_areas_to_attack state,region
      armies = GameState.get_armies(state, region) - 1
      if areas_to_attack != [] do
         attack_foreign_places(state, region, areas_to_attack, armies)
      else
         region <> " " <> pick_random(state.neighbors[region]) <> " " <> Integer.to_string(armies)
      end

   end

   def attack_foreign_places(state, region, areas, armies) when armies <= 0 or areas == [] do
      []
   end

   defp get_minimum_attack_strength(their_units) do
      trunc (their_units / (0.6 * 0.84) + 1)
   end

   def attack_foreign_places(state, region, [target | areas], armies) do
      min_strength = get_minimum_attack_strength(GameState.get_armies(state, target))
      if min_strength > armies do
         attack_foreign_places(state, region, areas, armies)
      else
          [region <> " " <> target <> " " <> Integer.to_string(min_strength)] ++ attack_foreign_places(state, region, areas, armies - min_strength)

      end
   end


   defp get_attack_strings(state, areas) do
      strings = Enum.map(areas, &(get_attacks state,&1)) |> Enum.filter &(&1 != [])
      if strings != [] do
          Enum.reduce List.flatten(strings), "", &(&2 <> state.bot_name <> " attack/transfer " <> &1 <> ", ")
      else
          "No Moves"
      end
   end

   defp attack_randomly(state) do

       own_areas = MapHelper.get_owned_areas state.ownership, state.bot_name
       big_areas = Enum.filter own_areas, &(GameState.get_armies(state, &1) > 1)
       get_attack_strings(state, big_areas)
   end

   defp get_super_region(region, state) do
       {region, MapHelper.get_super_region(state.map, region)}
   end

   defp get_number_of_wastelands(state, super_region) do
      MapHelper.get_number_of_wastelands(state.map, state.ownership, super_region)
   end

   defp get_number_of_turns_until_conquered(state, super_region) do
      regions_of_interest = MapHelper.get_unowned_areas state.ownership, state.bot_name |>
                          MapHelper.filter_by_super_region state.map, super_region
      if length regions_of_interest == 0 do
           0
      else
           0
      end
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

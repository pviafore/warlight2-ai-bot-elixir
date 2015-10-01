defmodule MapHelper do

   def get_owned_areas(ownership_list, name) do
      Enum.map (Enum.filter ownership_list, (fn {_, {player_name, _}} -> player_name == name end)), &(elem(&1, 0))
   end

   def get_unowned_areas(ownership_list, name) do
      Enum.map (Enum.filter ownership_list, (fn {_, {player_name, _}} -> player_name != name end)), &(elem(&1, 0))
   end

   def get_super_region(map, region) do
      elem( (Enum.find map, &(region in elem(&1, 1).regions)), 0)
   end

   def get_number_of_wastelands(map, ownership_list, super_region) do
      regions = map[super_region].regions
      owner_lists = Enum.filter ownership_list, &(elem(&1, 0) in regions)
      length(Enum.filter owner_lists, fn {_, {_, num}} -> num == 6 end)
   end

   def filter_by_super_region(regions, map, super_region) do
      Enum.filter(regions, &(&1 in map[super_region].regions))
   end
end

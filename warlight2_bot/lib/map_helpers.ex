defmodule MapHelper do

   def get_owned_areas(ownership_list, name) do
      Enum.map (Enum.filter ownership_list, (fn {_, {player_name, _}} -> player_name == name end)), &(elem(&1, 0))
   end

   def get_unowned_areas(ownership_list, name) do
      Enum.map (Enum.filter ownership_list, (fn {_, {player_name, _}} -> player_name != name end)), &(elem(&1, 0))
   end
end

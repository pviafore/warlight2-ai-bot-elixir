defmodule MapHelpersTest do
   use ExUnit.Case

   test "should find owned list on empty list" do
      assert [] == MapHelper.get_owned_areas([], "hello")
   end

   test "should find owned list on unowned list" do
      assert [] == MapHelper.get_owned_areas([{1, {"nope", 3}}, {2, {"nope", 4}}], "hello")
   end

   test "should find owned list where an owner exists" do
      assert [3] == MapHelper.get_owned_areas([{1, {"nope", 3}}, {2, {"nope", 4}}, {3, {"hello", 5}}], "hello")
   end

   test "should find unowned list on empty list" do
      assert [] == MapHelper.get_unowned_areas([], "hello")
   end

   test "should find unowned list on unowned list" do
      assert [] == MapHelper.get_unowned_areas([{1, {"nope", 3}}, {2, {"nope", 4}}], "nope")
   end

   test "should find unowned list where an owner exists" do
      assert [3] == MapHelper.get_unowned_areas([{1, {"nope", 3}}, {2, {"nope", 4}}, {3, {"hello", 5}}], "nope")
   end

   test "can find super region" do
       assert "5" == MapHelper.get_super_region %{"2" =>%{:regions => [1,3]}, "5" =>%{:regions => [4,6]}}, 6
       assert "2" == MapHelper.get_super_region %{"2" => %{:regions => [1,3]}, "5" => %{:regions => [4,6]}}, 3
   end

   test "can find number of wastelands in non wasteland superregion " do
      assert 0 == MapHelper.get_number_of_wastelands %{"2" =>%{:regions => ["1"]}, "5" =>%{:regions => ["2","3"]}}, [{"1", {"nope", 3}}, {"2", {"nope", 4}}, {"3", {"neutral", 6}}], "2"
      assert 1 == MapHelper.get_number_of_wastelands %{"2" =>%{:regions => ["1"]}, "5" =>%{:regions => ["2","3"]}}, [{"1", {"nope", 3}}, {"2", {"nope", 4}}, {"3", {"neutral", 6}}], "5"

   end
end

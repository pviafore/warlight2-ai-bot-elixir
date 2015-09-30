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
end
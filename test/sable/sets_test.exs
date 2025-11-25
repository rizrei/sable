defmodule Sable.SetsTest do
  use Sable.DataCase

  alias Sable.Sets

  describe "sets" do
    alias Sable.Sets.Set

    import Sable.AccountsFixtures, only: [user_scope_fixture: 0]
    import Sable.SetsFixtures

    @invalid_attrs %{comment: nil}

    test "list_sets/1 returns all scoped sets" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      set = set_fixture(scope)
      other_set = set_fixture(other_scope)
      assert Sets.list_sets(scope) == [set]
      assert Sets.list_sets(other_scope) == [other_set]
    end

    test "get_set!/2 returns the set with given id" do
      scope = user_scope_fixture()
      set = set_fixture(scope)
      other_scope = user_scope_fixture()
      assert Sets.get_set!(scope, set.id) == set
      assert_raise Ecto.NoResultsError, fn -> Sets.get_set!(other_scope, set.id) end
    end

    test "create_set/2 with valid data creates a set" do
      valid_attrs = %{comment: "some comment"}
      scope = user_scope_fixture()

      assert {:ok, %Set{} = set} = Sets.create_set(scope, valid_attrs)
      assert set.comment == "some comment"
      assert set.user_id == scope.user.id
    end

    test "create_set/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Sets.create_set(scope, @invalid_attrs)
    end

    test "update_set/3 with valid data updates the set" do
      scope = user_scope_fixture()
      set = set_fixture(scope)
      update_attrs = %{comment: "some updated comment"}

      assert {:ok, %Set{} = set} = Sets.update_set(scope, set, update_attrs)
      assert set.comment == "some updated comment"
    end

    test "update_set/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      set = set_fixture(scope)

      assert_raise MatchError, fn ->
        Sets.update_set(other_scope, set, %{})
      end
    end

    test "update_set/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      set = set_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Sets.update_set(scope, set, @invalid_attrs)
      assert set == Sets.get_set!(scope, set.id)
    end

    test "delete_set/2 deletes the set" do
      scope = user_scope_fixture()
      set = set_fixture(scope)
      assert {:ok, %Set{}} = Sets.delete_set(scope, set)
      assert_raise Ecto.NoResultsError, fn -> Sets.get_set!(scope, set.id) end
    end

    test "delete_set/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      set = set_fixture(scope)
      assert_raise MatchError, fn -> Sets.delete_set(other_scope, set) end
    end

    test "change_set/2 returns a set changeset" do
      scope = user_scope_fixture()
      set = set_fixture(scope)
      assert %Ecto.Changeset{} = Sets.change_set(scope, set)
    end
  end
end

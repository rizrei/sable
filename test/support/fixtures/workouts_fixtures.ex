defmodule Sable.WorkoutsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sable.Workouts` context.
  """

  @doc """
  Generate a workout.
  """
  def workout_fixture(attrs \\ %{}) do
    {:ok, workout} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title"
      })
      |> Sable.Workouts.create_workout()

    workout
  end
end

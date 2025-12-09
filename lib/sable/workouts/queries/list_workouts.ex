defmodule Sable.Workouts.Queries.ListWorkouts do
  @moduledoc """
  A query module for filtering Workouts based on parameters.
  """

  import Ecto.Query

  alias Sable.Workouts.Queries.ListWorkouts.Params
  alias Sable.Workouts.Queries.ListWorkouts.Params.Filter
  alias Sable.Workouts.{Workout, WorkoutTag}

  def call(%Params{limit: limit, offset: offset, filter: filter, order_by: order_by}) do
    Workout
    |> with_filter(filter)
    |> with_order(order_by)
    |> with_limit(limit)
    |> with_offset(offset)
  end

  defp with_filter(query, %Filter{} = filter) do
    filter
    |> Map.from_struct()
    |> Enum.reduce(query, fn
      {:search, term}, query -> with_search(query, term)
      {:tag_id, tag_id}, query -> with_tag_id(query, tag_id)
    end)
  end

  defp with_search(query, term) when is_binary(term),
    do: where(query, [q], ilike(q.title, ^"%#{term}%"))

  defp with_search(query, _), do: query

  defp with_tag_id(query, nil), do: query
  defp with_tag_id(query, []), do: query

  defp with_tag_id(query, tag_ids) do
    query
    |> join(:left, [w], wt in WorkoutTag, on: wt.workout_id == w.id)
    |> where([_w, wt], wt.tag_id in ^tag_ids)
  end

  defp with_order(query, nil), do: query

  defp with_order(query, order_by) do
    query
    |> order_by(^build_order_list(order_by))
  end

  defp build_order_list(order_by_map),
    do: order_by_map |> Map.from_struct() |> Enum.map(fn {k, v} -> {v, k} end)

  defp with_limit(query, nil), do: query
  defp with_limit(query, limit), do: limit(query, ^limit)

  defp with_offset(query, nil), do: query
  defp with_offset(query, offset), do: offset(query, ^offset)
end

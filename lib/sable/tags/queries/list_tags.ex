defmodule Sable.Tags.Queries.ListTags do
  @moduledoc """
  A query module for filtering Tags based on parameters.
  """

  import Ecto.Query

  alias Sable.Tags.Queries.ListTags.Params
  alias Sable.Tags.Queries.ListTags.Params.Filter
  alias Sable.Tags.Tag

  def call(%Params{limit: limit, offset: offset, filter: filter, order_by: order_by}) do
    Tag
    |> with_filter(filter)
    |> with_order(order_by)
    |> with_limit(limit)
    |> with_offset(offset)
    |> distinct(true)
  end

  defp with_filter(query, %Filter{} = filter) do
    filter
    |> Map.from_struct()
    |> Enum.reduce(query, fn
      {:search, term}, query -> with_search(query, term)
      {:user_id, user_id}, query -> with_user_id(query, user_id)
    end)
  end

  defp with_search(query, term) when is_binary(term),
    do: where(query, [q], ilike(q.title, ^"%#{term}%"))

  defp with_search(query, _), do: query

  defp with_user_id(query, nil), do: query
  defp with_user_id(query, []), do: query

  defp with_user_id(query, user_id) do
    query
    |> join(:inner, [t], w in assoc(t, :workouts))
    |> join(:inner, [_t, w], uw in assoc(w, :user_workouts))
    |> where([_t, _w, uw], uw.user_id == ^user_id)
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

defmodule SableWeb.TagComponents do
  use SableWeb, :live_component

  attr :tags, :list
  attr :class, :string, default: nil
  attr :rest, :global

  def tags_list(assigns) do
    ~H"""
    <div class="flex gap-2 flex-wrap">
      <span
        :for={tag <- @tags}
        class="px-2 py-1 rounded-lg text-white text-sm"
        style={"background-color: #{tag.color};"}
      >
        {tag.title}
      </span>
    </div>
    """
  end
end

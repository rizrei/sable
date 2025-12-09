defmodule Sable.Factories.TagFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def tag_factory do
        %Sable.Tag{
          title: sequence(:title, &"title_#{&1}"),
          color: "#" <> Faker.Color.rgb_hex()
        }
      end
    end
  end
end

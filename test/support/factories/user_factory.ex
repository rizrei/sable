defmodule Sable.Factories.UserFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %Sable.User{
          first_name: Faker.Person.first_name(),
          last_name: Faker.Person.last_name(),
          phone: ru_phone()
        }
      end

      defp ru_phone do
        "+7" <> (Stream.repeatedly(fn -> Enum.random(0..9) end) |> Enum.take(10) |> Enum.join())
      end
    end
  end
end

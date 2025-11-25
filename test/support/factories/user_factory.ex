defmodule Sable.Factories.UserFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %Sable.Accounts.User{
          email: Faker.Internet.email(),
          hashed_password: Bcrypt.hash_pwd_salt("Passw0rd")
        }
      end
    end
  end
end

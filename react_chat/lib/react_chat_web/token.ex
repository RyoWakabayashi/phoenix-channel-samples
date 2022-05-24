defmodule ReactChatWeb.Token do
  # no signer
  use Joken.Config, default_signer: nil

  add_hook(JokenJwks, strategy: ReactChatWeb.Auth0JwksStrategy)

  @impl true
  def token_config do
    domain = Application.get_env(:react_chat, ReactChatWeb.Token)[:domain]
    client_id = Application.get_env(:react_chat, ReactChatWeb.Token)[:client_id]

    default_claims()
    |> add_claim("aud", nil, &(&1 == client_id))
    |> add_claim("iss", nil, &(&1 == "https://#{domain}/"))
  end
end

defmodule ReactChatWeb.Auth0JwksStrategy do
  use JokenJwks.DefaultStrategyTemplate

  def init_opts(_) do
    domain = Application.get_env(:react_chat, ReactChatWeb.Token)[:domain]
    [jwks_url: "https://#{domain}/.well-known/jwks.json"]
  end
end

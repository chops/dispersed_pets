defmodule PocketPets.Dispersed.Auth do
  @moduledoc """
  HMAC authentication helpers for the Dispersed API.
  """

  @empty_sha256 :crypto.hash(:sha256, "") |> Base.encode16(case: :lower)

  def headers(method, path, query, body, opts \\ []) do
    public_key = Keyword.fetch!(opts, :public_key)
    secret_key = Keyword.fetch!(opts, :secret_key)
    timestamp = Keyword.get_lazy(opts, :timestamp, fn -> System.system_time(:millisecond) end)

    nonce =
      Keyword.get_lazy(opts, :nonce, fn ->
        :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
      end)

    query_string = canonical_query(query)
    body_sha = body_sha256(body)

    canonical =
      [
        public_key,
        to_string(timestamp),
        nonce,
        method |> to_string() |> String.upcase(),
        path,
        query_string,
        body_sha
      ]
      |> Enum.join("|")

    signature =
      :crypto.mac(:hmac, :sha256, secret_key, canonical)
      |> Base.encode16(case: :lower)

    [
      {"x-api-key", public_key},
      {"x-time", to_string(timestamp)},
      {"x-nonce", nonce},
      {"x-signature", signature},
      {"content-type", "application/json"},
      {"accept", "application/json"}
    ]
  end

  def canonical_body(nil), do: ""

  def canonical_body(body), do: encode_value(body)

  defp body_sha256(nil), do: @empty_sha256

  defp body_sha256(body) do
    body
    |> canonical_body()
    |> then(&:crypto.hash(:sha256, &1))
    |> Base.encode16(case: :lower)
  end

  defp canonical_query(query) when query in [%{}, [], nil], do: ""

  defp canonical_query(query) when is_map(query) do
    query
    |> Enum.flat_map(fn {key, value} ->
      value
      |> List.wrap()
      |> Enum.map(&{to_string(key), to_string(&1)})
    end)
    |> Enum.sort()
    |> Enum.map_join("&", fn {key, value} ->
      encode_query_part(key) <> "=" <> encode_query_part(value)
    end)
  end

  defp canonical_query(query) when is_list(query), do: canonical_query(Map.new(query))

  defp encode_query_part(value), do: URI.encode(value, &URI.char_unreserved?/1)

  defp encode_value(value) when is_map(value) do
    entries =
      value
      |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
      |> Enum.map_join(",", fn {key, value} ->
        Jason.encode!(to_string(key)) <> ":" <> encode_value(value)
      end)

    "{" <> entries <> "}"
  end

  defp encode_value(value) when is_list(value) do
    "[" <> Enum.map_join(value, ",", &encode_value/1) <> "]"
  end

  defp encode_value(value), do: Jason.encode!(value)
end

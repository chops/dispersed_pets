defmodule PocketPets.Dispersed.AuthTest do
  use ExUnit.Case, async: true

  alias PocketPets.Dispersed.Auth

  test "canonical body sorts nested map keys" do
    body = %{z: 1, a: %{d: 4, b: 2}, list: [%{y: true, x: false}]}

    assert Auth.canonical_body(body) ==
             ~s({"a":{"b":2,"d":4},"list":[{"x":false,"y":true}],"z":1})
  end

  test "headers include deterministic HMAC signature" do
    headers =
      Auth.headers("POST", "/v1/jobs", %{"b" => "2", "a" => "1"}, %{z: 1},
        public_key: "pk_test",
        secret_key: "sk_test",
        timestamp: 1_706_918_400_000,
        nonce: "00000000000000000000000000000000"
      )

    assert {"x-api-key", "pk_test"} in headers
    assert {"x-time", "1706918400000"} in headers
    assert {"x-nonce", "00000000000000000000000000000000"} in headers
    assert {"content-type", "application/json"} in headers

    assert {"x-signature", signature} = List.keyfind(headers, "x-signature", 0)
    assert byte_size(signature) == 64
  end
end

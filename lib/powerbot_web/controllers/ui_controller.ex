defmodule PowerbotWeb.UIController do
  use PowerbotWeb, :controller

  def index(conn, params) do
    url_with_port =
      Atom.to_string(conn.scheme) <>
        "://" <>
        conn.host <> ":" <> Integer.to_string(conn.port) <> conn.request_path

    url = Atom.to_string(conn.scheme) <> "://" <> conn.host <> conn.request_path

    # <-- This assumes it is the IndexController which maps to index_url/3
    url_phoenix_helper =
      PowerbotWeb.Router.Helpers.ui_url(conn, :index, some: "/foo")

    url_from_endpoint_config =
      Atom.to_string(conn.scheme) <>
        "://" <>
        Application.get_env(:powerbot, PowerbotWeb.Endpoint)[:url][:host] <>
        conn.request_path

    url_from_host_header =
      Atom.to_string(conn.scheme) <>
        "://" <>
        (Enum.into(conn.req_headers, %{}) |> Map.get("host")) <>
        conn.request_path

    text = ~s"""

    url_with_port :: #{url_with_port}

    url :: #{url}

    url_phoenix_helper :: #{url_phoenix_helper}

    url_from_endpoint_config :: #{url_from_endpoint_config}

    url_from_host_header :: #{url_from_host_header}
    """

    text(conn, text)

    render(conn, text)
    # render(conn, "index.html")
  end
end

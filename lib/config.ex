defmodule Config do
  @moduledoc "Config value getter"
  use ExConfig, app: :powerbot, sections: [:sparky, :p12, :roon]
end

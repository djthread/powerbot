defmodule Config do
  @moduledoc "Config value getter"
  use ExConfig,
    app: :powerbot,
    sections: [:sparky, :p12, :roon],
    data_sources: [ExConfig.ApplicationEnvironmentDataSource]
end

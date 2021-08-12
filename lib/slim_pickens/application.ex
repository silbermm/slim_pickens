defmodule SlimPickens.Application do
  @moduledoc false

  use Bakeware.Script

  @impl true
  def main(args) do
    SlimPickens.CLI.main(args)
  end
end

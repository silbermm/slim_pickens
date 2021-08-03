defmodule SlimPickens.Application do
  @moduledoc false

  use Bakeware.Script

  @impl Bakeware.Script
  def main(args) do
    _ = application()
    SlimPickens.CLI.main(args)
  end

  @impl true
  def application() do
    children = []

    opts = [strategy: :one_for_one, name: SlimPickens.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

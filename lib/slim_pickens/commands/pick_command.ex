defmodule SlimPickens.Commands.PickCommand do
  @moduledoc """
    Cherry-picks chosen commits from <from-branchname> to a new branch with a parent of <to-branchname>

    pick <from-branchname> --to <to-branchname>

      --guess, -g Make a intermediate branch by making a best guess.
                  Without this flag, you will be prompted for a branchname

      --help, -h  Print this help message
  """
  alias __MODULE__
  use Prompt.Command
  alias SlimPickens.Commands.PickFlow
  import SlimPickens.Commands.PickFlow

  @impl true
  def init(argv) do
    argv
    |> OptionParser.parse(
      strict: [help: :boolean, to: :string],
      aliases: [h: :help]
    )
    |> PickFlow.new()
  end

  @impl true
  def process(%PickFlow{help: true}), do: help()
  def process(%PickFlow{from: from, to: to} = tst) when is_nil(from) or is_nil(to), do: help()

  def process(%PickFlow{from: from, to: to, guess: guess} = cmd) do
    cmd
    |> checkout(:from)
    |> pick_commits()
    |> checkout(:to)
    |> create_branch()
    |> cherry_pick()
    |> finish()
  end
end

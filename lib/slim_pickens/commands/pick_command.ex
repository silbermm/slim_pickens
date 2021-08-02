defmodule SlimPickens.Commands.PickCommand do
  @moduledoc """
    Cherry-picks chosen commits from <from-branchname> to <to-branchname>

    slim pick <from-branchname> --to <to-branchname>

      --help, -h  Print this help message
  """
  alias __MODULE__
  use Prompt.Command

  @type t :: %PickCommand{
          help: boolean(),
          to: String.t(),
          from: String.t()
        }

  defstruct help: false, to: nil, from: nil

  @impl true
  def init(argv) do
    argv
    |> OptionParser.parse(
      strict: [help: :boolean, to: :string],
      aliases: [h: :help]
    )
    |> parse()
  end

  @impl true
  def process(%PickCommand{help: true}), do: help()
  def process(%PickCommand{from: from, to: to} = tst) when is_nil(from) or is_nil(to), do: help()

  def process(%PickCommand{from: from, to: to}) do
    :ok
  end

  @spec parse({list(), list(), list()}) :: PickCommand.t()
  defp parse({_opts, [], _}), do: %PickCommand{help: true}
  defp parse({[help: true], _, _}), do: %PickCommand{help: true}

  defp parse({opts, [from_branch | _], _}) do
    to = Keyword.get(opts, :to, nil)
    %PickCommand{help: false, to: to, from: from_branch}
  end
end

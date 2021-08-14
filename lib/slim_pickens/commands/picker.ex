defmodule SlimPickens.Commands.Picker do
  @moduledoc false

  alias __MODULE__

  @type t :: %Picker{
          help: boolean(),
          to: String.t(),
          from: String.t(),
          guess: boolean(),
          git_opts: map(),
          commits: list(String.t()),
          error: String.t(),
          error_type: atom()
        }

  defstruct help: false,
            to: nil,
            from: nil,
            guess: false,
            git_opts: %{},
            commits: [],
            error: nil,
            error_type: nil

  def new({_opts, [], _}), do: %Picker{help: true}
  def new({[help: true], _, _}), do: %Picker{help: true}

  def new({opts, [from_branch | _], _}) do
    to = Keyword.get(opts, :to, nil)
    guess = Keyword.get(opts, :guess, false)

    case SlimPickens.Git.init() do
      {:ok, opts} ->
        %Picker{help: false, to: to, from: from_branch, guess: guess, git_opts: opts}

      _err ->
        %Picker{help: true, error: "Git ins not installed on your system"}
    end
  end

  def add_error(%Picker{} = picker, type, error) do
    %Picker{picker | error: error, error_type: type}
  end

  def get_branch_name(%Picker{} = picker, :to), do: picker.to
  def get_branch_name(%Picker{} = picker, :from), do: picker.from

  def add_commits(%Picker{} = picker, commits), do: %Picker{picker | commits: commits}

  def guess_branch_name(%Picker{from: from, to: to, git_opts: git_opts}) do
    git_opts
    |> Map.get(:branch)
    |> String.replace_suffix(from, "")
    |> Kernel.<>(to)
  end
end

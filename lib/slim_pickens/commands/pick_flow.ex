defmodule SlimPickens.Commands.PickFlow do
  @moduledoc "Handles the details of the cherry-pick flow"

  alias SlimPickens.Git
  alias __MODULE__
  import Prompt

  @type t :: %PickFlow{
          help: boolean(),
          to: String.t(),
          from: String.t(),
          guess: boolean(),
          git_opts: map(),
          commits: list(String.t())
        }

  defstruct help: false, to: nil, from: nil, guess: false, git_opts: %{}, commits: []

  @type error_from :: :checkout | :pick | :create_branch | :cherry_pick | :finish
  @type ret_error :: {:error, error_from(), binary()}

  @spec new({list(), list(), list()}) :: t()
  def new({_opts, [], _}), do: %PickFlow{help: true}
  def new({[help: true], _, _}), do: %PickFlow{help: true}

  def new({opts, [from_branch | _], _}) do
    to = Keyword.get(opts, :to, nil)
    guess = Keyword.get(opts, :guess, false)

    case SlimPickens.Git.init() do
      {:ok, opts} ->
        %PickFlow{help: false, to: to, from: from_branch, guess: guess, git_opts: opts}

      err ->
        display("Git is not installed on your system", error: true)
        %PickFlow{help: true}
    end
  end

  @spec checkout(t() | ret_error(), :from | :to) :: t() | ret_error()

  def checkout(%PickFlow{git_opts: git_opts} = cmd, branch) do
    branch_name = Map.get(cmd, branch)
    display("Checking out #{branch_name}", position: :left, color: IO.ANSI.green())

    with {:ok, _, 0} <- SlimPickens.Git.checkout(branch_name, git_opts),
         {:ok, _, 0} <- SlimPickens.Git.pull(git_opts) do
      cmd
    else
      {:ok, reason, _} -> {:error, :checkout, reason}
      {:error, reason} -> {:error, :checkout, reason}
    end
  end

  def checkout(err, _branch), do: err

  @spec pick_commits(t() | ret_error()) :: t() | ret_error()
  def pick_commits(%PickFlow{git_opts: git_opts} = cmd) do
    case SlimPickens.Git.show_commits(git_opts) do
      {:ok, res, 0} ->
        res = select("Choose commits in order seperated by spaces", res, multi: true)
        res = Enum.map(res, &List.first(String.split(&1)))
        %PickFlow{cmd | commits: res}

      {:error, reason} ->
        {:error, :pick, reason}

      _ ->
        {:error, :pick, "unable to pick commits"}
    end
  end

  def pick_commits(err), do: err

  @spec create_branch(t() | ret_error()) :: t() | ret_error()
  def create_branch(%PickFlow{git_opts: git_opts, from: from, to: to, guess: true} = cmd) do
    first_branch = Map.get(git_opts, :branch)
    new_branch = String.replace_suffix(first_branch, from, "") <> to
    display("Creating branch #{new_branch}", position: :left, color: IO.ANSI.green())

    case SlimPickens.Git.create_branch(new_branch, git_opts) do
      {:ok, _, 0} -> cmd
      _ -> {:error, :create_branch, "Unable to create branch"}
    end
  end

  def create_branch(%PickFlow{git_opts: git_opts, from: from, to: to, guess: false} = cmd) do
    with branch_name <- text("Name of new branch", position: :left),
         {:ok, _, 0} <- SlimPickens.Git.create_branch(branch_name, git_opts) do
      cmd
    else
      _ -> {:error, :create_branch, "Unable to create branch"}
    end
  end

  def create_branch(err), do: err

  @spec cherry_pick(t() | ret_error()) :: t() | ret_error()
  def cherry_pick(%PickFlow{git_opts: git_opts, commits: commits} = cmd) do
    display("Cherry-picking chosen commits", position: :left, color: IO.ANSI.green())

    case SlimPickens.Git.cherry_pick(git_opts, commits) do
      :ok -> cmd
      {:error, e} -> {:error, :cherry_pick, e}
    end
  catch
    err -> {:error, :cherry_pick, err}
  end

  def cherry_pick(err), do: err

  @spec finish(t() | ret_error()) :: :ok | ret_error()
  def finish(%PickFlow{}) do
    display("All done, just push your branch and create a PR", color: IO.ANSI.green())
  end

  def finish({:error, _, reason}) do
    display("ERROR: #{inspect(reason)}", position: :left, color: IO.ANSI.red())
  end
end

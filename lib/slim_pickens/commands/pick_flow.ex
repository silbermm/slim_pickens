defmodule SlimPickens.Commands.PickFlow do
  @moduledoc "Handles the details of the cherry-pick flow"

  alias SlimPickens.Git
  alias SlimPickens.Commands.Picker
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

 
  # TODO: Cleanup Error Process

  @spec checkout(Picker.t() | ret_error(), :from | :to) :: Picker.t() | ret_error()
  def checkout(%Picker{git_opts: git_opts} = cmd, branch) do
    branch_name = Picker.get_branch_name(cmd, branch)
    display("Checking out #{branch_name}", position: :left, color: IO.ANSI.green())

    with {:ok, _, 0} <- Git.checkout(branch_name, git_opts),
         {:ok, _, 0} <- Git.pull(git_opts) do
      cmd
    else
      {:ok, reason, _} -> {:error, :checkout, reason}
      {:error, reason} -> {:error, :checkout, reason}
    end
  end

  def checkout(err, _branch), do: err

  @spec pick_commits(Picker.t() | ret_error()) :: Picker.t() | ret_error()
  def pick_commits(%Picker{git_opts: git_opts} = cmd) do
    case Git.show_commits(git_opts) do
      {:ok, res, 0} ->
        res = select("Choose commits in order seperated by spaces", res, multi: true)
        res = Enum.map(res, &List.first(String.split(&1)))
        Picker.add_commits(cmd, res)

      {:error, reason} ->
        {:error, :pick, reason}

      _ ->
        {:error, :pick, "unable to pick commits"}
    end
  end

  def pick_commits(err), do: err

  @spec create_branch(Picker.t() | ret_error()) :: Picker.t() | ret_error()
  def create_branch(%Picker{git_opts: git_opts, guess: true} = cmd) do
    new_branch = Picker.guess_branch_name(cmd)
    display("Creating branch #{new_branch}", position: :left, color: IO.ANSI.green())

    case Git.create_branch(new_branch, git_opts) do
      {:ok, _, 0} -> cmd
      _ -> {:error, :create_branch, "Unable to create branch"}
    end
  end

  def create_branch(%Picker{git_opts: git_opts, guess: false} = cmd) do
    with branch_name <- text("Name of new branch", position: :left),
         {:ok, _, 0} <- Git.create_branch(branch_name, git_opts) do
      cmd
    else
      _ -> {:error, :create_branch, "Unable to create branch"}
    end
  end

  def create_branch(err), do: err

  @spec cherry_pick(Picker.t() | ret_error()) :: Picker.t() | ret_error()
  def cherry_pick(%Picker{git_opts: git_opts, commits: commits} = cmd) do
    display("Cherry-picking chosen commits", position: :left, color: IO.ANSI.green())

    case Git.cherry_pick(commits, git_opts) do
      :ok -> cmd
      {:error, e} -> {:error, :cherry_pick, e}
    end
  catch
    err -> {:error, :cherry_pick, err}
  end

  def cherry_pick(err), do: err

  @spec finish(Picker.t() | ret_error()) :: :ok | ret_error()
  def finish(%Picker{}) do
    display("All done, just push your branch and create a PR", color: IO.ANSI.green())
  end

  def finish({:error, _, reason}) do
    display("ERROR: #{inspect(reason)}", position: :left, color: IO.ANSI.red())
  end
end

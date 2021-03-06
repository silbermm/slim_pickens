defmodule SlimPickens.Commands.PickFlow do
  @moduledoc "Handles the details of the cherry-pick flow"

  alias SlimPickens.Git
  alias SlimPickens.Commands.Picker
  import Prompt

  @spec checkout(Picker.t(), :from | :to) :: Picker.t()
  def checkout(%Picker{error: error} = cmd, _branch) when not is_nil(error), do: cmd

  def checkout(%Picker{git_opts: git_opts} = cmd, branch) do
    branch_name = Picker.get_branch_name(cmd, branch)
    display("Checking out #{branch_name}", position: :left, color: IO.ANSI.green())

    with {:ok, _, 0} <- Git.checkout(branch_name, git_opts),
         {:ok, _, 0} <- Git.pull(git_opts) do
      cmd
    else
      {:ok, reason, _} -> Picker.add_error(cmd, :checkout, reason)
      {:error, reason} -> Picker.add_error(cmd, :checkout, reason)
    end
  end

  @spec pick_commits(Picker.t()) :: Picker.t()
  def pick_commits(%Picker{error: error} = cmd) when not is_nil(error), do: cmd

  def pick_commits(%Picker{git_opts: git_opts} = cmd) do
    case Git.show_commits(git_opts) do
      {:ok, res, 0} ->
        res = select("Choose commits in order separated by spaces", res, multi: true)
        res = Enum.map(res, &List.first(String.split(&1)))
        Picker.add_commits(cmd, res)

      {:error, reason} ->
        Picker.add_error(cmd, :pick, reason)

      _ ->
        Picker.add_error(cmd, :pick, "unable to pick commits")
    end
  end

  @spec create_branch(Picker.t()) :: Picker.t()
  def create_branch(%Picker{error: error} = cmd) when not is_nil(error), do: cmd

  def create_branch(%Picker{git_opts: git_opts, guess: true} = cmd) do
    new_branch = Picker.guess_branch_name(cmd)
    display("Creating branch #{new_branch}", position: :left, color: IO.ANSI.green())

    case Git.create_branch(new_branch, git_opts) do
      {:ok, _, 0} -> cmd
      _ -> Picker.add_error(cmd, :create_branch, "Unable to create branch")
    end
  end

  def create_branch(%Picker{git_opts: git_opts, guess: false} = cmd) do
    with branch_name <- text("Name of new branch", position: :left),
         {:ok, _, 0} <- Git.create_branch(branch_name, git_opts) do
      cmd
    else
      _ -> Picker.add_error(cmd, :create_branch, "Unable to create branch")
    end
  end

  @spec cherry_pick(Picker.t()) :: Picker.t()
  def cherry_pick(%Picker{error: error} = cmd) when not is_nil(error), do: cmd

  def cherry_pick(%Picker{git_opts: git_opts, commits: commits} = cmd) do
    display("Cherry-picking chosen commits", position: :left, color: IO.ANSI.green())

    case Git.cherry_pick(commits, git_opts) do
      :ok ->
        cmd

      {:error, e} ->
        Picker.add_error(cmd, :cherry_pick, e)
    end
  catch
    err -> Picker.add_error(cmd, :cherry_pick, err)
  end

  @spec finish(Picker.t()) :: :ok
  def finish(%Picker{error: error}) when not is_nil(error) do
    display("ERROR: #{inspect(error)}", position: :left, color: IO.ANSI.red())
  end

  def finish(%Picker{}) do
    display("All done, just push your branch and create a PR", color: IO.ANSI.green())
  end
end

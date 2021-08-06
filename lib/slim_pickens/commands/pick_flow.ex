defmodule SlimPickens.Commands.PickFlow do
  @moduledoc "Handles the details of the cherry-pick flow"

  alias SlimPickens.Git
  import Prompt

  @type error_from :: :checkout | :pick | :create_branch | :cherry_pick | :finish
  @type ret_error :: {:error, error_from(), binary()}

  @spec checkout(pid(), binary()) :: pid() | ret_error()
  def checkout(pid, branch) when is_pid(pid) do
    display("Checking out #{branch}", position: :left, color: IO.ANSI.green())

    with {:ok, _, 0} <- SlimPickens.Git.checkout(pid, branch),
         {:ok, _, 0} <- SlimPickens.Git.pull(pid) do
      pid
    else
      {:ok, reason, _} -> {:error, :checkout, reason}
      {:error, reason} -> {:error, :checkout, reason}
    end
  end

  def checkout(err, _branch), do: err

  @spec pick_commits(pid() | :error) :: pid() | ret_error()
  def pick_commits(pid) when is_pid(pid) do
    case SlimPickens.Git.show_commits(pid) do
      {:ok, res, 0} ->
        res = select("Choose commits in order seperated by spaces", res, multi: true)
        res = Enum.map(res, &List.first(String.split(&1)))
        SlimPickens.Git.add_commit_hashs(pid, res)
        pid

      {:error, reason} ->
        {:error, :pick, reason}

      _ ->
        {:error, :pick, "unable to pick commits"}
    end
  end

  def pick_commits(err), do: err

  @spec create_branch(pid() | :error) :: pid() | ret_error()
  def create_branch(pid) when is_pid(pid) do
    with branch_name <- text("Name of new branch", position: :left),
         {:ok, _, 0} <- SlimPickens.Git.create_branch(pid, branch_name) do
      pid
    else
      _ -> {:error, :create_branch, "Unable to create branch"}
    end
  end

  def create_branch(err), do: err

  @spec cherry_pick(pid() | :error) :: pid() | ret_error()
  def cherry_pick(pid) when is_pid(pid) do
    display("Cherry-picking chosen commits", position: :left, color: IO.ANSI.green())

    case SlimPickens.Git.cherry_pick(pid) do
      :ok -> pid
      {:error, e} -> {:error, :cherry_pick, e}
    end
  end

  def cherry_pick(err), do: err

  @spec finish(pid() | :error) :: :ok | ret_error()
  def finish(pid) when is_pid(pid) do
    display("All done, just push your branch and create a PR", color: IO.ANSI.green())
    GenServer.stop(pid)
  end

  def finish({:error, _, reason}) do
    display("ERROR: #{reason}", position: :left, color: IO.ANSI.red())
  end
end

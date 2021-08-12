defmodule SlimPickens.Git do
  @moduledoc "A naive approach to using GIT that calls out to the system installed git"

  @spec init(Keyword.t()) :: {:ok, map()} | {:error, :nogit}
  def init(opts \\ []) do
    case check_git() do
      nil ->
        {:error, :nogit}

      {username, branch} ->
        {:ok,
         %{
           path: Keyword.get(opts, :path, File.cwd!()),
           username: Keyword.get(opts, :username, username),
           branch: branch
         }}
    end
  end

  @spec checkout(String.t(), map()) :: {:error, any()} | {:ok, String.t(), integer()}
  def checkout(branch, %{path: path}) do
    try do
      {result, exit_code} = System.cmd("git", ["checkout", branch], cd: path)
      {:ok, result, exit_code}
    rescue
      e in ArgumentError -> {:error, e}
    end
  end

  @spec pull(map()) :: {:error, any()} | {:ok, binary(), integer()}
  def pull(%{path: path}) do
    try do
      {result, exit_code} = System.cmd("git", ["pull"], cd: path)
      {:ok, result, exit_code}
    rescue
      e in ArgumentError -> {:error, e}
    end
  end

  @spec show_commits(map()) :: {:error, any()} | {:ok | :error, [String.t()], integer()}
  def show_commits(%{path: path, username: username}) do
    try do
      {result, exit_code} =
        System.cmd(
          "git",
          ["--no-pager", "log", "-6", "--skip=0", "--oneline", "--author", username],
          cd: path
        )

      if exit_code == 0 && result != "" do
        result = String.split(String.trim(result), "\n")
        {:ok, result, exit_code}
      else
        {:ok, [], exit_code}
      end
    rescue
      e in ArgumentError -> {:error, e}
    end
  end

  @spec cherry_pick([String.t()], map()) :: :ok | {:error, any()}
  def cherry_pick(commits, %{path: path}) do
    try do
      for commit <- commits do
        {result, exit_code} = System.cmd("git", ["cherry-pick", commit], cd: path)

        if exit_code > 0 do
          raise result
        end
      end

      :ok
    rescue
      e -> {:error, e}
    end
  end

  @spec create_branch(String.t(), map()) ::
          {:error, any()} | {:ok | :error, String.t(), integer()}
  def create_branch(branch_name, %{path: path}) do
    try do
      {result, exit_code} = System.cmd("git", ["checkout", "-b", branch_name], cd: path)
      {:ok, result, exit_code}
    rescue
      e in ArgumentError -> {:error, e}
    end
  end

  defp check_git() do
    case System.find_executable("git") do
      nil ->
        nil

      _ ->
        {username, _} = System.cmd("git", ["config", "--global", "--get", "user.name"])
        {branch, _} = System.cmd("git", ["branch", "--show-current"])
        {username, branch}
    end
  end
end

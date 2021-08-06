defmodule SlimPickens.Git do
  @moduledoc "A naive approach to using GIT that calls out to the system installed git"

  use GenServer

  def start_link(path) do
    GenServer.start_link(__MODULE__, path)
  end

  @impl true
  def init(path) do
    case check_git() do
      nil ->
        {:stop, :nogit}

      username ->
        {:ok, %{path: path, log_skip: 0, username: username, commits: []}}
    end
  end

  @spec checkout(pid(), String.t()) :: {:error, any()} | {:ok, String.t(), integer()}
  def checkout(pid, branch), do: GenServer.call(pid, {:checkout, branch})

  @spec pull(pid()) :: {:error, any()} | {:ok, binary(), integer()}
  def pull(pid), do: GenServer.call(pid, :pull)

  @spec show_commits(pid()) :: {:error, any()} | {:ok | :error, String.t(), integer()}
  def show_commits(pid), do: GenServer.call(pid, {:show_commits, :current})
  def show_commits(pid, :next), do: GenServer.call(pid, {:show_commits, :next})
  # TODO
  def show_commits(pid, :previous), do: GenServer.call(pid, {:show_commits, :previous})

  @spec add_commit_hashs(pid(), list(String.t())) :: :ok
  def add_commit_hashs(pid, hashs), do: GenServer.cast(pid, {:add_commit_hashs, hashs})
  def add_commit_hashs(pid, hashs), do: GenServer.cast(pid, {:add_commit_hashs, hashs})

  def cherry_pick(pid), do: GenServer.call(pid, :cherry_pick)

  @spec create_branch(pid(), String.t()) ::
          {:error, any()} | {:ok | :error, String.t(), integer()}
  def create_branch(pid, branch_name), do: GenServer.call(pid, {:create_branch, branch_name})

  defp check_git() do
    case System.find_executable("git") do
      nil ->
        nil

      _ ->
        {username, _} = System.cmd("git", ["config", "--global", "--get", "user.name"])
        username
    end
  end

  @doc ""
  def handle_cast({:add_commit_hashs, hashs}, %{path: path, commits: commits} = state) do
    hashs = commits ++ hashs
    {:noreply, %{state | commits: hashs}}
  end

  @impl true
  def handle_call({:checkout, branch}, _, %{path: path} = state) do
    try do
      {result, exit_code} = System.cmd("git", ["checkout", branch], cd: path)
      {:reply, {:ok, result, exit_code}, state}
    rescue
      e in ArgumentError -> {:reply, {:error, e}, state}
    end
  end

  @impl true
  def handle_call({:create_branch, name}, _, %{path: path} = state) do
    try do
      {result, exit_code} = System.cmd("git", ["checkout", "-b", name], cd: path)
      {:reply, {:ok, result, exit_code}, state}
    rescue
      e in ArgumentError -> {:reply, {:error, e}, state}
    end
  end

  @impl true
  def handle_call(:cherry_pick, _, %{path: path, commits: commits} = state) do
    try do
      for commit <- commits do
        {result, exit_code} = System.cmd("git", ["cherry-pick", commit], cd: path)

        if exit_code > 0 do
          raise result
        end
      end

      {:reply, :ok, 0}
    rescue
      e in ArgumentError -> {:reply, {:error, e}, state}
      e -> {:reply, {:error, e}, state}
    end
  end

  @impl true
  def handle_call(:pull, _, %{path: path} = state) do
    try do
      {result, exit_code} = System.cmd("git", ["pull"], cd: path)
      {:reply, {:ok, result, exit_code}, state}
    rescue
      e in ArgumentError -> {:reply, {:error, e}, state}
    end
  end

  @impl true
  def handle_call(
        {:show_commits, :current},
        _,
        %{path: path, username: username, log_skip: skip} = state
      ) do
    try do
      {result, exit_code} =
        System.cmd(
          "git",
          ["--no-pager", "log", "-6", "--skip=#{skip}", "--oneline", "--author", username],
          cd: path
        )

      if exit_code == 0 && result != "" do
        result = String.split(String.trim(result), "\n")
        {:reply, {:ok, result, exit_code}, state}
      else
        {:reply, {:ok, [], exit_code}, state}
      end
    rescue
      e in ArgumentError -> {:reply, {:error, e}, state}
    end
  end

  @impl true
  def handle_call(
        {:show_commits, :next},
        _,
        %{path: path, username: username, log_skip: skip} = state
      ) do
    try do
      {result, exit_code} =
        System.cmd(
          "git",
          ["--no-pager", "log", "-4", "--skip=#{4 + skip}", "--oneline", "--author", username],
          cd: path
        )

      if exit_code == 0 && result == "" do
        {:reply, {:ok, result, exit_code}, %{state | log_skip: skip - 4}}
      else
        if exit_code > 0 do
          {:reply, {:error, [], exit_code}, state}
        else
          result =
            result
            |> String.trim()
            |> String.split("\n")

          new_skip =
            case Enum.count(result) do
              4 ->
                skip + 4

              _ ->
                # TODO somehow indicate that there are no more records to see
                skip
            end

          {:reply, {:ok, result, exit_code}, %{state | log_skip: new_skip}}
        end
      end
    rescue
      e in ArgumentError -> {:reply, {:error, e}, state}
    end
  end
end

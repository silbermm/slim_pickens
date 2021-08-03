defmodule SlimPickens.CLI do
  @moduledoc """
  slim - a tool to help with cherry-picking PR strategies

    pick <branch>   specify the branch that we are cherry-picking from
    --help          print this help message
    --version       print the version
  """

  use Prompt, otp_app: :slim_pickens

  def main(argv) do
    commands = [{"pick", SlimPickens.Commands.PickCommand}]
    process(argv, commands)
  end
end

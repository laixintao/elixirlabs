defmodule ThySupervisor do
  use GenServer

  # API
  def start_link(child_spec) do
    GenServer.start_link(__MODULE__, [child_spec])
  end

  def start_child(supervisor, child_spec) do
    GenServer.call(supervisor, {:start_child, child_spec})
  end

  def init([child_spec]) do
    Process.flag(:trap_exit, true)
    state = child_spec |> start_children |> Enum.into(HashDict.new)
    {:ok, state}
  end

  # callbacks
  def handle_call({:start_child, child_spec}, _from, state) do
    case start_child(child_spec) do
      {:ok, pid} ->
        new_state = state |> HashDict.put(pid, child_spec)
        {:reply, {:ok, pid}, new_state}
      :error -> 
        {:reply, {:error, "error starting child!"}, state}
    end
  end

  # private functions
  defp start_child({mod, fun, args}) do
    case apply(mod, fun, args) do
      pid when is_pid(pid) ->
        Process.link(pid)
        {:ok, pid}
      _ ->
          :error
    end
  end
end

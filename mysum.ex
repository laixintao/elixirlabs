defmodule MySum do
    def sum([]), do: 0

    def sum([head | tail]) do
        head + sum(tail)
    end
end

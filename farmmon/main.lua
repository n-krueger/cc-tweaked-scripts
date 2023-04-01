local fun = require("fun")

local n = 100
local test = fun.sum(
    fun.map(
        function (x) return x^2 end,
        take(n, fun.tabulate(math.sin))
    )
)

print(x)

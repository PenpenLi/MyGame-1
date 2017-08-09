--
-- Author: Johnny Lee
-- Date: 2014-07-10 16:44:55
--
local pokerUI = {}

pokerUI.PokerCard           = import("game.pokerUI.pokerCard")

-- 添加点击声效
function buttontHandler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

return pokerUI

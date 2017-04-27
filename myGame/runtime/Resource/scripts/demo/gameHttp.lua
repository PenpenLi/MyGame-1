local httpModule = import('game.gameBase.httpModule')

local gameHttp = class(HttpModule)

function gameHttp:ctor(defaultURL)
	httpModule:ctor(defaultURL)
end


function gameHttp:dtor()
	httpModule:dtor()
end

function gameHttp:getDefaultURL( ... )
	HttpModule:getDefaultURL()
end

function gameHttp:setDefaultURL(url)
	HttpModule:setDefaultURL(url)
end



return gameHttp
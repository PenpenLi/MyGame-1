-- PopupAnim.lua
-- Last modification : 2016-08-10
-- Description: 弹窗动画

local PopupAnim = {}

local easing = require("libEffect.easing")
local genieShader = require("shaders.genie")
PopupAnim.pop = function(args)
	if not args.pop then
		return
	end
    local dataTime = easing.getEaseArray("easeOutBack", args.time or 500, 0, 1)
    local resTime = new(ResDoubleArray, dataTime)

    local dataBend = easing.getEaseArray("easeOutBack", args.time or 500, 0, 1)
    local resBend = new(ResDoubleArray, dataBend)

    local table = {}

    table.animTime = new(AnimIndex, kAnimNormal, 0, #dataTime - 1, args.time or 500, resTime, 0)
    table.animBend = new(AnimIndex, kAnimNormal, 0, #dataBend - 1, args.time or 500, resBend, 0)
    
    table.animTime:setDebugName("table.animTime")
    table.animBend:setDebugName("table.animBend")

    local propScale = new(PropScale, table.animTime, table.animBend, kCenterDrawing)

    args.pop:doAddProp(propScale, args.sequence or 1)
   
    -- table.animBend:setEvent(table,function ()
    --     if args.callback then
    --         args.callback()
    --     end
    --     args.pop:removeProp(args.sequence or 1)
    --     delete(propTranslate)
    --     delete(table.animTime) 
    --     delete(table.animBend) 
    --     delete(resBend)  
    --     delete(resTime)   
    -- end)
    Clock.instance():schedule_once(function(dt)
        if args.callback then
            args.callback()
        end
        args.pop:doRemoveProp(args.sequence or 1)
        delete(propTranslate)
        delete(table.animTime) 
        delete(table.animBend) 
        delete(resBend)  
        delete(resTime)   
    end, (args.time or 500)/1000)
end

return PopupAnim
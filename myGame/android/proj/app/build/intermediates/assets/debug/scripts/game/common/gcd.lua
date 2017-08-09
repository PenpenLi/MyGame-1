
local GCD = {}

local blocks = {}

function GCD.PostDelay(obj, func, userdata, delay, loop)
	if not tolua.isnull(obj) then
		local block = {}
		block.obj = obj
		block.func = func
		block.userdata = userdata
		if loop then
		    block.id = Clock.instance():schedule(function(dt)
		    	if not tolua.isnull(block.obj) then
		    		block.func(block.obj, block.userdata)
		   		else
		   			block.id:cancel()
					table.removebyvalue(blocks,block)
		    	end
		    end, delay/1000)
		else
	       block.id = Clock.instance():schedule_once(function(dt)
	       		if not tolua.isnull(block.obj) then
					block.func(block.obj, block.userdata)
       			end
				block.id:cancel()
				table.removebyvalue(blocks,block)
		    end, delay/1000)    
		end
		table.insert(blocks, block)
		return block.id
	end
end


function GCD.CancelById(obj,id)
	if obj == nil or id == nil then
		return
	end
	local index = 0
	for k, v in ipairs(blocks) do
		if v.obj == obj and v.id == id then
	        v.id:cancel()
	        index = k
			break
		end
	end
	if index~=0 then
		table.remove(blocks,index)
	end
end

function GCD.Cancel(obj,func)
	if obj == nil then
		return
	end
	local i = 1
	while i<=#blocks do
		local v = blocks[i]
		if (v.obj == obj and  func and v.func == func) or (v.obj == obj) then
			v.id:cancel()
			table.remove(blocks,i)
		else
			i = i + 1		
		end
	end
end

return GCD
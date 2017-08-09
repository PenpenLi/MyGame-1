local DemoData =  class(GameBaseData);
 -- MAX_OBJECTS: 每个节点（象限）所能包含物体的最大数量
 -- MAX_LEVELS: 四叉树的最大深度


function DemoData:ctor(controller)
	Log.printInfo("DemoData.ctor");
end

return DemoData
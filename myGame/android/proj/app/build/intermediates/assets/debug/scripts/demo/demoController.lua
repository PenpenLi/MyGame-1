--

local DemoController = class(GameBaseController);

function DemoController:ctor(state, viewClass, viewConfig, dataClass)
    Log.printInfo("DemoController.ctor");
    self.m_state = state;

end

return DemoController
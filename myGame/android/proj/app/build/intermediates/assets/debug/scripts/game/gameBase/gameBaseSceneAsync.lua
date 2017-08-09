
GameBaseSceneAsync = class(GameBaseScene, false)

local function loadBasicResource(callback, resource)
	if resource then
	    local len = #resource
	    if len == 0 then
	        callback()
	    else
	        for i = 1, len do
	            TextureCache.instance():get_async(resource[i], function() 
	                len = len - 1
	                if len == 0 then
	                    callback()
	                end
	            end)
	        end
	    end
	else
		callback()
	end
end

function loadEditorViews(callback, configs)
    if configs then
        local len = #configs 
        local completedCnt = 0
        for i = 1, len do
            local config = configs[i]
            SceneLoader.loadAsync(config, function(root)
                completedCnt = completedCnt + 1
                SceneLoader.setPreload(config, root)
                if completedCnt == len then
                    callback()
                end
            end)
        end
    else
        callback()
    end
end

function GameBaseSceneAsync:ctor(viewConfig, controller, dataClass, varConfig)
    super(self, nil, controller)
    loadBasicResource(function()
        if tolua.isnull(self) then return end
        loadEditorViews(function()
            if tolua.isnull(self) then return end
            SceneLoader.loadAsync(viewConfig, function(root)
                if tolua.isnull(self) then 
                    delete(root)
                    self.m_isLoaded = true
                    if self.m_loadedCallback then
                        self.m_loadedCallback()
                    end
                    return 
                end
                self.m_root = root
                self.m_root:addTo(self)
                self.m_controlsMap = {}
                self:addEventListeners()
                self:declareLayoutVar(varConfig)
                self:start()
                self.m_isLoaded = true
                if self.m_loadedCallback then
                    self.m_loadedCallback()
                end
            end)
        end, self.PreloadEditViews)
    end, self.PrepareLoad)
end

function GameBaseSceneAsync:start()

end
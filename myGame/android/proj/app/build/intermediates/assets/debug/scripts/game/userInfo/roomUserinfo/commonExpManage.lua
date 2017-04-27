
local CommonExpManage = {}

CommonExpManage.MAX_NUM = 12

function CommonExpManage.addCommonExp(expId)
	local commonExp = CommonExpManage.getCommonExp()

	local has = false
	for i,exp in ipairs(commonExp) do
		if exp.expId == expId then
			if not exp.count then
				exp.count = 0
			end
			exp.count = exp.count + 1
			exp.time = os.time()
			has = true
			break
		end
	end

	if not has then
		if #commonExp >= CommonExpManage.MAX_NUM then
			table.remove(commonExp,#commonExp)
		end

		local exp = {}
		exp.expId = expId
		exp.count = 1
		exp.time = os.time()
		table.insert(commonExp,exp)
	end

	CommonExpManage.saveCommonExp(commonExp)
end

function CommonExpManage.getCommonExp()
	return CommonExpManage.sortCommonExp()
end

function CommonExpManage.sortCommonExp()
	local commonExp = nk.DictModule:getString("commonExp", "commonExp", "")

	local timeSort = function(exp1, exp2)
		local sort = false
		if exp1.count > exp2.count then
			sort = true
		elseif exp1.count == exp2.count and exp1.time > exp2.time then
			sort = true
		end
		return sort
	end

	if commonExp ~= "" then
		commonExp = json.decode(commonExp)
		table.sort(commonExp, function(exp1, exp2)
	        return timeSort(exp1, exp2)
	        -- return exp1.count > exp2.count
	    end)
	else
		commonExp = {}
	end
    return commonExp
end

function CommonExpManage.saveCommonExp(commonExp)
	nk.DictModule:setString("commonExp", "commonExp",json.encode(commonExp))
    nk.DictModule:saveDict("commonExp")
end

return CommonExpManage

-- local commonExp = {
--     [1] = {expId = 1, count = 2, time = 4654654646},
--     [2] = {expId = 102, count = 6, time = 4654654646},
-- }

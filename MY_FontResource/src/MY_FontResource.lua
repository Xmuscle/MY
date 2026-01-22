--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 字体资源
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_FontResource/MY_FontResource'
local PLUGIN_NAME = 'MY_FontResource'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_FontResource'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '>=3.0.0') then
	return
end
--------------------------------------------------------------------------

local D = {}
local FONT_DIR = X.PACKET_INFO.ROOT:gsub('%./', '/') .. 'MY_FontResource/font/'
local FONT_LIST = X.LoadLUAData(FONT_DIR .. '{$lang}.jx3dat') or {}

function D.GetList()
	local aList, tExist, szLang = {}, {}, X.ENVIRONMENT.GAME_LANG
	-- 内置字体
	for _, p in ipairs(Font.GetFontPathList() or {}) do
		local szFile = p.szFile:gsub('/', '\\')
		local szKey = szFile:lower()
		if not tExist[szKey] then
			table.insert(aList, { szName = p.szName, szFile = szFile })
			tExist[szKey] = true
		end
	end
	-- 描述文件字体
	for _, p in ipairs(FONT_LIST) do
		if p.tLang[szLang] then
			local szFile = p.szFile:gsub('^%./', FONT_DIR):gsub('/', '\\')
			local szKey = szFile:lower()
			if not tExist[szKey] then
				table.insert(aList, { szName = p.szName, szFile = szFile })
				tExist[szKey] = true
			end
		end
	end
	-- 直接从font文件夹读取字体文件
	for _, szFileName in ipairs(CPath.GetFileList(FONT_DIR) or {}) do
		if szFileName:lower():match('%.ttf$') or szFileName:lower():match('%.otf$') then
			local szFile = (FONT_DIR .. szFileName):gsub('/', '\\')
			local szKey = szFile:lower()
			if not tExist[szKey] then
				local szName = szFileName:gsub('%.[^.]+$', '') -- 去掉扩展名作为显示名称
				table.insert(aList, { szName = szName, szFile = szFile })
				tExist[szKey] = true
			end
		end
	end
	-- 存在性检查
	for i, p in X.ipairs_r(aList) do
		if not IsFileExist(p.szFile) then
			table.remove(aList, i)
		end
	end
	return aList
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_FontResource',
	exports = {
		{
			fields = {
				GetList = D.GetList,
			},
		},
	},
}
MY_FontResource = X.CreateModule(settings)
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]

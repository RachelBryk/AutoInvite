-- Public domain

_addon.author  = 'RachelB';
_addon.name    = 'AutoInvite';
_addon.version = '1.0';

require 'common'

local default_config =
{
	invite_keywords = {};
	disband_keywords = {};
	whitelist = {};
};
local config = default_config;

ashita.register_event('load', function()
	config = settings:load(_addon.path .. 'settings/AutoInvite.json') or default_config;
	config = table.merge(default_config, config);
end );

ashita.register_event('unload', function()
	settings:save(_addon.path .. 'settings/AutoInvite.json', config);
end );

ashita.register_event('newchat', function(mode, chat)
	if (mode ~= 12) then
		return false;
	end

	start = chat:find("]"); -- find end of timestamp
	length = chat:find(">") - 1;

	if (start ~= nil) then
		start = start + 4; -- 4 characters from end of timestamp to start of name
	else
		start = 1; -- no timestamp
	end
	if length < start then -- no timestamp, but ] found within the tell...
		start = 1;
	end

	name = chat:sub(start, length);

	if #config.whitelist ~= 0 then
		i = 1;
		while i <= #config.whitelist do
			if (config.whitelist[i] == name) then
				n = 1;
				while n <= #config.invite_keywords do
					if chat:contains(config.invite_keywords[n]) then
						print("Sending invite to " .. config.whitelist[i]);
						AshitaCore:GetChatManager():QueueCommand("/pcmd add " .. config.whitelist[i], 1);
						break;
					end
					n = n + 1;
				end
				n = 1;
				while n <= #config.disband_keywords do
					if chat:contains(config.disband_keywords[n]) then
						print("Disbanding party.");
						AshitaCore:GetChatManager():QueueCommand("/pcmd leave", 1);
						break;
					end
					n = n + 1;
				end
			end
			i = i + 1;
		end
	end

	return false;
end );


ashita.register_event('command', function(cmd, nType)
	local args = cmd:GetArgs();
	if (args[1] ~= '/ai' and args[1] ~= '/autoinvite') then
		return false;
	end

	if (args[2] == "add") then
		if (#args ~= 4) then
			return true;
		end

		if (args[3] == "whitelist") then
			config.whitelist[#config.whitelist+1] = args [4]
			print("Added " .. args[4] .. " to invite whitelist.");
		end

		if (args[3] == "invite") then
			config.invite_keywords[#config.invite_keywords+1] = args [4]
			print("Added " .. args[4] .. " to invite keyword list.");
		end

		if (args[3] == "disband") then
			config.disband_keywords[#config.disband_keywords+1] = args [4]
			print("Added " .. args[4] .. " to disband keyword list.");
		end
	end

	return true;

end );

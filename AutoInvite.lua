-- Public domain

_addon.author  = 'RachelB';
_addon.name    = 'AutoInvite';
_addon.version = '1.1';

require 'common'

local default_config =
{
	invite_keywords = {};
	disband_keywords = {};
	leader_keywords = {};
	ally_keywords = {};
	allydisband_keywords = {};
	allyleader_keywords = {};
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
	length = chat:find(">") - 3;

	if (start ~= nil) then
		start = start + 6; -- 4 characters from end of timestamp to start of name
	else
		start = 3; -- no timestamp
	end
	if length < start then -- no timestamp, but ] found within the tell...
		start = 3;
	end

	name = chat:sub(start, length);

	for i = 1, #config.whitelist, 1 do
		if (name == config.whitelist[i]) then
			for n = 1, #config.ally_keywords, 1 do
				if (chat:contains(config.ally_keywords[n])) then
					print("Inviting " .. config.whitelist[i] .. " to alliance");
					AshitaCore:GetChatManager():QueueCommand("/acmd add " .. config.whitelist[i], 1);
					return false;
				end
			end
			for n = 1, #config.allydisband_keywords, 1 do
				if chat:contains(config.allydisband_keywords[n]) then
					print("Disbanding from alliance.");
					AshitaCore:GetChatManager():QueueCommand("/acmd leave", 1);
					return false;
				end
			end
			for n = 1, #config.allyleader_keywords, 1 do
				if (chat:contains(config.allyleader_keywords[n])) then
					print("Giving alliance leader to " .. config.whitelist[i]);
					AshitaCore:GetChatManager():QueueCommand("/acmd leader " .. config.whitelist[i], 1);
					return false;
				end
			end
			for n = 1, #config.invite_keywords, 1 do
				if (chat:contains(config.invite_keywords[n])) then
					print("Sending invite to " .. config.whitelist[i]);
					AshitaCore:GetChatManager():QueueCommand("/pcmd add " .. config.whitelist[i], 1);
					return false;
				end
			end
			for n = 1, #config.disband_keywords, 1 do
				if (chat:contains(config.disband_keywords[n])) then
					print("Disbanding party.");
					AshitaCore:GetChatManager():QueueCommand("/pcmd leave", 1);
					return false;
				end
			end
			for n = 1, #config.leader_keywords, 1 do
				if (chat:contains(config.leader_keywords[n])) then
					print("Giving leader to " .. config.whitelist[i]);
					AshitaCore:GetChatManager():QueueCommand("/pcmd leader " .. config.whitelist[i], 1);
					return false;
				end
			end
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

		if (args[3] == "leader") then
			config.leader_keywords[#config.leader_keywords+1] = args [4]
			print("Added " .. args[4] .. " to leader keyword list.");
		end

		if (args[3] == "ally") then
			config.ally_keywords[#config.ally_keywords+1] = args [4]
			print("Added " .. args[4] .. " to ally keyword list.");
		end

		if (args[3] == "disbandally") then
			config.allydisband_keywords[#config.allydisband_keywords+1] = args [4]
			print("Added " .. args[4] .. " to disband ally keyword list.");
		end

		if (args[3] == "allyleader") then
			config.allyleader_keywords[#config.allyleader_keywords+1] = args [4]
			print("Added " .. args[4] .. " to ally leader keyword list.");
		end
	end

	return true;

end );

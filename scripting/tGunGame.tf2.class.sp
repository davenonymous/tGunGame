#include <sourcemod>
#include <tf2items.defaults>
#include <sdktools>
#include <tf2_stocks>
#include <tf2_advanced>
#include <levelmod>

#pragma semicolon 1 // Force strict semicolon mode.

#define PLUGIN_VERSION		"0.1.0"
#define PLUGIN_CONTACT		"http://thrawn.de/"
#define MAXLEVELS 50

new g_iClassOnLevel[MAXLEVELS];
new g_iClass[MAXPLAYERS+1];

public Plugin:myinfo =
{
	name = "tGunGame Mod, TF2 Classes",
	author = "Thrawn",
	description = "tGunGame plugin, forces classes on specific levels",
	version = PLUGIN_VERSION,
	url = "http://thrawn.de"
}

public OnPluginStart() {
	ParseKeyValues();

	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("post_inventory_application", CallCheckInventory, EventHookMode_Post);
}

stock ParseKeyValues() {
	new Handle:kv = CreateKeyValues("GunGame");

	new String:file[256];
	BuildPath(Path_SM, file, sizeof(file), "configs/gungame.levels.txt");
	FileToKeyValues(kv, file);

	if (!KvGotoFirstSubKey(kv))
		return;

	do
	{
		decl String:sLevel[8];
		KvGetSectionName(kv, sLevel, sizeof(sLevel));
		new iLevel = StringToInt(sLevel);

		decl String:sClass[8];
		KvGetString(kv, "class", sClass, sizeof(sClass));
		new iClass = StringToInt(sClass);

		LogMessage("On Level %i, player is class %i", iLevel, iClass);
		g_iClassOnLevel[iLevel] = iClass;
	} while (KvGotoNextKey(kv));

	CloseHandle(kv);
}


public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	new TFClassType:class;
	switch(g_iClass[client]) {
		case 1:	class = TFClass_Scout;
		case 2:	class = TFClass_Soldier;
		case 3:	class = TFClass_Pyro;
		case 4:	class = TFClass_DemoMan;
		case 5: class = TFClass_Heavy;
		case 6: class = TFClass_Engineer;
		case 7: class = TFClass_Medic;
		case 8: class = TFClass_Sniper;
		case 9: class = TFClass_Spy;
		default:class = TFClass_Scout;
	}

	TF2_SetPlayerClass(client, class, true, true);
}


public lm_OnClientLevelUp(client, iLevel, iAmount, bool:isLevelDown) {
	g_iClass[client] = g_iClassOnLevel[iLevel];

	new Float:fLocation[3];
	new Float:fAngles[3];

	GetClientAbsOrigin(client, fLocation);
	GetClientAbsAngles(client, fAngles);

	TF2_RespawnPlayer(client);
	TeleportEntity(client, fLocation, fAngles, NULL_VECTOR);
}

public Action:CallCheckInventory(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(0.1, CheckInventory, client);
}

public Action:CheckInventory(Handle:timer, any:client)
{
	new iHealth = TF2_GetPlayerNormalHealth(client);
	SetEntityHealth(client, iHealth);
	SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", TF2_GetPlayerClassSpeed(client));
}

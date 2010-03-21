#include <sourcemod>
#include <tf2items.defaults>
#include <sdktools>
#include <tf2_stocks>
#include <levelmod>

#pragma semicolon 1 // Force strict semicolon mode.

#define PLUGIN_VERSION		"0.1.0"
#define PLUGIN_CONTACT		"http://thrawn.de/"
#define MAXLEVELS 50

new g_hItemOnLevel[MAXLEVELS];

public Plugin:myinfo =
{
	name = "tGunGame Mod, TF2 Weapons",
	author = "Thrawn",
	description = "tGunGame plugin, forces tf2 weapons on clients, needs TF2Items",
	version = PLUGIN_VERSION,
	url = "http://thrawn.de"
}

public OnPluginStart() {
	ParseKeyValues();

	HookEvent("post_inventory_application", CallCheckInventory, EventHookMode_Post);
}

stock ParseKeyValues() {
	new Handle:kv = CreateKeyValues("GunGame");

	new String:file[256];
	BuildPath(Path_SM, file, sizeof(file), "configs/gungame.levels.txt");
	FileToKeyValues(kv, file);

	if (!KvGotoFirstSubKey(kv))
		return;

	new maxLevel;
	do
	{
		decl String:sLevel[8];
		KvGetSectionName(kv, sLevel, sizeof(sLevel));
		new iLevel = StringToInt(sLevel);

		decl String:sClass[8];
		KvGetString(kv, "weapon", sClass, sizeof(sClass));
		new iClass = StringToInt(sClass);

		LogMessage("On Level %i, player has weapon %i", iLevel, iClass);

		g_hItemOnLevel[iLevel] = iClass;
		maxLevel = iLevel;
	} while (KvGotoNextKey(kv));

	lm_ForceLevelMax(maxLevel+1);

	CloseHandle(kv);
}

public lm_OnClientLevelUp(iClient, iLevel, iAmount, bool:isLevelDown) {
	LogMessage("Giving %N a new weapon", iClient);
	TF2_RemoveAllWeapons(iClient);
	TF2Items_GiveWeapon(iClient, g_hItemOnLevel[iLevel]);
}

public Action:CallCheckInventory(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(0.1, CheckInventory, client);
}

public Action:CheckInventory(Handle:timer, any:iClient)
{
	TF2_RemoveAllWeapons(iClient);
	new iLevel = lm_GetClientLevel(iClient);
	TF2Items_GiveWeapon(iClient, g_hItemOnLevel[iLevel]);
}

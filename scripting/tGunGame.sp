#include <sourcemod>
#include <sdktools>
#include <levelmod>
#include <colors>

#pragma semicolon 1

#define PLUGIN_VERSION "0.1.0"

new Handle:g_hCvarAnnounce;
new Handle:g_hCvarEnable;

new Handle:g_hTimerAdvertisement[MAXPLAYERS+1] = INVALID_HANDLE;
new bool:g_bAnnounce;
new bool:g_bEnabled;

public Plugin:myinfo =
{
	name = "tGunGame",
	author = "Thrawn",
	description = "tGunGame core, provides an interface for GunGame modifications, uses tLevelmod",
	version = PLUGIN_VERSION,
	url = "http://thrawn.de"
}

public OnPluginStart()
{
	g_hCvarEnable = CreateConVar("sm_gg_enabled", "1", "Enables the plugin", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarAnnounce = CreateConVar("sm_gg_announce", "1", "Announce the gungame mod to clients joining the server", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	HookConVarChange(g_hCvarEnable, Cvar_Changed);
	HookConVarChange(g_hCvarAnnounce, Cvar_Changed);

	AutoExecConfig(true, "plugin.tGunGame");
}

public OnConfigsExecuted()
{
	g_bEnabled = GetConVarBool(g_hCvarEnable);
	g_bAnnounce = GetConVarBool(g_hCvarAnnounce);

	lm_ForceExpReqBase(2);
	lm_ForceExpReqMult(1.0);
	lm_ForceLevelDefault(0);
}

public Cvar_Changed(Handle:convar, const String:oldValue[], const String:newValue[]) {
	OnConfigsExecuted();
}


public OnClientPutInServer(client)
{
	if(lm_IsEnabled() && g_bEnabled)
	{
		if(g_bAnnounce)
			g_hTimerAdvertisement[client] = CreateTimer(60.0, Timer_Advertisement, client);
	}
}

public OnClientDisconnect(client)
{
	if(lm_IsEnabled() && g_bEnabled)
	{
		if(g_hTimerAdvertisement[client]!=INVALID_HANDLE)
			CloseHandle(g_hTimerAdvertisement[client]);
	}
}

public Action:Timer_Advertisement(Handle:timer, any:client)
{
	g_hTimerAdvertisement[client] = INVALID_HANDLE;
	CPrintToChat(client, "This server is running {red}GunGame{default}.");
}


public lm_OnClientLevelUp(iClient,iLevel, iAmount, bool:isLevelDown) {

}
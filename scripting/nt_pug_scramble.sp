#include <sourcemod>
#include <sdktools>
#include <neotokyo>
	
bool DoScramble[32+1];
bool TeamJin = true;
bool Cooldown;

public Plugin myinfo =
{	
	name = "NT Scramble",
	description = "Use !scramble",
	author = "bauxite",
	version = "0.1.0",
	url = "https://github.com/bauxiteDYS/SM-NT-Scramble",
}

public OnPluginStart()
{
	RegAdminCmd("sm_scramble", Command_Scramble, ADMFLAG_GENERIC);	
}

public Action Command_Scramble(int client, int args)	
{	

	if(client <= 0)
	{
		return Plugin_Stop;
	}
	
	if (args > 0) 
	{
		PrintToChat(client, "use !scramble to randomise players in teams");
		return Plugin_Stop;
	}
	
	if (Cooldown)
	{
		ReplyToCommand(client, "Scramble is on cooldown, wait 10s");
		return Plugin_Stop;
	}
	
	int iRandomPlayer;
	int count;
	
	for (int i = 1; i <= 32; i++) 
    	{ 
		DoScramble[i] = false;
		
		if (IsClientValid(i) && GetClientTeam(i) > 1)
		{ 
			DoScramble[i] = true;
			count++;
		} 
	}
	
	for (int i = 1; i <= count; i++) 
   	 { 
		
		iRandomPlayer = GetRandomPlayer();
		
		if(iRandomPlayer > 0)
		{
			DoScramble[iRandomPlayer] = false;
			
			if(IsPlayerAlive(iRandomPlayer))
			{
				KillWithoutXpLoss(iRandomPlayer);
			}
				
			switch(TeamJin)
			{
				case true:
				{	
					FakeClientCommand(iRandomPlayer, "jointeam 2"); 
					TeamJin = false;
				}
				case false:
				{	
					FakeClientCommand(iRandomPlayer, "jointeam 3"); 
					TeamJin = true;
				}
			}
		}
    } 
	
	Cooldown = true;
	
	CreateTimer(10.0, ResetCooldown, _, TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Handled;
}		

public Action ResetCooldown(Handle timer)
{
	Cooldown = false;
	
	return Plugin_Stop;
}

stock int GetRandomPlayer() 
{ 
	int clients[32+1]; 
	int clientCount; 
	for (int i = 1; i <= 32; i++) 
	{ 
		if (IsClientValid(i) && DoScramble[i] == true)
		{ 
			clients[clientCount++] = i; 
		} 
	} 
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount)]; 
}


stock bool:IsClientValid(i)
{
	if(i > 0 && i <= MaxClients && IsClientInGame(i) && IsClientConnected(i) && ! IsClientSourceTV(i))
	{
		return true;
	}
	
	return false;
}

void KillWithoutXpLoss(int client)
{
	int xp = GetPlayerXP(client);
	FakeClientCommand(client, "kill");
	SetPlayerXP(client, xp);
}

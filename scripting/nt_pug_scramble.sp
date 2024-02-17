#include <sourcemod>
#include <sdktools>
#include <neotokyo>

bool DoScramble[32+1];
bool Cooldown;

public Plugin myinfo =
{	
	name = "NT Scramble",
	description = "Use !scramble",
	author = "bauxite",
	version = "0.1.3",
	url = "https://discord.gg/afhZuFB9A5",
}

public OnPluginStart()
{
	RegAdminCmd("sm_scramble", Command_Scramble, ADMFLAG_GENERIC);
	Cooldown = false;
}

public Action Command_Scramble(int client, int args)	
{	
	if(client == 0)
	{
		ReplyToCommand(client, "No");
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

	bool TeamJin;
	
	for (int i = 1; i <= 32; i++) 
    { 
		DoScramble[i] = false;
		
		if(IsClientInGame(i))
		{
			if (GetClientTeam(i) > 1)
			{ 
				DoScramble[i] = true;
			} 
		}
	}
	
	int RandPlayer;
		
	for (int b = 1; b <= 32; b++) 
    { 
		RandPlayer = GetRandomPlayer();
		
		DoScramble[RandPlayer] = false;
		
		if(RandPlayer > 0)
		{
			//PrintToConsoleAll("Player %d", RandPlayer);
			
			if(IsClientInGame(RandPlayer))
			{
				if(IsPlayerAlive(RandPlayer))
				{
					KillWithoutXpLoss(RandPlayer);
				}
				
				switch(TeamJin)
				{
					case true:
					{	
						FakeClientCommand(RandPlayer, "jointeam 2"); 
						TeamJin = false;
					}
					case false:
					{	
						FakeClientCommand(RandPlayer, "jointeam 3"); 
						TeamJin = true;
					}
				}	
			}
		}
    } 
	
	//PrintToConsoleAll("scrambled");
	
	Cooldown = true;
	
	CreateTimer(10.0, ResetCooldown, _, TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Handled;
}		


int GetRandomPlayer()
{
	int count;
	int List[32+1]; 
		
	for (int a = 1; a <= 32; a++) 
    { 
		if (IsClientInGame(a) && DoScramble[a])
		{ 
			List[++count] = a;
		} 
	}
	
	if(count == 0)
	{
		return 0;
	}
	
	if(count > 0)
	{
		return List[GetRandomInt(1,count)];
	}
	
	return 0;
}
	
public Action ResetCooldown(Handle timer)
{
	Cooldown = false;
	
	return Plugin_Stop;
}


void KillWithoutXpLoss(int client)
{
	int xp = GetPlayerXP(client);
	FakeClientCommand(client, "kill");
	SetPlayerXP(client, xp);
}

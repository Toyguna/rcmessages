#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "0.00"

public Plugin myinfo = 
{
	name = "Random Chat Messages",
	author = "Toyguna",
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

//	Global Variables  //
char configdir[PLATFORM_MAX_PATH] = "addons/sourcemod/configs/randomchatmsg";
char msgsdir[PLATFORM_MAX_PATH] = "addons/sourcemod/configs/randomchatmsg/messages.txt";
char cfgdir[PLATFORM_MAX_PATH] = "addons/sourcemod/configs/randomchatmsg/config.cfg";

ConVar g_cvPrefix;
ConVar g_cvPrefixColor;
ConVar g_cvMsgInterval;

ArrayList messages;

Handle msg_timer;

public void OnPluginStart() {
	CreateDirectory(configdir, 3);

	g_cvPrefix = CreateConVar("rcmsg_prefix", "[default]", "Set the prefix of random chat messages.");
	g_cvPrefixColor = CreateConVar("rcmsg_prefixcolor", "FFFFFF", "Set the color of the prefix.");
	g_cvMsgInterval = CreateConVar("rcmsg_interval", "300.0", "Set the interval of random messages", _, true, 5.0);
	
	PrintToServer(cfgdir);
	PrintToServer(msgsdir);
	
	RegAdminCmd("sm_rcmsg_update_msgs", Command_UpdateMessages, ADMFLAG_GENERIC, "Usage: !rcmsg_update_msgs");
	RegAdminCmd("sm_rcmsg_update_interval", Command_UpdateInterval, ADMFLAG_GENERIC, "Usage: !rcmsg_update_interval");
	RegAdminCmd("sm_rcmsg_update_cfg", Command_UpdateCfg, ADMFLAG_GENERIC, "Usage: !rcmsg_update_cfg");
	
	LoadTranslations("custom_rules.phrases");
	
	ReadConfig();
	UpdateMessages();
	RestartTimer();
}

public void OnMapStart() {
	ReadConfig();
	UpdateMessages();
	RestartTimer();
}

public void RestartTimer() {
	if (msg_timer != null) {
		KillTimer(msg_timer, false);
	}

	char buffer[32];
	g_cvMsgInterval.GetString(buffer, sizeof(buffer));
	float interval = StringToFloat(buffer);

	msg_timer = CreateTimer(interval, SendMessage, _, TIMER_REPEAT);
	
	PrintToServer("[RandomChatMessages] %T", "UpdateInterval", LANG_SERVER);
}


// commands

public Action Command_UpdateMessages(int client, int args) {
	UpdateMessages();
	
	return Plugin_Handled;
}

public Action Command_UpdateInterval(int client, int args) {
	RestartTimer();
	
	return Plugin_Handled;
}

public Action Command_UpdateCfg(int client, int args) {
	ReadConfig();
	
	return Plugin_Handled;
}


public Action SendMessage(Handle timer) {
	if (messages == null) return;
	
	int len = messages.Length;
	
	if (len < 1) return;


	int msgidx = GetRandomInt(0, len - 1);

	char buffer[200];
	messages.GetString(msgidx, buffer, sizeof(buffer));
	
	char prefix[64];
	g_cvPrefix.GetString(prefix, sizeof(prefix));
	
	char prefixcolor[64];
	g_cvPrefixColor.GetString(prefixcolor, sizeof(prefixcolor));
	
	char msg[300]; // msg (200) + prefix (64) + color (36)
	Format(msg, sizeof(msg), "\x07%s%s \x01%s", prefixcolor, prefix, buffer);
	
	PrintToChatAll(msg);
}

public void UpdateMessages() {
	Handle file = OpenFile(msgsdir, "r");
	
	
	if (file == INVALID_HANDLE) {
		PrintToServer("[RandomChatMessages] %T", "ErrorLoadMsgsFail", LANG_SERVER);
		return;
	}
	
	char linedata[200];
	
	ArrayList list = new ArrayList(ByteCountToCells(sizeof(linedata)));
	
	while (!IsEndOfFile(file) && ReadFileLine(file, linedata, sizeof(linedata))) {
		if (StrEqual(linedata[1], "//")) {
			continue;
		}
		
		linedata[(strlen(linedata)-1)] = '\0'; 
		
		list.PushString(linedata);

	}
	
	file.Close();
	
	PrintToServer("[RandomChatMessages] %T", "UpdateMessages", LANG_SERVER);
	
	messages = list.Clone();
	delete list;
}

public void ReadConfig() {
	KeyValues kv = new KeyValues("Config");
	kv.ImportFromFile(cfgdir);	

	char buffer[256];
	
	kv.GetString("rcmsg_prefix", buffer, sizeof(buffer), "[default]");
	g_cvPrefix.SetString(buffer);
		
	kv.GetString("rcmsg_prefixcolor", buffer, sizeof(buffer), "FFFFFF");
	g_cvPrefixColor.SetString(buffer);
	
	g_cvMsgInterval.FloatValue = kv.GetFloat("rcmsg_interval", 5.0);
	
	delete kv;
	
	PrintToServer("[RandomChatMessages] %T", "UpdateConfig", LANG_SERVER);
}
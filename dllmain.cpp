#define _CRT_SECURE_NO_WARNINGS

#include <string>
#include <array>
#include <stdio.h>
#include <stdlib.h>
#include <sstream>
#include <locale>
#include <codecvt>
#include <iomanip>
#include <iostream>
#include <fstream>
#include <functional>
#include <vector>

#include "easyhook.h"
#include "lua.hpp"

#define LUA_LIB EXTERN_C int
#undef main



enum Star_PlayerMode {
	Casual,
	Survival,
	Hardcore
};



enum Star_ChatSendMode {
	World,
	Local
};

static uintptr_t base = (uintptr_t)GetModuleHandle(0);

namespace Star	 {
	enum TileLayer {
		Foreground,
		Background
	};
	namespace Assets {
		const DWORD64 ASSETS = 0xE8AE0;
		const DWORD64 ASSETEXISTS = 0xECF10;
		const DWORD64 IMAGE = 0xF1B80;

		typedef std::shared_ptr<void>* (__fastcall* imageTemp)(void* as, std::shared_ptr<void>*, void* path);
		auto image = (Star::Assets::imageTemp)(base + Star::Assets::IMAGE);
	}
	namespace ChatProcessor {
		const DWORD64 CHATPROCESSOR = 0x57C0D0;
		const DWORD64 RENICK = 0x19FDF0;

		typedef void* (__fastcall* renick)(void* cp, void* result, unsigned __int16 clientId, void* nick); //void*(Star::ChatProcessor *this, Star::String *result, unsigned __int16 clientId, Star::String *nick)
	}
	namespace Chat {
		const DWORD64 CHAT = 0x88D210;
		const DWORD64 CURRENTCHAT = 0x88FB80;
		const DWORD64 HASFOCUS = 0x8907C0;

		typedef void* (__fastcall* currentChatTemp)(void* c, std::string* result);

		auto currentChat = (Star::Chat::currentChatTemp)(base + Star::Chat::CURRENTCHAT);
	}
	namespace ClientDisconnectRequestPacket {
		const DWORD64 MAKESHARED = 0x2F3AB0;

		typedef std::shared_ptr<void>(__fastcall* make_sharedTemp)(std::shared_ptr<void>* result);
		auto make_shared = (Star::ClientDisconnectRequestPacket::make_sharedTemp)(base + Star::ClientDisconnectRequestPacket::MAKESHARED);
	}
	namespace Image {
		const DWORD64 GET = 0x6A6B0;

		typedef std::array<char,4>* (__fastcall* getTemp)(void* im, std::array<unsigned char,4>* result, std::array<unsigned int,2>* pos);
		auto get = (Star::Image::getTemp)(base + Star::Image::GET);
	}
	namespace Maybe {
		namespace String {
			const DWORD64 TAKE = 0x95460;
			typedef void*(__fastcall* take)(void* s, void* result);
		}
	}
	namespace String {
		const DWORD64 STRING = 0xC1370; //void(Star::String *this, std::basic_string<char,std::char_traits<char>,std::allocator<char> > *s)
		const DWORD64 UTF8PTR = 0xCC000;
		const DWORD64 LENGTH = 0xCAB90;

		typedef const char*(__fastcall* utf8PtrTemp)(void* s);
		typedef unsigned __int64(__fastcall* lengthTemp)(void* s);

		auto utf8Ptr = (Star::String::utf8PtrTemp)(base + Star::String::UTF8PTR);
		auto length = (Star::String::lengthTemp)(base + Star::String::LENGTH);

	}
	enum HumanoidEmote {
		Idle,
		Walk,
		Run,
		Jump,
		Fall,
		Swim,
		SwimIdle,
		Duck,
		Sit,
		Lay
	};
	namespace Humanoid {
		const DWORD64 SETMOVINGBACKWARDS = 0x244690;
		const DWORD64 SETEMOTESTATE = 0x2443B0;

		typedef void (__fastcall* setMovingBackwardsTemp)(void* h, bool movingBackwards);
		typedef void(__fastcall* setEmoteStateTemp)(void* h, Star::HumanoidEmote state);

		auto setMovingBackwards = (Star::Humanoid::setMovingBackwardsTemp)(base + Star::Humanoid::SETMOVINGBACKWARDS);
		auto setEmoteState = (Star::Humanoid::setEmoteStateTemp)(base + Star::Humanoid::SETEMOTESTATE);
	}
	namespace HumanoidIdentity {
		const DWORD64 TOJSON = 0x244A60;

		typedef void*(__fastcall* toJsonTemp)(void* hi, void* result);
		auto toJson = (Star::HumanoidIdentity::toJsonTemp)(base + Star::HumanoidIdentity::TOJSON);
	}
	namespace Player {
		const DWORD64 RECEIVEMESSAGE = 0x3C6290;
		const DWORD64 SETSPECIES = 0x3C9000;
		const DWORD64 CURRENCY = 0x3BB1B0;
		const DWORD64 KILL = 0x3C1CE0;
		const DWORD64 SETGENDER = 0x3C8690;
		const DWORD64 SETNAME = 0x3C8A30;
		const DWORD64 SETPERSONALITY = 0x3C8F40;
		const DWORD64 ADDCHATMESSAGE = 0x3B92E0;
		const DWORD64 DISKSTORE = 0x3BB8A0;
		const DWORD64 DRAWABLES = 0x3BC160;
		const DWORD64 SETBODYDIRECTIVES = 0x3C8280;
		const DWORD64 SETEMOTEDIRECTIVES = 0x3C8490;
		const DWORD64 SETHAIRDIRECTIVES = 0x3C8750;
		const DWORD64 SETFACIALHAIR = 0x3C84D0;
		const DWORD64 SETFACIALMASK = 0x3C8540;
		const DWORD64 SETHAIRTYPE = 0x3C8790;
		const DWORD64 SONGBOOK = 0x3C9270;
		const DWORD64 NAME = 0x3C2B40;
		const DWORD64 LOUNGE = 0x3C21B0;
		const DWORD64 UUID = 0x3CD250;
		const DWORD64 AIMPOSITION = 0x3CD250;
		const DWORD64 FORCENUDE = 0x3BEA80;
		const DWORD64 SETNETSTATES = 0x3C8A70;
		const DWORD64 INVENTORY = 0x3C19D0;

		typedef void(__fastcall* setSpeciesTemp)(void* p, std::string *species);
		typedef void(__fastcall* killTemp)(void* p);
		typedef void(__fastcall* setGenderTemp)(void* p,bool* gender);
		typedef void(__fastcall* setNameTemp)(void* p, std::string* name);
		typedef void(__fastcall* addChatMessageTemp)(void* p, std::string* message);
		typedef void(__fastcall* setPersonalityTemp)(void* p, void* personality);
		typedef void*(__fastcall* diskStoreTemp)(void* p, void* result);
		typedef void*(__fastcall* drawablesTemp)(void* p, void* result);
		typedef void(__fastcall* setBodyDirectivesTemp)(void* p, std::string* directives);
		typedef void(__fastcall* setEmoteDirectivesTemp)(void* p, std::string* directives);
		typedef void(__fastcall* setHairDirectivesTemp)(void* p, std::string* directives);
		typedef void(__fastcall* setFacialHairTemp)(void* p, std::string* group, std::string* type, std::string* directives);
		typedef void(__fastcall* setFacialMaskTemp)(void* p, std::string* group, std::string* type, std::string* directives);
		typedef void(__fastcall* setHairTypeTemp)(void* p, std::string* group, std::string* type);
		typedef std::shared_ptr<void>*(__fastcall* songbookTemp)(void* p, std::shared_ptr<void>* result);
		typedef void*(__fastcall* nameTemp)(void* p);
		typedef bool(__fastcall* loungeTemp)(void* p, int loungeableEntityId, unsigned __int64 anchorIndex);
		typedef std::array<char, 16>(__fastcall* uuid)(void* p, void* result);
		typedef std::array<float,2>*(__fastcall* aimPositionTemp)(void* p, std::array<float,2>* result);
		typedef void(__fastcall* forceNudeTemp)(void* p);

		auto setGender = (Star::Player::setGenderTemp)(base + Star::Player::SETGENDER);
		auto setName = (Star::Player::setNameTemp)(base + Star::Player::SETNAME);
		auto setSpecies = (Star::Player::setSpeciesTemp)(base + Star::Player::SETSPECIES);
		auto setBodyDirectives = (Star::Player::setBodyDirectivesTemp)(base + Star::Player::SETBODYDIRECTIVES);
		auto setEmoteDirectives = (Star::Player::setEmoteDirectivesTemp)(base + Star::Player::SETEMOTEDIRECTIVES);
		auto setHairDirectives = (Star::Player::setHairDirectivesTemp)(base + Star::Player::SETHAIRDIRECTIVES);
		auto setFacialHair = (Star::Player::setFacialHairTemp)(base + Star::Player::SETFACIALHAIR);
		auto setFacialMask = (Star::Player::setFacialMaskTemp)(base + Star::Player::SETFACIALMASK);
		auto setHairType = (Star::Player::setHairTypeTemp)(base + Star::Player::SETHAIRTYPE);
		auto setPersonality = (Star::Player::setPersonalityTemp)(base + Star::Player::SETPERSONALITY);
		auto diskStore = (Star::Player::diskStoreTemp)(base + Star::Player::DISKSTORE);
		auto kill = (Star::Player::killTemp)(base + Star::Player::KILL);
		auto songbook = (Star::Player::songbookTemp)(base + Star::Player::SONGBOOK);
		auto drawables = (Star::Player::drawablesTemp)(base + Star::Player::DRAWABLES);
		auto name = (Star::Player::nameTemp)(base + Star::Player::NAME);
		auto lounge = (Star::Player::loungeTemp)(base + Star::Player::LOUNGE);
		auto aimPosition = (Star::Player::aimPositionTemp)(base + Star::Player::AIMPOSITION);
		auto forceNude = (Star::Player::forceNudeTemp)(base + Star::Player::FORCENUDE);
		auto addChatMessage = (Star::Player::addChatMessageTemp)(base + Star::Player::ADDCHATMESSAGE);
	}
	namespace PlayerInventory {
		DWORD64 PLAYERINVENTORY = 0x3E6210;
		DWORD64 MAKESHARED = 0x3AF6D0;
		DWORD64 LOAD = 0x3F1F50;
		DWORD64 STORE = 0x3F68A0;
		DWORD64 NETELEMENTSNEEDSTORE = 0x3F3610;
		DWORD64 ITEMSCANFIT = 0x3F0F30;

		typedef std::shared_ptr<void>*(__fastcall* make_sharedTemp)(std::shared_ptr<void>* result);
		typedef void(__fastcall* loadTemp)(void* pi, void* store);
		typedef void(__fastcall* storeTemp)(void* pi, void* result);

		auto make_shared = (Star::PlayerInventory::make_sharedTemp)(base + Star::PlayerInventory::MAKESHARED);
		auto load = (Star::PlayerInventory::loadTemp)(base + Star::PlayerInventory::LOAD);
		auto store = (Star::PlayerInventory::storeTemp)(base + Star::PlayerInventory::STORE);
	}
	namespace InventoryPane {
		DWORD64 UPDATE = 0x8D56F0;

		typedef void(__fastcall* updateTemp)(void* ip);
		auto update = (Star::InventoryPane::updateTemp)(base + Star::InventoryPane::UPDATE);
	}
	namespace Monster{
		const DWORD64 DESTROY = 0x2B9B40;

		typedef void (__fastcall* destroy)(void* m, void* renderCallback);
	}
	namespace SongBook {
		const DWORD64 PLAY = 0x49D0D0;

		typedef void(__fastcall* playTemp)(void* sb, void* song, void* timeSource);
		auto play = (Star::SongBook::playTemp)(base + Star::SongBook::PLAY);
	}
	enum LogLevel {
		Debug,
		Info,
		Warn,
		Error
	};
	namespace Logger {
		const DWORD64 LOG = 0x9CBA0;
		const DWORD64 LOGF = 0x156E0;

		typedef void(__fastcall* logTemp)(Star::LogLevel level, const char* msg);

		auto log = (Star::Logger::logTemp)(base + Star::Logger::LOG);
	}
	namespace WorldClient {
		const DWORD64 WORLDCLIENT = 0x5DDDA0;
		const DWORD64 OVERRIDEGRAVITY = 0x5F4780;
		const DWORD64 REMOVEENTITY = 0x5F6BB0;
		const DWORD64 CLEARWORLD = 0x5E9F10;
		const DWORD64 TRYGIVEMAINPLAYERITEM = 0x5FBB50;
		const DWORD64 MATERIAL = 0x5F3C90;
		const DWORD64 UPDATE = 0x5FBD80;

		typedef void(__fastcall* overrideGravity)(void* wc, float gravity);
		typedef void(__fastcall* removeEntityTemp)(void* wc, int entityId, bool andDie);
		typedef void(__fastcall* clearWorld)(void* wc);
		typedef unsigned __int64(__fastcall* materialTemp)(void* wc, std::array<int, 2> * pos, Star::TileLayer layer);

		auto removeEntity = (Star::WorldClient::removeEntityTemp)(base + Star::WorldClient::REMOVEENTITY);
		auto material = (Star::WorldClient::materialTemp)(base + Star::WorldClient::MATERIAL);
	}
	namespace WorldServer {
		const DWORD64 WORLDSERVER = 0x64FC30;
		const DWORD64 REMOVEENTITY = 0x66E750;
		const DWORD64 THREATLEVEL = 0x673A40;

		typedef void(__fastcall* removeEntity)(void* ws, int entityId, bool andDie);
		typedef float(__fastcall* threatLevel)(void* ws);
	}
	namespace TeamClient {
		const DWORD64 TEAMCLIENT = 0x51F9A0;
		const DWORD64 ACCEPTINVITATION = 0x520FD0;
		const DWORD64 INVOKEREMOTE = 0x521DD0;
		const DWORD64 ISTEAMLEADER = 0x521F50;
		const DWORD64 STATUSUPDATE = 0x522B00;
		const DWORD64 INVITEPLAYER = 0x5219F0;

		typedef void(__fastcall* acceptInvitationTemp)(void* rc, void* inviterUuid);
		typedef void(__fastcall* invokeRemoteTemp)(void* tc, std::string* method, void* args, std::function<void __cdecl(void* const&)> responseFunction);
		typedef void(__fastcall* invitePlayerTemp)(void* tc, void* playerName);

		auto invokeRemote = (Star::TeamClient::invokeRemoteTemp)(base + Star::TeamClient::INVOKEREMOTE);
		auto acceptInvitation = (Star::TeamClient::acceptInvitationTemp)(base + Star::TeamClient::ACCEPTINVITATION);
		auto invitePlayer = (Star::TeamClient::invitePlayerTemp)(base + Star::TeamClient::INVITEPLAYER);
	}
	namespace TeamBar {
		const DWORD64 TEAMBAR = 0x917D70;
		const DWORD64 ACCEPTINVITATION = 0x919530;
		const DWORD64 INVITEPLAYER = 0x91ACE0;

		typedef void(__fastcall* acceptInvitationTemp)(void* tc, void* inviterUuid);
		typedef void(__fastcall* invitePlayerTemp)(void* tc, void* playerName);

		auto invitePlayer = (Star::TeamBar::invitePlayerTemp)(base + Star::TeamBar::INVITEPLAYER);
	}
	namespace Uuid {
		const DWORD64 UUID = 0xD05C0; // Star::Uuid::Uuid(Star::Uuid *this, Star::String *hex)
		const DWORD64 HEX = 0xD0860;

		typedef void* (__fastcall* uuidTemp)(void* u, std::string* hex); // Star::Uuid::Uuid(Star::Uuid *this, Star::String *hex)
		typedef void* (__fastcall* hexTemp)(void* u, void* result);

		auto uuid = (Star::Uuid::uuidTemp)(base + Star::Uuid::UUID);
		auto hex = (Star::Uuid::hexTemp)(base + Star::Uuid::HEX);
	}
	namespace Json {
		const DWORD64 PRINTJSON = 0x7F0C0;
		const DWORD64 SIZE = 0x81E30;
		const DWORD64 PARSEJSON = 0x7EAE0;
		const DWORD64 GETFROMKEY = 0x7C0A0; //Star::Json * Star::Json::get(Star::Json *this, Star::Json *result, Star::String *key)
		const DWORD64 TYPENAME = 0x82640;
		const DWORD64 SETKEY = 0x81890; //Star::Json * Star::Json::set(Star::Json *this, Star::Json *result, Star::String key, Star::Json value)
		const DWORD64 JSONFROMSTRING = 0x77820; // Star::Json::Json(Star::Json *this, Star::String s)

		typedef std::string* (__fastcall* printJsonTemp)(void* j, std::string* result, int pretty, bool sort);
		typedef unsigned __int64(__fastcall* size)(void* j);
		typedef void* (__fastcall* parseJsonTemp)(void* result, std::string* json);
		typedef void* (__fastcall* getFromKey)(void* j, void* result, void* key);
		typedef void(__fastcall* typeNameTemp)(void* j, void* result);
		typedef void*(__fastcall* setKeyTemp)(void* j, void* result, std::string* key, void* value);
		typedef void(__fastcall* JsonFromStringTemp)(void* j, std::string* s);

		auto parseJson = (Star::Json::parseJsonTemp)(base + Star::Json::PARSEJSON);
		auto printJson = (Star::Json::printJsonTemp)(base + Star::Json::PRINTJSON);
		auto typeName = (Star::Json::typeNameTemp)(base + Star::Json::TYPENAME);
		auto setKey = (Star::Json::setKeyTemp)(base + Star::Json::SETKEY);
		auto JsonFromString = (Star::Json::JsonFromStringTemp)(base + Star::Json::JSONFROMSTRING);

	}
	namespace EntityMap {
		const DWORD64 ENTITYMAP = 0x21AC70;
		const DWORD64 REMOVEENTITY = 0x222660;
		const DWORD64 ENTITY = 0x220220;
		const DWORD64 GETPLAYER = 0x5D7D50;
		const DWORD64 ENTITYQUERY = 0x220280;

		typedef std::shared_ptr<void>*(__fastcall* removeEntityTemp)(void* em, std::shared_ptr<void>* result, int entityId);
		typedef std::shared_ptr<void>*(__fastcall* entityTemp)(void* em, std::shared_ptr<void>* result, int entityId);
		typedef std::shared_ptr<void>*(__fastcall* getPlayerTemp)(void* em, std::shared_ptr<void>* result, int entityId);

		auto removeEntity = (Star::EntityMap::removeEntityTemp)(base + Star::EntityMap::REMOVEENTITY);
		auto entity = (Star::EntityMap::entityTemp)(base + Star::EntityMap::ENTITY);
		auto getPlayer = (Star::EntityMap::getPlayerTemp)(base + Star::EntityMap::GETPLAYER);
	}
	namespace Entity {
		const DWORD64 UNIQUEID = 0x6A2390;
		const DWORD64 ISMASTER = 0x6A2210;

		typedef void*(__fastcall* uniqueIdTemp)(void* e, void* result);

		auto uniqueId = (Star::Entity::uniqueIdTemp)(base + Star::Entity::UNIQUEID);
	}
	namespace MovementController {
		const DWORD64 UPDATEFORCEREGIONS = 0x2EBB40;
	}
	namespace Lua {
		const DWORD64 LUA_NEWSTATE = 0x42180;
		const DWORD64 S_INIT = 0x427B0;
		const DWORD64 GETTOP = 0x28C10;

	}
	namespace TechController {
		const DWORD64 PARENTDIRECTIVES = 0x535340;

		typedef void* (__fastcall* parentDirectives)(void* tc, void* result);
	}
	namespace StatusController {
		const DWORD64 PARENTDIRECTIVES = 0x4E3900;
		const DWORD64 NETSTORE = 0x4E3550;

		typedef void* (__fastcall* parentDirectives)(void* tc, void* result);
	}
	namespace MainInterface {
		const DWORD64 MAININTERFACE = 0x8E7210;
		const DWORD64 DOCHAT = 0x8ECF20;

		typedef void(__fastcall* doChat)(void* mi, void* chat, bool addToHistory);
	}
	namespace UniverseClient {
		const DWORD64 UNIVERSECLIENT = 0x5626D0;
		const DWORD64 SENDCHAT = 0x565DB0;
		const DWORD64 SETMAINPLAYER = 0x565F00;

		typedef void(__fastcall* sendChatTemp)(void* uc, std::string* text, Star_ChatSendMode sendMode);
		typedef void(__fastcall* setMainplayerTemp)(void* uc, std::shared_ptr<void> player);

		auto sendChat = (Star::UniverseClient::sendChatTemp)(base + Star::UniverseClient::SENDCHAT);
		auto setMainPlayer = (Star::UniverseClient::setMainplayerTemp)(base + Star::UniverseClient::SETMAINPLAYER);
	}
	namespace UniverseConnection {
		const DWORD64 UNIVERSECONNECTION = 0x568610;
		const DWORD64 ISOPEN = 0x56A320;
		const DWORD64 PUSHSINGLE = 0x56AA50;

		typedef void (__fastcall* pushSingleTemp)(void* ucn, std::shared_ptr<void> packet);
		auto pushSingle = (Star::UniverseConnection::pushSingleTemp)(base + Star::UniverseConnection::PUSHSINGLE);
	}
	namespace InterfaceCursor {
		const DWORD64 DRAWABLE = 0x8D8000;
	}
	namespace Drawable {
		const DWORD64 SCALE = 0x1DD9E0;
		typedef void(__fastcall* scale)(void* d, float scaling, std::array<float,2>* scaleCenter);
	}
	namespace SayChatAction {
		const DWORD64 SAYCHATACTION = 0x199F60;
	}
	namespace PcP2PNetworkingService {
		const DWORD64 SETACTIVITYDATA = 0x7F7C50;
	}
	namespace NetworkedAnimator {
		const DWORD64 NETWORKEDANIMATOR = 0x30F220;

		typedef void (__fastcall* NetworkedAnimatorTemp)(void* na, void* config, void* relativePath);

		auto NetworkedAnimator = (Star::NetworkedAnimator::NetworkedAnimatorTemp)(base + Star::NetworkedAnimator::NETWORKEDANIMATOR);
	}
	const DWORD64 UTF16TOSTRING = 0xD5C00;
	typedef void*(__fastcall* utf16ToStringTemp)(void* result, const wchar_t* s);
	auto utf16ToString = (Star::utf16ToStringTemp)(base + Star::UTF16TOSTRING);

	const DWORD64 PARSEPERSONALITY = 0x23F430;
	typedef void* (__fastcall* parsePersonalityTemp)(void* result, void* config);
	auto parsePersonality = (Star::parsePersonalityTemp)(base + Star::PARSEPERSONALITY);

	const DWORD64 ENTITYASMONSTER = 0x212430;
	typedef std::shared_ptr<void>* (__fastcall* entityAsMonster)(void* result, void* p);
}

namespace discord {
	namespace PartySize {
		const DWORD64 SETMAXSIZE = 0x80E820;
	}
}

using namespace discord;


void* mainPlayerPointer;
void* worldClientPointer;
void* worldServerPointer;
void* chatProcessorPointer;
void* teamClientPointer;
void* entityMapPointer;
void* mainInterfacePointer;
void* universeClientPointer;
void* teamBarPointer;
void* chatPointer;
void* assetsPointer;
void* mainPlayerInventoryPointer;
void* universeConnectionPointer;
void* inventoryPanePointer;


int numMessages = 0; // limit the number of messages printed per tick
bool alwaysMaster = false; // if true, Entity::isMaster will always return true
std::string customPortrait = ""; // if not "", team portrait will be set to this drawable list
std::string customChatMessage = "";
bool chatFocused = false;
bool canPickupItems = true;
bool inventoryNetworked = true;


template<typename T> class Hook {
public:
	Hook() {}
	template<typename T1> Hook(T1 _base, T _hook) {
		Base = (T)_base;
		hook = (T)_hook;
		LhInstallHook(Base, hook, NULL, &hti);
	}
	template<typename T1, typename T2> Hook(T1 _lib, T2 _base, T _hook) {
		Base = (T)GetProcAddress(GetModuleHandle(_lib), _base);
		hook = (T)_hook;
		LhInstallHook(Base, hook, NULL, &hti);
	}

	bool GetEnabled() {
		return enabled;
	}
	void SetEnabled(bool _enabled) {
		if (enabled != _enabled) {
			enabled = _enabled;
			if (enabled)
				LhSetExclusiveACL(acl, NULL, &hti);
			else
				LhSetInclusiveACL(acl, NULL, &hti);
		}
	}

	void Uninstall() {
		LhUninstallHook(&hti);
	}

	T Base;

private:
	bool enabled = false;
	T hook = NULL;
	unsigned long acl[1] = {};
	HOOK_TRACE_INFO hti = { NULL };
};

// this is complex but common, returns a pointer to a Star::String from an std::string
void* makeStarString(std::string inpStr) {
	std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
	std::wstring wideString = converter.from_bytes(inpStr);
	const wchar_t* szString = wideString.c_str();

	void* newStringPtr;
	newStringPtr = malloc((wideString.length() + 5) * 10 * sizeof(wchar_t));

	Star::utf16ToString(newStringPtr, szString);

	return newStringPtr;
}



void dummyResponse(void* const &) { // invokeRemote expects a response function

}
LUA_LIB acceptInvitation(lua_State* L) {

	std::string selfUuid = lua_tostring(L, 1);
	std::string targetUuid = lua_tostring(L, 2);
	
	std::string methodName = "team.acceptInvitation";

	std::string argsJsonStr = "{\"inviterUuid\":\"" + selfUuid + "\",\"inviteeUuid\":\"" + targetUuid +"\"}";
	void* argsJson = malloc(2 * 1024); //2 kb is already way overkill

	Star::Json::parseJson(argsJson, &argsJsonStr);

	std::function<void __cdecl(void* const&)> responseFunction = dummyResponse;

	Star::TeamClient::invokeRemote(teamClientPointer, &methodName, argsJson, responseFunction);

	free(argsJson);

	return 0;
}

LUA_LIB removeEntity(lua_State* L) {
	int inp = (int)lua_tonumber(L, 1);
	
	//alwaysMaster = true;

	std::shared_ptr<void> resultPtr;
	Star::EntityMap::removeEntity(entityMapPointer, &resultPtr, inp);
	//Star::WorldClient::removeEntity(worldClientPointer,inp,true);

	//alwaysMaster = false;

	return 0;
}

LUA_LIB removeMonster(lua_State* L) {
	int inp = (int)lua_tonumber(L, 1);

	std::shared_ptr<void> resultPtr;

	Star::EntityMap::entity(entityMapPointer, &resultPtr, inp);

	std::shared_ptr<void> monsterSharedPtr;

	auto entityAsMonsterFunc = (Star::entityAsMonster)(base + Star::ENTITYASMONSTER);
	entityAsMonsterFunc(&monsterSharedPtr, &resultPtr);

	void* monsterPtr = monsterSharedPtr.get();

	void* renderCallback = malloc(1024 * 1024);

	auto destroyFunc = (Star::Monster::destroy)(base + Star::Monster::DESTROY);
	destroyFunc(monsterPtr, renderCallback);

	free(renderCallback);


	return 0;
}

LUA_LIB suicide(lua_State* L) {
	Star::Player::kill(mainPlayerPointer);
	return 0;
}

LUA_LIB setGender(lua_State* L) {
	bool gender = lua_toboolean(L,1);

	Star::Player::setGender(mainPlayerPointer,&gender);

	return 0;
}

LUA_LIB setName(lua_State* L) {
	std::string newName(lua_tostring(L, 1));

	Star::Player::setName(mainPlayerPointer, &newName);

	return 0;
}

LUA_LIB setSpecies(lua_State* L) {
	std::string newSpecies(lua_tostring(L, 1));

	Star::Player::setSpecies(mainPlayerPointer, &newSpecies);

	return 0;
}

LUA_LIB setBodyDirectives(lua_State* L) {
	std::string newDirectives(lua_tostring(L, 1));

	Star::Player::setBodyDirectives(mainPlayerPointer, &newDirectives);

	return 0;
}

LUA_LIB setEmoteDirectives(lua_State* L) {
	std::string newDirectives(lua_tostring(L, 1));

	Star::Player::setEmoteDirectives(mainPlayerPointer, &newDirectives);

	return 0;
}

LUA_LIB setHairDirectives(lua_State* L) {
	std::string newDirectives(lua_tostring(L, 1));

	Star::Player::setHairDirectives(mainPlayerPointer, &newDirectives);

	return 0;
}

LUA_LIB setFacialHair(lua_State* L) {
	std::string groupString(lua_tostring(L, 1));
	std::string typeString(lua_tostring(L, 2));
	std::string directivesString(lua_tostring(L, 3));

	Star::Player::setFacialHair(mainPlayerPointer, &groupString, &typeString, &directivesString);

	return 0;
}

LUA_LIB setFacialMask(lua_State* L) {
	std::string groupString(lua_tostring(L, 1));
	std::string typeString(lua_tostring(L, 2));
	std::string directivesString(lua_tostring(L, 3));

	Star::Player::setFacialMask(mainPlayerPointer, &groupString, &typeString, &directivesString);

	return 0;
}

LUA_LIB setHairType(lua_State* L) {
	std::string groupString(lua_tostring(L, 1));
	std::string typeString(lua_tostring(L, 2));

	Star::Player::setHairType(mainPlayerPointer, &groupString, &typeString);

	return 0;
}

LUA_LIB setPersonality(lua_State* L) {

	std::string bodyIdle = lua_tostring(L, 1);
	std::string armIdle = lua_tostring(L, 2);
	
	float headX = lua_tonumber(L, 3);
	float headY = lua_tonumber(L, 4);
	float armX = lua_tonumber(L, 5);
	float armY = lua_tonumber(L, 6);

	std::string personalityJsonStr = "[\"" + bodyIdle + "\",\"" + armIdle + "\",[" + std::to_string(headX) + "," + std::to_string(headY) + "],[" + std::to_string(armX) + "," + std::to_string(armY) + "]]";

	void* personalityJson = malloc(2 * 1024); //2 kb is already way overkill

	Star::Json::parseJson(personalityJson, &personalityJsonStr);

	void* personalityPtr = malloc(2 * 1024);

	Star::parsePersonality(personalityPtr, personalityJson);

	free(personalityJson);

	Star::Player::setPersonality(mainPlayerPointer, personalityPtr);

	free(personalityPtr);

	return 0;
}

LUA_LIB resetMessageCount(lua_State* L) {
	numMessages = 0;

	return 0;
}

LUA_LIB joinParty(lua_State* L) {
	
	std::string uuidString = lua_tostring(L, 1);	


	// allocate enough space for the new uuid
	void* uuidPtr;
	uuidPtr = malloc(uuidString.size() * 2 * sizeof(wchar_t)); // not sure how much space to allocate so go a little over just in case

	// creates a new Star::Uuid object and puts it's pointer in uuidPtr
	Star::Uuid::uuid(uuidPtr, &uuidString);

	
	// finally forces you into the target player's team
	Star::TeamClient::acceptInvitation(teamClientPointer, uuidPtr);

	return 0;
}

LUA_LIB playerUniqueId(lua_State* L) {
	int inp = (int)lua_tonumber(L, 1);

	std::shared_ptr<void> resultPtr;

	Star::EntityMap::entity(entityMapPointer, &resultPtr, inp);

	void* entityPtr = resultPtr.get();

	void* uuidStarString = malloc(128);

	
	void* s = Star::Entity::uniqueId(entityPtr, uuidStarString);



	std::string uuidString = Star::String::utf8Ptr(uuidStarString);
	Star::Logger::log(Star::LogLevel::Info, uuidString.c_str());


	return 0;
}

LUA_LIB savePlayerFile(lua_State* L) {
	int inp = (int)lua_tonumber(L, 1);

	std::shared_ptr<void> resultPtr;

	
	Star::EntityMap::getPlayer(entityMapPointer, &resultPtr, inp);

	void* playerPtr = resultPtr.get();

	void* playerJson = (void*)malloc(sizeof(unsigned char) * 1024 * 1024 * 10); // allocate 10 MB because i don't know how to do it dynamically based on what i need

	Star::Player::diskStore(playerPtr, playerJson);



	std::string* jsonStarString = (std::string*)malloc(sizeof(unsigned char) * 1024 * 1024 * 10); // allocate 10 MB for the string too

	Star::Json::printJson(playerJson, jsonStarString, 1, false); // i think 1 sets pretty to true

	free(playerJson);

	double playerSize = Star::String::length(jsonStarString);
	std::string format = "B";
	if (playerSize > 1024) {
		playerSize /= 1024;
		format = "KB";
	}
	if (playerSize > 1024) {
		playerSize /= 1024;
		format = "MB";
	}
	Star::Logger::log(Star::LogLevel::Info, (std::to_string(playerSize) + " " + format).c_str());

	std::string jsonString = Star::String::utf8Ptr(jsonStarString);

	free(jsonStarString);

	std::ofstream myfile;
	myfile.open("playerDump.json");
	myfile << jsonString;
	myfile.close();


	return 1;
}

LUA_LIB sendChat(lua_State* L) {
	std::string message = lua_tostring(L,1);

	Star::UniverseClient::sendChat(universeClientPointer, &message, Star_ChatSendMode::World);

	return 0;
}

LUA_LIB currentChat(lua_State* L) {
	std::string* chatStr = (std::string*)malloc(1024 * 100); // 100,000 characters should be enough
	Star::Chat::currentChat(chatPointer, chatStr);


	lua_pushstring(L, (*chatStr).c_str());

	free(chatStr);

	return 1;
}

LUA_LIB copySong(lua_State* L) {
	int inp = (int)lua_tonumber(L, 1);

	std::shared_ptr<void> resultPtr;

	Star::EntityMap::getPlayer(entityMapPointer, &resultPtr, inp);

	void* playerPtr = resultPtr.get();

	std::shared_ptr<void> songSharedPtr;

	Star::Player::songbook(playerPtr, &songSharedPtr);

	void* songbookPtr = songSharedPtr.get();

	int songJsonPtrOffset = 0xF0;
	void* songJsonPtr = (reinterpret_cast<void*>(reinterpret_cast<char*>(songbookPtr) + songJsonPtrOffset));



	std::string* jsonStarString = (std::string*)malloc(1024 * 1024);
	Star::Json::printJson(songJsonPtr, jsonStarString, 1, false);
	std::string jsonString = Star::String::utf8Ptr(jsonStarString);
	Star::Logger::log(Star::LogLevel::Info, jsonString.c_str());

	//std::shared_ptr<void> mainSongbookSharedPtr;

	//void* mainPlayerSongbook = Star::Player::songbook(mainPlayerPointer, &mainSongbookSharedPtr);

	//Star::SongBook::play(mainPlayerSongbook, songJsonPtr, timeSourcePtr);

	// lol just set my songbook to be theirs
	int songbookPtrOffset = 0xBA8;
	std::shared_ptr<void>* selfSongbookPtrLoc = (reinterpret_cast<std::shared_ptr<void>*>(reinterpret_cast<char*>(playerPtr) + songbookPtrOffset));
	std::shared_ptr<void>* selfSongbookSharedPtr = new std::shared_ptr<void>(songbookPtr);
	*selfSongbookPtrLoc = *selfSongbookSharedPtr;

	return 0;
}

LUA_LIB setTeamPortrait(lua_State* L) {
	customPortrait = lua_tostring(L, 1);
	return 0;
}

LUA_LIB setChatMessage(lua_State* L) {
	customChatMessage = lua_tostring(L, 1);
	return 0;
}

std::string playerTechDirectives = "";

Hook<void* (*)(void* tc, void* result)> TechController_parentDirectives_HOOK;
void* TECHCONTROLLER_PARENTDIRECTIVES_HOOK(void* tc, void* result) {
	void* dirStar = TechController_parentDirectives_HOOK.Base(tc,result);

	playerTechDirectives = Star::String::utf8Ptr(dirStar);


	return dirStar;
}

std::string playerStatusDirectives = "";

Hook<void* (*)(void* sc, void* result)> StatusController_parentDirectives_HOOK;
void* STATUSCONTROLLER_PARENTDIRECTIVES_HOOK(void* sc, void* result) {
	void* dirStar = StatusController_parentDirectives_HOOK.Base(sc, result);

	playerStatusDirectives = Star::String::utf8Ptr(dirStar);


	return dirStar;
}

LUA_LIB playerDirectives(lua_State* L) {
	int inp = (int)lua_tonumber(L, 1);

	std::shared_ptr<void> resultPtr;

	Star::EntityMap::getPlayer(entityMapPointer, &resultPtr, inp);

	void* playerPtr = resultPtr.get();



	TechController_parentDirectives_HOOK = Hook<void*(*)(void* tc, void* result)>(base + Star::TechController::PARENTDIRECTIVES, TECHCONTROLLER_PARENTDIRECTIVES_HOOK);
	TechController_parentDirectives_HOOK.SetEnabled(true);

	StatusController_parentDirectives_HOOK = Hook<void* (*)(void* sc, void* result)>(base + Star::StatusController::PARENTDIRECTIVES, STATUSCONTROLLER_PARENTDIRECTIVES_HOOK);
	StatusController_parentDirectives_HOOK.SetEnabled(true);


	void* drawablesPtr = malloc(1024 * 1024); // don't know how big drawables will be so allocate a megabyte of space and then instantly free it

	Star::Player::drawables(playerPtr, drawablesPtr);

	free(drawablesPtr);


	TechController_parentDirectives_HOOK.SetEnabled(false);
	StatusController_parentDirectives_HOOK.SetEnabled(false);

	lua_pushstring(L, playerTechDirectives.c_str());
	lua_pushstring(L, playerStatusDirectives.c_str());

	return 2;
}

LUA_LIB lounge(lua_State* L) {
	int entityid = lua_tonumber(L,1);
	unsigned __int64 anchorIndex = lua_tonumber(L, 2);

	Star::Player::lounge(mainPlayerPointer, entityid, anchorIndex);

	return 0;
}

LUA_LIB getPixel(lua_State* L) {
	void* inpImage = makeStarString(lua_tostring(L, 1));
	unsigned int x = lua_tonumber(L, 2);
	unsigned int y = lua_tonumber(L, 3);

	std::array<unsigned int,2> pos = {4,4};

	std::shared_ptr<void> imgShared;

	Star::Assets::image(assetsPointer, &imgShared, inpImage);

	void* image = imgShared.get();

	std::array<unsigned char,4> color;

	Star::Image::get(image, &color, &pos);

	int r = (int)color[0];
	int g  = (int)color[1];
	int b = (int)color[2];
	int a = (int)color[3];

	std::stringstream stream;

	stream << std::setfill('0') << std::setw(2) << std::hex << r;
	std::string rStr = stream.str();

	stream.str("");
	stream << std::setfill('0') << std::setw(2) << std::hex << g;
	std::string gStr = stream.str();

	stream.str("");
	stream << std::setfill('0') << std::setw(2) << std::hex << b;
	std::string bStr = stream.str();

	stream.str("");
	stream << std::setfill('0') << std::setw(2) << std::hex << a;
	std::string aStr = stream.str();

	std::string hexColor = rStr + gStr + bStr + aStr;

	Star::Logger::log(Star::LogLevel::Info, hexColor.c_str());

	lua_pushstring(L, hexColor.c_str());


	return 1;
}

LUA_LIB playerAimPosition(lua_State* L) {
	int inp = (int)lua_tonumber(L, 1);

	std::shared_ptr<void> resultPtr;

	Star::EntityMap::getPlayer(entityMapPointer, &resultPtr, inp);

	void* playerPtr = resultPtr.get();

	std::array<float, 2> aimPosResult;

	Star::Player::aimPosition(playerPtr, &aimPosResult);

	lua_pushnumber(L,aimPosResult.at(0));
	lua_pushnumber(L, aimPosResult.at(1));

	return 2;
}

LUA_LIB forceNude(lua_State* L) {
	Star::Player::forceNude(mainPlayerPointer);
	return 0;
}

LUA_LIB setMovingBackwards(lua_State* L) {
	bool movingBackwards = lua_toboolean(L, 1);


	int humanoidPtrOffset = 0x138;
	void* humanoidPtr = (reinterpret_cast<void*>(reinterpret_cast<char*>(mainPlayerPointer) + humanoidPtrOffset));

	Star::Humanoid::setMovingBackwards(humanoidPtr, movingBackwards);

	return 0;
}

LUA_LIB chatGetFocused(lua_State* L) {
	lua_pushboolean(L, chatFocused);
	return 1;
}

LUA_LIB addChatMessage(lua_State* L) {
	std::string newMessage(lua_tostring(L, 1));

	Star::Player::addChatMessage(mainPlayerPointer, &newMessage);

	return 0;
}

LUA_LIB disconnect(lua_State* L) {
	std::shared_ptr<void> newPacket;

	Star::ClientDisconnectRequestPacket::make_shared(&newPacket);

	Star::UniverseConnection::pushSingle(universeConnectionPointer, newPacket);

	return 0;
}

LUA_LIB setColor(lua_State* L) {

	char r = lua_tonumber(L, 1);
	char g = lua_tonumber(L, 2);
	char b = lua_tonumber(L, 3);
	char a = lua_tonumber(L, 4);

	int humanoidPointerOffset = 0x6F8;
	void* humanoidIdentityPtr = (reinterpret_cast<void*>(reinterpret_cast<char*>(mainPlayerPointer) + humanoidPointerOffset));

	int colorPointerOffset = 0x1F8;

	std::array<char,4>* colorPtr = (reinterpret_cast<std::array<char, 4>*>(reinterpret_cast<char*>(humanoidIdentityPtr) + colorPointerOffset));

	*colorPtr = {r,g,b,a};

	return 0;
}

LUA_LIB copyInventory(lua_State* L) {
	int inp = (int)lua_tonumber(L, 1);
	std::shared_ptr<void> resultPtr;
	Star::EntityMap::getPlayer(entityMapPointer, &resultPtr, inp);
	void* targetPlayerPtr = resultPtr.get();

	Star::InventoryPane::update(inventoryPanePointer);
	std::shared_ptr<void>* parentPlayerSharedPtr = (reinterpret_cast<std::shared_ptr<void>* > (reinterpret_cast<char*>(inventoryPanePointer) + 0x250));
	std::shared_ptr<void> newParentPlayerSharedPtr = *(new std::shared_ptr<void>());
	*parentPlayerSharedPtr = newParentPlayerSharedPtr;

	return 0;
}

LUA_LIB setEmoteState(lua_State* L) {
	int state = lua_tointeger(L, 1);


	int humanoidPtrOffset = 0x138;
	void* humanoidPtr = (reinterpret_cast<void*>(reinterpret_cast<char*>(mainPlayerPointer) + humanoidPtrOffset));

	Star::Humanoid::setEmoteState(humanoidPtr, (Star::HumanoidEmote)state);

	return 0;
}

// TODO: make a custom networked animator actually work
LUA_LIB setCustomHumanoidParticles(lua_State* L) {
	//std::string animatorJsonInput(lua_tostring(L, 1));
	int humanoidPtrOffset = 0x138;
	void* humanoidPtr = (*(reinterpret_cast<std::shared_ptr<void>*>(reinterpret_cast<char*>(mainPlayerPointer) + humanoidPtrOffset))).get();
	int particleEmittersPtrOffset = 0x800;
	void* particleEmittersJson = (reinterpret_cast<void*>(reinterpret_cast<char*>(humanoidPtr) + particleEmittersPtrOffset));

	std::string* jsonStarString = (std::string*)malloc(1024);
	//Star::Json::printJson(particleEmittersJson, jsonStarString, 1, false);
	Star::Json::printJson(particleEmittersJson, jsonStarString, 1, false);
	std::string jsonString = Star::String::utf8Ptr(jsonStarString);
	free(jsonStarString);
	Star::Logger::log(Star::LogLevel::Info, jsonString.c_str());

	return 0;
}

LUA_LIB invitePlayer(lua_State* L) {
	std::string inviteeName = lua_tostring(L, 1);
	std::string inviterName = lua_tostring(L, 2);
	std::string inviterUuid = lua_tostring(L, 3);


	std::string methodName = "team.invite";

	std::string argsJsonStr = "{\"inviteeName\":\"" + inviteeName + "\",\"inviterName\":\"" + inviterName + "\",\"inviterUuid\":\"" + inviterUuid + "\"}";
	void* argsJson = malloc(1024 * 1024 * 256); //256MB just in case you're spamming or something

	Star::Json::parseJson(argsJson, &argsJsonStr);


	std::function<void __cdecl(void* const&)> responseFunction = dummyResponse;

	Star::TeamClient::invokeRemote(teamClientPointer, &methodName, argsJson, responseFunction);

	free(argsJson);

	return 0;
}

LUA_LIB setCanPickupItems(lua_State* L) {
	canPickupItems = lua_toboolean(L, 1);
	return 0;
}

LUA_LIB material(lua_State* L) {
	int x = lua_tonumber(L, 1);
	int y = lua_tonumber(L, 2);
	std::string layer = lua_tostring(L, 3);

	Star::TileLayer layerNum;

	if (layer == "foreground") {
		layerNum = Star::TileLayer::Foreground;
	}
	else if (layer == "background") {
		layerNum = Star::TileLayer::Background;
	} else {
		Star::Logger::log(Star::LogLevel::Error, ("Error: " + layer + " is not a valid layer.").c_str());
		return 0;
	}

	std::array<int, 2> position = {x, y};

	unsigned __int64 materialId = Star::WorldClient::material(worldClientPointer, &position, layerNum);

	lua_pushnumber(L,materialId);

	return 1;
}


static const struct luaL_Reg luaFuncs[] = {
	{"acceptInvitation",acceptInvitation},
	{"removeEntity",removeEntity},
	{"suicide",suicide},
	{"setGender",setGender},
	{"setName",setName},
	{"setSpecies",setSpecies},
	{"setPersonality",setPersonality},
	{"resetMessageCount",resetMessageCount},
	{"joinParty",joinParty},
	{"playerUniqueId",playerUniqueId},
	{"savePlayerFile",savePlayerFile},
	{"sendChat",sendChat},
	{"playerDirectives",playerDirectives},
	{"setBodyDirectives",setBodyDirectives},
	{"setEmoteDirectives",setEmoteDirectives},
	{"setHairDirectives",setHairDirectives},
	{"setFacialHair",setFacialHair},
	{"setFacialMask",setFacialMask},
	{"setHairType",setHairType},
	{"currentChat",currentChat},
	{"lounge",lounge},
	{"destroyMonster",removeMonster},
	{"setTeamPortrait",setTeamPortrait},
	{"setChatMessage",setChatMessage},
	{"getPixel",getPixel},
	{"playerAimPosition",playerAimPosition},
	{"forceNude",forceNude},
	{"chatFocused",chatGetFocused},
	{"addChatMessage",addChatMessage},
	{"disconnect",disconnect},
	{"setColor",setColor},
	{"copySong",copySong},
	{"copyInventory",copyInventory},
	{"setMovingBackwards",setMovingBackwards},
	{"setEmoteState",setEmoteState},
	{"setCustomHumanoidParticles",setCustomHumanoidParticles},
	{"invitePlayer",invitePlayer},
	{"setCanPickupItems",setCanPickupItems},
	{"material",material},
	{ NULL, NULL }
};

LUA_LIB __declspec(dllexport) dll_init(lua_State* L) {


	luaL_newlibtable(L, luaFuncs);
	luaL_setfuncs(L, luaFuncs, 0);

	return 1;
}



// lua hooks
/*
Hook<lua_State* (*)(void* call, void* ud)> Lua_newState_HOOK;

lua_State* LUA_NEWSTATE_HOOK(void* call, void* ud) {
	lua_State* L = Lua_newState_HOOK.Base(call, ud);
	Star::Logger::log(Star::LogLevel::Info, "WorkingDLL: Lua State Intercepted");

	lua_register(L, "test", test);

	return L;
}


Hook<int(*)(lua_State* L)> lua_gettop_HOOK;

int LUA_GETTOP_HOOK(lua_State* L) {
	//lua_register(L, "test", dll_test);
	return lua_gettop_HOOK.Base(L);
}
*/
	
// intercept chat bubbles to log when people use live chat

//std::string chatBubbleMessage = "";
//int chatBubbleSender = 0;

Hook<void(*)(void* sca, int entity, void* text, void* position)> SayChatAction_SayChatAction_HOOK;
void SAYCHATACTION_SAYCHATACTION_HOOK(void* sca, int entity, void* text, void* position) {
	//chatBubbleMessage = Star::String::utf8Ptr(text);
	//chatBubbleSender = entity;
	
	//std::shared_ptr<void>* resultPtr = new std::shared_ptr<void>();
	//Star::EntityMap::getPlayer(entityMapPointer, &(*resultPtr), entity);

	//void* nameStarStr = Star::Player::name((*resultPtr).get());
	//std::string* nameStr = new std::string(Star::String::utf8Ptr(nameStarStr));
	


	//delete(resultPtr);
	//free(nameStarStr);
	//delete(nameStr);

	SayChatAction_SayChatAction_HOOK.Base(sca, entity, text, position);
	

	//Star::Logger::log(Star::LogLevel::Info, chatBubbleMessage.c_str());

	return;
}

Hook<void*(*)(void* p, void* result, unsigned __int16 fromConnection, void* message, void* args)> Player_receive_message_HOOK;
void* PLAYER_RECEIVEMESSAGE_HOOK(void* p, void* result, unsigned __int16 fromConnection, void* message, void* args) {

	int playerPointerOffset = 0x1450; // determined experimentally by comparing hooked pointer with one gotten from WorldClient
	void* newPlayerPointer = reinterpret_cast<void*>(reinterpret_cast<char*>(p) - playerPointerOffset);
	mainPlayerPointer = newPlayerPointer;


	if (numMessages <= 5) {
		std::string messageName = Star::String::utf8Ptr(message);
		messageName = messageName.substr(0, 50); // cut it off if it's longer than 50 characters
		std::string logMessage = (std::string)"Message Recieved: " + messageName + (std::string)" from " + std::to_string(fromConnection);
		Star::Logger::log(Star::LogLevel::Info, logMessage.c_str());
		numMessages++;
	}


	return Player_receive_message_HOOK.Base(p, result, fromConnection, message, args);
}

Hook<void(*)(void* wc, std::shared_ptr<void> mainPlayer)> WorldClient_WorldClient_HOOK;
void WORLDCLIENT_WORLDCLIENT_HOOK(void* wc, std::shared_ptr<void> mainPlayer) {

	Star::Logger::log(Star::LogLevel::Info, "WorkingDLL: World Client hooked");
	WorldClient_WorldClient_HOOK.Base(wc, mainPlayer);

	worldClientPointer = wc;
	mainPlayerPointer = mainPlayer.get();

	const void* address = static_cast<const void*>(wc);
	std::stringstream ss;
	ss << address;
	std::string str = ss.str();

	Star::Logger::log(Star::LogLevel::Info, "constructor pointer:");
	Star::Logger::log(Star::LogLevel::Info, str.c_str());

	/* sets gravity
	auto gravFunction = (WorldClient::overrideGravity)(base + WorldClient::OVERRIDEGRAVITY);
	gravFunction(wc, 0);
	*/
	return;
}

Hook<void(*)(void* wc)> WorldClient_update_HOOK;
void WORLDCLIENT_UPDATE_HOOK(void* wc) {



	worldClientPointer = wc;


	WorldClient_update_HOOK.Base(wc);

	return;
}


Hook<void(*)(void* ws, void* chunks)>WorldServer_WorldServer_HOOK;
void WORLDSERVER_WORLDSERVER_HOOK(void* ws, void* chunks) {
	Star::Logger::log(Star::LogLevel::Info, "WorkingDLL: World Server hooked");
	WorldServer_WorldServer_HOOK.Base(ws, chunks);;

	worldServerPointer = ws;


	return;
}

Hook<void(*)(void* cp)>ChatProcessor_ChatProcessor_HOOK;
void CHATPROCESSOR_CHATPROCESSOR_HOOK(void* cp) {
	Star::Logger::log(Star::LogLevel::Info, "WorkingDLL: Chat Processor hooked");

	chatProcessorPointer = cp;

	ChatProcessor_ChatProcessor_HOOK.Base(cp);


	return;
}

Hook<void(*)(void* tc, std::shared_ptr<void> mainPlayer, std::shared_ptr<void> clientContext)> TeamClient_TeamClient_HOOK;
void TEAMCLIENT_TEAMCLIENT_HOOK(void* tc, std::shared_ptr<void> mainPlayer, std::shared_ptr<void> clientContext) {
	Star::Logger::log(Star::LogLevel::Info, "WorkingDLL: Team Client hooked");

	teamClientPointer = tc;

	TeamClient_TeamClient_HOOK.Base(tc, mainPlayer, clientContext);


	return;
}

Hook<void(*)(void* em, void* worldSize, int beginIdSpace, int endIdSpace)>EntityMap_EntityMap_HOOK;
void ENTITYMAP_ENTITYMAP_HOOK(void* em, void* worldSize, int beginIdSpace, int endIdSpace) {
	Star::Logger::log(Star::LogLevel::Info, "WorkingDLL: Entity Map hooked");

	EntityMap_EntityMap_HOOK.Base(em, worldSize, beginIdSpace, endIdSpace);


	return;
}

Hook<void(*)(void* mc)>MovementController_UpdateForceRegions_HOOK;
void MOVEMENTCONTROLLER_UPDATEFORCEREGIONS_HOOK(void* mc) {
	// just do nothing
	return;
}

Hook<void(*)(void* mi, std::shared_ptr<void> client, std::shared_ptr<void> painter, std::shared_ptr<void> cinematicOverlay)>MainInterface_MainInterface_HOOK;
void MAININTERFACE_MAININTERFACE_HOOK(void* mi, std::shared_ptr<void> client, std::shared_ptr<void> painter, std::shared_ptr<void> cinematicOverlay) {
	Star::Logger::log(Star::LogLevel::Info, "WorkingDLL: Main Interface hooked");

	mainInterfacePointer = mi;
	MainInterface_MainInterface_HOOK.Base(mi, client, painter, cinematicOverlay);


	return;
}

Hook<void(*)(void* uc, std::shared_ptr<void> playerStorage, std::shared_ptr<void> statistics)>UniverseClient_UniverseClient_HOOK;
void UNIVERSECLIENT_UNIVERSECLIENT_HOOK(void* uc, std::shared_ptr<void> playerStorage, std::shared_ptr<void> statistics) {
	Star::Logger::log(Star::LogLevel::Info, "WorkingDLL: Universe Client hooked");

	universeClientPointer = uc;
	UniverseClient_UniverseClient_HOOK.Base(uc, playerStorage, statistics);
	return;
}

Hook<void(*)(void* uc, std::string* text, Star_ChatSendMode sendMode)>UniverseClient_sendChat_HOOK;
void UNIVERSECLIENT_SENDCHAT_HOOK(void* uc, std::string* text, Star_ChatSendMode sendMode) {

	if (customChatMessage == "") {
		UniverseClient_sendChat_HOOK.Base(uc, text, sendMode);	
	}
	else {
		UniverseClient_sendChat_HOOK.Base(uc, &customChatMessage, sendMode);
		customChatMessage = "";
	}

	return;
}

Hook<void(*)(void* tb, void* mainInterface, std::shared_ptr<void> universeClient)> TeamBar_TeamBar_HOOK;
void TEAMBAR_TEAMBAR_HOOK(void* tb, void* mainInterface, std::shared_ptr<void> universeClient) {
	Star::Logger::log(Star::LogLevel::Info, "WorkingDLL: Team Bar hooked");

	teamBarPointer = tb;

	TeamBar_TeamBar_HOOK.Base(tb, mainInterface, universeClient);


	universeClientPointer = universeClient.get();

	return;
}

Hook<void(*)(void* c, std::shared_ptr<void> client)> Chat_Chat_HOOK;
void CHAT_CHAT_HOOK(void* c, std::shared_ptr<void> client) {
	Star::Logger::log(Star::LogLevel::Info, "WorkingDLL: Chat hooked");
	Chat_Chat_HOOK.Base(c, client);;

	chatPointer = c;
	universeClientPointer = client.get();

	return;
}

Hook<bool(*)(void* c)> Chat_hasFocus_HOOK;
bool CHAT_HASFOCUS_HOOK(void* c) {

	chatPointer = c;

	chatFocused = Chat_hasFocus_HOOK.Base(c);

	return chatFocused;
}

Hook<bool(*)(void* ucn)> UniverseConnection_isOpen_HOOK;
bool UNIVERSECONNECTION_ISOPEN_HOOK(void* ucn) {

	universeConnectionPointer = ucn;

	return UniverseConnection_isOpen_HOOK.Base(ucn);
}

Hook<void(*)(void* l, const char* msg, void* args)>Logger_logf_HOOK;
void LOGGER_LOGF_HOOK(void* l, const char* msg, void* args) {
	return;
}


int discUpdates = 0;

Hook<void(*)(void* pcp2pns, void* title, void* party)> PcP2PNetworkingService_setActivityData_HOOK;
void PCP2PNETWORKINGSERVICE_SETACTIVITYDATA_HOOK(void* pcp2pns, void* title, void* party) {

	void* newMessage = makeStarString("Borking Starbound #" + std::to_string(discUpdates));
	discUpdates++;

	PcP2PNetworkingService_setActivityData_HOOK.Base(pcp2pns, newMessage, party);

	return;
}

Hook<void(*)(void* ps, int maxSize)> PartySize_SetMaxSize_HOOK;
void PARTYSIZE_SETMAXSIZE_HOOK(void* ps, int maxSize) {

	int newMaxSize = rand() % 90 + 10;
	PartySize_SetMaxSize_HOOK.Base(ps, newMaxSize);

	return;
}

Hook<bool(*)(void* e)> Entity_isMaster_HOOK;
bool ENTITY_ISMASTER_HOOK(void* e) {
	if (!alwaysMaster) {
		return Entity_isMaster_HOOK.Base(e);
	}
	return true;
}

Hook<bool(*)(void* tc, void* playerUUid)> TeamClient_isTeamLeader_HOOK;
bool TEAMCLIENT_ISTEAMLEADER_HOOK(void* tc, void* playerUuid) {
	return TeamClient_isTeamLeader_HOOK.Base(tc,playerUuid);
}

Hook<void(*)(void* tc, std::string* method, void* args, std::function<void __cdecl(void* const&)> responseFunction)> TeamClient_invokeRemote_HOOK;
void TEAMCLIENT_INVOKEREMOTE_HOOK(void* tc, std::string* method, void* args, std::function<void __cdecl(void* const&)> responseFunction) {


	if (*method == "team.updateStatus") {
		std::string warpMode = "None";
		void* warpModeJson = malloc(128);
		Star::Json::JsonFromString(warpModeJson, &warpMode);
		std::string keyStr = "warpMode";

		Star::Json::setKey(args, args, &keyStr, warpModeJson);
		free(warpModeJson);

		if (customPortrait != "") {
			keyStr = "portrait";
			std::string portraitJsonStr = customPortrait;
			void* portraitJson = malloc(1024 * 1024);

			Star::Json::parseJson(portraitJson, &portraitJsonStr);

			Star::Json::setKey(args, args, &keyStr, portraitJson);
			free(portraitJson);
		}

	}
	TeamClient_invokeRemote_HOOK.Base(tc, method, args, responseFunction);
}

Hook<void(*)(void* tc)> TeamClient_statusUpdate_HOOk;
void TEAMCLIENT_STATUSUPDATE_HOOK(void* tc) {
	TeamClient_invokeRemote_HOOK.SetEnabled(true);
	TeamClient_statusUpdate_HOOk.Base(tc);
	TeamClient_invokeRemote_HOOK.SetEnabled(false);
}

Hook<void(*)(void* as, void* settings, void* assetSources)> Assets_Assets_HOOK;
void ASSETS_ASSETS_HOOK(void* as, void* settings, void* assetSources) {
	assetsPointer = as;
	Star::Logger::log(Star::LogLevel::Info, "Assets hooked");
	Assets_Assets_HOOK.Base(as, settings, assetSources);	
}

Hook<bool(*)(void* as, void* path)> Assets_assetExists_HOOK;
bool ASSETS_ASSETEXISTS_HOOK(void* as, void* path) {
	assetsPointer = as;
	return Assets_assetExists_HOOK.Base(as, path);
}

Hook<void*(*)(void* em, void* result, void* boundBox, void* filter)> EntityMap_entityQuery_HOOK;
void* ENTITYMAP_ENTITYQUERY_HOOK(void* em, void* result, void* boundBox, void* filter) {
	entityMapPointer = em;

	return EntityMap_entityQuery_HOOK.Base(em, result, boundBox, filter);
}

Hook<void(*)(void* pi)> PlayerInventory_PlayerInventory_HOOK;
void PLAYERINVENTORY_PLAYERINVENTORY_HOOK(void* pi) {
	mainPlayerInventoryPointer = pi;
	PlayerInventory_PlayerInventory_HOOK.Base(pi);
}

// stop player inventory from being networked
Hook<void(*)(void* pi)> PlayerInventory_netElementsNeedStore_HOOK;
void PLAYERINVENTORY_NETELEMENTSNEEDSTORE_HOOK(void* pi) {
	if (inventoryNetworked) {
		PlayerInventory_netElementsNeedStore_HOOK.Base(pi);
	}
	return;
}

//stopping player junk from being networked
Hook<void(*)(void* p)> Player_setNetStates_HOOK;
void PLAYER_SETNETSTATES_HOOK(void* p) {
	Player_setNetStates_HOOK.Base(p);
}

Hook<void(*)(void* ip)> InventoryPane_update_HOOK;
void INVENTORYPANE_UPDATE_HOOK(void* pi) {
	inventoryPanePointer = pi;
	InventoryPane_update_HOOK.Base(pi);
	return;
}

Hook<unsigned __int64(*)(void* pi, std::shared_ptr<void> *items)> PlayerInventory_itemsCanFit_HOOK;
unsigned __int64 PLAYERINVENTORY_ITEMSCANFIT_HOOK(void* pi, std::shared_ptr<void> *items) {
	if (canPickupItems) {
		return PlayerInventory_itemsCanFit_HOOK.Base(pi, items);
	} else {
		return 0;
	}
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {

	char moduleName[MAX_PATH];
	GetModuleFileNameA(hModule, moduleName, sizeof(moduleName));
	HMODULE hm;
	int a = lstrlenA(moduleName);
	LPWSTR modName = SysAllocStringLen(NULL, a);
	MultiByteToWideChar(CP_ACP, 0, moduleName, a, modName, a);;
	GetModuleHandleEx(GET_MODULE_HANDLE_EX_FLAG_PIN, modName, &hm);


	if (ul_reason_for_call == DLL_PROCESS_ATTACH) {

		SayChatAction_SayChatAction_HOOK = Hook<void(*)(void* sca, int entity, void* text, void* position)>(base + Star::SayChatAction::SAYCHATACTION, SAYCHATACTION_SAYCHATACTION_HOOK);
		SayChatAction_SayChatAction_HOOK.SetEnabled(false);

		UniverseConnection_isOpen_HOOK = Hook<bool(*)(void* ucn)>(base + Star::UniverseConnection::ISOPEN, UNIVERSECONNECTION_ISOPEN_HOOK);
		UniverseConnection_isOpen_HOOK.SetEnabled(true);

		Player_receive_message_HOOK = Hook<void*(*)(void* p, void* result, unsigned __int16 fromConnection, void* message, void* args)>(base + Star::Player::RECEIVEMESSAGE, PLAYER_RECEIVEMESSAGE_HOOK);
		Player_receive_message_HOOK.SetEnabled(true);

		WorldClient_WorldClient_HOOK = Hook<void(*)(void* wc, std::shared_ptr<void> mainPlayer)>(base + Star::WorldClient::WORLDCLIENT, WORLDCLIENT_WORLDCLIENT_HOOK);
		WorldClient_WorldClient_HOOK.SetEnabled(true);

		WorldClient_update_HOOK = Hook<void(*)(void* wc)>(base + Star::WorldClient::UPDATE, WORLDCLIENT_UPDATE_HOOK);
		WorldClient_update_HOOK.SetEnabled(true);

		WorldServer_WorldServer_HOOK = Hook<void(*)(void* wc, void* chunks)>(base + Star::WorldServer::WORLDSERVER, WORLDSERVER_WORLDSERVER_HOOK);
		WorldServer_WorldServer_HOOK.SetEnabled(true);

		ChatProcessor_ChatProcessor_HOOK = Hook<void(*)(void* cp)>(base + Star::ChatProcessor::CHATPROCESSOR, CHATPROCESSOR_CHATPROCESSOR_HOOK);
		ChatProcessor_ChatProcessor_HOOK.SetEnabled(true);

		TeamClient_TeamClient_HOOK = Hook<void(*)(void* tc, std::shared_ptr<void> mainPlayer, std::shared_ptr<void> clientContext)>(base + Star::TeamClient::TEAMCLIENT, TEAMCLIENT_TEAMCLIENT_HOOK);
		TeamClient_TeamClient_HOOK.SetEnabled(true);

		EntityMap_EntityMap_HOOK = Hook<void(*)(void* em, void* worldSize, int beginIdSpace, int endIdSpace)>(base + Star::EntityMap::ENTITYMAP, ENTITYMAP_ENTITYMAP_HOOK);
		EntityMap_EntityMap_HOOK.SetEnabled(true);

		MovementController_UpdateForceRegions_HOOK = Hook<void(*)(void* mc)>(base + Star::MovementController::UPDATEFORCEREGIONS, MOVEMENTCONTROLLER_UPDATEFORCEREGIONS_HOOK);
		MovementController_UpdateForceRegions_HOOK.SetEnabled(true);

		MainInterface_MainInterface_HOOK = Hook<void(*)(void* mi, std::shared_ptr<void> client, std::shared_ptr<void> painter, std::shared_ptr<void> cinematicOverlay)>(base + Star::MainInterface::MAININTERFACE, MAININTERFACE_MAININTERFACE_HOOK);
		MainInterface_MainInterface_HOOK.SetEnabled(true);

		UniverseClient_UniverseClient_HOOK = Hook<void(*)(void* uc, std::shared_ptr<void> playerStorage, std::shared_ptr<void> statistics)>(base + Star::UniverseClient::UNIVERSECLIENT, UNIVERSECLIENT_UNIVERSECLIENT_HOOK);
		UniverseClient_UniverseClient_HOOK.SetEnabled(true);

		UniverseClient_sendChat_HOOK = Hook<void(*)(void* uc, std::string* text, Star_ChatSendMode sendMode)>(base + Star::UniverseClient::SENDCHAT, UNIVERSECLIENT_SENDCHAT_HOOK);
		UniverseClient_sendChat_HOOK.SetEnabled(true);

		TeamBar_TeamBar_HOOK = Hook<void(*)(void* tb, void* mainInterface, std::shared_ptr<void> universeClient)>(base + Star::TeamBar::TEAMBAR, TEAMBAR_TEAMBAR_HOOK);
		TeamBar_TeamBar_HOOK.SetEnabled(true);

		Chat_Chat_HOOK = Hook<void(*)(void* c, std::shared_ptr<void> client)>(base + Star::Chat::CHAT, CHAT_CHAT_HOOK);
		Chat_Chat_HOOK.SetEnabled(true);

		Entity_isMaster_HOOK = Hook<bool(*)(void* e)>(base + Star::Entity::ISMASTER, ENTITY_ISMASTER_HOOK);
		Entity_isMaster_HOOK.SetEnabled(true);

		TeamClient_invokeRemote_HOOK = Hook<void(*)(void* tc, std::string * method, void* args, std::function<void __cdecl(void* const&)> responseFunction)>(base + Star::TeamClient::INVOKEREMOTE, TEAMCLIENT_INVOKEREMOTE_HOOK);
		TeamClient_invokeRemote_HOOK.SetEnabled(true);

		TeamClient_statusUpdate_HOOk = Hook<void(*)(void* tc)>(base + Star::TeamClient::STATUSUPDATE, TEAMCLIENT_STATUSUPDATE_HOOK);
		TeamClient_statusUpdate_HOOk.SetEnabled(false);

		Assets_Assets_HOOK = Hook<void(*)(void* as, void* settings, void* assetSources)>(base + Star::Assets::ASSETS, ASSETS_ASSETS_HOOK);
		Assets_Assets_HOOK.SetEnabled(true);
		
		Assets_assetExists_HOOK = Hook<bool(*)(void* as, void* path)>(base + Star::Assets::ASSETEXISTS, ASSETS_ASSETEXISTS_HOOK);
		Assets_assetExists_HOOK.SetEnabled(true);

		EntityMap_entityQuery_HOOK = Hook<void* (*)(void* em, void* result, void* boundBox, void* filter)>(base + Star::EntityMap::ENTITYQUERY, ENTITYMAP_ENTITYQUERY_HOOK);
		EntityMap_entityQuery_HOOK.SetEnabled(true);

		Chat_hasFocus_HOOK = Hook<bool(*)(void* c)>(base + Star::Chat::HASFOCUS, CHAT_HASFOCUS_HOOK);
		Chat_hasFocus_HOOK.SetEnabled(true);

		Player_setNetStates_HOOK = Hook<void(*)(void* p)>(base + Star::Player::SETNETSTATES, PLAYER_SETNETSTATES_HOOK);
		Player_setNetStates_HOOK.SetEnabled(false);

		PlayerInventory_netElementsNeedStore_HOOK = Hook<void(*)(void* pi)>(base + Star::PlayerInventory::NETELEMENTSNEEDSTORE, PLAYERINVENTORY_NETELEMENTSNEEDSTORE_HOOK);
		PlayerInventory_netElementsNeedStore_HOOK.SetEnabled(true);

		PlayerInventory_itemsCanFit_HOOK = Hook<unsigned __int64(*)(void* pi, std::shared_ptr<void> *items)>(base + Star::WorldClient::TRYGIVEMAINPLAYERITEM, PLAYERINVENTORY_ITEMSCANFIT_HOOK);
		PlayerInventory_itemsCanFit_HOOK.SetEnabled(true);

		InventoryPane_update_HOOK = Hook<void(*)(void* ip)>(base + Star::InventoryPane::UPDATE, INVENTORYPANE_UPDATE_HOOK);
		InventoryPane_update_HOOK.SetEnabled(true);

		// trying to hook starbound's discord message to be edgy
		PcP2PNetworkingService_setActivityData_HOOK = Hook<void(*)(void* pcp2pns, void* title, void* party)>(base + Star::PcP2PNetworkingService::SETACTIVITYDATA, PCP2PNETWORKINGSERVICE_SETACTIVITYDATA_HOOK);
		PcP2PNetworkingService_setActivityData_HOOK.SetEnabled(true);

		PartySize_SetMaxSize_HOOK = Hook<void(*)(void* ps, int maxSize)>(base + PartySize::SETMAXSIZE, PARTYSIZE_SETMAXSIZE_HOOK);
		PartySize_SetMaxSize_HOOK.SetEnabled(true);

		Logger_logf_HOOK = Hook<void(*)(void* l, const char* msg, void* args)>(base + Star::Logger::LOGF, LOGGER_LOGF_HOOK);
		Logger_logf_HOOK.SetEnabled(true);



		Star::Logger::log(Star::LogLevel::Info, "WorkingDLL: Hooks attached");
	}
	if (ul_reason_for_call == DLL_PROCESS_DETACH) {
		SayChatAction_SayChatAction_HOOK.SetEnabled(false);
		UniverseConnection_isOpen_HOOK.SetEnabled(false);
		Player_receive_message_HOOK.SetEnabled(false);
		WorldClient_WorldClient_HOOK.SetEnabled(false);
		WorldClient_update_HOOK.SetEnabled(false);
		WorldServer_WorldServer_HOOK.SetEnabled(false);
		ChatProcessor_ChatProcessor_HOOK.SetEnabled(false);
		TeamClient_TeamClient_HOOK.SetEnabled(false);
		EntityMap_EntityMap_HOOK.SetEnabled(false);
		MovementController_UpdateForceRegions_HOOK.SetEnabled(false);
		MainInterface_MainInterface_HOOK.SetEnabled(false);
		UniverseClient_UniverseClient_HOOK.SetEnabled(false);
		UniverseClient_sendChat_HOOK.SetEnabled(false);
		TeamBar_TeamBar_HOOK.SetEnabled(false);
		Chat_Chat_HOOK.SetEnabled(false);
		Entity_isMaster_HOOK.SetEnabled(false);
		TeamClient_invokeRemote_HOOK.SetEnabled(false);
		TeamClient_statusUpdate_HOOk.SetEnabled(false);
		Assets_Assets_HOOK.SetEnabled(false);
		Assets_assetExists_HOOK.SetEnabled(false);
		EntityMap_entityQuery_HOOK.SetEnabled(false);
		Chat_hasFocus_HOOK.SetEnabled(false);
		Player_setNetStates_HOOK.SetEnabled(true);
		PlayerInventory_netElementsNeedStore_HOOK.SetEnabled(false);
		PlayerInventory_itemsCanFit_HOOK.SetEnabled(false);
		InventoryPane_update_HOOK.SetEnabled(false);

		// discord stuff
		PcP2PNetworkingService_setActivityData_HOOK.SetEnabled(false);
		PartySize_SetMaxSize_HOOK.SetEnabled(false);
		Logger_logf_HOOK.SetEnabled(false);
		//Lua_newState_HOOK.SetEnabled(false);
		//lua_gettop_HOOK.SetEnabled(false);
	}

	return TRUE;
}

int playerForCid(unsigned __int16 connection) {
	return -1;
}
void Main()
{
#if SIG_DEVELOPER
	NadeoServices::AddAudience("NadeoServices");
	NadeoServices::AddAudience("NadeoLiveServices");

	ApiConsole::Initialize();
#endif

	auto app = cast<CGameManiaPlanet>(GetApp());
	auto api = app.ManiaPlanetScriptAPI;

	while (true) {
		// Wait until user is connected to Ubi services
		if (api.MasterServer_MSUsers.Length == 0) {
			yield();
			continue;
		}

		auto audiences = NadeoServices::Tokens.GetKeys();
		for (uint i = 0; i < audiences.Length; i++) {
			IToken@ token;
			if (NadeoServices::Tokens.Get(audiences[i], @token)) {
				token.UpdateAsync();
			}
		}

		yield();
	}
}

#if SIG_DEVELOPER
void RenderMenu()
{
	if (UI::MenuItem("\\$f93" + Icons::Ticket + "\\$z Nadeo API Console", "", ApiConsole::Visible)) {
		ApiConsole::Visible = !ApiConsole::Visible;
	}
}

void RenderInterface()
{
	ApiConsole::Render();
}
#endif

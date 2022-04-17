void Main()
{
	auto app = cast<CGameManiaPlanet>(GetApp());
	auto api = app.ManiaPlanetScriptAPI;

	while (true) {
		// Wait until user is connected to Ubi services
		if (api.MasterServer_MSUsers.Length == 0) {
			yield();
			continue;
		}

		for (uint i = 0; i < NadeoServices::Tokens.Length; i++) {
			NadeoServices::Tokens[i].UpdateAsync();
		}

		yield();
	}
}

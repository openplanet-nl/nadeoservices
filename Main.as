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

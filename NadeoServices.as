namespace NadeoServices
{
	string BaseURL()
	{
		warn("DEPRECATED: For the Live API, you should use NadeoServices::BaseURLLive() instead of BaseURL().");
		return BaseURLLive();
	}

	string BaseURLCore() { return "https://prod.trackmania.core.nadeo.online"; }
	string BaseURLLive() { return "https://live-services.trackmania.nadeo.live"; }
	string BaseURLClub() { return "https://club.trackmania.nadeo.club"; }
	string BaseURLCompetition() { return "https://competition.trackmania.nadeo.club"; }
	string BaseURLMatchmaking() { return "https://matchmaking.trackmania.nadeo.club"; }

	dictionary Tokens;

	IToken@ GetToken(const string &in audience)
	{
		IToken@ token = null;
		Tokens.Get(audience, @token);
		return token;
	}

	void AddAudience(const string &in audience)
	{
		if (GetToken(audience) !is null) {
			return;
		}

		IToken@ newToken = null;

		if (audience == "NadeoServices") {
			@newToken = CoreToken();
		} else if (audience == "NadeoLiveServices" || audience == "NadeoClubServices") {
			@newToken = AccessToken(audience);
		}

		if (newToken is null) {
			throw("Unknown token audience. Use \"NadeoServices\", \"NadeoLiveServices\", or \"NadeoClubServices\".");
		}

		Tokens.Set(audience, @newToken);
	}

	bool IsAuthenticated(const string &in audience)
	{
		IToken@ token;
		if (Tokens.Get(audience, @token)) {
			return token.IsAuthenticated();
		}
		return false;
	}

	string GetAccountID()
	{
		return Internal::NadeoServices::GetAccountID();
	}

	Net::HttpRequest@ Request(const string &in audience)
	{
		auto token = GetToken(audience);
		if (token is null) {
			throw("Unknown token audience \"" + audience + "\"!");
			return null;
		}

		if (!token.IsAuthenticated()) {
			throw("Token with audience \"" + audience + "\" is not authenticated!");
			return null;
		}

		auto ret = Net::HttpRequest();
		ret.Headers["Authorization"] = "nadeo_v1 t=" + token.GetToken();
		return ret;
	}

	Net::HttpRequest@ Get(const string &in audience, const string &in url = "")
	{
		auto ret = Request(audience);
		ret.Method = Net::HttpMethod::Get;
		ret.Url = url;
		return ret;
	}

	Net::HttpRequest@ Post(
		const string &in audience,
		const string &in url = "",
		const string &in body = "",
		const string &in contentType = "application/json"
	) {
		auto ret = Request(audience);
		ret.Method = Net::HttpMethod::Post;
		ret.Url = url;
		ret.Body = body;
		ret.Headers["Content-Type"] = contentType;
		return ret;
	}

	Net::HttpRequest@ Put(
		const string &in audience,
		const string &in url = "",
		const string &in body = "",
		const string &in contentType = "application/json"
	) {
		auto ret = Request(audience);
		ret.Method = Net::HttpMethod::Put;
		ret.Url = url;
		ret.Body = body;
		ret.Headers["Content-Type"] = contentType;
		return ret;
	}

	Net::HttpRequest@ Delete(
		const string &in audience,
		const string &in url = ""
	) {
		auto ret = Request(audience);
		ret.Method = Net::HttpMethod::Delete;
		ret.Url = url;
		return ret;
	}

	Net::HttpRequest@ Patch(
		const string &in audience,
		const string &in url = "",
		const string &in body = "",
		const string &in contentType = "application/json"
	) {
		auto ret = Request(audience);
		ret.Method = Net::HttpMethod::Patch;
		ret.Url = url;
		ret.Body = body;
		ret.Headers["Content-Type"] = contentType;
		return ret;
	}

	string GetDisplayNameAsync(const string &in accountId)
	{
		auto userMgr = GetApp().UserManagerScript;
		auto userId = userMgr.Users[0].Id;

		string ret = userMgr.FindDisplayName(accountId);
		if (ret == "") {
			MwFastBuffer<wstring> accountIds;
			accountIds.Add(accountId);

			auto req = userMgr.RetrieveDisplayName(userId, accountIds);
			while (req.IsProcessing) {
				yield();
			}
			userMgr.TaskResult_Release(req.Id);

			ret = userMgr.FindDisplayName(accountId);
		}

		return ret;
	}

	dictionary GetDisplayNamesAsync(const array<string> &in accountIds)
	{
		auto userMgr = GetApp().UserManagerScript;
		auto userId = userMgr.Users[0].Id;

		dictionary ret;

		array<string> missing;
		for (uint i = 0; i < accountIds.Length; i++) {
			string accountId = accountIds[i];
			string displayName = userMgr.FindDisplayName(accountId);
			if (displayName != "") {
				ret.Set(accountId, displayName);
			} else {
				missing.InsertLast(accountId);
			}
		}

		while (missing.Length > 0) {
			MwFastBuffer<wstring> ids;
			uint idsToAdd = Math::Min(missing.Length, 209);
			for (uint i = 0; i < idsToAdd; i++) {
				ids.Add(missing[i]);
			}

			auto req = userMgr.RetrieveDisplayName(userId, ids);
			while (req.IsProcessing) {
				yield();
			}
			userMgr.TaskResult_Release(req.Id);

			for (uint i = 0; i < idsToAdd; i++) {
				string accountId = missing[i];
				string displayName = userMgr.FindDisplayName(accountId);
				ret.Set(accountId, displayName);
			}

			missing.RemoveRange(0, idsToAdd);
		}

		return ret;
	}
}

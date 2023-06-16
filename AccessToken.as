class AccessToken : IToken
{
	string m_audience;
	string m_token;

	uint64 m_expirationTime = 0;
	bool m_refreshRequested = true;
	int m_retryTimer = 1;

	AccessToken(const string &in audience)
	{
		m_audience = audience;
	}

	string GetToken() { return m_token; }
	bool IsAuthenticated() { return m_token != ""; }

	void UpdateAsync()
	{
		if (Time::Now > m_expirationTime) {
			m_refreshRequested = true;
		}

		if (m_refreshRequested) {
			m_refreshRequested = false;

			auto app = cast<CGameManiaPlanet>(GetApp());
			auto api = app.ManiaPlanetScriptAPI;

			// Make sure we don't interrupt any existing token requests
			if (!api.Authentication_GetTokenResponseReceived) {
				trace("Waiting for existing token request to finish");
				while (!api.Authentication_GetTokenResponseReceived) {
					sleep(1000);
				}
			}

			trace("Requesting token for audience \"" + m_audience + "\"");
			api.Authentication_GetToken(api.MasterServer_MSUsers[0].Id, m_audience);
			while (!api.Authentication_GetTokenResponseReceived) {
				yield();
			}

			if (api.Authentication_ErrorCode == 0) {
				m_token = api.Authentication_Token;

				// Token should be valid for 55 minutes + some random amount of seconds. Note that
				// Nadeo's code validates it for 55 minutes. We set it to a bit later to avoid
				// potentially interrupting their code, possibly breaking the game's own authentication.
				uint64 expireMilliseconds = 55 * 60 * 1000;
				expireMilliseconds += uint64(Math::Rand(1.0f, 60.0f) * 1000.0f);
				m_expirationTime = Time::Now + expireMilliseconds;
				m_retryTimer = 1;

				trace("Got token for audience \"" + m_audience + "\"");
				return;
			}

			warn("Token authentication error " + api.Authentication_ErrorCode + "! Retrying in " + m_retryTimer + " seconds.");

			// Retry request after an increasing amount of time (1s -> 2s -> 4s -> 8s -> 16s -> ...)
			// Note this is intentionally mimicking Nadeo's code!
			m_expirationTime = Time::Now + m_retryTimer * 1000;
			m_retryTimer *= 2;
		}
	}
}

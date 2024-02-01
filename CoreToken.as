class CoreToken : IToken
{
	string GetAudience() { return "NadeoServices"; }
	string GetToken() { return Internal::NadeoServices::GetCoreToken(); }
	bool IsAuthenticated() { return true; }
	void UpdateAsync() {}
}

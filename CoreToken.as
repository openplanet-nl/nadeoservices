class CoreToken : IToken
{
	string GetToken() { return Internal::NadeoServices::GetCoreToken(); }
	bool IsAuthenticated() { return true; }
	void UpdateAsync() {}
}

interface IToken
{
	string GetAudience();
	string GetToken();
	bool IsAuthenticated();
	void UpdateAsync();
}

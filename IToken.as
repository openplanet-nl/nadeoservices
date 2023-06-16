interface IToken
{
	string GetToken();
	bool IsAuthenticated();
	void UpdateAsync();
}

namespace Tests
{
	[Test]
	void Token(Tests::Context@ ctx)
	{
		NadeoServices::AddAudience("NadeoServices");
		NadeoServices::AddAudience("NadeoLiveServices");

		ctx.AssertNotNull(NadeoServices::GetToken("NadeoServices"));
		ctx.AssertNotNull(NadeoServices::GetToken("NadeoLiveServices"));
		ctx.AssertTrue(NadeoServices::IsAuthenticated("NadeoServices"));
	}

	[Test]
	void AccountID(Tests::Context@ ctx)
	{
		ctx.AssertNotSame(NadeoServices::GetAccountID(), "");
	}

	[Test]
	void AccountIDLoginConversion(Tests::Context@ ctx)
	{
		ctx.AssertSame(NadeoServices::LoginToAccountId("c5jutptORLinoaIUmVWscA"), "7398eeb6-9b4e-44b8-a7a1-a2149955ac70");
		ctx.AssertSame(NadeoServices::AccountIdToLogin("7398eeb6-9b4e-44b8-a7a1-a2149955ac70"), "c5jutptORLinoaIUmVWscA");
		ctx.AssertSame(NadeoServices::LoginToAccountId(NadeoServices::AccountIdToLogin(NadeoServices::GetAccountID())), NadeoServices::GetAccountID());
	}
}

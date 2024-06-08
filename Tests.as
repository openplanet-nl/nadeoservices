namespace Tests
{
	[Test]
	void TestAccountIDLoginConversion(Tests::Context@ ctx)
	{
		ctx.AssertSame(NadeoServices::LoginToAccountId("c5jutptORLinoaIUmVWscA"), "7398eeb6-9b4e-44b8-a7a1-a2149955ac70");
		ctx.AssertSame(NadeoServices::AccountIdToLogin("7398eeb6-9b4e-44b8-a7a1-a2149955ac70"), "c5jutptORLinoaIUmVWscA");
	}
}

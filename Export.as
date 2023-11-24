/* // Example usage
 * void Main()
 * {
 *   // Add the audiences you need
 *   NadeoServices::AddAudience("NadeoLiveServices");
 *
 *   // Wait until the services are authenticated
 *   while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
 *     yield();
 *   }
 *
 *   // Build the API URL
 *   string url = NadeoServices::BaseURLLive() + "/api/token/campaign/month?offset=0&length=27";
 *
 *   // Create a request to the live services
 *   auto req = NadeoServices::Get("NadeoLiveServices", url);
 *
 *   // Start the request and wait for it to complete
 *   req.Start();
 *   while (!req.Finished()) {
 *     yield();
 *   }
 *   print("API response: " + req.String());
 * }
 */

namespace NadeoServices
{
	// Add the audiences you need, eg. "NadeoLiveServices" or "NadeoClubServices".
	import void AddAudience(const string &in audience) from "NadeoServices";

	// Checks if the given audience is authenticated.
	import bool IsAuthenticated(const string &in audience) from "NadeoServices";

	// Gets the currently authenticated account ID.
	import string GetAccountID() from "NadeoServices";

	// Returns the base URL for the core API. (Requires the "NadeoServices" audience)
	import string BaseURLCore() from "NadeoServices";
	// Returns the base URL for the live API. (Requires the "NadeoLiveServices" audience)
	import string BaseURLLive() from "NadeoServices";
	// Returns the base URL for the meet API. (Requires "NadeoClubServices" audience)
	import string BaseURLMeet() from "NadeoServices";

	// Returns the base URL for the club API. (Requires the "NadeoClubServices" audience)
	// DEPRECATED: Use NadeoServices::BaseURLMeet() instead.
	import string BaseURLClub() from "NadeoServices";
	// Returns the base URL for the competition API. (Requires the "NadeoClubServices" audience)
	// DEPRECATED: Use NadeoServices::BaseURLMeet() instead.
	import string BaseURLCompetition() from "NadeoServices";
	// Returns the base URL for the matchmaking API. (Requires the "NadeoClubServices" audience)
	// DEPRECATED: Use NadeoServices::BaseURLMeet() instead.
	import string BaseURLMatchmaking() from "NadeoServices";

	// Create an HTTP request object with the correct authentication header for the audience already
	// filled in. Throws an exception if the audience is not authenticated yet.
	import Net::HttpRequest@ Request(const string &in audience) from "NadeoServices";

	// Creates a GET HTTP request with the correct authentication header for the audience already
	// filled in. Throws an exception if the audience is not authenticated yet.
	import Net::HttpRequest@ Get(
		const string &in audience,
		const string &in url = ""
	) from "NadeoServices";

	// Creates a POST HTTP request with the correct authentication header for the audience already
	// filled in. Throws an exception if the audience is not authenticated yet.
	import Net::HttpRequest@ Post(
		const string &in audience,
		const string &in url = "",
		const string &in body = "",
		const string &in contentType = "application/json"
	) from "NadeoServices";

	// Creates a PUT HTTP request with the correct authentication header for the audience already
	// filled in. Throws an exception if the audience is not authenticated yet.
	import Net::HttpRequest@ Put(
		const string &in audience,
		const string &in url = "",
		const string &in body = "",
		const string &in contentType = "application/json"
	) from "NadeoServices";

	// Creates a DELETE HTTP request with the correct authentication header for the audience already
	// filled in. Throws an exception if the audience is not authenticated yet.
	import Net::HttpRequest@ Delete(
		const string &in audience,
		const string &in url = ""
	) from "NadeoServices";

	// Creates a PATCH HTTP request with the correct authentication header for the audience already
	// filled in. Throws an exception if the audience is not authenticated yet.
	import Net::HttpRequest@ Patch(
		const string &in audience,
		const string &in url = "",
		const string &in body = "",
		const string &in contentType = "application/json"
	) from "NadeoServices";

	// Gets a display name from an account ID. Must be called from a yieldable function. If you want
	// to fetch multiple display names, use `GetDisplayNamesAsync` instead, as it will be much more
	// efficient.
	import string GetDisplayNameAsync(const string &in accountId) from "NadeoServices";

	// Gets multiple display names (as `string`) from their account IDs. Must be called from a
	// yieldable function. If you want to fetch only a single display name you can also use
	// `GetDisplayNameAsync`.
	import dictionary GetDisplayNamesAsync(const array<string> &in accountIds) from "NadeoServices";
}

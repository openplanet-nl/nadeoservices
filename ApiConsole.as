#if SIG_DEVELOPER
namespace ApiConsole
{
	UI::Font@ FontMono;

	array<string> ContentTypes = {
		"application/json",
		"application/x-www-form-urlencoded",
		"text/plain",
		"text/xml"
	};

	[Setting hidden]
	bool Visible = false;

	[Setting hidden]
	bool Setting_ApiConsole_SelectableRawResponse = false;

	array<RequestData@> RoutesCore;
	array<RequestData@> RoutesLive;
	array<RequestData@> RoutesMeet;

	array<RequestData@> RoutesSaved;
	bool OpenSaveRoutePopup = false;
	string SaveRouteName = "";

	RequestData Request;

	bool Waiting = false;

	string Error = "";
	int ResponseCode = 0;
	dictionary@ ResponseHeaders;
	string ResponseRaw = "";
	string ResponsePretty = "";

	string GetBaseUrl()
	{
		switch (Request.m_base) {
			case BaseUrl::Core: return NadeoServices::BaseURLCore();
			case BaseUrl::Live: return NadeoServices::BaseURLLive();
			case BaseUrl::Meet: return NadeoServices::BaseURLMeet();
		}
		throw("Invalid base URL type");
		return "";
	}

	string GetAudience()
	{
		switch (Request.m_base) {
			case BaseUrl::Core: return "NadeoServices";
			case BaseUrl::Live: return "NadeoLiveServices";
			case BaseUrl::Meet: return "NadeoLiveServices";
		}
		throw("Invalid base URL type");
		return "";
	}

	void Initialize()
	{
		@FontMono = UI::LoadFont("DroidSansMono.ttf", 16);

		RoutesCore = LoadRequestDataList(Json::FromFile("ApiConsoleRoutesCore.json"));
		RoutesLive = LoadRequestDataList(Json::FromFile("ApiConsoleRoutesLive.json"));
		RoutesMeet = LoadRequestDataList(Json::FromFile("ApiConsoleRoutesMeet.json"));

		auto jsSavedRoutes = Json::FromFile(IO::FromStorageFolder("SavedRoutes.json"));
		if (jsSavedRoutes.GetType() == Json::Type::Array) {
			RoutesSaved = LoadRequestDataList(jsSavedRoutes);
		}
	}

	void WriteSavedRoutes()
	{
		SaveRequestDataList(RoutesSaved, IO::FromStorageFolder("SavedRoutes.json"));
	}

	void Render()
	{
		if (!Visible) {
			return;
		}

		UI::SetNextWindowSize(1500, 600);
		if (UI::Begin("\\$f93" + Icons::Ticket + "\\$z Nadeo API Console###NadeoAPIConsole", Visible, UI::WindowFlags::NoCollapse | UI::WindowFlags::MenuBar)) {
			RenderMenuBar();
			RenderRequestBar();

			UI::Columns(2);
			RenderRequest();
			UI::NextColumn();
			if (ResponseCode != 0) {
				RenderResponse();
			}
			UI::Columns(1);

			RenderSavedRoutePopup();
		}
		UI::End();
	}

	void RenderMenuBar()
	{
		if (UI::BeginMenuBar()) {
			if (UI::BeginMenu("Settings")) {
				if (UI::MenuItem("Selectable raw response", "", Setting_ApiConsole_SelectableRawResponse)) {
					Setting_ApiConsole_SelectableRawResponse = !Setting_ApiConsole_SelectableRawResponse;
				}
				UI::SetItemTooltip(
					"This makes the raw response selectable so it can be more easily copied. Due to a\n"
					"limitation in ImGui, this does not enable word wrapping, so is disabled by default.");
				UI::EndMenu();
			}

			if (UI::BeginMenu("Routes")) {
				if (UI::MenuItem("Clear current request")) {
					Request.Clear();
				}
				UI::Separator();
				RenderMenuRoutes("Core", RoutesCore);
				RenderMenuRoutes("Live", RoutesLive);
				RenderMenuRoutes("Meet", RoutesMeet);
				UI::Separator();
				RenderMenuSavedRoutes();
				if (UI::MenuItem(Icons::PlusCircle + " Save current request")) {
					OpenSaveRoutePopup = true;
				}
				UI::EndMenu();
			}

			if (UI::BeginMenu("Help")) {
				if (UI::MenuItem(Icons::QuestionCircle + " Web Services Documentation")) {
					OpenBrowserURL("https://webservices.openplanet.dev/");
				}
				UI::Separator();
				if (UI::MenuItem(Icons::Discord + " Openplanet Discord")) {
					OpenBrowserURL("https://openplanet.dev/link/discord");
				}
				UI::EndMenu();
			}

			UI::EndMenuBar();
		}
	}

	void RenderMenuRoutes(const string &in name, const array<RequestData@> &in routes)
	{
		if (UI::BeginMenu(name, routes.Length > 0)) {
			for (uint i = 0; i < routes.Length; i++) {
				auto route = routes[i];

				string name = route.m_name;
				if (name.Length == 0) {
					name = route.m_path;
				}

				if (UI::MenuItem(name + "##route" + i)) {
					Request = route;
				}
			}
			UI::EndMenu();
		}
	}

	void RenderMenuSavedRoutes()
	{
		if (UI::BeginMenu(Icons::Star + " Saved routes", RoutesSaved.Length > 0)) {
			for (uint i = 0; i < RoutesSaved.Length; i++) {
				auto route = RoutesSaved[i];

				string name = route.m_name;
				if (name.Length == 0) {
					name = route.m_path;
				}

				if (UI::BeginMenu(name + "##route" + i)) {
					if (UI::MenuItem("\\$f93" + Icons::FolderOpen + "\\$z Load route")) {
						Request = route;
					}
					UI::Separator();
					if (UI::MenuItem(Icons::FloppyO + " Overwrite with current")) {
						string name = route.m_name;
						route = Request;
						route.m_name = name;
						WriteSavedRoutes();
					}
					if (UI::MenuItem(Icons::MinusCircle + " Delete route")) {
						RoutesSaved.RemoveAt(i);
						WriteSavedRoutes();
					}
					UI::EndMenu();
				}
			}
			UI::EndMenu();
		}
	}

	void RenderRequestBar()
	{
		UI::BeginDisabled(Waiting);
		UI::SetNextItemWidth(100);
		if (UI::BeginCombo("##BaseURLType", tostring(Request.m_base))) {
			for (int i = 0; i < 3; i++) {
				if (UI::Selectable(tostring(BaseUrl(i)), Request.m_base == BaseUrl(i))) {
					Request.m_base = BaseUrl(i);
				}
			}
			UI::EndCombo();
		}
		UI::SameLine();
		UI::SetNextItemWidth(100);
		if (UI::BeginCombo("##RequestMethod", tostring(Request.m_method).ToUpper())) {
			for (int i = 0; i < 6; i++) {
				if (UI::Selectable(tostring(Net::HttpMethod(i)).ToUpper(), Request.m_method == Net::HttpMethod(i))) {
					Request.m_method = Net::HttpMethod(i);
				}
			}
			UI::EndCombo();
		}
		UI::SameLine();
		UI::PushFont(FontMono);
		UI::TextDisabled(GetBaseUrl());
		UI::SameLine();
		UI::SetNextItemWidth(UI::GetContentRegionAvail().x - 60);
		bool pressedEnter = false;
		Request.m_path = UI::InputText("##PathInput", Request.m_path, pressedEnter, UI::InputTextFlags::EnterReturnsTrue);
		UI::PopFont();
		UI::SameLine();
		if (UI::ButtonColored(Icons::ArrowRight, 0.05f, 0.6f, 0.6f, vec2(UI::GetContentRegionAvail().x, 0)) || pressedEnter) {
			startnew(StartRequestAsync);
		}
		UI::EndDisabled();
	}

	void RenderRequest()
	{
		UI::BeginTabBar("RequestTabs");

		if (UI::BeginTabItem(Icons::Link + " Request query")) {
			Request.m_query.Render();
			UI::EndTabItem();
		}

		if (UI::BeginTabItem(Icons::Kenney::List + " Request headers")) {
			Request.m_headers.Render();
			UI::EndTabItem();
		}

		if (RequestMethodAcceptsData(Request.m_method) && UI::BeginTabItem(Icons::Code + " Request body")) {
			if (UI::BeginCombo("Content type", Request.m_contentType)) {
				for (uint i = 0; i < ContentTypes.Length; i++) {
					string contentType = ContentTypes[i];
					if (UI::Selectable(contentType, Request.m_contentType == contentType)) {
						Request.m_contentType = contentType;
					}
				}
				UI::EndCombo();
			}
			Request.m_body = UI::InputTextMultiline("##RequestBody", Request.m_body, UI::GetContentRegionAvail());
			UI::EndTabItem();
		}

		UI::EndTabBar();
	}

	void RenderResponse()
	{
		UI::BeginTabBar("ResponseTabs");

		if (UI::BeginTabItem(Icons::Kenney::List + " Response headers")) {
			if (UI::BeginChild("Container")) {
				UI::Text("Response code \\$f93" + ResponseCode);
				UI::PushFont(FontMono);
				auto keys = ResponseHeaders.GetKeys();
				for (uint i = 0; i < keys.Length; i++) {
					string key = keys[i];
					string value;
					ResponseHeaders.Get(key, value);
					UI::Text("\\$f93" + key + "\\$z: " + value);
				}
				UI::PopFont();
				UI::EndChild();
			}
			UI::EndTabItem();
		}

		if (ResponsePretty.Length > 0 && UI::BeginTabItem(Icons::FileTextO + " Pretty response")) {
			UI::PushFont(FontMono);
			UI::InputTextMultiline("##ResponsePretty", ResponsePretty, UI::GetContentRegionAvail(), UI::InputTextFlags::ReadOnly);
			UI::PopFont();
			UI::EndTabItem();
		}

		if (UI::BeginTabItem(Icons::FileO + " Raw response")) {
			UI::PushFont(FontMono);
			if (Setting_ApiConsole_SelectableRawResponse) {
				UI::InputTextMultiline("##ResponseRaw", ResponseRaw, UI::GetContentRegionAvail(), UI::InputTextFlags::ReadOnly);
			} else {
				if (UI::BeginChild("Container")) {
					UI::TextWrapped(ResponseRaw);
					UI::EndChild();
				}
			}
			UI::PopFont();
			UI::EndTabItem();
		}

		UI::EndTabBar();
	}

	void RenderSavedRoutePopup()
	{
		if (OpenSaveRoutePopup) {
			OpenSaveRoutePopup = false;
			SaveRouteName = "";
			UI::OpenPopup("Save current request");
		}

		UI::SetNextWindowSize(0, 0);
		if (UI::BeginPopupModal("Save current request", UI::WindowFlags::NoSavedSettings | UI::WindowFlags::NoResize)) {
			bool pressedEnter = false;
			UI::Text("Please enter a name for this route:");
			if (UI::IsWindowAppearing()) {
				UI::SetKeyboardFocusHere();
			}
			UI::SetNextItemWidth(250);
			SaveRouteName = UI::InputText("##SaveRouteName", SaveRouteName, pressedEnter, UI::InputTextFlags::EnterReturnsTrue);
			if (UI::ButtonColored(Icons::FloppyO + " Save", 0.4f) || pressedEnter) {
				RequestData@ newRequest = RequestData();
				newRequest = Request;
				newRequest.m_name = SaveRouteName;
				RoutesSaved.InsertLast(newRequest);
				WriteSavedRoutes();
				UI::CloseCurrentPopup();
			}
			UI::SameLine();
			if (UI::Button("Cancel")) {
				UI::CloseCurrentPopup();
			}
			UI::EndPopup();
		}
	}

	bool RequestMethodAcceptsData(Net::HttpMethod method)
	{
		switch (method) {
			case Net::HttpMethod::Post:
			case Net::HttpMethod::Put:
			case Net::HttpMethod::Patch:
				return true;
		}
		return false;
	}

	void StartRequestAsync()
	{
		if (Waiting) {
			error("Request still pending");
			return;
		}

		if (!Request.m_path.StartsWith("/")) {
			Error = "Request path should start with a forward slash (/).";
			return;
		}

		auto req = NadeoServices::Request(GetAudience());
		req.Method = Request.m_method;

		for (uint i = 0; i < Request.m_headers.Length; i++) {
			auto item = Request.m_headers[i];
			req.Headers.Set(item.m_key, item.m_value);
		}

		req.Headers.Set("Content-Type", Request.m_contentType);
		if (RequestMethodAcceptsData(Request.m_method)) {
			req.Body = Request.m_body;
		}

		req.Url = GetBaseUrl() + Request.m_path;
		for (uint i = 0; i < Request.m_query.Length; i++) {
			auto item = Request.m_query[i];
			if (i == 0) {
				req.Url += "?";
			} else {
				req.Url += "&";
			}
			req.Url += item.m_key + "=" + Net::UrlEncode(item.m_value);
		}

		req.Start();

		Waiting = true;

		Error = "";
		ResponseCode = 0;
		ResponseRaw = "";
		@ResponseHeaders = null;
		ResponsePretty = "";

		while (!req.Finished()) {
			yield();
		}

		Error = req.Error();
		ResponseCode = req.ResponseCode();
		@ResponseHeaders = req.ResponseHeaders();

		ResponseRaw = req.String();

		string headerContentType;
		ResponseHeaders.Get("content-type", headerContentType);
		if (headerContentType != "") {
			if (headerContentType == "application/json") {
				ResponsePretty = Json::Write(req.Json(), true);
			}
		}

		Waiting = false;
	}
}
#endif

#if SIG_DEVELOPER
namespace ApiConsole
{
	enum BaseUrl
	{
		Core,
		Live,
		Meet,
	}

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

	BaseUrl BaseUrlType = BaseUrl::Core;
	Net::HttpMethod RequestMethod = Net::HttpMethod::Get;
	string RequestPath = "/api/routes";
	dictionary RequestQuery;
	dictionary RequestHeaders;
	string RequestContentType = "application/json";
	string RequestBody = "{}";

	bool Waiting = false;

	string AddQuery_Key = "";
	string AddQuery_Value = "";

	string AddHeader_Key = "";
	string AddHeader_Value = "";

	string Error = "";
	int ResponseCode = 0;
	dictionary@ ResponseHeaders;
	string ResponseRaw = "";
	string ResponsePretty = "";

	string GetBaseUrl()
	{
		switch (BaseUrlType) {
			case BaseUrl::Core: return NadeoServices::BaseURLCore();
			case BaseUrl::Live: return NadeoServices::BaseURLLive();
			case BaseUrl::Meet: return NadeoServices::BaseURLMeet();
		}
		throw("Invalid base URL type");
		return "";
	}

	string GetAudience()
	{
		switch (BaseUrlType) {
			case BaseUrl::Core: return "NadeoServices";
			case BaseUrl::Live: return "NadeoLiveServices";
			case BaseUrl::Meet: return "NadeoLiveServices";
		}
		throw("Invalid base URL type");
		return "";
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
				if (UI::BeginMenu("Core")) {
					//TODO
					UI::EndMenu();
				}
				if (UI::BeginMenu("Live")) {
					//TODO
					UI::EndMenu();
				}
				if (UI::BeginMenu("Meet")) {
					//TODO
					UI::EndMenu();
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

	void RenderRequestBar()
	{
		UI::BeginDisabled(Waiting);
		UI::SetNextItemWidth(100);
		if (UI::BeginCombo("##BaseURLType", tostring(BaseUrlType))) {
			for (int i = 0; i < 3; i++) {
				if (UI::Selectable(tostring(BaseUrl(i)), BaseUrlType == BaseUrl(i))) {
					BaseUrlType = BaseUrl(i);
				}
			}
			UI::EndCombo();
		}
		UI::SameLine();
		UI::SetNextItemWidth(100);
		if (UI::BeginCombo("##RequestMethod", tostring(RequestMethod).ToUpper())) {
			for (int i = 0; i < 6; i++) {
				if (UI::Selectable(tostring(Net::HttpMethod(i)).ToUpper(), RequestMethod == Net::HttpMethod(i))) {
					RequestMethod = Net::HttpMethod(i);
				}
			}
			UI::EndCombo();
		}
		UI::SameLine();
		UI::TextDisabled(GetBaseUrl());
		UI::SameLine();
		UI::SetNextItemWidth(UI::GetContentRegionAvail().x - 60);
		UI::SameLine();
		bool pressedEnter = false;
		RequestPath = UI::InputText("##PathInput", RequestPath, pressedEnter, UI::InputTextFlags::EnterReturnsTrue);
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
			AddQuery_Key = UI::InputText("Key", AddQuery_Key);
			AddQuery_Value = UI::InputText("Value", AddQuery_Value);
			if (UI::ButtonColored(Icons::PlusCircle + " Add query parameter", 0.4f)) {
				if (AddQuery_Key != "" && AddQuery_Value != "") {
					RequestQuery.Set(AddQuery_Key, AddQuery_Value);
					AddQuery_Key = "";
					AddQuery_Value = "";
				}
			}
			UI::SameLine();
			if (UI::Button("Clear all query")) {
				RequestQuery.DeleteAll();
			}

			UI::SeparatorTextOpenplanet("Query variables");
			if (UI::BeginChild("Container")) {
				auto keys = RequestQuery.GetKeys();
				for (uint i = 0; i < keys.Length; i++) {
					string key = keys[i];
					string value;
					RequestQuery.Get(key, value);
					UI::PushID(key);
					if (UI::ButtonColored(Icons::MinusCircle, 0)) {
						RequestQuery.Delete(key);
					}
					UI::SameLine();
					UI::Text("\\$f93" + key + "\\$z: " + value);
					UI::PopID();
				}
				UI::EndChild();
			}
			UI::EndTabItem();
		}

		if (UI::BeginTabItem(Icons::Kenney::List + " Request headers")) {
			AddHeader_Key = UI::InputText("Key", AddHeader_Key);
			AddHeader_Value = UI::InputText("Value", AddHeader_Value);
			if (UI::ButtonColored(Icons::PlusCircle + " Add header", 0.4f)) {
				if (AddHeader_Key != "" && AddHeader_Value != "") {
					RequestHeaders.Set(AddHeader_Key, AddHeader_Value);
					AddHeader_Key = "";
					AddHeader_Value = "";
				}
			}
			UI::SameLine();
			if (UI::Button("Clear all headers")) {
				RequestHeaders.DeleteAll();
			}

			UI::SeparatorTextOpenplanet("Request headers");
			if (UI::BeginChild("Container")) {
				auto keys = RequestHeaders.GetKeys();
				for (uint i = 0; i < keys.Length; i++) {
					string key = keys[i];
					string value;
					RequestHeaders.Get(key, value);
					UI::PushID(key);
					if (UI::ButtonColored(Icons::MinusCircle, 0)) {
						RequestHeaders.Delete(key);
					}
					UI::SameLine();
					UI::Text("\\$f93" + key + "\\$z: " + value);
					UI::PopID();
				}
				UI::EndChild();
			}
			UI::EndTabItem();
		}

		if (RequestMethodAcceptsData(RequestMethod) && UI::BeginTabItem(Icons::Code + " Request body")) {
			if (UI::BeginCombo("Content type", RequestContentType)) {
				for (uint i = 0; i < ContentTypes.Length; i++) {
					string contentType = ContentTypes[i];
					if (UI::Selectable(contentType, RequestContentType == contentType)) {
						RequestContentType = contentType;
					}
				}
				UI::EndCombo();
			}
			RequestBody = UI::InputTextMultiline("##RequestBody", RequestBody, UI::GetContentRegionAvail());
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
				UI::PushFont(g_fontMono);
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
			UI::PushFont(g_fontMono);
			UI::InputTextMultiline("##ResponsePretty", ResponsePretty, UI::GetContentRegionAvail(), UI::InputTextFlags::ReadOnly);
			UI::PopFont();
			UI::EndTabItem();
		}

		if (UI::BeginTabItem(Icons::FileO + " Raw response")) {
			UI::PushFont(g_fontMono);
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

		if (!RequestPath.StartsWith("/")) {
			Error = "Request path should start with a forward slash (/).";
			return;
		}

		auto req = NadeoServices::Request(GetAudience());
		req.Method = RequestMethod;

		auto requestHeaderKeys = RequestHeaders.GetKeys();
		for (uint i = 0; i < requestHeaderKeys.Length; i++) {
			string key = requestHeaderKeys[i];
			string value;
			RequestHeaders.Get(key, value);
			req.Headers.Set(key, value);
		}

		req.Headers.Set("Content-Type", RequestContentType);
		if (RequestMethodAcceptsData(RequestMethod)) {
			req.Body = RequestBody;
		}

		req.Url = GetBaseUrl() + RequestPath;
		auto requestQueryKeys = RequestQuery.GetKeys();
		for (uint i = 0; i < requestQueryKeys.Length; i++) {
			string key = requestQueryKeys[i];
			string value;
			RequestQuery.Get(key, value);
			if (i == 0) {
				req.Url += "?";
			} else {
				req.Url += "&";
			}
			req.Url += key + "=" + Net::UrlEncode(value);
		}
		print(req.Url);

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

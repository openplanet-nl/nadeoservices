#if SIG_DEVELOPER
namespace ApiConsole
{
	class KeyedListItem
	{
		string m_key;
		string m_value;

		KeyedListItem() {}
		KeyedListItem(const string &in key, const string &in value)
		{
			m_key = key;
			m_value = value;
		}
	}

	class KeyedList
	{
		array<KeyedListItem@> m_items;

		uint get_Length() { return m_items.Length; }
		KeyedListItem@ opIndex(uint index) { return m_items[index]; }

		void Render()
		{
			if (UI::ButtonColored(Icons::PlusCircle + " Add item", 0.4f)) {
				m_items.InsertLast(KeyedListItem());
			}
			UI::SameLine();
			if (UI::ButtonColored("Clear all", 0)) {
				m_items.RemoveRange(0, m_items.Length);
			}

			if (UI::BeginChild("Container")) {
				vec2 spacing = UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing);
				float w = (UI::GetContentRegionAvail().x - 40 - spacing.x * 2) / 2.0f;
				for (uint i = 0; i < m_items.Length; i++) {
					auto item = m_items[i];
					UI::PushID("item" + i);
					UI::SetNextItemWidth(w);
					item.m_key = UI::InputText("##Key", item.m_key);
					UI::SameLine();
					UI::SetNextItemWidth(w);
					item.m_value = UI::InputText("##Value", item.m_value);
					UI::SameLine();
					if (UI::ButtonColored(Icons::MinusCircle, 0)) {
						m_items.RemoveAt(i);
					}
					UI::PopID();
				}
				UI::EndChild();
			}
		}

		void Clear()
		{
			m_items.RemoveRange(0, m_items.Length);
		}

		void FromJson(const Json::Value@ js)
		{
			Clear();

			if (js is null) {
				return;
			}

			auto keys = js.GetKeys();
			for (uint j = 0; j < keys.Length; j++) {
				string key = keys[j];
				string value = js[key];
				m_items.InsertLast(KeyedListItem(key, value));
			}
		}

		Json::Value@ ToJson()
		{
			auto ret = Json::Object();
			for (uint i = 0; i < m_items.Length; i++) {
				auto item = m_items[i];
				ret[item.m_key] = item.m_value;
			}
			return ret;
		}
	}
}
#endif

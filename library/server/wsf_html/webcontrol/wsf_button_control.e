note
	description: "Summary description for {WSF_BUTTON_CONTROL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WSF_BUTTON_CONTROL

inherit

	WSF_CONTROL

create
	make

feature {NONE}

	make (n: STRING; v: STRING)
		do
			control_name := n
			text := v
			click_event := agent donothing
		end

feature {WSF_PAGE_CONTROL, WSF_CONTROL} -- STATE MANAGEMENT

	set_state (new_state: JSON_OBJECT)
		do
			if attached {JSON_STRING} new_state.item (create {JSON_STRING}.make_json ("text")) as new_text then
				text := new_text.unescaped_string_32
			end
		end

	state: JSON_OBJECT
		do
			create Result.make
			Result.put (create {JSON_STRING}.make_json (text), create {JSON_STRING}.make_json ("text"))
		end

feature --EVENT HANDLING

	donothing (p: WSF_PAGE_CONTROL) --UGLY HACK MUST BE REMOVED
		do
		end

	set_click_event (e: PROCEDURE [ANY, TUPLE [WSF_PAGE_CONTROL]])
		do
			click_event := e
		end

	handle_callback (cname: STRING; event: STRING; page: WSF_PAGE_CONTROL)
		do
			if Current.control_name.is_equal (cname) and attached click_event then
				click_event.call ([page])
			end
		end

feature

	render: STRING
		do
			Result := "<button data-name=%"" + control_name + "%" data-type=%"WSF_BUTTON_CONTROL%">" + text + "</button>"
		end

	set_text (t: STRING)
		do
			text := t
		end

feature

	text: STRING

	click_event: PROCEDURE [ANY, TUPLE [WSF_PAGE_CONTROL]]

end

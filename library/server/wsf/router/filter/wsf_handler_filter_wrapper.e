note
	description: "[
				Handler wrapping a filter
			]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WSF_HANDLER_FILTER_WRAPPER

inherit
	WSF_HANDLER

create
	make_with_filter

feature {NONE} -- Initialization

	make_with_filter (f: WSF_FILTER)
		do
			filter := f
		end

feature -- Access

	filter: WSF_FILTER

feature -- Execution

	execute (req: WSF_REQUEST; res: WSF_RESPONSE)
		do
			filter.execute (req, res)
		end

note
	copyright: "2011-2013, Jocelyn Fiat, Javier Velilla, Olivier Ligot, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
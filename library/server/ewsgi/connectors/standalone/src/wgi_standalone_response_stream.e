note
	description: "[
			WGI Response implemented using stream buffer
			for the standalone Eiffel web server connector.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	WGI_STANDALONE_RESPONSE_STREAM

inherit
	WGI_RESPONSE_STREAM
		redefine
			put_header_text
		end

create
	make

feature -- Header output operation		

	put_header_text (a_text: READABLE_STRING_8)
		local
			o: like output
		do
			o := output
			o.put_string (a_text)

			if not {HTTPD_SERVER}.is_persistent_connection_supported then
					-- standalone does not support persistent connection for now
				o.put_string ("Connection: close")
				o.put_crlf
			end

			-- end of headers
			o.put_crlf

			header_committed := True
		end

;note
	copyright: "2011-2015, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end

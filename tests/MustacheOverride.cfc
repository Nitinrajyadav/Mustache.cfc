component extends="mustache.Mustache" {

	/**
	 * Encodes a plain text string (can be overridden)
	 */
	private function textEncode(input, options) output=false {
		// check the options 
		if ( structKeyExists(arguments.options, "useDefault") && arguments.options.useDefault ) {
			return super.textEncode(argumentCollection=arguments);
		}
		return "`" & arguments.input & "`";
	}

	/**
	 * Encodes a string into HTML (can be overridden)
	 */
	private function htmlEncode(input, options) output=false {
		// check the options
		if ( structKeyExists(arguments.options, "useDefault") && arguments.options.useDefault ) {
			return super.htmlEncode(argumentCollection=arguments);
		}
		return "|" & arguments.input & "|";
	}

}

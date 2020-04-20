/* 
	This extension to Mustache provides the following functionality:

	1) It adds C-template-style "modifiers" (or formatters). You can now use the following
	   syntax with your variables:

	   Hello "{{NAME:leftPad(20):upperCase}}"

	   This would output the "NAME" variable, left justify it's output to 20 characters and
	   make the string upper case.

	   The idea is to provide a collection of common formatter functions, but a user could
	   extend this component to add in their own user formatters.

	   This method provides is more readable and easy to implement over the lambda functionality
	   in the default Mustache syntax.
*/
component extends="Mustache" output="false" {
	/**
	 * the only difference to the original RegEx is I capture the ".*" match 
	 * Explanation : 
	 *  https://jex.im/regulex/#!flags=&re=%5C%7B%5C%7B(!%7C%5C%7B%7C%26%7C%5C%3E)%3F%5Cs*(%5Cw%2B)(.*%3F)%5C%7D%3F%5C%7D%5C%7D
	 * 
	 * Examples: TODO
	 * 
	*/
	variables.TagRegEx = CreateObject("java","java.util.regex.Pattern").compile("\{\{(!|\{|&|\>)?\s*(\w+)(.*?)\}?\}\}", 32);

	/**
	 * captures arguments to be passed to formatter functions
	 * 
	 * Explanation: 
	 *  https://jex.im/regulex/#!flags=&re=%5B%5E%5Cs%2C%5D*(%3F%3C!%5C%5C)%5C(.*%3F(%3F%3C!%5C%5C)%5C)%7C(%3F%3C!%5C%5C)%5C%5B.*%3F(%3F%3C!%5C%5C)%5C%5D%7C(%3F%3C!%5C%5C)%5C%7B.*%3F(%3F%3C!%5C%5C)%5C%7D%7C(%3F%3C!%5C%5C)('%7C%22%22).*%3F(%3F%3C!%5C%5C)%5C1%7C(%3F%3A(%3F!%2C)%5CS)%2B
	 * 
	 * Examples: TODO
	 * 
	 */
	variables.Mustache.ArgumentsRegEx = createObject("java","java.util.regex.Pattern").compile("[^\s,]*(?<!\\)\(.*?(?<!\\)\)|(?<!\\)\[.*?(?<!\\)\]|(?<!\\)\{.*?(?<!\\)\}|(?<!\\)('|"").*?(?<!\\)\1|(?:(?!,)\S)+", 40);
	
	// overwrite the default methods
	private function onRenderTag(rendered, options) {
		var results = arguments.rendered;
		if ( !structKeyExists(arguments.options, "extra") || !len(arguments.options.extra) ) {
			return results;
		}
		
		var extras = listToArray(arguments.options.extra, ":");
		
		// look for functional calls (see #2)
		for ( var fn in extras ) {
			
			// all formatting functions start with two underscores
			fn = trim("__" & fn);
			var fnName = listFirst(fn, "(");

			// check to see if we have a function matching this fn name 
			if ( structKeyExists(variables, fnName) && isCustomFunction(variables[fnName]) ) {
				
				var args = [];
				// get the arguments (but ignore empty arguments)
				if ( reFind("\([^\)]+\)", fn) ) {
					// get the arguments from the function name
					args = replace(fn, fnName & "(", "");
					// gets the arguments from the string
					args = regexMatch(left(args, len(args)-1), variables.Mustache.ArgumentsRegEx);
				} 

				var invokeArgs = { name= 1, value= results };
				for(var i=2; i<=ArrayLen(args); i++){
					invokeArgs[name] = i;
					invokeArgs[value] = trim(args[i]);
				}

				// we'll call each function in a series, the output of one function will be the input in the next 
				results =  Invoke(method= fnName, arguments= invokeArgs );
			}
		}
		return results;
	}

	private function regexMatch(text, re) {
		var results = [];
		var matcher = arguments.re.matcher(arguments.text);
		while ( matcher.find() ) {
			ArrayAppend(results, matcher.group() ?: '');
		}
		return results;
	}


	/* 
		MUSTACHE FUNCTIONS 

		the first argument of these function will always the text being processed, 
		and the user inputs will be anything after the 2nd argument(inclusive)
	*/

	private function __leftPad(string value, numeric length) {
		return lJustify(arguments.value, arguments.length);
	}

	private function __rightPad(string value, numeric length) {
		return rJustify(arguments.value, arguments.length);
	}

	private function __upperCase(string value) {
		return ucase(arguments.value);
	}

	private function __lowerCase(string value) {
		return lcase(arguments.value);
	}

	private function __multiply(numeric num1, numeric num2) {
		return arguments.num1 * arguments.num2;
	}

}

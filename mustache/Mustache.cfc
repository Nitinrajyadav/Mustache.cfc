/* 
	Mustache.cfc

	This component is a ColdFusion implementation of the Mustache logic-less tempesting language (see http://mustache.github.com/.)

	Key features of this implementation: 
	* Enhanced whitespace management - extra whitespace around conditional output is automatically removed
	* Partials
	* Multi-line comments
	* And can be extended via the onRenderTag event to add additional rendering logic

	       Homepage: https: //github.com/rip747/Mustache.cfc
	Source Code    : https: //github.com/rip747/Mustache.cfc.git
	       NOTES   : 
	reference for string building
	http: //www.aliaspooryorik.com/blog/index.cfm/e/posts.details/post/string-concatenation-performance-test-128
*/
component output="false" {
	// namespace for Mustache private variables (to avoid name collisions when extending Mustache.cfc) 
	variables.Mustache         = {};
	variables.Mustache.Pattern = createObject("java","java.util.regex.Pattern");
	
	/**
	 * captures the ".*" match for looking for formatters (see #2) 
	 * and also allows nested structure references (see #3), removes looking for comments 
	 * 
	 * Explanation: 
	 *      ->  start with  '{{', 
	 * $1   ->  either none or one of " {, &, <",  
	 *      ->  0 or more times "white space"
	 * $2   ->  either a "." (self),  "one word",  or "dot concatenated words" (property-identifier)
	 * $3   ->  0 or more times "any char except a new line"
	 *      ->  0 or 1 "}"
	 *      ->  ends with "}}"
	 * 
	 * Examples: TODO: 
	 * 
	 * 
	 */ 
	variables.Mustache.TagRegEx = variables.Mustache.Pattern.compile("\{\{(\{|&|\>)?\s*((?:\w+(?:(?:\.\w+){1,})?)|\.)(.*?)\}?\}\}", 32);

	/**
	 * Partial regex
	 * 
	 * Explanation: 
	 *      ->  start with  '{{<', 
	 *      ->  0 or more times "white space"
	 * $1   ->  either a "." (self),  "one word",  or "dot concatenated words" (property-identifier)
	 * $2   ->  0 or more times "any char except a new line"
	 *      ->  0 or 1 "}"
	 *      ->  ends with "}}"
	 * 
	 * Examples: TODO: 
	 * 
	 * 
	 */ 
	variables.Mustache.PartialRegEx = variables.Mustache.Pattern.compile("\{\{\>\s*((?:\w+(?:(?:\.\w+){1,})?)|\.)(.*?)\}?\}\}", 32);
	
	/**
	 * captures nested structure references
	 * 
	 * Explanation: 
	 * see https  : //jex.im/regulex/#!flags=&re=%5C%7B%5C%7B%5Cs*(%23%23%7C%5C%5E)%5Cs*(%5Cw%2B(%3F%3A(%3F%3A%5C.%5Cw%2B)%7B1%2C%7D)%3F)%5Cs*%7D%7D(.*%3F)%5C%7B%5C%7B%5Cs*%2F%5Cs*%5C2%5Cs*%5C%7D%5C%7D
	 * 
	 *      ->  start with  '{{', 
	 *      ->  0 or more times "white space"
	 * $1   ->  either a "##" or "^"
	 * 	    ->  0 or more times "white space"
	 * $2   ->  either "one word",  or "dot concatenated words" (property-identifier)
	 *      ->  0 or more times "white space"
	 *      ->  "}}"
	 *      ->  ends with "}}"
	 * $3   ->  0 or more times "any char except a new line"
	 *      ->  "{{""
	 *      ->  0 or more times "white space"
	 *      ->  "/"
	 *      ->  0 or more times "white space"
	 *      -> back-reference to $2
	 *      ->  0 or more times "white space"
	 *      ->  ends with "}}"
	 * 
	 * Examples: TODO: 
	 * 
	 * 
	 */
	variables.Mustache.SectionRegEx = variables.Mustache.Pattern.compile("\{\{\s*(##|\^)\s*(\w+(?:(?:\.\w+){1,})?)\s*}}(.*?)\{\{\s*/\s*\2\s*\}\}", 32);
	
	
	/**
	 * captures nested structure references
	 * 
	 * Explanation: 
	 * see https  : //jex.im/regulex/#!flags=&re=((%5E%5Cr%3F%5Cn%3F)%7C%5Cs%2B)%3F%5C%7B%5C%7B!.*%3F%5C%7D%5C%7D(%5Cr%3F%5Cn%3F(%5Cr%3F%5Cn%3F)%3F)%3F
	 * 
	 * 
	 * Examples: TODO: 
	 * 
	 * 
	 */ 
	variables.Mustache.CommentRegEx = variables.Mustache.Pattern.compile("((^\r?\n?)|\s+)?\{\{!.*?\}\}(\r?\n?(\r?\n?)?)?", 40);
	
	/**
	 * captures nested structure references
	 * 
	 * Explanation: 
	 * see https  : //jex.im/regulex/#!flags=&re=(%5E(%5Cr%3F%5Cn))%7C((%3F%3C!(%5Cr%3F%5Cn))(%5Cr%3F%5Cn)%24)
	 * 
	 * Examples: TODO: 
	 * 
	 * 
	 */ 
	variables.Mustache.HeadTailBlankLinesRegEx = variables.Mustache.Pattern.compile(javaCast("string", "(^(\r?\n))|((?<!(\r?\n))(\r?\n)$)"), 32);
	
	// for tracking partials 
	variables.Mustache.partials = {};
	
	// Raising Errors 
	variables.Mustache.RaiseErrors = "true";





	public function init(partials={}, raiseErrors="true") {
		setPartials(arguments.partials);
		setRaiseErrors(arguments.RaiseErrors);
		return this;
	}




	/**
	 * main function to call to a new template
	 * 
	 * @template struct,                = {}
	 * @context  instance on Mustache = this
	 * @partials {struct}             = {}
	 * @options  {struct}             = {}
	 */
	public function render(
		         template = readMustacheFile( ListLast( getMetaData(this).name, '.') ),
		         context  = this,
		required partials = {},
		         options  = {}
	) {
		//  Replace partials in template 
		    arguments.template = replacePartialsInTemplate(arguments.template,arguments.partials);
		var results            = renderFragment(argumentCollection=arguments);
		//  remove single blank lines at the head/tail of the stream 
		results = variables.Mustache.HeadTailBlankLinesRegEx.matcher(javaCast("string", results)).replaceAll("");
		return results;
	}

	/**
	 * @author NoAuthor
	 * NoFunctionDescription
	 * 
	 * @template !{} 
	 * @partials !{} 
	 */
	private function replacePartialsInTemplate(template, partials) {
		var matches = ReFindNoCaseValues(arguments.template, variables.Mustache.PartialRegEx);
		if (ArrayLen(matches)) {
			var partial = getPartial(Trim(matches[2]), arguments.partials);
			var result  = ReplaceNoCase(arguments.template, matches[1], partial);
		} else {
			var result = arguments.template;
		}
		return result;
	}

	/**
	 * handles all the various fragments of the template
	 */
	private function renderFragment(template, context, partials, options) {
		//  clean the comments from the template 
		arguments.template = variables.Mustache.CommentRegEx.matcher(javaCast("string", arguments.template)).replaceAll("$3");

		StructAppend(arguments.partials, variables.Mustache.partials, false);
		arguments.template = renderSections(arguments.template, arguments.context, arguments.partials, arguments.options);
		return renderTags(arguments.template, arguments.context, arguments.partials, arguments.options);
	}

	private function renderSections(template, context, partials, options) {
		var lastSectionPosition = -1;

		while ( true ) {
			var matches = ReFindNoCaseValues(arguments.template, variables.Mustache.SectionRegEx);
			if ( arrayLen(matches) == 0 )  break;
			
			var tag      = matches[1];
			var type     = matches[2];
			var tagName  = matches[3];
			var inner    = matches[4];
			var rendered = renderSection(tagName, type, inner, arguments.context, arguments.partials, arguments.options);
			
			//  look to see where the current tag exists in the output; which we use to see if starting whitespace should be trimmed -
			var sectionPosition = find(tag, arguments.template);
			//  trims out empty lines from appearing in the output 
			if ( len(trim(rendered)) == 0 ) {
				rendered = "$2";
			} else {
				// escape the back-reference 
				rendered = replace(rendered, "$", "\$", "all");
			}

			var whiteSpaceRegex = "";  //  rendered content was empty, so we just want to replace all the text 
			//  if the current section is in the same place as the last template, 
			//  we do not need to clean up whitespace--because it's already been managed 
			if ( sectionPosition < lastSectionPosition ) {
				//  do not remove whitespace before the output, because we have already cleaned it 
				if ( rendered == "$2" ) {
					rendered = "";  //  no whitespace to clean up 
				}
			} else {
				//  clean out the extra lines of whitespace from the output 
				whiteSpaceRegex = "(^\r?\n?)?(\r?\n?)?";
			}
			// we use a regex to remove unwanted white-spacing from appearing 
			arguments.template = variables.Mustache.Pattern
								.compile( javaCast("string", whiteSpaceRegex & "\Q" & tag & "\E(\r?\n?)?"), 40 )
								.matcher( javaCast("string", arguments.template) )
								.replaceAll(rendered);

			//  track the position of the last section -
			lastSectionPosition = sectionPosition;
		}
		return arguments.template;
	}


	private function renderSection(tagName, type, inner, context, partials, options){
		
		var ctx = get(arguments.tagName, arguments.context, arguments.partials, arguments.options);
		
		if(arguments.type != "^" ){

			if( IsStruct(ctx) && !StructIsEmpty(ctx) ) {
				return renderFragment(arguments.inner, ctx, arguments.partials, arguments.options);
			} 
			
			if( IsQuery(ctx) && ctx.recordCount ) {
				return renderQuerySection(arguments.inner, ctx, arguments.partials, arguments.options);
			} 
			
			if( IsArray(ctx) && !ArrayIsEmpty(ctx) ) {
				return renderArraySection(arguments.inner, ctx, arguments.partials, arguments.options);
			} 
			 
			if( StructKeyExists(arguments.context, arguments.tagName) && IsCustomFunction(arguments.context[arguments.tagName]) ) {
				return renderLambda(arguments.tagName, arguments.inner, arguments.context, arguments.partials, arguments.options);
			}
		}

		if ( arguments.type == "^" xor convertToBoolean(ctx) ) {
			return arguments.inner;
		}

		return "";
	}

	/**
	 * render a lambda function (also provides a hook if you want to extend how lambdas works)
	 */
	private function renderLambda(tagName, template, context, partials, options) output=false {
	
		//  if running on a component 
		if ( IsObject(arguments.context) ) {
			//  call the function and pass in the arguments 
			return Invoke( 
				arguments.context, 
				arguments.tagName, 
				[ arguments.template ]
			); 
		} 
		//  otherwise we have a struct w/a reference to a function or closure 
		else {
			var fn = arguments.context[arguments.tagName];
			return fn(arguments.template);
		}
	}

	private boolean function convertToBoolean(any value) {
		if ( isBoolean(arguments.value) ) {
			return arguments.value;
		}
		if ( isSimpleValue(arguments.value) ) {
			return arguments.value != "";
		}
		if ( isStruct(arguments.value) ) {
			return !StructIsEmpty(arguments.value);
		}
		if ( isQuery(arguments.value) ) {
			return arguments.value.recordCount != 0;
		}
		if ( isArray(arguments.value) ) {
			return !arrayIsEmpty(arguments.value);
		}
		return false;
	}

	private function renderQuerySection(template, query, partials, options) {
		var results = [];
		//  trim the trailing whitespace--so we don't print extra lines 
		arguments.template = rTrim(arguments.template);
		for(var record in arguments.query){
			ArrayAppend(results, renderFragment(arguments.template, record, arguments.partials, arguments.options))
		}
		return ArrayToList(results, "");
	}

	private function renderArraySection(template, context, partials, options) {
		var results = "";
		//  trim the trailing whitespace--so we don't print extra lines 
		            arguments.template = rTrim(arguments.template);
		saveContent variable           = "results" {
			for ( var item in arguments.context ) {
				writeOutput(
					renderFragment(arguments.template, item, arguments.partials, arguments.options)
				);
			}
		}
		return results;
	}


	private function renderTags(template, context, partials, options) {
		
		while (true) {
			var matches = ReFindNoCaseValues(arguments.template, variables.Mustache.TagRegEx);
			if ( !arrayLen(matches) ) break;

			var tag     = matches[1];
			var type    = matches[2];
			var tagName = matches[3];
			var extra   = matches[4];  //  gets the ".*" capture 
			
			var renderedTag        = renderTag(type, tagName, arguments.context, arguments.partials, arguments.options, extra);
			    arguments.template = replace(arguments.template, tag, renderedTag);
		}

		return arguments.template;
	}

	private function renderTag(type, tagName, context, partials, options, extra){
		
		var results          = "";
		var arguments.extras = listToArray(arguments.extra, ":");

		if ( arguments.type == "!" )  return "";
		
		if ( (arguments.type == "{") || (arguments.type == "&") ) {
			arguments.value     = get(arguments.tagName, arguments.context, arguments.partials, arguments.options);
			arguments.valueType = "text";
			results             = textEncode(arguments.value, arguments.options, arguments);
		} else if ( arguments.type == ">" ) {
			arguments.value     = renderPartial(arguments.tagName, arguments.context, arguments.partials, arguments.options);
			arguments.valueType = "partial";
			results             = arguments.value;
		} else {
			arguments.value     = get(arguments.tagName, arguments.context, arguments.partials, arguments.options);
			arguments.valueType = "html";
			results             = htmlEncode(arguments.value, arguments.options, arguments);
		}

		return onRenderTag(results, arguments);
	}


	/**
	 * If we have the partial registered, use that, otherwise use the registered text
	 */
	private function renderPartial(required name, required context, required partials, options) {
		if ( structKeyExists(arguments.partials, arguments.name) ) {
			return this.render(arguments.partials[arguments.name], arguments.context, arguments.partials, arguments.options);
		} else {
			return this.render(readMustacheFile(arguments.name), arguments.context, arguments.partials, arguments.options);
		}
	}

	private function readMustacheFile(filename) {
		var template = "";
		try {
			template = FileRead("#getDirectoryFromPath(getMetaData(this).path)##arguments.filename#.mustache");
		} catch (any cfCatch) {
			if ( getRaiseErrors() ) {
				throw( message="Cannot not find `#arguments.filename#` template", type="Mustache.TemplateMissing" );
			}
			return "";
		}
		return trim(template);
	}

	private function get(key, context, partials, options) {
		//  if we are the implicit iterator 
		if ( arguments.key == "." ) {
			return toString(context);
		} 

		if ( find(".", arguments.key) ) {
			//  if we're a nested key, do a nested lookup 
			var thisKey       = ListFirst(arguments.key, ".");
			var restOfTheKeys = ListRest(arguments.key, ".");
			if ( StructKeyExists(arguments.context, thisKey) ) {
				return get(restOfTheKeys, context[thisKey], arguments.partials, arguments.options);
			} else {
				return "";
			}
		} 
		else if ( IsStruct(arguments.context) && StructKeyExists(arguments.context, arguments.key) ) {
			if ( IsCustomFunction(arguments.context[arguments.key]) ) {
				return renderLambda(arguments.key, '', arguments.context, arguments.partials, arguments.options);
			} else {
				return arguments.context[arguments.key];
			}
		} 
		else if ( IsQuery(arguments.context) ) {
			if ( ListContainsNoCase(arguments.context.columnList, arguments.key) ) {
				return arguments.context[arguments.key][arguments.context.currentRow];
			} else {
				return "";
			}
		} else {
			return "";
		}
	}



	private function ReFindNoCaseValues(text, re) output=false {
		var results = [];
		var matcher = arguments.re.matcher(arguments.text);
		if ( matcher.Find() ) {
			for ( var i=0 ; i<=matcher.groupCount(); i++ ) {
				ArrayAppend(results, matcher.group( JavaCast("int", i ) ) ?: "");
			}
		}
		return results;
	}

	private function getPartial(required name, partials) {
		if ( structKeyExists(variables.Mustache.partials, arguments.name) ) {
			return variables.Mustache.partials[arguments.name];
		} else if ( structKeyExists(arguments,"partials") && structKeyExists(arguments.partials, arguments.name) ) {
			return arguments.partials[arguments.name];
		} else {
			//  Fetch from file as last resort 
			return readMustacheFile(arguments.name);
		}
	}


	/**
	 * override this function in your methods to provide additional formatting to rendered content
	 */
	private function onRenderTag(rendered, callerArgs) {
		//  do nothing but return the passed in value 
		return arguments.rendered;
	}

	public function getPartials() {
		return variables.Mustache.partials;
	}

	public function setPartials(required partials, options) {
		variables.Mustache.partials = arguments.partials;
	}

	public function getRaiseErrors() {
		return variables.Mustache.RaiseErrors;
	}

	public function setRaiseErrors(required boolean value) {
		variables.Mustache.RaiseErrors = arguments.value;
	}

	/**
	 * Encodes a plain text string (can be overridden)
	 */
	private function textEncode(input, options, callerArgs) {
		//  we normally don't want to do anything, but this function is manually so we can overwrite the default behavior of {{{token}}} 
		return arguments.input;
	}

	/**
	 * Encodes a string into HTML (can be overridden)
	 */
	private function htmlEncode(input, options, callerArgs) {
		return htmlEditFormat(arguments.input);
	}
}

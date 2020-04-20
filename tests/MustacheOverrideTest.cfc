component extends="mxunit.framework.TestCase" {

	public function setup() {
		variables.partials = {};
		variables.options = {};
		variables.stache = createObject("component", "MustacheOverride").init();
	}

	public function tearDown() {
		// // make sure tests are case sensitive //
		assertEqualsCase(expected, variables.stache.render(variables.template, variables.context, variables.partials, variables.options));
		// // reset variables //
		variables.partials = {};
		variables.context = {};
	}

	public function textEncode() {
		variables.context  = { thing = 'World'};
		variables.template = "Hello, {{{thing}}}!";
		expected           = "Hello, `World`!";
	}

	public function htmlEncode() {
		variables.context  = { thing = 'World'};
		variables.template = "Hello, {{thing}}!";
		expected           = "Hello, |World|!";
	}

	public function textEncode_options_useDefault() {
		variables.options  = {useDefault=true};
		variables.context  = { thing = '<b>World</b>'};
		variables.template = "Hello, {{{thing}}}!";
		expected           = "Hello, #context.thing#!";
	}

	public function htmlEncode_options_useDefault() {
		variables.options  = {useDefault=true};
		variables.context  = { thing = '<b>World</b>'};
		variables.template = "Hello, {{thing}}!";
		expected           = "Hello, #htmlEditFormat(context.thing)#!";
	}

}

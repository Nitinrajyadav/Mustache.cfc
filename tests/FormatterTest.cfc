component extends="mxunit.framework.TestCase" {

	public function setup() {
		// variables.stache   = createObject("component", "mustache.MustacheFormatter").init();
		variables.stache   = createObject("component", "mustache/MustacheFormatter");

		variables.partials = {};
		variables.template = "Hello, {{thing}}!";
	}

	public function tearDown() {
		// // make sure tests are case sensitive //
		assertEqualsCase(variables.expected, variables.stache.render(variables.template, variables.context, variables.partials));
		// // reset variables //
		variables.partials = {};
		variables.context  = {};
	}

	public function invalidFormatter() {
		variables.context  = { thing = 'World'};
		variables.template = "Hello, {{thing:XXXXXX()}}!";
		variables.expected = "Hello, World!";
	}

	public function upperCase() {
		variables.context  = { thing = 'World'};
		variables.template = "Hello, {{thing:upperCase()}}!";
		variables.expected = "Hello, WORLD!";
	}

	public function lowerCase() {
		variables.context  = { thing = 'World'};
		variables.template = "Hello, {{thing:lowerCase()}}!";
		variables.expected = "Hello, world!";
	}

	public function leftPad() {
		variables.context  = { thing = 'World'};
		variables.template = "Hello, [{{thing:leftPad(20)}}]";
		variables.expected = "Hello, [#lJustify('World', 20)#]";
	}

	public function rightPad() {
		variables.context  = { thing = 'World'};
		variables.template = "Hello, [{{thing:rightPad(20)}}]";
		variables.expected = "Hello, [#rJustify('World', 20)#]";
	}

	public function multiply() {

		variables.context = {
				name  = "Dan", 
				value = 1000
			};

		variables.template = 'Hello {{name}}! You have just won ${{value}}! Taxes are ${{value:multiply(0.2)}}!';
		variables.expected = 'Hello Dan! You have just won $1000! Taxes are $200!';
	}

	public function chainedFormatters() {
		variables.context  = { thing = 'World'};
		variables.template = "Hello, {{thing:upperCase():leftPad(20):rightPad(40)}}!";
		variables.expected = "Hello, #rJustify(lJustify('WORLD', 20), 40)#!";
	}

	public function complexTemplate() {
		var Helper             = createObject("component", "tests.Helper");
		variables.context  = Helper.getComplexContext();
		variables.template = Helper.getComplexFormatterTemplate();
		variables.expected = trim('
			Please do !respond to this message. This = = for information purposes only.

			FOR SECURITY PURPOSES, PLEASE DO !FORWARD THIS EMAIL TO OTHERS.

			A new ticket has been entered && assigned to Tommy.
			+----------------------------------------------------------------------------+
			| Ticket : 1234                         Priority: Medium                     |
			| Name   : Jenny                        Phone : 867-5309                   |
			| Subject: E-mail !working                                                   |
			+----------------------------------------------------------------------------+
			Description: 
			Here''s a description

			with some

			new lines
					');
	}
    public function complexTemplateRev2() {
		var Helper            = createObject("component", "tests.Helper");
		variables.context 							  = Helper.getComplexContext();
		// change context 
		variables.context.Settings.EnableEmailUpdates = false;
		variables.context.Assignee.Name               = "";
		variables.context.Ticket.Note                 = "";
		variables.context.Ticket.Description          = "";
		variables.template                            = Helper.getComplexFormatterTemplate();
		variables.expected                            = trim('
FOR SECURITY PURPOSES, PLEASE DO !FORWARD THIS EMAIL TO OTHERS.

A new ticket has been entered && = = UNASSIGNED.
+----------------------------------------------------------------------------+
| Ticket : 1234                         Priority: Medium                     |
| Name   : Jenny                          Phone : 867-5309                   |
| Subject: E-mail !working                                                	 |
+----------------------------------------------------------------------------+
');
	}

}

component extends="mxunit.framework.TestCase" {
	
	public function setup() {
		variables.stache   = createObject("component", "mustache/Mustache");
		variables.template = "";
		variables.partials = {};
	}

	public function tearDown() {
		assertEquals(variables.expected, variables.stache.render(variables.template, variables.context, variables.partials));
	}

	public function basic() {
	variables.context  = { thing = 'world'};
	variables.template = "Hello, {{thing}}!";
	variables.expected = "Hello, World!";
	}

	public function basicWithSpace() {
	variables.context  = { thing = 'world'};
	variables.template = "Hello, {{ thing }}!";
	variables.expected = "Hello, World!";
	}

	public function basicWithMuchSpace() {
	variables.context  = { thing = 'world'};
	variables.template = "Hello, {{             thing    }}!";
	variables.expected = "Hello, World!";
	}

	public function lessBasic() {
	variables.context  = { beverage = 'soda', person = 'Bob' };
	variables.template = "It's a nice day for {{beverage}}, right {{person}}?";
	variables.expected = "It's a nice day for soda, right Bob?";
	}

	public function evenLessBasic() {
	variables.context  = { name = 'Jon', thing = 'racecar'};
	variables.template = "I think {{name}} wants a {{thing}}, right {{name}}?";
	variables.expected = "I think Jon wants a racecar, right Jon?";
	}

	public function ignoresMisses() {
	variables.context  = { name = 'Jon'};
	variables.template = "I think {{name}} wants a {{thing}}, right {{name}}?";
	variables.expected = "I think Jon wants a , right Jon?";
	}

	public function renderZero() {
	variables.context  = { value = 0 };
	variables.template = "My value == {{value}}.";
	variables.expected = "My value == 0.";
	}

	public function comments() {
		                  variables.context  = structNew();
		variables.context['!']               = "FAIL";
		variables.context['the']             = "FAIL";
		                  variables.template = "What {{!the}} what?";
		                  variables.expected = "What what?";
	}

	public function falseSectionsAreHidden() {
	variables.context  = { set = false };
	variables.template = "Ready {{##set}}set {{/set}}go!";
	variables.expected = "Ready go!";
	}

	public function trueSectionsAreShown() {
	variables.context  = { set = true };
	variables.template = "Ready {{##set}}set {{/set}}go!";
	variables.expected = "Ready set go!";
	}

	public function falseSectionsWithSpaceAreHidden() {
	variables.context  = { set = false };
	variables.template = "Ready {{ ##set }}set {{ /set }}go!";
	variables.expected = "Ready go!";
	}

	public function trueSectionsWithSpaceAreShown() {
	variables.context  = { set = true };
	variables.template = "Ready {{ ##set }}set {{ /set }}go!";
	variables.expected = "Ready set go!";
	}

	public function falseSectionsAreShownIfInverted() {
	variables.context  = { set = false };
	variables.template = "Ready {{^set}}set {{/set}}go!";
	variables.expected = "Ready set go!";
	}

	public function trueSectionsAreHiddenIfInverted() {
	variables.context  = { set = true };
	variables.template = "Ready {{^set}}set {{/set}}go!";
	variables.expected = "Ready go!";
	}

	public function emptyStringsAreFalse() {
	variables.context  = { set = "" };
	variables.template = "Ready {{##set}}set {{/set}}go!";
	variables.expected = "Ready go!";
	}

	public function emptyQueriesAreFase() {
	variables.context  = { set = QueryNew('firstname,lastname') };
	variables.template = "Ready {{^set}}No records found {{/set}}go!";
	variables.expected = "Ready No records found go!";
	}

	public function emptyStructsAreFalse() {
	variables.context  = { set = {} };
	variables.template = "Ready {{^set}}No records found {{/set}}go!";
	variables.expected = "Ready No records found go!";
	}

	public function emptyArraysAreFalse() {
	variables.context  = { set = [] };
	variables.template = "Ready {{^set}}No records found {{/set}}go!";
	variables.expected = "Ready No records found go!";
	}

	public function nonEmptyStringsAreTrue() {
	variables.context  = { set = "x" };
	variables.template = "Ready {{##set}}set {{/set}}go!";
	variables.expected = "Ready set go!";
  }
  
	public function skipMissingField() {
	variables.context  = structNew();
	variables.template = "There's something {{##foo}}missing{{/foo}}!";
	variables.expected = "There's something !";
	}

	public function structAsSection() {
	variables.context = {
      contact = { name = 'Jenny', phone = '867-5309'}
    };
	variables.template = "{{##contact}}({{name}}'s number == {{phone}}){{/contact}}";
	variables.expected = "(Jenny's number == 867-5309)";
	}

	public function noSpaceTokenTest_array() {
	variables.context = {
      list = [{item='a'}, {item='b'}, {item='c'}, {item='d'}, {item='e'}]
    };
	variables.template = "{{##list}}({{item}}){{/list}}";
	variables.expected = "(a)(b)(c)(d)(e)";
	}

	public function implicitIterator_String() {
	variables.context = {
      list = ['a', 'b', 'c', 'd', 'e']
    };
	variables.template = "{{##list}}({{.}}){{/list}}";
	variables.expected = "(a)(b)(c)(d)(e)";
	}

	public function implicitIterator_Integer() {
	variables.context = {
      list = [1, 2, 3, 4, 5]
    };
	variables.template = "{{##list}}({{.}}){{/list}}";
	variables.expected = "(1)(2)(3)(4)(5)";
	}

	public function implicitIterator_Decimal() {
	variables.context = {
      list = [1.10, 2.20, 3.30, 4.40, 5.50]
    };
	variables.template = "{{##list}}({{.}}){{/list}}";
	variables.expected = "(1.1)(2.2)(3.3)(4.4)(5.5)";
	}

	public function queryAsSection() {
		var contacts = queryNew("name,phone");
		queryAddRow(contacts);
		querySetCell(contacts, "name", "Jenny");
		querySetCell(contacts, "phone", "867-5309");
		queryAddRow(contacts);
		querySetCell(contacts, "name", "Tom");
		querySetCell(contacts, "phone", "555-1234");
	variables.context  = {contacts = contacts};
	variables.template = "{{##contacts}}({{name}}'s number == {{phone}}){{/contacts}}";
	variables.expected = "(Jenny's number == 867-5309)(Tom's number == 555-1234)";
	}

	public function missingQueryColumnIsSkipped() {
    var contacts = queryNew("name");
		queryAddRow(contacts);
		querySetCell(contacts, "name", "Jenny");
	variables.context  = {contacts = contacts};
	variables.template = "{{##contacts}}({{name}}'s number == {{phone}}){{/contacts}}";
	variables.expected = "(Jenny's number == )";
	}

	public function arrayAsSection() {
	variables.context = {
      contacts = [
        { name = 'Jenny', phone = '867-5309'}
        , { name = 'Tom', phone = '555-1234'}
      ]
    };
	variables.template = "{{##contacts}}({{name}}'s number == {{phone}}){{/contacts}}";
	variables.expected = "(Jenny's number == 867-5309)(Tom's number == 555-1234)";
	}

	public function missingStructKeyIsSkipped() {
	variables.context = {
      contacts = [
        { name = 'Jenny', phone = '867-5309'}
        , { name = 'Tom'}
      ]
    };
	variables.template = "{{##contacts}}({{name}}'s number == {{^phone}}unlisted{{/phone}}{{phone}}){{/contacts}}";
	variables.expected = "(Jenny's number == 867-5309)(Tom's number == unlisted)";
	}

	public function escape() {
	variables.context  = { thing = '<b>world</b>'};
	variables.template = "Hello, {{thing}}!";
	variables.expected = "Hello, &lt;b&gt;world&lt;/b&gt;!";
	}

	public function dontEscape() {
	variables.template = "Hello, {{{thing}}}!";
	variables.context  = { thing = '<b>world</b>'};
	variables.expected = "Hello, <b>world</b>!";
	}

	public function dontEscapeWithAmpersand() {
	variables.context  = { thing = '<b>world</b>'};
	variables.template = "Hello, {{&thing}}!";
	variables.expected = "Hello, <b>world</b>!";
	}

	public function ignoreWhitespace() {
	variables.context  = { thing = 'world'};
	variables.template = "Hello, {{   thing   }}!";
	variables.expected = "Hello, world!";
	}

	public function ignoreWhitespaceInSection() {
	variables.context  = { set = true };
	variables.template = "Ready {{##  set  }}set {{/  set  }}go!";
	variables.expected = "Ready set go!";
	}

	public function callAFunction() {
	variables.context           = createObject("component", "Person");
	variables.context.firstname = "Chris";
	variables.context.lastname  = "Wanstrath";
	variables.template          = "Mustache was created by {{fullname}}.";
	variables.expected          = "Mustache was created by Chris Wanstrath.";
	}

	private function lambdaTest() {
		return "Chris Wanstrath";
	}

	public function lambda() {
	variables.context  = {fullname=lambdaTest};
	variables.template = "Mustache was created by {{fullname}}.";
	variables.expected = "Mustache was created by Chris Wanstrath.";
	}

	public function filter() {
    variables.context  = createObject("component", "Filter");
    variables.template = "Hello, {{##bold}}world{{/bold}}.";
    variables.expected = "Hello, <b>world</b>.";
	}

	public function partial() {
		//  using a subclass so that it will look for the partial in this directory 
	variables.stache   = createObject("component", "Winner").init();
	variables.context  = { word = 'Goodnight', name = 'Gracie' };
	variables.template = "<ul><li>Say {{word}}, {{name}}.</li><li>{{> gracie_allen}}</li></ul>";
	variables.expected = "<ul><li>Say Goodnight, Gracie.</li><li>Goodnight</li></ul>";
	}

	public function globalRegisteredPartial() {
		//  reinit, passing in the global partial 

		var initPartials = 
			{
				gracie_allen = fileRead(expandPath("/tests/gracie_allen.mustache"))
			};
	variables.stache   = createObject("component", "mustache.Mustache").init(initPartials);
	variables.context  = { word = 'Goodnight', name = 'Gracie' };
	variables.template = "<ul><li>Say {{word}}, {{name}}.</li><li>{{> gracie_allen}}</li></ul>";
	variables.expected = "<ul><li>Say Goodnight, Gracie.</li><li>Goodnight</li></ul>";
	}

	public function runtimeRegisteredPartial() {

		partials = 
			{
				gracie_allen = fileRead(expandPath("/tests/gracie_allen.mustache"))
			};
	variables.context  = { word = 'Goodnight', name = 'Gracie' };
	variables.template = "<ul><li>Say {{word}}, {{name}}.</li><li>{{> gracie_allen}}</li></ul>";
	variables.expected = "<ul><li>Say Goodnight, Gracie.</li><li>Goodnight</li></ul>";
	}

	public function invertedSectionHiddenIfStructureNotEmpty() {
    variables.context  = {set = {something='whatever'}};
    variables.template = "{{##set}}This sentence should be showing.{{/set}}{{^set}}This sentence should not.{{/set}}";
    variables.expected = "This sentence should be showing.";
	}

	public function invertedSectionHiddenIfQueryNotEmpty() {
    var contacts = queryNew("name,phone");
		queryAddRow(contacts);
		querySetCell(contacts, "name", "Jenny");
		querySetCell(contacts, "phone", "867-5309");
	variables.context  = {set = contacts};
	variables.template = "{{##set}}This sentence should be showing.{{/set}}{{^set}}This sentence should not.{{/set}}";
	variables.expected = "This sentence should be showing.";
	}

	public function invertedSectionHiddenIfArrayNotEmpty() {
    variables.context  = {set = [1]};
    variables.template = "{{##set}}This sentence should be showing.{{/set}}{{^set}}This sentence should not.{{/set}}";
    variables.expected = "This sentence should be showing.";
	}

	public function dotNotation() {
		variables.context            = {};
		variables.context["value"]                     = "root";
		variables.context["level1"]                    = {};
		variables.context["level1"]["value"]           = "level 1";
		variables.context["level1"]["level2"]          = {};
		variables.context["level1"]["level2"]["value"] = "level 2";
		variables.template           = "{{value}}|{{level1.value}}|{{level1.level2.value}}|{{notExist}}|{{level1.notExists}}|{{levelX.levelY}}";
		variables.expected           = "root|level 1|level 2|||";
	}

	public function whitespaceHeadAndTail() {
	variables.context  = { thing = 'world'};
	variables.template = "#chr(32)##chr(9)##chr(32)#{{thing}}#chr(32)##chr(9)##chr(32)#";
	variables.expected = "#chr(32)##chr(9)##chr(32)#world#chr(32)##chr(9)##chr(32)#";
	}

	public function whitespaceEmptyLinesInHeadAndTail() {
	variables.context  = { thing = 'world'};
	variables.template = "#chr(10)##chr(32)##chr(9)##chr(32)#{{thing}}#chr(32)##chr(9)##chr(32)##chr(10)#";
	variables.expected = "#chr(32)##chr(9)##chr(32)#world#chr(32)##chr(9)##chr(32)#";
	}

	public function whitespaceEmptyLinesWithCarriageReturnInHeadAndTail() {
	variables.context  = { thing = 'world'};
	variables.template = "#chr(13)##chr(10)##chr(32)##chr(9)##chr(32)#{{thing}}#chr(32)##chr(9)##chr(32)##chr(13)##chr(10)#";
	variables.expected = "#chr(32)##chr(9)##chr(32)#world#chr(32)##chr(9)##chr(32)#";
	}

	public function whiteSpaceManagement() {

		variables.context = {
				name     = "Dan", 
				value    = 1000, 
				taxValue = 600, 
				in_ca    = true, 
				html     = "<b>some html</b>"
			};

		variables.context.list      = [];
		variables.context.list[1]   = {item="First note"};
		variables.context.list[2]   = {item="Second note"};
		variables.context.list[3]   = {item="Third note"};
		variables.context.list[4]   = {item="Etc, etc, etc."};

	variables.template = trim('
Hello "{{name}}"
You have just won ${{value}}!

{{##in_ca}}
Well, ${{taxValue}}, after taxes.
{{/in_ca}}

I did{{^in_ca}} <strong><em>not</em></strong>{{/in_ca}} calculate taxes.

Here is some HTML          : {{html}}
Here is some unescaped HTML: {{{html}}}

Here are the history notes: 

{{##list}}
  * {{item}}
{{/list}}
			');

	variables.expected = trim('
Hello "Dan"
You have just won $1000!

Well, $600, after taxes.

I did calculate taxes.

Here is some HTML          : &lt;b&gt;some html&lt;/b&gt;
Here is some unescaped HTML: <b>some html</b>

Here are the history notes: 

  * First note
  * Second note
  * Third note
  * Etc, etc, etc.
			');
	}

	public function whiteSpaceManagementWithFalseBlocks() {

	variables.context = {
		name     = "Dan",
		value    = 1000, 
		taxValue = 600, 
		in_ca    = false, 
		html     = "<b>some html</b>"
	};

	variables.context.list     = [];
	variables.context.list[1]  = {item="First note"};
	variables.context.list[2]  = {item="Second note"};
	variables.context.list[3]  = {item="Third note"};
	variables.context.list[4]  = {item="Etc, etc, etc."};

	variables.template = trim('
Hello "{{name}}"
You have just won ${{value}}!

{{##in_ca}}
Well, ${{taxValue}}, after taxes.
{{/in_ca}}

I did{{^in_ca}} <strong><em>not</em></strong>{{/in_ca}} calculate taxes.

Here is some HTML          : {{html}}
Here is some unescaped HTML: {{{html}}}

Here are the history notes: 

{{##list}}
  * {{item}}
{{/list}}
			');

	variables.expected = trim('
Hello "Dan"
You have just won $1000!

I did <strong><em>not</em></strong> calculate taxes.

Here is some HTML          : &lt;b&gt;some html&lt;/b&gt;
Here is some unescaped HTML: <b>some html</b>

Here are the history notes: 

  * First note
  * Second note
  * Third note
  * Etc, etc, etc.
			');
	}

	public function whiteSpaceManagementWithElseIffy() {

	variables.context = {
				        name     = "Dan"
				      , value    = 1000
				      , taxValue = 600
				      , in_ca    = false
				      , html     = "<b>some html</b>"
			};

		variables.template = trim('
Hello "{{name}}"
You have just won ${{value}}!

{{##in_ca}}
Well, ${{taxValue}}, after taxes.
{{/in_ca}}
{{^in_ca}}
No new taxes!
{{/in_ca}}

I did{{^in_ca}} <strong><em>not</em></strong>{{/in_ca}} calculate taxes.
			');

			variables.expected = trim('
Hello "Dan"
You have just won $1000!

No new taxes!

I did <strong><em>not</em></strong> calculate taxes.
			');
	}

	public function whiteSpaceManagementWithEmptyElseIffy() {

		variables.context = {
				        name     = "Dan"
				      , value    = 1000
				      , taxValue = 600
				      , in_ca    = false
				      , html     = "<b>some html</b>"
			};

		variables.template = trim('
Hello "{{name}}"
You have just won ${{value}}!

{{##in_ca}}
Well, ${{taxValue}}, after taxes.
{{/in_ca}}
{{^in_ca}}
{{/in_ca}}

I did{{^in_ca}} <strong><em>not</em></strong>{{/in_ca}} calculate taxes.
			');

		variables.expected = trim('
Hello "Dan"
You have just won $1000!

I did <strong><em>not</em></strong> calculate taxes.
			');
	}

	public function whiteSpaceManagementWithEmptyValue() {

		variables.context = {
				  empty_value = ""
			};

		variables.template = trim('
First line!

{{empty_value}}

Last line!
			');

			variables.expected = trim('
First line!



Last line!
			');
	}

	public function whiteSpaceManagementWithNonEmptyValue() {

	variables.context = {
				  not_empty_value = "here!"
			};

		variables.template = trim('
First line!

{{not_empty_value}}

Last line!
			');

		variables.expected = trim('
        First line!

        here!

        Last line!
			');
	}

	public function multilineComments() {

		variables.context = { thing = 'world'};

		variables.template = trim('
          Hello {{!inline comment should only produce one space}} {{thing}}!
          {{!
            a multi
            line comment
          }}
          Bye{{!inline comment should only produce one space}} {{thing}}!
		  No{{! break }}space!
		  ');

			variables.expected = trim('Hello world! Bye world! Nospace!');
	}

	public function complexTemplate() {
		var Helper             = createObject("component", "tests.Helper");
		    variables.context  = Helper.getComplexContext();
		    variables.template = Helper.getComplexTemplate();
		    variables.expected = trim('
		Please do !respond to this message. This =  = for information purposes only.
		Please do not respond to this message. This is for information purposes only.

        FOR SECURITY PURPOSES, PLEASE DO !FORWARD THIS EMAIL TO OTHERS.
        A new ticket has been entered && assigned to Tommy.
        Ticket No         : 1234
               Priority   : Medium
               Name       : Jenny
               Subject    : E-mail !working
        Phone  Number     : 867-5309
               Description: 
        Here''s a description
        with some
		new lines
		
        Public Note: 
        User needs to update their software to the latest version.
        Thank you,
		Support Team');
	}

	public function complexTemplateRev2() {
		var Helper            = createObject("component", "tests.Helper");
		    variables.context = Helper.getComplexContext();
		// // change context //
		variables.context.Settings.EnableEmailUpdates = false;
		variables.context.Settings.ShowPrivateNote    = true;
		variables.context.Assignee.Name               = "";
		variables.context.Customer.Room               = "100";
		variables.context.Customer.Department         = "Human Resources";
		variables.context.Ticket.Note                 = "";
		variables.context.Ticket.Description          = "";
		variables.template                            = Helper.getComplexTemplate();
		variables.expected                            = trim('
        FOR SECURITY PURPOSES, PLEASE DO !FORWARD THIS EMAIL TO OTHERS.

        A new ticket has been entered && =  = UNASSIGNED.

        Ticket No        : 1234
               Priority  : Medium
               Name      : Jenny
               Subject   : E-mail !working
        Phone  Number    : 867-5309
               Room      : 100
               Department: Human Resources

        Description: 


        Private Note: 
        Client doesn''t want to listen to instructions

        Thank you,
        Support Team
		');
	}

}

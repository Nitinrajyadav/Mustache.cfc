component extends="mxunit.framework.TestCase" {
	stache = createObject("component", "mustache.Mustache").init();
	partials = {};

	public function setup() {
	}

	public function tearDown() {
		/* 
		<cfoutput>#htmlCodeFormat(expected)#</cfoutput>
		<hr />
		<cfoutput>#htmlCodeFormat(stache.render(template, context, partials))#</cfoutput>
		<cfabort />
*/
		assertEquals(expected, stache.render(template, context, partials));
	}

	public function basic() {
	var	context = { thing = 'world'};
	var		template = "Hello, {{thing}}!";
	var		expected = "Hello, World!";
	}

	public function basicWithSpace() {
	var	context = { thing = 'world'};
	var		template = "Hello, {{ thing }}!";
	var		expected = "Hello, World!";
	}

	public function basicWithMuchSpace() {
	var	context = { thing = 'world'};
	var		template = "Hello, {{             thing    }}!";
	var		expected = "Hello, World!";
	}

	public function lessBasic() {
	var	context = { beverage = 'soda', person = 'Bob' };
	var		template = "It's a nice day for {{beverage}}, right {{person}}?";
	var		expected = "It's a nice day for soda, right Bob?";
	}

	public function evenLessBasic() {
	var	context = { name = 'Jon', thing = 'racecar'};
	var		template = "I think {{name}} wants a {{thing}}, right {{name}}?";
	var		expected = "I think Jon wants a racecar, right Jon?";
	}

	public function ignoresMisses() {
	var	context = { name = 'Jon'};
	var		template = "I think {{name}} wants a {{thing}}, right {{name}}?";
	var		expected = "I think Jon wants a , right Jon?";
	}

	public function renderZero() {
	var	context = { value = 0 };
	var		template = "My value == {{value}}.";
	var		expected = "My value == 0.";
	}

	public function comments() {
	var	context = structNew();
		context['!'] = "FAIL";
		context['the'] = "FAIL";
	var		template = "What {{!the}} what?";
	var		expected = "What what?";
	}

	public function falseSectionsAreHidden() {
	var	context =  { set = false };
	var		template = "Ready {{##set}}set {{/set}}go!";
	var		expected = "Ready go!";
	}

	public function trueSectionsAreShown() {
	var	context =  { set = true };
	var		template = "Ready {{##set}}set {{/set}}go!";
	var		expected = "Ready set go!";
	}

	public function falseSectionsWithSpaceAreHidden() {
	var	context =  { set = false };
	var		template = "Ready {{ ##set }}set {{ /set }}go!";
	var		expected = "Ready go!";
	}

	public function trueSectionsWithSpaceAreShown() {
	var	context =  { set = true };
	var		template = "Ready {{ ##set }}set {{ /set }}go!";
	var		expected = "Ready set go!";
	}

	public function falseSectionsAreShownIfInverted() {
	var	context =  { set = false };
	var		template = "Ready {{^set}}set {{/set}}go!";
	var		expected = "Ready set go!";
	}

	public function trueSectionsAreHiddenIfInverted() {
	var	context =  { set = true };
	var		template = "Ready {{^set}}set {{/set}}go!";
	var		expected = "Ready go!";
	}

	public function emptyStringsAreFalse() {
	var	context =  { set = "" };
	var		template = "Ready {{##set}}set {{/set}}go!";
	var		expected = "Ready go!";
	}

	public function emptyQueriesAreFase() {
	var	context =  { set = QueryNew('firstname,lastname') };
	var		template = "Ready {{^set}}No records found {{/set}}go!";
	var		expected = "Ready No records found go!";
	}

	public function emptyStructsAreFalse() {
	var	context =  { set = {} };
	var		template = "Ready {{^set}}No records found {{/set}}go!";
	var		expected = "Ready No records found go!";
	}

	public function emptyArraysAreFalse() {
	var	context =  { set = [] };
	var		template = "Ready {{^set}}No records found {{/set}}go!";
	var		expected = "Ready No records found go!";
	}

	public function nonEmptyStringsAreTrue() {
	var	context =  { set = "x" };
	var		template = "Ready {{##set}}set {{/set}}go!";
	var		expected = "Ready set go!";
  }
  
	public function skipMissingField() {
	var	context =  structNew();
	var		template = "There's something {{##foo}}missing{{/foo}}!";
	var		expected = "There's something !";
	}

	public function structAsSection() {
	var	context = {
      contact = { name = 'Jenny', phone = '867-5309'}
    };
	var		template = "{{##contact}}({{name}}'s number == {{phone}}){{/contact}}";
	var		expected = "(Jenny's number == 867-5309)";
	}

	public function noSpaceTokenTest_array() {
	var	context = {
      list = [{item='a'}, {item='b'}, {item='c'}, {item='d'}, {item='e'}]
    };
	var		template = "{{##list}}({{item}}){{/list}}";
	var		expected = "(a)(b)(c)(d)(e)";
	}

	public function implicitIterator_String() {
	var	context = {
      list = ['a', 'b', 'c', 'd', 'e']
    };
	var		template = "{{##list}}({{.}}){{/list}}";
	var		expected = "(a)(b)(c)(d)(e)";
	}

	public function implicitIterator_Integer() {
	var	context = {
      list = [1, 2, 3, 4, 5]
    };
	var		template = "{{##list}}({{.}}){{/list}}";
	var		expected = "(1)(2)(3)(4)(5)";
	}

	public function implicitIterator_Decimal() {
	var	context = {
      list = [1.10, 2.20, 3.30, 4.40, 5.50]
    };
	var		template = "{{##list}}({{.}}){{/list}}";
	var		expected = "(1.10)(2.20)(3.30)(4.40)(5.50)";
	}

	public function queryAsSection() {
		var	contacts = queryNew("name,phone");
		queryAddRow(contacts);
		querySetCell(contacts, "name", "Jenny");
		querySetCell(contacts, "phone", "867-5309");
		queryAddRow(contacts);
		querySetCell(contacts, "name", "Tom");
		querySetCell(contacts, "phone", "555-1234");
	var	context = {contacts = contacts};
	var		template = "{{##contacts}}({{name}}'s number == {{phone}}){{/contacts}}";
	var		expected = "(Jenny's number == 867-5309)(Tom's number == 555-1234)";
	}

	public function missingQueryColumnIsSkipped() {
    var		contacts = queryNew("name");
		queryAddRow(contacts);
		querySetCell(contacts, "name", "Jenny");
	var	context = {contacts = contacts};
	var		template = "{{##contacts}}({{name}}'s number == {{phone}}){{/contacts}}";
	var		expected = "(Jenny's number == )";
	}

	public function arrayAsSection() {
	var	context = {
      contacts = [
        { name = 'Jenny', phone = '867-5309'}
        , { name = 'Tom', phone = '555-1234'}
      ]
    };
	var		template = "{{##contacts}}({{name}}'s number == {{phone}}){{/contacts}}";
	var		expected = "(Jenny's number == 867-5309)(Tom's number == 555-1234)";
	}

	public function missingStructKeyIsSkipped() {
	var	context = {
      contacts = [
        { name = 'Jenny', phone = '867-5309'}
        , { name = 'Tom'}
      ]
    };
	var		template = "{{##contacts}}({{name}}'s number == {{^phone}}unlisted{{/phone}}{{phone}}){{/contacts}}";
	var		expected = "(Jenny's number == 867-5309)(Tom's number == unlisted)";
	}

	public function escape() {
	var	context = { thing = '<b>world</b>'};
	var		template = "Hello, {{thing}}!";
	var		expected = "Hello, &lt;b&gt;world&lt;/b&gt;!";
	}

	public function dontEscape() {
	var		template = "Hello, {{{thing}}}!";
	var	context = { thing = '<b>world</b>'};
	var		expected = "Hello, <b>world</b>!";
	}

	public function dontEscapeWithAmpersand() {
	var	context = { thing = '<b>world</b>'};
	var		template = "Hello, {{&thing}}!";
	var		expected = "Hello, <b>world</b>!";
	}

	public function ignoreWhitespace() {
	var	context = { thing = 'world'};
	var		template = "Hello, {{   thing   }}!";
	var		expected = "Hello, world!";
	}

	public function ignoreWhitespaceInSection() {
	var	context =  { set = true };
	var		template = "Ready {{##  set  }}set {{/  set  }}go!";
	var		expected = "Ready set go!";
	}

	public function callAFunction() {
	var	context = createObject("component", "Person");
		context.firstname = "Chris";
		context.lastname = "Wanstrath";
	var		template = "Mustache was created by {{fullname}}.";
	var		expected = "Mustache was created by Chris Wanstrath.";
	}

	private function lambdaTest() {
		return "Chris Wanstrath";
	}

	public function lambda() {
	var	context = {fullname=lambdaTest};
	var		template = "Mustache was created by {{fullname}}.";
	var		expected = "Mustache was created by Chris Wanstrath.";
	}

	public function filter() {
    var	context = createObject("component", "Filter");
	var		template = "Hello, {{##bold}}world{{/bold}}.";
	var		expected = "Hello, <b>world</b>.";
	}

	public function partial() {
		//  using a subclass so that it will look for the partial in this directory 
		stache = createObject("component", "Winner").init();
	var	context = { word = 'Goodnight', name = 'Gracie' };
	var		template = "<ul><li>Say {{word}}, {{name}}.</li><li>{{> gracie_allen}}</li></ul>";
	var		expected = "<ul><li>Say Goodnight, Gracie.</li><li>Goodnight</li></ul>";
	}

	public function globalRegisteredPartial() {
		//  reinit, passing in the global partial 

		var initPartials =
			{
				gracie_allen = fileRead(expandPath("/tests/gracie_allen.mustache"))
			};
		stache = createObject("component", "mustache.Mustache").init(initPartials);
	var	context = { word = 'Goodnight', name = 'Gracie' };
	var		template = "<ul><li>Say {{word}}, {{name}}.</li><li>{{> gracie_allen}}</li></ul>";
	var		expected = "<ul><li>Say Goodnight, Gracie.</li><li>Goodnight</li></ul>";
	}

	public function runtimeRegisteredPartial() {

		partials =
			{
				gracie_allen = fileRead(expandPath("/tests/gracie_allen.mustache"))
			};
	var	context = { word = 'Goodnight', name = 'Gracie' };
	var		template = "<ul><li>Say {{word}}, {{name}}.</li><li>{{> gracie_allen}}</li></ul>";
	var		expected = "<ul><li>Say Goodnight, Gracie.</li><li>Goodnight</li></ul>";
	}

	public function invertedSectionHiddenIfStructureNotEmpty() {
    var	context =  {set = {something='whatever'}};
	var		template = "{{##set}}This sentence should be showing.{{/set}}{{^set}}This sentence should not.{{/set}}";
	var		expected = "This sentence should be showing.";
	}

	public function invertedSectionHiddenIfQueryNotEmpty() {
    var		contacts = queryNew("name,phone");
		queryAddRow(contacts);
		querySetCell(contacts, "name", "Jenny");
		querySetCell(contacts, "phone", "867-5309");
	var	context = {set = contacts};
	var		template = "{{##set}}This sentence should be showing.{{/set}}{{^set}}This sentence should not.{{/set}}";
	var		expected = "This sentence should be showing.";
	}

	public function invertedSectionHiddenIfArrayNotEmpty() {
    var	context =  {set = [1]};
	var		template = "{{##set}}This sentence should be showing.{{/set}}{{^set}}This sentence should not.{{/set}}";
	var		expected = "This sentence should be showing.";
	}

	public function dotNotation() {
    var	context =  {};
		context["value"] = "root";
		context["level1"] = {};
		context["level1"]["value"] = "level 1";
		context["level1"]["level2"] = {};
		context["level1"]["level2"]["value"] = "level 2";
	var		template = "{{value}}|{{level1.value}}|{{level1.level2.value}}|{{notExist}}|{{level1.notExists}}|{{levelX.levelY}}";
	var		expected = "root|level 1|level 2|||";
	}

	public function whitespaceHeadAndTail() {
	var	context = { thing = 'world'};
	var		template = "#chr(32)##chr(9)##chr(32)#{{thing}}#chr(32)##chr(9)##chr(32)#";
	var		expected = "#chr(32)##chr(9)##chr(32)#world#chr(32)##chr(9)##chr(32)#";
	}

	public function whitespaceEmptyLinesInHeadAndTail() {
	var	context = { thing = 'world'};
	var		template = "#chr(10)##chr(32)##chr(9)##chr(32)#{{thing}}#chr(32)##chr(9)##chr(32)##chr(10)#";
	var		expected = "#chr(32)##chr(9)##chr(32)#world#chr(32)##chr(9)##chr(32)#";
	}

	public function whitespaceEmptyLinesWithCarriageReturnInHeadAndTail() {
	var	context = { thing = 'world'};
	var		template = "#chr(13)##chr(10)##chr(32)##chr(9)##chr(32)#{{thing}}#chr(32)##chr(9)##chr(32)##chr(13)##chr(10)#";
	var		expected = "#chr(32)##chr(9)##chr(32)#world#chr(32)##chr(9)##chr(32)#";
	}

	public function whiteSpaceManagement() {

	var	context = {
				  name="Dan"
				, value=1000
				, taxValue=600
				, in_ca=true
				, html="<b>some html</b>"
			};

			context.list = [];
			context.list[1] = {item="First note"};
			context.list[2] = {item="Second note"};
			context.list[3] = {item="Third note"};
			context.list[4] = {item="Etc, etc, etc."};

	var			template = trim('
Hello "{{name}}"
You have just won ${{value}}!

{{##in_ca}}
Well, ${{taxValue}}, after taxes.
{{/in_ca}}

I did{{^in_ca}} <strong><em>not</em></strong>{{/in_ca}} calculate taxes.

Here is some HTML: {{html}}
Here is some unescaped HTML: {{{html}}}

Here are the history notes:

{{##list}}
  * {{item}}
{{/list}}
			');

	var			expected = trim('
Hello "Dan"
You have just won $1000!

Well, $600, after taxes.

I did calculate taxes.

Here is some HTML: &lt;b&gt;some html&lt;/b&gt;
Here is some unescaped HTML: <b>some html</b>

Here are the history notes:

  * First note
  * Second note
  * Third note
  * Etc, etc, etc.
			');
	}

	public function whiteSpaceManagementWithFalseBlocks() {

	var	context = {
				  name="Dan"
				, value=1000
				, taxValue=600
				, in_ca=false
				, html="<b>some html</b>"
			};

			context.list = [];
			context.list[1] = {item="First note"};
			context.list[2] = {item="Second note"};
			context.list[3] = {item="Third note"};
			context.list[4] = {item="Etc, etc, etc."};

	var			template = trim('
Hello "{{name}}"
You have just won ${{value}}!

{{##in_ca}}
Well, ${{taxValue}}, after taxes.
{{/in_ca}}

I did{{^in_ca}} <strong><em>not</em></strong>{{/in_ca}} calculate taxes.

Here is some HTML: {{html}}
Here is some unescaped HTML: {{{html}}}

Here are the history notes:

{{##list}}
  * {{item}}
{{/list}}
			');

	var			expected = trim('
Hello "Dan"
You have just won $1000!

I did <strong><em>not</em></strong> calculate taxes.

Here is some HTML: &lt;b&gt;some html&lt;/b&gt;
Here is some unescaped HTML: <b>some html</b>

Here are the history notes:

  * First note
  * Second note
  * Third note
  * Etc, etc, etc.
			');
	}

	public function whiteSpaceManagementWithElseIffy() {

	var	context = {
				  name="Dan"
				, value=1000
				, taxValue=600
				, in_ca=false
				, html="<b>some html</b>"
			};

		var	template = trim('
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

			var expected = trim('
Hello "Dan"
You have just won $1000!

No new taxes!

I did <strong><em>not</em></strong> calculate taxes.
			');
	}

	public function whiteSpaceManagementWithEmptyElseIffy() {

		var context = {
				  name="Dan"
				, value=1000
				, taxValue=600
				, in_ca=false
				, html="<b>some html</b>"
			};

		var	template = trim('
Hello "{{name}}"
You have just won ${{value}}!

{{##in_ca}}
Well, ${{taxValue}}, after taxes.
{{/in_ca}}
{{^in_ca}}
{{/in_ca}}

I did{{^in_ca}} <strong><em>not</em></strong>{{/in_ca}} calculate taxes.
			');

		var	expected = trim('
Hello "Dan"
You have just won $1000!

I did <strong><em>not</em></strong> calculate taxes.
			');
	}

	public function whiteSpaceManagementWithEmptyValue() {

		var context = {
				  empty_value=""
			};

		var	template = trim('
First line!

{{empty_value}}

Last line!
			');

			var expected = trim('
First line!



Last line!
			');
	}

	public function whiteSpaceManagementWithNonEmptyValue() {

	var	context = {
				  not_empty_value="here!"
			};

		var	template = trim('
First line!

{{not_empty_value}}

Last line!
			');

		var 	expected = trim('
        First line!

        here!

        Last line!
			');
	}

	public function multilineComments() {

		var  context = { thing = 'world'};

		var	template = trim('
          Hello {{!inline comment should only produce one space}} {{thing}}!
          {{!
            a multi
            line comment
          }}
          Bye{{!inline comment should only produce one space}} {{thing}}!
          No{{! break }}space!
			');

			var expected = trim('
              Hello world!
              Bye world!
              Nospace!
			');
	}

	public function complexTemplate() {
		var Helper = createObject("component", "tests.Helper");
		var context = Helper.getComplexContext();
		var template = Helper.getComplexTemplate();
		var expected = trim('
        Please do !respond to this message. This == for information purposes only.

        FOR SECURITY PURPOSES, PLEASE DO !FORWARD THIS EMAIL TO OTHERS.

        A new ticket has been entered && assigned to Tommy.

        Ticket No: 1234
        Priority: Medium
        Name: Jenny
        Subject: E-mail !working
        Phone Number: 867-5309

        Description:
        Here''s a description

        with some

        new lines

        Public Note:
        User needs to update their software to the latest version.

        Thank you,
        Support Team
		');
	}

	public function complexTemplateRev2() {
		var Helper = createObject("component", "tests.Helper");
		var context = Helper.getComplexContext();
		// // change context //
		context.Settings.EnableEmailUpdates = false;
		context.Settings.ShowPrivateNote = true;
		context.Assignee.Name = "";
		context.Customer.Room = "100";
		context.Customer.Department = "Human Resources";
		context.Ticket.Note = "";
		context.Ticket.Description = "";
		var template = Helper.getComplexTemplate();
		var expected = trim('
        FOR SECURITY PURPOSES, PLEASE DO !FORWARD THIS EMAIL TO OTHERS.

        A new ticket has been entered && == UNASSIGNED.

        Ticket No: 1234
        Priority: Medium
        Name: Jenny
        Subject: E-mail !working
        Phone Number: 867-5309
        Room: 100
        Department: Human Resources

        Description:


        Private Note:
        Client doesn''t want to listen to instructions

        Thank you,
        Support Team
		');
	}

}

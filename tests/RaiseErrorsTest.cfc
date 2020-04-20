component extends="mxunit.framework.TestCase" {

	public function setup() {
		variables.partials = {};
	}

	public function missingPartialErrorThrown() {
		expectException("Mustache.TemplateMissing");
		var stache   = createObject("component", "mustache.Mustache").init();
		var context  = { word = 'Goodnight', name = 'Gracie' };
		var template = "<ul><li>Say {{word}}, {{name}}.</li><li>{{> gracie_allen}}</li></ul>";
		var expected = "<ul><li>Say Goodnight, Gracie.</li><li>Goodnight</li></ul>";
		stache.render(template, context, variables.partials);
	}

	public function missingPartialSilentFailure() {
		var stache   = createObject("component", "mustache.Mustache").init(raiseErrors=false);
		var context  = { word = 'Goodnight', name = 'Gracie' };
		var template = "<ul><li>Say {{word}}, {{name}}.</li><li>{{> gracie_allen}}</li></ul>";
		var expected = "<ul><li>Say Goodnight, Gracie.</li><li></li></ul>";
		assertEquals(expected, stache.render(template, context));
	}

	public function missingTemplateErrorThrown() {
		expectException("Mustache.TemplateMissing");
		var stache = createObject("component", "mustache.Mustache").init();
		var stache.render();
	}

	public function missingTemplateSilentFailure() {
		var stache = createObject("component", "mustache.Mustache").init(raiseErrors=false);
		assertEquals("", stache.render());
	}

}

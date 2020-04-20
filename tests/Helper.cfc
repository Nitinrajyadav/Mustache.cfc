component {
	variables.crlf  = chr(13) & chr(10);
	variables.crlf2 = variables.crlf & variables.crlf;

	public function getComplexContext() {
		var     context     = {};
		context["Settings"] = {'EnableEmailUpdates'=true, 'ShowPrivateNote'=false, 'Signature'="Support Team"};
		context["Assignee"] = {'Name'="Tommy"};
		context["Customer"] = {'Name'="Jenny", 'Phone'="867-5309"};
		context["Ticket"]   = {'Number'="1234", 'Subject'="E-mail !working", 'Priority'="Medium", Description="Here's a description#variables.crlf2#with some#variables.crlf2#new lines", Note="User needs to update their software to the latest version.", PrivateNote="Client doesn't want to listen to instructions"};
		return context;
	}

	public function getComplexTemplate() {
		// we to remove carriage returns, because the CFC doesn't have them
		return trim(replace(fileRead(expandPath("./complex.mustache")), chr(13), "", "all"));
	}

	public function getComplexFormatterTemplate() {
		// we to remove carriage returns, because the CFC doesn't have them
		return trim(replace(fileRead(expandPath("./complexFormatter.mustache")), chr(13), "", "all"));
	}

}

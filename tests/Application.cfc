// set up a dummy application so that we don't need any specific mappings and the tests can run from any sub-directory //
component output="false" {
	
	// SET APPLICATION MAPPINGS
	this.mappings["/tests"]    = getDirectoryFromPath(getCurrentTemplatePath());
	this.mappings["/mustache"] = this.mappings["/tests"] & "../mustache";
	
	// APPLICATION CFC PROPERTIES
	this.name                     = hash(this.mappings["/tests"]);
	this.applicationTimeout       = createTimespan(0, 0, 10, 0);
	this.serverSideFormValidation = false;
	this.clientManagement         = false;
	this.setClientCookies         = false;
	this.setDomainCookies         = false;
	this.sessionManagement        = false;

}

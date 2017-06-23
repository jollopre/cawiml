@Path("/collection")
public class Collection{
	/* ... */
	@Path("/token/{id}")
	@POST
	public void postToken(@PathParam("id") String id) throws IOException{
		/* Creates an instance of the survey id for an interviewee */
	}
	@Path("/token/{id}")
	@DELETE
	public void deleteToken(@PathParam("id") String id) throws IOException{
		/*  Disables the survey id for an interviewee */
	}
	@Path("/surveyinfo/{id}")
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public Survey getSurveyInfo(@PathParam("id") String id) throws IOException{
		/* Retrieves the information from the survey id (e.g. name, description and datetime that it was created). */
	}
	@Path("/resume/{id}")
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public RoutingStatus getResume(@PathParam("id") String id) throws IOException{
		/* Retrieves the last state reached for an interviewee. */
	}
	@Path("/previous/{id}")
	@POST
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public RoutingStatus postPrevious(@PathParam("id") String id, Vector<Response> clientResponse) throws IOException{
		/* Gets the next state of the survey for an interviewee */
	}
	@Path("/next/{id}")
	@POST
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public RoutingStatus postNext(@PathParam("id") String id, Vector<Response> clientResponse) throws IOException{
		/* Gets the previousmark the interviewee has finish the questionnaire and the cookie have to deleted from the browser. state of the survey for an interviewee */
	}
	/* ... */
}
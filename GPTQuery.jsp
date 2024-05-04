<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page language="java" import="java.sql.*" %> 
<%@ page language="java" import="java.util.*" %> 

<%@ page language="java" import="java.util.regex.Matcher" %>
<%@ page language="java" import="java.util.regex.Pattern" %>
 
<%@ page language="java" import="java.net.*" %>
<%@ page language="java" import="java.io.*" %>

<%//this is a skeleton page. whenever you want to make a new webpage that the user should be authenticated to view, start with a copy of this page and work from there %>


    
<% 

//Warning: DO NOT CHANGE ANY CODE HERE!!! LOTS OF HACKS. STUPID CODE. I HATED PROGRAMMING THIS SHIT. IT WAS DUMB. DO NOT CHANGE ANY CODE HERE
//verify login with sessionID cookie
String JDBC_DRIVER = "com.mysql.jdbc.Driver";  
String DB_URL = "jdbc:mysql://localhost:3306/moviesdb";
String USER = "root";
String pass = "password";
Connection dbConn = null;
Statement st = null;
ResultSet rs = null;
Statement lt = null;
ResultSet ls = null;

boolean sessionExpired = false;


Cookie cookies[] = request.getCookies();
String providedSessionID = "";

if(cookies.length == 0){
	response.sendRedirect("index.jsp"); //send to login page
}


for(Cookie c: cookies){
	if(c.getName().equals("movieSiteSessionID")){
		providedSessionID = c.getValue();
	}
}

if(providedSessionID == "0000000000000000"){
	response.sendRedirect("index.jsp"); //send to login page
}




try{
	
	dbConn = DriverManager.getConnection(DB_URL, USER, pass);

    st = dbConn.createStatement();
    rs = st.executeQuery("SELECT * FROM user");

	String getSessionID="";

	
    
    boolean validSession = false;
    
    //check database to see if session id exists
    while(rs.next() && validSession == false) 
    {   
    	getSessionID = rs.getString(4);

    	
    	if(getSessionID.equals(providedSessionID)){
    		validSession = true;
    	}
    }
    

    
    
    //the hacks begin here...
    if(validSession == true){
    	//dont touch, this shit took forever to figure out
    	
    	//update the booleanHack value to true or false depending on how old the cookieSetTime is
    	String sqlQuery = "UPDATE `user` "
                + "SET `booleanHack` = CASE "
                + "                     WHEN (NOW() > DATE_ADD(`cookieSetTime`, INTERVAL 20 MINUTE)) THEN 'TRUE' "
                + "                     ELSE 'FALSE' "
                + "                 END "
                + "WHERE `sessionID` = ?";
    	 
    	PreparedStatement pstmt = dbConn.prepareStatement(sqlQuery);
    	pstmt.setString(1, providedSessionID);
    	pstmt.executeUpdate();
    	

    	
    	//get if it is true or false and stick it in a variable
    	sqlQuery = "SELECT * FROM user WHERE sessionID = ?";
    	pstmt = dbConn.prepareStatement(sqlQuery);
    	pstmt.setString(1, providedSessionID);
    	
    	rs = pstmt.executeQuery();
    	
    	String boolResult = "";

    	while(rs.next()){ //it is nonsense that I have to parse this way, but it is the only way that works...
    		boolResult = rs.getString(6);
    		
    	}
    	
    	
    	//reset the boolean hack back to null
    	String resetBoolHack = "UPDATE user SET booleanHack = NULL WHERE sessionID = ?";
    	pstmt = dbConn.prepareStatement(resetBoolHack);
    	pstmt.setString(1, providedSessionID);
    	pstmt.executeUpdate();
    	
    	sessionExpired = Boolean.parseBoolean(boolResult);

    	
    	
    	
    	//thank god we are back to code that isnt a million little hacks
    	if(sessionExpired == true){ //if the session expired
    		response.sendRedirect("index.jsp"); //send to login page because session has expired
    	}else{ //update cookie expiration time in browser, update session set time in database
    		String updateIdQuery = "UPDATE user SET cookieSetTime = now() WHERE sessionID = ?";
    		PreparedStatement preparedStmt = dbConn.prepareStatement(updateIdQuery);
    	    preparedStmt.setString(1, getSessionID);
    	    
    	    preparedStmt.executeUpdate();
    	    
    	          
    	    Cookie cookie = new Cookie("movieSiteSessionID", getSessionID); //give user sessionID cookie
    	    cookie.setMaxAge(60*20); //20 minutes for max cookie age, may change later
    	    response.addCookie(cookie);
    	}
    	
    	
    }else{ //catch all else sends people to login page because..... well I forgot I am getting confused with all these if statements
    	response.sendRedirect("index.jsp"); //send to login page
    }
	
}

catch(SQLException e){
	out.println("ERROR: COULD NOT CONNECT TO DATABASE"); //if you see this error, you fucked something up with the database or java code that talks with the database.
}

//end of sessionID cookie verification to verify that user is actually logged in. They will be logged out after 20 minutes of not accessing resources
//Copy and paste this entire java block to the top of any web page where the user should be logged in to use it!!
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

<!--  ChatGPT code starts here -->


<%!
//send and get messages with chat gpt
public static String chatGPT(String message) {

    String url = "https://api.openai.com/v1/chat/completions";
    String apiKey = "sk-proj-DNA8YczgaXk5dO0H0n3sT3BlbkFJkqkAdVGRSiAfZoWHvaWU";
    String model = "gpt-3.5-turbo";

    try {
        URL obj = URI.create(url).toURL();
        HttpURLConnection con = (HttpURLConnection) obj.openConnection();
        con.setRequestMethod("POST");
        con.setRequestProperty("Authorization", "Bearer " + apiKey);
        con.setRequestProperty("Content-Type", "application/json");

        String body = "{\"model\": \"" + model + "\", \"messages\": [{\"role\": \"user\", \"content\": \"" + message + "\"}]}";
        con.setDoOutput(true);
        OutputStreamWriter writer = new OutputStreamWriter(con.getOutputStream());
        writer.write(body);
        writer.flush();
        writer.close();

        BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
        String inputLine;
        StringBuffer response = new StringBuffer();
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        return extractContentFromResponse(response.toString());

    } catch (IOException e) {
        throw new RuntimeException(e);
    }

}

%>


<%!
//fix the output from GPT
public static String fixIt(String input) {
    String patternToReplace = "\\\\\"";
    // Define the replacement string
    String replacement = "\"";

    // Create a Pattern object
    Pattern pattern = Pattern.compile(patternToReplace);

    // Create a Matcher object
    Matcher matcher = pattern.matcher(input);

    // Use the replaceAll() method to perform the replacement
    String result = matcher.replaceAll(replacement);

    return result;

}

%>


<%!
//puts GPT content into a string
public static String extractContentFromResponse(String response) {
    int startMarker = response.indexOf("content") + 11; // Marker for where the content starts.
    int endMarker = response.indexOf("}", startMarker); // Marker for where the content ends.
    return response.substring(startMarker, endMarker - 7); // Returns the substring containing only the response.
}

%>

<%!
//puts GPT content into a string
public static String extractContentFromResponse2(String response) {
    int startMarker = response.indexOf("\"") + 1; // Marker for where the content starts.
    int endMarker = response.indexOf("\"", startMarker); // Marker for where the content ends.
    return response.substring(startMarker, endMarker); // Returns the substring containing only the response.
}

%>





<%
String movieList = "";
String movie = "";
String rating="";
String userName="";


//get username
String getUsername = "SELECT username FROM user WHERE SessionID = ?";
PreparedStatement preparedStmt2 = dbConn.prepareStatement(getUsername);
preparedStmt2.setString(1, providedSessionID);

rs = preparedStmt2.executeQuery();

	
	while(rs.next()) {   //
		userName = rs.getString(1);
	} 
	
	



String getWatched = "SELECT * FROM watched WHERE username = ?";
PreparedStatement preparedStmt3 = dbConn.prepareStatement(getWatched);
preparedStmt3.setString(1, userName);
rs = preparedStmt3.executeQuery();

//check database to see if session id exists
while(rs.next()) 
{   
	movie = rs.getString(2);
	rating = rs.getString(3);
	
	movieList = movieList + "{" + movie + " (rating: " + rating + "/5)" + "}   ";
	
}

out.println("<br>" + movieList + "</br>");

String query = "Please recommend a movie based on the following movies and the rating I gave them out of 5: ";


String description = fixIt(chatGPT(query + movieList));
String recommendedMovie = extractContentFromResponse2(description);

out.println("<br>" + recommendedMovie + "</br>");

out.println("<br>CHATGPT RESPONSE:" + description + "</br>");

%>


<!-- ChatGPT code ends here -->


</body>
</html>
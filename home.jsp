<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page language="java" import="java.sql.*" %> 
<%@ page language="java" import="java.util.*" %> 


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
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Home Page</title>
    <link
      rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
    />
    <link rel="stylesheet" href="homestyle.css" />
  </head>
  <body>
    <div class="container">
      <nav>
        <h1>FilmFocus</h1>
        <ul>
          <li>Watch List</li>
          <li>See Recommended</li>
        </ul>
        <button class="profile"><img src="profile.png" alt="" /></button>
      </nav>
      <div class="search">
  <div class="searchInput">
    <input type="text" placeholder="Search for movie">
    <div class="resultBox">
      <!-- here list are inserted from javascript -->
    </div>
    <div class="icon"><i class="fas fa-search"></i></div>
  </div>
</div>
      <div class="content">
        <h1><br />Trending Movies</h1>
      </div>
    </div>

    <script>
    
    let suggestions = [];
    <%
  //java
  int i = 0;
  int numMovies = 0;
  st = dbConn.createStatement();
  lt = dbConn.createStatement();
  rs = st.executeQuery("SELECT * FROM movies");
  ls = lt.executeQuery("SELECT * FROM movies");

  try{
  //get num of movies
  while(rs.next()) 
  {   
  	numMovies++;

  }

  //array to store all movie names
  String[] movieList = new String[numMovies];  

  //add movie names to list
  while(ls.next()) 
  {   
  	movieList[i] = ls.getString(1);
  	i++;
  }
            		  
          		  
  //this puts all the elements in movieList into keywords
  for(i = 0; i < numMovies; i++){
  %>
  	suggestions[<%= i %>] = "<%= movieList[i] %>"
  <%
  }

  }

  catch(SQLException e){
  	out.println("ERROR: COULD NOT CONNECT TO DATABASE"); //if you see this error, you fucked something up with the database or java code that talks with the database.
  }
  %>

    // getting all required elements
    const searchInput = document.querySelector(".searchInput");
    const input = searchInput.querySelector("input");
    const resultBox = searchInput.querySelector(".resultBox");
    const icon = searchInput.querySelector(".icon");
    let linkTag = searchInput.querySelector("a");
    let webLink;

    // if user press any key and release
    input.onkeyup = (e)=>{
        let userData = e.target.value; //user enetered data
        let emptyArray = [];
        if(userData){
            emptyArray = suggestions.filter((data)=>{
                //filtering array value and user characters to lowercase and return only those words which are start with user enetered chars
                return data.toLocaleLowerCase().startsWith(userData.toLocaleLowerCase()); 
            });
            emptyArray = emptyArray.map((data)=>{
                // passing return data inside li tag
                return data = '<li>'+ data +'</li>';
            });
            searchInput.classList.add("active"); //show autocomplete box
            showSuggestions(emptyArray);
            let allList = resultBox.querySelectorAll("li");
            for (let i = 0; i < allList.length; i++) {
                //adding onclick attribute in all li tag
                allList[i].setAttribute("onclick", "select(this)");
            }
        }else{
            searchInput.classList.remove("active"); //hide autocomplete box
        }
    }

    function showSuggestions(list){
        let listData;
        if(!list.length){
            userValue = inputBox.value;
            listData = '<li>'+ userValue +'</li>';
        }else{
            listData = list.join('');
        }
        resultBox.innerHTML = listData;
    }

    </script>
  </body>
</html>


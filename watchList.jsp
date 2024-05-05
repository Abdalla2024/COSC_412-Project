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
String username = "";

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
    		username = rs.getString(1); //username to be used for toWatch list
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
	response.sendRedirect("index.jsp");
}

//end of sessionID cookie verification to verify that user is actually logged in. They will be logged out after 20 minutes of not accessing resources
//Copy and paste this entire java block to the top of any web page where the user should be logged in to use it!!
%>


    
    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Updating your To Watch queue...</title>
<link
      rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
    />
<style>
@import url("https://fonts.googleapis.com/css2?family=Montserrat:wght@100;200;300;400;500;600&display=swap");

* {
    margin: 0;
    padding: 0;
    font-family: 'Poppins', sans-serif;
    box-sizing: border-box;
}

nav {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px 0;
    background: linear-gradient(to right, #000011, #000044);
}

nav h1 {
    padding-top: 10px;
    padding-left: 20px;
    text-align: center;
    margin: 10px 20px;
    font-size: 50px; /* Adjust font size as needed */
    color: #fff;
    font-weight: bold;
}


.profile {
    width: 50px; /* Adjust the width and height to your desired size */
    height:50px;
    border-radius: 50%; /* This will make the container circular */
    overflow: hidden; /* This will hide any parts of the image that exceed the circular border */
    border: 2px solid black;
    margin-right: 20px;
    cursor: pointer;
}

.profile img {
    width: 115%; /* Increase the width of the image by 10% */
    height: 115%; /* Increase the height of the image by 10% */
    transform: translate(-6.3%, -6.3%); /* Move the image slightly to the top-left to center it */
}

.logo {
    width: 180px;
    cursor: pointer;
    margin-left: 20px;
}

nav ul li{
    padding-top: 10px;
    text-align: center;
    display: inline-block;
    margin: 10px 20px;
    font-size: 24px; /* Adjust font size as needed */
    color: #fff;
    font-weight: bold;
    cursor: pointer;
}

nav ul li button {
    width: 250px; /* Adjust width as needed */
    height: 40px; /* Adjust height as needed */
    
    background: #fff;
    font-size: 20px;
    
    border-radius: 10px; /* Half of the height, making it an oval shape */
    border: none; /* Remove default button border */
     /* Change cursor to pointer on hover */ 
}

.dropdown-content {
	display: none;
    position: absolute;
    background-color: #f9f9f9;
    min-width: 10px; /* Adjust the width of the dropdown content */
    max-width: 90px;
    box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
    z-index: 1;
    border-radius: 8px; /* Add rounded corners */
    left: -20px; /* Adjust the position to the left */
    overflow: hidden;
}

.dropdown-content a {
    color: black;
    padding: 8px 12px; /* Adjust the padding of the links */
    text-decoration: none;
    display: block;
}

.dropdown-content a:hover {
    background-color: #efefef;
    border-radius: 8px;
}

.logout-container {
    position: relative;
    display: inline-block;
}

.search{
  max-width: 450px;
  margin: 75px auto;
  margin-bottom: 75px;
}

.search .searchInput{
  background: #fff;
  width: 100%;
  border-radius: 5px;
  position: relative;
  box-shadow: 0px 1px 5px 3px rgba(0,0,0,0.12);
}

.searchInput input{
  height: 55px;
  width: 100%;
  outline: none;
  border: none;
  border-radius: 5px;
  padding: 0 60px 0 20px;
  font-size: 18px;
  box-shadow: 0px 1px 5px rgba(0,0,0,0.1);
}

.searchInput.active input{
  border-radius: 5px 5px 0 0;
}

.searchInput .resultBox {
  position: absolute;
  top: calc(100% + 5px); /* Adjust the vertical distance from the input */
  left: 0;
  width: 100%;
  background: #fff; /* Set background color */
  box-shadow: 0px 1px 5px 3px rgba(0, 0, 0, 0.12);
  border-radius: 5px;
  padding: 10px; /* Adjust padding as needed */
  opacity: 0;
  pointer-events: none;
  max-height: 280px;
  overflow-y: auto;
  z-index: 999; /* Ensure the results box appears above other content */
}

.searchInput.active .resultBox{
  padding: 10px 8px;
  opacity: 1;
  pointer-events: auto;
}

.resultBox li{
  list-style: none;
  padding: 8px 12px;
  display: none;
  width: 100%;
  cursor: default;
  border-radius: 3px;
}

.searchInput.active .resultBox li{
  display: block;
}
.resultBox li:hover{
  background: #efefef;
}

.searchInput .icon{
  position: absolute;
  right: 0px;
  top: 0px;
  height: 55px;
  width: 55px;
  text-align: center;
  line-height: 55px;
  font-size: 20px;
  color: #644bff;
  cursor: pointer;
}

.content p{
    text-align: center;
}


.movie-list {
    display: flex;
    overflow-x: auto; /* Allow horizontal scrolling if needed */
    padding: 20px 0;
    padding-left: 20px; /* Add left padding */
}

.movie {
    margin-right: 20px; /* Add spacing between movies */
    transition: transform 0.3s; /* Add smooth transition effect */
}

.movie a {
    text-decoration: none; /* Remove underline from links */
    color: inherit; /* Inherit text color */
}

.movie img {
    width: 150px; /* Set a fixed width */
    height: 200px; /* Set a fixed height */
    object-fit: cover; /* Ensure the entire area of the container is covered */
    cursor: pointer;
}

.movie p {
    margin-top: 5px;
    font-size: 16px;
    color: black;
}

.movie:hover {
    transform: scale(1.05); /* Increase size on hover */
}

button {
  display: block; /* Display buttons as block elements */
  margin: 0 auto 20px; /* Center the buttons horizontally and add bottom margin */
  width: 200px; /* Set a fixed width for the buttons */
  height: 50px; /* Set a fixed height for the buttons */
  font-size: 18px; /* Increase font size */
  background-color: #455EB5; /* Button background color */
  color: #FFFFFF; /* Button text color */
  border: none; /* Remove button border */
  border-radius: 8px; /* Apply border radius */
  cursor: pointer; /* Change cursor to pointer on hover */
  transition: all 0.3s ease; /* Add smooth transition effect */
}

button:hover {
  background-color: #5643CC; /* Change background color on hover */
}




</style>
</head>
<body>

<nav>
        <a href="home.jsp" style="text-decoration: none;"><h1>FilmFocus</h1></a>
        <ul>
          <a href="watchList.jsp"><li>Watch List</li></a>
          
          
          <a href="recommended.jsp"><li>See Recommended</li></a>
          
          
        </ul>
        <div class="logout-container">
            <button class="profile" id="logoutButton"><img src="profile.png" alt="" /></button>
    <div id="logoutDropdown" class="dropdown-content">
        <a href="logout.jsp" style="font-size: 14px">Log Out</a>
    </div>
</div>

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
        <h1><br />Movies Watched</h1>
        <div class="movie-list">
            <div class="movie">
                <a href="showMovie.jsp">
                <img src="moviePictures/1917.png">
                <p>1917</p>     
            	</a>     
            </div>
         </div>
      </div>
            

<button>Add Movie</button>
<button>See Recommended</button>

<h1>For You</h1>

<%





boolean validEntry = true;
st = dbConn.createStatement();
rs = st.executeQuery("SELECT * FROM towatch");

String movieName= request.getParameter("movieName"); //get movie name from the page


try {
	
	while(rs.next() && validEntry == true) {   //checks to see if the movie is already in the user's towatch list
		if(rs.getString(1).equals(username) && (rs.getString(3).equals(movieName))){
			validEntry = false;
		}
		 
	}
	 
	if(validEntry == false){//if it is, tell him then don't do anything else
		 out.println("<br>Movie already in your towatch list</br>");
	}else{ //if it is not, add it and tell user
		
	String sql = "INSERT INTO towatch (username, moviename) VALUES (?, ?)";
	PreparedStatement statement = dbConn.prepareStatement(sql);
	statement.setString(1, username);
    statement.setString(2, movieName);
    statement.executeUpdate();
	
	}

}
catch(SQLException e){
	out.println("ERROR: COULD NOT CONNECT TO DATABASE"); //if you see this error, you fucked something up with the database or java code that talks with the database.
}

%>

<Script>

var logoutButton = document.getElementById("logoutButton");
var dropdown = document.getElementById("logoutDropdown");

logoutButton.addEventListener("click", function(event) {
    event.stopPropagation(); // Prevent the click event from propagating to the document
    if (dropdown.style.display === "none" || dropdown.style.display === "") {
        dropdown.style.display = "block"; // Show the dropdown if it's hidden
    } else {
        dropdown.style.display = "none"; // Hide the dropdown if it's shown
    }
});

document.addEventListener("click", function(event) {
    if (event.target !== logoutButton) {
        dropdown.style.display = "none"; // Hide the dropdown when clicking outside of it
    }
});

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


function select(el){
	console.log(this.constructor.name)
}

</script>

<form id="myForm" action="showMovie.jsp" method="post">
	<input type="hidden" name="sendSearchResults" id="myField" value="" />
</form>


<script>
	function select(el) {
	    // Extract the text content of the clicked element
	    var selectedText = el.textContent;
	    
	    // Do whatever you need with the selected text
	    document.getElementById('myField').value = selectedText;
	    //console.log("Selected text:", selectedText);
	    
        // Submit the form
        document.getElementById('myForm').submit();
	}
</script>

</body>
</html>
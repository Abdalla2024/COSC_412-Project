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
	response.sendRedirect("index.jsp"); //send to login page
}

//end of sessionID cookie verification to verify that user is actually logged in. They will be logged out after 20 minutes of not accessing resources
//Copy and paste this entire java block to the top of any web page where the user should be logged in to use it!!
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Results Page</title>
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

body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
    background-color: #f2f2f2;
}

.container {
    max-width: 1200px;
    margin: 50px auto;
    display: flex;
    align-items: center;
    justify-content: flex-start; /* Align items to the left */
    margin-left: 50px;
}

.movie-image p {
margin-bottom: 30px;
font-size: 20px;
}

.movie-image img {
    width: 70%;
    height: auto;
}

.movie-info {
    width: 50%; /* Adjust the width */
    padding: 40px 20px; /* Add padding */
    background-color: #fff;
    border-radius: 10px;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.2);
   
}

.movie-info p {
    margin-bottom: 20px; /* Add more spacing between different descriptions */
}

/* Additional styles for better readability */
.movie-title {
    margin-top: 0;
    color: #333;
    font-size: 2em;
    margin-bottom: 30px;
}

.add-to-watch-list {
    margin-left: calc(50% - 100px); /* Adjust 100px to half of the button's width */
    padding: 15px 30px; /* Increase padding to make the button bigger */
    font-size: 16px; /* Increase font size */
    background-color: #007bff; /* Button color */
    color: #fff; /* Text color */
    border: none;
    border-radius: 8px; /* Increase border radius for rounded corners */
    cursor: pointer;
}

.add-to-watch-list:hover {
    background-color: #0056b3; /* Hover color */
}

/* Modal Popup Styles */
.modal {
  display: none; /* Hidden by default */
  position: fixed;
  z-index: 9999;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5); /* Semi-transparent background */
}

.modal button {
	margin-top: 20px;
    padding: 15px 30px; /* Increase padding to make the button bigger */
    font-size: 16px; /* Increase font size */
    background-color: #007bff; /* Button color */
    color: #fff; /* Text color */
    border: none;
    border-radius: 8px; /* Increase border radius for rounded corners */
    cursor: pointer;
}

.modal button:hover {
	background-color: #0056b3; /* Hover color */
}

.modal-content {
  background-color: #fff;
  margin: 10% auto; /* Adjust the margin for vertical centering */
  padding: 60px; /* Increase padding to make it longer up and down */
  border-radius: 15px; /* Squared corners */
  width: 50%;
  text-align: center; /* Center the content */
}
.close {
  color: #aaa;
  float: right;
  font-size: 28px;
  font-weight: bold;
}

.close:hover,
.close:focus {
  color: black;
  text-decoration: none;
  cursor: pointer;
}

.star {
  width: 400px;
}

.star > * {
  float: right;
}

.star label {
  height: 50px;
  width: 50px;
  position: relative;
  cursor: pointer;
  padding: 0 10px;
}

.star label:after {
  transition: all 1s ease-out;
  position: absolute;
  content: '☆';
  color: orange;
  font-size: 65px;
}

.star label:nth-of-type(5):after {
  animation-delay: 5 * .1s;
}
.star label:nth-of-type(4):after {
  animation-delay: 4 * .1s;
}
.star label:nth-of-type(3):after {
  animation-delay: 3 * .1s;
}
.star label:nth-of-type(2):after {
  animation-delay: 2 * .1s;
}
.star label:nth-of-type(1):after {
  animation-delay: 1 * .1s;
}

.star input {
  display: none;
}

.star input:checked + label:after,
.star input:checked ~ label:after {
  content: '★';
  color: gold;
  text-shadow: 0 0 10px gold;
}

/* Add more styles as needed */


</style>
</head>
<body>

<nav>
        <a href="home.jsp" style="text-decoration: none;"><h1>FilmFocus</h1></a>
        <ul>
          <a href="addToWatch.jsp"><li>Watch List</li></a>
          
          
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

<%


String movieSearch = request.getParameter("sendSearchResults");
String name = "Issue getting name from DB...";
String director = "Issue getting director from DB...";
String genre = "Issue getting genre from DB...";
String year = "Issue getting year from DB...";
String description = "Issue getting description from DB...";


st = dbConn.createStatement();
String selectMovieName = "SELECT * FROM movies WHERE name = ?";
PreparedStatement searchStatement = dbConn.prepareStatement(selectMovieName);
searchStatement.setString(1, movieSearch);
rs = searchStatement.executeQuery();

try {
	
	while(rs.next()) {   //
		name = rs.getString(1);
		director = rs.getString(2);
		genre = rs.getString(3);
		year = Integer.toString((rs.getInt(4)));
		description = rs.getString(5);
	}
}
	catch(SQLException e){
		out.println("ERROR: COULD NOT CONNECT TO DATABASE"); //if you see this error, you fucked something up with the database or java code that talks with the database.
	}





%>

<div class="container">
        <div class="movie-image">
        <p>Search results for <%out.print("\"" + name  + "\"");%></p>
            <img src="moviePictures/<%out.print(name);%>.png">
        </div>
        <div class="movie-info">
            <h2 class="movie-title"><% out.println(name); %></h2>
            <p><strong>Director:</strong> <% out.println(director); %></p>
            <p><strong>Genre:</strong><% out.println(genre); %></p>
            <p><strong>Year:</strong><% out.println(year); %></p>
            <p><strong>Description:</strong><% out.println(description); %></p>
            <button id="addToWatchListBtn" class="add-to-watch-list">Add to Watch List</button>
        </div>
    </div>


<div id="myModal" class="modal">
  <form id="ratingForm" class="modal-content" action="addToWatch.jsp" method="post">
  <input type="hidden" name="movieName" value="<%= name %>">
    <span class="close">&times;</span>
    <h2>Rate this movie</h2>
    <div class="star">
      <input type="radio" id="r1" name="rating" value="1">
      <label for="r1"></label>

      <input type="radio" id="r2" name="rating" value="2">
      <label for="r2"></label>

      <input type="radio" id="r3" name="rating" value="3">
      <label for="r3"></label>

      <input type="radio" id="r4" name="rating" value="4">
      <label for="r4"></label>

      <input type="radio" id="r5" name="rating" value="5">
      <label for="r5"></label>
    
    	
    </div>
    

    <button type="submit" id="movieRatedBtn">Add to Watch List</button>
  </form>
</div>

<%

String pictureName = "moviePictures/" + name;

%>



<script>

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


//Get the modal
var modal = document.getElementById("myModal");

// Get the button that opens the modal
var btn = document.getElementById("addToWatchListBtn");

// Get the <span> element that closes the modal
var closeBtn = document.getElementsByClassName("close")[0];

// When the user clicks the button, open the modal
btn.onclick = function() {
  modal.style.display = "block";
}

// When the user clicks on <span> (x), close the modal
closeBtn.onclick = function() {
  modal.style.display = "none";
}

// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
  if (event.target == modal) {
    modal.style.display = "none";
  }
}

// Function to handle adding to watch list from modal
document.getElementById("addToWatchListBtnModal").onclick = function() {
  // Add your logic to handle adding to watch list here
  alert("Added to Watch List!");
  modal.style.display = "none"; // Close the modal after adding to watch list
}

document.querySelectorAll('.star input').forEach(input => {
	  input.addEventListener('click', function() {
	    if (this.checked) {
	      this.checked = false;
	    } else {
	      this.checked = true;
	    }
	  });
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
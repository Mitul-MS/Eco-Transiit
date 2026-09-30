<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>Save Favorite Route</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>

<div class="navbar">

    <h2>EcoTransit</h2>

    <div>
        <a href="dashboard.jsp">Home</a>
        <a href="impact.jsp">Your Impact</a>
        <a href="leaderboard.jsp">Leaderboard</a>
        <a href="monthly.jsp">Emission Summary</a>
        <a href="profile.jsp">Profile</a>
    </div>

</div>


<div class="container">

<%
    Object studentIdObject =
        session.getAttribute("studentId");

    String pickup =
        request.getParameter("pickup");

    String destination =
        request.getParameter("destination");


    if (studentIdObject == null) {

        response.sendRedirect("index.jsp");

        return;
    }


    if (pickup == null ||
        destination == null ||
        pickup.trim().isEmpty() ||
        destination.trim().isEmpty()) {
%>

    <div class="card">

        <h2>
            Invalid Route
        </h2>

        <p>
            Pickup and destination are required.
        </p>

        <br>

        <a href="dashboard.jsp">
            Back to Dashboard
        </a>

    </div>

<%
        return;
    }


    int studentId =
        (Integer) studentIdObject;

    pickup =
        pickup.trim();

    destination =
        destination.trim();


    try {

        Connection con =
            com.greenmobility.DBConnection.getConnection();


        String checkSql =
            "SELECT favorite_id " +
            "FROM favorite_routes " +
            "WHERE student_id = ? " +
            "AND LOWER(pickup_location) = LOWER(?) " +
            "AND LOWER(destination_location) = LOWER(?)";


        PreparedStatement checkStmt =
            con.prepareStatement(checkSql);

        checkStmt.setInt(1, studentId);
        checkStmt.setString(2, pickup);
        checkStmt.setString(3, destination);


        ResultSet checkRs =
            checkStmt.executeQuery();


        if (checkRs.next()) {

            checkRs.close();
            checkStmt.close();
            con.close();
%>

            <div class="card">

                <h2>
                    Route Already Saved
                </h2>

                <p>
                    This route is already in your
                    favorite routes.
                </p>

                <br>

                <a href="profile.jsp">
                    View Favorite Routes
                </a>

                <br><br>

                <a href="dashboard.jsp">
                    Back to Dashboard
                </a>

            </div>

<%
            return;
        }


        checkRs.close();
        checkStmt.close();


        String insertSql =
            "INSERT INTO favorite_routes " +
            "(student_id, pickup_location, " +
            "destination_location) " +
            "VALUES (?, ?, ?)";


        PreparedStatement insertStmt =
            con.prepareStatement(insertSql);

        insertStmt.setInt(1, studentId);
        insertStmt.setString(2, pickup);
        insertStmt.setString(3, destination);


        insertStmt.executeUpdate();

        insertStmt.close();
        con.close();

%>


    <div class="card">

        <h1>
            Route Saved
        </h1>

        <p>
            Your favorite route has been saved successfully.
        </p>

        <hr>

        <h2>
            <%= pickup %>
        </h2>

        <p>
            to
        </p>

        <h2>
            <%= destination %>
        </h2>

        <br>

        <a href="profile.jsp">
            View Favorite Routes
        </a>

        <br><br>

        <a href="dashboard.jsp">
            Back to Dashboard
        </a>

    </div>


<%
    } catch (Exception e) {
%>


    <div class="card">

        <h2>
            Could Not Save Route
        </h2>

        <p>
            <%= e.getMessage() %>
        </p>

        <br>

        <a href="dashboard.jsp">
            Back to Dashboard
        </a>

    </div>


<%
    }
%>


</div>

</body>

</html>
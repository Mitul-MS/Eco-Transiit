<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>Available Transport</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>

<div class="navbar">

    <h2>Green Mobility</h2>

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
    String pickup =
        request.getParameter("pickup");

    String destination =
        request.getParameter("destination");


    if (pickup == null ||
        destination == null ||
        pickup.trim().isEmpty() ||
        destination.trim().isEmpty()) {
%>

    <div class="card">

        <h2>
            Enter your journey
        </h2>

        <p>
            Please enter a pickup location and
            destination first.
        </p>

        <br>

        <a href="dashboard.jsp">
            Back to Search
        </a>

    </div>

<%
        return;
    }


    pickup =
        pickup.trim();

    destination =
        destination.trim();


    String searchedRoute =
        pickup + " to " + destination;
%>


<div class="card">

    <h1>
        Available Transport
    </h1>

    <p>
        <strong><%= pickup %></strong>
        to
        <strong><%= destination %></strong>
    </p>

    <br>

    <a href="addFavorite.jsp?pickup=<%= java.net.URLEncoder.encode(pickup, "UTF-8") %>&destination=<%= java.net.URLEncoder.encode(destination, "UTF-8") %>">
        Save Route
    </a>

</div>


<%
    try {

        Connection con =
            com.greenmobility.DBConnection.getConnection();


        String sql =
            "SELECT * FROM Vehicles_Slots " +
            "WHERE LOWER(route) = LOWER(?) " +
            "AND vehicle_status = 'Available' " +
            "AND booked_count < capacity " +
            "ORDER BY slot_time";


        PreparedStatement stmt =
            con.prepareStatement(sql);

        stmt.setString(1, searchedRoute);


        ResultSet rs =
            stmt.executeQuery();


        boolean found = false;


        while (rs.next()) {

            found = true;


            int slotId =
                rs.getInt("slot_id");

            String vehicle =
                rs.getString("vehicle_type");

            String model =
                rs.getString("vehicle_model");

            String fuel =
                rs.getString("fuel_type");

            Timestamp time =
                rs.getTimestamp("slot_time");

            int capacity =
                rs.getInt("capacity");

            int booked =
                rs.getInt("booked_count");

            int available =
                capacity - booked;

            boolean zeroEmission =
                rs.getBoolean("zero_emission");

            double distance =
                rs.getDouble("distance_km");
%>


<div class="card transport-card">

    <h2>
        <%= model %>
    </h2>


    <p>

        <strong>
            <%= fuel %>
        </strong>

        <% if (zeroEmission) { %>

            · Zero Emission

        <% } %>

    </p>


    <hr>


    <p>

        <strong>
            Vehicle
        </strong>

        <br>

        <%= vehicle %>

    </p>


    <p>

        <strong>
            Departure
        </strong>

        <br>

        <%= time %>

    </p>


    <p>

        <strong>
            Distance
        </strong>

        <br>

        <%= String.format(
            "%.1f",
            distance
        ) %>
        km

    </p>


    <p>

        <strong>
            Seats Available
        </strong>

        <br>

        <%= available %>

    </p>


    <p>

        <strong>
            Capacity
        </strong>

        <br>

        <%= capacity %>
        passengers

    </p>


    <br>


    <form
        action="book.jsp"
        method="post"
    >

        <input
            type="hidden"
            name="slotId"
            value="<%= slotId %>"
        >

        <button type="submit">
            Book Ride
        </button>

    </form>


    <br>


    <a href="scheduleRide.jsp?slotId=<%= slotId %>">
        Schedule Ride
    </a>


</div>


<%
        }


        if (!found) {
%>


<div class="card">

    <h2>
        No transport available
    </h2>

    <p>
        There are currently no available green
        transportation options for this journey.
    </p>

    <br>

    <a href="dashboard.jsp">
        Search Another Journey
    </a>

</div>


<%
        }


        rs.close();
        stmt.close();
        con.close();


    } catch (Exception e) {
%>


<div class="card">

    <h2>
        Error loading transport
    </h2>

    <p>
        <%= e.getMessage() %>
    </p>

</div>


<%
    }
%>


</div>

</body>

</html>
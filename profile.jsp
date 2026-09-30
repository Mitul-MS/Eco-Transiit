<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>My Profile</title>
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


<%
    Object studentIdObject =
        session.getAttribute("studentId");

    if (studentIdObject == null) {

        response.sendRedirect("index.jsp");

        return;
    }


    int studentId =
        (Integer) studentIdObject;


    String studentName = "";
    String email = "";

    double totalCo2 = 0;
    double totalDistance = 0;

    int totalRides = 0;


    try {

        Connection con =
            com.greenmobility.DBConnection.getConnection();


        String sql =
            "SELECT " +
            "s.name, " +
            "s.email, " +
            "s.total_co2_saved_kg, " +
            "COUNT(b.booking_id) AS total_rides, " +
            "COALESCE(SUM(b.distance_km), 0) AS total_distance " +
            "FROM Students s " +
            "LEFT JOIN Bookings b " +
            "ON s.student_id = b.student_id " +
            "AND b.booking_status = 'Confirmed' " +
            "WHERE s.student_id = ? " +
            "GROUP BY s.student_id, s.name, " +
            "s.email, s.total_co2_saved_kg";


        PreparedStatement stmt =
            con.prepareStatement(sql);

        stmt.setInt(1, studentId);


        ResultSet rs =
            stmt.executeQuery();


        if (rs.next()) {

            studentName =
                rs.getString("name");

            email =
                rs.getString("email");

            totalCo2 =
                rs.getDouble("total_co2_saved_kg");

            totalRides =
                rs.getInt("total_rides");

            totalDistance =
                rs.getDouble("total_distance");
        }


        rs.close();
        stmt.close();

        con.close();


    } catch (Exception e) {

        out.println(
            "<p>Error loading profile: "
            + e.getMessage()
            + "</p>"
        );

    }
%>


<div class="container">


    <div class="hero-content">

        <h1>
            My Profile
        </h1>

        <p>
            Your Green Mobility journey
        </p>

    </div>


    <div class="card">

        <h2>
            <%= studentName %>
        </h2>

        <p>
            <%= email %>
        </p>

    </div>


    <div class="section">

        <div class="section-title">

            <h2>
                Your Statistics
            </h2>

        </div>


        <div class="impact-grid">


            <div class="impact-card">

                <h2>
                    <%= totalRides %>
                </h2>

                <p>
                    Green Rides
                </p>

            </div>


            <div class="impact-card">

                <h2>
                    <%= String.format(
                        "%.1f",
                        totalDistance
                    ) %>
                    km
                </h2>

                <p>
                    Green Distance
                </p>

            </div>


            <div class="impact-card">

                <h2>
                    <%= String.format(
                        "%.2f",
                        totalCo2
                    ) %>
                    kg
                </h2>

                <p>
                    CO2 Saved
                </p>

            </div>


        </div>

    </div>


    <div class="section">

        <div class="section-title">

            <h2>
                Favorite Routes
            </h2>

            <p>
                Your saved journeys for quicker access.
            </p>

        </div>


<%
    try {

        Connection favoriteCon =
            com.greenmobility.DBConnection.getConnection();


        String favoriteSql =
            "SELECT " +
            "favorite_id, " +
            "pickup_location, " +
            "destination_location " +
            "FROM favorite_routes " +
            "WHERE student_id = ? " +
            "ORDER BY favorite_id DESC";


        PreparedStatement favoriteStmt =
            favoriteCon.prepareStatement(favoriteSql);

        favoriteStmt.setInt(1, studentId);


        ResultSet favoriteRs =
            favoriteStmt.executeQuery();


        boolean hasFavorites = false;


        while (favoriteRs.next()) {

            hasFavorites = true;


            String pickup =
                favoriteRs.getString(
                    "pickup_location"
                );


            String destination =
                favoriteRs.getString(
                    "destination_location"
                );
%>


        <div class="card">

            <h2>
                <%= pickup %>
                →
                <%= destination %>
            </h2>

            <p>
                Saved Route
            </p>

            <br>

            <a href="slots.jsp?pickup=<%= java.net.URLEncoder.encode(pickup, "UTF-8") %>&destination=<%= java.net.URLEncoder.encode(destination, "UTF-8") %>">
                Search This Route
            </a>

        </div>


<%
        }


        if (!hasFavorites) {
%>


        <div class="card">

            <h2>
                No Favorite Routes Yet
            </h2>

            <p>
                Save a route from the ride search page
                and it will appear here.
            </p>

            <br>

            <a href="dashboard.jsp">
                Search for a Ride
            </a>

        </div>


<%
        }


        favoriteRs.close();
        favoriteStmt.close();
        favoriteCon.close();


    } catch (Exception e) {

        out.println(
            "<div class='card'>" +
            "<h2>Error loading favorite routes</h2>" +
            "<p>" + e.getMessage() + "</p>" +
            "</div>"
        );

    }
%>


    </div>


    <div class="section">

        <div class="section-title">

            <h2>
                Upcoming Scheduled Rides
            </h2>

            <p>
                Your rides planned for the future.
            </p>

        </div>


<%
    try {

        Connection scheduleCon =
            com.greenmobility.DBConnection.getConnection();


        String scheduleSql =
            "SELECT " +
            "sr.schedule_id, " +
            "sr.scheduled_date, " +
            "sr.scheduled_time, " +
            "sr.booking_status, " +
            "v.vehicle_model, " +
            "v.vehicle_type, " +
            "v.fuel_type, " +
            "v.route " +
            "FROM scheduled_rides sr " +
            "JOIN Vehicles_Slots v " +
            "ON sr.slot_id = v.slot_id " +
            "WHERE sr.student_id = ? " +
            "AND sr.booking_status = 'Upcoming' " +
            "ORDER BY sr.scheduled_date, " +
            "sr.scheduled_time";


        PreparedStatement scheduleStmt =
            scheduleCon.prepareStatement(scheduleSql);

        scheduleStmt.setInt(1, studentId);


        ResultSet scheduleRs =
            scheduleStmt.executeQuery();


        boolean hasScheduledRides = false;


        while (scheduleRs.next()) {

            hasScheduledRides = true;


            int scheduleId =
                scheduleRs.getInt("schedule_id");


            String model =
                scheduleRs.getString(
                    "vehicle_model"
                );


            String vehicle =
                scheduleRs.getString(
                    "vehicle_type"
                );


            String fuel =
                scheduleRs.getString(
                    "fuel_type"
                );


            String route =
                scheduleRs.getString(
                    "route"
                );


            Date date =
                scheduleRs.getDate(
                    "scheduled_date"
                );


            Time time =
                scheduleRs.getTime(
                    "scheduled_time"
                );


            String status =
                scheduleRs.getString(
                    "booking_status"
                );
%>


        <div class="card">

            <h2>
                <%= model %>
            </h2>

            <p>
                <strong>
                    Vehicle:
                </strong>
                <%= vehicle %>
            </p>

            <p>
                <strong>
                    Type:
                </strong>
                <%= fuel %>
            </p>

            <p>
                <strong>
                    Route:
                </strong>
                <%= route %>
            </p>

            <p>
                <strong>
                    Date:
                </strong>
                <%= date %>
            </p>

            <p>
                <strong>
                    Time:
                </strong>
                <%= time %>
            </p>

            <p>
                <strong>
                    Status:
                </strong>
                <%= status %>
            </p>


            <br>


            <form
                action="cancelSchedule.jsp"
                method="post"
                onsubmit="return confirm('Are you sure you want to cancel this scheduled ride?');"
            >

                <input
                    type="hidden"
                    name="scheduleId"
                    value="<%= scheduleId %>"
                >

                <button type="submit">
                    Cancel Scheduled Ride
                </button>

            </form>

        </div>


<%
        }


        if (!hasScheduledRides) {
%>


        <div class="card">

            <h2>
                No Upcoming Rides
            </h2>

            <p>
                You don't have any scheduled rides yet.
            </p>

            <br>

            <a href="dashboard.jsp">
                Schedule a Ride
            </a>

        </div>


<%
        }


        scheduleRs.close();
        scheduleStmt.close();
        scheduleCon.close();


    } catch (Exception e) {

        out.println(
            "<div class='card'>" +
            "<h2>Error loading scheduled rides</h2>" +
            "<p>" + e.getMessage() + "</p>" +
            "</div>"
        );

    }
%>


    </div>


    <div class="section">

        <div class="section-title">

            <h2>
                Booking History
            </h2>

            <p>
                View your previous journeys and
                individual CO2 savings.
            </p>

        </div>


        <div class="card">

            <a href="mybookings.jsp">
                View My Bookings
            </a>

        </div>

    </div>


    <div class="section">

        <div class="section-title">

            <h2>
                Shared Rides
            </h2>

            <p>
                Travel with other students going
                the same way.
            </p>

        </div>


        <div class="card">

            <p>
                Create a shared ride or join one
                using a private ride code.
            </p>

            <br>

            <a href="sharedride.jsp">
                Open Shared Rides
            </a>

        </div>

    </div>


    <div class="section">

        <div class="section-title">

            <h2>
                Referral
            </h2>

            <p>
                Invite other students to join
                Green Mobility.
            </p>

        </div>


        <div class="card">

            <p>
                Your referral link will appear here.
            </p>

        </div>

    </div>


    <br>


    <a href="logout.jsp">

        <button type="button">
            Logout
        </button>

    </a>


</div>

</body>

</html>
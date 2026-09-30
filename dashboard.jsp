<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>EcoTransit</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>

<div class="navbar">

    <h2>EcoTransit</h2>

    <div>
        <a href="impact.jsp">Your Impact</a>
        <a href="leaderboard.jsp">Leaderboard</a>
        <a href="monthly.jsp">Emission Summary</a>
        <a href="profile.jsp">Profile</a>
    </div>

</div>


<%
    Object studentIdObject =
        session.getAttribute("studentId");

    Object studentNameObject =
        session.getAttribute("studentName");


    if (studentIdObject == null) {

        response.sendRedirect("index.jsp");

        return;
    }


    int studentId =
        (Integer) studentIdObject;

    String studentName =
        String.valueOf(studentNameObject);


    double totalCo2 = 0;
    double totalDistance = 0;

    int totalRides = 0;
    int participatingStudents = 0;
    int zeroEmissionRides = 0;
    int sharedJourneys = 0;


    String previousVehicle = "";
    String previousRoute = "";
    Timestamp previousTime = null;

    double previousDistance = 0;
    double previousCo2 = 0;

    boolean hasPreviousRide = false;


    try {

        Connection con =
            com.greenmobility.DBConnection.getConnection();


        String impactSql =
            "SELECT " +
            "COUNT(*) AS total_rides, " +
            "COALESCE(SUM(distance_km), 0) AS total_distance, " +
            "COALESCE(SUM(co2_saved_kg), 0) AS total_co2 " +
            "FROM Bookings " +
            "WHERE booking_status = 'Confirmed'";


        PreparedStatement impactStmt =
            con.prepareStatement(impactSql);


        ResultSet impactRs =
            impactStmt.executeQuery();


        if (impactRs.next()) {

            totalRides =
                impactRs.getInt("total_rides");

            totalDistance =
                impactRs.getDouble("total_distance");

            totalCo2 =
                impactRs.getDouble("total_co2");
        }


        impactRs.close();
        impactStmt.close();


        String studentSql =
            "SELECT COUNT(DISTINCT student_id) " +
            "AS participating_students " +
            "FROM Bookings " +
            "WHERE booking_status = 'Confirmed'";


        PreparedStatement studentStmt =
            con.prepareStatement(studentSql);


        ResultSet studentRs =
            studentStmt.executeQuery();


        if (studentRs.next()) {

            participatingStudents =
                studentRs.getInt(
                    "participating_students"
                );
        }


        studentRs.close();
        studentStmt.close();


        String zeroSql =
            "SELECT COUNT(*) AS zero_rides " +
            "FROM Bookings b " +
            "JOIN Vehicles_Slots v " +
            "ON b.slot_id = v.slot_id " +
            "WHERE v.zero_emission = TRUE " +
            "AND b.booking_status = 'Confirmed'";


        PreparedStatement zeroStmt =
            con.prepareStatement(zeroSql);


        ResultSet zeroRs =
            zeroStmt.executeQuery();


        if (zeroRs.next()) {

            zeroEmissionRides =
                zeroRs.getInt("zero_rides");
        }


        zeroRs.close();
        zeroStmt.close();


        String sharedSql =
            "SELECT COUNT(*) AS shared_journeys " +
            "FROM Ride_Participants " +
            "WHERE student_id = ? " +
            "AND participant_status = 'Joined'";


        PreparedStatement sharedStmt =
            con.prepareStatement(sharedSql);


        sharedStmt.setInt(1, studentId);


        ResultSet sharedRs =
            sharedStmt.executeQuery();


        if (sharedRs.next()) {

            sharedJourneys =
                sharedRs.getInt("shared_journeys");
        }


        sharedRs.close();
        sharedStmt.close();


        String previousSql =
            "SELECT " +
            "v.vehicle_model, " +
            "v.route, " +
            "v.slot_time, " +
            "b.distance_km, " +
            "b.co2_saved_kg " +
            "FROM Bookings b " +
            "JOIN Vehicles_Slots v " +
            "ON b.slot_id = v.slot_id " +
            "WHERE b.student_id = ? " +
            "AND b.booking_status = 'Confirmed' " +
            "ORDER BY b.booked_at DESC " +
            "LIMIT 1";


        PreparedStatement previousStmt =
            con.prepareStatement(previousSql);


        previousStmt.setInt(1, studentId);


        ResultSet previousRs =
            previousStmt.executeQuery();


        if (previousRs.next()) {

            hasPreviousRide = true;


            previousVehicle =
                previousRs.getString(
                    "vehicle_model"
                );


            previousRoute =
                previousRs.getString(
                    "route"
                );


            previousTime =
                previousRs.getTimestamp(
                    "slot_time"
                );


            previousDistance =
                previousRs.getDouble(
                    "distance_km"
                );


            previousCo2 =
                previousRs.getDouble(
                    "co2_saved_kg"
                );
        }


        previousRs.close();
        previousStmt.close();


        con.close();


    } catch (Exception e) {

        out.println(
            "<div class='card'>" +
            "<p>Error loading dashboard data: " +
            e.getMessage() +
            "</p>" +
            "</div>"
        );

    }
%>


<div class="container">


    <div class="hero-content">

        <h1>
            Welcome, <%= studentName %>
        </h1>

        <p>
            Where are you going today?
        </p>

    </div>


    <div class="card">

        <form
            action="slots.jsp"
            method="get"
        >

            <label>
                Pickup Location
            </label>

            <input
                type="text"
                name="pickup"
                placeholder="Enter pickup location"
                required
            >


            <br>


            <label>
                Destination
            </label>

            <input
                type="text"
                name="destination"
                placeholder="Enter destination"
                required
            >


            <br>


            <button type="submit">
                Search Rides
            </button>

        </form>


        <br>


        <p>
            Want to travel with other students?
        </p>


        <a href="sharedride.jsp">
            Join or Create a Shared Ride
        </a>

    </div>


    <div class="card">

        <h2>
            Previous Ride
        </h2>


<%
    if (hasPreviousRide) {
%>


        <h3>
            <%= previousVehicle %>
        </h3>


        <p>
            <strong>
                Route:
            </strong>

            <%= previousRoute %>
        </p>


        <p>
            <strong>
                Ride Time:
            </strong>

            <%= previousTime %>
        </p>


        <p>
            <strong>
                Distance:
            </strong>

            <%= String.format(
                "%.1f",
                previousDistance
            ) %>
            km
        </p>


        <p>
            <strong>
                CO2 Saved:
            </strong>

            <%= String.format(
                "%.2f",
                previousCo2
            ) %>
            kg
        </p>


        <br>


        <a href="mybookings.jsp">
            View Ride History
        </a>


<%
    } else {
%>


        <p>
            You haven't completed a green ride yet.
        </p>


        <br>


        <a href="dashboard.jsp">
            Find Your First Ride
        </a>


<%
    }
%>


    </div>


    <div class="section">


        <div class="section-title">

            <h2>
                Our Impact
            </h2>

            <p>
                Together, every greener journey moves
                our campus towards a cleaner future.
            </p>

        </div>


        <div class="impact-grid">


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
                    <%= participatingStudents %>
                </h2>

                <p>
                    Students Participating
                </p>

            </div>


            <div class="impact-card">

                <h2>
                    <%= zeroEmissionRides %>
                </h2>

                <p>
                    Zero-Emission Rides
                </p>

            </div>


            <div class="impact-card">

                <h2>
                    <%= sharedJourneys %>
                </h2>

                <p>
                    Shared Journeys
                </p>

            </div>


        </div>

    </div>


    <br><br>


    <a href="logout.jsp">

        <button type="button">
            Logout
        </button>

    </a>


</div>

</body>

</html>
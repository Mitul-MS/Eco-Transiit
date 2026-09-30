<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>My Bookings</title>
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

    <div class="hero-content">

        <h1>My Bookings</h1>

        <p>
            View your green journeys and manage your bookings.
        </p>

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


    try {

        Connection con =
            com.greenmobility.DBConnection.getConnection();


        String sql =
            "SELECT " +
            "b.booking_id, " +
            "b.ride_group_id, " +
            "b.booking_status, " +
            "v.vehicle_model, " +
            "v.vehicle_type, " +
            "v.route, " +
            "v.slot_time, " +
            "b.distance_km, " +
            "b.co2_saved_kg, " +
            "b.booked_at " +
            "FROM Bookings b " +
            "JOIN Vehicles_Slots v " +
            "ON b.slot_id = v.slot_id " +
            "WHERE b.student_id = ? " +
            "ORDER BY b.booked_at DESC";


        PreparedStatement stmt =
            con.prepareStatement(sql);

        stmt.setInt(1, studentId);


        ResultSet rs =
            stmt.executeQuery();


        boolean hasBookings = false;


        while (rs.next()) {

            hasBookings = true;


            int bookingId =
                rs.getInt("booking_id");

            int rideGroupId =
                rs.getInt("ride_group_id");

            String bookingStatus =
                rs.getString("booking_status");

            String vehicleModel =
                rs.getString("vehicle_model");

            String vehicleType =
                rs.getString("vehicle_type");

            String route =
                rs.getString("route");

            Timestamp slotTime =
                rs.getTimestamp("slot_time");

            double distance =
                rs.getDouble("distance_km");

            double co2Saved =
                rs.getDouble("co2_saved_kg");

            Timestamp bookedAt =
                rs.getTimestamp("booked_at");
%>


<div class="card">

    <h2>
        <%= vehicleModel %>
    </h2>

    <p>
        <strong>Vehicle:</strong>
        <%= vehicleType %>
    </p>

    <p>
        <strong>Route:</strong>
        <%= route %>
    </p>

    <p>
        <strong>Ride Time:</strong>
        <%= slotTime %>
    </p>

    <p>
        <strong>Distance:</strong>
        <%= String.format("%.1f", distance) %> km
    </p>

    <p>
        <strong>CO2 Saved:</strong>
        <%= String.format("%.2f", co2Saved) %> kg
    </p>

    <p>
        <strong>Booked At:</strong>
        <%= bookedAt %>
    </p>

    <p>
        <strong>Status:</strong>
        <%= bookingStatus %>
    </p>


<%
    if ("Confirmed".equalsIgnoreCase(bookingStatus)
        && rideGroupId > 0) {
%>


    <br>

    <form
        action="cancelRide.jsp"
        method="post"
        onsubmit="return confirm('Are you sure you want to cancel this ride?');"
    >

        <input
            type="hidden"
            name="bookingId"
            value="<%= bookingId %>"
        >

        <button type="submit">
            Cancel Ride
        </button>

    </form>


<%
    } else if ("Cancelled".equalsIgnoreCase(bookingStatus)) {
%>


    <p>
        This ride has been cancelled.
    </p>


<%
    }
%>


</div>


<%
        }


        if (!hasBookings) {
%>


<div class="card">

    <h2>
        No Bookings Yet
    </h2>

    <p>
        You haven't booked any green rides yet.
    </p>

    <br>

    <a href="dashboard.jsp">
        Find a Ride
    </a>

</div>


<%
        }


        rs.close();
        stmt.close();


        String totalSql =
            "SELECT total_co2_saved_kg " +
            "FROM Students " +
            "WHERE student_id = ?";


        PreparedStatement totalStmt =
            con.prepareStatement(totalSql);

        totalStmt.setInt(1, studentId);


        ResultSet totalRs =
            totalStmt.executeQuery();


        if (totalRs.next()) {
%>


<div class="card">

    <h2>
        Total CO2 Saved
    </h2>

    <h1>
        <%= String.format(
            "%.2f",
            totalRs.getDouble("total_co2_saved_kg")
        ) %>
        kg
    </h1>

</div>


<%
        }


        totalRs.close();
        totalStmt.close();

        con.close();

%>


<br>

<a href="dashboard.jsp">
    Back to Dashboard
</a>

<br><br>

<a href="sharedride.jsp">
    Shared Ride
</a>


<%
    } catch (Exception e) {

        out.println(
            "<div class='card'>" +
            "<h2>Error loading bookings</h2>" +
            "<p>" + e.getMessage() + "</p>" +
            "</div>"
        );

    }
%>


</div>

</body>

</html>
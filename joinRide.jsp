<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>Join Shared Ride</title>
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

    if (studentIdObject == null) {

        response.sendRedirect("index.jsp");

        return;
    }

    int studentId =
        (Integer) studentIdObject;

    String shareCode =
        request.getParameter("shareCode");


    if (shareCode == null ||
        shareCode.trim().isEmpty()) {
%>


    <div class="card">

        <h2>Enter a Shared Ride Code</h2>

        <p>
            Please enter the code provided by
            the student who created the ride.
        </p>

        <br>

        <a href="sharedride.jsp">
            Back to Shared Ride
        </a>

    </div>


<%
        return;
    }


    shareCode =
        shareCode.trim().toUpperCase();


    try {

        Connection con =
            com.greenmobility.DBConnection.getConnection();


        /*
         * Find the exact shared ride.
         */

        String rideSql =
            "SELECT " +
            "r.ride_group_id, " +
            "r.slot_id, " +
            "r.ride_status, " +
            "v.vehicle_model, " +
            "v.vehicle_type, " +
            "v.fuel_type, " +
            "v.route, " +
            "v.slot_time, " +
            "v.capacity, " +
            "v.booked_count " +
            "FROM Ride_Groups r " +
            "JOIN Vehicles_Slots v " +
            "ON r.slot_id = v.slot_id " +
            "WHERE r.share_code = ? " +
            "AND r.ride_status = 'Active'";


        PreparedStatement rideStmt =
            con.prepareStatement(rideSql);

        rideStmt.setString(1, shareCode);


        ResultSet rideRs =
            rideStmt.executeQuery();


        if (!rideRs.next()) {

            rideRs.close();
            rideStmt.close();
            con.close();
%>


            <div class="card">

                <h2>Ride Not Found</h2>

                <p>
                    This shared ride code is invalid
                    or the ride is no longer active.
                </p>

                <br>

                <a href="sharedride.jsp">
                    Try Another Code
                </a>

            </div>


<%
            return;
        }


        int rideGroupId =
            rideRs.getInt("ride_group_id");

        int slotId =
            rideRs.getInt("slot_id");

        String model =
            rideRs.getString("vehicle_model");

        String vehicle =
            rideRs.getString("vehicle_type");

        String fuel =
            rideRs.getString("fuel_type");

        String route =
            rideRs.getString("route");

        Timestamp time =
            rideRs.getTimestamp("slot_time");

        int capacity =
            rideRs.getInt("capacity");

        int bookedCount =
            rideRs.getInt("booked_count");


        rideRs.close();
        rideStmt.close();


        /*
         * Check whether this student
         * is already part of the ride.
         */

        String participantCheck =
            "SELECT participant_id, participant_status " +
            "FROM Ride_Participants " +
            "WHERE ride_group_id = ? " +
            "AND student_id = ?";


        PreparedStatement participantCheckStmt =
            con.prepareStatement(participantCheck);

        participantCheckStmt.setInt(1, rideGroupId);
        participantCheckStmt.setInt(2, studentId);


        ResultSet participantRs =
            participantCheckStmt.executeQuery();


        if (participantRs.next()) {

            String status =
                participantRs.getString("participant_status");


            participantRs.close();
            participantCheckStmt.close();
            con.close();
%>


            <div class="card">

                <h2>
                    Already Joined
                </h2>

                <p>
                    You are already associated with
                    this shared ride.
                </p>

                <p>
                    Status:
                    <strong><%= status %></strong>
                </p>

                <br>

                <a href="sharedride.jsp">
                    Back to Shared Ride
                </a>

            </div>


<%
            return;
        }


        participantRs.close();
        participantCheckStmt.close();


        /*
         * Check remaining capacity.
         */

        if (bookedCount >= capacity) {

            con.close();
%>


            <div class="card">

                <h2>
                    Ride Full
                </h2>

                <p>
                    Unfortunately, this vehicle has
                    no seats remaining.
                </p>

                <br>

                <a href="dashboard.jsp">
                    Search Other Rides
                </a>

            </div>


<%
            return;
        }


        /*
         * Add the student as a participant.
         */

        String insertParticipant =
            "INSERT INTO Ride_Participants " +
            "(ride_group_id, student_id) " +
            "VALUES (?, ?)";


        PreparedStatement participantStmt =
            con.prepareStatement(insertParticipant);


        participantStmt.setInt(1, rideGroupId);
        participantStmt.setInt(2, studentId);


        participantStmt.executeUpdate();


        participantStmt.close();


        /*
         * Reserve one more seat.
         */

        String updateSlot =
            "UPDATE Vehicles_Slots " +
            "SET booked_count = booked_count + 1 " +
            "WHERE slot_id = ?";


        PreparedStatement updateStmt =
            con.prepareStatement(updateSlot);


        updateStmt.setInt(1, slotId);


        updateStmt.executeUpdate();


        updateStmt.close();


        con.close();

%>


    <div class="card">

        <h1>
            Ride Joined
        </h1>

        <p>
            You have successfully joined the shared ride.
        </p>

        <hr>

        <h2>
            <%= model %>
        </h2>

        <p>
            <strong>Vehicle:</strong>
            <%= vehicle %>
        </p>

        <p>
            <strong>Type:</strong>
            <%= fuel %>
        </p>

        <p>
            <strong>Route:</strong>
            <%= route %>
        </p>

        <p>
            <strong>Departure:</strong>
            <%= time %>
        </p>

        <hr>

        <p>
            <strong>Shared Ride Code:</strong>
            <%= shareCode %>
        </p>

        <br>

        <p>
            You are now a participant in this
            specific shared ride.
        </p>

        <br>

        <a href="sharedride.jsp">
            Shared Ride Home
        </a>

        <br><br>

        <a href="mybookings.jsp">
            My Bookings
        </a>

    </div>


<%
    } catch (Exception e) {
%>


    <div class="card">

        <h2>
            Could Not Join Ride
        </h2>

        <p>
            <%= e.getMessage() %>
        </p>

        <br>

        <a href="sharedride.jsp">
            Try Again
        </a>

    </div>


<%
    }
%>


</div>

</body>

</html>
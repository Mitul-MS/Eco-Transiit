<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>Schedule Confirmation</title>
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

    String slotIdStr =
        request.getParameter("slotId");

    String scheduledDate =
        request.getParameter("scheduledDate");

    String scheduledTime =
        request.getParameter("scheduledTime");


    if (studentIdObject == null) {

        response.sendRedirect("index.jsp");

        return;
    }


    if (slotIdStr == null ||
        scheduledDate == null ||
        scheduledTime == null ||
        scheduledDate.trim().isEmpty() ||
        scheduledTime.trim().isEmpty()) {
%>

    <div class="card">

        <h2>
            Invalid Schedule
        </h2>

        <p>
            Please provide a valid date and time.
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

    int slotId =
        Integer.parseInt(slotIdStr);


    try {

        java.time.LocalDate selectedDate =
            java.time.LocalDate.parse(
                scheduledDate
            );

        java.time.LocalTime selectedTime =
            java.time.LocalTime.parse(
                scheduledTime
            );

        java.time.LocalDate today =
            java.time.LocalDate.now();


        if (selectedDate.isBefore(today)) {
%>

    <div class="card">

        <h2>
            Invalid Date
        </h2>

        <p>
            You cannot schedule a ride for a
            date that has already passed.
        </p>

        <br>

        <a href="scheduleRide.jsp?slotId=<%= slotId %>">
            Choose Another Date
        </a>

    </div>

<%
            return;
        }


        Connection con =
            com.greenmobility.DBConnection.getConnection();


        String slotSql =
            "SELECT " +
            "vehicle_model, " +
            "vehicle_type, " +
            "fuel_type, " +
            "route " +
            "FROM Vehicles_Slots " +
            "WHERE slot_id = ? " +
            "AND vehicle_status = 'Available'";


        PreparedStatement slotStmt =
            con.prepareStatement(slotSql);

        slotStmt.setInt(1, slotId);


        ResultSet slotRs =
            slotStmt.executeQuery();


        if (!slotRs.next()) {

            slotRs.close();
            slotStmt.close();
            con.close();
%>

            <div class="card">

                <h2>
                    Ride Not Available
                </h2>

                <p>
                    The selected transport is no longer
                    available.
                </p>

                <br>

                <a href="dashboard.jsp">
                    Back to Dashboard
                </a>

            </div>

<%
            return;
        }


        String model =
            slotRs.getString("vehicle_model");

        String vehicle =
            slotRs.getString("vehicle_type");

        String fuel =
            slotRs.getString("fuel_type");

        String route =
            slotRs.getString("route");


        slotRs.close();
        slotStmt.close();


        String duplicateSql =
            "SELECT schedule_id " +
            "FROM scheduled_rides " +
            "WHERE student_id = ? " +
            "AND slot_id = ? " +
            "AND scheduled_date = ? " +
            "AND scheduled_time = ? " +
            "AND booking_status = 'Upcoming'";


        PreparedStatement duplicateStmt =
            con.prepareStatement(duplicateSql);

        duplicateStmt.setInt(1, studentId);
        duplicateStmt.setInt(2, slotId);
        duplicateStmt.setDate(
            3,
            java.sql.Date.valueOf(selectedDate)
        );
        duplicateStmt.setTime(
            4,
            java.sql.Time.valueOf(
                selectedTime
            )
        );


        ResultSet duplicateRs =
            duplicateStmt.executeQuery();


        if (duplicateRs.next()) {

            duplicateRs.close();
            duplicateStmt.close();
            con.close();
%>

            <div class="card">

                <h2>
                    Ride Already Scheduled
                </h2>

                <p>
                    You already have this transport
                    scheduled for the selected date
                    and time.
                </p>

                <br>

                <a href="profile.jsp">
                    View Your Profile
                </a>

            </div>

<%
            return;
        }


        duplicateRs.close();
        duplicateStmt.close();


        String insertSql =
            "INSERT INTO scheduled_rides " +
            "(student_id, slot_id, " +
            "scheduled_date, scheduled_time, " +
            "booking_status) " +
            "VALUES (?, ?, ?, ?, 'Upcoming')";


        PreparedStatement insertStmt =
            con.prepareStatement(insertSql);


        insertStmt.setInt(1, studentId);
        insertStmt.setInt(2, slotId);

        insertStmt.setDate(
            3,
            java.sql.Date.valueOf(selectedDate)
        );

        insertStmt.setTime(
            4,
            java.sql.Time.valueOf(selectedTime)
        );


        insertStmt.executeUpdate();

        insertStmt.close();

        con.close();

%>


<div class="card">

    <h1>
        Ride Scheduled
    </h1>

    <p>
        Your ride has been scheduled successfully.
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
        <strong>Date:</strong>
        <%= selectedDate %>
    </p>

    <p>
        <strong>Time:</strong>
        <%= selectedTime %>
    </p>

    <hr>

    <p>
        <strong>Status:</strong>
        Upcoming
    </p>

    <br>

    <a href="profile.jsp">
        View Scheduled Rides
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
        Could Not Schedule Ride
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
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>Cancel Scheduled Ride</title>
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

    String scheduleIdStr =
        request.getParameter("scheduleId");


    if (studentIdObject == null) {

        response.sendRedirect("index.jsp");

        return;
    }


    if (scheduleIdStr == null ||
        scheduleIdStr.trim().isEmpty()) {
%>

    <div class="card">

        <h2>
            Invalid Scheduled Ride
        </h2>

        <p>
            No scheduled ride was selected.
        </p>

        <br>

        <a href="profile.jsp">
            Back to Profile
        </a>

    </div>

<%
        return;
    }


    int studentId =
        (Integer) studentIdObject;

    int scheduleId =
        Integer.parseInt(scheduleIdStr);


    Connection con = null;


    try {

        con =
            com.greenmobility.DBConnection.getConnection();

        con.setAutoCommit(false);


        String checkSql =
            "SELECT schedule_id, booking_status " +
            "FROM scheduled_rides " +
            "WHERE schedule_id = ? " +
            "AND student_id = ? " +
            "FOR UPDATE";


        PreparedStatement checkStmt =
            con.prepareStatement(checkSql);

        checkStmt.setInt(1, scheduleId);
        checkStmt.setInt(2, studentId);


        ResultSet checkRs =
            checkStmt.executeQuery();


        if (!checkRs.next()) {

            checkRs.close();
            checkStmt.close();

            con.rollback();
            con.close();
%>

            <div class="card">

                <h2>
                    Scheduled Ride Not Found
                </h2>

                <p>
                    This scheduled ride does not
                    belong to your account.
                </p>

                <br>

                <a href="profile.jsp">
                    Back to Profile
                </a>

            </div>

<%
            return;
        }


        String status =
            checkRs.getString("booking_status");


        checkRs.close();
        checkStmt.close();


        if (!"Upcoming".equalsIgnoreCase(status)) {

            con.rollback();
            con.close();
%>

            <div class="card">

                <h2>
                    Ride Already Cancelled
                </h2>

                <p>
                    This scheduled ride is no longer active.
                </p>

                <br>

                <a href="profile.jsp">
                    Back to Profile
                </a>

            </div>

<%
            return;
        }


        String updateSql =
            "UPDATE scheduled_rides " +
            "SET booking_status = 'Cancelled' " +
            "WHERE schedule_id = ? " +
            "AND student_id = ?";


        PreparedStatement updateStmt =
            con.prepareStatement(updateSql);

        updateStmt.setInt(1, scheduleId);
        updateStmt.setInt(2, studentId);

        updateStmt.executeUpdate();

        updateStmt.close();


        con.commit();

        con.close();

%>


<div class="card">

    <h1>
        Scheduled Ride Cancelled
    </h1>

    <p>
        Your scheduled ride has been cancelled successfully.
    </p>

    <p>
        The vehicle and other students' bookings
        have not been affected.
    </p>

    <br>

    <a href="profile.jsp">
        Back to Profile
    </a>

    <br><br>

    <a href="dashboard.jsp">
        Find Another Ride
    </a>

</div>


<%
    } catch (Exception e) {

        if (con != null) {

            try {
                con.rollback();
            } catch (Exception ignored) {
            }

            try {
                con.close();
            } catch (Exception ignored) {
            }
        }
%>


<div class="card">

    <h2>
        Cancellation Failed
    </h2>

    <p>
        <%= e.getMessage() %>
    </p>

    <br>

    <a href="profile.jsp">
        Back to Profile
    </a>

</div>


<%
    }
%>


</div>

</body>

</html>
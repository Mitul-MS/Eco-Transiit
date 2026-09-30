<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>Cancel Ride</title>
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

    String bookingIdStr =
        request.getParameter("bookingId");


    if (studentIdObject == null ||
        bookingIdStr == null) {

        response.sendRedirect("index.jsp");

        return;
    }


    int studentId =
        (Integer) studentIdObject;

    int bookingId =
        Integer.parseInt(bookingIdStr);


    Connection con = null;


    try {

        con =
            com.greenmobility.DBConnection.getConnection();

        con.setAutoCommit(false);


        String bookingSql =
            "SELECT " +
            "b.slot_id, " +
            "b.ride_group_id, " +
            "b.co2_saved_kg, " +
            "b.booking_status " +
            "FROM Bookings b " +
            "WHERE b.booking_id = ? " +
            "AND b.student_id = ? " +
            "FOR UPDATE";


        PreparedStatement bookingStmt =
            con.prepareStatement(bookingSql);

        bookingStmt.setInt(1, bookingId);
        bookingStmt.setInt(2, studentId);


        ResultSet bookingRs =
            bookingStmt.executeQuery();


        if (!bookingRs.next()) {

            bookingRs.close();
            bookingStmt.close();
            con.rollback();
            con.close();
%>

            <div class="card">

                <h2>Booking Not Found</h2>

                <p>
                    This booking does not belong to
                    your account.
                </p>

                <br>

                <a href="mybookings.jsp">
                    Back to My Bookings
                </a>

            </div>

<%
            return;
        }


        int slotId =
            bookingRs.getInt("slot_id");

        int rideGroupId =
            bookingRs.getInt("ride_group_id");

        double co2Saved =
            bookingRs.getDouble("co2_saved_kg");

        String bookingStatus =
            bookingRs.getString("booking_status");


        bookingRs.close();
        bookingStmt.close();


        if (!"Confirmed".equalsIgnoreCase(bookingStatus)) {

            con.rollback();
            con.close();
%>

            <div class="card">

                <h2>Ride Already Cancelled</h2>

                <p>
                    This booking is no longer active.
                </p>

                <br>

                <a href="mybookings.jsp">
                    Back to My Bookings
                </a>

            </div>

<%
            return;
        }


        if (rideGroupId <= 0) {

            con.rollback();
            con.close();
%>

            <div class="card">

                <h2>Cancellation Not Available</h2>

                <p>
                    This is not a shared ride booking.
                </p>

                <br>

                <a href="mybookings.jsp">
                    Back to My Bookings
                </a>

            </div>

<%
            return;
        }


        String participantSql =
            "SELECT participant_id, participant_status " +
            "FROM Ride_Participants " +
            "WHERE ride_group_id = ? " +
            "AND student_id = ? " +
            "FOR UPDATE";


        PreparedStatement participantStmt =
            con.prepareStatement(participantSql);

        participantStmt.setInt(1, rideGroupId);
        participantStmt.setInt(2, studentId);


        ResultSet participantRs =
            participantStmt.executeQuery();


        if (!participantRs.next()) {

            participantRs.close();
            participantStmt.close();
            con.rollback();
            con.close();
%>

            <div class="card">

                <h2>Participant Record Not Found</h2>

                <p>
                    Your participation in this shared ride
                    could not be found.
                </p>

                <br>

                <a href="mybookings.jsp">
                    Back to My Bookings
                </a>

            </div>

<%
            return;
        }


        int participantId =
            participantRs.getInt("participant_id");

        String participantStatus =
            participantRs.getString("participant_status");


        participantRs.close();
        participantStmt.close();


        if (!"Joined".equalsIgnoreCase(participantStatus)) {

            con.rollback();
            con.close();
%>

            <div class="card">

                <h2>Already Cancelled</h2>

                <p>
                    You are no longer an active participant
                    in this shared ride.
                </p>

                <br>

                <a href="mybookings.jsp">
                    Back to My Bookings
                </a>

            </div>

<%
            return;
        }


        String updateParticipant =
            "UPDATE Ride_Participants " +
            "SET participant_status = 'Cancelled' " +
            "WHERE participant_id = ?";


        PreparedStatement updateParticipantStmt =
            con.prepareStatement(updateParticipant);

        updateParticipantStmt.setInt(1, participantId);

        updateParticipantStmt.executeUpdate();

        updateParticipantStmt.close();


        String updateBooking =
            "UPDATE Bookings " +
            "SET booking_status = 'Cancelled' " +
            "WHERE booking_id = ?";


        PreparedStatement updateBookingStmt =
            con.prepareStatement(updateBooking);

        updateBookingStmt.setInt(1, bookingId);

        updateBookingStmt.executeUpdate();

        updateBookingStmt.close();


        String updateSlot =
            "UPDATE Vehicles_Slots " +
            "SET booked_count = " +
            "CASE " +
            "WHEN booked_count > 0 " +
            "THEN booked_count - 1 " +
            "ELSE 0 " +
            "END " +
            "WHERE slot_id = ?";


        PreparedStatement updateSlotStmt =
            con.prepareStatement(updateSlot);

        updateSlotStmt.setInt(1, slotId);

        updateSlotStmt.executeUpdate();

        updateSlotStmt.close();


        String updateStudent =
            "UPDATE Students " +
            "SET total_co2_saved_kg = " +
            "CASE " +
            "WHEN total_co2_saved_kg >= ? " +
            "THEN total_co2_saved_kg - ? " +
            "ELSE 0 " +
            "END " +
            "WHERE student_id = ?";


        PreparedStatement updateStudentStmt =
            con.prepareStatement(updateStudent);

        updateStudentStmt.setDouble(1, co2Saved);
        updateStudentStmt.setDouble(2, co2Saved);
        updateStudentStmt.setInt(3, studentId);

        updateStudentStmt.executeUpdate();

        updateStudentStmt.close();


        con.commit();

        con.close();

%>


<div class="card">

    <h1>
        Ride Cancelled
    </h1>

    <p>
        Your participation in the shared ride
        has been cancelled successfully.
    </p>

    <hr>

    <p>
        The shared ride itself is still active.
    </p>

    <p>
        Other students in the vehicle are
        not affected by your cancellation.
    </p>

    <p>
        The seat has been released for another student.
    </p>

    <hr>

    <p>
        <strong>
            <%= String.format("%.2f", co2Saved) %> kg
        </strong>
        of CO2 savings has been removed from
        your personal impact.
    </p>

    <br>

    <a href="mybookings.jsp">
        View My Bookings
    </a>

    <br><br>

    <a href="impact.jsp">
        View Your Impact
    </a>

    <br><br>

    <a href="dashboard.jsp">
        Back to Dashboard
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

    <a href="mybookings.jsp">
        Back to My Bookings
    </a>

</div>


<%
    }
%>


</div>

</body>

</html>
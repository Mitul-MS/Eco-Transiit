<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>Booking Confirmation</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>

<div class="navbar">

    <h2>EcoTransit</h2>

    <div>
        <a href="dashboard.jsp">Home</a>
        <a href="monthly.jsp">Your Impact</a>
        <a href="leaderboard.jsp">Leaderboard</a>
        <a href="monthly.jsp">Emission Summary</a>
        <a href="#">Profile</a>
    </div>

</div>


<div class="container">

<%
    Object studentIdObject =
        session.getAttribute("studentId");

    String slotIdStr =
        request.getParameter("slotId");

    if (studentIdObject == null ||
        slotIdStr == null) {

        out.println("<div class='card'>");
        out.println("<h2>Invalid booking request.</h2>");
        out.println("<a href='dashboard.jsp'>Back to Dashboard</a>");
        out.println("</div>");

        return;
    }

    int studentId =
        (Integer) studentIdObject;

    int slotId =
        Integer.parseInt(slotIdStr);

    Connection con = null;

    try {

        con =
            com.greenmobility.DBConnection.getConnection();


        /*
         * Check whether the student has
         * already booked this transport slot.
         */

        String checkBooking =
            "SELECT booking_id " +
            "FROM Bookings " +
            "WHERE student_id = ? " +
            "AND slot_id = ?";

        PreparedStatement checkStmt =
            con.prepareStatement(checkBooking);

        checkStmt.setInt(1, studentId);
        checkStmt.setInt(2, slotId);

        ResultSet bookingResult =
            checkStmt.executeQuery();


        if (bookingResult.next()) {

            bookingResult.close();
            checkStmt.close();
            con.close();
%>

            <div class="card">

                <h2>Already Booked</h2>

                <p>
                    You have already booked this transport.
                </p>

                <br>

                <a href="mybookings.jsp">
                    View My Bookings
                </a>

            </div>

<%
            return;
        }


        bookingResult.close();
        checkStmt.close();


        /*
         * Get transport information
         * including route distance and
         * emission factor.
         */

        String slotSql =
            "SELECT capacity, booked_count, " +
            "vehicle_type, vehicle_model, " +
            "fuel_type, route, slot_time, " +
            "distance_km, co2_per_km, " +
            "zero_emission " +
            "FROM Vehicles_Slots " +
            "WHERE slot_id = ?";

        PreparedStatement slotStmt =
            con.prepareStatement(slotSql);

        slotStmt.setInt(1, slotId);

        ResultSet slotResult =
            slotStmt.executeQuery();


        if (!slotResult.next()) {

            slotResult.close();
            slotStmt.close();
            con.close();
%>

            <div class="card">

                <h2>Transport Not Found</h2>

                <p>
                    The selected transport could not be found.
                </p>

                <br>

                <a href="dashboard.jsp">
                    Back to Dashboard
                </a>

            </div>

<%
            return;
        }


        int capacity =
            slotResult.getInt("capacity");

        int bookedCount =
            slotResult.getInt("booked_count");

        String vehicle =
            slotResult.getString("vehicle_type");

        String model =
            slotResult.getString("vehicle_model");

        String fuel =
            slotResult.getString("fuel_type");

        String route =
            slotResult.getString("route");

        Timestamp time =
            slotResult.getTimestamp("slot_time");

        double distance =
            slotResult.getDouble("distance_km");

        double co2PerKm =
            slotResult.getDouble("co2_per_km");

        boolean zeroEmission =
            slotResult.getBoolean("zero_emission");


        slotResult.close();
        slotStmt.close();


        /*
         * Check capacity.
         */

        if (bookedCount >= capacity) {

            con.close();
%>

            <div class="card">

                <h2>Sorry, this transport is full.</h2>

                <p>
                    Please choose another available ride.
                </p>

                <br>

                <a href="dashboard.jsp">
                    Search Again
                </a>

            </div>

<%
            return;
        }


        /*
         * Calculate CO2 savings.
         *
         * Baseline assumed:
         * 0.12 kg CO2 saved per km.
         *
         * The actual vehicle emission
         * factor is also retrieved so
         * the calculation can be
         * improved later.
         */

        double baselineCo2PerKm = 0.12;

        double vehicleEmission =
            distance * co2PerKm;

        double baselineEmission =
            distance * baselineCo2PerKm;

        double co2Saved =
            baselineEmission - vehicleEmission;


        if (co2Saved < 0) {
            co2Saved = 0;
        }


        /*
         * Insert booking.
         */

        String insertSql =
            "INSERT INTO Bookings " +
            "(student_id, slot_id, " +
            "distance_km, co2_saved_kg) " +
            "VALUES (?, ?, ?, ?)";

        PreparedStatement insertStmt =
            con.prepareStatement(insertSql);

        insertStmt.setInt(1, studentId);
        insertStmt.setInt(2, slotId);
        insertStmt.setDouble(3, distance);
        insertStmt.setDouble(4, co2Saved);

        insertStmt.executeUpdate();

        insertStmt.close();


        /*
         * Increase booked seats.
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


        /*
         * Update student's total
         * environmental contribution.
         */

        String updateStudent =
            "UPDATE Students " +
            "SET total_co2_saved_kg = " +
            "total_co2_saved_kg + ? " +
            "WHERE student_id = ?";

        PreparedStatement studentStmt =
            con.prepareStatement(updateStudent);

        studentStmt.setDouble(1, co2Saved);
        studentStmt.setInt(2, studentId);

        studentStmt.executeUpdate();

        studentStmt.close();

%>


<div class="card">

    <h1>Booking Confirmed</h1>

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
        <% if (zeroEmission) { %>
            · Zero Emission
        <% } %>
    </p>

    <p>
        <strong>Route:</strong>
        <%= route %>
    </p>

    <p>
        <strong>Departure:</strong>
        <%= time %>
    </p>

    <p>
        <strong>Distance:</strong>
        <%= String.format("%.1f", distance) %> km
    </p>

    <hr>

    <h2>
        CO2 Saved:
        <%= String.format("%.2f", co2Saved) %> kg
    </h2>

    <br>

    <a href="dashboard.jsp">
        Back to Dashboard
    </a>

    <br><br>

    <a href="mybookings.jsp">
        View My Bookings
    </a>

</div>


<%
        con.close();

    } catch (Exception e) {

        if (con != null) {
            con.close();
        }
%>


<div class="card">

    <h2>Booking Failed</h2>

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
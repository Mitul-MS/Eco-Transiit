<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.UUID" %>

<!DOCTYPE html>
<html>

<head>
    <title>Create Shared Ride</title>
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

    String selectedSlotStr =
        request.getParameter("slotId");


    if (selectedSlotStr == null) {
%>

    <div class="hero-content">

        <h1>Create a Shared Ride</h1>

        <p>
            Choose a transport option and create
            a ride that specific students can join.
        </p>

    </div>


<%
        try {

            Connection con =
                com.greenmobility.DBConnection.getConnection();

            String sql =
                "SELECT * FROM Vehicles_Slots " +
                "WHERE vehicle_status = 'Available' " +
                "AND booked_count < capacity " +
                "ORDER BY slot_time";

            PreparedStatement stmt =
                con.prepareStatement(sql);

            ResultSet rs =
                stmt.executeQuery();


            while (rs.next()) {

                int slotId =
                    rs.getInt("slot_id");

                String model =
                    rs.getString("vehicle_model");

                String route =
                    rs.getString("route");

                String fuel =
                    rs.getString("fuel_type");

                Timestamp time =
                    rs.getTimestamp("slot_time");

                int available =
                    rs.getInt("capacity")
                    - rs.getInt("booked_count");
%>


    <div class="card transport-card">

        <h2>
            <%= model %>
        </h2>

        <p>
            <strong>Route:</strong>
            <%= route %>
        </p>

        <p>
            <strong>Type:</strong>
            <%= fuel %>
        </p>

        <p>
            <strong>Departure:</strong>
            <%= time %>
        </p>

        <p>
            <strong>Seats Available:</strong>
            <%= available %>
        </p>

        <form action="createRide.jsp" method="post">

            <input
                type="hidden"
                name="slotId"
                value="<%= slotId %>"
            >

            <button type="submit">
                Create Shared Ride
            </button>

        </form>

    </div>


<%
            }

            rs.close();
            stmt.close();
            con.close();

        } catch (Exception e) {

            out.println(
                "<p>Error loading transport: "
                + e.getMessage()
                + "</p>"
            );
        }
%>


<%
    } else {

        int slotId =
            Integer.parseInt(selectedSlotStr);

        Connection con = null;

        try {

            con =
                com.greenmobility.DBConnection.getConnection();


            String slotSql =
                "SELECT capacity, booked_count, " +
                "vehicle_model, vehicle_type, " +
                "fuel_type, route, slot_time, " +
                "distance_km, co2_per_km, " +
                "zero_emission " +
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

                    <h2>Transport unavailable</h2>

                    <p>
                        Please choose another transport.
                    </p>

                    <br>

                    <a href="createRide.jsp">
                        Choose Another Transport
                    </a>

                </div>

<%
                return;
            }


            int capacity =
                slotRs.getInt("capacity");

            int bookedCount =
                slotRs.getInt("booked_count");

            String model =
                slotRs.getString("vehicle_model");

            String vehicle =
                slotRs.getString("vehicle_type");

            String fuel =
                slotRs.getString("fuel_type");

            String route =
                slotRs.getString("route");

            Timestamp time =
                slotRs.getTimestamp("slot_time");

            double distance =
                slotRs.getDouble("distance_km");

            double co2PerKm =
                slotRs.getDouble("co2_per_km");

            boolean zeroEmission =
                slotRs.getBoolean("zero_emission");


            slotRs.close();
            slotStmt.close();


            if (bookedCount >= capacity) {

                con.close();
%>

                <div class="card">

                    <h2>This transport is full.</h2>

                    <p>
                        Please choose another transport.
                    </p>

                    <br>

                    <a href="createRide.jsp">
                        Choose Another Transport
                    </a>

                </div>

<%
                return;
            }


            String existingBookingSql =
                "SELECT booking_id " +
                "FROM Bookings " +
                "WHERE student_id = ? " +
                "AND slot_id = ?";

            PreparedStatement existingStmt =
                con.prepareStatement(existingBookingSql);

            existingStmt.setInt(1, studentId);
            existingStmt.setInt(2, slotId);

            ResultSet existingRs =
                existingStmt.executeQuery();


            if (existingRs.next()) {

                existingRs.close();
                existingStmt.close();
                con.close();
%>

                <div class="card">

                    <h2>Already Booked</h2>

                    <p>
                        You have already booked this transport.
                        You cannot create another shared ride
                        using the same booking.
                    </p>

                    <br>

                    <a href="mybookings.jsp">
                        View My Bookings
                    </a>

                </div>

<%
                return;
            }


            existingRs.close();
            existingStmt.close();


            double baselineCo2PerKm = 0.12;

            double baselineEmission =
                distance * baselineCo2PerKm;

            double vehicleEmission =
                distance * co2PerKm;

            double co2Saved =
                baselineEmission - vehicleEmission;


            if (co2Saved < 0) {
                co2Saved = 0;
            }


            String shareCode =
                "GM-" +
                UUID.randomUUID()
                    .toString()
                    .substring(0, 6)
                    .toUpperCase();


            String insertRide =
                "INSERT INTO Ride_Groups " +
                "(slot_id, created_by, share_code) " +
                "VALUES (?, ?, ?)";

            PreparedStatement rideStmt =
                con.prepareStatement(
                    insertRide,
                    Statement.RETURN_GENERATED_KEYS
                );

            rideStmt.setInt(1, slotId);
            rideStmt.setInt(2, studentId);
            rideStmt.setString(3, shareCode);

            rideStmt.executeUpdate();


            ResultSet keys =
                rideStmt.getGeneratedKeys();

            int rideGroupId = 0;

            if (keys.next()) {

                rideGroupId =
                    keys.getInt(1);
            }


            keys.close();
            rideStmt.close();


            String participantSql =
                "INSERT INTO Ride_Participants " +
                "(ride_group_id, student_id) " +
                "VALUES (?, ?)";

            PreparedStatement participantStmt =
                con.prepareStatement(participantSql);

            participantStmt.setInt(1, rideGroupId);
            participantStmt.setInt(2, studentId);

            participantStmt.executeUpdate();

            participantStmt.close();


            String bookingSql =
                "INSERT INTO Bookings " +
                "(student_id, slot_id, " +
                "distance_km, co2_saved_kg, " +
                "ride_group_id) " +
                "VALUES (?, ?, ?, ?, ?)";

            PreparedStatement bookingStmt =
                con.prepareStatement(bookingSql);

            bookingStmt.setInt(1, studentId);
            bookingStmt.setInt(2, slotId);
            bookingStmt.setDouble(3, distance);
            bookingStmt.setDouble(4, co2Saved);
            bookingStmt.setInt(5, rideGroupId);

            bookingStmt.executeUpdate();

            bookingStmt.close();


            String updateSlot =
                "UPDATE Vehicles_Slots " +
                "SET booked_count = booked_count + 1 " +
                "WHERE slot_id = ?";

            PreparedStatement updateStmt =
                con.prepareStatement(updateSlot);

            updateStmt.setInt(1, slotId);

            updateStmt.executeUpdate();

            updateStmt.close();


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


            con.close();

%>


    <div class="card">

        <h1>
            Shared Ride Created
        </h1>

        <p>
            Your shared ride is ready.
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
            Your CO2 Savings
        </h2>

        <h1>
            <%= String.format("%.2f", co2Saved) %> kg
        </h1>

        <p>
            This shared ride has been added to your
            personal environmental impact.
        </p>

        <hr>

        <h2>
            Share Code
        </h2>

        <h1>
            <%= shareCode %>
        </h1>

        <p>
            Give this code only to the students
            you want to join your shared ride.
        </p>

        <br>

        <a href="sharedride.jsp">
            Shared Ride Home
        </a>

        <br><br>

        <a href="mybookings.jsp">
            View My Booking
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
                con.close();
            }

            out.println(
                "<div class='card'>" +
                "<h2>Could not create shared ride</h2>" +
                "<p>" + e.getMessage() + "</p>" +
                "</div>"
            );
        }
    }
%>


</div>

</body>

</html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>Schedule Ride</title>
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
    Object studentIdObject =
        session.getAttribute("studentId");

    String slotIdStr =
        request.getParameter("slotId");


    if (studentIdObject == null) {

        response.sendRedirect("index.jsp");

        return;
    }


    if (slotIdStr == null ||
        slotIdStr.trim().isEmpty()) {
%>

    <div class="card">

        <h2>
            Invalid Ride
        </h2>

        <p>
            Please select a ride before scheduling it.
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
%>


<div class="hero-content">

    <h1>
        Schedule Your Ride
    </h1>

    <p>
        Choose the date and time for your journey.
    </p>

</div>


<%
    try {

        Connection con =
            com.greenmobility.DBConnection.getConnection();


        String sql =
            "SELECT " +
            "vehicle_model, " +
            "vehicle_type, " +
            "fuel_type, " +
            "route, " +
            "slot_time, " +
            "capacity, " +
            "booked_count " +
            "FROM Vehicles_Slots " +
            "WHERE slot_id = ? " +
            "AND vehicle_status = 'Available'";


        PreparedStatement stmt =
            con.prepareStatement(sql);

        stmt.setInt(1, slotId);


        ResultSet rs =
            stmt.executeQuery();


        if (!rs.next()) {

            rs.close();
            stmt.close();
            con.close();
%>

            <div class="card">

                <h2>
                    Ride Not Available
                </h2>

                <p>
                    The selected transport could not
                    be found or is unavailable.
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
            rs.getString("vehicle_model");

        String vehicle =
            rs.getString("vehicle_type");

        String fuel =
            rs.getString("fuel_type");

        String route =
            rs.getString("route");

        Timestamp slotTime =
            rs.getTimestamp("slot_time");

        int capacity =
            rs.getInt("capacity");

        int bookedCount =
            rs.getInt("booked_count");


        int available =
            capacity - bookedCount;


        rs.close();
        stmt.close();
        con.close();
%>


<div class="card">

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
        <strong>Regular Departure:</strong>
        <%= slotTime %>
    </p>

    <p>
        <strong>Seats Available:</strong>
        <%= available %>
    </p>

</div>


<div class="card">

    <h2>
        Choose Your Schedule
    </h2>

    <form
        action="saveSchedule.jsp"
        method="post"
    >

        <input
            type="hidden"
            name="slotId"
            value="<%= slotId %>"
        >


        <label>
            Date
        </label>

        <input
            type="date"
            name="scheduledDate"
            required
        >


        <br><br>


        <label>
            Time
        </label>

        <input
            type="time"
            name="scheduledTime"
            value="<%= new java.text.SimpleDateFormat("HH:mm").format(slotTime) %>"
            required
        >


        <br><br>


        <button type="submit">
            Schedule Ride
        </button>

    </form>

</div>


<%
    } catch (Exception e) {
%>

<div class="card">

    <h2>
        Could Not Load Ride
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
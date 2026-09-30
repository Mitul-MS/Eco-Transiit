<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>

    <title>Your Impact</title>

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


    double dailyCo2 = 0;

    double dailyDistance = 0;

    int dailyRides = 0;


    double monthlyCo2 = 0;

    double monthlyDistance = 0;

    int monthlyRides = 0;


    double yearlyCo2 = 0;

    double yearlyDistance = 0;

    int yearlyRides = 0;


    try {

        Connection con =
            com.greenmobility.DBConnection.getConnection();


        String totalSql =
            "SELECT " +

            "COUNT(*) AS total_rides, " +

            "COALESCE(SUM(distance_km), 0) " +
            "AS total_distance, " +

            "COALESCE(SUM(co2_saved_kg), 0) " +
            "AS total_co2 " +

            "FROM Bookings " +

            "WHERE student_id = ? " +

            "AND booking_status = 'Confirmed'";


        PreparedStatement totalStmt =
            con.prepareStatement(totalSql);


        totalStmt.setInt(1, studentId);


        ResultSet totalRs =
            totalStmt.executeQuery();


        if (totalRs.next()) {

            totalRides =
                totalRs.getInt("total_rides");

            totalDistance =
                totalRs.getDouble("total_distance");

            totalCo2 =
                totalRs.getDouble("total_co2");

        }


        totalRs.close();

        totalStmt.close();


        String dailySql =
            "SELECT " +

            "COUNT(*) AS rides, " +

            "COALESCE(SUM(distance_km), 0) " +
            "AS distance, " +

            "COALESCE(SUM(co2_saved_kg), 0) " +
            "AS co2 " +

            "FROM Bookings " +

            "WHERE student_id = ? " +

            "AND booking_status = 'Confirmed' " +

            "AND DATE(booked_at) = CURDATE()";


        PreparedStatement dailyStmt =
            con.prepareStatement(dailySql);


        dailyStmt.setInt(1, studentId);


        ResultSet dailyRs =
            dailyStmt.executeQuery();


        if (dailyRs.next()) {

            dailyRides =
                dailyRs.getInt("rides");

            dailyDistance =
                dailyRs.getDouble("distance");

            dailyCo2 =
                dailyRs.getDouble("co2");

        }


        dailyRs.close();

        dailyStmt.close();


        String monthlySql =
            "SELECT " +

            "COUNT(*) AS rides, " +

            "COALESCE(SUM(distance_km), 0) " +
            "AS distance, " +

            "COALESCE(SUM(co2_saved_kg), 0) " +
            "AS co2 " +

            "FROM Bookings " +

            "WHERE student_id = ? " +

            "AND booking_status = 'Confirmed' " +

            "AND YEAR(booked_at) = YEAR(CURDATE()) " +

            "AND MONTH(booked_at) = MONTH(CURDATE())";


        PreparedStatement monthlyStmt =
            con.prepareStatement(monthlySql);


        monthlyStmt.setInt(1, studentId);


        ResultSet monthlyRs =
            monthlyStmt.executeQuery();


        if (monthlyRs.next()) {

            monthlyRides =
                monthlyRs.getInt("rides");

            monthlyDistance =
                monthlyRs.getDouble("distance");

            monthlyCo2 =
                monthlyRs.getDouble("co2");

        }


        monthlyRs.close();

        monthlyStmt.close();


        String yearlySql =
            "SELECT " +

            "COUNT(*) AS rides, " +

            "COALESCE(SUM(distance_km), 0) " +
            "AS distance, " +

            "COALESCE(SUM(co2_saved_kg), 0) " +
            "AS co2 " +

            "FROM Bookings " +

            "WHERE student_id = ? " +

            "AND booking_status = 'Confirmed' " +

            "AND YEAR(booked_at) = YEAR(CURDATE())";


        PreparedStatement yearlyStmt =
            con.prepareStatement(yearlySql);


        yearlyStmt.setInt(1, studentId);


        ResultSet yearlyRs =
            yearlyStmt.executeQuery();


        if (yearlyRs.next()) {

            yearlyRides =
                yearlyRs.getInt("rides");

            yearlyDistance =
                yearlyRs.getDouble("distance");

            yearlyCo2 =
                yearlyRs.getDouble("co2");

        }


        yearlyRs.close();

        yearlyStmt.close();


        con.close();

    } catch (Exception e) {

        out.println(
            "<div class='card'>" +

            "<h2>Error loading impact data</h2>" +

            "<p>" +
            e.getMessage() +
            "</p>" +

            "</div>"
        );

    }

%>


<div class="container">


    <div class="hero-content">

        <h1>
            <%= studentName %>'s Impact
        </h1>

        <p>
            Every greener journey you take contributes
            to a cleaner and more sustainable future.
        </p>

    </div>


    <div class="section">

        <div class="section-title">

            <h2>
                Your Overall Contribution
            </h2>

            <p>
                Your complete Green Mobility journey.
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
                    Total CO2 Saved
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


        </div>

    </div>


    <div class="section">

        <div class="section-title">

            <h2>
                Your Impact Over Time
            </h2>

            <p>
                See how your contribution changes
                across different time periods.
            </p>

        </div>


        <div class="impact-grid">


            <div class="impact-card">

                <h2>
                    <%= String.format(
                        "%.2f",
                        dailyCo2
                    ) %>
                    kg
                </h2>

                <p>
                    CO2 Saved Today
                </p>

                <br>

                <p>
                    <%= dailyRides %>
                    rides
                    ·
                    <%= String.format(
                        "%.1f",
                        dailyDistance
                    ) %>
                    km
                </p>

            </div>


            <div class="impact-card">

                <h2>
                    <%= String.format(
                        "%.2f",
                        monthlyCo2
                    ) %>
                    kg
                </h2>

                <p>
                    CO2 Saved This Month
                </p>

                <br>

                <p>
                    <%= monthlyRides %>
                    rides
                    ·
                    <%= String.format(
                        "%.1f",
                        monthlyDistance
                    ) %>
                    km
                </p>

            </div>


            <div class="impact-card">

                <h2>
                    <%= String.format(
                        "%.2f",
                        yearlyCo2
                    ) %>
                    kg
                </h2>

                <p>
                    CO2 Saved This Year
                </p>

                <br>

                <p>
                    <%= yearlyRides %>
                    rides
                    ·
                    <%= String.format(
                        "%.1f",
                        yearlyDistance
                    ) %>
                    km
                </p>

            </div>


        </div>

    </div>


    <div class="section">

        <div class="section-title">

            <h2>
                Your Green Journey
            </h2>

            <p>
                See how each confirmed ride contributes
                to your environmental impact.
            </p>

        </div>


<%
    try {

        Connection con =
            com.greenmobility.DBConnection.getConnection();


        String bookingSql =
            "SELECT " +

            "b.booking_id, " +

            "b.distance_km, " +

            "b.co2_saved_kg, " +

            "b.booked_at, " +

            "v.vehicle_model, " +

            "v.fuel_type, " +

            "v.route " +

            "FROM Bookings b " +

            "JOIN Vehicles_Slots v " +

            "ON b.slot_id = v.slot_id " +

            "WHERE b.student_id = ? " +

            "AND b.booking_status = 'Confirmed' " +

            "ORDER BY b.booked_at DESC";


        PreparedStatement bookingStmt =
            con.prepareStatement(bookingSql);


        bookingStmt.setInt(1, studentId);


        ResultSet bookingRs =
            bookingStmt.executeQuery();


        boolean hasBookings = false;


        while (bookingRs.next()) {

            hasBookings = true;
%>


        <div class="card">

            <h2>
                <%= bookingRs.getString(
                    "vehicle_model"
                ) %>
            </h2>


            <p>

                <strong>
                    Route:
                </strong>

                <%= bookingRs.getString(
                    "route"
                ) %>

            </p>


            <p>

                <strong>
                    Distance:
                </strong>

                <%= String.format(
                    "%.1f",
                    bookingRs.getDouble(
                        "distance_km"
                    )
                ) %>

                km

            </p>


            <p>

                <strong>
                    Transportation:
                </strong>

                <%= bookingRs.getString(
                    "fuel_type"
                ) %>

            </p>


            <hr>


            <h3>

                CO2 Saved:

                <%= String.format(
                    "%.2f",
                    bookingRs.getDouble(
                        "co2_saved_kg"
                    )
                ) %>

                kg

            </h3>


            <p>

                <strong>
                    Booked:
                </strong>

                <%= bookingRs.getTimestamp(
                    "booked_at"
                ) %>

            </p>

        </div>


<%
        }


        if (!hasBookings) {
%>


        <div class="card">

            <h2>
                Your journey starts here.
            </h2>

            <p>
                You haven't completed any confirmed
                green rides yet.
            </p>

            <br>

            <a href="dashboard.jsp">
                Find a Ride
            </a>

        </div>


<%
        }


        bookingRs.close();

        bookingStmt.close();

        con.close();


    } catch (Exception e) {

        out.println(
            "<div class='card'>" +

            "<h2>Error loading your bookings</h2>" +

            "<p>" +
            e.getMessage() +
            "</p>" +

            "</div>"
        );

    }

%>


    </div>


    <div class="section">

        <div class="section-title">

            <h2>
                Your Contribution to a Greener India
            </h2>

        </div>


        <div class="card">

            <p>
                Every time you choose shared, electric or
                non-motorized transportation instead of an
                individual high-emission journey, you help
                reduce unnecessary fuel consumption and
                carbon emissions.
            </p>

            <br>

            <p>
                Your current estimated contribution is
                <strong>
                    <%= String.format(
                        "%.2f",
                        totalCo2
                    ) %>
                    kg
                </strong>
                of CO2 savings through confirmed
                Green Mobility rides.
            </p>

            <br>

            <p>
                When thousands of students make similar
                choices, these individual contributions can
                collectively support cleaner campuses,
                reduced congestion and more sustainable
                transportation habits across India.
            </p>

        </div>

    </div>


</div>

</body>

</html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>Monthly Green Mobility Summary</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>

<div class="container">

<h1>Monthly Emission Summary</h1>

<table>
    <tr>
        <th>Month</th>
        <th>Total Bookings</th>
        <th>Total Distance (km)</th>
        <th>Total CO2 Saved (kg)</th>
    </tr>

<%
    try {

        Connection con =
            com.greenmobility.DBConnection.getConnection();

        String sql =
            "SELECT " +
            "DATE_FORMAT(booked_at, '%Y-%m') AS month, " +
            "COUNT(*) AS total_bookings, " +
            "SUM(distance_km) AS total_distance, " +
            "SUM(co2_saved_kg) AS total_co2 " +
            "FROM Bookings " +
            "GROUP BY DATE_FORMAT(booked_at, '%Y-%m') " +
            "ORDER BY month DESC";

        PreparedStatement stmt =
            con.prepareStatement(sql);

        ResultSet rs =
            stmt.executeQuery();

        while (rs.next()) {
%>

    <tr>

        <td>
            <%= rs.getString("month") %>
        </td>

        <td>
            <%= rs.getInt("total_bookings") %>
        </td>

        <td>
            <%= String.format("%.2f",
                rs.getDouble("total_distance")) %>
        </td>

        <td>
            <%= String.format("%.2f",
                rs.getDouble("total_co2")) %>
            kg
        </td>

    </tr>

<%
        }

        rs.close();
        stmt.close();
        con.close();

    } catch (Exception e) {

        out.println(
            "<p>Error loading monthly summary: "
            + e.getMessage()
            + "</p>"
        );
    }
%>

</table>

<br>

<a href="leaderboard.jsp">
    View Leaderboard
</a>

<br><br>

<a href="slots.jsp">
    Book a Ride
</a>
</div>

</body>
</html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>CO2 Savings Leaderboard</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>

<div class="container">

<h1>CO2 Savings Leaderboard</h1>

<table>

    <tr>
        <th>Rank</th>
        <th>Student</th>
        <th>Email</th>
        <th>CO2 Saved (kg)</th>
    </tr>

<%
    try {

        Connection con =
            com.greenmobility.DBConnection.getConnection();

        String sql =
            "SELECT name, email, total_co2_saved_kg " +
            "FROM Students " +
            "ORDER BY total_co2_saved_kg DESC";

        PreparedStatement stmt =
            con.prepareStatement(sql);

        ResultSet rs =
            stmt.executeQuery();

        int rank = 1;

        while (rs.next()) {
%>

    <tr>

        <td>
            <%= rank %>
        </td>

        <td>
            <%= rs.getString("name") %>
        </td>

        <td>
            <%= rs.getString("email") %>
        </td>

        <td>
            <%= String.format("%.2f",
                rs.getDouble("total_co2_saved_kg")) %>
            kg
        </td>

    </tr>

<%
            rank++;
        }

        rs.close();
        stmt.close();
        con.close();

    } catch (Exception e) {

        out.println(
            "<p>Error loading leaderboard: "
            + e.getMessage()
            + "</p>"
        );
    }
%>

</table>

<br>

<a href="slots.jsp">
    Book a Ride
</a>

<br><br>

<a href="mybookings.jsp">
    My Bookings
</a>
</div>

</body>
</html>
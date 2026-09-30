<%@ page import="java.sql.*" %>

<%
    String name = request.getParameter("name");
    String email = request.getParameter("email");

    try {
        Connection con = com.greenmobility.DBConnection.getConnection();

        String checkSql = "SELECT student_id FROM Students WHERE email = ?";
        PreparedStatement checkStmt = con.prepareStatement(checkSql);
        checkStmt.setString(1, email);

        ResultSet rs = checkStmt.executeQuery();

        int studentId;

        if (rs.next()) {

            studentId = rs.getInt("student_id");

        } else {

            String insertSql =
                "INSERT INTO Students (name, email) VALUES (?, ?)";

            PreparedStatement insertStmt =
                con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);

            insertStmt.setString(1, name);
            insertStmt.setString(2, email);

            insertStmt.executeUpdate();

            ResultSet generatedKeys =
                insertStmt.getGeneratedKeys();

            generatedKeys.next();

            studentId = generatedKeys.getInt(1);

            insertStmt.close();
        }

        session.setAttribute("studentId", studentId);
        session.setAttribute("studentName", name);

        con.close();

        response.sendRedirect("dashboard.jsp");

    } catch (Exception e) {
        out.println("<h2>Something went wrong!</h2>");
        out.println("<p>" + e.getMessage() + "</p>");
    }
%>
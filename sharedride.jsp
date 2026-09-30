<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>

<head>
    <title>Shared Ride</title>
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


    <div class="hero-content">

        <h1>Shared Ride</h1>

        <p>
            Travel together with students going
            the same way and make your journey greener.
        </p>

    </div>


    <div class="dashboard-grid">


        <div class="card">

            <h2>Create a Shared Ride</h2>

            <p>
                Choose a transport slot and create a
                private shared ride for your group.
            </p>

            <br>

            <a href="createRide.jsp">
                Create Shared Ride
            </a>

        </div>


        <div class="card">

            <h2>Join a Shared Ride</h2>

            <p>
                Have a share code from another student?
                Enter it to join their specific ride.
            </p>

            <br>

            <form action="joinRide.jsp" method="post">

                <label>
                    Shared Ride Code
                </label>

                <input
                    type="text"
                    name="shareCode"
                    placeholder="Enter ride code"
                    required
                >

                <br>

                <button type="submit">
                    Join Ride
                </button>

            </form>

        </div>


    </div>


    <div class="card">

        <h2>How Shared Rides Work</h2>

        <p>
            1. Create or receive a shared ride code.
        </p>

        <p>
            2. Students with the code can join
            the specific vehicle.
        </p>

        <p>
            3. Every participant gets their own
            contribution recorded.
        </p>

        <p>
            4. If one student cancels, only that
            student's participation is cancelled.
        </p>

        <p>
            5. The vehicle and other participants
            remain unaffected.
        </p>

    </div>


</div>

</body>

</html>
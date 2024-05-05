# Tripinsights

The application hosted in this repo is a heavily modified and recreated version of the original [My Driving application](https://github.com/Azure-Samples/MyDriving).

## Contents
You work for Humongous Insurance. One of their products provides customers the opportunity to qualify for lower car insurance rates. Customers can do this by opting in to use Humongous Insurance's TripInsights app, which collects data about their driving habits. Your team has been assigned to modernize the application and move it to the cloud.

The TripInsights application, once a monolith, has been refactored into a number of microservices:

![Untitled](./images/ApplicationArchitecture.png)

- **Trip Viewer WebApp (`.NET Core`)**: Your customers use this web application to review their driving scores and trips. The trips are being simulated against the APIs within the OpenHack environment.
- **Trip API (`Go`)**: The mobile application sends the vehicle's on-board diagnostics (OBD) trip data to this API to be stored.
- **Points of Interest API (`.NET Core`)**: This API is used to collect the points of the trip when a hard stop or hard acceleration was detected.
- **User Profile API (`NodeJS`)**: This API is used by the application to read the user's profile information.
- **User API (`Java`)**: This API is used by the application to create and modify the users.

The source code of all the microservices is available in this repo.
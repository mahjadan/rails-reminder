
# Rails Reminder

Rails Reminder is a web application that allows users to create, update, and receive notifications for reminders. Users can easily manage their reminders and snooze them as needed. The application utilizes various technologies and frameworks, including Rails 7, Action Cable, Stimulus, Redis, Sidekiq job processing, Postgres database, and Turbo Streams.


## Demo 
you can access this [link](https://reminder.masjidsinfo.com) to try it. 
## Features

- **Reminder Management:** Users can create new reminders, update existing ones, and delete reminders they no longer need. The application provides a user-friendly interface for managing reminders efficiently.

- **Notification System:** When a reminder's due time arrives, users receive real-time notifications thanks to the integration of Action Cable. Users are instantly informed about their upcoming tasks, ensuring they don't miss important events.

- **Snooze Functionality:** Users have the ability to snooze reminders, providing flexibility in managing their schedule. The snooze feature allows users to temporarily delay reminders and reschedule them for a more convenient time.

## Technology Stack

The Rails Reminder application is built using the following technologies:

- **Ruby:** Version 3.1.1 is used as the programming language for the application.

- **Rails:** The application is developed on Rails 7, a powerful web development framework that provides a robust foundation for building scalable and maintainable web applications.

- **Action Cable:** Action Cable is utilized to implement real-time communication and enable instant notifications for reminder events.

- **Stimulus:** Stimulus, a JavaScript framework, is used to enhance the interactivity and responsiveness of the application's user interface.

- **Redis:** Redis, an in-memory data store, is employed as a backend for Action Cable to facilitate the real-time communication between the server and clients.

- **Sidekiq:** Sidekiq is used as a background job processing system to handle time-consuming tasks and improve the application's performance.

- **Postgres:** PostgreSQL is chosen as the database management system for storing and retrieving reminder data.

- **Turbo Streams:** Turbo Streams is used to update the user interface with real-time changes without the need for full page reloads.

## Installation

To run the Rails Reminder application locally, follow these steps:

1. Clone the GitHub repository:

   ```
   git clone https://github.com/mahjadan/rails-reminder.git
   ```

2. Install the required dependencies using Bundler:

   ```
   cd rails-reminder
   bin/bundle install
   ```

3. Set up the PostgreSQL database. Update the `config/database.yml` file with your database credentials.

4. Perform database migrations:

   ```
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

5. Start the Redis server.

6. Start the Sidekiq job processing system:

   ```
   bin/bundle exec sidekiq
   ```

7. Start the Rails server:

   ```
   bin/dev
   ```

8. Access the application by visiting `http://localhost:3000` in your web browser.

Feel free to explore the code and contribute to the Rails Reminder application by submitting pull requests or reporting any issues you encounter.

For more detailed information and documentation, please visit the [Rails Reminder GitHub repository](https://github.com/mahjadan/rails-reminder).

## Todo

- Implement additional features, such as recurring reminders, tags, and sharing reminders with other users.
- Enhance the user interface to improve usability and provide a seamless experience. ( user login, registration, editing...).
- Optimize performance and scalability to handle a larger number of reminders and users.

We welcome contributions and suggestions to help us improve and expand the functionality of the Rails Reminder application.

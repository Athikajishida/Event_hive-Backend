# Event Hive - Backend

## Overview

Event Hive is a backend system for an Event Booking System that supports two user roles:  
- **Event Organizers**: Can create, read, update, and manage events.  
- **Customers**: Can book tickets for events.  

The API is built using **Ruby on Rails 8**, with **Sidekiq** for background jobs and **Redis** for job queue management.

## Features

- **User Authentication & Role-based Access Control**
- **Event Management (CRUD)**
- **Ticket Booking System**
- **Asynchronous Email Notifications using Sidekiq**
- **RESTful API Endpoints**
- **PostgreSQL Database**

## Tech Stack

- **Backend:** Ruby on Rails 8 (Ruby 3.2.2)
- **Database:** PostgreSQL
- **Background Jobs:** Sidekiq + Redis
- **Authentication:** bcrypt & JWT

## Setup Instructions

### Prerequisites

Make sure you have installed:  
- Ruby 3.2.2  
- Rails 8+  
- PostgreSQL  
- Redis  

### Installation Steps

1. **Clone the Repository**
   ```sh
   git clone https://github.com/Athikajishida/Event_hive-Backend.git
   cd Event_hive-Backend
2. **Install Dependencies**
   ```sh
   bundle install

3. **Set up Database**
   ```sh
   rails db:create db:migrate db:seed
4. **Run Redis (Required for Sidekiq)**
   ```sh
   redis-server
5. **Start the Sidekiq Worker**
   ```sh
   bundle exec sidekiq

6. **Start the Rails Server**
   ```sh
   rails s




